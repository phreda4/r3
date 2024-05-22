| Obj Model Loader to Robj
| PHREDA 2023
|-----------------------------------
|MEM 512
^r3/win/console.r3
^r3/win/SDL2gfx.r3

^r3/lib/3d.r3
^r3/lib/gui.r3
^r3/lib/mem.r3

^r3/util/sort.r3
^r3/util/loadobj.r3
^r3/util/bfont.r3
^r3/util/dlgfile.r3

#filename * 1024
#cutpath ( $2f )
#fpath * 1024
#fname 

:getpath | 'filename 'path --
	strcpyl 2 -
	( dup c@ $2f <>? drop 1 - ) drop
	0 swap c!+ 'fname !
	;
	
| GENERATE file
|-------------
#vertex_buffer_data 
#normal_buffer_data
#uv_buffer_data 
#filenames

:vert+uv | nro --
	dup $fffff and 1 - ]vert | vertex
	@+ f2fp da!+ @+ f2fp da!+ @ f2fp da!+ | x y z
	
	dup 20 >> $fffff and 1 - ]uv | texture
	@+ f2fp db!+ @ neg f2fp db!+
	
	nface 3 * 3 * 2 << 12 - a+
	40 >> $fffff and 1 - ]norm | normal
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
	$01 or ,q			| tipo 1 - plano
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
		colorl over 4 << + @ 
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



|--- how many vertes repeat?
#facerep

:eqvert | 'v1 a2 'v2 -- 'v1 a2
	pick2 =? ( 1 'facerep +! ) drop ;

:equalsvert | face2 face1 --
	@+ pick2 @+ eqvert @+ eqvert @ eqvert drop
	@+ pick2 @+ eqvert @+ eqvert @ eqvert drop
	@ over @+ eqvert @+ eqvert @ eqvert drop
	drop
	;

:vertexrep?
	0 'facerep !
	facel 
	0 ( nface <? 1 + swap
		over ( nface <?  | nro face n2
			dup ]face	| nro face1 n2 face2
			pick2 equalsvert
			1 + ) drop
		32 + swap ) 2drop ;
|---------------------------------		

| tipo 2 -- +index	
#auxvert | vertices
#auxvert>

#indexa | index
#indexa> 

#colornow -1
#indcolor * 128

:searchvert | vert -- vert nvert/-1 
	auxvert ( auxvert> <? 
		@+ pick2 
		=? ( drop auxvert - 3 >> 1 - ; )
		drop ) drop 
	-1 ;
	
:newvert | vert -- vert nvert
	dup auxvert> !+ 'auxvert> !
	auxvert> auxvert - 3 >> 1 - 
	;
	
:addvert, | vert --
	searchvert -? ( drop newvert ) 
	indexa> w!+ 'indexa> !
	drop 
	1 colornow 3 << 'indcolor + +! | add index to col
	;

:savever
	$fffff and 1 - ]vert
	@+ f2fp , @+ f2fp , @ f2fp , ;

:savenor
	40 >> $fffff and 1 - ]norm 
	@+ f2fp , @+ f2fp , @ f2fp , ;
	
:saveuv
	20 >> $fffff and 1 - ]uv 
	@+ f2fp , @ neg f2fp , ;
	
	
#sortface 
:fillvertex&index
	here 'sortface !
	facel 
	nface ( 1? 1 - swap
		dup 24 + @ ,q
		dup ,q
		32 + swap 
		) 2drop
	|--------- ordenado por colores
	nface sortface shellsort | len lista			

	here 
	dup dup 'auxvert ! 'auxvert> ! | cada vertice usado
	nface 3 * 3 << + | 3 vertices por cara | nro/vert/norm | max
	dup dup 'indexa ! 'indexa> !
	'here !
|	"vertex add" .println

|	facel nface ( 1? 1 - swap
|		dup 24 + @ 'colornow ! 
|		@+ addvert, @+ addvert,	@+ addvert,
|		8 + swap ) 2drop
		
	sortface nface
	( 1? 1- swap
		@+ 'colornow !
		@+ @+ addvert, @+ addvert, @ addvert,
		swap ) 2drop

	indexa> 'here ! ;


	
