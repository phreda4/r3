| Jetpac 

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#sprplayer
#fx 0 0

#xp 200.0 #yp 500.0
#vxp #vyp
#axp #ayp

:int. 16 >> ;

:jetpack
	
	10 10 bat 
	ayp axp vyp vxp "%f %f %f %f" sprint bprint	

	|cohete 1? ( fuego ) drop 
	65 sprplayer xp int. yp int. tsdraw

	xp vxp axp +
	1.9 clampmax -1.9 clampmin | limites x
	dup 'vxp !
	+
	'xp !

	vyp ayp + 0.1 +
	5.0 clampmax -4.0 clampmin | limite y
	'vyp !
	
	vyp 'yp +!
	
	yp
	500.0 >? ( 500.0 'yp ! 0 'vyp ! )
	drop
	;

:teclado
	SDLkey 
	>esc< =? ( exit )
	<up> =? ( -0.2 'ayp ! )	>up< =? ( 0 'ayp ! )	
	<le> =? ( -0.2 'axp ! ) >le< =? ( 0 'axp ! )	
	<ri> =? ( 0.2 'axp ! ) >ri< =? ( 0 'axp ! )
	<esp> =? (  )
	drop 
	;
	
:juego
	0 SDLcls
	
	jetpack
	SDLredraw
	
	teclado
	;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	64 64 "media\img\sokoban_tilesheet.png" loadts 'sprplayer !

	'juego SDLshow
	SDLquit ;	
	
: main ;
