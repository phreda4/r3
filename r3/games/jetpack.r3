| Jetpac 

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#sprplayer
#fx 0 0

#xp 200.0 #yp 500.0	| posicion
#vxp #vyp			| velocidad
#axp #ayp			| aceleracion

#nspr 91

:disparo
	8 + >a
	25 sprplayer 
	a@+ int. a@+ int. tsdraw
	a@ a> 16 - +!
	| limites 
	a> 16 - @  int.
	-16 <? ( drop 0 ; )
	800 >? ( drop 0 ; )
	drop
	;
	
:veldisp
	nspr 91 =? ( drop 4.0 ; ) drop
	-4.0 ;
	
:+disparo | x y --
	'disparo 'fx p!+ >a
	swap a!+ a!+ 
	veldisp a!
	;
	
:jetpack
	
	10 10 bat 
	ayp axp vyp vxp "%f %f %f %f" sprint bprint	

	|cohete 1? ( fuego ) drop 
	nspr sprplayer xp int. yp int. tsdraw

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
	500.0 >? ( 500.0 'yp ! 0 'vyp ! 0 'vxp ! )
	drop
	;

:teclado
	SDLkey 
	>esc< =? ( exit )
	<up> =? ( -0.2 'ayp ! 91 'nspr ! )	>up< =? ( 0 'ayp ! )	
	<le> =? ( -0.2 'axp ! 94 'nspr ! ) >le< =? ( 0 'axp ! )	
	<ri> =? ( 0.2 'axp ! ) >ri< =? ( 0 'axp ! )
	<esp> =? ( xp yp +disparo )
	drop 
	;
	
:juego
	0 SDLcls
	
	'fx p.draw
	jetpack
	SDLredraw
	
	teclado
	;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	64 64 "media\img\sokoban_tilesheet.png" tsload 'sprplayer !

	'juego SDLshow
	SDLquit ;	
	
: main ;