|--------------------------
:,vf3
	dup $fffff and f2fp ,
	dup 20 >> $fffff and f2fp ,
	40 >> $fffff and f2fp , ;
	
:,vf
	f2fp , ;
	
:,material | n -- n
	'indcolor over 3 << + @ ,		| cntindex +0
	dup ]Kd@ ,vf3	| diffuse color +4
	dup ]Ka@ ,vf3	| ambient color +16
	dup ]Ke@ ,vf3	| emissive +28
	dup ]Ks@ ,vf3	| specular	+40
	dup ]Ns@ ,vf	| shininess +52
	dup ]d@ ,vf		| opacity	+56
	dup ]Ni@ drop	
	dup ]i@ drop
	dup ]Mkd@ ,		| diffuse Map { 255 255 255 255} +60
	dup ]MNs@ , 	| especular Map { 255 255 255 255} +64
	dup ]Mbp@ ,		| normal Map { 127 127 255 0 } +68
	; | +72

:namenmap | n --
	72 * 40 + inimem + ;

:,filen | "" -- adri
	0? ( ; ) 
	here strcpylnl 
	here swap 'here ! 
	inimem - ;
	
:,filesimg | n -- n
	dup ]Mkd@ ,filen over namenmap 60 + d!
	dup ]MNs@ ,filen over namenmap 64 + d!
	dup ]Mbp@ ,filen over namenmap 68 + d!
	;

:convertobj2 | --
	0 ( ncolor <? 
		0 over 3 << 'indcolor + !
		1 + ) drop

	mark
	|*** find and reeplace repetitions in vertex,normal and uv!!
	fillvertex&index
	|---- generate file
	mark
	here 'inimem !
	| cnt partes
	ncolor $ff and 8 << | cnt colores
	$02 or ,q			| tipo 2 - indices
	0 ,			| filenames +8 | not used <<<
	0 ,			| VA		+12
	0 , 		| vertex>	+16
	0 , 		| normal>	+20
	0 , 		| uv>		+24
	0 ,			| index> 	+28
	
	auxvert> auxvert - 3 >> ,		| cnt vert +32
	indexa> indexa - 1 >> ,			| cntindex +36
	| +40
	0 ( ncolor <? ,material 1 + ) drop	| Materiales
	
	here inimem - inimem 16 + d!
	auxvert ( auxvert> <? @+ savever ) drop
	here inimem - inimem 20 + d!
	auxvert ( auxvert> <? @+ savenor ) drop
	here inimem - inimem 24 + d!
	auxvert ( auxvert> <? @+ saveuv ) drop
	here inimem - inimem 28 + d!
	indexa ( indexa> <? w@+ ,w ) drop
	
	|--- old format
	here inimem - inimem 8 + d! | start string
	
	0 ( ncolor <? ,filesimg 1 + ) drop | texture names

	fname 'fpath "%s/%sm" sprint savemem
	empty
	
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

#colist $ff0000 $ff00 $ff $ffff00 $ff00ff $ffff $ffffff

:ncolorset | nro -- nro
	dup $fffff and 1 - 3 << 'colist + @ SDLColor ;
	
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
	
:objpoint
	verl >b
	nver ( 1? 1 -
		b@+ b@+ b@+ 
		8 b+ |b@+ $7 and 3 << 'colist + @ SDLColor
		project3d
		SDLPoint ) drop	;
|------------------------
:,d "%d " ,print ;

:,vf3
	dup $fffff and ,d
	dup 20 >> $fffff and ,d
	40 >> $fffff and ,d ;
	
:,vf ,d ;

