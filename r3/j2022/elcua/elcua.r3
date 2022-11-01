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

#sbuffer 
#sinicio
#sprincipal
#scursor
#ssigno
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
"inicio.mp3" 		| 0
"comencemos.mp3"
"correcto.mp3" 
"incorrecto.mp3" 
"siguiente-nivel.mp3" 
"circulo.mp3"		| 5
"triangulo.mp3"
"cuadrado.mp3"
"hexagono.mp3"
"cual-de-estas-figuras.mp3" | 9
"de-que-hay-mas.mp3"
"de-que-hay-menos.mp3"
"es-la-mas-lenta.mp3"
"es-la-mas-rapida.mp3"
0

#sndlist * 128

:loadsndfile
	'sndlist >a
	'sndfile ( dup c@ 1? drop
		dup "r3/j2022/elcua/audio/%s" sprint
		Mix_LoadWAV a!+
		>>0 ) drop ;

:playsnd | n --
	3 << 'sndlist + @ 1 swap SNDplayn ;
	
	
#playlist * 1024
#playnow 'playlist
#playlast 'playlist

#playestado 0
#waitnext	

:playreset
	'playlist dup 'playnow ! 'playlast ! 
	0 'playestado ! ;

:nextevent
	playnow	playlast =? ( drop playreset ; ) 
	@+
	$100000000 and? ( dup $fffff and playsnd ) | play
	$200000000 and? ( dup $fffff and msec + 'waitnext ! ) | wait
	$400000000 and? ( dup $fffff and msec + 'waitnext ! ) | exec
	32 >> 'playestado !
	'playnow ! ;
	
:playloop
	playestado 0? ( drop ; ) 
	$ff =? ( nextevent )
	$1 =? ( 1 Mix_Playing 1? ( 2drop ; ) 2drop nextevent ; )
	$2 =? ( msec waitnext <? ( 2drop ; ) 2drop nextevent ; )
	$4 =? ( msec waitnext <? ( 2drop ; ) 2drop playnow @+ ex 'playnow ! nextevent ; )
	drop ;

:activate
	playestado 0? ( $ff 'playestado ! ) drop ;
	
:>>play | nro --
	$100000000 or playlast !+ 'playlast ! 
	activate ;
	
:>>wait | msec --
	$200000000 or playlast !+ 'playlast ! 
	activate ;
	
:>>ex | 'vec msec --
	$400000000 or playlast !+ !+ 'playlast ! 
	activate ;
	
|----------------------------------------------	
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
	2.0 randmax 0.4 + 	|vx
	pv>v a!+ 
	16 << 
	2.0 randmax 0.4 +	|vy 
	pv>v a!+ ;

|---------------------------------------- vidas
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
#estado
#respur -1 
#respok	

:interaccion
	1 'estado ! -1 'respur ! ;
:habla
	0 'estado ! ;
	
:esok
	habla
	2 >>play
	'interaccion 0 >>ex
	;
	
:respuestabtn | resp -- resp
	dup 'respur !
	respok =? ( esok ; ) 
	habla
	3 >>play
	'interaccion 0 >>ex
	-1 'vidas +!
	;
	
|----------------------------------------	
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


|--- boton
:btnd  | n 'vecor 'i x y -- n
	rot pick4 
	respur =? ( swap 8 + swap ) drop
	@ SDLImage
	drop ;
	
| 213 x 118
:btni | n 'vecor 'i x y -- n
	estado 0? ( drop btnd ; ) drop
	213 118 guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;

:jugando
	gui
	$0 SDLcls

	'obj p.draw
	
	0 0 sprincipal SDLImage 
	
	playloop
	impvidas
	
	0 'respuestabtn 'btncir1 210 546 btni drop
	1 'respuestabtn 'btntri1 420 546 btni drop
	2 'respuestabtn 'btncua1 640 546 btni drop
	3 'respuestabtn 'btnhex1 860 546 btni drop
	
|	'exit "Salir" 1000 600 100 40 botont
|	reloj	
	
	sdlx sdly scursor SDLimage
	
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( 4 >>play )

	drop 
	;

|	340.0 .. 870.0 
|	160.0 .. 470.0 
:randpos
	530 randmax 340 +
	310 randmax 160 + ;

#srct [ 0 0 530 310 ]
#mpixel 
#mpitch

:statica
	drop 
	sbuffer 'srct 'mpixel 'mpitch SDL_LockTexture
	mpixel >a 530 310 * ( 1? 1 - 
		rand8 $7f and dup 8 << over 16 << or or
		da!+ ) drop
	sbuffer SDL_UnlockTexture
	340 160 sbuffer SDLImage 	
	;
	
:jini
	'obj p.clear
	'statica 'obj p!+ drop 
	;
	
|"cual-de-estas-figuras.mp3" | 9
:signopreg
	drop
	605 56 - 
	310 107 -
	msec 5 << 40 xy+polar
	ssigno SDLImage
	;
	
:j1
	9 >>play
	4 randmax dup 'respok !
	5 + >>play
	'interaccion 0 >>ex
	'obj p.clear
	'statica 'obj p!+ drop 	
	'signopreg 'obj p!+ drop 
	;

|"de-que-hay-mas.mp3"
:j2
	'obj p.clear
	
	4 randmax 1 +
	( 1? 1 - randpos 40 0 $ff0000 +obj ) drop
	4 randmax 1 +
	( 1? 1 - randpos 40 3 $ffff00 +obj ) drop
	4 randmax 1 +
	( 1? 1 - randpos 40 4 $ff9900 +obj ) drop
	4 randmax 1 +
	( 1? 1 - randpos 40 6 $ffff +obj ) drop
	10 >>play
	;
|"de-que-hay-menos.mp3"
|"es-la-mas-lenta.mp3"
|"es-la-mas-rapida.mp3"	

|--------------------------------------------------	
:jugar
	0 'nropreg !
	-1 'respur !
	inireloj	
	jini
	1000 >>wait
	1 >>play
	'j1 2000 >>ex
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
	
	"r3/j2022/elcua/img/pregunta.png" loadimg 'ssigno !	
	
	SNDInit
	loadsndfile
	rerand
	100 'obj p.ini
	;
	
:main
	"El Cua" 1280 720 SDLinit
	530 310 SDLframebuffer 'sbuffer !
	
	|SDLfull
	inicio
	0 SDL_ShowCursor
	jugar
	SDLquit ;	
	
: main ;


