^r3/lib/math.r3
^r3/win/sdl2gfx.r3
^r3/util/bfont.r3

:part- | dx dy part -- dx dy
	dup c@ 1 nand? ( 2drop ; ) drop | lock
	pick2 neg over 1 + d+!
	over neg swap 5 + d+! ;

:part+ | dx dy part -- dx dy
	dup c@ 1 nand? ( 2drop ; ) drop | lock
	pick2 over 1 + d+!
	over swap 5 + d+! ;

|---spring
| p1 p2 [length stifnedd]
:updspring | 'p1 -- 
	a@+
	over 1 + d@ over 1 + d@ -	| p1 p2 dx
	pick2 5 + d@ pick2 5 + d@ - | p1 p2 dx dy
	over dup *. over dup *. +
	sqrt. dup da@+ - 			| p1 p2 dx dy d2 d2-len
	swap /.						| p1 p2 dx dy d3
	da@+ *.						| p1 p2 dx dy d3*stiff
	rot over *.	2/.		| p1 p2 dy d3 dx*d3
	rot rot *. 2/.		| p1 p2 dx* dy*
	swap
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

| spring list
#splist
'p1 'p2 [ 50.0 0.5 ]
0

| particle list
#plist 
'p1 'p2 0

:update
	0.0 0.001 	| ax*dt*dt ay*dt*dt
	'plist >b
	( b@+ 1? >a updpart 
		) 3drop
	'splist >a
	( a@+ 1? updspring 
		) drop 
	;

:pxy
	1 + d@+ 16 >> swap 4 + d@ 16 >> ;
	
:draw
	$0 SDLCls

	$ffe451 SDLcolor
	'p1 pxy 'p2 pxy SDLLine
	$ff0040 SDLcolor
	4 dup 'p1 pxy SDLFEllipse
	$00aefa SDLcolor
	4 dup 'p2 pxy SDLFEllipse
	$fff0e8 SDLcolor
	2 dup SDLX sdly SDLFEllipse

	update
	
	0 200 bat
	'p2 pxy swap "%d %d " sprint bprint
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( 	'splist >a a@+ updspring )
	drop
	
	SDLredraw ;
	
: 
	"r3sdl" 800 600 SDLinit
	bfont1 
	'draw SDLshow
	SDLquit ;	
	
