| Obj Model Loader to Robj
| PHREDA 2023
|-----------------------------------
^r3/win/console.r3
^r3/win/SDL2gfx.r3

^r3/lib/3d.r3
^r3/lib/gui.r3

^r3/util/loadobj.r3
^r3/util/bfont.r3


#filename * 1024
#cutpath ( 0 )
#fpath * 1024
#fname 

:getpath | 'filename 'path --
	strcpyl 2 -
	( dup c@ $2f <>?
		0? ( 'fpath c! drop ; )
		drop 1 - ) drop
	0 swap c!+ 'fname !
	;
	
| GENERATE file
|-------------
#vertex_buffer_data 
#normal_buffer_data
#uv_buffer_data 
#filenames

:vert+uv | nro --
	dup $fffff and 1 - | vertex
	5 << verl +
	@+ f2fp da!+ @+ f2fp da!+ @ f2fp da!+ | x y z
	dup 20 >> $fffff and 1 - | texture
	24 * texl +
	@+ f2fp db!+ @ neg f2fp db!+
	nface 3 * 3 * 2 << 12 - a+
	40 >> $fffff and 1 - | normal
	24 * norml +
	@+ f2fp da!+ @+ f2fp da!+ @ f2fp da!+ | x y z
	nface 3 * 3 * 2 << neg a+
	;

#inimem
#sizemem

| tipo 1 -- 1 texture, all vertex in 1 draw call
:convertobj1 | --
	mark
	here 'inimem !
	
	| cnt partes
	ncolor $ff and 8 << | cnt colores
	$01 or ,q			| tipo 
	0 ,			| filenames +8
	0 ,			| VA		+12
	0 , 		| vertex>	+16
	0 , 		| normal>	+20
	0 , 		| uv>		+24
	nface 3 * , | cntvert	+28
	
	here 		
	dup 'vertex_buffer_data ! 
	nface 3 * 3 * 2 << + | 3 vertices por vertice 3 coor por vertices 4 bytes por nro
	dup 'normal_buffer_data !
	nface 3 * 3 * 2 << + | 3 vertices por vertice 3 coor por vertices 4 bytes por nro
	'uv_buffer_data  !
	vertex_buffer_data >a
	| normal_buffer_data = vertex + nface 3 * 3 * 2 << +
	uv_buffer_data >b
	facel 
	nface ( 1? 1 - swap
		@+ vert+uv
		@+ vert+uv
		@+ vert+uv
		8 + swap ) 2drop
	b> 'here !
	b> 'filenames !
	
	0 ( ncolor <? 
		colorl over 5 << + 8 + @ 
		here strcpylnl 'here !
		1 + ) drop
	
	filenames inimem - inimem 8 + d!
	vertex_buffer_data inimem - inimem 16 + d!
	normal_buffer_data inimem - inimem 20 + d!
	uv_buffer_data inimem - 	inimem 24 + d!
	
	here inimem - 'sizemem !
	fname 'fpath "%s/%s.mem" sprint savemem
	empty
	;


| DRAW
|-------------
#v2d

| WIRE
:drawtri | x y x y x y --
	>r >r 2over 2over SDLLine
	r> r> 2swap 2over SDLLine
	SDLLine ;

:d>xy | d -- x y
	dup 32 >> swap 32 << 32 >> ;
:xy>d | x y --
	$ffffffff and swap 32 << or ;

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
#xcam 0 #ycam 0 #zcam -20.0
#xm #ym
#rx #ry

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;

#model

:useobj | ""
	empty
	mark
	dup 'fpath getpath
	dup 'filename strcpy
	loadobj 'model !
	| objminmax objcentra
	;
	
:objinfo
	8 0 bat 'filename bprint
	8 16 bat nver "vert:%d" sprint bprint nface " tria:%d" sprint bprint ncolor " col:%d" sprint bprint 
	0 ( ncolor <? 
		8 32 pick2 4 << + bat dup "Color %d : " sprint bprint
		colorl over 5 << + 8 + @ "%w" sprint bprint
		1 + ) drop
	8 sh 32 - bat sizemem 10 >> "mem used: %d kb" sprint bprint
	;
	
:main
	gui
	'dnlook 'movelook onDnMove
	0 SDLcls

	1.0 3dmode
|	freelook
	rx ry 0 mrot
	xcam ycam zcam mtrans
	
	$007f00 SDLColor
	objwire
	
	objinfo
	
	SDLredraw
	
	SDLkey
	<up> =? ( 1.0 'zcam +! )
	<dn> =? ( -1.0 'zcam +! )

	<f1> =? ( convertobj1 )
	<f10> =? ( objminmax objcentra )
	>esc< =? ( exit )
	drop ;

|------------------------------------	
: 
	"r3sdl" 800 600 SDLinit
	bfont1

	mark
	"media/obj/food/Brocolli.obj" 	
|	"media/obj/food/Bellpepper.obj" 
|	"media/obj/food/Banana.obj" 
|	"media/obj/food/Crabcake.obj" 
|	"media/obj/food/Apple.obj" 
	|"media/obj/mario/mario.obj"
	useobj
	
	'main SDLshow 
	SDLquit
	;