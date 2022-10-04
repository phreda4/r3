| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

^r3/util/penner.r3


#puntos
#vidas

#sprj

#fx 0 0
#ene 0 0

#xvp #yvp	| viewport

#xp 30.0 #yp 30.0	| pos player
#vxp 0 #vyp 0		| vel player

#np 0

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

#dirx

:direne | dirx -- dirx sdir
	-? ( $80004 ; ) $140004 ;
	
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
	|-4.0 'vxp !
	-10.0 'vyp !
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
	xp int. sw 2 >> + <? ( drop ; )
	16 << 
	15 5 << 16 << +enemigo
	8 'enenow +! ;
	
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


:panim | -- nanim	
	msec 5 >> $3 and ;
	
:pstay
	0
	np 11 >? ( 2drop 12 dup ) drop
	'np !
	;
	
:prunl
|	estela	
	4 wall? 1? ( drop ; ) drop
	0 panim + 'np !
	-2.0 'xp +!
	;
	
:prunr
|	estela	
	52 wall? 1? ( drop ; ) drop
	12 panim + 'np !
	2.0 'xp +!
	;

	
#ep 'pstay

:pisoysalto
	floor? 0? ( drop
		|7 panim + 'np !
		0.3 'vyp +!
		10.0 clampmax
		roof? 1? ( vyp -? ( 0 'vyp ! ) drop ) drop
		; ) drop
	0 'vyp !
	yp $ffffe00000 and 'yp ! | fit y to map (64.0)
	
	SDLkey
	<up> =? ( -10.0 'vyp ! )
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
	;
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<le> =? ( 'prunl 'ep ! )
	<ri> =? ( 'prunr 'ep ! )
	>le< =? ( 'pstay 'ep ! )
	>ri< =? ( 'pstay 'ep ! )
	
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
	
	
:jugando
	$0 SDLcls
	time.delta
	
	testene
	
	viewport
	drawmapa	
	'ene p.draw
	player
	'fx p.draw
	
	SDLredraw
	
	teclado ;

:main
	100 'fx p.ini
	100 'ene  p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	
	32 32 "r3\j2022\efrain\sprites.png" loadts 'sprj !
	"r3\j2022\efrain\nivel.map" loadtilemap 'mapajuego !
	
	time.start
	
	'jugando SDLshow
	SDLquit ;	
	
: main ;