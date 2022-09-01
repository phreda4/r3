
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
	
:poligono | ang n r x y --
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
	

	
:tfigura
	0? ( drop nip a@+ pv.p 16 >> a@+ pv.p 16 >> tcirc ; )
	swap
	a@+ pv.p 16 >> 
	a@+ pv.p 16 >> poligono ;
	
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
	600.0 <? ( hit )
	1200.0 >? ( hit )
	swap 32 << or a!+
	a@ pv@
	50.0 <? ( hit )
	300.0 >? ( hit )
	swap 32 << or a!+
	
	
|	a@+ a> 
	
	;
	
:+obj | x y size caras color --
	'figura 'obj p!+ >a
	a!+ 
	0
	0.02 randmax 0.01 - | -0.01 __ 0.01
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
#circulo
#cuadrado
#triangulo
#pentagono


:pregunta
	$0 SDLColor
	600 10 600 400 SDLFRect

	'obj p.draw
	
	;
	:a
	$ff0000 SDLColor
	msec 4 << 5 40 660 90 poligono
	$ff00 SDLColor
	30 750 40 tcirc
	$ff SDLColor
	msec 4 << 3 40 760 120 poligono
	$ffff SDLColor
	msec 3 << 4 40 860 220 poligono
	;
	
:boton | x y w h -- size
	2over 2over guibox
	SDLb SDLx SDLy guiIn	
	$ffffff  [ $00ff00 nip ; ] guiI
	SDLColor
	2over 2over SDLFRect	
	xywh64 ;

	
:respuesta
	600 420 300 100 boton
	$11 "CUA" rot $0 fontt textbox
	|r1 'tocoboton onClick drop	
	
	910 420 300 100 boton
	$11 "CUA" rot $0 fontt textbox

	600 530 300 100 boton
	$11 "CUA" rot $0 fontt textbox
	|r1 'tocoboton onClick drop	
	
	910 530 300 100 boton
	$11 "CUA" rot $0 fontt textbox
	;
	
	
:jugando
	gui
	$0 SDLcls
	0 0 sfondo sdlimage
	
	pregunta
	respuesta
	
	0 scursor sdlx sdly tsdraw
	
	SDLredraw
	teclado
	;

:jugar
	'obj p.clear
	
	660 90 40 5 $ff0000 +obj
	660 90 40 4 $ff00 +obj
	660 90 40 3 $ff +obj
	660 90 40 0 $ffff +obj
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


