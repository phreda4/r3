| Obj Model Loader
| - faltan indices negativos
| PHREDA 2017,2021
|-----------------------------------
^r3/win/console.r3
^r3/win/SDL2.r3

^r3/lib/3d.r3
^r3/util/loadobj.r3


|-------------
#v2d
#zbuffer

#txres
#tyres
#tritt
0 0 0 0
0 0 0 0
0 0 0 0

:dumptri
	'tritt
	@+ "%d " .print @+ "%d " .print @+ "%d " .print @+ "%h " .print cr
	@+ "%d " .print @+ "%d " .print @+ "%d " .print @+ "%h " .print cr
	@+ "%d " .print @+ "%d " .print @+ "%d " .print @+ "%h " .print cr
	drop ;

:setcolor
	5 << colorl + 24 + @
	dup @
	dup $ffff and 'txres !
	16 >>> 'tyres !
|	'tritexture !
	drop
	;

:d>xy | d -- x y
	dup 32 >> swap 32 << 32 >> ;
:xy>d | x y --
	$ffffffff and swap 32 << or ;
	
:svert
	b@+ 1 - 3 << v2d + @+ d>xy swap a!+ a!+ | x y
	@ a!+ | z
	b@+ 16 >>> 1 - 24 * texl +
	@+ txres
	1.0 */ $ffff and 16 <<  | 0..1 0
	swap @ tyres
	1.0 - 1.0 */ $ffff and
	or
	a!+
	;

:objsolid
	0 zbuffer sw sh * fill
	mark
	here 'v2d !
	verl >b
	nver ( 1? 1 -
		b@+ b@+ b@+ 8 b+
		project3dz xy>d , neg , ) drop

	facel >b
	nface ( 1? 1 -
		b> 6 3 << + @ setcolor
		'tritt >a
		svert svert svert
		8 b+
		b> >r
|		dumptri trace

|		'tritt tritex2 |**

|		dumptri
		r> >b
		) drop
	empty
	;

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
		b@+ 8 b+ 1 - 3 << v2d + @ d>xy
		b@+ 8 b+ 1 - 3 << v2d + @ d>xy
		b@+ 8 b+ 1 - 3 << v2d + @ d>xy
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
	0 SDLClear

	1.0 3dmode
	freelook
	xcam ycam zcam mtrans
	
	$ffffff SDLColor
	objwire
	SDLRedraw
	
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
