| variable animator
| PHREDA 2022
| ---start 1.0 seconds, go from 10 to 100 in 2.0 seconds with 1 penner function
| +vanim | 100 10 1 2.0 1.0 -- 
| ---exe in 3.0 seconds (only one in one time!)
| +vexe | 'exe 3.0 --
| ---update 
| vupdate | --
|
^r3/win/console.r3
^r3/util/penner.r3

^r3/win/sdl2gfx.r3
^r3/util/bfont.r3
^r3/lib/rand.r3

|.... time control
#prevt

#timenow
| time
#timeline #timeline< #timeline> 
| el timenow
#exelist #exelist>
| ini | fin | ease ms | 'VAR
#exevar #exevar> | el

::timeline.reset
	0 'timenow ! 
	msec 'prevt ! 
	timeline dup 'timeline< ! 'timeline> ! 
	exelist 'exelist> !
	exevar 'exevar> !
	;

::vrew
	0 'timenow ! 
	timeline dup 'timeline< ! 'timeline> ! ;

::timeline.ini
	here
	dup 'timeline ! $fff +
	dup 'exelist ! $fff +
	dup 'exevar ! $7fff + 
	'here !
	timeline.reset ;

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
	swap 32 >> easem				| fn f->f
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
	timeline.reset
	;	

|....
| timestart duracion ease scale
| ff00000000000000
:addint | 'var ini fin ease dur. -- nro
	1000 *. $ffffffff and	| duracion ms
	swap $ff and 32 << or	| ease
	exevar> !+ !+ !+ !+ 'exevar> !
	exevar> exevar - 5 >> 1 - ;
	
:addexe | 'vector -- nro
	dup dup 0
	exevar> !+ !+ !+ !+ 'exevar> !
	exevar> exevar - 5 >> 1 - ;

::+vanim | 'ex start --
	>r addint r> +tline ;
	
::+vexe | 'vector start --
	swap addexe swap +tline ;
	
|*********DEBUG
:dumptline
	timenow "%d " bprint
	timeline< timeline - 4 >> "%d" bprint bcr
	timeline
	( timeline> <?
		timeline< =? ( ">" bprint )
		@+ "%h " bprint
		) drop bcr ;

|------------------
#var1 30
#var2 40
	
:ani1t
	timeline.reset
	'var1 100 600 15 randmax 2.0 0.0 +vanim  
	'var1 600 100 15 randmax 4.0 2.0 +vanim  
	'var2 100 500 15 randmax 4.0 0.0 +vanim  
	'var2 500 100 15 randmax 2.0 4.0 +vanim  
	;

:ani1
	var2 var1 "%d %d" bprint bcr
	$ff00 sdlcolor
	var1 var2 40 40 sdlfrect
	;
	
#varx * $7f
:ani2t
	timeline.reset
	'varx >a
	0 ( $10 <? 
		a> 700 100 pick3 3.0 0.0 +vanim
		a> 100 700 pick3 3.0 3.5 +vanim
		8 a+
		1 + ) drop 
	|'exit 6.8 +vexe 
	'ani2t 7.0 +vexe 
	;

	
:ani2
	$ff sdlcolor
	'varx 
	0 ( $10 <?
		swap @+ pick2 30 * 50 + 25 25 sdlfrect
		swap 1 + ) 2drop ;
	
:main
	$0 SDLcls
	
	$ff00 bcolor
	0 0 bat "test varanim" bprint bcr
	
|	ani1
	ani2
	
|	dumptline
	vupdate
	
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( timeline.reset )
	<f2> =? ( ani1t )
	<f3> =? ( ani2t )
	drop ;
	
:start
	timeline.ini
	'main SDLshow 
	;
	
: 
	"r3sdl" 800 600 SDLinit
	bfont1
	start
	SDLquit
	;	