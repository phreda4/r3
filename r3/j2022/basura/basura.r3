| vialbot 

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/win/sdl2mixer.r3

^r3/lib/rand.r3
^r3/lib/gui.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/fontutil.r3
^r3/util/boxtext.r3

#mapajuego
#sprplayer

#musicplay

#font

#sbtndia
#sbtniempo
#svida1
#svida2
#sinicio
#sinicial
#sganaste
#sperdiste
#sbtnj1 #sbtnj2
#sbtns1 #sbtns2

#items 0 0
#fx 0 0

#xmapa 0 
#ymapa 0

#xp 100
#yp 600
#zp 0
#vzp 0

#puntos 0
#vidas 5

#dias "Lunes" "Martes" "Miercoles" "Jueves" "Viernes" "Sabado" "Domingo"
#diahoy 'dias
#mododia 1

|-------------- tiempo
#prevt
#dtime
#tiempo 

:time.start
	msec 'prevt ! 0 'dtime ! 0 'tiempo ! ;

:time.delta
	msec dup prevt - dup 'tiempo +! 'dtime ! 'prevt ! ;

	
:+obj | 'from 'vec --
	'items p!+ >a >b
	0 a!+	| estado
	db@+ a!+	| anima
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	1.0 a!
	;

:animcntm | cnt msec -- 0..cnt-1
	55 << 1 >>> 63 *>> ; | 55 speed

:distplayer | x y -- x y f
	zp 0 >? ( drop 1000 ; ) drop	| saltando no toca
	over xp - over yp - distfast ;
	
|--------------------------------
:vidamenos
	-1 'vidas +!
| modo renace
	vidas 0? ( exit ) drop
	;
	
:basuraok
	10 'puntos +!
	;
	
:basuraerr
|	-10 'puntos +!
	vidamenos
	;
	
:tocobasura	
	mododia =? ( drop basuraok ; ) drop basuraerr ;
	
|--------------------------------
| nro-tile mask-cnt ( 0>1 1>2 3>4)
#tipoitems (
6 $0
7 $10
8 $13
12 $11
14 $3
18 $11
20 $2
24 $1
36 $1
34 $10	| tacho verde
35 $0	| tacho gris
)

|--------------------------------
:item | a --
	>a a@ dup 0.05 + a!+ 
	16 >> a@+ $f and and a@+ + sprplayer 
	a@+ xmapa -
	a@+ ymapa - 
	distplayer 32 <? ( drop 4drop
		a> 32 - @
		4 >> tocobasura
		0 ; ) drop
	tsdraw ;
	
:+item | x y c i --
	'item 'items p!+ >a 
	rand a!+ a!+ a!+ swap a!+ a! ;

:+ritem | x y --
	9 randmax 1 << 'tipoitems + 
	c@+ swap c@ +item ;
	

#error 0
#errornow 
:descompone 1 'error ! ;
|--------------------------------
:gato | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 30 + sprplayer 
	16 a+
	a@+ 
	dup 3 + sw >? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - 
	distplayer 48 <? ( |drop 4drop 0 vidamenos ; 
				descompone
				) drop
	tsdraw
	;
	
:+gato | x y --
	'gato 'items p!+ >a 0 a!+ 0 a!+ 0 a!+ swap a!+ a! ;

|--------------------------------
:perro | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer 
	16 a+
	a@+ 
	dup 5 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - 
	distplayer 48 <? ( 
|		drop 4drop 0 vidamenos ; 
		descompone
		) drop
	tsdraw
	;
	
:+perro | x y --
	'perro 'items p!+ >a 0 a!+ 0 a!+ 0 a!+ swap a!+ a! ;
	
|--------------------------------
#btnpad

:xmove | d --
	a@ + 80 max a! ;

:ymove | d --
	a@ + 410 max 770 min a! ;

:a@anim | -- nroanim ; A@!+
	errornow 1? ( drop rand 4 >> $1 and 4 + 8 a+ ; ) drop
	a@ dup dtime 32 << + a!+
	dup $ffff and 
	over 16 >> $ffff and 
	rot 32 >> animcntm + 
	;
	
:a!anim | nuevoanim -- ; a:
	a@ $ffffffff not and or	a! ;

:jug	
	>a
	a@anim a@+
	8 a+
	a@+ dup 300 - 'xmapa !
	xmapa - dup 'xp !
	a@+ |dup 200 - 'ymapa !
	ymapa - dup 'yp !
	zp int. -
	tsdraw
	
	errornow 0? ( 
		btnpad
		-8 a+ %1000 and? ( -3 ymove ) %100 and? ( 3 ymove  )
		-8 a+ %10 and? ( -1 xmove ) %1 and? ( 1 xmove )
		drop
		) drop
	
	a@ 2 + a!
	
	zp vzp +
	0 <=? ( drop 0 'zp ! 0 'vzp ! ; )
	'zp !
	-0.3 'vzp +!	
	;
	
