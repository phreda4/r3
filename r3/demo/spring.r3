| spring demo
| PHREDA 2022
^r3/lib/math.r3
^r3/win/sdl2gfx.r3
^r3/util/bfont.r3

:part- | dx dy part -- dx dy
	dup c@ 1 nand? ( 2drop ; ) drop | lock
	pick2 neg over 1 + d+!
	over neg swap 9 + d+! ;

:part+ | dx dy part -- dx dy
	dup c@ 1 nand? ( 2drop ; ) drop | lock
	pick2 over 1 + d+!
	over swap 9 + d+! ;

|---spring
| p1 p2 [length stifnedd]
:updspring | 'p1 -- 
	a@+
	over 1 + d@ over 1 + d@ -	| p1 p2 dx
	pick2 9 + d@ pick2 9 + d@ - | p1 p2 dx dy
	over dup *. over dup *. +
	sqrt. dup da@+ - 			| p1 p2 dx dy d2 d2-len
	swap /.						| p1 p2 dx dy d3
	da@+ *.	2/.					| p1 p2 dx dy d3*stiff
	rot over *.			| p1 p2 dy d3 dx*d3
	rot rot *. 			| p1 p2 dx* dy*
	rot part+
	rot part-
	2drop
	;
	
| particula
| (lock) [ x x1 y y1 ]
:updpart | dt*dt*ax y -- ; a part
	ca@+ 1 nand? ( drop ; ) drop | 16 a+
	da@+ da@+			| x x1
	neg over + pick3 +	| x nx
	over +
	-8 a+ da!+ da!+	
	da@+ da@+			| y y1
	neg over + pick2 +	| y ny
	over +
	-8 a+ da!+ da!+	
	;
	
| particles
#p1 ( 0 ) [ 64.0 64.0 10.0 10.0 ]
#p2 ( 1 ) [ 10.0 10.0 15.0 15.0 ]
#p3 ( 1 ) [ 10.0 10.0 60.0 60.0 ]

| spring list
#splist
'p1 'p2 [ 50.0 0.5 ]
'p2 'p3 [ 50.0 0.5 ]
0

| particle list
#plist 
'p1 'p2 'p3 0

:update
	0.0 0.04 	| ax*dt*dt ay*dt*dt
	'plist >b
	( b@+ 1? >a updpart 
		) 3drop
	'splist >a
	( a@+ 1? updspring 
		) drop 
	;

:pxy
	1 + d@+ 16 >> swap 4 + d@ 16 >> ;
	
:drawpoint
	'plist >b
	( b@+ 1? 
		4 dup rot pxy SDLFEllipse
		) drop ;
		
:drawsprints
	'splist >a
	( a@+ 1? 
		pxy a@+ pxy SDLLine
		8 a+
		) drop 	;
		
:draw
	$0 SDLCls

	$ffe451 SDLcolor
	drawsprints
	$00aefa SDLcolor
	drawpoint
	
|	2 dup SDLX sdly SDLFEllipse

	update
	
	SDLkey
	>esc< =? ( exit )
	drop
	
	SDLredraw ;
	
: 
	"r3sdl" 800 600 SDLinit
	bfont1 
	'draw SDLshow
	SDLquit ;	
	
