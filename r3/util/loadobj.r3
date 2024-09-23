| Obj Model Loader
| PHREDA 2017
|-----------------------------------
^r3/lib/mem.r3
^r3/lib/parse.r3
^r3/lib/sdl2image.r3

#path * 1024

#textobj | textparse
#textmtl

##verl #verl> ##nver 	| vertices
##facel	#facel> ##nface | faces (tri or quad)
##norml #norml> #nnorm	| normal
##texl #texl> ##ntex	| texture coord
##paral #paral> #npara	| parametros
##colorl #colorl> ##ncolor 	| colores

|---------
::]face | nro -- FACE ( p1 p2 p3 color)
	5 << facel + ;

::]vert | nro -- vertex 
	5 << verl + ;

::]norm | nro -- normal
	24 * norml + ;

::]uv | nro -- uv 
	24 * texl + ;

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
		dup 4 << colorl + @ 0? ( 3drop -1 ; )
		pick2 =pre 1? ( 2drop nip ; )
		2drop 1 + ) 2drop -1 ;
		
:unusedcol
	ncolor ( 1? 1 -
		dup 4 << colorl + @ 0? ( -1 'ncolor +! ) drop
		) drop ;
			

:uface
	trim ?sint
	-? ( verl> verl - 5 >> 1 + + )
	'nv ! dup 1 - c@ 33 <? ( drop 1 - ; ) drop
	trim ?sint
	-? ( texl> texl - 24 / 1 + + )
	'nt ! dup 1 - c@ 33 <? ( drop 1 - ; ) drop
	trim ?sint
	-? ( norml> norml - 24 / 1 + + )
	'nn ! dup 1 - c@ 33 <? ( drop 1 - ; ) drop
	;

:4to
	dup c@ $ff and 13 <=? ( drop ; ) drop
	uface
	nv b!+ nt 32 << nn or b!+
	b> 72 - @+ b!+ @+ b!+		| vert 0
	16 + @+ b!+ @+ b!+           | vert 2
	colornow b!+ ;

:pack nn 20 << nt or 20 << nv or ; | 4 | 20 nn|20 nt | 20 nv
	
| formato normal|texture|vertice  - 20 bits c/u 
:face	| face nvert( v/t/n  v//n v/t  v)??
	>>sp
	facel> >b
	| solo tres 
	uface pack b!+ uface pack b!+ uface pack b!+
	colornow b!+
	| manejar aca si hay cuatro
|	4to
	b> 'facel> !
	;
	
:usmt	| usemtl [material name]
	>>sp trim dup "%w" sprint searchcol 'colornow ! ;

:parseline
|	dup "%l" .println .input
	"vt" =pre 1? ( drop dup texc drop ; ) drop	| textcoor (u, v [,w])
	"vn" =pre 1? ( drop dup norm drop ; ) drop	| normales (x,y,z)
	"vp" =pre 1? ( drop dup pspa drop ; ) drop	| param space ( u [,v] [,w] )
	"v" =pre 1? ( drop dup vert drop ; ) drop	| vertices (x,y,z[,w=1])
	"f" =pre 1? ( drop dup face drop ; ) drop	| face nvert( v/t/n  v//n v/t  v)??
|	"s" =pre 1? ( drop ; ) drop	| 1/off
|	"o" =pre 1? ( drop ; ) drop	| o [object name]
|	"g" =pre 1? ( drop ; ) drop	| g [group name]
|	"mtllib" =pre 1? ( drop ; ) drop	| mtllib [external .mtl file name]
	"usemtl" =pre 1? ( drop usmt ; ) drop	| usemtl [material name]
	;

::>>cr | adr -- adr'/0	; proxima linea/0
	( c@+ $ff and 13 >? drop ) 0? ( nip ; ) drop ;

:parseobj | text --
	( trim parseline >>cr 1? ) drop ;

|--------------------
| nombre text mem solido
#colornow

#colka * 1024
#colkd * 1024
#colks * 1024
#colke * 1024
#colNs * 1024
#colNi * 1024
#cold * 1024
#colI * 1024
#colMapKd * 1024
#colMapNs * 1024
#colMapBp * 1024

:n]Ka! colornow 3 << 'colka + ! ; 
:n]Kd! colornow 3 << 'colkd + ! ;
:n]Ks! colornow 3 << 'colks + ! ;
:n]Ke! colornow 3 << 'colke + ! ;
:n]Ns! colornow 3 << 'colNs + ! ;
:n]Ni! colornow 3 << 'colNi + ! ;
:n]d! colornow 3 << 'cold + ! ;
:n]i! colornow 3 << 'colI + ! ;
:n]Mkd! colornow 3 << 'colMapKd + ! ;
:n]MNs! colornow 3 << 'colMapNs + ! ;
:n]Mbp! colornow 3 << 'colMapBp + ! ;

::]Ka@ 3 << 'colka + @ ;
::]Kd@ 3 << 'colkd + @ ;
::]Ks@ 3 << 'colks + @ ;
::]Ke@ 3 << 'colke + @ ;
::]Ns@ 3 << 'colNs + @ ;
::]Ni@ 3 << 'colNi + @ ;
::]d@ 3 << 'cold + @ ;
::]i@ 3 << 'colI + @ ;
::]Mkd@ 3 << 'colMapKd + @ ;
::]MNs@ 3 << 'colMapNs + @ ;
::]Mbp@ 3 << 'colMapBp + @ ;


:parseV | adr -- adr val
	>>sp trim
	getfenro ;
	
:parseV3 | adr -- adr val
	>>sp trim
	getfenro $fffff and swap
	getfenro $fffff and 20 << swap
	getfenro $fffff and 40 << 
	rot or rot or ;

