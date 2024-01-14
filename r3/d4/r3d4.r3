| r3 debbugger 4
| PHREDA 2024
| IDE 4 r3
|-----------------
^r3/win/console.r3
^r3/win/mconsole.r3
^r3/editor/code-print.r3

^r3/d4/r3token.r3

|--------------------------------	
|--------------------------------		
|--------------------------------	

#initok 0

:dicword | nro --
	dup "%d." ,print
	4 << dic + @
	dup "%h " ,print 
	40 >>> src + "%w" ,print
	,nl
	;
	
:showdic
	0 ( rows 4 - <?
		dup initok + 
		cntdef >=? ( 2drop ; )
		dicword
		1+ ) drop ;
	
:showmem
	fmem ( fmem> <?
		@+ "%h " ,print
		) drop 
	,nl ;
	
|---------------------
:showsrc
	src 0? ( drop ; ) >r
	235 ,bc 
	1 2 rows 10 - cols 1 - r> code-print ;

|---------------------
:showvar
	cntdef "def:%d " ,print  
	cnttok "tok:%d " ,print  
	cntstr "str:%d " ,print  
	cntblk "blk:%d " ,print  
	,nl
	;

|---------------------
:showtok | nro
	dup "%h. " ,print
	dup $ff and
	3 =? ( drop 8 >> $ffffff and strm + 34 ,c ,s 34 ,c ; ) 				| str
	4 =? ( drop 32 << 40 >> "(%d)" ,print ; )				| lit
|	5 =? ( drop 8 >> $ffffff and fmem + @ "(%d)" ,print ; ) | big lit
	drop
	40 >> src + "%w " ,print ;
	
:listtoken
	0 ( 20 <?
		dup initok + 
		cnttok >=? ( 2drop ; )
		3 << tok + 
		<<ip =? ( ">" ,print )
		@ showtok ,nl
		1+ ) drop ;

|---------------------		
:main | --
	mark
	,hidec 
	,reset ,cls ,bblue
	'filename ,s "  " ,s ,eline ,nl ,reset
	error 1? ( dup ,print ) drop ,nl
	
|	showvar 
|	showdic
|	showmem
	listtoken	
|	showsrc
	,nl
	<<ip "%h" ,print ,nl
	,stack
	
	,showc
	memsize type	| type buffer
	empty			| free buffer
	;

|--------------------------------	
#exit 0	

:evkey	
	evtkey
	$1B1001 =? ( 1 'exit ! ) | >ESC<
|	teclado 

	$3b =? ( stepvm ) |f1
	
	$50 =? ( 1 'initok +! ) 
	$48 =? ( -1 initok + 0 max 'initok ! )
	
	drop
	;
:a
|	$48 =? ( karriba ) $50 =? ( kabajo )
|	$4d =? ( kder ) $4b =? ( kizq )
|	$47 =? ( khome ) $4f =? ( kend )
|	$49 =? ( kpgup ) $51 =? ( kpgdn )
|	$3c =? ( play2cursor playvm gotosrc ) |f2
|	$3d =? ( mode!view codetoword ) | f3 word analisys
	| $3e f4
|	$3f =? ( stepvm gotosrc )	| f5
|	$40 =? ( stepvmn gotosrc )	| f6
|	$41 =? ( setbp ) | f7

|	$43 =? ( 1 statevars xor 'statevars ! ) | f9
	
;

:evmouse
	evtmb $0 =? ( drop ; ) drop 
|	evtmxy
	;

:evsize	
	.getconsoleinfo
|	rows 1 - 'hcode !
|	cols 7 - 'wcode !
	;	
	
|--------------------- BOOT
: 	
	evtmouse
	.getconsoleinfo .cls

|	'filename "mem/main.mem" load drop
|	"r3/demo/textxor.r3" 
	"r3/test/testasm.r3"
	r3load
	resetvm

	|.ovec 
	( exit 0? drop 
		main
		getevt
		$1 =? ( evkey )
		$2 =? ( evmouse )
		$4 =? ( evsize )
		drop ) 
	drop ;