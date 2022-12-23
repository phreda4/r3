^r3/win/sdl2.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	
^r3/lib/rand.r3	
^r3/lib/gui.r3	

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

:tsign | v1 v2 v3 -- -1/0
	pick2 >X over >X - pick2 >Y pick2 >Y - *
	rot >X pick2 >X - rot >Y pick3 >Y swap - * 
	- 63 >> nip ;
	
:isPointInTri | pt v1 v2 v3 -- 0/1
	pick3 pick3 pick3 tsign >r
	pick3 rot pick2 tsign r> 	| pt v1 v3
	<>? ( 4drop 0 ; ) >r
	swap tsign r>	
	<>? ( drop 0 ; )
	drop 1 ;

:makelist
	'v >a
	cntp dup 'nv !
	( 1? 1 -
		dup ca!+ ) drop 
	0 'ni ! ;
	
:]v 'v + c@ ;
	
:1+nv
	1 + nv >=? ( 0 nip ) ;

:i!+ | i --
	'i ni + c! 1 'ni +! ;
	
:v- | n --
	'v over + dup 1 + rot nv swap - cmove | 
	-1 'nv !
	;
	
#pu #pv #pw	

:inside? | n -- n/0
	pu =? ( 1 a+ ; )
	pv =? ( 1 a+ ; )
	pw =? ( 1 a+ ; )
	a@+ pu ]v pv ]v pw ]v isPointInTri
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
	2 ( nv >?
		pv dup 'pu ! 1+nv dup 'pv ! 1+nv 'pw !
		emptyTri 1? ( insTri ) drop
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
	dup >X 8 - swap >Y 8 - | x w
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
		
|------------------------------------------		
:main
	gui
	$0 SDLcls

	drawl
	drawp
	drawpoints
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( repoly )
	<f2> =? ( addpoint ) 
	drop ;

:
	"r3sdl" 800 600 SDLinit
	repoly
	'main SDLshow 
	SDLquit
	;