:newmtl
	1 'colornow +!
	dup >>sp trim colornow swap 
	colorl> !+ !+ 'colorl> !
|	colornow "c:%d" .println
	0 n]Ka! 0 n]Kd! 0 n]Ks! 0 n]Ke!
	0 n]Mkd! 0 n]MNs! 0 n]Mbp!
	0 n]Ns! 1.0 n]Ni!
	1.0 n]d! 2.0 n]i! 
	;

:parselinem
	|dup "%l" .println
	"newmtl " =pre 1? ( drop newmtl ; ) drop
	"Ka" =pre 1? ( drop parseV3 n]Ka! ; ) drop	| ambient color
	"Kd" =pre 1? ( drop parseV3 n]Kd! ; ) drop	| diffuse color
	"Ks" =pre 1? ( drop parseV3 n]Ks! ; ) drop	| specular
	"Ke" =pre 1? ( drop parseV3 n]Ke! ; ) drop	| emissive
	"Ni" =pre 1? ( drop parseV n]Ni! ; ) drop	| optical density*
	"Ns" =pre 1? ( drop parseV n]Ns! ; ) drop	| shininess
	"d " =pre 1? ( drop parseV n]d! ; ) drop	| opacity
	"illum" =pre 1? ( drop parseV n]i! ; ) drop | illumination
	"map_Kd" =pre 1? ( drop >>sp trim dup n]Mkd! ; ) drop | diffuse Map { 255 255 255 255}
	"map_Ns" =pre 1? ( drop >>sp trim dup n]Mns! ; ) drop | especular Map { 255 255 255 255}
	"map_bump " =pre 1? ( drop >>sp trim dup n]Mbp! ; ) drop | normal Map { 127 127 255 0 }
	;
	
|	"map_Ka" =pre 1? ( drop ; ) drop
|	"map_Ks" =pre 1? ( drop ; ) drop
|	"map_d" =pre 1? ( drop ; ) drop
|	"bump" =pre 1? ( drop ; ) drop
|	"disp" =pre 1? ( drop ; ) drop
|	"decal" =pre 1? ( drop ; ) drop
|	"Tr" =pre 1? ( drop ; ) drop | 1-d	

:notmtl
	"error, not MTL!" .println
|	7 + trim dup colora 4 + !
|	existe?
|	dup 'path "%s%l" sprint
|	loadimg colora 12 + !
	;

:parsemtl | text --
	0? ( drop notmtl ; )
	-1 'colornow !
	( trim parselinem >>cr 1? ) drop ;

|--------- contar elementos y cargar mtl
:mtli	| mtllib [external .mtl file name]
	>>sp trim
	dup 'path "%s%l" sprint
	here dup 'textmtl !
	swap load 0 swap c!+ 'here !
	;

::cnt/
	0 swap
	( c@+ 13 >? 
		$2f =? ( rot 1 + -rot )
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
	"f" =pre 1? ( drop |facecnt 
					1 'nface +! ; ) drop	| face nvert( v/t/n  v//n v/t
|	"s" =pre 1? ( drop ; ) drop	| 1/off
|	"o" =pre 1? ( drop ; ) drop	| o [object name]
	"g" =pre 1? ( drop ; ) drop	| g [group name]
	"mtllib" =pre 1? ( drop mtli ; ) drop	| mtllib [external .mtl file name]
	"usemtl" =pre 1? ( drop 1 'ncolor +! ; ) drop	| usemtl [material name]
	;

:preparse | adr --
	( trim parsecount >>cr 1? ) drop ;
	
|--------------------------------------------------	

| extrat path from string, keep in path var

::getpath | str -- str
	'path over
	( c@+ $ff and 32 >=?
		rot c!+ swap ) 2drop
	1 -
	( dup c@ $2f <>? drop
		1 - 'path <=? ( 0 'path ! drop ; )
		) drop
	0 swap 1 + c! ;
	
::loadobj | "" -- mem
	getpath
	here dup 'textobj !
	swap load over =? ( 2drop 0 ; ) 
	0 swap c!+ 'here !
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
	ntex 24 * +
	dup dup 'facel ! 'facel> ! | falta contar 4 vertices 
	nface 5 << + | 4 valores
    dup dup 'norml ! 'norml> !
	nnorm 24 * +
    dup dup 'paral ! 'paral> !
	npara 24 * +
	dup dup 'colorl ! 'colorl> !
	ncolor 1 + 4 << + | adrname id?
	'here !
|	here textobj - 10 >> "%d kb" .println
	textmtl parsemtl
	textobj parseobj
	|here textobj - 10 >> "%d kb" .println
	unusedcol
	here
	;

|------------------------------------------
##xmin ##ymin ##zmin ##xmax ##ymax ##zmax


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

::objescalax | por div --
	verl >b
	nver ( 1? 1 -
		b@ pick3 pick3 */ b!+
		8 b+ |b@ pick3 pick3 */ b!+
		8 b+ |b@ pick3 pick3 */ b!+
		8 b+
		) 3drop ;

::objescalay | por div --
	verl >b
	nver ( 1? 1 -
		8 b+ |b@ pick3 pick3 */ b!+
		b@ pick3 pick3 */ b!+
		8 b+ |b@ pick3 pick3 */ b!+
		8 b+
		) 3drop ;

::objescalaz | por div --
	verl >b
	nver ( 1? 1 -
		8 b+ |b@ pick3 pick3 */ b!+
		8 b+ |b@ pick3 pick3 */ b!+
		b@ pick3 pick3 */ b!+
		8 b+
		) 3drop ;
		

::objcube | lado --
	xmax ymax zmax max max
	xmin ymin zmin min min - | largo
	objescala
	;
