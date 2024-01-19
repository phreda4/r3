| r3 debbugger 4
| PHREDA 2024
| IDE 4 r3
|-----------------
^r3/win/console.r3
^r3/win/mconsole.r3
^r3/editor/code-print.r3

^r3/d4/r3token.r3

|--------------------------------	
| DICCIONARY LIST
| info1
| $..............01 - code/data
| $..............02 - loc/ext
| $..............04	1 es usado con direccion
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva
| $..............40	1 si tiene anonimas
| $..............80	1 termina sin ;
| $............ff.. flag2
| $......ffffff....	-> tok+ -> code
| $ffffff.......... -> src+ -> src
|
| info2
| $..............ff - Data use		255
| $............ff.. - Data delta	-128..127
| $.........fff.... - calls			1024+
| $........f....... - +info: inline,constant,exec,only stack
| $ffffffff........ - len
|--------------------------------	

#wcode 40
#hcode 25

#inidic 0

#colpal ,red ,magenta

::,col "%dG" sprint ,[ ; | x y -- 

:info1 | n --
	|dup "%h " ,print
	,bblue
	dup 1 and ":#" + c@ ,c		| code/data
	dup 1 >> 1 and " e" + c@ ,c	| local/export
	dup 2 >> 1 and " '" + c@ ,c	| /use adress
	dup 3 >> 1 and " >" + c@ ,c	| /R unbalanced
	dup 4 >> 1 and " ;" + c@ ,c	| /many exit
	dup 5 >> 1 and " R" + c@ ,c	| /recursive
	dup 6 >> 1 and " [" + c@ ,c	| /have anon
	dup 7 >> 1 and " ." + c@ ,c	| /not end
	dup 8 >> $ff and "%h" ,print
|	dup 8 >> 1 and " ." + c@ ,c	| /not end
	,reset
	" " ,s
	dup 1 and 3 << 'colpal + @ ex
	|dup $3 and 1 << " ::: ###" + c@+ ,c c@ ,c
	dup 40 >>> src + "%w " ,print
	
	|dup 16 >> $ffffff and pick2 8 + @ 16 >> $ffffff and swap - "%d " ,print
	drop
	;
:info2 | n --
	,reset
	40 ,col
	dup $ff and "%d " ,print		| duse unsigned
	dup 48 << 56 >> "%d " ,print	| ddelta signed
	 9 ,c
	dup 16 >> $ffff and "%d " ,print	| calls
	 9 ,c
	dup 32 >> " %d " ,print			| len
	drop
|	dup @ 16 >> $ffffff and over 16 - @ 16 >> $ffffff and - "%d " ,print
	dup 16 - toklend nip " %d" ,print | len for data
	;
:dicword | nro --
	,reset
	dup "%d." ,print
	4 << dic + 
	@+ info1
	@+ info2
	drop
	,nl
	;
	
:showdic
	0 ( 20 <?
		dup inidic + 
		cntdef >=? ( 2drop ; )
		dicword
		1+ ) drop ;
		
|--------------------------------			
:showmem
	"mem" ,print ,nl
	fmem ( fmem> <?
		@+ "%h " ,print
		) drop 
	,nl ;
	
|---------------------
:showsrc
	src 0? ( drop ; ) >r
	235 ,bc 
	3 2 hcode 4 - wcode 4 - r> code-print ;
	
|---------------------
:showvar
	cntdef "def:%d" ,print  
	dic> dic - 4 >> "(%d) " ,print
	cnttok "tok:%d" ,print  
	tok> tok - 3 >> "(%d) " ,print
	cntstr "str:%d" ,print  
	strm> strm - "(%d) " ,print

	fmem> fmem - "m:%d" ,print
	,nl
	;

|---------------------
#initok 0

:showtok | nro
	dup "%h. " ,print
	dup $ff and
	1 =? ( drop 32 << 40 >> " %d" ,print ; )				| lit
	2 =? ( "w " ,print )
	3 =? ( "wa " ,print )
	4 =? ( "v " ,print )
	5 =? ( "va " ,print )
	6 =? ( drop 8 >> $ffffff and strm + 34 ,c ,s 34 ,c ; ) 	| str
	drop
	40 >> src + "%w " ,print ;
	
:listtoken
	0 ( 18 <?
		dup initok + 
		cnttok >=? ( 2drop ; )
		3 << tok + 
		<<ip =? ( "> " ,print )
		@ showtok ,nl
		1+ ) drop ;

|--------------------------------	
#exit 0	
#mode 0

:infobottom
	1 hcode 2 - ,at 
	,bblue ,white ,eline
	|" ^[7mF1^[27mRUN ^[7mF2^[27mRUN2C ^[7mF5^[27mSTEP ^[7mF6^[27mSTEPN ^[7mF7^[27mBP ^[7mF9^[27mVAR" 
	" ^[7mTAB^[27mMODE ^[7mF1^[27mSTEP " 
	,printe ,nl
|	" info ^[7mF1^[27m " ,printe ,nl
	,reset ,bblack 
	regb rega <<ip "IP:%h RA:%h RB:%h " ,print ,nl
|	,stackprintvm 
	,stack 

	;	

:screen | --
	mark
	,hidec 
	,reset ,cls ,bblue
	"^[37mr3d4 " ,printe
	'filename ,s "  " ,s ,eline ,nl ,reset
	
	error 1? ( dup ,bred ,print ,reset ) drop ,nl
	
	mode
	0 =? ( showvar showdic )
	1 =? ( showvar listtoken )
	2 =? ( showsrc )
	drop
|	
|	showmem
|	,nl
|	<<ip "%h" ,print ,nl
	infobottom
	,showc
	memsize type	| type buffer
	empty			| free buffer
	;

:changemode
	mode 1 + 2 >? ( 0 nip ) 'mode !
	;
	
:evkey	
	evtkey
	$1B1001 =? ( 1 'exit ! ) | >ESC<
|	teclado 

	$3b =? ( stepvm ) |f1
	
	$50 =? ( 1 'initok +! ) 
	$48 =? ( -1 initok + 0 max 'initok ! )
	
	$49 =? ( -1 'inidic +! ) 
	$51 =? ( 1 'inidic +! )
	
	$9000F =? ( changemode ) | tab
	drop
	;
:a
|	$48 =? ( karriba ) $50 =? ( kabajo )
|	$4d =? ( kder ) $4b =? ( kizq )
|	$47 =? ( khome ) $4f =? ( kend )
|	$49 =? ( kpgup ) $51 =? ( kpgdn\ )
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
	rows 1 - 'hcode !
	cols 7 - 'wcode !
	;	
	
|--------------------- BOOT
: 	
	evtmouse
	evsize
	.cls

|	'filename "mem/main.mem" load drop
|	"r3/demo/textxor.r3" 
|	"r3/democ/palindrome.r3" 
	"r3/test/testasm.r3"
	r3load
	
	resetvm
	
	cntdef 18 - 0 max 'inidic !
	cnttok 18 - 0 max 'initok !
	|.ovec 
	( exit 0? drop 
		screen
		getevt
		$1 =? ( evkey )
		$2 =? ( evmouse )
		$4 =? ( evsize )
		drop ) 
	drop ;