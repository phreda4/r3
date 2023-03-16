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
	dup 48 >> swap 			|x1
	dup 16 << 48 >> swap	|y1
	dup 32 << 48 >> swap	|x2
	48 << 48 >> ;			|y2

::64boxr | b -- x y w h 
	dup 48 >> swap 
	dup 16 << 48 >> swap	
	dup 32 << 48 >> pick3 - swap
	48 << 48 >> pick2 - ;
	
:2sort | x x -- min max
	over <? ( swap ) ;
	
:box2rec | x y x y -- x y w h
	rot 2sort 2swap 2sort | ym M xm M
	over - 2swap over - | xm W ym H
	rot swap ;

:rec2box | x y w h - x y x y
	swap pick3 + swap pick2 + ;

:.x1 48 >> ; 			
:.y1 16 << 48 >> ;
:.x2 32 << 48 >> ;
:.y2 48 << 48 >> ;
		
:overlaps | b1 b2 -- overlap?
	over .x2 over .x1 <? ( 3drop 0 ; ) drop 
	over .x1 over .x2 >? ( 3drop 0 ; ) drop 
	over .y2 over .y1 <? ( 3drop 0 ; ) drop
	swap .y1 swap .y2 >? ( drop 0 ; ) drop 
	-1 ;
|    return self.x2>=box.x1 and self.x1<=box.x2 and self.y2>=box.y1 and self.y1<=box.y2
	;

:contains | b1 b2 -- contain?
	over .x1 over .x1 <? ( 3drop 0 ; ) drop
	over .y1 over .y1 <? ( 3drop 0 ; ) drop
	over .x2 over .x2 >? ( 3drop 0 ; ) drop
	swap .y2 swap .y2 >? ( drop 0 ; ) drop
	-1 ;
|		  return box.x1>=self.x1 and box.y1>=self.y1 and box.x2<=self.x2 and box.y2<=self.y2
		   
:expand | b1 b2 -- b3
	over .x1 over .x1 min 48 << >a
	over .y1 over .y1 min $ffff and 32 << a+
	over .x2 over .x2 max $ffff and 16 << a+
	.y2 swap .y2 max $ffff and >a or ;
	
|------------------------------------------
#box1

#x1 #y1 

:drawlistb
	$ff0000 SDLColor
	box1 64boxr SDLRect
	'listb ( listb> <?
		$ffffff SDLColor
		@+ 
		dup box1 overlaps 1? ( $ff SDLColor ) drop		
		dup box1 contains 1? ( $ff00 SDLColor ) drop
		64boxr SDLRect
		) drop ;
	
:insertbox
	SDLx SDLy guiIn	
	[ SDLx 'x1 ! SDLy 'y1 ! ; ]
	[ $ff00 SDLColor x1 y1 SDLx SDLy box2rec SDLRect ; ]
	[ x1 y1 SDLx SDLy box2rec rec2box xywh64 listb> !+ 'listb> ! ; ]
	guiMap
	;
	
:main
	gui
	$0 SDLcls

	insertbox
	drawlistb
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

:
	"r3sdl" 800 600 SDLinit
	400 400 100 50 box2rec rec2box xywh64 'box1 !
	'main SDLshow 
	SDLquit
	;
