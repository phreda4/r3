| r3 win compiler - d4 version
| PHREDA 2026
|------------------
^r3/lib/console.r3

^r3/d4/r3token.r3
|^r3/d4/genx64.r3

#filename * 1024

|------------------ CODE
:codew | nro -- nro
	dup nro>dic @ 1 and? ( drop ; ) | only code
	
	dic>name "; --- :%w " ,print ,cr
	
	dup nro>dic toklen | nro adr len
	( 1? 1- swap
		d@+ "$%h " ,print
		swap ) 2drop
	,cr		
	;	
	
:generatecode	
	mark
	";---r3 code" ,print ,cr

	0 ( cntdef 1- <?
		codew
		1+ )
	";-----BOOT-----" ,s ,cr
	codew drop
	0 ,c
	"asm/code.asm"
	savemem 
	empty ;

|------------------ DATA
#d1 "dq " #d2 "dd " #d3	"db " #d4 "rb "
#dtipo 'd1
#dini 0 #dcnt 0 #instr 0

:tok>dicn | nro -- adr
	dup 4 << dic + @ dic>name "%w" sprint ;

:tok>cte | tok -- nro
	40 >>> src +
	dup ?numero 1? ( drop nip nip ; ) drop
	str>fnro nip ;

:tok>str | tok -- str
	8 >> $ffffffff and strm + ;

:pasoinstr	| cuando hay un string en otro tipo
	,cr dtipo ,s 0 'dini ! 0 'instr ! ;

:stringdd | cuando hay string dentro de otro tipo
	dtipo 'd3 =? ( drop "," ,s ; ) drop
	,cr 'd3 ,s 1 'instr !
|	'd3 'dtipo !
	;

:dfin
	instr 1? ( drop pasoinstr ; ) drop
	dini 0 'dini ! 1? ( drop dtipo ,s ; )
	drop "," ,s ;
:dfins
	dini 0? ( drop stringdd ; ) drop
	'd3 ,s 0 'dini ! ;
:dfind
	instr 1? ( drop pasoinstr ; ) drop
	dini 0 'dini ! 1? ( 'd1 ,s drop ; ) "," ,s drop  ;

:dtipoch
	dini 1? ( drop ; ) drop
	,cr 1 'dini ! ;

:cpycad | adr --
	( c@+ 1? 34 =? ( dup ,c ) ,c ) 2drop ;
	
:cpycadsrc | adr --
	( c@+ 1? 
		34 =? ( drop c@+ 
			34 <>? ( 2drop ; )
			"""," ,s dup ,d "," ,s
			) 
		$ff and 32 <? ( """," ,s ,d "," ,s 34 ) | not print char
		,c ) 2drop ;

:stringwith0 | str --
	34 ,c here swap cpycadsrc here - 34 ,c drop ",0" ,s ;

:,ddefw
:,ddefv drop ;

:,dlit  1 'dcnt +! dfin 
|		dcnt $f and $f =? ( ,cr ) drop	| every 16
		tok>cte
		-? ( ,d ; ) "$" ,s ,h ;

:,dlits	1 'dcnt +! dfins 
		tok>str
		stringwith0 ;

:,dwor	1 'dcnt +! dfind
		tok>dicn
		,s ;

:,d;	drop ;

:,d(	drop 'd3 'dtipo ! dtipoch ;
:,d)	drop 'd1 'dtipo ! dtipoch ;
:,d[	drop 'd2 'dtipo ! dtipoch ;
:,d]	drop 'd1 'dtipo ! dtipoch ;

:,d*	'd4 'dtipo ! dtipoch ;

#coded ,dlit ,dlit ,dwor ,dwor ,dwor ,dwor ,dlits ,d; ,d( ,d) ,d[ ,d]

|----- data
:datastep
	dup $ff and
	12 <? ( 3 << 'coded + @ ex ; )
	51 =? ( ,d* ) | token * antes 51
	2drop  | vacio
	;

:gendata | nro -- nro
	dup 4 << dic + @ 1 nand? ( drop ; ) | only data
	
	'd1 'dtipo !
	1 'dini !
	0 'dcnt !
	0 'instr !

|    ";--------------------------" ,s ,cr

    "; " ,s |dup dicc - 5 >> ,datainfo ,cr
	dup dic>name ,s ,sp
	
	dup nro>dic toklend | nro adr len	
	( 1? 1- swap
		d@+ datastep
		swap ) 2drop
	dini 0? ( drop ,cr ; ) drop
	dcnt 1? ( drop ,cr ; ) drop
	dtipo ,s 0 ,d ,cr
	;

	
|----- string
:otrostr | token btoken -- token btoken
	1 'dini !
	over 8 >> $ffffffff and "str%h " ,print
	over ,dlits
	,cr ;
	
:gendatastr | adr --
	dup 4 << dic + @ 1 nand? ( drop ; ) | only code
	dup nro>dic toklen | nro adr len
	( 1? 1- swap
		d@+ dup 
		$ff and 6 =? ( otrostr ) 2drop
		swap ) 2drop
	,cr
	;
		
:generatedata
	mark
	";---r3 compiler data.asm" ,print ,cr
	"; *** STRINGS ***" ,s ,cr

	0 ( cntdef <?
		gendatastr
		1+ ) drop

	"; *** VARS ***" ,s ,cr
	"align 16 " ,s ,cr
	0 ( cntdef <?
		gendata
		1+ ) drop
	0 ,c
	"asm/data.asm"
	savemem 
	empty ;
	
|------------------ SETS
:generatesets
	mark
	";---r3 setings" ,print ,cr
	switchmem 20 << "MEMSIZE equ 0x%h" ,print ,cr
	"VEROPT equ 1" ,print ,cr | version OPT
	0 ,c
	"asm/set.asm"
	savemem 
	empty ;

|------------------ MAIN
:compiling..
	generatecode 
	generatedata
|	generatesets
	;
	
:
	.reset 
	"Win64 Compiler" .println
	
	|'filename "mem/menu.mem" load drop
	"r3/d4/gen/plain.r3" 'filename strcpy
	
	" compiling " .write 'filename .write "..." .println
	'filename r3load
	error 0? ( compiling.. ) drop
	
|	"asm\compile.bat" sys
|	"r3fasm.exe" sys
	.cr
	
	"press any key to continue..." .print
	waitkey
	;

