| Jetpac 

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/lib/rand.r3
^r3/lib/gui.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#sinicio
#sganaste
#sperdiste
#sbtnj1 #sbtnj2
#sbtns1 #sbtns2

#sprplayer
#fx 0 0

#mapajuego
#xvp #yvp

#xp 200.0 #yp 500.0	| posicion
#vxp #vyp			| velocidad
#axp #ayp			| aceleracion

#cohete
#nspr 1
#puntos

:[map]@ | x y -- c
	swap xvp - 
	swap yvp - 
	scr2tile c@ ;

:[map]! | c x y -- 
	swap xvp - 
	swap yvp - 
	scr2tile c! ;

:[map]@s | x y -- c
	[map]@
	3 <? ( ; ) 
	drop 0 ;
	
:disparo
	>a
	8 sprplayer 
	a@+ int. xvp - a@+ int. tsdraw
	a@ a> 16 - +!
	| limites 
	a> 16 - @  int.
	xvp <? ( drop 0 ; )
	xvp 800 + >? ( drop 0 ; )
	drop
	;
	
:veldisp
	nspr 1 =? ( drop 5.0 ; ) drop
	-5.0 ;
	
:+disparo | x y --
	'disparo 'fx p!+ >a
	swap a!+ a!+ 
	veldisp a!
	;
	
:fuego	
	2 msec 4 >> $3 and + sprplayer xp int. xvp - yp int. 10 + tsdraw
	;
	
:jetpack
	
	|10 10 bat ayp axp vyp vxp "%f %f %f %f" sprint bprint	
10 10 bat xp yp "%f %f" sprint bprint	

	cohete 1? ( fuego ) drop 
	nspr sprplayer xp int. xvp - yp int. tsdraw

	xp vxp axp +
	1.9 clampmax -1.9 clampmin | limites x
	dup 'vxp !
	+
	dup 16 >> 400 - 'xvp !
	'xp !

	vyp ayp + 0.1 + | gravedad
	5.0 clampmax -4.0 clampmin | limite y
	'vyp !
	
	vyp 'yp +!
	
	xp int. yp int. [map]@s 1? ( 
|		1.0 randmax 0.5 - 'vyp +! 1.0 randmax 0.5 - 'vxp +! 
		-1 'puntos !
		exit
		) drop
		
	xp 3500.0 >? ( 	exit ) drop
	
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

|------------
:btni | 'vecor 'i x y -- 
	pick2 @ SDLImagewh guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;
		
:gano
	gui
	0 0 sganaste SDLImage
	'exit 'sbtns1 450 400 btni
	SDLRedraw
	
	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:perdio
	gui
	0 0 sperdiste SDLImage
	'exit 'sbtns1 450 400 btni
	SDLRedraw
	
	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:jugar
	200.0 'xp !
	500.0 'yp !
	0 'puntos !
	'juego SDLshow

	puntos -? ( drop 'perdio SDLShow ; ) drop
	'gano sdlShow
	;

:menu
	gui
	0 0 sinicio SDLImage

	'jugar 'sbtnj1 100 400 btni
	'exit 'sbtns1 450 400 btni
	SDLredraw
	
	SDLkey
	>ESC< =? ( exit )
	drop
	;	

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	32 32 "r3\j2022\jetpack\img\jetpack.png" loadts 'sprplayer !
	"r3\j2022\jetpack\mapa.map" loadtilemap 'mapajuego !
	
	"r3\j2022\jetpack\img\inicio.png" loadimg 'sinicio !		
	"r3\j2022\jetpack\img\ganaste.png" loadimg 'sganaste !		
	"r3\j2022\jetpack\img\perdiste.png" loadimg 'sperdiste !		

	"r3\j2022\jetpack\img\btnp1.png" loadimg 'sbtnj1 !		
	"r3\j2022\jetpack\img\btnp2.png" loadimg 'sbtnj2 !		
	"r3\j2022\jetpack\img\btns1.png" loadimg 'sbtns1 !		
	"r3\j2022\jetpack\img\btns2.png" loadimg 'sbtns2 !			
	
	'menu sdlshow
	
	SDLquit ;	
	
: main ;
