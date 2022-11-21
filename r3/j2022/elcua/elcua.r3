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
#swin
#sperdio
#scursor
#splay1
#splay2
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
"otra-oportunidad.mp3" |14
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

:+objv | vx x vy y size caras color --
	'figura 'obj p!+ >a
	a!+ 
	0
	0.03 randmax 0.015 - | -0.01 __ 0.01
	pv>v a!+ | rotacion
	32 << or a!+  | caras|size
	2swap 
	16 << swap pv>v a!+ 
	16 << swap pv>v a!+ ;

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

#cambiaestado

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

:correcto
	drop
	$11 "Correcto !!!"
	330 160 530 310 xywh64 
	$ffffff fontt textbox | $vh str box color font	
	;

:nono
	drop
	$11 "No, No !!"
	330 160 530 310 xywh64 
	$ffffff fontt textbox | $vh str box color font	
	;


:interaccion
	1 'estado ! -1 'respur ! ;
:habla
	0 'estado ! ;
	
:esok
	habla
	2 >>play
	200 >>wait
	4 >>play
	
	'obj p.clear
	'statica 'obj p!+ drop 	
	'correcto 'obj p!+ drop 	

	1 'nropreg +!

 	'interaccion 1000 >>ex
	cambiaestado 1000 >>ex
	;
	
:respuestabtn | resp -- resp
	dup 'respur !
	respok =? ( esok ; ) 
	habla
	3 >>play

	'obj p.clear
	'statica 'obj p!+ drop 	
	'nono 'obj p!+ drop 	

	'interaccion 1000 >>ex
	cambiaestado 1000 >>ex
	
	-1 'vidas +!
	
	vidas 0? ( exit ) drop
	;
	
