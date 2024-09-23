| spring demo
| PHREDA 2022
^r3/lib/math.r3
^r3/lib/sdl2gfx.r3
^r3/util/bfont.r3

|--------- main words
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
	sqrt. 
	dup da@+ - 			| p1 p2 dx dy d2 d2-len
	
|	swap 0? ( 1 + )
|	/.						| p1 p2 dx dy d3
|	da@+ *.	2/.				| p1 p2 dx dy d3*stiff

	da@+ 2/. rot 1 or */ | 1 or = never 0/

	rot over *.			| p1 p2 dy d3 dx*d3
	-rot *. 			| p1 p2 dx* dy*
	rot part+
	rot part-
	2drop
	;
	
| particula
| (lock) [ x x1 y y1 ]
:updpart | dt*dt*ax y -- ; a part
	ca@+ 1 nand? ( drop 16 a+ ; ) drop | 16 a+
	da@+ da@+			| x x1
	neg over + pick3 +	| x nx
	over +
	-8 a+ da!+ da!+	
	da@+ da@+			| y y1
	neg over + pick2 +	| y ny
	over +
	-8 a+ da!+ da!+	
	;

:upd-spring | 'slist ax*dt*dt ay*dt*dt 'plist --
	>b 
	( b@+ 1? >a updpart 
		) 3drop
	>a
	( a@+ 1? updspring 
		) drop ;

:pxy! | x y 'p --
	rot over 1 + d! 9 + d! ;
	
:pxy | 'p -- x y
	1 + d@+ 16 >> swap 4 + d@ 16 >> ;

:drawpoint | 'plist --
	>b
	( b@+ 1? 
		4 dup rot pxy SDLFEllipse
		) drop ;
		
:drawsprints
	>a
	( a@+ 1? 
		pxy a@+ pxy SDLLine
		8 a+
		) drop 	;

|-------------- demo pendulum	
| particles
#p1 ( 0 ) [ 400.0 400.0 100.0 100.0 ]
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

:key&mouse
	SDLkey
	>esc< =? ( exit )
	drop
	sdlb 0? ( drop ; ) drop
	sdlx 16 << sdly 16 << 'p3 pxy!
	;
	
:pendulum
	$0 SDLCls

	10 10 bat "pendulum demo" bprint
	$ffe451 SDLcolor
	'splist drawsprints
	$00aefa SDLcolor
	'plist drawpoint
	
	'splist 0.0 0.04 'plist upd-spring
	key&mouse
	SDLredraw ;

|-------------- demo cloth
#points 
#springs
#listp

:newpoint | x y --
	1 ca!+ swap dup da!+ da!+ dup da!+ da!+ ;
:getpointxy | x y -- p
	10 * + 17 * points + ;
	
:inicloth
	here dup 'points ! >a
	0 ( 10 <?
		0 ( 10 <?
			over 30 * 150 + 16 <<
			over 30 * 150 + 16 <<
			newpoint
			1 + ) drop
		1 + ) drop
	0 0 getpointxy 0 swap c!
	0 9 getpointxy 0 swap c!
		
	a> 'listp !
	here >b
	0 ( 10 <?
		0 ( 10 <?
			b> a!+ 17 b+
			1 + ) drop
		1 + ) drop
	0 a!+
	a> 'springs !
	0 ( 9 <?
		0 ( 9 <?
			over over getpointxy a!+
			over 1 + over getpointxy a!+
			30.0 da!+ 0.5 da!+
			over over getpointxy a!+
			over over 1 + getpointxy a!+
			30.0 da!+ 0.5 da!+
			1 + ) drop
		dup 9 getpointxy a!+
		dup 1 + 9 getpointxy a!+
		30.0 da!+ 0.5 da!+
		1 + ) drop
	0 ( 9 <? 
		9 over getpointxy a!+
		9 over 1 + getpointxy a!+
		30.0 da!+ 0.5 da!+
		1 + ) drop 
	0 a!+
	;
	
:key&mouse
	SDLkey
	>esc< =? ( exit )
	drop

	sdlb 0? ( drop ; ) drop
	sdlx 16 << sdly 16 << 
	9 9 getpointxy pxy!
	;
	
:cloth
	$0 SDLCls

	10 10 bat "cloth demo" bprint
	$ffe451 SDLcolor
	springs drawsprints
	
	springs |0.0 0.04 
	msec 4 << sin 7 >> 0.04 
	listp upd-spring
	
	key&mouse
	SDLredraw ;

|-------------- softboy
:lim-point | 'plist --
	>b
	( b@+ 1? 
		dup 1 + | x 
		dup d@ sw 1 - 16 << clamp0max swap d!
		9 +		| y
		dup d@ sh 1 - 16 << clamp0max swap d!
		) drop ;

:getpointn | n -- a
	17 * points + ;
	
:ppdist | p1 p2 -- dist
	over 1 + d@ over 1 + d@ - dup *.
	rot 9 + d@ rot 9 + d@ - dup *. +
	sqrt.
	;
	
:inisoftbody
	here dup 'points ! >a
	0 ( 5 <?
		dup 1.0 5 */ sincos
		100.0 *. 400.0 + swap 
		100.0 *. 300.0 +
		newpoint
		1 + ) drop
		
	a> 'listp !
	here >b
	0 ( 5 <?
		b> a!+ 17 b+
		1 + ) drop
	0 a!+
	
	a> 'springs !
	0 ( 5 <?
		dup ( 5 <? 
			over getpointn a!+
			dup getpointn a!+
			over getpointn over getpointn ppdist 
			da!+ 0.5 da!+
			1 + ) drop
		1 + ) drop
	0 a!+
	;
	
:key&mouse
	SDLkey
	>esc< =? ( exit )
	drop
	
	sdlb 0? ( drop ; ) drop
	sdlx 16 << sdly 16 << points pxy!	
	;
		
:softbody
	$0 SDLCls

	10 10 bat "soft body" bprint
	$ffe451 SDLcolor
	springs drawsprints
	
	springs 0.0 0.04 listp upd-spring

	listp lim-point
	key&mouse
	SDLredraw ;
	
|-----------------------------------------	
: 
	"r3sdl" 800 600 SDLinit
	bfont1 
	'pendulum SDLshow
	
	inicloth
	'cloth SDLshow

	inisoftbody
	'softbody SDLshow
	
	SDLquit ;	
	
