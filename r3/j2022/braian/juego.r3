
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/boxtext.r3
^r3/util/tilesheet.r3
^r3/util/arr16.r3

^r3/lib/rand.r3
^r3/lib/gui.r3

#sfondo
#scursor

#obj 0 0

#simaneges
#stablero
#smapa

#fontt
#preguntas

#tiempo
#nropreg 0

#mseca

:inireloj
	0 'tiempo !
	msec 'mseca !
	;
	
:reloj
	msec dup mseca - 'tiempo +! 'mseca ! 
	tiempo 1000 /
	"%d" sprint
	100 10 $ff0000 fontt
	textline | str x y color font --
	;


:teclado
	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( 1 'nropreg +! )
	drop 
	;

|----------------------------------------	
	
#xc #yc #sa #ra #an

:tri | dx dy dx dy --
	yc + swap xc + swap 2swap
	yc + swap xc + swap xc yc 
	SDLTriangle
	;
	
:tpoli | ang n r x y --
	'yc ! 'xc ! 'ra !
	1.0 swap / 'sa !
	'an !
	0 ( 1.0 <? 
		dup an + ra polar 
		pick2 an + sa + ra polar 
		tri sa + ) drop 
		;
		

:tcirc | r x y --
	pick2 rot rot SDLFEllipse ;
	
|----------------------------------------	
:pv.p | a -- 'a
	dup 32 >> 			| vel
	swap $ffffffff and  | pos
	+ ;

:pv>v | p v -- pv
	32 << or ;

:pv@ | a -- 'a
	dup 32 >> 			| vel
	swap $ffffffff and  | pos
	over +
	;
	
:hit | v pos -- v pos
	swap neg swap ;
	
:changevel
	a> -2 3 << +
	dup @ $ffffffff and 0.03 randmax 0.015 - 32 << or swap !
	;
	
:tfigura
	0? ( drop nip a@+ pv.p 16 >> a@+ pv.p 16 >> tcirc ; )
	swap
	a@+ pv.p 16 >> a@+ pv.p 16 >> tpoli ;
	
|600 10 600 500	
:figura
	>a
	a@+ SDLColor
	a@+ pv.p 
	a@+ dup $ffff and swap 32 >> 
	tfigura
	
	-4 3 << a+
	a@ pv@ swap 32 << or a!+
	8 a+
	a@ pv@
	650.0 <? ( hit changevel )
	1150.0 >? ( hit changevel )
	swap 32 << or a!+
	a@ pv@
	50.0 <? ( hit )
	470.0 >? ( hit )
	swap 32 << or a!+
	;
	
:+obj | x y size caras color --
	'figura 'obj p!+ >a
	a!+ 
	0
	0.03 randmax 0.015 - | -0.01 __ 0.01
	pv>v a!+ | rotacion
	32 << or a!+  | caras|size
	swap 
	16 << 
	2.0 randmax 0.4 +
	pv>v a!+ 
	16 << 
	2.0 randmax 0.4 +
	pv>v a!+ ;
	
|----------------------------------------	
:randpos
	500 randmax 650 +
	400 randmax 60 + ;
	
:pregunta
	$0 SDLColor
	600 10 600 500 SDLFRect

	'obj p.draw
	;
	
:boton | x y w h -- xy
	2over 2over guibox
	SDLb SDLx SDLy guiIn	
	$ffffff  [ $666666 nip ; ] guiI
	SDLColor
	2over 2over SDLFRect	
	1 >> rot + rot rot 1 >> + swap
	;

	
:respuesta
	600 520 300 90 boton
	$ffff SDLColor
	40 rot rot tcirc | ang n r x y --
	
	910 520 300 90 boton
	$ff SDLColor
	>r >r 0.125 3 40 r> r> tpoli | ang n r x y --

	600 620 300 90 boton
	$ff00 SDLColor
	>r >r 0.125 4 40 r> r> tpoli | ang n r x y --
	
	910 620 300 90 boton
	$ff0000 SDLColor
	>r >r 0.125 5 40 r> r> tpoli | ang n r x y --
	;
	
	
:jugando
	gui
	$0 SDLcls
	0 0 sfondo sdlimage
	
	pregunta
	respuesta

	reloj	
	
	0 scursor sdlx sdly tsdraw

	
	SDLredraw
	teclado
	;


	
:jugar
	'obj p.clear
	
	
	4 randmax 1 +
	( 1? 1 -
		randpos 40 5 $ff0000 +obj
		) drop

	4 randmax 1 +
	( 1? 1 -
		randpos 40 4 $ff00 +obj
		) drop
		
	4 randmax 1 +
	( 1? 1 -
		randpos 40 3 $ff +obj
		) drop

	4 randmax 1 +
	( 1? 1 -
		randpos 40 0 $ffff +obj
		) drop
		
	inireloj		
	'jugando SDLshow
	;
	
:inicio
	ttf_init
	"r3/j2022/braian/font/RobotoCondensed-Bold.ttf" 50 TTF_OpenFont 'fontt !	
	128 dup "r3\j2022\braian\cursor.png" loadts 'scursor !	
	"r3\j2022\braian\fondo.png" loadimg 'sfondo !
	100 'obj p.ini
	0 'nropreg !
	;
	
:main
	"r3sdl" 1280 720 SDLinit
	|"r3sdl" 1024 576 SDLinit
	|SDLfull
	inicio
	0 SDL_ShowCursor
	jugar
	SDLquit ;	
	
: main ;