:a!xy | x y --
	swap a!+ a!+ ;
	
:center> | x y -- v 
	32 << swap $ffffffff and or ;
	
:a@xyz | -- x y 
	a@+ |center
	a@+ over 32 >> - xmapa -
	a@+ rot 32 << 32 >> - ymapa - zp int. -
	;

:a@xy | -- x y 
	a@+ |center
	a@+ over 32 >> - xmapa -
	a@+ rot 32 << 32 >> - ymapa -
	;
	
|=======================	
:+jugador
	'jug 'items p!+ >a
	$40000 a!+ | anim
	sprplayer a!+ | sprite
	
	0 a!+ 
	xp a!+ yp a!+
	xp 300 - 'xmapa ! 
	|yp 200 - 'ymapa !
	;
	
|--------------------------------
:randy | -- ; 420..990
	360 randmax 410 + ;

:reset
	100 dup 300 - 'xmapa ! 'xp ! 
	600 |dup 200 - 'ymapa ! 
	'yp ! 
	300 'ymapa !
	0 'zp ! 0 'vzp !
	0 'puntos ! 5 'vidas !	

	'items p.clear
	200 ( 1? 1 -
		12000 randmax 600 +
		randy +ritem
		) drop 
	+jugador
	time.start
	
	1 
	'dias
	5 randmax ( 1? 1 -
		rot 1 +
		rot >>0
		rot ) drop 
	'diahoy !
	$1 and 'mododia !
	;	
		
|---------------------
#secant

:creador
	msec 10 >>
	secant =? ( drop ; )
	'secant !
	3 randmax 0? ( 800 randy +perro ) drop | 1/3
	4 randmax 0? ( -128 randy +gato ) drop
	;

