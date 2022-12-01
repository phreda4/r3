| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3
^r3/lib/gui.r3

^r3/util/penner.r3

#puntos
#vidas

#sprj
#sinicio
#sganaste
#sperdiste
#sbtnj1 #sbtnj2
#sbtns1 #sbtns2


#fx 0 0
#ene 0 0

#xvp #yvp	| viewport

#xp 30.0 #yp 30.0	| pos player
#vxp 0 #vyp 0		| vel player

#np 0
#face
#ep 0

#mapajuego

|--------------------------------
#prevt
#dtime
#reloj

:time.start
	msec 'prevt ! 0 'dtime ! 
	0 'reloj ! ;

:time.delta
	msec dup prevt - 'dtime ! 'prevt ! 
	dtime 'reloj +! ;

:animcntm | cnt msec -- 0..cnt-1
	55 << 1 >>> 63 *>> ; | 55 speed

|--------------------------------
:viewport
	xp int. sw 1 >> - 'xvp !
	yp int. sh 1 >> - 'yvp !
	;
		
|--------------------------------
:[map]@ | x y -- c
	swap xvp - 
	swap yvp - 
	scr2tile c@ ;

:[map]! | c x y -- 
	swap xvp - 
	swap yvp - 
	scr2tile c! ;
	
:[map]@s
	[map]@ 
	1 =? ( ; )
	3 =? ( ; )
	9 =? ( ; )
	41 42 bt? ( ; ) 
	50 56 bt? ( ; )
	0 nip ; 
	
:roof? | -- techo?
	xp int. 32 + 
	yp int. 8 +
	[map]@s ;

:floor? | -- piso?
	xp int. 16 + yp int. 64 + [map]@s
	xp int. 40 + yp int. 64 + [map]@s or	
	;

:wall? | dx -- wall?
	xp int. +
	yp int. 32 +
	[map]@s ;


|---------------------------------------------
:muerto
	>a
	a@ dtime + 
	10000 >? ( drop 0 ; ) 
	a!+ 
	a@+
	sprj 
	a@+ int. xvp -
	a@+ int. yvp -
	64 64 tsdraws
	;
	
:+muerto | face x y --
	'muerto 'fx p!+ >a 
	0 a!+ | TIME
	rot a!+
	swap a!+ a!+
	;

#testf

|---------------------------------------------
:hitene | x y i n p -- x y p
	dup 24 + >a 

	pick4 a@+ int. xvp - 32 + -
	pick4 a@+ int. yvp - 32 + -	
	distfast 
	16 >? ( drop ; )
	drop
	
	-24 a+
	a@+	16 >> 3 >> 16 +
	a@+ a@+ 16.0 + +muerto
	
	dup 'ene p.del
|	pick4 16 << pick4 16 << +fx
	1 'puntos +!
|	1 playsnd
	0 'testf !
	;

	
:disparo
	dup >a
	a@+ int. xvp - 4 - 
	-8 <? ( 2drop 0 ; )
	800 >? ( 2drop 0 ; )
	a@+ int. yvp -
	
	over xvp +
	over yvp +
	[map]@s 1? ( 4drop 0 ; ) drop
	a> >r
	1 'testf !
	'hitene 'ene p.mapv
	
	over 8 + over 
	SDLLine
	r> >a
	a@ swap +!
	testf 0? ( ; ) drop
	;
	
:+disparo | dirx x y --
	'disparo 'fx p!+ >a 
	swap a!+ a!+
	a!+
	;

#timeshoot

:disparar
	msec timeshoot <? ( drop ; ) 1000 + 'timeshoot !
	6.0
	face 1 nand? ( swap neg swap ) drop 
	xp 32.0 + over + yp 34.0 + +disparo
	;

	
|---------------------------------------------
#dirx

:direne | dirx -- dirx sdir
	-? ( $40004 ; ) $c0004 ;
	
