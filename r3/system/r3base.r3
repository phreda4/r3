| r3 base words
| PHREDA 1018
|-------------
^r3/lib/mem.r3
^r3/lib/parse.r3

^r3/system/r3parse.r3
^r3/system/r3stack.r3

##r3filename * 256
##r3path * 256

##cnttokens
##cntdef

##error
##lerror
##modo

##switchmem	10 | MEM 640 		set data memory size (in kb) min 1kb

|---- includes
| 'string|'mem
##inc * $fff
##inc> 'inc

|---------  #src
|...source
|---------	#code
|...token	#<<boot
|...		#code>
|---------	#blok
| blok info

##src
##code
##code>
##<<boot -1
##blok
##cntblk 0
##nbloques 0

|---- dicc
| str|token|info|mov  	32B /word
| 0   8     16    24	

| info
| $1 - code/data
| $2 - loc/ext

| $4	1 es usado con direccion
| $8	1 r esta desbalanceada		| var cte
| $10	0 un ; 1 varios ;
| $20	1 si es recursiva
| $40	1 si tiene anonimas
| $80	1 termina sin ;
| $100	1 inline
| $200	tiene inline dentro

|   $fff000 - calls
| $ff000000 - level/data type

| mov
| $fffff000 -- 20 bits token len
| $1ff - movs delta -16..15 uso:0..15

##dicc
##dicc>
##dicc<

#r3base
";" "(" ")" "[" "]"
"EX" "0?" "1?" "+?" "-?"
"<?" ">?" "=?" ">=?" "<=?" "<>?" "and?" "nand?" "BT?"
"DUP" "DROP" "OVER" "PICK2" "PICK3" "PICK4" "SWAP" "NIP"
"ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP"
">R" "R>" "R@"
"AND" "OR" "XOR" 
"+" "-" "*" "/"
"<<" ">>" ">>>"
"MOD" "/MOD" "*/" "*>>" "<</"
"NOT" "NEG" "ABS" "SQRT" "CLZ"
"@" "C@" "W@" "D@"
"@+" "C@+" "W@+" "D@+"
"!" "C!" "W!" "D!"
"!+" "C!+" "W!+" "D!+" |85 88
"+!" "C+!" "W+!" "D+!" 
">A" "A>" "A+" 
"A@" "A!" "A@+" "A!+"
"CA@" "CA!" "CA@+" "CA!+"
"DA@" "DA!" "DA@+" "DA!+"
">B" "B>" "B+"
"B@" "B!" "B@+" "B!+" 
"CB@" "CB!" "CB@+" "CB!+"
"DB@" "DB!" "DB@+" "DB!+" 
"MOVE" "MOVE>" "FILL"
"CMOVE" "CMOVE>" "CFILL" 
"DMOVE" "DMOVE>" "DFILL" 
"MEM"
"LOADLIB" "GETPROC"
"SYS0" "SYS1" "SYS2" "SYS3" "SYS4" "SYS5" 
"SYS6" "SYS7" "SYS8" "SYS9" "SYS10" 
( 0 )

::r3basename | nro -- str
	'r3base swap
	( 1? 1 - swap >>0 swap ) drop ;

::?base | adr -- nro/-1
	0 'r3base			| adr 0 'r3base
	( dup c@ 1? drop
		pick2 over =s 1? ( 2drop nip ; ) drop
		>>0 swap 1 + swap ) 4drop
	-1 ;

::allocdic | cnt --
	5 << here
	dup 'dicc ! dup 'dicc> ! dup 'dicc< !
	+ 'here ! ;

::adr>dic | adr -- nro
	dicc - 5 >> ;

::dic>adr | nro -- adr
	5 << dicc + ;

::dic>tok | nro -- 'tok
	dic>adr 8 + ;

::dic>inf | nro -- 'inf
	dic>adr 16 + ;

::dic>mov | nro -- 'mov
	dic>adr 24 + ;

::dic>du | nro -- delta uso
	dic>adr 24 + @
	dup	55 << 59 >>	| delta
	swap $f and ;	| uso

::dic>len@
	dic>adr 24 + @ 12 >>> ;

::adr>dicname | adr -- nadr
	adr>dic "w%h" sprint ;

::tok>dicname | nro -- nadr
	8 >>> "w%h" sprint ;

