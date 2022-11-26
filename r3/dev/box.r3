^r3/win/sdl2.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	
^r3/lib/rand.r3	
^r3/lib/gui.r3	

#listb * 1024
#listb> 'listb

|------------------------------------------
::xywh64 | x y w h -- 64b
	$ffff and swap
	$ffff and 16 << or swap
	$ffff and 32 << or swap
	$ffff and 48 << or ;
	
::64box | b -- x y w h 
	dup 48 >> swap 
	dup 16 << 48 >> swap	
	dup 32 << 48 >> swap
	48 << 48 >> ;

:2sort | x x -- min max
	over <? ( swap ) ;
	
:box2rec | x y x y -- x y w h
	rot 2sort 2swap 2sort | ym M xm M
	over - 2swap over - | xm W ym H
	rot swap ;
	
:rec2box | x y w h - x y x y
	swap pick3 + swap pick2 + ;

:drawlistb
	$ffffff SDLColor
	'listb ( listb> <?
		@+ 64box SDLRect
		) drop ;
		
|------------------------------------------
#x1 #y1 
	
:cursor
	SDLb SDLx SDLy guiIn	
	[ SDLx 'x1 ! SDLy 'y1 ! ; ]
	[ $ff00 SDLColor x1 y1 SDLx SDLy box2rec SDLRect ; ]
	[ x1 y1 SDLx SDLy box2rec xywh64 listb> !+ 'listb> ! ; ]
	guiMap
	;
	
:main
	gui
	$0 SDLcls

	cursor
	drawlistb
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

:
	"r3sdl" 800 600 SDLinit
	'main SDLshow 
	SDLquit
	;
