| Obj Model Loader
| PHREDA 2017
|-----------------------------------
^r3/lib/sys.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

^r3/win/SDL2image.r3


#textobj | textparse
#textmtl

##verl	| vertices
#verl>
##nver

##facel	| faces
#facel>
##nface

##norml	| normal
#norml>
#nnorm

##texl	| text
#texl>
#ntex

##paral	| parametros
#paral>
#npara

#ncolor	| colores
##colorl
#colorl>

|-----------------------------
:vert	| vertices (x,y,z[,w=1])
	2 + trim
	verl> >b
	getfenro b!+
	getfenro b!+
	getfenro b!+
	1.0 over c@ 32 >=? ( 2drop getfenro dup ) drop
	b!+ b> 'verl> !
	;
:texc	| textcoor (u, v [,w])
	texl> >b
	3 + trim
	getfenro b!+
	getfenro b!+
	1.0 over c@ 32 >=? ( 2drop getfenro dup ) drop
	b!+ b> 'texl> !
	;
:norm	| normales (x,y,z)
	norml> >b
	3 + trim
	getfenro b!+
	getfenro b!+
	getfenro b!+
	b> 'norml> !
	;
:pspa	| param space ( u [,v] [,w] )
	paral> >b
	3 + trim
	getfenro b!+
	getfenro b!+
	getfenro b!+
	b> 'paral> !
	;

#nv #nt #nn #colornow

:searchcol | str -- nro
	0 ( ncolor <?
		|dup "%d." .print
		dup 4 << colorl + @ 0? ( 3drop -1 ; )
		pick2
		|2dup "%w %w" .println
		=pre 1? ( 2drop nip ; )
		2drop 1 + ) 2drop -1 ;

:uface
	?sint
	-? ( verl> verl - 5 >> 1 + + )
	'nv ! dup 1 - c@
	32 <? ( drop 1 - ; ) 33 <? ( drop ; ) drop
	?sint
	-? ( texl> texl - 24 / 1 + + )
	'nt ! dup 1 - c@
	32 <? ( drop 1 - ; ) 33 <? ( drop ; ) drop
	?sint
	-? ( norml> norml - 24 / 1 + + )
	'nn ! dup 1 - c@
	32 <? ( drop 1 - ; ) drop
	;

:4to
	dup c@ $ff and 13 <=? ( drop ; ) drop
	uface
	nv b!+ nt 32 << nn or b!+
	b> 72 - @+ b!+ @+ b!+		| vert 0
	16 + @+ b!+ @+ b!+           | vert 2
	colornow b!+ ;

