| r3 sdl program
^r3/win/sdl2gfx.r3
^r3/util/bfont.r3
^r3/lib/rand.r3

#yj1 10 #v1 0 #p1
:j1
	$ff0000 Color 10 yj1 20 80 FRect
	v1 'yj1 +!
	;

#yj2 10 #v2 0 #p2
:j2
	$ff Color 770 yj2 20 80 FRect
	v2 'yj2 +!
	;

#x 400.0 #y 300.0
#vx 3.0 #vy 1.0

:reset 
	400.0 'x ! 300.0 'y ! 
	3.0 randmax 1.0 + 
	%1000 and? ( neg )
	'vx ! 
	0 'vy ! ;

:hitx vx neg 'vx ! ;
:hity vy neg 'vy ! ;
:int 16 >> ;

:hit1 | x -- x
	y int
	yj1 30 + -
	-40 <? ( drop ; )
	40 >? ( drop ; )
	0.1 * 'vy +!
	30.0 'x !	
	hitx
	;
:hit2
	y int
	yj2 30 + -
	-40 <? ( drop ; )
	40 >? ( drop ; )
	0.1 * 'vy +!
	750.0 'x !
	hitx
	;
:pierde1 1 'p2 +! reset ;
:pierde2 1 'p1 +! reset ;

:pelota
	$ffffff Color
	x int y int 20 20 FRect
	vx 'x +!
	vy 'y +!
|	x 0 <? ( hitx ) 780.0 >? ( hitx ) drop
	y 0 <? ( hity ) 580.0 >? ( hity ) drop
	x 
	30.0 <? ( hit1 )
	0 <? ( pierde1 )
	750.0 >? ( hit2 ) 
	780.0 >? ( pierde2 ) 
	drop
	;

:demo
	0 clrscr
	j1 j2 pelota
	
	$ffffff bcolor 
	350 10 bat 
	p2 p1 "%d - %d" sprint bprint
	
	redraw
	
	SDLkey 
	>esc< =? ( exit )
	<q> =? ( -3 'v1 ! ) >q< =? ( 0 'v1 ! )
	<a> =? ( 3 'v1 ! ) >a< =? ( 0 'v1 ! )
	<up> =? ( -3 'v2 ! ) >up< =? ( 0 'v2 ! )
	<dn> =? ( 3 'v2 ! ) >dn< =? ( 0 'v2 ! )
	drop ;

:main
	"r3sdl" 800 600 SDLinit
	bfont2
	'demo SDLshow
	SDLquit ;	
	
: main ;