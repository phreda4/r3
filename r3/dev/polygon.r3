^r3/win/sdl2.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	
^r3/lib/rand.r3	
^r3/lib/gui.r3	
^r3/util/bfont.r3

|------------------------------------------
| polygon points 
#cntp
#p * 1024
#np 'p
#v * 128
#nv
#i * 128
#ni


| pack xy in a 64 bits number
:>Y 32 >> ;
:>X 32 << 32 >> ;

:parea | v1 v2 -- area
	over >X over >Y * rot >Y rot >X * - ;
	
:tarea | -- area
	0 >a
	'p 
	cntp 1 - 3 << over + @ | v0 vu
	swap
	( np <? | vu 'v0
		@+  | vu 'v1 v0
		rot over | 'v1 v0 vu v0
		parea a+
		swap ) 2drop
	a> ;
	

:tsign | v1 v2 v3 -- -1/0
	pick2 >X over >X - pick2 >Y pick2 >Y - *
	rot >X pick2 >X - rot >Y pick3 >Y swap - * 
	- nip ;
	
:isPointInTri | pt v1 v2 v3 -- 0/1
	pick3 pick3 pick3 tsign -? ( nip 4drop 0 ; ) drop
	pick3 rot pick2 tsign	-? ( 4drop 0 ; ) drop
	swap tsign				-? ( drop 0 ; ) drop
	1 ;

:invlist
	'v >a 0 ( nv <? dup ca!+ 1 + ) drop ;

:makelist
	0 'ni ! 
	cntp 'nv !
	tarea -? ( drop invlist ; ) drop
	'v >a nv ( 1? 1 - dup ca!+ ) drop ;
	
:]v 'v + c@ ;

:]vp 'v + c@ 3 << 'p + @ ;
	
:1+nv
	1 + nv >=? ( 0 nip ) ;

:i!+ | i --
	'i ni + c! 1 'ni +! ;
	
:v- | n --
	'v over + dup 1 + rot nv swap - cmove | 
|	drop
	-1 'nv +!
	;
	
#pu #pv #pw	

:inside? | n -- n/0
	pu =? ( 1 a+ ; )
	pv =? ( 1 a+ ; )
	pw =? ( 1 a+ ; )
	a@+ pu ]vp pv ]vp pw ]vp isPointInTri
	1? ( 2drop 0 ; ) drop
	;
	
:emptyTri | -- 0/1= without point inside
	'v >a
	nv ( 1?  
		inside? 0? ( ; )
		1 - ) 
	1 or ;
	
:insTri
	pu ]v i!+
	pv ]v i!+ 
	pw ]v i!+
	pv v- 
	;
	
:triangulate
	makelist
	0 'pv !
	cntp 'nv !
	2 ( nv <?
		pv dup 'pu ! 1+nv dup 'pv ! 1+nv 'pw !
|		pv pu pw "%d %d %d" .println
		emptyTri 1? ( insTri ) drop
|		dup "%d" .println
		) drop
	;

|------------------------------------------
:randxy
	600 randmax 100 +
	400 randmax 100 + ;

:repoly
	'p 'np ! 
	6 ( 1? 1 -
		randxy 32 << or np !+ 'np ! 
		) drop 
	6 'cntp ! ;

#xa #ya 	
	
:setxy | adr dx dy
	pick2 8 - @ 
	rot over >X +
	rot rot >Y + 32 << or
	over 8 - !
	SDLx 'xa ! SDLy 'ya ! 
	;
	

:dpoint | 'l xy -- 'l
	dup >X 8 - swap >Y 8 - | x y
	
	over 18 + over bat 
	pick2 'p - 3 >> 1 - "%d" sprint bprint
	
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
	dup >X swap >Y | x y
	2dup
	( a> np <? drop
		a@+ dup 32 << 32 >> swap 32 >> | x y 
		2swap 2over SDLLine
		) drop 
	SDLLine ;

|------------------------------------------		
| points alone
#points * 1024
#point> 'points

:addpoint
	SDLx SDLy 
	32 << swap $ffffffff and or 
	point> !+ 'point> !
	;
	
:pointcolor | p -- p
	'p >a
	dup a@+ a@+ a@+ isPointInTri  
	1? ( drop $ff0000 SDLColor ; ) drop
	$ff00 SDLColor ;
		
:drawpoints
	'points ( point> <? 
		@+ 
		pointcolor
		dup >X 4 - swap >Y 4 - 8 8 SDLRect
		) drop ;

:pdebug
	1 1 bat
	$ffffff bcolor
	'p ( np <? 
		@+ dup >y swap >x "(%d:%d) " sprint bprint		
		) drop
	1 14 bat
	0 ( nv <? 
		dup 'v + c@ "%d " sprint bprint
		1 + ) drop 
	1 28 bat
	0 ( ni <? 
		dup 'i + c@ "%d " sprint bprint
		1 + ) drop 
	;
	
|------------------------------------------		
:main
	gui
	$0 SDLcls
	pdebug

	drawl
	drawp
	drawpoints
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( repoly )
	<f2> =? ( addpoint ) 
	<f3> =? ( triangulate )
	drop ;

:
	"r3sdl" 800 600 SDLinit
	bfont1
	
	repoly
	'main SDLshow 
	SDLquit
	;