:,debcolor
	'indcolor over 3 << + @ ,d		| cntindex +0
	dup ]Kd@ ,vf3	| diffuse color +4
	dup ]Ka@ ,vf3	| ambient color +16
	dup ]Ke@ ,vf3	| emissive +28
	dup ]Ks@ ,vf3	| specular	+40
	dup ]Ns@ ,vf	| shininess +52
	dup ]d@ ,vf		| opacity	+56
	dup ]Ni@ drop	
	dup ]i@ drop
	dup ]Mkd@ ,d		| diffuse Map { 255 255 255 255} +60
	dup ]MNs@ ,d 	| especular Map { 255 255 255 255} +64
	dup ]Mbp@ ,d		| normal Map { 127 127 255 0 } +68
	,nl
	;
	
:debugfile
	fillvertex&index
	mark
|	nver ( 1? 1 -
|		b@+ "%f " ,print b@+ "%f " ,print b@+ "%f " ,print b@+ "%f " ,print ,cr
|		) drop
	facel >b
|	nface ( 1? 1 -
|		b@+ "%h " ,print b@+ "%h " ,print b@+ "%h " ,print 	b@+ "%h " ,print  ,cr
|		) drop
	"index" ,print ,nl		
|	indexa ( indexa> <? w@+ ,d ) drop	
	sortface 
	nface ( 1? 1 -
		swap @+ "%d " ,print @+ "%d " ,print ,nl
		swap ) 2drop
		
	"colors" ,print ,nl
	0 ( ncolor <? 
		,debcolor
		1 + ) drop | texture names	
	"test.txt" savemem
	empty ;

| MAIN
|-----------------------------------
#xcam 0 #ycam 0 #zcam -8.0
#xm #ym
#rx #ry

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;

#model

:useobj | "" --
	empty
	mark
	dup 'fpath getpath
	dup 'filename strcpy
	loadobj 'model !
	| objminmax objcentra
	;
	
|---------------------------------------------------		
:loadobj | --	
	dlgFileLoad
	drop
	;
	
|---------------------------------------------------	
:objinfo
	8 0 bat 'filename bprint
	" >> F1:LOAD F2:OBJ1 F3:OBJ2 F9:CUBO1.0 F10:CENTER" bprint
	8 16 bat nver "vert:%d" sprint bprint nface " tria:%d" sprint bprint ncolor " col:%d" sprint bprint 
	0 ( ncolor <? 
		8 32 pick2 4 << + bat dup "Color %d : " sprint bprint
		colorl over 4 << + @ "%w" sprint bprint
		1 + ) drop
	8 sh 48 - bat 
	|facerep "rep:%d" sprint bprint
	auxvert> auxvert - 3 >> "vertices:%d " sprint bprint
	indexa> indexa  - 1 >> "index:%d " sprint bprint
	
	8 sh 32 - bat sizemem 10 >> "mem used: %d kb" sprint bprint
	;
	
:dibuja
	nface 10000 <? ( objwire drop ; ) drop
	objpoint ;
		
:main
	gui
	'dnlook 'movelook onDnMove
	0 SDLcls

	1.0 3dmode
	rx ry 0 mrot
	xcam ycam zcam mtrans
	
	$007f00 SDLColor
	
	dibuja
	
	objinfo
	SDLredraw
	
	SDLkey
	<up> =? ( 1.0 'zcam +! )
	<dn> =? ( -1.0 'zcam +! )

	<f1> =? ( loadobj ) 
	<f2> =? ( convertobj1 )
	<f3> =? ( convertobj2 )
	
	<f9> =? ( objminmax 1.0 objcube )
	<f10> =? ( objminmax objcentra )
	<f11> =? ( debugfile )
	>esc< =? ( exit )
	drop ;

|------------------------------------	
: 
	"r3sdl" 800 600 SDLinit
	bfont1

	"media/obj/" dlgSetPath
	mark
	|"r3/games/lunar/obj/nave1.obj"
	|"r3/games/lunar/obj/pablo.obj"
|	"r3/games/lunar/obj/nave.obj"
|	"r3/games/lunar/obj/navelau.obj"
|	"r3/games/lunar/obj/extraterrestrenave.obj" |*
|	"r3/games/lunar/obj/piedra.obj" |**
|	"r3/games/lunar/obj/yyyht.obj"
	"r3/games/lunar/obj/astro1.obj"
	useobj
	'main SDLshow 
	SDLquit
	;