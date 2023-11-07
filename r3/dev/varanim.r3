| variable animator
| PHREDA 2022
| ---start 1.0 seconds, go from 10 to 100 in 2.0 seconds with QUAD_IN penner function
| +vanim | 100 10 'Quad_In 2.0 1.0 -- 
| +exe | 'exe start --
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
| ini fin ease ms | 'VAR
#exevar #exevar> | el

::timeline.reset
	0 'timenow ! 
	timeline dup 'timeline< ! 'timeline> ! 
	exelist 'exelist> !
	exevar 'exevar> !
	;

::timeline.ini
	msec 'prevt ! 
	here
	dup 'timeline ! $fff +
	dup 'exelist ! $fff +
	dup 'exevar ! $3fff + 
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
| timestart duracion ease scale
:addint | 'var ini fin ease dur. -- nro
	1000 *. 4 >> $fffff and	| duracion ms
	swap $f and 20 << or	| ease
	swap $fffff and 24 << or | fin
	swap $fffff and 48 << or | ini
	exevar> !+ !+ 'exevar> !
	exevar> exevar - 4 >> 1 -
	;
	
:delex | 'list var X -- 'list
	48 >> swap @ !	| set fin
	8 - exelist> 8 - dup 'exelist> !
	@ over ! ;
	
:execinterp | var --
	timenow over $ffffffff and -	| actual-inicio
	swap 32 >> 4 << exevar +		| T0 VAR
	@+ rot							| var X t0
	1.0 pick2 $fffff and 4 << */	| var X t0 tmax
	1.0 >=? ( drop delex ; )		| var X f x 	
	over 20 >> easem				| fn f->f
	over 24 << 48 >> rot 48 >> over -  | var f ini len
	rot *. + swap @ !
	;
	
::vupdate | --
	msec dup prevt - swap 'prevt ! 'timenow +!
	tictline
	exelist 
	( exelist> <?  
		@+ execinterp
		) drop 
	exelist exelist> <? ( drop ; ) drop
	timeline< timeline> <? ( drop ; ) drop
	timeline.reset
	;	

|....
::+vanim | 'ex start --
	+tline ;
	
::+vexe | 'vector start --
	+tline ;
	
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
	
:resetyl
	timeline.reset
	'var1 100 600 15 randmax 2.0 addint 0.0 +vanim  
	'var1 600 100 15 randmax 4.0 addint 2.0 +vanim  
	'var2 100 500 15 randmax 4.0 addint 0.0 +vanim  
	'var2 500 100 15 randmax 2.0 addint 4.0 +vanim  
	;

:main
	$0 SDLcls
	
	$ff00 bcolor
	0 0 bat "test varanim" bprint bcr
	
	var2 var1 "%d %d" bprint bcr
	bcr
	$ff00 sdlcolor
	var1 var2 40 40 sdlfrect
	
	dumptline
	vupdate
	
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( timeline.reset )
	<f2> =? ( resetyl 'resetyl 6.0 +vexe )
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