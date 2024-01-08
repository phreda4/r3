| r3debug
| PHREDA 2020
|------------------
^r3/lib/parse.r3
^r3/system/r3vmd.r3
^r3/win/console.r3
^r3/win/mconsole.r3
^r3/editor/code-print.r3
^r3/system/meta/metalibs.r3

#filename * 1024

#src	| src code
#dic 	| dicctionary
#dic>
#tok	| tokens
#tok>
#strm	| string
#strm>
#fmem	| var + freemem
#fmem>

#boot>>

#cntdef
#cnttok
#cntstr
#cntblk

#error
#lerror

#state
#flag
#datac

|--------------------------------
:error! | adr "" --
	'error ! 'lerror ! ;

#sst * 256 	| stack of blocks
#sst> 'sst
:sst!	sst> w!+ 'sst> ! ;
:sst@   -2 'sst> +! sst> w@ ;
:level 	sst> 'sst xor ;	

|-------------------------------- 1pass
:iscom | adr -- 'adr
|WIN|	"WIN|" =pre 1? ( drop 4 + ; ) drop | Compila para WINDOWS
|LIN|	"LIN|" =pre 1? ( drop 4 + ; ) drop | Compila para LINUX
|MAC|	"MAC|" =pre 1? ( drop 4 + ; ) drop | Compila para MAC
|RPI|	"RPI|" =pre 1? ( drop 4 + ; ) drop | Compila para RPI
|	"MEM" =pre 1? ( drop				| MEM 640
|		4 +
|		trim str>nro 'switchmem !
|		>>cr ; ) drop
    >>cr ;
	
:isstr | adr -- 'adr
	1+ ( c@+ 1? 
		1 'cntstr +! 
		34 =? ( drop c@+ 34 <>? ( drop 1- ; ) ) 
		drop ) drop 
	dup 1- "str not close" error!
	;
	
:wrd2dicc
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1+ )	| trim0
	$7c =? ( drop iscom ; )	| $7c |	 Comentario
