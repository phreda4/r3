| ElCua
|
^r3/win/sdl2gfx.r3
^r3/win/sdl2poly.r3
^r3/win/sdl2image.r3
^r3/win/sdl2mixer.r3

^r3/util/boxtext.r3
^r3/util/tilesheet.r3
^r3/util/arr16.r3

^r3/lib/rand.r3
^r3/lib/gui.r3

#sinicio
#sprincipal
#scursor
#btncir1 	
#btncir2 	
#btntri1 	
#btntri2 	
#btncua1 	
#btncua2 	
#btnhex1 	
#btnhex2 	
#vida1
#vida2

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

|----------------------------------------	
#sndfile 
"inicio.mp3" 
"correcto.mp3" 
"incorrecto.mp3" 
"siguiente-nivel.mp3"
"cual-de-estas-es-el-cuadrado.mp3"
"cual-de-estas-es-un-triangulo.mp3"
"cual-es-el-pentagono.mp3"
"reconocer-el-ciculo.mp3"
"cuantos lados tiene esta figura.mp3"
"esta-otra-cuantos-tiene.mp3"

0

#sndlist * 1024

:loadsndfile
	'sndlist >a
	'sndfile ( dup c@ 1? drop
		dup "r3/j2022/elcua/audio/%s" sprint
		Mix_LoadWAV a!+
		>>0 ) drop ;

:playsnd | n --
	3 << 'sndlist + @ SNDplay ;
	
|----------------------------------------	
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
	a@+ pv.p 16 >> a@+ pv.p 16 >> SDLFngon ;
	

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
	320.0 <? ( hit changevel )
	920.0 >? ( hit changevel )
	swap 32 << or a!+
	a@ pv@
	50.0 <? ( hit )
	400.0 >? ( hit )
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

| 676 107,56,51
:vidas
	

	
|----------------------------------------	
:pregunta
	$0 SDLColor
	600 10 600 500 SDLFRect
	'obj p.draw
	;

:botont | 'v "" x y w h --
	2over 2over guibox
	SDLb SDLx SDLy guiIn	
	$ffffff  [ $00ff00 nip ; ] guiI
	SDLColor
	2over 2over SDLFRect	
	xywh64 
	$11 rot rot $0 fontt textbox 
	onCLick ;	
	
:boton | x y w h -- xy
	2over 2over guibox
	SDLb SDLx SDLy guiIn	
	$ffffff  [ $666666 nip ; ] guiI
	SDLColor
	2over 2over SDLFRect	
	1 >> rot + rot rot 1 >> + swap
	;

	
| 213 x 118

:btni | 'vecor 'ip 'i x y -- size
	213 118 guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;

#resp

:botones
	[ 1 'resp ! ; ] 'btncir1 210 546 btni
	[ 2 'resp ! ; ] 'btntri1 420 546 btni
	[ 3 'resp ! ; ] 'btncua1 640 546 btni
	[ 4 'resp ! ; ] 'btnhex1 860 546 btni
|	210 546 btncir1 SDLImage
|	420 546 btntri1 SDLImage
|	640 546 btncua1 SDLImage
|	860 546 btnhex1 SDLImage
	;
	
:jugando
	gui
	0 0 sprincipal SDLImage 

	vidas
|	pregunta
	botones

|	'exit "Salir" 1000 600 100 40 botont
|	reloj	
	
|	$ffff00 SDLColor
|	msec 3 << 6 100 300 300 SDLFngon
|	5 linegr!
|	$ffff SDLColor
|	msec 4 << 6 100 300 300 SDLngon
|	$ffffff SDLColor
|	10 linegr!
|	300 300 gop
|	msec 4 << 100 polar 300 + swap 300 + swap gline
	
	sdlx sdly scursor SDLimage
	
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( 1 playsnd )
	<f2> =? ( 2 playsnd )
	<f3> =? ( 3 playsnd )
	<f4> =? ( 4 playsnd )
	<f5> =? ( 5 playsnd )
	<f6> =? ( 6 playsnd )
	<f7> =? ( 7 playsnd )
	<f8> =? ( 8 playsnd )
	<f9> =? ( 9 playsnd )

	drop 
	;

:randpos
	600 randmax 320 +
	400 randmax 60 + ;
	
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
		randpos 40 6 $ffff +obj
		) drop
		
	inireloj		
	'jugando SDLshow
	;
	


:inicio
	ttf_init
	"r3/j2022/elcua/font/RobotoCondensed-Bold.ttf" 40 TTF_OpenFont 'fontt !	
	"r3/j2022/elcua/img/cursor.png" loadimg 'scursor !	
	"r3/j2022/elcua/img/inicio.png" loadimg 'sinicio !	
	"r3/j2022/elcua/img/principal.png" loadimg 'sprincipal !	

	"r3/j2022/elcua/img/btncir1.png" loadimg 'btncir1 !	
	"r3/j2022/elcua/img/btncir2.png" loadimg 'btncir2 !	
	"r3/j2022/elcua/img/btntri1.png" loadimg 'btntri1 !	
	"r3/j2022/elcua/img/btntri2.png" loadimg 'btntri2 !	
	"r3/j2022/elcua/img/btncua1.png" loadimg 'btncua1 !	
	"r3/j2022/elcua/img/btncua2.png" loadimg 'btncua2 !	
	"r3/j2022/elcua/img/btnhex1.png" loadimg 'btnhex1 !	
	"r3/j2022/elcua/img/btnhex2.png" loadimg 'btnhex2 !	

	"r3/j2022/elcua/img/vida1.png" loadimg 'vida1 !	
	"r3/j2022/elcua/img/vida2.png" loadimg 'vida2 !	
	
	SNDInit
	loadsndfile
	
	100 'obj p.ini
	0 'nropreg !

	;
	
:main
	"El Cua" 1280 720 SDLinit
	|SDLfull
	inicio
	0 SDL_ShowCursor
|	0 playsnd
	jugar
	SDLquit ;	
	
: main ;


