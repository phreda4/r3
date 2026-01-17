| variable animator
| PHREDA 2023
|
| vaini | max --
| vareset | -- 
| ---start 1.0 seconds, go from 10 to 100 in 2.0 seconds with 1 penner function
| +vanim | 'var 100 10 1 2.0 1.0 -- 
| ---exe in 3.0 seconds 
| +vexe | 'exe 3.0 --
| +vvexe | v1 'exe1 3.0 --
| +vvvexe | v1 v2 'exe2 3.0 --
| ---update 
| vupdate | --
|
| vvexe: get param >>	dup @ -> v1
| vvvexe: get param >>	dup @+ swap @ -> v2 v1
|
^r3/lib/mem.r3
^r3/lib/color.r3
^r3/util/penner.r3

|.... time control
#prevt
#timenow
##deltatime
| time		execute		end
##timeline	##timeline<	##timeline> 
| ini | fin | ease ms | 'VAR
##exevar 
#maxcnt

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

:tictline | ; add to execlist
	timeline< timenow
	( over
		timeline> =? ( 'timeline< ! 2drop ; )
		@ $ffffffff and >=? swap 
		dup @ $ffffffff nand timenow or over !
		8 + swap ) drop
	'timeline< ! 
	;

|-----
:remlast | 'list X -- 'list
	8 + @+ swap @ !  | set fin
:remlist | 'list -- 'list ; remove from lista
	-1 over 8 - @ 32 >> $ffff and 5 << exevar + !	| mark empty
	dup 8 - over timeline> over - 3 >> move
	-8 'timeline> +! -8 'timeline< +!
	8 - ;
	
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

:execinterp | 'list var -- 'list
	timenow over $ffffffff and -	| actual-inicio=t0	| 'l1 var tn
	over 48 >> $3 and 3 << 'inlist + @ >a |'interp !
	swap 32 >> $ffff and 5 << exevar +		| 'list T0 VAR		| 'l1 tn ex
	@+ 0? ( drop nip @+ ex drop remlist ; )				| l1 tn ex+ v .. l1
	rot								| var X t0
	over $ffffffff and 16 <</		| var X t0 tmax
	$ffff >=? ( 2drop remlast ; )		| var X f x 	
	swap 32 >> ease				| fn f->f
	>b a> ex ;

::vupdate | --
	ab[
	msec dup prevt - swap 'prevt ! dup 'deltatime ! 'timenow +!
	tictline
	timeline ( timeline< <? 
		@+ execinterp ) drop 
	]ba ;

:searchless | time adr --time adr
	( 8 - timeline >=?
		dup @ $ffffffff and | time adr time
		pick2 <=? ( drop 8 + ; )
		drop ) 8 + ;

:+tline	| info time --
	1000 *. timenow + 
	timeline> searchless | adr
	dup dup 8 + swap timeline> over - 3 >> move> 
	rot 32 << rot or swap ! 
	8 'timeline> +! ;

:findempty | -- firstempty
	exevar ( @+ -1 <>? drop 24 + ) drop 8 - ;
	
:+ev | a b c d -- n
	findempty !+ !+ !+ !+ exevar - 5 >> 1- ;

:addint | 'var ini fin ease dur. -- nro
	1000 *. $ffffffff and	| duracion ms
	swap $ff and 32 << or	| ease
	+ev ;
	
::+vanim | 'var ini fin ease dur. start --
	>r addint r> +tline ;

::+vboxanim | 'var fin ini ease dur. start --
	>r addint $10000 or r> +tline ;

::+vxyanim | 'var ini fin ease dur. start --
	>r addint $20000 or r> +tline ;

::+vcolanim | 'var ini fin ease dur. start --
	>r addint $30000 or r> +tline ;
	
::+vexe | 'vector start --
	swap dup dup 0 +ev swap +tline ;

::+vvexe | v 'vector start --
	swap rot over 0 +ev swap +tline ;

::+vvvexe | v v 'vector start --
	>r 0 +ev r> +tline ;

|-------------- pack / unpack
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

|--- for sprite
::64xyrz | b -- x y r z
	dup 48 >> swap dup 16 << 48 >> swap
	dup 32 << 48 >> 2 << swap 48 << 48 >> 4 << ;
	
::xyrz64 | x y r z -- b
	4 >> $ffff and swap
	2 >> $ffff and 16 << or swap
	$ffff and 32 << or swap
	$ffff and 48 << or ;

|--- for rect
::64box | b adr --
	swap
	dup 48 >> rot d!+
	swap dup 16 << 48 >> rot d!+
	swap dup 32 << 48 >> rot d!+
	swap 48 << 48 >> swap d! ;		
	
|--- for xy	
::32xy | b -- x y 
	dup 32 >> swap 32 << 32 >> ;
	
::xy32 | x y -- b
	$ffffffff and swap 32 >> $ffffffff and or ;

::vaempty
	timeline> timeline - 3 >> ;