| program 2 
| more graphics

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

:waitkey
	SDLkey >esc< =? ( exit ) drop ;
	
:puntos
	$ffffff randmax SDLColor 
	sw randmax 
	sh randmax 
	SDLPoint
			
	SDLredraw 
	waitkey ;

:lineas
	$ffffff randmax SDLColor 
	sw randmax sh randmax 
	sw randmax sh randmax 
	SDLLine
	
	SDLredraw 
	waitkey ;

:cajas
	$ffffff randmax SDLColor 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	SDLRect
	
	SDLredraw 
	waitkey ;

:fillcajas
	$ffffff randmax SDLColor 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	SDLFRect
	
	SDLredraw 
	waitkey ;

:elipse
	$ffffff randmax SDLColor 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	SDLEllipse
	
	SDLredraw 
	waitkey ;

:fillelipse
	$ffffff randmax SDLColor 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	SDLFEllipse
	
	SDLredraw 
	waitkey ;

:filltri
	$ffffff randmax SDLColor 
	sw randmax sh randmax 
	sw randmax sh randmax 
	sw randmax sh randmax 
	SDLTriangle

	SDLredraw 
	waitkey ;
	
:	
	"r3 graphics" 800 600 SDLinit

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
