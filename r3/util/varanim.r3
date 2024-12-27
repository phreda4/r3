| variable animator
| PHREDA 2023
|
| vaini | max --
| vareset | -- 
| ---start 1.0 seconds, go from 10 to 100 in 2.0 seconds with 1 penner function
| +vanim | 'var 100 10 1 2.0 1.0 -- 
| ---exe in 3.0 seconds 
| +vexe | 'exe 3.0 --
| +vvexe | v1 'exe 3.0 --
| +vvvexe | v1 v2 'exe 3.0 --
| ---update 
| vupdate | --
|
^r3/lib/console.r3
^r3/lib/mem.r3
^r3/util/penner.r3

|.... time control
#prevt
#timenow
| time		execute		end
#timeline	#timeline<	#timeline> 
| ini | fin | ease ms | 'VAR
#exevar 
#max

::vareset
	0 'timenow ! 
	msec 'prevt ! 
	timeline dup 'timeline< ! 'timeline> ! 
	exevar -1 max 2 << fill
	;

::vaini | max --
	dup 'max !
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
	-1 over 8 - @ 32 >> 5 << exevar + !	| mark empty
	dup 8 - over timeline> over - 3 >> move
	-8 'timeline> +! -8 'timeline< +!
	8 - ;
	
| adr -> ini fin var
:inval | 1 64bit
	>a a@+ a@+ over - b> *. + a@ ! ;
	
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
	over $ff000000 and over $ff000000 and over - b> *. +  $ff000000 and -rot
	over $ff0000 and over $ff0000 and over - b> *. + $ff0000 and -rot
	over $ff00 and over $ff00 and over - b> *. + $ff00 and -rot
	swap $ff and swap $ff and over - b> *. + $ff and -rot
	or or or a@ ! ;
		
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
	msec dup prevt - swap 'prevt ! 'timenow +!
	tictline
	timeline ( timeline< <? 
		@+ execinterp ) drop ;

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

::+vboxanim | 'var ini fin ease dur. start --
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
	