:face	| face nvert( v/t/n  v//n v/t  v)??
	2 + trim
	facel> >b
	| solo tres
	uface
	nv b!+ nt 32 << nn or b!+
	uface
	nv b!+ nt 32 << nn or b!+
   	uface
	nv b!+ nt 32 << nn or b!+
	colornow b!+
	| manejar aca si hay cuatro
|	4to
	b> 'facel> !
	;
:smoo	| 1/off
	2 + trim
	;
:onam	| o [object name]
	2 + trim
	;
:gman	| g [group name]
	2 + trim
	;

:usmt	| usemtl [material name]
	6 + trim
	dup "%l" sprint 
|	dup .println
	searchcol 'colornow !
	;

:parseline
	"vt" =pre 1? ( drop texc ; ) drop	| textcoor (u, v [,w])
	"vn" =pre 1? ( drop norm ; ) drop	| normales (x,y,z)
	"vp" =pre 1? ( drop pspa ; ) drop	| param space ( u [,v] [,w] )
	"v" =pre 1? ( drop vert ; ) drop	| vertices (x,y,z[,w=1])
	"f" =pre 1? ( drop face ; ) drop	| face nvert( v/t/n  v//n v/t  v)??
	"s" =pre 1? ( drop smoo ; ) drop	| 1/off
	"o" =pre 1? ( drop onam ; ) drop	| o [object name]
	"g" =pre 1? ( drop gman ; ) drop	| g [group name]
	"mtllib" =pre 1? ( drop ; ) drop	| mtllib [external .mtl file name]
	"usemtl" =pre 1? ( drop usmt ; ) drop	| usemtl [material name]
	;

::>>cr | adr -- adr'/0	; proxima linea/0
	( c@+ $ff and 13 >? drop ) 0? ( nip ; ) drop ;

:parseobj | text --
	( trim parseline >>cr 1? ) drop ;


|--------------------
| nombre text mem solido
#colora

:illum
	;

:newmtl
	colorl> 'colora !
	32 'colorl> +!
	7 + trim
	dup colora !
	;

:texmap
	7 + trim dup colora 8 + !
|	existe?
	dup 'path "%s%l" sprint
	| loadimg  |** no carga imagen
	|dup .println
	
	colora 24 + !
	;

:colorp
	3 + trim
	getfenro $ff 1.0 */ $ff0000 and swap
	getfenro $ff 1.0 */ 8 >> $ff00 and swap
	getfenro $ff 1.0 */ 16 >> $ff and
	rot or rot or
	colora 24 + !
	;

:parselinem
	"newmtl " =pre 1? ( drop newmtl ; ) drop
	"Ka" =pre 1? ( drop colorp ; ) drop
	"Kd" =pre 1? ( drop colorp ; ) drop
	"Ks" =pre 1? ( drop ; ) drop
	"Ke" =pre 1? ( drop ; ) drop
	"Ni" =pre 1? ( drop ; ) drop
	"d " =pre 1? ( drop ; ) drop
	"Tr" =pre 1? ( drop ; ) drop | 1-d
	"illum" =pre 1? ( drop illum ; ) drop
	"map_Kd" =pre 1? ( drop texmap ; ) drop
	"map_Ka" =pre 1? ( drop texmap ; ) drop
	"map_Ks" =pre 1? ( drop ; ) drop
	"map_Ns" =pre 1? ( drop ; ) drop
	"map_d" =pre 1? ( drop ; ) drop
	"map_bump " =pre 1? ( drop ; ) drop
	"bump" =pre 1? ( drop ; ) drop
	"disp" =pre 1? ( drop ; ) drop
	"decal" =pre 1? ( drop ; ) drop
	;

:notmtl
|	7 + trim dup colora 4 + !
|	existe?
|	dup 'path "%s%l" sprint
|	loadimg colora 12 + !
	;

:parsemtl | text --
	0? ( drop notmtl ; )
	( trim parselinem >>cr 1? ) drop ;

|--------- contar elementos y cargar mtl
:mtli	| mtllib [external .mtl file name]
	6 + trim
	dup 'path
	"%s%l" sprint
	here dup 'textmtl !
	swap
	load 0 swap !+ 'here !
	;

::cnt/
	0 swap
	( c@+ 13 >? 
		$2f =? ( rot 1 + rot rot )
		drop
		) 2drop ;

| contar 2 caras para 4 vertices
:facecnt
	dup 2 + trim	| 3 y 6 -->1  4 y 8 -->2
	cnt/ 1 >> not 1 and 1 + ;

:parsecount
	"vt" =pre 1? ( drop 1 'ntex +! ; ) drop	| textcoor (u, v [,w])
	"vn" =pre 1? ( drop 1 'nnorm +! ; ) drop	| normales (x,y,z)
	"vp" =pre 1? ( drop 1 'npara +! ; ) drop	| param space ( u [,v] [,w] )
	"v" =pre 1? ( drop 1 'nver +! ; ) drop	| vertices (x,y,z[,w=1])
	"f" =pre 1? ( drop facecnt 'nface +! ; ) drop	| face nvert( v/t/n  v//n v/t
	"s" =pre 1? ( drop ; ) drop	| 1/off
	"o" =pre 1? ( drop ; ) drop	| o [object name]
	"g" =pre 1? ( drop ; ) drop	| g [group name]
	"mtllib" =pre 1? ( drop mtli ; ) drop	| mtllib [external .mtl file name]
	"usemtl" =pre 1? ( drop 1 'ncolor +! ; ) drop	| usemtl [material name]
	;

:preparse | adr --
	( trim parsecount >>cr 1? ) drop ;

::loadobj | "" -- mem
	getpath
	here dup 'textobj !
	swap load over =? ( 2drop 0 ; ) 0 swap !+
	'here !
	0 'nver !
	0 'nface !
	0 'nnorm !
	0 'ntex !
	0 'npara !
	0 'textmtl !
	textobj preparse
	here
	dup dup 'verl ! 'verl> !
	nver 0? ( nip ; )
	5 << +
	dup dup 'texl ! 'texl> !
	ntex 
	24 * +
	dup dup 'facel ! 'facel> ! | falta contar 4 vertices
	nface 
	7 3 << * +
    dup dup 'norml ! 'norml> !
	nnorm
	24 * +
    dup dup 'paral ! 'paral> !
	npara
	24 * +
	dup dup 'colorl ! 'colorl> !
	ncolor 1 + 5 << +
	'here !
	textmtl parsemtl
	textobj parseobj
	here
	;

|------------------------------------------
#xmin #ymin #zmin #xmax #ymax #zmax

::objminmax | --
	verl >b
	b@+ dup 'xmin ! 'xmax !
	b@+ dup 'ymin ! 'ymax !
	b@+ dup 'zmin ! 'zmax !
	8 b+
	nver 1 - ( 1? 1 -
		b@+ xmin <? ( dup 'xmin ! ) xmax >? ( dup 'xmax ! ) drop
		b@+ ymin <? ( dup 'ymin ! ) ymax >? ( dup 'ymax ! ) drop
		b@+ zmin <? ( dup 'zmin ! ) zmax >? ( dup 'zmax ! ) drop
		8 b+
		) drop ;

::objmove | x y z --
	verl >b
	nver ( 1? 1 -
		b@ pick4 + b!+
		b@ pick3 + b!+
		b@ pick2 + b!+
		8 b+
		) 4drop ;

::objcentra
	xmax xmin + 1 >> neg
	ymax ymin + 1 >> neg
	zmax zmin + 1 >> neg
	objmove
	;

::objescala | por div --
	verl >b
	nver ( 1? 1 -
		b@ pick3 pick3 */ b!+
		b@ pick3 pick3 */ b!+
		b@ pick3 pick3 */ b!+
		8 b+
		) 3drop ;


::objcube | lado --
	xmax ymax zmax max max
	xmin ymin zmin min min - | largo
	objescala
	;
