| variable animator with GROUP TAG support
| PHREDA 2023 / extended with group tags 2026
|
| vaini		| max --

| +vanim    | 'var fin ini ease dur. start --
| +vboxanim | 'var fin ini ease dur. start --
| +vxyanim  | 'var fin ini ease dur. start --
| +vcolanim | 'var fin ini ease dur. start --

| +vanimg    | 'var fin ini ease dur. start group --
| +vboxanimg | 'var fin ini ease dur. start group --
| +vxyanimg  | 'var fin ini ease dur. start group --
| +vcolanimg | 'var fin ini ease dur. start group --

| ---exe in 3.0 seconds 
| +vexe		| 'exe 3.0 --
| +vvexe	| v1 'exe1 3.0 --
| +vvvexe	| v1 v2 'exe2 3.0 --
| +vexeg	| 'exe 3.0 group --
| +vvexeg	| v1 'exe1 3.0 group --
| +vvvexeg	| v1 v2 'exe2 3.0 group --

| ---update 
| vupdate	| --

| vareset    | -- 			kill all events
| vkillgroup | group --		kill for group
| vkillvar   | 'var --		kill for 'var
| vaempty    | -- n			cnt now
|
| the exe words receive the ADDRESS of the stored parameters and must leave it
| on the stack (it is dropped after the call): 'exe | adr -- adr
| vvexe: get param >>	dup @ -> adr v1
| vvvexe: get param >>	dup @+ swap @ -> adr v2 v1

^r3/lib/mem.r3
^r3/lib/color.r3
^r3/util/penner.r3

|.... time control
#prevt
#timenow
##deltatime | milliseconds between the last two vupdate or timer. calls
| time         execute      end
##timeline | start of the event list (8 bytes per event, sorted by start time)
##timeline< | end of the events already running in the list
##timeline> | end of the event list
| ease ms | ini | fin | 'VAR
##exevar | table with the data of each event (32 bytes: +0 ease and duration, +8 ini, +16 fin, +24 variable; the exe events keep 0, 'exe and the parameters)
#maxcnt

::timer< | -- ; reset the timer (deltatime = 0)
	msec 'prevt ! 0 'deltatime ! ;
::timer. | -- ; update the timer: deltatime = milliseconds since the previous call
	msec dup prevt - 'deltatime ! 'prevt ! ;
::timer+ | n -- n' ; add deltatime to n
	deltatime + ;
| $ffffffff7fffffff and  ; 	| for ring counter
::timer- | n -- n' ; subtract deltatime from n
	deltatime - ;

| -------------------------------------------------------
| RESET
| -------------------------------------------------------
::vareset | -- ; remove all the events and restart the animation clock
    0 'timenow !
    msec 'prevt !
    timeline dup 'timeline< ! 'timeline> !
    exevar -1 maxcnt 2 << fill
    ;

::vaini | max -- ; reserve at here the memory for up to max events at the same time and reset
    dup 'maxcnt !
    3 <<
    here
    dup 'timeline ! over +
    dup 'exevar ! swap 2 << +
    'here !
    vareset ;

| -------------------------------------------------------
| INTERPOLATORS
| -------------------------------------------------------
| adr -> ini fin var
:inval | 1 64bit
    >a a@+ a@+
    over - b> *. + a@ ! ;

:inbox | 4 16bits
    >a a@+ a@+
    over 48 >> over 48 >> over - b> *. + 48 << -rot
    over 16 << 48 >> over 16 << 48 >> over - b> *. + $ffff and 32 << -rot
    over 32 << 48 >> over 32 << 48 >> over - b> *. + $ffff and 16 << -rot
    swap 48 << 48 >> swap 48 << 48 >> over - b> *. + $ffff and
    or or or a@ ! ;

:inxy | 2 32bits
    >a a@+ a@+
    over 32 >> over 32 >> over - b> *. + 32 << -rot
    swap 32 << 32 >> swap 32 << 32 >> over - b> *. + $ffffffff and
    or a@ ! ;

:incol | 4 8bits $AARRGGBB, the four channels (alpha included) are mixed
    >a a@+ a@+ b> 8 >> $ff clamp0max >r
    2dup r@ colmix $ffffff and       | ini fin rgb
    -rot 24 >> $ff and swap 24 >> $ff and swap | rgb ia fa
    r> colmix $ff and 24 << or a@ ! ;

#inlist inval inbox inxy incol

| -------------------------------------------------------
| TIMELINE INTERNAL
| -------------------------------------------------------
:remlast | 'list X -- 'list
    8 + @+ swap @ !  | set fin
:remlist | 'list -- 'list ; remove from lista
	8 -
    -1 over @ 32 >> $ffff and 5 << exevar + !  | mark empty
    dup dup 8 + timeline> over - 3 >> move
    -8 'timeline> +! -8 'timeline< +!
    ;