::adr>toklen | adr -- adr len
	8 + @+ swap 8 + @ 12 >>> ;

::adr>toklenreal | adr -- adr len | don't traverse many times the same code
	dup 16 + @ $80 and? ( drop adr>toklen ; ) drop | $80	1 termina sin ;
	dup 56 + @ 12 >>> swap
	adr>toklen rot - ;

::dic>toklen | nro -- adr len
	dic>adr adr>toklen ;

::dic>toklenreal | adr -- adr len
	dic>adr adr>toklenreal ;

::dic>call@ | nr -- calls
	dic>inf @ 12 >>> $fff and ;

#flagword %10

::allwords
	$ffffff 'flagword ! ;
::exportwords
	%10 'flagword ! ;

::?word | str -- str dir / str 0
	dicc> 32 -	|---largo
	( dicc >=?
		dup @ pick2			| str ind pal str
		=s 1? ( drop
			dup 16 + @
			flagword and? ( drop ; )
			drop dicc< >=? ( ; ) dup
			) drop
		32 - ) drop
	0 ;

::word!+ | info info mem name --
	dicc> !+ !+ !+ !+ 'dicc> ! ;

::wordnow | -- now
	dicc> dicc - 5 >> ;


::r3name | "" --
	dup
	'r3filename strcpy
	'r3path strcpyl
	( 'r3path >? 1 -
		dup c@ $2f | /
			=? ( drop 0 swap c! ; )
		drop ) drop
	0 'r3path !
	;

|--- dibuja movimiento pilas
| mov
| $1ff - movs delta -16..15 uso:0..15

:,ncar | n car -- car
	( swap 1? 1 - swap dup ,c 1 + ) drop ;

::,mov | mov --
	"( " ,s
	97 >r	| 'a'
	dup $f and
	dup r> ,ncar >r
	" -- " ,s
	swap 55 << 59 >> + | deltaD
	-? ( ,d r> drop " ]" ,s ; ) | error en analisis!!
	r> ,ncar drop
	" )" ,s ;

:,movx | mov --
	dup
	dup $f and "U:%d " ,print
	55 << 59 >> "D:%d " ,print
	,mov
	;


::,codeinfo | nro --
	dic>adr
	@+ ":%w  |" ,print
	@+ drop |code - 2 >> "(%h) " ,print
	@+
	dup "%h|" ,print
	dup 1 >> $1 and "le" + c@ ,c	| export/local
	dup 2 >> $1 and " '" + c@ ,c	| /adress used
	dup 3 >> $1 and " r" + c@ ,c	| /rstack mod
	dup 4 >> $1 and " ;" + c@ ,c	| /multi;
	dup 5 >> $1 and " R" + c@ ,c	| /recurse
	dup 6 >> $1 and " [" + c@ ,c	| /anon
	dup 7 >> $1 and " ." + c@ ,c	| /no ;
	dup 8 >> $1 and " i" + c@ ,c	| /inline
|	dup 9 >> $1 and " >" + c@ ,c	| /llama palabras
	dup 10 >> $1 and " I" + c@ ,c	| /inline adentro


	dup 12 >> $fff and "| calls:%d " ,print
	24 >> $ff and "niv:%d " ,print
	
	@ dup 12 >>> "len:%d " ,print
	,mov
|	$fff and " %h " ,print
	;

#datastr "val" "ddat" "dcod" "str" "lval" "lddat" "ldcod" "lstr" "multi" "buff"

::datatype | nro -- str
	'datastr swap ( 0 <>? 1 - swap >>0 swap ) drop ;

::,datainfo | nro --
	dic>adr
	@+ "#%w " ,print
	@+ drop |code - 2 >> "(%h) " ,print
	@+
	dup 1 >> $1 and "le" + c@ ,c	| export/local
	dup 2 >> $1 and " '" + c@ ,c	| /adress used
	dup 3 >> $1 and " c" + c@ ,c	| cte

	dup 12 >> $fff and "calls:%d " ,print
	" type:" ,s
	24 >> $f and datatype ,s

	@ dup 12 >>> " len:%d " ,print
	$fff and " %h " ,print
	;

::,wordinfo
	dup dic>adr 16 + @
	$1 nand? ( drop ,codeinfo ; )
	drop ,datainfo ;

|--------------------
:val 8 >>> ;

