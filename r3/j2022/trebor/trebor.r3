| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#sprites

#fx 0 0

#xp 30.0 #yp 30.0
#vxp #vyp

#np 65

#mapajuego

|--------------------------------
	
:humo
	>a
	a@
	100 >? ( drop 0 ; ) 
	1 + a!+
	25 sprites 
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

#sanim ( 0 1 0 2 )

:panim | -- nanim	
	msec 7 >> $3 and 'sanim + c@ ;
	
:pstay
	65 'np !
	;
:prunl
	estela	
	94 panim + 'np !
	-2.0 'xp +!
	;
:prunr
	estela	
	91 panim + 'np !
	2.0 'xp +!
	;
:prunu
	estela	
	68 panim + 'np !
	-2.0 'yp +!
	;
:prund
	estela	
	65 panim + 'np !
	2.0 'yp +!
	;

:saltar
|	zp 1? ( drop ; ) drop
|	4.0 'vzp !
	;
	
#ep 'pstay


:player	
	np sprites xp int. yp int. 64 64 tsdraws
	ep ex
	
	;
	
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
	drop 
	;
	
:jugando
	0 SDLcls

	24 18 0 0 0 0 64 64
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
	
	32 32 "r3\j2022\trebor\trebor.png" loadts 'sprites !
	"media/map/ini.map" loadtilemap 'mapajuego !
	
	'jugando SDLshow
	SDLquit ;	
	
: main ;