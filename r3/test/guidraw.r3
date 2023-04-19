| sdl2 dibujo

^r3/win/sdl2gfx.r3	
^r3/lib/gui.r3	
^r3/lib/rand.r3	

#xo #yo	
#ink $ff00

:xy!
	'yo ! 'xo ! ;
	
:xypen | -- x y
	SDLx SDLy ;

:drawline
	gui		
	SDLx SDLy guiIn
	
	[ xypen xy! ; ] 
	[ ink SDLColor xypen 2dup xo yo SDLLine xy! rand 'ink ! ; ]  
	onDnMove 
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

: 
	"r3sdl" 800 600 SDLinit

	0 SDLcls
	
	'drawline SDLshow 
	SDLquit
	;

