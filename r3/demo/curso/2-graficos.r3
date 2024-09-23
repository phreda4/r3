| programa 2 
| puntos en pantalla

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

:puntos
	$ffffff randmax SDLColor 
	sw randmax 
	sh randmax 
	SDLPoint
			
	SDLredraw 
	SDLkey >esc< =? ( exit ) drop ;

:lineas
	$ffffff randmax SDLColor 
	sw randmax sh randmax 
	sw randmax sh randmax 
	SDLLine
	
	SDLredraw 
	SDLkey >esc< =? ( exit ) drop ;

:cajas
	$ffffff randmax SDLColor 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	SDLRect
	
	SDLredraw 
	SDLkey >esc< =? ( exit ) drop ;

:fillcajas
	$ffffff randmax SDLColor 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	SDLFRect
	
	SDLredraw 
	SDLkey >esc< =? ( exit ) drop ;

:elipse
	$ffffff randmax SDLColor 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	SDLEllipse
	
	SDLredraw 
	SDLkey >esc< =? ( exit ) drop ;


:fillelipse
	$ffffff randmax SDLColor 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	SDLFEllipse
	
	SDLredraw 
	SDLkey >esc< =? ( exit ) drop ;

:filltri
	$ffffff randmax SDLColor 
	sw randmax sh randmax 
	sw randmax sh randmax 
	sw randmax sh randmax 
	SDLTriangle

	SDLredraw 
	SDLkey >esc< =? ( exit ) drop ;
	
:	|====================== INICIO 
	"r3sdl" 800 600 SDLinit

	0 SDLcls
	'puntos SDLShow

	0 SDLcls
	'lineas SDLShow

	0 SDLcls
	'cajas SDLShow
	
	0 SDLcls
	'fillcajas SDLShow
	
	0 SDLcls
	'elipse  SDLShow
	
	0 SDLcls
	'fillelipse SDLShow

	0 SDLcls
	'filltri SDLShow
	
	SDLquit 
	;
