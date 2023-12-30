| r3debug
| PHREDA 2020
|------------------
^r3/system/r3parse.r3
^r3/system/r3vmd.r3
^r3/win/console.r3
^r3/win/mconsole.r3
^r3/editor/code-print.r3
^r3/system/meta/metalibs.r3

#filename * 1024

#src	| src code
#dic 	| dicctionary
#tok	| tokens
#tok>
#fmem

#boot>>
#cntdef
#cnttok
#error
#lerror

|--------------------------------
:error! | adr "" --
	'error ! 'lerror ! ;

:,t | src nro --
	over src - 32 << or
	tok> !+ 'tok> ! ;

|--------------------------------
:.inc >>cr ;
:.com >>cr ;
:.def 1 ,t >>sp ;
:.var 2 ,t >>sp ;
:.str 3 ,t >>str ;
:.nro 4 ,t >>sp ;
:.base 5 ,t >>sp ;
:.word 6 ,t >>sp ;
:.adr 7 ,t >>sp ;
:.iword 8 ,t >>sp ;
:.iadr 9 ,t >>sp ;

:?base	;
:?word	;
:?iword	;

:wrd2token | str -- str'
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1 + )	| trim0
|	over "%w " .print |** debug
	$5e =? ( drop .inc ; )	| $5e ^  Include
	$7c =? ( drop .com ; )	| $7c |	 Comentario
	$3A =? ( drop .def ; )	| $3a :  Definicion
	$23 =? ( drop .var ; )	| $23 #  Variable
	$22 =? ( drop .str ; )	| $22 "	 Cadena
	$27 =? ( drop 			| $27 ' Direccion
		|dup ?base 0 >=? ( .base ; ) drop
		1 + 
		?word 1? ( .adr ; ) drop
		?iword 1? ( .iadr ; ) drop
		1 - "Addr not exist" error!
		0 ; )
	drop
	dup isNro 1? ( drop .nro ; ) drop		| numero
	dup ?base 0 >=? ( .base ; ) drop		| base
	?word 1? ( .word ; ) drop				| palabra
	?iword 1? ( .iword ; ) drop				| palabra
 	"Word not found" error!
	0 ;

:iscom
|WIN|	"WIN|" =pre 1? ( drop 4 + ; ) drop | Compila para WINDOWS
|LIN|	"LIN|" =pre 1? ( drop 4 + ; ) drop | Compila para LINUX
|MAC|	"MAC|" =pre 1? ( drop 4 + ; ) drop | Compila para MAC
|RPI|	"RPI|" =pre 1? ( drop 4 + ; ) drop | Compila para RPI
|	"MEM" =pre 1? ( drop				| MEM 640
|		4 +
|		trim str>nro 'switchmem !
|		>>cr ; ) drop
    >>cr ;
	
:wrd2dicc
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1 + )	| trim0
	$7c =? ( drop iscom ; )	| $7c |	 Comentario
	1 'cnttok +!
|	$5e =? ( drop isinc ; )	| $5e ^  Include
	$3A =? ( 1 'cntdef +! )	| $3a :  Definicion
	$23 =? ( 1 'cntdef +! )	| $23 #  Variable
|	$28 =? ( 1 'cntblk +! )		| $28 (
|	$5b =? ( 1 'cntblk +! )		| $5b [	
	$22 =? ( drop >>str ; )	| $22 "	 Cadena
	drop >>sp
	;

:r3load | 'filename --
	0 0 error!
	
	dup 'filename strcpy
	here dup 'src !
	swap load 
	here =? ( "no source code." error! ; ) 
	0 swap c!+ 'here !
	src only13 
	
	|-- cnt
	0 'cntdef !
	0 'cnttok !
	src ( wrd2dicc 1? ) drop
	
	|-- make mem
	here 
	dup 'dic !	| dicctionary
	cntdef 3 << +	| dicc size
	dup 'tok ! 	| tokens
	dup 'tok> !
	cnttok 3 << +	| tok size
	dup 'fmem ! | memory
	'here !
	
	|-- build tok
	src ( wrd2token 1? ) drop
	;
	
|--------------------------------	
:showsrc
	src 0? ( drop ; ) >r
	235 ,bc 
	1 2 rows 10 - cols 1 - r> code-print ;

#initok 0

:listtoken
	initok
	25 ( 1? 1- swap
		dup "%d. " ,print 
		dup 3 << tok + @ 32 >> src + "%w" ,print
		,nl
		1+ swap ) 2drop ;
		
:main | --
	mark
	,hidec 
	,reset ,cls ,bblue
	'filename ,s "  " ,s ,eline ,nl ,reset
	
	listtoken	
|	showsrc
	
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
	"r3/demo/textxor.r3" r3load
	
	|.ovec 
	( exit 0? drop 
		main
		getevt
		$1 =? ( evkey )
		$2 =? ( evmouse )
		$4 =? ( evsize )
		drop ) drop ;
	;

