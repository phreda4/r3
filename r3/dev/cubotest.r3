| draw cube
| PHREDA 2025
^r3/lib/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/3d.r3

|------------------------------
#xcam 0 #ycam 0 #zcam 0.6

#octvert * 3072 	| 32 niveles de 3 valores*8 vert
#octvert> 'octvert

#rotsum * 2048		| 32 niveles de 2 valores*8 vert
#rotsum> 'rotsum

#ymin #nymin
#xmin #nxmin
#zmin #nzmin

#ymax #nymax
#xmax #nxmax
#zmax

#ozmin
#ozmax

#mask

#x0 #y0 #z0
#x1 #y1 #z1
#x2 #y2 #z2
#x4 #y4 #z4

#x7 #y7 #z7	| centro del cubo
#n1 #n2 #n3
|---------------
:dist3d | x y z -- x y z d
	pick2 dup * pick2 dup * + over dup * + ;

:dist3dc | x y z -- d
	dup * swap dup * + swap dup * + ;

:id3d3i
	transform
	dist3d 'zmin ! 0 'nzmin ! swap rot
	;

:id3d3 | id --
	>r transform
	dist3d zmin <? ( 'zmin ! r> 'nzmin ! swap rot ; )
	drop r> drop swap rot ;

:fillstart | --
	'octvert >b
	0.05 0.05 0.05 id3d3i dup 'x0 ! db!+ dup 'y0 ! db!+ dup 'z0 ! db!+ | 111
	0.05 0.05 -0.05 1 id3d3 dup 'x1 ! db!+ dup 'y1 ! db!+ dup 'z1 ! db!+ | 110
	0.05 -0.05 0.05 2 id3d3 dup 'x2 ! db!+ dup 'y2 ! db!+ dup 'z2 ! db!+ | 101
	0.05 -0.05 -0.05 3 id3d3 db!+ db!+ db!+ | 100
	-0.05 0.05 0.05 4 id3d3 dup 'x4 ! db!+ dup 'y4 ! db!+ dup 'z4 ! db!+ | 011
	-0.05 0.05 -0.05 5 id3d3 db!+ db!+ db!+ | 010
	-0.05 -0.05 0.05 6 id3d3 db!+ db!+ db!+ | 001
	-0.05 -0.05 -0.05 7 id3d3 dup x0 + 2/ 'x7 ! db!+ dup y0 + 2/ 'y7 ! db!+ dup z0 + 2/ 'z7 ! db!+ | 000
	b>
	'octvert> ! ;

:id3di | x y z -- u v
	project 	| x y
	;

:id3d | id x y z -- u v
	project | id x y
	rot drop ;

:fillveciso | --
	octvert> 96 - >b
	'rotsum
	db@+ db@+ db@+ id3di rot d!+ d!+
	1 db@+ db@+ db@+ id3d rot d!+ d!+
	2 db@+ db@+ db@+ id3d rot d!+ d!+
	3 db@+ db@+ db@+ id3d rot d!+ d!+
	4 db@+ db@+ db@+ id3d rot d!+ d!+
	5 db@+ db@+ db@+ id3d rot d!+ d!+
	6 db@+ db@+ db@+ id3d rot d!+ d!+
	7 db@+ db@+ db@ id3d rot d!+ d!+
	'rotsum> ! ;

:getn | n --
	3 << 'rotsum + d@+ swap d@ 200 - swap ;

:getn2 | n --
	3 << 'rotsum + d@+ swap d@ 200 + swap ;

#lx #ly

:line
	2dup lx ly sdlline
:op 
	'ly ! 'lx ! ;

:drawire
	$ff sdlcolor
	0 getn op
	1 getn line
	3 getn line
	2 getn line
	0 getn line
	4 getn op
	5 getn line
	7 getn line
	6 getn line
	4 getn line
	0 getn op 4 getn line
	1 getn op 5 getn line
	2 getn op 6 getn line
	3 getn op 7 getn line
	;

|---- real cube

| corregido para ccw
#cara [
$2310 $4620 $0154 0
$0231 $1375 $5401 0
$2310 $2046 $6732 0
$3102 $7513 $3267 0
$4576 $4620 $0154 0
$7645 $5137 $4015 0
$6457 $6204 $7326 0
$7645 $7513 $7326 0
]

#vert [
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
]

#index [ 0 1 2 2 3 0 ]

#rec $ff00

:aclara
    rec $f0f0f colavg 'rec !
	;
	
:drawquado | x y x y x y x y --
	'vert >a
	swap i2fp da!+ i2fp da!+ rec da!+ 8 a+
	swap i2fp da!+ i2fp da!+ rec da!+ 8 a+
	swap i2fp da!+ i2fp da!+ rec da!+ 8 a+
	swap i2fp da!+ i2fp da!+ rec da!+ 
	SDLrenderer 0 'vert 4 'index 6 SDL_RenderGeometry 
	;
	
|-------------------------
:caraq
	dup $f and getn >r >r
	4 >> dup $f and getn >r >r
	4 >> dup $f and getn >r >r
	4 >> $f and getn
	r> r> r> r> r> r>
	drawquado ;

:drawq
	4 << 'cara +
	d@+ caraq aclara
	d@+ caraq aclara
	d@ caraq ;
	

|----------------
#verc * 128
:getnn
	3 << 'verc + d@+ swap d@ ;

:cara1
	dup getnn op
	dup 2 xor getnn line
	dup 3 xor getnn line
	dup 1 xor getnn line
	;

:cara2
	dup getnn op
	dup 4 xor getnn line
	dup 6 xor getnn line
	dup 2 xor getnn line
	;

:cara3
	dup getnn op
	dup 1 xor getnn line
	dup 5 xor getnn line
	dup 4 xor getnn line
	;

:drawq3
	'verc >b
	0 ( 8 <? 
		dup getn2 
|		2dup "%d %d" .println
		swap db!+ db!+ 
		1+ ) drop
	cara1 aclara
	cara2 aclara
	cara3 drop ;


:calco
	x0 x1 - x7 * y0 y1 - y7 * + z0 z1 - z7 * + dup 'n1 ! 
	63 >> $1 and
	x0 x2 - x7 * y0 y2 - y7 * + z0 z2 - z7 * + dup 'n2 ! 
	63 >> $2 and or
	x0 x4 - x7 * y0 y4 - y7 * + z0 z4 - z7 * + dup 'n3 ! 
	63 >> $4 and or
	$7 xor
	'mask ! ;
	
#xr #yr
:freelook
	sdlb 0? ( drop ; ) drop
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg 'xr ! 'yr ! ;

:main
	0 sdlcls
	$ff00 sdlcolor

	freelook

	1.0 3dmode
	xr mrotx yr mroty 
	xcam ycam zcam mtrans

	fillstart
	fillveciso
	
	calco

	$ff00ff 'rec !
	mask drawq

	$ff00 sdlcolor
   	mask drawq3

	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop 
	;

: 
	"cube" 1024 720 SDLinit
	'main sdlshow
	SDLquit ;
