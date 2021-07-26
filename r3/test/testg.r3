| sdl2 test program
| PHREDA 2021

^r3/win/sdl2.r3	
^r3/lib/sys.r3
^r3/lib/gr.r3
	
:xypen SDLx SDLy ;

:drawl
	xypen line
	SDLkey
	>esc< =? ( exit )
	drop ;
		
:draw
	SDLupdate xypen op
	'drawl onshow ;

:main
	windows
	sdl2
	"r3sdl" 640 480 SDLinit
	draw
	SDLquit
	;

: main ;
