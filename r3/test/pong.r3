| r3 sdl program
^r3/win/sdl2gfx.r3

#yj1 10
#v1 0
:j1
	$ff0000 Color
	10 yj1 20 80 FRect
	v1 'yj1 +!
	;

#yj2 10
#v2 0
:j2
	$ff Color
	770 yj2 20 80 FRect
	v2 'yj2 +!
	;

#x 400.0 #y 300.0
#vx 3.0 #vy 1.0

:hitx vx neg 'vx ! ;
:hity vy neg 'vy ! ;
:int 16 >> ;

:pelota
	$ffffff Color
	x int y int 20 20 FRect
	vx 'x +!
	vy 'y +!
	x 0 <? ( hitx ) 780.0 >? ( hitx ) drop
	y 0 <? ( hity ) 580.0 >? ( hity ) drop
	;

:demo
	0 clrscr
	j1
	j2
	pelota
	redraw
	
	SDLkey 
	>esc< =? ( exit )
	<q> =? ( -1 'v1 ! ) >q< =? ( 0 'v1 ! )
	<a> =? ( 1 'v1 ! ) >a< =? ( 0 'v1 ! )
	<up> =? ( -1 'v2 ! ) >up< =? ( 0 'v2 ! )
	<dn> =? ( 1 'v2 ! ) >dn< =? ( 0 'v2 ! )
	drop ;

:main
	"r3sdl" 800 600 SDLinit
	'demo SDLshow
	SDLquit ;	
	
: main ;