:valstr
	8 >>> src +
	( c@+ 1?
		34 =? ( drop c@+ 34 <>? ( 2drop ; ) dup ,c )
		,c )
	2drop ;

:tn val src + ,w ;
:ts """" ,s valstr """" ,s ;
:tw val dic>adr @ ,w ;
:taw val dic>adr @ "'" ,s ,w ;

#ltok 0 0 0 0 0 0 0 tn tn tn tn ts tw tw taw taw

::,tokenprint | nro --
	dup $ff and
	15 >? ( 16 - r3basename ,s drop ; )
	3 << 'ltok + @ ex ;

|-------------------- print code converted for run
:nil drop 0 ,d ;
:td 8 >> ,d ;
:tb "%" ,s 8 >> ,b ;
:th "$" ,s 8 >> ,h ;
:tf 8 >> ,f ;

|*** big version, not done
:tdb 8 >> ,d ;
:tbb "%" ,s 8 >> ,b ;
:thb "$" ,s 8 >> ,h ;
:tfb 8 >> ,f ;

#ltok nil tdb tbb thb tfb 0 tw td tb th tf ts tw tw taw taw

::,tokenprintc
	dup $ff and
	15 >? ( 16 - r3basename ,s drop ; )
	3 << 'ltok + @ ex ;

|--------------------
:tn val src + ,w ;
:tw val "w" ,s ,h ;
:taw val "'w" ,s ,h ;

#ltok 0 0 0 0 0 0 0 tn tn tn tn ts tw tw taw taw

::,tokenprintn | nro --
	dup $ff and 
	15 >? ( 16 - r3basename ,s drop ; )
	3 << 'ltok + @ 0? ( 2drop ; )
	ex ;

|--------------------
:col_str .white ;
:col_adr .cyan ;
:col_nor .green ;
:col_nro .yellow ;

:val 8 >>> ;

:valstr
	8 >>> src +
	( c@+ 1?
		34 =? ( drop c@+ 34 <>? ( 2drop ; ) dup emit )
		emit )
	2drop ;

:tn col_nro val src + "%w" .print ;
:ts col_str """" .print valstr """" .print ;
:tw col_nor val dic>adr @ "%w" .print ;
:taw col_adr val dic>adr @ "'%w" .print ;

:tnx col_nro 8 >> "%d" .print ;

#ltok 0 0 0 0 0 0 0 tn tn tn tnx ts tw tw taw taw

::tokenprint | nro --
	dup $ff and
	15 >? ( 16 - r3basename col_nor .print drop ; )
	3 << 'ltok + @ 0? ( 2drop ; )
	ex
	;

|--------------------
:td col_nro 8 >> "%d" .print ;
:tb col_nro 8 >> "%%%b" .print ;
:th col_nro 8 >> "$%h" .print ;
:tf col_nro 8 >> "%f" .print ;

|*** big version, not done
:tdb col_nro 8 >> "%d" .print ;
:tbb col_nro 8 >> "%%%b" .print ;
:thb col_nro 8 >> "$%h" .print ;
:tfb col_nro 8 >> "%f" .print ;

:ts col_str 8 >> blok + 34 emit .print 34 emit ;

:nil drop "nil" .print ;

#ltok nil tdb tbb thb tfb 0 tw td tb th tf ts tw tw taw taw

::tokenprintc
	dup $ff and
	15 >? ( 16 - r3basename col_nor .print drop ; )
	3 << 'ltok + @ ex ;

|------------- DEBUG
::debuginc
	'inc ( inc> <?
		@+ swap @+
		rot "%l %h" .println
		) drop ;

::debugdicc
	dicc ( dicc> <? dup >a
		a@+ a@+ a@+ a@+ 2swap swap
		"%w %h %h %h" .println
		32 +
		) drop ;

::debugcode
	code ( code> <?
		dup "%h:" .print 
		d@+ dup "%h " .print
		tokenprint 
		cr ) drop ;
		
|------------- FILE
::savedicc
	mark
	dicc> dicc - 5 >> ,d
	dicc ( dicc> <?
		@+ , @+ , @+ , @+ ,
		) drop
	"mem/dicc.db" savemem
	empty
	;

::savecode
	mark
	<<boot src - ,
	here src code> over - cmove
	code> over - 'here +!
	"mem/code.db" savemem
	empty
	;