| r3 debbugger 4
| PHREDA 2024
| IDE 4 r3
|-----------------
^r3/win/console.r3
^r3/win/mconsole.r3

^r3/d4/r3edit.r3
^r3/d4/r3token.r3

#wcode 40
#hcode 25

#exit 0	

:infobottom
	1 hcode 2 - ,at 
	,bblue ,white ,eline
	|" ^[7mF1^[27mRUN ^[7mF2^[27mRUN2C ^[7mF5^[27mSTEP ^[7mF6^[27mSTEPN ^[7mF7^[27mBP ^[7mF9^[27mVAR" 
	" NORMAL ^[7mTAB^[27mMODE ^[7mF1^[27mSTEP " 
	,printe ,nl
|	" info ^[7mF1^[27m " ,printe ,nl
	,reset ,bblack 
	regb rega <<ip "IP:%h RA:%h RB:%h " ,print ,nl
|	,stackprintvm 
	,stack 
	;	

|--------------- DICCIONARY
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
|	dup 8 >> $ff and "%h" ,print
	dup 8 >> 1 and " m" + c@ ,c	| /mem access
	dup 9 >> 1 and " A" + c@ ,c	| />A
	dup 10 >> 1 and " a" + c@ ,c	| /A
	dup 11 >> 1 and " B" + c@ ,c	| />B
	dup 12 >> 1 and " b" + c@ ,c	| /B

	,reset
	" " ,s
	dup 1 and 3 << 'colpal + @ ex
	|dup $3 and 1 << " ::: ###" + c@+ ,c c@ ,c
	dup 40 >>> src + "%w " ,print
	
	|dup 16 >> $ffffff and pick2 8 + @ 16 >> $ffffff and swap - "%d " ,print
	drop
	;
	
:info2 | n --
	,bwhite ,black dup ,mov 
	,reset
|	dup $ff and "%d " ,print		| duse unsigned
|	dup 48 << 56 >> "%d " ,print	| ddelta signed
	
	40 ,col
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

:keydic | key -- key
	$49 =? ( -1 'inidic +! ) 
	$51 =? ( 1 'inidic +! )
	;
		
|--------------- MEMORY
:showmem
	"mem" ,print ,nl
	fmem ( fmem> <?
		@+ "%h " ,print
		) drop 
	,nl ;
	
|--------------- SRC CODE
:showsrc
	src 0? ( drop ; ) drop
	235 ,bc 
	3 2 hcode 4 - wcode 4 - src
	code-print 
	;

:keysrc | key -- key
	code-key ;
	
|--------------- VARIABLE
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
|	dup "%h. " ,print
	dup $ff and
	1 =? ( drop 32 << 40 >> " %d" ,print ; )				| lit
|	2 =? ( "" ,print )
|	3 =? ( "" ,print )
|	4 =? ( "" ,print )
|	5 =? ( "" ,print )
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

	
:keydic	
	$1B1001 =? ( 1 'exit ! ) | >ESC<
|	teclado 
	|$9000F =? ( changemode ) | tab

|	$1B1001 =? ( 0 'nmode ! ) | >ESC<
	$3b =? ( stepvm ) |f1
	$3c =? ( pass4 ) |f2
|	$3c =? ( play2cursor playvm gotosrc ) |f2
|	$3d =? ( mode!view codetoword ) | f3 word analisys
	| $3e f4
|	$3f =? ( stepvm gotosrc )	| f5
|	$40 =? ( stepvmn gotosrc )	| f6
|	$41 =? ( setbp ) | f7
|	$43 =? ( 1 statevars xor 'statevars ! ) | f9
	;

#smode 'showsrc
#kmode 'keysrc

	
|--------------------------------	

:screen | --
	mark
	,hidec 
	,reset ,cls ,bblue
	" ^[37mr3d4 " ,printe
	'filename ,s "  " ,s ,eline ,reset
	error 1? ( dup ,bred ,print ,reset ) drop ,nl
	
	smode ex
	
	infobottom
	,showc
	memsize type	| type buffer
	empty			| free buffer
	;

	
:evkey	
	evtkey 
	$1B1001 =? ( 1 'exit ! )
	kmode ex 
	drop ;

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
	
	src code-set
	
	
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