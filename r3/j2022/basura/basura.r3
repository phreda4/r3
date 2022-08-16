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

#xp 30
#yp 230
#zp 0
#vzp 0

#xmapa 0 
#ymapa 0

#np 3

|--------------------------------
:humo
	>a
	a@
	100 >? ( drop 0 ; ) 
	1 + a!+
	25 sprplayer 
	a@+  a@+ tsdraw
	;
	
:+humo | x y --
	'humo 'fx p!+ >a 
	0 a!+
	swap a!+ a!+
	;
	
#ev 0	
:estela	
	1 'ev +!
	ev 20 <? ( drop ; ) drop
	0 'ev !
	|xp yp zp - +humo
	;
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
)

|--------------------------------
:item | a --
	>a a@ dup 0.02 + a!+ 
	16 >> a@+ and a@+ + sprplayer a@+ 
	dup 1 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - tsdraw
	;
	
:+item | x y c i --
	'item 'fx p!+ >a 0 a!+ a!+ a!+ swap a!+ a!
	3 'fx p.sort ;

:+ritem | x y --
	10 randmax 1 << 'tipoitems +
	c@+ swap c@ +item ;
	
|--------------------------------
:gato | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 30 + sprplayer a@+ 
	dup 3 + sw >? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - tsdraw
	;
	
:+gato | x y --
	'gato 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;
	

|--------------------------------
:perro | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer a@+ 
	dup 3 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ ymapa - tsdraw
	;
	
:+perro | x y --
	'perro 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;
	
|--------------------------------
:panim | -- nanim	
	msec 7 >> $3 and ;
	
:pstay
	;
	
:prunl 
	xp 2 -
	100 <? ( drop ; )
	'xp ! ;
:prunr 
	xp 2 +
	500 >? ( drop ; ) 
	'xp ! ;
:prunu 
	yp 2 -
	200 <? ( drop ; )
	dup 330 - 'ymapa !
	'yp ! ;
:prund 
	yp 2 +
	700 >? ( drop ; )
	dup 330 - 'ymapa !
	'yp ! ;
:saltar
	zp 1? ( drop ; ) drop
	5.0 'vzp !
	;
	
#ep 'pstay

:jugador
	>a 0
	
|	12 sprplayer xp 2 + yp 2 + tsdraw	| sombra
	0 panim + sprplayer xp yp zp int. - ymapa - tsdraw
	ep ex
	
	zp vzp +
	0 <=? ( drop 0 'zp ! 0 'vzp ! ; )
	'zp !
	-0.1 'vzp +!
	;
	
:+jugador
	'jugador 'fx p!+ >a
	8 a+ xp a!+ yp a!+
	3 'fx p.sort
	;
		
:hacenivel
	200 ( 1? 1 -
		12000 randmax 800 +
		440 randmax 260 + +ritem
		) drop ;
		
|--------------------------------
:teclado
	SDLkey 
	>esc< =? ( exit )
	<up> =? ( 'prunu 'ep ! )
	<dn> =? ( 'prund 'ep ! )
	<le> =? ( 'prunl 'ep ! )
	<ri> =? ( 'prunr 'ep ! )
	>up< =? ( 'pstay 'ep ! )
	>dn< =? ( 'pstay 'ep ! )
	>le< =? ( 'pstay 'ep ! )
	>ri< =? ( 'pstay 'ep ! )
	<esp> =? ( saltar )
	<f1> =? ( 800 400 randmax 180 + +perro ) 
	<f2> =? ( -128 400 randmax 180 + +gato ) 
	<f3> =? ( 800 400 randmax 180 + +ritem )
	drop 
	;

:ciudad
	5 4
	xmapa 8 >> ymapa 8 >>
	xmapa $ff and neg 
	ymapa $ff and neg
	256 dup mapajuego tiledraws
	1 'xmapa +! ;

:jugando
	$039be5 SDLcls
	ciudad
	+jugador
	'fx p.drawo
	
	$0 font "vidas:" 20 20 ttfprint | color font "text" x y -- 
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