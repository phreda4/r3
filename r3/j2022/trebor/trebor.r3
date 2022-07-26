| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#sprj
#spre

#fx 0 0

#xvp #yvp	| viewport

#xp 30.0 #yp 30.0	| pos player
#vxp 0 #vyp 0		| vel player

#np 0

#mapajuego

|--------------------------------
	
:humo
	>a
	a@
	100 >? ( drop 0 ; ) 
	1 + a!+
	25 spre
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
	xp yp +humo
	;


|--------------------------------
#timeene

#enemilist
1.1 [ 2 3 20 3 ] [ 4 7 ]

:procene
	>a
	a@+ msec 10 *>> |escala
	$1ffff and
	$10000 and? ( $1ffff xor )
	;

|--------------------------------
#enelist 
0.9 [ 2 20 3 3 ] 
0.4 [ 10 10 5 10 ]
0


:vlerp | vel xi xf -- xn
	over - pick2 msec 10 *>> $1ffff and $10000 and? ( $1ffff xor )
	*. + ;

:getxyene	| vel -- x y
	da@+ 32 * xvp - | 32 tile map size - viewport
	da@+ 32 * xvp - | vel x1 x2
	vlerp 	| vel x
	swap
	da@+ 32 * yvp - 
	da@+ 32 * yvp - | vel y1 y2
	vlerp
	nip 	| x y
	;
	
:drawene	
	7 spre
	2swap
	64 64 tsdraws ;

:hitplayer | x y -- x y
|	over xp - over yp - distfast
|	32 <? ( 1 'modo ! )
|	drop
	;	
	
:enemigos
	'enelist >a ( a@+ 1? 
		getxyene
		hitplayer
		drawene
		) drop
	;
	
|--------------------------------
:viewport
	xp int. sw 1 >> - 'xvp !
	yp int. sh 1 >> - 'yvp !
	;
		
|--------------------------------
:[map]@ | x y -- adr
	swap xvp - 
	swap yvp - 
	scr2tile c@ ;
	
:roof? | -- techo?
	xp int. 32 + 
	yp int. 8 +
	[map]@ ;

:floor? | -- piso?
	xp int. 16 + yp int. 64 + [map]@
	xp int. 40 + yp int. 64 + [map]@ or	
	;

:wall? | dx -- wall?
	xp int. +
	yp int. 32 +
	[map]@ ;
	
:panim | -- nanim	
	msec 5 >> 7 mod abs ;
	
:pstay
	|0 'np !
	;
	
:prunl
|	estela	
	4 wall? 1? ( drop ; ) drop
	22 panim + 'np !
	-2.0 'xp +!
	;
	
:prunr
|	estela	
	52 wall? 1? ( drop ; ) drop
	0 panim + 'np !
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
	<up> =? ( -8.0 'vyp ! )
	drop
	;

:debug
	$ffffff bcolor 
	10 10 bat 
	floor? "f:%d " sprint bprint  	
	roof? "r:%d " sprint bprint
	;
	
:player	
	np sprj 
	xp int. xvp -
	yp int. 6 + yvp -
	64 64 tsdraws
	ep ex
	pisoysalto
	
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
	
:drawmapa
	26 20
	xvp 5 >> yvp 5 >>
	xvp $1f and neg 
	yvp $1f and neg
	32 32
	mapajuego 'vectortile 
	tiledrawvs ;
	
	
:jugando
	$666666 SDLcls

	viewport
	drawmapa	
	'fx p.draw
	enemigos
	player
	
	SDLredraw
	
	teclado ;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	
	32 32 "r3\j2022\trebor\treborj.png" loadts 'sprj !
	20 20 "r3\j2022\trebor\trebore.png" loadts 'spre !
	"r3\j2022\trebor\nivel.map" loadtilemap 'mapajuego !
	
	'jugando SDLshow
	SDLquit ;	
	
: main ;