:saltar
	zp 0? ( 9.0 'vzp ! ) drop  ;

:teclado
	SDLkey 
	<esc> =? ( 0 'vidas ! exit )
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 not and 'btnpad ! )
	>dn< =? ( btnpad %100 not and 'btnpad ! )
	>le< =? ( btnpad %10 not and 'btnpad ! )
	>ri< =? ( btnpad %1 not and 'btnpad ! )	
	<esp> =? ( saltar )
|	<f1> =? ( 800 randy +perro ) 
|	<f2> =? ( -128 randy +gato ) 
|	<f3> =? ( 800 randy +ritem )
	drop 
	;

:alive!
	800 randy +perro 
	-128 randy +gato
	;
	

:ciudad
	5 4
	xmapa 8 >> ymapa 8 >>
	xmapa $ff and neg 
	ymapa $ff and neg
	256 dup mapajuego tiledraws

	0 'error !
	'items p.drawo
	error 'errornow !
	
	5 'items p.sort	
	;

|---------------------------------------- vidas
:nvidas | n -- img
	vidas <? ( drop svida2 ; ) drop svida1 ;
	
| 676 107,56,51
:impvidas
	500
	0 ( 5 <? swap
		dup 10 
		pick3 nvidas SDLImage 
		60 +
		swap 1 + ) 2drop ;
		
|------------------------------------------------
:jugando
	$039be5 SDLcls
	time.delta
	creador
	ciudad

	impvidas	
	
	330 16 sbtniempo sdlImage
	$ffffff font 
	60 tiempo 1000 / - "0:%d" sprint
	|puntos "%d" sprint
	380 16 ttfprint | color font "text" x y -- 

	10 10 sbtndia sdlImage
	$ffffff font diahoy
	80 14 ttfprint | color font "text" x y -- 
	
	tiempo 59000 >? ( exit ) drop
	
	SDLredraw
	teclado ;


|---------------------------------------
:perdiste
	0 0 sperdiste SDLImage

	$11
	puntos "hiciste %d puntos!" sprint
	100 10 600 100 xywh64
	$0 font textbox 
	
	SDLRedraw
	
	SDLkey 
	>esc< =? ( exit )
	drop 
	;

:ganaste	
	0 0 sganaste SDLImage

	$11
	puntos "hiciste %d puntos!" sprint
	100 10 600 100 xywh64
	$0 font textbox 

	SDLRedraw
	
	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:jugar
	rerand
	reset
	
	'jugando SDLshow

	vidas 0? ( drop 
		'perdiste SDLshow 
		; ) drop
	'ganaste SDLshow
	;
	
|---------------------------------------
#texto
"¡Hola, soy Protectrón!
En este juego tendrás que
juntar en un minuto la
mayor cantidad de 
residuos.*
¡IMPORTANTE!
los días lunes, miércoles y
viernes junta los RESÍDUOS
ORGÁNICOS
Los dias martes y jueves los
RESIDUOS INORGÁNICOS*
Depende también de vos
que la ciudad esté limpia
$"

#texto> 
#buffer * 1024
#buffer>

#tt
#waitnext

:>>title
	time.delta 
	dtime 'tt +!
	tt waitnext <? ( drop ; ) drop
	
	texto> c@
	0? ( drop jugar exit ; )
	$2a =? ( drop 'buffer 'buffer> ! tt 3000 + 'waitnext ! 2 'texto> +! ; ) |*
	$24 =? ( drop tt 3000 + 'waitnext ! 1 'texto> +! ; ) |$
	buffer> c!+ 0 over c! 'buffer> !
	1 'texto> +! 
	tt 50 + 'waitnext !
	;
	
:>>adv	
	texto> c@
	0? ( drop jugar exit ; )
	$2a =? ( drop 'buffer 'buffer> ! tt 3000 + 'waitnext ! 1 'texto> +! ; ) |*
	$24 =? ( drop tt 3000 + 'waitnext ! 1 'texto> +! ; ) |$
	buffer> c!+ 0 over c! 'buffer> !
	1 'texto> +! >>adv
	;
	
:inicio
	0 0 sinicio SDLImage

	msec 7 >> $3 and sprplayer
	80 280 
	256 dup tsdraws

	>>title	
	
	$11
	'buffer
	260 60 550 300 xywh64
	$ffffffff font textbox 
	
	SDLRedraw 
	SDLkey 
	<F1> =? ( jugar exit ) 
	<ret> =? ( >>adv )
	>esc< =? ( exit )
	drop 
	;

:pantalla1
	'texto 'texto> !
	'buffer 0 over c! 'buffer> !
	time.start
	0 'tt ! 0 'waitnext !
	musicplay -1 Mix_PlayMusic
	'inicio SDLshow
	Mix_HaltMusic
	;

|---------------------------------------
	
:btni | 'vecor 'i x y -- 
	pick2 @ SDLImagewh guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;
	
:inicial
	gui
	0 0 sinicial SDLImage

	[ pantalla1 ; ] 'sbtnj1 200 300 btni
	[ exit ; ] 'sbtns1 400 300 btni
	
	SDLRedraw
	
	SDLkey 
	<F1> =? ( pantalla1 ) 
	>esc< =? ( exit )
	drop 
	;

:principal
	'inicial SDLshow
	;
	
|---------------------------------------
:main
	500 'items p.ini
	500 'fx p.ini
	"r3sdl" 800 600 SDLinit
	|SDLfull

	ttf_init
	"r3/j2022/basura/font/ChakraPetch-Bold.ttf" 30 TTF_OpenFont 'font !		
	
	"r3/j2022/basura/mapa.map" loadtilemap 'mapajuego !
	128 128 "r3/j2022/basura/img/sprites.png" loadts 'sprplayer !
	"r3/j2022/basura/img/btndia.png" loadimg 'sbtndia !
	"r3/j2022/basura/img/btntiempo.png" loadimg 'sbtniempo !
	"r3/j2022/basura/img/vida1.png" loadimg 'svida2 !
	"r3/j2022/basura/img/vida2.png" loadimg 'svida1 !

	"r3/j2022/basura/img/inicial.png" loadimg 'sinicial !
	"r3/j2022/basura/img/inicio.png" loadimg 'sinicio !
	"r3/j2022/basura/img/ganaste.png" loadimg 'sganaste !
	"r3/j2022/basura/img/perdiste.png" loadimg 'sperdiste !

	"r3/j2022/basura/img/inicial.png" loadimg 'sinicial !

	"r3/j2022/basura/img/btnj1.png" loadimg 'sbtnj1 ! 
	"r3/j2022/basura/img/btnj2.png" loadimg 'sbtnj2 ! 
	"r3/j2022/basura/img/btns1.png" loadimg 'sbtns1 ! 
	"r3/j2022/basura/img/btns2.png" loadimg 'sbtns2 ! 
	
	SNDInit
	"r3/j2022/basura/audio/Basuralu.mp3" Mix_LoadMUS 'musicplay !	
	rerand
	
	principal
	
	SDLquit ;	
	
: main ;