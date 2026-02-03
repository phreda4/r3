| program 1
| red box

^r3/lib/sdl2gfx.r3

:main
	0 sdlcls
	$ff0000 sdlcolor
	10 10 100 100 sdlfrect
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	drop ;
	
:
	"red box in the corner" 800 600 SDLinit
	'main SDLShow
	SDLquit 
	;
