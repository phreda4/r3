| r3info with new tokenizer
| PHREDA 2024
|------------------
^r3/lib/console.r3
^r3/d4/r3token.r3

#name * 1024

|----------- SAVE INFOMAP
|	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println

:>>13 | a -- a
	( c@+ 1?
		13 =? ( drop ; ) 
		drop ) drop 1 - ;
	
:countlines | adr -- line
	0 src ( pick2 <=? 
		>>13 swap 1 + swap ) 
	drop nip ;
	
:onlywords
	dup 16 + @ 1 and? ( drop 32 + ; ) drop | variable no graba
	
	@+ countlines 1 -
	,q				| fff -nro de linea
	8 +
	@+ swap @+ 
	rot 32 << or 
	,q 				| info y mov<<32
	;
	
:savemap
	mark
	inc> 'inc -		| cantidad de includes
	dic> dic -	| cantidad de palabras
	swap 32 << or
	|,h ,cr
	,q
	
	dic< ( dic> <? | solo codigo principal
		onlywords ) drop

	"mem/srcinfo.db" savemem
	empty ;
	
:saveerr
	mark
	0 ,q
	lerror countlines 1 -
	$100000000 or
	,q
	error ,q
	"mem/srcinfo.db" savemem
	empty ;
	
|--------------------- BOOT
: 	
	"mem/srcinfo.db" delete 
	
	.cls
	'filename "mem/main.mem" load drop
|	"r3/test/testasm.r3" 'filename strcpy
	
	'filename r3load
|	'filename .println
	error 1? ( dup saveerr ; ) drop
	savemap
	;
