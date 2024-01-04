^r3/win/console.r3

#test "f 46 	47 	49
f 46 	49 	50"	
#test> 0

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
	nn 20 << nt or 20 << nv or 
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