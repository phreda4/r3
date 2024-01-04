^r3/win/console.r3

#test "
vt -2.777953 -9.769963E-15 
vt 3.126388E-13 -2.777953 
vt 3.126388E-13 2.777953 

f 1 	29 	3
f 19 	20 	18
f 17 	18 	20
f 104 	81 	21
f 20 	28 	29
f 20 	29 	17
f 1 	2 	29"	
#test> 0

:texc	| textcoor (u, v [,w])
	
	3 + trim
	getfenro "%f " .print
	getfenro "%f " .print
	1.0 over c@ 32 >=? ( 2drop getfenro dup ) drop
	"%f " .println
	;

#nv #nt #nn 

:uface
	trim ?sint
	'nv ! dup 1 - c@
	9 <? ( drop 1 - ; ) 33 <? ( drop ; ) drop
	trim ?sint
	'nt ! dup 1 - c@
	9 <? ( drop 1 - ; ) 33 <? ( drop ; ) drop
	trim ?sint
	'nn ! dup 1 - c@
	9 <? ( drop 1 - ; ) drop
	;
	
:pack 
	nn "%d/" .print
	|20 << 
	nt "%d/" .print
	|or 20 << 
	nv 
	|or 
	"%d " .print
	; | 4 | 20 nn|20 nt | 20 nv
	
| formato normal|texture|vertice  - 20 bits c/u 
:face	| face nvert( v/t/n  v//n v/t  v)??
	>>sp trim
	| solo tres 
	uface pack
	uface pack 
	uface pack 
	.cr
	;
	
:parseline
	"f" =pre 1? ( drop face ; ) drop	| face nvert( v/t/n  v//n v/t  v)??
	"vt" =pre 1? ( drop texc ; ) drop	| textcoor (u, v [,w])
	;

::>>cr | adr -- adr'/0	; proxima linea/0
	( c@+ $ff and 13 >? drop ) 0? ( nip ; ) drop ;
	
:parseobj | text --
	( trim parseline >>cr 1? ) drop ;
	
:
.cls
"test parse float" .println
'test parseobj
waitesc
;