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
#sbtnj1
#sbtnj2
#sbtns1
#sbtns2

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

:time.start
	msec 'prevt ! 0 'dtime ! ;

:time.delta
	msec dup prevt - 'dtime ! 'prevt ! ;

	
:+obj | 'from 'vec --
	'fx p!+ >a >b
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
	-10 'puntos +!
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
	'item 'fx p!+ >a 0 a!+ a!+ a!+ swap a!+ a! ;

:+ritem | x y --
	9 randmax 1 << 'tipoitems + 
	c@+ swap c@ +item ;
	

|--------------------------------
:gato | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 30 + sprplayer 
	16 a+
	a@+ 
	dup 3 + sw >? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - 
	
	distplayer 32 <? ( drop 4drop 0 vidamenos ; ) drop
	tsdraw
	;
	
:+gato | x y --
	'gato 'fx p!+ >a 0 a!+ 0 a!+ 0 a!+ swap a!+ a! ;

|--------------------------------
:perro | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer 
	16 a+
	a@+ 
	dup 5 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - 
	distplayer 32 <? ( drop 4drop 0 vidamenos ; ) drop
	tsdraw
	;
	
:+perro | x y --
	'perro 'fx p!+ >a 0 a!+ 0 a!+ 0 a!+ swap a!+ a! ;
	
|--------------------------------
#btnpad

:xmove | d --
	a@ + 80 max a! ;

:ymove | d --
	a@ + 420 max 790 min a! ;

:a@anim | -- nroanim ; A@!+
	a@ dup dtime 32 << + a!+
	dup $ffff and 
	over 16 >> $ffff and 
	rot 32 >> animcntm + 
	;
	
:a!anim | nuevoanim -- ; a:
	a@ $ffffffff not and or a! ;

:jug	
	>a
	a@anim a@+
	8 a+
	a@+ dup 300 - 'xmapa !
	xmapa - dup 'xp !
	a@+ dup 200 - 'ymapa !
	ymapa - dup 'yp !
	zp int. -
	tsdraw
	
	btnpad
	-8 a+ %1000 and? ( -3 ymove ) %100 and? ( 3 ymove  )
	-8 a+ %10 and? ( -1 xmove ) %1 and? ( 1 xmove )
	drop
	
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
	'jug 'fx p!+ >a
	$40000 a!+ | anim
	sprplayer a!+ | sprite
	
	0 a!+ 
	xp a!+ yp a!+
	xp 300 - 'xmapa ! 
	yp 200 - 'ymapa !
	;
	

:debug	
	.cls "list:" .println
	[ dup 8 + >a a@+ a@+ a@+ "%d %d %d" .println ; ] 'fx p.mapv 
	;
	
|--------------------------------
:randy | -- ; 420..990
	370 randmax 420 + ;

:reset
	100 dup 300 - 'xmapa ! 'xp ! 
	600 dup 200 - 'ymapa ! 'yp ! 
	0 'zp ! 0 'vzp !
	0 'puntos ! 5 'vidas !	

	'fx p.clear
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
	<f1> =? ( exit )
	<f2> =? ( 0 'vidas ! exit )
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

	'fx p.drawo
	
	5 'fx p.sort	
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
	
	10 16 sbtniempo sdlImage

	$ffffff font puntos "%d" sprint
	60 16 ttfprint | color font "text" x y -- 

	500 534 sbtndia sdlImage
	$ffffff font diahoy
	570 550 ttfprint | color font "text" x y -- 
	
	SDLredraw
	teclado ;


|---------------------------------------
:perdiste
	0 0 sperdiste SDLImage

|	[ pantalla1 ; ] 'sbtnj1 200 300 btni
|	[ exit ; ] 'sbtns1 400 300 btni
	
	SDLRedraw
	
	SDLkey 
	>esc< =? ( exit )
	drop 
	;

:ganaste	
	0 0 sganaste SDLImage

|	[ pantalla1 ; ] 'sbtnj1 200 300 btni
|	[ exit ; ] 'sbtns1 400 300 btni
	
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
	$2a =? ( drop 'buffer 'buffer> ! tt 3000 + 'waitnext ! 1 'texto> +! ; ) |*
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
	'inicio SDLshow
	;

|---------------------------------------
	
:btni | 'vecor 'i x y -- 
	181 51 guibox
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