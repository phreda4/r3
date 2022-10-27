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

#vidas 3
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
"comencemos.mp3"
"correcto.mp3" 
"incorrecto.mp3" 
"cual-de-estas-figuras.mp3"
"triangulo.mp3"
"cuadrado.mp3"
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
	
#playlist * 1024
#playnow 'playlist
#playlast 'playlist

:playreset
	'playlist dup 'playnow ! 'playlast ! ;
	
:playloop
	Mix_PlayingMusic 1? ( drop ; ) drop
	playnow playlast =? ( drop playreset ; ) 
	@+ playsnd 'playnow ! ;

:>>play | nro --
	playlast !+ 'playlast ! ;
	
|1, Cual de estas figuras es un
|circulo
|triangulo
|cuadrado
|hexagono

|2.Cual figura es la mas rapida
|3 Cual Figura es la mas lenta
|4.De que figura hay mas
|5.De que figura hay menos

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
	340.0 <? ( hit changevel )
	867.0 >? ( hit changevel )
	swap 32 << or a!+
	a@ pv@
	166.0 <? ( hit )
	462.0 >? ( hit )
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

:nvidas | n -- img
	vidas <? ( drop vida2 ; ) drop vida1 ;
	
| 676 107,56,51
:impvidas
	676
	0 ( 3 <? swap
		dup 107 
		pick3 nvidas SDLImage 
		60 +
		swap 1 + ) 2drop ;

	
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

	playloop
	
	impvidas
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
	<f1> =? ( 4 >>play )

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
	1 >>play
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