|----------------------------------------	

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
	>esc< =? ( 0 'vidas ! exit )
	drop 
	;

|	340.0 .. 870.0 
|	160.0 .. 470.0 
:randpos
	530 randmax 340 +
	310 randmax 160 + ;

	
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

#cntmax

:fill0 ( 1? 1 - randpos 40 0 $ff0000 +obj ) drop ; 
:fill1 ( 1? 1 - randpos 40 3 $ffff00 +obj ) drop ;
:fill2 ( 1? 1 - randpos 40 4 $ff9900 +obj ) drop ;
:fill3 ( 1? 1 - randpos 40 6 $ffff +obj ) drop ;

|"de-que-hay-mas.mp3" 
:j2
	'obj p.clear
	
	10 >>play
	'interaccion 0 >>ex
	4 randmax 'respok !
	2 randmax 3 + 'cntmax !

	respok
	0 =? ( cntmax dup fill0 1 - dup fill1 dup fill2 fill3 )
	1 =? ( cntmax dup fill1 1 - dup fill0 dup fill2 fill3 )
	2 =? ( cntmax dup fill2 1 - dup fill0 dup fill1 fill3 )
	3 =? ( cntmax dup fill3 1 - dup fill0 dup fill1 fill2 )
	drop
	;
|"de-que-hay-menos.mp3"

:j3
	'obj p.clear
	
	11 >>play
	'interaccion 0 >>ex
	4 randmax 'respok !
	2 randmax 2 + 'cntmax !

	respok
	0 =? ( cntmax dup fill0 1 + dup fill1 dup fill2 fill3 )
	1 =? ( cntmax dup fill1 1 + dup fill0 dup fill2 fill3 )
	2 =? ( cntmax dup fill2 1 + dup fill0 dup fill1 fill3 )
	3 =? ( cntmax dup fill3 1 + dup fill0 dup fill1 fill2 )
	drop
	;

:signo
	rand %100000 and? ( swap neg swap ) drop ;
	
:randvpos | vel
	dup signo 
	530 randmax 340 +
	rot signo
	310 randmax 160 + 
	;

:vel0 randvpos 40 0 $ff0000 +objv ; 
:vel1 randvpos 40 3 $ffff00 +objv ;
:vel2 randvpos 40 4 $ff9900 +objv ;
:vel3 randvpos 40 6 $ffff +objv ;

|"es-la-mas-lenta.mp3"

:j4
	'obj p.clear
	
	12 >>play
	'interaccion 0 >>ex
	4 randmax 'respok !
	4.0 randmax 2.0 + 'cntmax !

	respok
	0 =? ( cntmax dup vel0 2.0 + dup vel1 dup vel2 vel3 )
	1 =? ( cntmax dup vel1 2.0 + dup vel0 dup vel2 vel3 )
	2 =? ( cntmax dup vel2 2.0 + dup vel0 dup vel1 vel3 )
	3 =? ( cntmax dup vel3 2.0 + dup vel0 dup vel1 vel2 )
	drop
	;
|"es-la-mas-rapida.mp3"	

:j5
	'obj p.clear
	
	13 >>play
	'interaccion 0 >>ex
	4 randmax 'respok !
	3.0 randmax 3.0 + 'cntmax !

	respok
	0 =? ( cntmax dup vel0 2.0 - dup vel1 dup vel2 vel3 )
	1 =? ( cntmax dup vel1 2.0 - dup vel0 dup vel2 vel3 )
	2 =? ( cntmax dup vel2 2.0 - dup vel0 dup vel1 vel3 )
	3 =? ( cntmax dup vel3 2.0 - dup vel0 dup vel1 vel2 )
	drop
	;

|--------------------------------------------------	
:pantgano
	gui
	0 0 swin SDLImage 
	'obj p.draw
	playloop
	
	sdlx sdly scursor SDLimage
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:gano
	'obj p.clear
	1 fill0
	1 fill1
	1 fill2
	1 fill3
	'exit 10000 >>ex
	'pantgano SDLshow
	;
	
|-----------------------------------	
:pantperdio
	gui
	0 0 sperdio SDLImage 
	'obj p.draw
	playloop
	
	sdlx sdly scursor SDLimage
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:perdio
	'obj p.clear
	'exit 10000 >>ex
	'pantperdio SDLshow
	exit
	;
	
	
:subenivel
	nropreg
	1 =? ( 'j1 100 >>ex )
	2 =? ( 'j2 100 >>ex )
	3 =? ( 'j3 100 >>ex )
	4 =? ( 'j4 100 >>ex )
	5 =? ( 'j5 100 >>ex )
	6 =? ( exit ) 
	drop
	;
	
:jugar
	1 'nropreg !
	-1 'respur !
	inireloj	
	jini
	
	subenivel 
|	500 >>wait
	1 >>play
|	'j1 1000 >>ex
	'jugando SDLshow
	vidas 0? ( drop perdio ; ) drop
	gano
	;

:btnplay | n 'vecor 'i x y -- n
	|435 95 guibox
	pick2 @ SDLimagewh guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;

:pantini
	gui
	0 0 sinicio SDLImage 
	playloop
	
	[ jugar ; ] 'splay1 420 600 btnplay
	
	sdlx sdly scursor SDLimage
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:iniciojuego
	'subenivel 'cambiaestado !
	0 >>play 
	'pantini SDLshow
	;

:inicio
	ttf_init
	"r3/j2022/elcua/font/RobotoCondensed-Bold.ttf" 60 TTF_OpenFont 'fontt !	
	
	"r3/j2022/elcua/img/cursor.png" loadimg 'scursor !	
	"r3/j2022/elcua/img/inicio.png" loadimg 'sinicio !	
	
	"r3/j2022/elcua/img/principal.png" loadimg 'sprincipal !	
	"r3/j2022/elcua/img/win.png" loadimg 'swin !	
	"r3/j2022/elcua/img/lose.png" loadimg 'sperdio !	

	"r3/j2022/elcua/img/btncir1.png" loadimg 'btncir1 !	
	"r3/j2022/elcua/img/btncir2.png" loadimg 'btncir2 !	
	"r3/j2022/elcua/img/btntri1.png" loadimg 'btntri1 !	
	"r3/j2022/elcua/img/btntri2.png" loadimg 'btntri2 !	
	"r3/j2022/elcua/img/btncua1.png" loadimg 'btncua1 !	
	"r3/j2022/elcua/img/btncua2.png" loadimg 'btncua2 !	
	"r3/j2022/elcua/img/btnhex1.png" loadimg 'btnhex1 !	
	"r3/j2022/elcua/img/btnhex2.png" loadimg 'btnhex2 !	

	"r3/j2022/elcua/img/play1.png" loadimg 'splay1 !	
	"r3/j2022/elcua/img/play2.png" loadimg 'splay2 !	

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
	iniciojuego
	SDLquit ;	
	
: main ;


