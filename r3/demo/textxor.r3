| sdl2 xor texture
| PHREDA 2021

^r3/win/sdl2.r3	
^r3/lib/sys.r3
	
#textbitmap

#srct [ 0 0 800 600 ]
#mpixel 
#mpitch

:updatexor
	textbitmap 'srct 'mpixel 'mpitch SDL_LockTexture
	
	mpixel >a
	600 ( 1? 1 -
		800 ( 1? 1 -
			2dup xor msec + 8 << da!+
		) drop
	) drop
	
	textbitmap SDL_UnlockTexture
	;
		
:draw
	updatexor
	SDLrenderer textbitmap 0 0 SDL_RenderCopy		
	SDLrenderer SDL_RenderPresent
	
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