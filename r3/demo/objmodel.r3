| Obj Model Loader
| - faltan indices negativos
| PHREDA 2017,2021
|-----------------------------------
^r3/win/console.r3
^r3/win/SDL2gfx.r3

^r3/lib/3d.r3
^r3/util/loadobj.r3


|-------------
#v2d
#zbuffer

:d>xy | d -- x y
	dup 32 >> swap 32 << 32 >> ;
:xy>d | x y --
	$ffffffff and swap 32 << or ;
	

| WIRE
|-------------
:drawtri | x y x y x y --
	>r >r 2over 2over SDLLine
	r> r> 2swap 2over SDLLine
	SDLLine ;

::objwire
	mark
	here 'v2d !
	verl >b
	nver ( 1? 1 -
		b@+ b@+ b@+ 8 b+ project3d
		xy>d ,q ) drop
	facel >b
	nface ( 1? 1 -
		b@+ $fffff and 1 - 3 << v2d + @ d>xy
		b@+ $fffff and 1 - 3 << v2d + @ d>xy
		b@+ $fffff and 1 - 3 << v2d + @ d>xy
		8 b+
		drawtri
		) drop
	empty
	;


| MAIN
|-----------------------------------
#xcam 0 #ycam 0 #zcam -55.0
#xr #yr

:freelook
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg
|	swap 0 mrotxyz
	mrotx mroty ;

#model

:main
	0 SDLcls

	1.0 3dmode
	freelook
	xcam ycam zcam mtrans
	
	$ffffff SDLColor
	objwire
	SDLredraw
	
	SDLkey
	<up> =? ( 1.0 'zcam +! )
	<dn> =? ( -1.0 'zcam +! )
	<f1> =? ( objminmax objcentra )
	>esc< =? ( exit )
	drop ;

:memory
	mark
	"media/obj/mario/mario.obj"
	loadobj 'model !
	objminmax
	objcentra
	
	;

: memory 3 
	"r3sdl" 800 600 SDLinit
	'main SDLshow 
	SDLquit
	;
