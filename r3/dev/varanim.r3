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

|.... time control
#prevt

#timenow
#timeline #timeline< #timeline> 
#exelist #exelist>
#exevar #exevar>

::timeline.reset
	0 'timenow ! timeline 'timeline< ! ;
	
::timeline.clear
	timeline 'timeline> ! timeline.reset ;

::timeline.ini
	here 'timeline ! 
	$fff 'here +! 
	here dup 'exelist ! 'exelist> !
	$fff 'here +!
	here dup 'exevar ! 'exevar> !
	$3fff 'here +!
	timeline.clear ;

:searchless | time adr --time adr
	( 8 - timeline >=?
		dup @	| time adr time
		$ffffffff and
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

	
#t0
| interpolate
| x = 0.0 ... 1.0
| x = ease(x)
| x = xmin + xmax-xmin * x

:exlineal | f m
	;

:delex | 'list var X -- 'list
	48 >> swap @ !	| set fin
	8 -
	exelist> 8 - dup 'exelist> !
	@ over !
	;
	
:execinterp | var --
	timenow over $ffffffff and - |'t0 ! | actual-inicio
	swap 32 >> 4 << exevar + 	| T0 VAR
	@+ rot							| var X t0
	1.0 pick2 $fffff and 4 << */	| var X t0 tmax
	1.0 >=? ( drop delex ; )		| var X f x 	
	over 20 >> $f and drop | fn f->f
	
	over 24 << 48 >> rot 48 >> over -  | var f ini len
	rot *. +
	swap @ !
	;
	
:exenow	
	exelist ( exelist> <?  
		@+ execinterp
		) drop ;
	
|....
:vease
	;
	
::+vanim | v2 v1 'ex start --
	+tline ;
	
::+vexe | 'vector start --
	+tline ;
	
::vupdate | --
	msec dup prevt - swap 'prevt ! 'timenow +!
	tictline
	exenow
	;
	
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

#var1
#var2
#cc

:ex1 1 'var1 +! ;
	
:main
	$0 SDLcls
	
	$ff00 bcolor
	0 0 bat "test" bprint bcr
	var2 var1 "%d %d" bprint bcr
	bcr
	
	dumptline
	vupdate
	
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( timeline.reset )
	<f2> =? ( 
	'var1 30 10 0 2.0 addint 2.0 +vanim  
	'var1 10 30 0 4.0 addint 4.0 +vanim  )
|	<f3> =? ( 'ex1 3.0 +vexe )
	drop ;
	
:start

 500 $100000000 2000 / dup "%h " .print 16 *>> "%f" .println
 500 1.0 2000 */ "%f" .println
 1000 1.0 2000 */ "%f" .println
 1500 1.0 2000 */ "%f" .println
 2000 1.0 2000 */ "%f" .println
	timeline.ini
	msec 'prevt ! 
	
	'main SDLshow 
	;
	
: 
	"r3sdl" 800 600 SDLinit
	bfont1
	start
	SDLquit
	;	