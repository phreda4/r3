^r3/win/sdl2.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	
^r3/lib/rand.r3	
^r3/lib/gui.r3	

#p * 1024
#np 'p
|------------------------------------------


|------------------------------------------
:randxy
	600 randmax 100 +
	400 randmax 100 + ;

:repoly
	'p 'np ! 
	6 ( 1? 1 -
		randxy 32 << or np !+ 'np ! 
		) drop 
	
	;

#xa #ya 	
	
:setxy | adr dx dy
	pick2 8 - @ 
	rot over 32 << 32 >> +
	rot rot 32 >> + 32 << or
	over 8 - !
	SDLx 'xa ! SDLy 'ya ! 
	;
	

:dpoint | 'l xy -- 'l
	dup 32 << 32 >> 8 - swap 32 >> 8 - | x w
	16 16 | w h 
	2over 2over SDLRect 	
	guibox SDLb SDLx SDLy guiIn	
	[ SDLx 'xa ! SDLy 'ya ! ; ]
	[ SDLx xa - SDLy ya - setxy ; ]
	onDnMoveA
	;
	
:drawp
	$ff SDLColor
	'p ( np <? 
		@+ dpoint
		) drop ;

:drawl
	$ff0000 SDLColor
	'p >a a@+ 
	dup 32 << 32 >> swap 32 >> | x y
	2dup
	( a> np <? drop
		a@+ dup 32 << 32 >> swap 32 >> | x y 
		2swap 2over SDLLine
		) drop 
	SDLLine ;

|------------------------------------------		
:main
	gui
	$0 SDLcls

	drawl
	drawp
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( repoly )
	drop ;

:
	"r3sdl" 800 600 SDLinit
	repoly
	'main SDLshow 
	SDLquit
	;
