| variable animator with GROUP TAG support
| PHREDA 2023 / extended with group tags 2026
|
| === GROUP TAG (4 bits, values 0-15) ===
| stored in bits 0-3 of the timeline entry's high word
| Group 0 = default (no group), compatible with original varanim
|
| API :
| vaini      | max --
| vareset    | --
| +vanim     | 'var ini fin ease dur. start --        (group=0)
| +vanim-g   | 'var ini fin ease dur. start group --  (group 0-15)
| +vboxanim  | 'var fin ini ease dur. start --
| +vboxanim-g| 'var fin ini ease dur. start group --
| +vxyanim   | 'var ini fin ease dur. start --
| +vxyanim-g | 'var ini fin ease dur. start group --
| +vcolanim  | 'var ini fin ease dur. start --
| +vcolanim-g| 'var ini fin ease dur. start group --
| +vexe      | 'vector start --
| +vvexe     | v 'vector start --
| +vvvexe    | v v 'vector start --
| vupdate    | --
| vkill-group| group --    elimina todos los eventos del grupo
| vkill-var  | 'var --     elimina todos los eventos de esa variable
| vaempty    | -- n        cantidad de slots usados
|
| === FORMAT ENTRY iN TIMELINE (8 bytes) ===
| bits 63-32  time ini (ms, $ffffffff = invalido)
| bits 31-20  index in exevar (12 bits, hasta 4096 entradas)
| bits 19-16  GROUP TAG (4 bits, 0-15)
| bits 15-0   type (0=val, 1=box, 2=xy, 3=col) in bits 1-0

^r3/lib/mem.r3
^r3/lib/color.r3
^r3/util/penner.r3

|.... time control
#prevt
#timenow
##deltatime
| time         execute      end
##timeline  ##timeline<  ##timeline>
| ini | fin | ease ms | 'VAR
##exevar
#maxcnt

| -------------------------------------------------------
| RESET
| -------------------------------------------------------
::vareset
    0 'timenow !
    msec 'prevt !
    timeline dup 'timeline< ! 'timeline> !
    exevar -1 maxcnt 2 << fill
    ;

::vaini | max --
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

:incol | 4 8bits
    >a a@+ a@+
    b> 8 >> $ff and colmix a@ ! ;

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
    @+ 0? ( drop nip @+ ex drop remlist "r" .println ; )              | l1 tn ex+ v .. l1
    rot                            | var X t0
    over $fffffff and 16 <</      | var X t0 tmax
    $ffff >=? ( 2drop remlast ; )  | var X f x
    swap 32 >> ease                | fn f->f
    >b a> ex ;

:tictline | ; add to execlist
    timeline< timenow
    ( over
        timeline> =? ( 'timeline< ! 2drop ; )
        @ $fffffff and >=? swap
        dup @ $fffffff nand timenow or over !
        8 + swap ) drop
    'timeline< !
    ;
	
::vupdate | --
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

:addint | 'var ini fin ease dur. -- nro
    1000 *. $fffffff and  | duracion ms
    swap $ff and 32 << or  | ease
    +ev ;

| -------------------------------------------------------
| PUBLIC: group=0
| -------------------------------------------------------
::+vanim | 'var ini fin ease dur. start --
    >r addint r> +tline ;

::+vboxanim | 'var fin ini ease dur. start --
    >r addint $10000 or r> +tline ;

::+vxyanim | 'var ini fin ease dur. start --
    >r addint $20000 or r> +tline ;

::+vcolanim | 'var ini fin ease dur. start --
    >r addint $30000 or r> +tline ;

| -------------------------------------------------------
| PUBLIC: group 0-15
| -------------------------------------------------------

::+vanimg | 'var ini fin ease dur. start group --
    >r >r addint r> r> +tlineg ;

::+vboxanimg | 'var fin ini ease dur. start group --
    >r >r addint $10000 or r> r> +tlineg ;

::+vxyanimg | 'var ini fin ease dur. start group --
    >r >r addint $20000 or r> r> +tlineg ;

::+vcolanimg | 'var ini fin ease dur. start group --
    >r >r addint $30000 or r> r> +tlineg ;

| -------------------------------------------------------
| PUBLIC: EXE EVENTS (sin grupo, como original)
| -------------------------------------------------------
::+vexe | 'vector start --
    swap dup dup 0 +ev swap +tline ;

::+vvexe | v 'vector start --
    swap rot over 0 +ev swap +tline ;

::+vvvexe | v v 'vector start --
    >r 0 +ev r> +tline ;

| -------------------------------------------------------
| PUBLIC: KILL BY GROUP
| -------------------------------------------------------
:remlist2 | 'list -- 'list ; remove from lista
	8 -
    -1 over @ 32 >> $ffff and 5 << exevar + !  | mark empty
    dup dup 8 + timeline> over - 3 >> move
    -8 'timeline> +! 
	timeline< <? ( -8 'timeline< +! ) ;

::vkillgroup | group --
	$f and 28 <<
	timeline
	( timeline> <?
		@+ $f0000000 and
		pick2 =? ( swap remlist2 swap ) drop
		) 2drop ;

| -------------------------------------------------------
| PUBLIC: KILL BY VAR ADDRESS
| -------------------------------------------------------

::vkillvar | 'var --
	timeline
	( timeline> <?
		@+ 32 >> $fff and 5 << exevar + 16 + @
		pick2 =? ( swap remlist2 swap ) drop
		) 2drop ;

| -------------------------------------------------------
| PUBLIC: PACK / UNPACK
| -------------------------------------------------------
::64xy | b -- x y
    dup 48 >> swap 16 << 48 >> ;

::64wh | b -- w h
    dup 32 << 48 >> swap 48 << 48 >> ;

::64xywh | b -- x y w h
    dup 48 >> swap dup 16 << 48 >> swap
    dup 32 << 48 >> swap 48 << 48 >> ;

::xywh64 | x y w h -- b
    $ffff and swap
    $ffff and 16 << or swap
    $ffff and 32 << or swap
    $ffff and 48 << or ;

| --- for sprite
::64xyrz | b -- x y r z
    dup 48 >> swap dup 16 << 48 >> swap
    dup 32 << 48 >> 2 << swap 48 << 48 >> 4 << ;

::xyrz64 | x y r z -- b
    4 >> $ffff and swap
    2 >> $ffff and 16 << or swap
    $ffff and 32 << or swap
    $ffff and 48 << or ;

| --- for rect
::64box | b adr --
    swap
    dup 48 >> rot d!+
    swap dup 16 << 48 >> rot d!+
    swap dup 32 << 48 >> rot d!+
    swap 48 << 48 >> swap d! ;

| --- for xy
::32xy | b -- x y
    dup 32 >> swap 32 << 32 >> ;

::xy32 | x y -- b
    $ffffffff and swap 32 >> $ffffffff and or ;

| -------------------------------------------------------
| PUBLIC: UTILS
| -------------------------------------------------------
::vaempty
    timeline> timeline - 3 >> ;
