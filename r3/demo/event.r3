| event horizont
| PHREDA 2025

^r3/lib/sdl2gfx.r3	
	
#textbitmap #mpixel #mpitch
#x #y #w #h #cx #cy

:event
	textbitmap 0 'mpixel 'mpitch SDL_LockTexture
	sw fix. 'w !
	sh fix. 'h !
	mpixel >a
	sh ( 1? 1-
		dup fix. 'y !
		y 2* h - h /. 'cy !
		sw ( 1? 1-
			dup	fix. 'x !
			x 2* w - h /. 'cx !
			cx dup *. cy dup *. + sqrt.
			
			0.5 - 0.01 h *. y x - 2* h + w - 0? ( 1+ ) 
			/. +
			
			abs 0? ( 1+ )
			0.1 swap /. 255 over rot 1.0 + */
			
			dup dup 8 << or 8 << or 
			da!+
		) drop
	) drop
	textbitmap SDL_UnlockTexture
	;
		
:draw
	SDLrenderer textbitmap 0 0 SDL_RenderCopy		
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"r3sdl" 600 600 SDLinit
	600 600 SDLframebuffer 'textbitmap !
	event
	'draw SDLshow 
	SDLquit	;

: main ;
