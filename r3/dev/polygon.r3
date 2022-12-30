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
	- nip 63 >> ;
	
:isPointInTri | pt v1 v2 v3 -- 0/1
	pick3 pick3 pick3 tsign >r 
	pick3 rot pick2 tsign >r 
	swap tsign r> r> | s1 s2 s3
	<>? ( 2drop 0 ; ) <>? ( drop 0 ; ) drop
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
	1 + 
:vv
	nv >=? ( 0 nip ) ;

:i!+ | i --
	'i ni + c! 1 'ni +! ;
	
:v- | n --
	'v over + dup 1 + rot nv swap - cmove |  delete vertex
	-1 'nv +!
	;
	
#pu #pv #pw	

:close? | -- sign
	pu ]vp
	pv ]vp
	pw ]vp
	over >Y pick3 >Y -
	over >X pick4 >X - * >r
	over >X pick3 >X -
	over >Y pick4 >Y - * r> -
	nip nip nip ;

:inside? | n -- n/0
	pu ]v =? ( 8 a+ "u" .print ; )
	pv ]v =? ( 8 a+ "v" .print ; )
	pw ]v =? ( 8 a+ "w" .print ; )
	a@+ dup >y over >x "(%d:%d) " .print
	pu ]vp pv ]vp pw ]vp isPointInTri
	1? ( 2drop -1 ; ) drop
	;
	
:emptyTri | -- -/1= without point inside
	close? dup "=%d " .print
	+? ( -1 nip ; ) drop
	'p >a
	0 ( cntp <?  
		dup " %d" .print
		inside? -? ( ; )
		1 + ) 
	" ok " .print
	;
	
:insTri
	pu ]v i!+
	pv ]v i!+ 
	pw ]v i!+
	pv v- 
	;

:pdebug	
	pw pv pu "u:%d v:%d w:%d" .println
	0 ( nv <? 
		dup 'v + c@ "%d " .print
		1 + ) drop cr
	0 ( ni <? 
		dup 'i + c@ "%d " .print
		1 + ) drop cr ;
		
#loop		
:triangulate
	"----" .println
	makelist
	0 'pv !
	cntp dup 'nv !
	1 << 'loop !
	2 ( nv <?
		pdebug	
		pv vv dup 'pu ! 1+nv dup 'pv ! 1+nv 'pw !
		emptyTri +? ( 
			insTri 
			nv 1 << 'loop !
			) drop
		loop 1 - 0? ( 2drop ; ) 'loop !
		) drop ;

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
	guibox 
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
#index * 1024 | index in dword


| test point
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
		
| draw poly		
:drawpoly		
	'points point> =? ( drop ; ) drop
	SDLrenderer 0 'points cntp 'index ni SDL_RenderGeometry
	;

| build point and index for randergeometry
:buildpoly
	triangulate
	'points >a
	'p ( np <?
		@+ dup >x i2fp da!+
		>y i2fp da!+
		rand da!+
		0 da!+
		0 da!+
		) drop
	a> 'point> !
	'index >a
	'i ni ( 1? 1 - swap
		c@+ da!+
		swap ) 2drop
	;
	
| debug
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

	drawpoly
|	drawpoints

	drawl
	drawp

	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( repoly )
	<f2> =? ( buildpoly )
|	<f2> =? ( addpoint ) 

	drop ;

:
	"r3sdl" 800 600 SDLinit
	bfont1
	
	repoly
	'main SDLshow 
	SDLquit
	;
