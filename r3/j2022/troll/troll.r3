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
	xp int. 16 + 
	yp int. 2 +
	[map]@ ;

:floor? | -- piso?
	xp int. 2 + yp int. 32 + [map]@
	xp int. 30 + yp int. 32 + [map]@ or	
	;

:wall? | dx -- wall?
	xp int. +
	yp int. 16 +
	[map]@ ;
	
:panim | -- nanim	
	msec 6 >> 3 mod abs ;
	
:pstay
	|0 'np !
	;
	
:prunl
|	estela	
	0 wall? 1? ( drop ; ) drop
	8 panim + 'np !
	-2.0 'xp +!
	;
	
:prunr
|	estela	
	32 wall? 1? ( drop ; ) drop
	0 panim + 'np !
	2.0 'xp +!
	;

	
#ep 'pstay

:pisoysalto
	floor? 0? ( drop
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
	yp int. yvp -
	32 32 tsdraws
	ep ex
	pisoysalto
	
	vyp 'yp +!
	vxp 'xp +!
	
	viewport
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
	player
	
	SDLredraw
	
	teclado ;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	
	8 8 "r3\j2022\troll\troll-p.png" loadts 'sprj !
	"r3\j2022\troll\nivel.map" loadtilemap 'mapajuego !
	
	'jugando SDLshow
	SDLquit ;	
	
: main ;