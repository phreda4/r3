| programa 2 
| puntos en pantalla

^r3/win/sdl2gfx.r3
^r3/lib/rand.r3

:puntos
	$ffffff randmax Color 
	sw randmax 
	sh randmax 
	Point
			
	redraw 
	SDLkey >esc< =? ( exit ) drop ;

:lineas
	$ffffff randmax Color 
	sw randmax sh randmax 
	sw randmax sh randmax 
	Line
	
	redraw 
	SDLkey >esc< =? ( exit ) drop ;

:cajas
	$ffffff randmax Color 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	Rect
	
	redraw 
	SDLkey >esc< =? ( exit ) drop ;

:fillcajas
	$ffffff randmax Color 
	sw randmax sh randmax 
	sw over - randmax sh over - randmax 
	FRect
	
	redraw 
	SDLkey >esc< =? ( exit ) drop ;

:elipse
	$ffffff randmax Color 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	Ellipse
	
	redraw 
	SDLkey >esc< =? ( exit ) drop ;


:fillelipse
	$ffffff randmax Color 
	sw 3 >> randmax sh 3 >> randmax 
	sw randmax sh randmax 
	FEllipse
	
	redraw 
	SDLkey >esc< =? ( exit ) drop ;

:filltri
	$ffffff randmax Color 
	sw randmax sh randmax 
	sw randmax sh randmax 
	sw randmax sh randmax 
	Triangle

	redraw 
	SDLkey >esc< =? ( exit ) drop ;
	
:	|====================== INICIO 
	"r3sdl" 800 600 SDLinit

	0 clrscr
	'puntos SDLShow

	0 clrscr
	'lineas SDLShow

	0 clrscr
	'cajas SDLShow
	
	0 clrscr
	'fillcajas SDLShow
	
	0 clrscr
	'elipse  SDLShow
	
	0 clrscr
	'fillelipse SDLShow

	0 clrscr
	'filltri SDLShow
	
	SDLquit 
	;
