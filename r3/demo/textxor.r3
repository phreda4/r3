| sdl2 xor texture
| PHREDA 2021

^r3/lib/sdl2gfx.r3	
	
#textbitmap

#mpixel 
#mpitch

:updatexor
	textbitmap 0 'mpixel 'mpitch SDL_LockTexture
	
	mpixel >a
	600 ( 1? 1 -
		800 ( 1? 1 -
			2dup xor msec 3 >> + $ff and da!+
		) drop
	) drop
	
	textbitmap SDL_UnlockTexture
	;
		
:draw
	updatexor
	SDLrenderer textbitmap 0 0 SDL_RenderCopy		
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"r3sdl" 800 600 SDLinit
	800 600 SDLframebuffer 'textbitmap !
	| SDLfull | fullscreen
	'draw SDLshow 
	SDLquit	;

: main ;
