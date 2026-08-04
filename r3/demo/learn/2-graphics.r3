| program 2 
| more graphics

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

:waitkey
	SDLkey >esc< =? ( exit ) drop ;
	
:puntos
	$ffffff randmax color 
	sw randmax 
	sh randmax 
	point
			
	SDLredraw 
	waitkey ;

:lineas
	$ffffff randmax color 
	sw randmax sh randmax 
	sw randmax sh randmax 
	line
	
	SDLredraw 
	waitkey ;

:cajas
	$ffffff randmax color 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	rect
	
	SDLredraw 
	waitkey ;

:fillcajas
	$ffffff randmax color 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	frect
	
	SDLredraw 
	waitkey ;

:elipse
	$ffffff randmax color 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	ellipse
	
	SDLredraw 
	waitkey ;

:fillelipse
	$ffffff randmax color 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	fellipse
	
	SDLredraw 
	waitkey ;

:filltri
	$ffffff randmax color 
	sw randmax sh randmax 
	sw randmax sh randmax 
	sw randmax sh randmax 
	triangle

	SDLredraw 
	waitkey ;
	
:	
	"r3 graphics" 800 600 SDLinit

	0 cls
	'puntos SDLShow

	0 cls
	'lineas SDLShow

	0 cls
	'cajas SDLShow
	
	0 cls
	'fillcajas SDLShow
	
	0 cls
	'elipse  SDLShow
	
	0 cls
	'fillelipse SDLShow

	0 cls
	'filltri SDLShow
	
	SDLquit 
	;