:execinterp | 'list var -- 'list
    timenow over $fffffff and -   | actual-inicio=t0   | 'l1 var tn
    over 48 >> $3 and 3 << 'inlist + @ >a |'interp !
    swap 32 >> $ffff and 5 << exevar +     | 'list T0 VAR      | 'l1 tn ex
    @+ 0? ( drop nip @+ ex drop remlist ; )              | l1 tn ex+ v .. l1
    rot                            | var X t0
    over $fffffff and 16 <</      | var X t0 tmax
    $ffff >=? ( 2drop remlast ; )  | var X f x
    swap 32 >> ease                | fn f->f
    >b a> ex ;

:tictline | ; add to execlist
    timeline< timenow
    ( over
        timeline> =? ( 'timeline< ! 2drop ; )
        @ $fffffff and >=? swap 8 + swap ) drop
    'timeline< !
    ;
	
::vupdate | -- ; advance the animations with the time elapsed since the last call (once per frame): starts the events whose time has come, updates the variables and removes the finished ones
    ab[
    msec dup prevt - swap 'prevt ! dup 'deltatime ! 'timenow +!
    tictline
    timeline ( timeline< <?
        @+ execinterp ) drop
    ]ba ;

| -------------------------------------------------------
| SEARCH & INSERT IN TIMELINE
| -------------------------------------------------------
:searchless | time adr --time adr
    ( 8 - timeline >=?
        dup @ $fffffff and | time adr time
        pick2 <=? ( drop 8 + ; )
        drop ) 8 + ;

:+tline | info time --
    1000 *. timenow +
    timeline> searchless | adr
    dup dup 8 + swap timeline> over - 3 >> move>
    rot 32 << rot or swap !
    8 'timeline> +! ;

:+tlineg | info time group --
	$f and 28 << >r
    1000 *. timenow +
    timeline> searchless | adr
    dup dup 8 + swap timeline> over - 3 >> move>
    rot 32 << rot or r> or swap !
    8 'timeline> +! ;

| -------------------------------------------------------
| EXEVAR SLOT MANAGEMENT
| -------------------------------------------------------
:findempty | -- firstempty
    exevar ( @+ -1 <>? drop 24 + ) drop 8 - ;

:+ev | a b c d -- n
    findempty !+ !+ !+ !+ exevar - 5 >> 1- ;

:addint | 'var fin ini ease dur. -- nro
    1000 *. $fffffff and  | duracion ms
    swap $ff and 32 << or  | ease
    +ev ;

| -------------------------------------------------------
| PUBLIC: ADD EVENT
| -------------------------------------------------------
::+vanim | 'var fin ini ease dur. start -- ; animate the cell 'var from ini to fin (the first value is the destination); ease = easing number (0 linear, 1 Quad_In... see ease in penner.r3), dur. and start in seconds (fixed point); the animation starts at the first vupdate after start
	0
::+vanimg | 'var fin ini ease dur. start group -- ; like +vanim in a group (0..15) that vkillgroup can remove
    >r >r addint r> r> +tlineg ;

::+vboxanim | 'var fin ini ease dur. start -- ; animate the four 16-bit values packed in the cell (see xywh64), each one on its own
	0 
::+vboxanimg | 'var fin ini ease dur. start group -- ; like +vboxanim in a group (0..15)
    >r >r addint $10000 or r> r> +tlineg ;

::+vxyanim | 'var fin ini ease dur. start -- ; animate the two 32-bit values packed in the cell (see xy32), each one on its own
	0
::+vxyanimg | 'var fin ini ease dur. start group -- ; like +vxyanim in a group (0..15)
    >r >r addint $20000 or r> r> +tlineg ;
	
::+vcolanim | 'var fin ini ease dur. start -- ; animate a color $AARRGGBB mixing ini and fin channel by channel (alpha included)
	0
::+vcolanimg | 'var fin ini ease dur. start group -- ; like +vcolanim in a group (0..15)
    >r >r addint $30000 or r> r> +tlineg ;

| -------------------------------------------------------
| PUBLIC: EXE EVENTS
| -------------------------------------------------------
::+vexe | 'exe start -- ; execute 'exe once after start seconds; 'exe receives the address of the stored parameters and must leave it on the stack
|    swap dup dup 0 +ev swap +tline ;
	0
::+vexeg | 'exe start group -- ; like +vexe in a group (0..15)
    >r swap dup dup 0 +ev swap r> +tlineg ;

::+vvexe | v 'exe start -- ; like +vexe with a parameter: 'exe receives an address and reads v with dup @
    |swap rot over 0 +ev swap +tline ;
	0
::+vvexeg | v 'exe start group -- ; like +vvexe in a group (0..15)
	>r swap rot over 0 +ev swap r> +tlineg ;

::+vvvexe | v1 v2 'exe start -- ; like +vexe with two parameters: 'exe reads them with dup @+ swap @ (v2 deeper, v1 on top) and leaves the address
    |>r 0 +ev r> +tline ;
	0
::+vvvexeg | v1 v2 'exe start group -- ; like +vvvexe in a group (0..15)
    >r >r 0 +ev r> r> +tlineg ;

| -------------------------------------------------------
| PUBLIC: KILL BY GROUP
| -------------------------------------------------------
:remlist2 | 'list -- 'list ; remove from lista
	8 -
    -1 over @ 32 >> $ffff and 5 << exevar + !  | mark empty
    dup dup 8 + timeline> over - 3 >> move
    -8 'timeline> +! 
	timeline< <? ( -8 'timeline< +! ) ;

::vkillgroup | group -- ; remove all the events of the group (0..15)
	$f and 28 <<
	timeline
	( timeline> <?
		@+ $f0000000 and
		pick2 =? ( swap remlist2 swap ) drop
		) 2drop ;

| -------------------------------------------------------
| PUBLIC: KILL BY VAR ADDRESS
| -------------------------------------------------------

::vkillvar | 'var -- ; remove the animations of the variable 'var
	timeline
	( timeline> <?
		@+ 32 >> $ffff and 5 << exevar + 24 + @
		pick2 =? ( swap remlist2 swap ) drop
		) 2drop ;

| -------------------------------------------------------
| PUBLIC: PACK / UNPACK
| -------------------------------------------------------
::64xy | b -- x y ; unpack the first two signed 16-bit values (x in the highest 16 bits)
    dup 48 >> swap 16 << 48 >> ;

::64wh | b -- w h ; unpack the last two signed 16-bit values
    dup 32 << 48 >> swap 48 << 48 >> ;

::64xywh | b -- x y w h ; unpack four signed 16-bit values
    dup 48 >> swap dup 16 << 48 >> swap
    dup 32 << 48 >> swap 48 << 48 >> ;

::xywh64 | x y w h -- b ; pack four 16-bit values (x in the highest 16 bits)
    $ffff and swap
    $ffff and 16 << or swap
    $ffff and 32 << or swap
    $ffff and 48 << or ;

| --- for sprite
::64xyrz | b -- x y r z ; unpack a sprite: x y in 16 bits, r (rotation) with 2 bits less of precision and z (zoom) with 4 bits less
    dup 48 >> swap dup 16 << 48 >> swap
    dup 32 << 48 >> 2 << swap 48 << 48 >> 4 << ;

::xyrz64 | x y r z -- b ; pack a sprite (see 64xyrz)
    4 >> $ffff and swap
    2 >> $ffff and 16 << or swap
    $ffff and 32 << or swap
    $ffff and 48 << or ;

| --- for rect
::64box | b adr -- ; write the four 16-bit values of b as four dwords x y w h at adr (an SDL_Rect)
    swap
    dup 48 >> rot d!+
    swap dup 16 << 48 >> rot d!+
    swap dup 32 << 48 >> rot d!+
    swap 48 << 48 >> swap d! ;

| --- for xy
::32xy | b -- x y ; unpack two signed 32-bit values (x in the high half)
    dup 32 >> swap 32 << 32 >> ;

::xy32 | x y -- b ; pack two 32-bit values (x in the high half)
    $ffffffff and swap 32 << or ;

| -------------------------------------------------------
| PUBLIC: UTILS
| -------------------------------------------------------
::vaempty | -- n ; number of events in the list (waiting or running)
    timeline> timeline - 3 >> ;

|------------ FRAME ANIMATION
|init(12) cnt(8) now(8) ms(12) acc(24)  = 64 bits
|63..52   51..44   43..36  35..24  23..0
::aniInit | ini cnt fps -- V ; value of a frame animation: first frame ini (12 bits), cnt frames (up to 256) and fps in fixed point (10.0 = 10 frames per second, 0 = still)
	0? ( 2drop 0 1.0 )				| 0fps is still
	1000.0 swap / $fff and 24 <<	| ms x frame
	swap $ff and 44 << or	| cnt (0 = still)
	swap $fff and 52 << or ;		| init

::ani+! | dt 'V -- ; advance the frame animation in 'V by dt milliseconds (time over one frame is lost); after the last frame it goes back to the first
	swap over +! 
	dup @ dup $ffffff and	| 'v val acc
	over 24 >> $fff and -	| 'v val acc-ms ( acc-ms)
	-? ( 3drop ; ) 
	over 36 >> $ff and 1+	| 'v val nacc nnow
	pick2 44 >> $ff and		| 'v val nacc nnow cnt
	>=? ( 0 nip )			| 'v val nacc now
	36 << or				| 'v val nn
	swap $ff000ffffff nand or
	swap ! ;
	
|::ani+! | dt 'V -- ; advance the frame animation in 'V by dt milliseconds: as many frames as dt covers (the time left over is kept); after the last frame it goes back to the first
|	swap over +!				| 'V ; acc+dt
|	dup @ dup $ffffff and		| 'V val acc
|	over 24 >> $fff and 1 max	| 'V val acc ms
|	/mod swap				| 'V val rem q
|	0? ( 2drop 2drop ; )
|	pick2 36 >> $ff and +		| 'V val rem now+q
|	pick2 44 >> $ff and 1 max mod	| 'V val rem now
|	36 << or				| 'V val nn
|	swap $ff000ffffff nand or
|	swap ! ;	
	
::aniFrame | V -- f ; current frame number (ini + step)
	dup 36 >> $ff and swap 52 >> $fff and + ;

::aniCnt | V -- n ; current step 0..cnt-1 of the animation (it is not the number of frames)
	36 >> $ff and ;

::ani+timer! | 'V -- ; advance the frame animation in 'V by deltatime
	deltatime swap ani+! ;