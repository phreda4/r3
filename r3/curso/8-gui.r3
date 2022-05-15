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
	0 0 sw sh guiRect
	SDLb SDLx SDLy guiIn
	
	[ xypen xy! ; ] 
	[ ink Color xypen 2dup xo yo Line xy! rand 'ink ! ; ]  
	onDnMove 
	
	redraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

: 
	"r3sdl" 800 600 SDLinit

	0 clrscr
	
	'drawline SDLshow 
	SDLquit
	;