|	$5e =? ( drop isinc ; )	| $5e ^  Include
	$3A =? ( drop 1 'cntdef +! >>sp ; )	| $3a :  Definicion
	$23 =? ( drop 1 'cntdef +! >>sp ; )	| $23 #  Variable
	1 'cnttok +!
	$28 =? ( over 1+ c@ 33 <? ( 1 'cntblk +! ) drop )		| $28 (_
	$5b =? ( over 1+ c@ 33 <? ( 1 'cntblk +! ) drop )		| $5b [_
	$22 =? ( drop isstr ; )	| $22 "	 Cadena
	drop >>sp
	;

|-------------------------------- 2pass
#r3base
";" "(" ")" "[" "]" "EX" "0?" "1?" "+?" "-?"
"<?" ">?" "=?" ">=?" "<=?" "<>?" "AND?" "NAND?" "BT?"
"DUP" "DROP" "OVER" "PICK2" "PICK3" "PICK4" "SWAP" "NIP"
"ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP"
">R" "R>" "R@" "AND" "OR" "XOR" "+" "-" "*" "/" "<<" ">>" ">>>"
"MOD" "/MOD" "*/" "*>>" "<</" "NOT" "NEG" "ABS" "SQRT" "CLZ"
"@" "C@" "W@" "D@" "@+" "C@+" "W@+" "D@+"
"!" "C!" "W!" "D!" "!+" "C!+" "W!+" "D!+" 
"+!" "C+!" "W+!" "D+!" 
">A" "A>" "A+" "A@" "A!" "A@+" "A!+" "CA@" "CA!" "CA@+" "CA!+" "DA@" "DA!" "DA@+" "DA!+"
">B" "B>" "B+" "B@" "B!" "B@+" "B!+" "CB@" "CB!" "CB@+" "CB!+" "DB@" "DB!" "DB@+" "DB!+" 
"MOVE" "MOVE>" "FILL" "CMOVE" "CMOVE>" "CFILL" "DMOVE" "DMOVE>" "DFILL" 
"MEM" "LOADLIB" "GETPROC"
"SYS0" "SYS1" "SYS2" "SYS3" "SYS4" "SYS5" "SYS6" "SYS7" "SYS8" "SYS9" "SYS10" 
( 0 )

:,t | src nro --
	over src - 40 << or
	tok> !+ 'tok> ! ;

:.inc >>cr ;
:.com >>cr ;

|------- data
:,dataq | nro --
	fmem> !+ 'fmem> ! ;
:,datad | nro --
	fmem> d!+ 'fmem> ! ;
:,datab | nro --
	fmem> c!+ 'fmem> ! ;
:,datat | nro --
	'fmem> +! ;
	
#,dtipo	

:invarstr
	1 'datac +!
	fmem> >a
	1+ ( c@+ 1? 
		dup ca!+
		34 =? ( drop c@+ 
			34 <>? ( 2drop 0 a> 1- c!+ 'fmem> ! ; ) 
			) drop 
		) drop 
	"unfinish str" error!
	;

:invarnro
	1 'datac +!
	str>anro ,dtipo ex ;

:invarbase | adr nro -- adr
	1 =? ( drop ',datab ',dtipo ! ; )	| (
	2 =? ( drop ',dataq ',dtipo ! ; )	| )
	3 =? ( drop ',datad ',dtipo ! ; )	| [
	4 =? ( drop ',dataq ',dtipo ! ; )	| ]
	42 =? ( drop ',dataq ',dtipo ! ; )	| *
	drop
	"base in var" error!
	;

|------- code
:dic>name | dic -- dic str
	dup @ 40 >> src + ;
	
:endef
	level 1? ( over "bad Block ( )" error! ) drop
	state 2 <>? ( drop ; ) drop
	datac 1? ( drop ; ) drop
	0 ,dataq
	;

:.def 
	endef
	0 'flag !
	dup 1+ c@
	$3A =? ( 2 'flag ! ) |::
	33 <? ( tok> tok - 3 >> 'boot>> ! ) 
	drop
	
	dup src - 40 <<
	tok> tok - 3 >> 8 << or
	flag or
	dic> !+ 'dic> !

	1 'state ! >>sp ;
	
:.var 
	endef
	1 'flag !
	dup 1+ c@
	$23 =? ( 3 'flag ! ) |##
	drop
	
	dup src - 40 <<
	fmem> fmem - 8 << or
	flag or
	dic> !+ 'dic> !
	',dataq ',dtipo !
	0 'datac !
	2 'state ! >>sp ;

	
:.str 
	state 2 =? ( drop invarstr ; ) drop
	strm> strm - 8 << 3 or ,t 
	strm> >a
	1+ ( c@+ 1? 
		dup ca!+
		34 =? ( drop c@+ 
			34 <>? ( drop 0 a> 1- c!+ 'strm> ! 1- ; ) 
			) drop 
		) drop 1 - ;
		
		
:.nro 
	state 2 =? ( drop invarnro ; ) drop
	str>anro 
	dup 40 << 40 >> =? ( 
		$ffffff and 8 << 4 or ,t 
		>>sp ; ) drop
	5 or ,t | in SRC
	>>sp ;
	
:.base | adr nro -- adr
	state 2 =? ( drop invarbase ; ) drop	
|	0 =? (  )  | ;
|	1 =? ( blockIn )	| (
|	2 =? ( blockOut )	| )
|	3 =? ( anonIn )		| [
|	4 =? ( anonOut )	| ]
	8 +
	,t >>sp ;
	
:.word | adr nro -- adr
	8 << 6 or ,t >>sp ;
	
:.adr | adr nro -- adr
	8 << 7 or ,t >>sp ;
	
:.iword | adr nro -- adr
	8 << 8 or ,t >>sp ;
	
:.iadr | adr nro -- adr
	8 << 9 or ,t >>sp ;


:?base | adr -- nro+1/0
	0 'r3base			| adr 0 'r3base
	( dup c@ 1? drop
		pick2 over =s 1? ( 2drop nip 1+ ; ) drop
		>>0 swap 1+ swap ) 4drop
	0 ;

:?word | adr -- adr nro+1/0
	dic> 8 -
	( dic >=?
		dic>name pick2			| str ind pal str
		=s 1? ( drop
|			drop dicc< >=? ( ; ) dup | export
			dic> - 3 >> ;
			) drop
		8 - ) drop
	0 ;
	

:?iword	
	1
	;

:wrd2token | str -- str'
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1+ )	| trim0
	over "%w " .print |** debug
	$5e =? ( drop .inc ; )	| $5e ^  Include
	$7c =? ( drop .com ; )	| $7c |	 Comentario
	$3A =? ( drop .def ; )	| $3a :  Definicion
	$23 =? ( drop .var ; )	| $23 #  Variable
	$22 =? ( drop .str ; )	| $22 "	 Cadena
	$27 =? ( drop 			| $27 ' Direccion
		|dup ?base 1? ( drop "No Addr for base dicc" error! ; ) drop
		1+ 
		?word 1? ( .adr ; ) drop
		?iword 1? ( .iadr ; ) drop
		1- "Addr not exist" error!
		0 ; )
	drop
	dup isNro 1? ( drop .nro ; ) drop	| numero
	dup ?base 1? ( .base ; ) drop		| base
	?word 1? ( .word ; ) drop			| palabra
	?iword 1? ( .iword ; ) drop			| palabra
 	"Word not found" error!
	0 ;


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
	0 'cntstr !
	|--- 1 pass
	0 'state !
	src ( wrd2dicc 1? ) drop	
	lerror 1? ( drop ; ) drop | cut if error
	
	|-- make mem
	here 
	dup 'dic ! dup 'dic> !		| dicctionary
	cntdef 3 << +				| dicc size
	dup 'tok ! dup 'tok> !		| tokens 
	cnttok 3 << +				| tok size
	dup 'strm ! dup 'strm> ! 	| strings
	cntstr +					| str size
	dup 'fmem ! dup 'fmem> ! 	| memory const+var+free
	'here !
	
	|--- 2 pass
	0 'state !
	src ( wrd2token 1? ) drop	
	;
	
|--------------------------------	
:dicword | nro --
	3 << dic + @
	"%h" ,print ,nl
	;
	
:showdic
	0 ( cntdef <? 
		dup dicword
		1+ ) drop 
	,nl ;
	
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
#initok 0

:showtok | nro
	dup "%h. " ,print
	dup $ff and
	3 =? ( drop 8 >> $ffffff and strm + ,s ; ) 				| str
	4 =? ( drop 32 << 40 >> "(%d)" ,print ; )				| lit
|	5 =? ( drop 8 >> $ffffff and fmem + @ "(%d)" ,print ; ) | big lit
	drop
	40 >> src + "%w " ,print ;
	
:listtoken
	0 ( rows 4 - <?
		dup initok + 
		cnttok >=? ( 2drop ; )
		3 << tok + @ 
		showtok ,nl
		1+ ) drop ;

|---------------------		
:main | --
	mark
	,hidec 
	,reset ,cls ,bblue
	'filename ,s "  " ,s ,eline ,nl ,reset
	error 1? ( dup ,print ) drop ,nl
	
|	showvar 
	showdic
	showmem
|	listtoken	
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
	$50 =? ( 1 'initok +! ) 
	$48 =? ( -1 initok + 0 max 'initok ! )
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
		drop ) drop 
	;

