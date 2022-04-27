| sdl2 dibujo

^r3/win/sdl2gfx.r3	
^r3/lib/gui.r3	
^r3/lib/rand.r3	

#xo #yo	
#color $ff00

:xy!
	'yo ! 'xo ! ;
	
:xypen | -- x y
	SDLx SDLy ;

:drawline
	gui		
	0 0 sw sh guiRect
	SDLb SDLx SDLy guiIn
	
	[ xypen xy! ; ] 
	[ color SDLcolor xypen 2dup xo yo SDLLine xy! ; ]  
	onDnMove 
	
	SDLredraw
	
	SDLkey
	<esp> =? ( rand 'color ! )
	>esc< =? ( exit )
	drop ;

: 
	"r3sdl" 800 600 SDLinit

	$ff00 SDLcolor
	0 SDLClear
	
	'drawline SDLshow 
	SDLquit
	;

