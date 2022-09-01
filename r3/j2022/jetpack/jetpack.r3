| Jetpac 

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#sprplayer
#fx 0 0


#mapajuego
#xvp #yvp

#xp 200.0 #yp 500.0	| posicion
#vxp #vyp			| velocidad
#axp #ayp			| aceleracion

#cohete
#nspr 1

:disparo
	>a
	8 sprplayer 
	a@+ int. a@+ int. tsdraw
	a@ a> 16 - +!
	| limites 
	a> 16 - @  int.
	-16 <? ( drop 0 ; )
	800 >? ( drop 0 ; )
	drop
	;
	
:veldisp
	nspr 1 =? ( drop 4.0 ; ) drop
	-4.0 ;
	
:+disparo | x y --
	'disparo 'fx p!+ >a
	swap a!+ a!+ 
	veldisp a!
	;
	
:fuego	
	2 msec 4 >> $3 and + sprplayer xp int. yp int. 10 + tsdraw
	;
	
:jetpack
	
	10 10 bat 
	ayp axp vyp vxp "%f %f %f %f" sprint bprint	

	cohete 1? ( fuego ) drop 
	nspr sprplayer xp int. yp int. tsdraw

	xp vxp axp +
	1.9 clampmax -1.9 clampmin | limites x
	dup 'vxp !
	+
	'xp !

	vyp ayp + 0.1 + | graveda
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
	<up> =? ( -0.2 'ayp ! 1 'cohete ! )	>up< =? ( 0 'ayp ! 0 'cohete ! )	
	<le> =? ( -0.2 'axp ! 0 'nspr ! ) >le< =? ( 0 'axp ! )	
	<ri> =? ( 0.2 'axp ! 1 'nspr ! ) >ri< =? ( 0 'axp ! )
	<esp> =? ( xp yp +disparo )
	drop 
	;
	
:drawmapa
	26 20
	xvp 5 >> yvp 5 >>
	xvp $1f and neg 
	yvp $1f and neg
	32 32
	mapajuego tiledraws ;
	
:juego
	0 SDLcls
	drawmapa
	
	'fx p.draw
	jetpack
	SDLredraw
	
	teclado
	;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	SDLfull
	32 32 "r3\j2022\jetpack\jetpack.png" loadts 'sprplayer !
	"r3\j2022\jetpack\nivel.map" loadtilemap 'mapajuego !
	
	'juego SDLshow
	SDLquit ;	
	
: main ;
