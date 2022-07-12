| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#sprj
#spre

#fx 0 0

#xp 30.0 #yp 30.0
#vxp #vyp

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
:[map]@ | x y -- adr
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
	np sprj xp int. yp int. 6 + 64 64 tsdraws
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
	
:jugando
	$666666 SDLcls

	24 18 0 0 0 0 32 32
	mapajuego tiledraws
	
	'fx p.draw
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