| variable animator
| PHREDA 2023
|
| vaini | max --
| vareset | -- 
| ---start 1.0 seconds, go from 10 to 100 in 2.0 seconds with 1 penner function
| +vanim | 100 10 1 2.0 1.0 -- 
| ---exe in 3.0 seconds (only one in one time!)
| +vexe | 'exe 3.0 --
| ---update 
| vupdate | --
|
^r3/lib/mem.r3
^r3/win/core.r3
^r3/util/penner.r3

|.... time control
#prevt
#timenow
| time
#timeline #timeline< #timeline> 
| el timenow
#exelist #exelist>
| ini | fin | ease ms | 'VAR
#exevar #exevar> | el

::vareset
	0 'timenow ! 
	msec 'prevt ! 
	timeline dup 'timeline< ! 'timeline> ! 
	exelist 'exelist> !
	exevar 'exevar> !
	;

::vrew
	0 'timenow ! 
	timeline dup 'timeline< ! 'timeline> ! ;

::vaini | max --
	3 <<
	here
	dup 'timeline ! over +
	dup 'exelist ! over +
	dup 'exevar ! swap 2 << + 
	'here !
	vareset ;

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

:tictline
	timeline< timenow
	( over
		timeline> =? ( 'timeline< ! 2drop ; )
		@ $ffffffff and >=? swap 
		dup @ $ff00000000 and timenow or
		exelist> !+ 'exelist> !
		8 + swap ) drop
	'timeline< ! ;

|-----
:delex | 'list var -- 'list | ..
	8 + @+ swap @ !  | set fin
:delvec | 'list -- 'list
	8 - exelist> 8 - dup 'exelist> !
	@ over ! ;

#exepost 
	
:execinterp | 'list var -- 'list
	timenow over $ffffffff and -	| actual-inicio=t0
	swap 32 >> 5 << exevar +		| 'list T0 VAR
	@+ 0? ( drop nip @ 'exepost ! delvec ; )
	rot							| var X t0
	1.0 pick2 $ffffffff and */		| var X t0 tmax
	1.0 >=? ( 2drop delex ; )		| var X f x 	
	swap 32 >> ease				| fn f->f
	swap >a a@+ a@+ over - 
	rot *. + a@ !
	;
	
::vupdate | --
	msec dup prevt - swap 'prevt ! 'timenow +!
	tictline
	0 'exepost !
	exelist 
	( exelist> <? @+ execinterp ) drop 
	exepost 1? ( ex ; ) drop
	exelist exelist> <? ( drop ; ) drop
	timeline< timeline> <? ( drop ; ) drop
	vareset
	;	

:+ev
	exevar> !+ !+ !+ !+ 'exevar> !
	exevar> exevar - 5 >> 1 - ;

:addint | 'var ini fin ease dur. -- nro
	1000 *. $ffffffff and	| duracion ms
	swap $ff and 32 << or	| ease
	+ev ;
	
::+vanim | 'ex start --
	>r addint r> +tline ;
	
::+vexe | 'vector start --
	swap dup dup 0 +ev swap +tline ;