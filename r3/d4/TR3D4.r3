| r3 debbugger 4
| PHREDA 2024
| IDE 4 r3
|-----------------
^r3/lib/console.r3

^r3/d4/r3view.r3
^r3/d4/r3token.r3

#wcode 40
#hcode 25

#exit 0	

:infobottom
	1 hcode 2 - .at 
	.bblue .white .eline
	|" ^[7mF1^[27mRUN ^[7mF2^[27mRUN2C ^[7mF5^[27mSTEP ^[7mF6^[27mSTEPN ^[7mF7^[27mBP ^[7mF9^[27mVAR" 
	" DEBUG ^[7mTAB^[27mMODE ^[7mF1^[27mSTEP " 
	.printe .nl
|	" info ^[7mF1^[27m " ,printe ,nl
	.reset .bblack 
	regb rega <<ip "IP:%h RA:%h RB:%h " .print .nl
|	,stackprintvm 
	,stack 
	;	

|--------------- DICCIONARY
#inidic 0

#colpal .red .magenta


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
		cntdef 1 - >=? ( 2drop ; )
		dicword
		1+ ) drop ;

:keydic | key -- key
	[up] =? ( -1 'inidic +! ) 
	[dn] =? ( 1 'inidic +! )
	;
		
|--------------- MEMORY
:showmem
	"mem" ,print ,nl
	fmem ( fmem> <?
		@+ "%h " ,print
		) drop 
	,nl ;
	
	
|--------------- SRC CODE
:cursor2ip  
	<<ip 0? ( drop ; )
	@ 40 >>> src + 'fuente> ! ;
	
:showsrc
	src 0? ( drop ; ) drop
	code-draw
	;

:keysrc | key -- key
	code-key
	[f1] =? ( stepvm cursor2ip ) |f1
	[f2] =? ( stepvmn cursor2ip ) |f2
	;
	
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

|--------------- TOKENS
#initok 0

:showtok | nro
	dup "%h. " ,print
	dup $ff and
	1 =? ( drop 24 << 40 >> " %d" ,print ; )				| lit
	6 =? ( drop 8 >> $ffffff and strm + 34 ,c ,s 34 ,c ; ) 	| str
	drop
	40 >> src + "%w " ,print ;
	
:listtok
	0 ( 18 <?
		dup initok + 
		cnttok >=? ( 2drop ; )
		3 << tok + 
		<<ip =? ( "s" ,[ "> " ,print ) | save cursor position 
		@ showtok ,nl
		1+ ) drop ;

	
:keytok
|	$1B1001 =? ( 0 'nmode ! ) | >ESC<
	[f1] =? ( stepvm ) |f1
|	$3c =? ( play2cursor playvm gotosrc ) |f2
|	$3d =? ( mode!view codetoword ) | f3 word analisys
	| $3e f4
|	$3f =? ( stepvm gotosrc )	| f5
|	$40 =? ( stepvmn gotosrc )	| f6
|	$41 =? ( setbp ) | f7
|	$43 =? ( 1 statevars xor 'statevars ! ) | f9
	[up] =? ( -1 'initok +! ) 
	[dn] =? ( 1 'initok +! )
	;

|---------------------------------------------------
#smode 'showsrc
#kmode 'keysrc
#nmode 0

#slist 'showsrc 'listtok 'showdic
#klist 'keysrc 'keytok 'keydic 

:changemode
	nmode 1 + 2 >? ( 0 nip )
	dup 'nmode !
	3 <<
	dup 'slist + @ 'smode !
	'klist + @ 'kmode !
	;

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
	"u" ,[ ,showc	| restore cursor pos, show cursor
	memsize type	| type buffer
	empty			| free buffer
	;


:evsize	
	.getconsoleinfo
	rows 1 - 'hcode !
	cols 8 - 'wcode !
	;	

:teclado
	getch
	]esc[ =? ( drop 1 'exit ! ; )
	[tab] =? ( drop changemode ; ) | tab
|	$1d =? ( controlon ) 
	kmode ex 
	drop ;

:bucle
	( exit 0? drop 
		screen
		teclado	
		) drop ;
	
|--------------------- BOOT
: 	
	evsize
	.cls

|	'filename "mem/main.mem" load drop
|	"r3/demo/textxor.r3" 
|	"r3/democ/palindrome.r3" 
	"r3/test/testasm.r3"
	r3load
	src code-set
	
	resetvm
	cursor2ip  
	
	cntdef 18 - 0 max 'inidic !
	cnttok 18 - 0 max 'initok !
	|.ovec 
	bucle
	;
	
	