:enemigo | adr --
	dup >a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + 	
	sprj 
	a@+ 
	xp <? ( 1.0 'dirx ! )
	xp >? ( -1.0 'dirx ! )
	int. xvp -
	a@+ int. yvp -
	64 64 tsdraws

	>a 8 a+
	dirx 
	direne a!+
	a> +!
	
	a@+ xp - int. 
	a@+ yp - int. 
	distfast 32 >? ( drop ; ) drop

	-16 a+
	5.0
	a@ xp >? ( swap neg swap ) drop
	'vxp !
	
	-10.0 'vyp !  
	-1 'vidas +!
	vidas 0? ( exit ) drop
	;
	
:+enemigo | x y --
	'enemigo 'ene p!+ >a 
	0 a!+ | TIME
	$80004 a!+
	swap a!+ a!+
	;

#enelist  24 36 37 46 81 82 83 104 106 108 131 133 135 137 139 155 166 0
#enenow 'enelist

:testene
	enenow @ 0? ( drop ; )
	5 << | 32*
	xp int. sw 1 >> + >? ( drop ; )
	16 << 
	15 5 << 16 << +enemigo
	8 'enenow +! ;


:panim | -- nanim	
	msec 5 >> $3 and ;
	
	
:pstay
	0
	np 7 >? ( 2drop 8 dup ) drop
	'np !
	;
	
:prunl
|	estela	
	4 wall? 1? ( drop ; ) drop
	0 panim + 'np !
	-2.0 'xp +!
	$e face and 'face !
	;
	
:prunr
|	estela	
	52 wall? 1? ( drop ; ) drop
	8 panim + 'np !
	2.0 'xp +!
	1 face or 'face !
	;

:saltando
	0.4 vyp + 
	10.0 clampmax
	'vyp !
	roof? 1? ( vyp -? ( 0 'vyp ! ) drop )  drop
	floor? 0? ( drop ; ) drop
	0 'vyp !
	yp $ffffe00000 and 'yp !
	1 face and 'face !
	;
	
:pisoysalto
	face %10 and? ( drop saltando ; ) drop
	floor? 0? ( drop
		%10 face or 'face !
		saltando
		; ) drop
	
	SDLkey
	<up> =? ( -10.0 'vyp ! %10 face or 'face ! )
	drop
	;

:debug
	$ffffff bcolor 
	10 10 bat 
	floor? "f:%d " sprint bprint  	
	roof? "r:%d " sprint bprint
	;
	
:monedas
	xp int. 32 + yp int. 60 + [map]@
	33 <>? ( drop ; ) drop
	0 
	xp int. 32 + yp int. 60 + [map]!
	1 'puntos +!
	;
		
:player	
	np sprj 
	xp int. xvp -
	yp int. yvp -
	64 64 tsdraws
	ep ex
	pisoysalto
	monedas
	
	vyp 'yp +!
	vxp 'xp +!
	
	vxp 0.96 *. 'vxp !
	;
	
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<le> =? ( 'prunl 'ep ! )
	<ri> =? ( 'prunr 'ep ! )
	>le< =? ( 'pstay 'ep ! )
	>ri< =? ( 'pstay 'ep ! )
	
	<esp> =? ( disparar ) 
	<f1> =? ( xp yp +enemigo )
	drop 
	;

|---- sin reemplazo	
:drawmapa
	26 20
	xvp 5 >> yvp 5 >>
	xvp $1f and neg 
	yvp $1f and neg
	32 32
	mapajuego tiledraws ;
	
	
|---- con reemplazo	
:vectortile | tile -- tile
	17 <? ( ; ) 19 >? ( ; ) | agua
	drop
	msec 8 >> 3 mod abs 17 + 
	;
	
:drawmapar
	26 20
	xvp 5 >> yvp 5 >>
	xvp $1f and neg 
	yvp $1f and neg
	32 32
	mapajuego 'vectortile 
	tiledrawvs ;
	
|---- vidas	
:nvidas | n -- img
	vidas <? ( drop 18 ; ) drop 19 ;
	
| 676 107,56,51
:impvidas
	20
	0 ( 3 <? swap
		over nvidas sprj 
		pick2 10 tsdraw
		40 + swap 1 + ) 2drop ;
	
:jugando
	$0 SDLcls
	time.delta
	
	testene
	
	viewport
	drawmapa	
	'ene p.draw
	player
	'fx p.draw

	xp 7600.0 >? ( exit ) drop
	impvidas		
	|10 10 bat vidas "vidas:%d" sprint bprint
	
	600 10 bat
	puntos "%d " sprint bprint
	|xp "%f" sprint bprint
	SDLredraw
	
	teclado ;

|--------------------------------
:reset
	0 'puntos !
	3 'vidas !
	'fx p.clear
	'ene  p.clear
	0 'xvp ! 0 'yvp	! | viewport
	30.0 'xp ! 446.0 'yp !	| pos player
	0 'vxp ! 0 'vyp !		| vel player
	8 'np ! 1 'face ! 'pstay 'ep !
	'enelist 'enenow !
 	;

|------------
:btni | 'vecor 'i x y -- 
	pick2 @ SDLImagewh guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;
	
:gano
	gui
	0 0 sganaste SDLImage
	'exit 'sbtns1 400 400 btni
	SDLRedraw
	
	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:perdio
	gui
	0 0 sperdiste SDLImage
	'exit 'sbtns1 400 400 btni
	SDLRedraw
	
	SDLkey 
	>esc< =? ( exit )
	drop 
	;

:jugar
	reset 
	'jugando sdlshow

	vidas dup "%d" .println
	0? ( drop 'perdio sdlshow ; ) drop
	'gano sdlshow
	;

:menu
	gui
	0 0 sinicio SDLImage

	'jugar 'sbtnj1 200 400 btni
	'exit 'sbtns1 400 400 btni
	SDLredraw
	
	SDLkey
	>ESC< =? ( exit )
	drop
	;
	
:main
	100 'fx p.ini
	100 'ene p.ini
	"r3sdl" 800 600 SDLinit
	bfont2 
	|SDLfull
	
	"r3\j2022\manwithcap\nivel.map" loadtilemap 'mapajuego !
	32 32 "r3\j2022\manwithcap\img\sprites.png" loadts 'sprj !
	"r3\j2022\manwithcap\img\inicio.png" loadimg 'sinicio !		
	"r3\j2022\manwithcap\img\ganaste.png" loadimg 'sganaste !		
	"r3\j2022\manwithcap\img\perdiste.png" loadimg 'sperdiste !		

	"r3\j2022\manwithcap\img\btnj1.png" loadimg 'sbtnj1 !		
	"r3\j2022\manwithcap\img\btnj2.png" loadimg 'sbtnj2 !		
	"r3\j2022\manwithcap\img\btns1.png" loadimg 'sbtns1 !		
	"r3\j2022\manwithcap\img\btns2.png" loadimg 'sbtns2 !		
	
	time.start
	'menu SDLshow
	SDLquit ;	
	
: main ;