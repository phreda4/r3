| sdl2 dibujo

^r3/win/sdl2gfx.r3	

#xo #yo	

:xy!
	'yo ! 'xo ! ;
	
:xypen | -- x y
	SDLx SDLy ;

:drawline
	xo yo xypen	
	2dup xy!
	SDLLine
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

: 
	"r3sdl" 800 600 SDLinit
	
	SDLupdate 
	xypen xy!
	
	$ff00 SDLColor
	
	'drawline SDLshow 
	SDLquit
	;

