| vial

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/lib/rand.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/fontutil.r3

#mapajuego
#sprplayer
#font

#fx 0 0

#xmapa 0 
#ymapa 170

#xp 100
#yp 500
#zp 0
#vzp 0

|--------------------------------
| nro-tile mask-cnt ( 0>1 1>2 3>4)
#tipoitems (
6 0
7 0
8 3
12 1
14 3
18 1
20 2
24 1
34 0
35 0
36 0
)

|--------------------------------
:item | a --
	>a a@ dup 0.05 + a!+ 
	16 >> a@+ and a@+ + sprplayer 
	a@+ xmapa -
	a@+ ymapa - 
	tsdraw ;
	
:+item | x y c i --
	'item 'fx p!+ >a 0 a!+ a!+ a!+ swap a!+ a! ;

:+ritem | x y --
	11 randmax 1 << 'tipoitems +
	c@+ swap c@ +item ;
	
|--------------------------------
:gato | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 30 + sprplayer 
	16 a+
	a@+ 
	dup 3 + sw >? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - tsdraw
	;
	
:+gato | x y --
	'gato 'fx p!+ >a 0 a!+ 0 a!+ 0 a!+ swap a!+ a! ;

|--------------------------------
:perro | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer 
	16 a+
	a@+ 
	dup 3 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - tsdraw
	;
	
:+perro | x y --
	'perro 'fx p!+ >a 0 a!+ 0 a!+ 0 a!+ swap a!+ a! ;
	
|--------------------------------
#btnpad

#nrop

:panim! | nro -- 
	msec 7 >> $3 and + 'nrop ! ;
	
:pstay
	zp 1? ( drop ; ) drop 
	0 panim!
	;
	 
:saltar
	zp 1? ( drop ; ) drop
	5.0 'vzp !
	4 'nrop !
	;

:xmove | d --
	a@ + a! ;

:ymove | d --
	a@ + 420 max 990 min a! ;

:jug	
	>a
	a@ dup 0.05 + a!+ 
	16 >> a@+ and a@+ + 
	drop
	0 panim! 
	nrop sprplayer 
	a@+ xmapa -
	a@+ ymapa - zp int. -
	tsdraw
	
	btnpad
	-8 a+
	%1000 and? ( -2 ymove  )
	%100 and? ( 2 ymove  )
	-8 a+
	%10 and? ( -1 xmove )
	%1 and? ( 1 xmove )
	drop
	a@ 2 + a!
	
	a@+ 300 - 'xmapa ! 
	a@ 200 - 'ymapa ! 
	
	zp vzp +
	0 <=? ( drop 0 'zp ! 0 'vzp ! ; )
	'zp !
	-0.1 'vzp +!	
	;

:+juga
	'jug 'fx p!+ >a
	8 a+ 0 a!+ 0 a!+ xp a!+ yp a!+
	;
	
:randy | -- ; 420..990
	570 randmax 420 + ;
		
:hacenivel
	200 ( 1? 1 -
		12000 randmax 800 +
		randy +ritem
		) drop 
	+juga		
	;
	
	
:debug	
	.cls "list:" .println
	[ dup 8 + >a a@+ a@+ a@+ "%d %d %d" .println ; ] 'fx p.mapv 
	;
	
|--------------------------------
:teclado
	SDLkey 
	>esc< =? ( exit )
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 not and 'btnpad ! )
	>dn< =? ( btnpad %100 not and 'btnpad ! )
	>le< =? ( btnpad %10 not and 'btnpad ! )
	>ri< =? ( btnpad %1 not and 'btnpad ! )	
	<esp> =? ( saltar )
	<f1> =? ( 800 randy +perro ) 
	<f2> =? ( -128 randy +gato ) 
	<f3> =? ( 800 randy +ritem )
	drop 
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

:jugando
	$039be5 SDLcls
	ciudad
	
	|$0 font "vidas:" 20 20 ttfprint | color font "text" x y -- 
	
	$0 font 
	yp "vidas:%d" sprint
	20 20 ttfprint | color font "text" x y -- 
	
	SDLredraw
	teclado ;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	|SDLfull

	ttf_init
	"r3/j2022/basura/font/ChakraPetch-Bold.ttf" 30 TTF_OpenFont 'font !		
	
	"r3\j2022\basura\mapa.map" loadtilemap 'mapajuego !
	128 128 "r3\j2022\basura\sprites.png" loadts 'sprplayer !
	
	hacenivel
	
	'jugando SDLshow
	SDLquit ;	
	
: main ;