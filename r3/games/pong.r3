| r3 pong
| PHREDA
^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

|----- SCORE
#dig0 ( %1111 %1001 %1001 %1001 %1111 )
#dig1 ( %0001 %0001 %0001 %0001 %0001 )
#dig2 ( %1111 %0001 %1111 %1000 %1111 )
#dig3 ( %1111 %0001 %1111 %0001 %1111 )
#dig4 ( %1001 %1001 %1111 %0001 %0001 )
#dig5 ( %1111 %1000 %1111 %0001 %1111 )
#dig6 ( %0001 %0001 %1111 %1001 %1111 )
#dig7 ( %1111 %0001 %0001 %0001 %0001 )
#dig8 ( %1111 %1001 %1111 %1001 %1111 )
#dig9 ( %1111 %1001 %1111 %0001 %0001 )

#digits 'dig0 'dig1 'dig2 'dig3 'dig4 'dig5 'dig6  'dig7 'dig8 'dig9

#xx #yy
#startx #starty

:** | 0/1 --
	and? ( xx yy 20 dup SDLFRect ) 
	20 'xx +! ;

:drawd | addr --
	starty 'yy !
	5 ( 1? 1 - swap 
		c@+ startx 'xx !
		%1000 ** %0100 ** %0010 ** %0001 ** 
		drop 20 'yy +! swap ) 2drop ;

:drawdigit | n --
  3 << 'digits + @ drawd ;

:drawnumber | n x y --
  'starty ! 'startx !
  dup 10 / 10 mod drawdigit
  100 'startx +! 10 mod drawdigit ;

:ftoy
	sh 1 >> 16 *>> sh 1 >> + ;
:ftox
	sw 1 >> 16 *>> sw 1 >> + ;

|----- PLAYERS	
#yj1 #v1 #p1

:j1 $ff0000 SDLColor 10 yj1 20 80 SDLFRect v1 'yj1 +! ;

#yj2 #v2 #p2

:j2 $ff SDLColor 770 yj2 20 80 SDLFRect v2 'yj2 +! ;

|----- BALL
#x #y #vx #vy | ball pos

:reset 
	400.0 'x ! 290.0 'y ! 
	3.0 randmax 1.0 + 
	%1000 and? ( neg )
	'vx ! 0 'vy ! 
	260 'yj1 ! 260 'yj2 !
	;

:hitx vx neg 'vx ! ;
:hity vy neg 'vy ! ;

:hit1 | x -- x
	y int.
	yj1 30 + -
	-40 <? ( drop ; ) 40 >? ( drop ; )
	0.1 * 'vy +!
	30.0 'x ! hitx ;
	
:hit2
	y int.
	yj2 30 + -
	-40 <? ( drop ; ) 40 >? ( drop ; )
	0.1 * 'vy +! 
	750.0 'x ! hitx ;
	
:pierde1 1 'p2 +! reset ;
:pierde2 1 'p1 +! reset ;

:pelota
	$ffffff SDLColor
	x int. y int. 20 20 SDLFRect
	vx 'x +! vy 'y +!
|	x 0 <? ( hitx ) 780.0 >? ( hitx ) drop
	y 0 <? ( hity ) 580.0 >? ( hity ) drop
	x 
	30.0 <? ( hit1 ) 0 <? ( pierde1 )
	750.0 >? ( hit2 ) 780.0 >? ( pierde2 ) 
	drop
	;

:game
	0 SDLcls
	$ff0000 SDLColor p1 sw 1 >> 220 - 20 drawnumber
	$ff SDLColor p2 sw 1 >> 20 + 20 drawnumber
	j1 j2 pelota
	SDLredraw
	
	SDLkey 
	>esc< =? ( exit )
	<q> =? ( -3 'v1 ! ) >q< =? ( 0 'v1 ! )
	<a> =? ( 3 'v1 ! ) >a< =? ( 0 'v1 ! )
	<up> =? ( -3 'v2 ! ) >up< =? ( 0 'v2 ! )
	<dn> =? ( 3 'v2 ! ) >dn< =? ( 0 'v2 ! )
	drop ;

:main
	"Pong" 800 600 SDLinit
	reset
	'game SDLshow
	SDLquit ;	
	
: main ;