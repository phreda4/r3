| Conway Game of Life Graphics
| PHREDA 2021

^r3/win/sdl2.r3	
^r3/lib/sys.r3
^r3/lib/mem.r3
^r3/lib/rand.r3
	
#textbitmap
#mpixel 
#mpitch

#arena 
#arenan

:check | adr -- adr 
	dup 513 - >a	ca@+ ca@+ + ca@ + 
	512 a+			ca@ + -2 a+ ca@ +
	512 a+  		ca@+ + ca@+ + ca@ +
	3 =? ( drop 1 cb!+ ; )
	2 <>? ( drop 0 cb!+ ; ) 
	drop
	dup c@ cb!+ ;
	
:evolve
	arenan >b
	arena
	0 ( 512 <? 
		0 ( 512 <? 
			rot check 1 + rot rot 
			1 + ) drop
		1 + ) 2drop 
	arena arenan 512 512 * move ;
	
		
:drawarena
	textbitmap 0 'mpixel 'mpitch SDL_LockTexture
	
	mpixel >a
	arena >b
	512 ( 1? 1 -
		512 ( 1? 1 -
			cb@+ 1? ( $ffffff or ) da!+
		) drop
	) drop
	
	textbitmap SDL_UnlockTexture ;
		
:draw
	evolve
	drawarena
	SDLrenderer textbitmap 0 0 SDL_RenderCopy		
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

:arenarand
	rerand
	arena >a
	0 ( 512 <? 
		0 ( 512 <? 
			rand 29 >> 1 and ca!+
			1 + ) drop
		1 + ) drop ;
		
:main
	here 
	dup 'arena !			| start of arena
	512 512 * + 'arenan !	| copy of arena
	arenarand	
	
	"r3sdl" 512 512 SDLinit
	512 512 SDLframebuffer 'textbitmap !
	| SDLfull | fullscreen
	'draw SDLshow 
	SDLquit	;

: main ;
