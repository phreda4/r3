| programa 2 
| puntos en pantalla

^r3/win/sdl2.r3
^r3/lib/rand.r3

:puntos
	$ffffff randmax SDLcolor 
	sw randmax 
	sh randmax 
	SDLPoint
			
	SDLRedraw 
	SDLkey >esc< =? ( exit ) drop ;

:lineas
	$ffffff randmax SDLcolor 
	sw randmax sh randmax 
	sw randmax sh randmax 
	SDLLine
	
	SDLRedraw 
	SDLkey >esc< =? ( exit ) drop ;

:cajas
	$ffffff randmax SDLcolor 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	SDLRect
	
	SDLRedraw 
	SDLkey >esc< =? ( exit ) drop ;

:fillcajas
	$ffffff randmax SDLcolor 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	SDLFillRect
	
	SDLRedraw 
	SDLkey >esc< =? ( exit ) drop ;

:elipse
	$ffffff randmax SDLcolor 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	SDLellipse
	
	SDLRedraw 
	SDLkey >esc< =? ( exit ) drop ;


:fillelipse
	$ffffff randmax SDLcolor 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	SDLFillEllipse
	
	SDLRedraw 
	SDLkey >esc< =? ( exit ) drop ;

:filltri
	$ffffff randmax SDLcolor 
	sw randmax sh randmax 
	sw randmax sh randmax 
	sw randmax sh randmax 
	SDLtriangle

	SDLRedraw 
	SDLkey >esc< =? ( exit ) drop ;
	
:	|====================== INICIO 
	"r3sdl" 800 600 SDLinit

	0 SDLclear
	'puntos SDLShow

	0 SDLclear
	'lineas SDLShow

	0 SDLclear
	'cajas SDLShow
	
	0 SDLclear
	'fillcajas SDLShow
	
	0 SDLclear
	'elipse  SDLShow
	
	0 SDLclear
	'fillelipse SDLShow

	0 SDLclear
	'filltri SDLShow
	
	SDLquit 
	;
