| vial

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/lib/rand.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#mapajuego
#sprplayer
#sprperro

#fx 0 0

#xp 30.0 
#yp 230.0
#zp 0
#vzp 0

#np 3

|--------------------------------
:humo
	>a
	a@
	100 >? ( drop 0 ; ) 
	1 + a!+
	25 sprplayer 
	a@+ int. a@+ int. tsdraw
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
:perro | a --
	>a
	a@ dup 0.1 + a!+ 
	16 >> $3 and sprperro a@+ 
	dup 1 - -96 <? ( 4drop 0 ; ) a> 8 - !
	a@+ tsdraw
	;
	
:+perro | x y --
	'perro 'fx p!+ >a
	0 a!+
	swap a!+ a!
	
	3 'fx p.sort
	;
	
|--------------------------------
#sanim ( 0 1 0 2 )

:panim | -- nanim	
	msec 7 >> $3 and 'sanim + c@ ;
	
:pstay
	3 panim + 'np ! ;
	
:prunl
	estela	
	0 panim + 'np !
	-2.0 'xp +!
	;
:prunr
	estela	
	3 panim + 'np !
	2.0 'xp +!
	;
:prunu
	estela	
	0 panim + 'np !
	-2.0 'yp +!
	;
:prund
	estela	
	3 panim + 'np !
	2.0 'yp +!
	;

:saltar
	zp 1? ( drop ; ) drop
	4.0 'vzp !
	;
	
#ep 'pstay

:jugador
	>a 0
	
|	12 sprplayer xp int. 2 + yp int. 2 + tsdraw	| sombra
	np sprplayer xp int. yp zp - int. tsdraw
	ep ex
	
	zp vzp +
	0 <=? ( drop 0 'zp ! 0 'vzp ! ; )
	'zp !
	-0.1 'vzp +!
	;
	
:+jugador
	'jugador 'fx p!+ >a
	8 a+
	xp int. a!+
	yp int. 32 + a!+
	3 'fx p.sort
	;
		
|--------------------------------
:coso
	>a
	8 a+
	0 sprperro a@+ a@+ tsdraw
	;
	
:+coso
	'coso 'fx p!+ >a			
	0 a!+
	400 a!+
	300 a!+
	;
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
	drop 
	;

#xmapa 0
#xfmapa 0
	
:jugando
	$039be5 SDLcls

	5 3 xfmapa 0 xmapa 0 256 dup mapajuego tiledraws
	xmapa 1 -
	-255 <? ( 0 nip 1 'xfmapa +! ) 
	'xmapa ! 
	
	+jugador
	'fx p.drawo
	
	SDLredraw
	
	teclado ;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	
	"r3\j2022\vial\mapa.map" loadtilemap 'mapajuego !
	
	128 128 "r3\j2022\vial\Robot.png" loadts 'sprplayer !
	96 96 "r3\j2022\vial\perro.png" loadts 'sprperro !
|	+coso
	'jugando SDLshow
	SDLquit ;	
	
: main ;