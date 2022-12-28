| r3debug
| PHREDA 2020
|------------------
^r3/win/console.r3
^r3/win/mconsole.r3

^r3/system/r3base.r3
^r3/system/r3pass1.r3
^r3/system/r3pass2.r3
^r3/system/r3pass3.r3
^r3/system/r3pass4.r3

^r3/system/r3vm.r3

#ckey 
#name * 1024
#namenow * 256

#linecomm 
#linecomm>

::r3debuginfo | str --
	r3name
	here dup 'src !
	'r3filename
|	dup "load %s" .println
	2dup load			|	"load" slog
	here =? ( "no source code." .println  ; )
	src only13 0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	swap	
	r3-stage-1 error 1? ( "ERROR %s" .println lerror "%l" .println ; ) drop	
|	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println
	
	r3-stage-2 1? ( drop ; ) drop 		
	r3-stage-3			
	r3-stage-4			
	
|	debugmemtoken waitesc
	;

:savedebug
	mark
	error ,s ,cr
	lerror src - ,d ,cr
	"mem/debuginfo.db" savemem
	empty ;

:emptyerror
 	0 0	"mem/debuginfo.db" save ;

|-----------------------------
#emode

#xcode 6
#ycode 2
#wcode 40
#hcode 25

|------ MODES

:mode!imm
	0 'emode !
	rows 7 - 'hcode !
	cols 1 >> 'wcode !
	;

:mode!view
	1 'emode !
	rows 2 - 'hcode !
	cols 7 - 'wcode !
	;

|------ MEMORY VIEW
#actword 0
#iniword 0

#initok
#cnttok
#nowtok
#pagtok

#incnow

| includes list with cursor in actual
:incmap
	0 ( cntinc <?
		40 over 2 + ,at
		incnow =? ( ,rever )
		dup "%d " ,print
		dup 4 << 'inc + @+ swap @ "%h %l" ,print
		incnow =? ( ,reset )
		1 + ) drop 
	;

:wordanalysis
	actword dic>toklen
	'cnttok !
	'initok !
	0 'nowtok !
	0 'pagtok !
	;

:val 8 >>> ;

:valstr
	8 >>> src +
	( c@+ 1?
		34 =? ( drop c@+ 34 <>? ( 2drop ; ) dup ,c )
		,c )
	2drop ;
	
:tn 13 ,fcolor val src + ,w ;
:ts 15 ,fcolor """" ,s valstr """" ,s ;
:tw 10 ,fcolor val dic>adr @ ,w ;
:taw 14 ,fcolor val dic>adr @ "'" ,s ,w ;

:nil drop 0 ,d ;
:td 11 ,fcolor 8 >> ,d ;
:tb 11 ,fcolor "%" ,s 8 >> ,b ;
:th 11 ,fcolor "$" ,s 8 >> ,h ;
:tf 11 ,fcolor 8 >> ,f ;

|*** big version, not done
:tdb 8 >> ,d ;
:tbb "%" ,s 8 >> ,b ;
:thb "$" ,s 8 >> ,h ;
:tfb 8 >> ,f ;

#ltok nil tdb tbb thb tfb 0 tw td tb th tf ts tw tw taw taw

::,tokenprintc
	dup $ff and
	15 >? ( 16 - r3basename 9 ,fcolor ,s drop ; )
	3 << 'ltok + @ ex ;
	
:token | n
	cnttok >=? ( drop ; )
	2 << initok +
	d@ | dup
	,tokenprintc
	;
	
:wordmap
|	1 18 ,at
|	actword dic>adr
|	dup 16 + @ 1 and ":#" + c@ ,c |emit
|	@ "%w" ,print ,cr
	1 19 ,at
	0 ( cnttok <?
		dup token ,sp
		1 + ) drop ;

|-------------------------------------------
:printcode
	9 ,fcolor 
	@+ " :%w " ,print
	drop ;

:printdata
	13 ,fcolor 
	@+ " #%w " ,print
	drop ;

:printword | nro --
	actword =? ( ,rever )
	dup 1 + "%d." ,print
	5 << dicc +
	dup 16 + @ 1 nand? ( drop printcode ; ) drop
	printdata 
	;

:dicmap
	,reset
	0 ( 15 <?
		1 over 2 + ,at
		dup iniword +
		printword
		,reset
		1 + ) drop ;

:+word | d --
	actword +
	cntdef 1 - clamp0max
	iniword <? ( dup 'iniword ! )
	iniword 15 + >=? ( dup 15 - 1 + 'iniword ! )
	'actword !
	wordanalysis
	actword dic>adr @ findinclude 'incnow !
	;

:setword | w --
	cntdef 1 - clamp0max 'actword !
	0 +word
	;

:modeview
	ckey 
	$48 =? ( -1 +word ) | arriba 
	$50 =? ( 1 +word )	| abajo

|	$4d =? ( kder ) 
|	$4b =? ( kizq )
	$47 =? ( cntdef neg +word )	| home 
	$4f =? ( cntdef +word ) 	| end 
	$49 =? ( hcode neg +word )	| pgup 
	$51 =? ( hcode +word )		| pgdn 
	
	| $3b |f1
|	$3d =? ( mode!src ) | <f4> -- vie src
	drop

	mark
	,hidec ,reset ,cls
	dicmap
	
|	incmap
	
	1 18 ,at
	actword ,wordinfo ,eol 
	wordmap

	1 rows 1 + ,at ,rever
	cnttokens cntdef cntinc "inc:%d def:%d tokens:%d " ,print
	actword "%d" ,print
|	cursorpos
	,showc
	memsize type	| type buffer
	empty			| free buffer
	
	;

|------ VARIABLE VIEW
#varlist * $fff
#varlistc

:col_var
|	$ff00ff 'ink ! 
	;

:prevars
	'varlist >a
	dicc< ( dicc> <?
		dup 16 + @ 1 and? ( over dicc - 5 >> da!+ ) drop
		32 + ) drop
	a> 'varlist - 2 >>
	'varlistc ! ;

:showvars
	0 ( hcode <?
		varlistc >=? ( drop ; )
		cols 1 >> over 1 + ,at
		dup 2 << 'varlist + d@
		dup dic>adr @ "%w " col_var ,print
		dic>tok @ @ "%d" 
		|$ffffff 'ink ! 
		,print
		,cr
		1 + ) drop ;

|---------------------------------
:infobottom
	1 hcode 2 + ,at 
	,bblue ,white |,eline
	" info ^[7mF1^[27m " ,printe ,nl
	,reset ,bblack
	<<ip "IP:%h" ,print ,nl
	,stackprintvm
	;

|----- scratchpad
#outpad * 1024
#inpad * 1024
#bakip>
#bakcode>
#bakcode
#baksrc
#bakblk

:markcode
	<<ip 'bakip> !
	code> 'bakcode> !
	code 'bakcode !
	src 'baksrc !
	nbloques 'bakblk !
	mark ;

:emptycode
	empty
	bakip> '<<ip !
	bakcode> 'code> !
	bakcode 'code !
	baksrc 'src !
	bakblk 'nbloques !
	;

:execerr
	'outpad strcpy
	emptycode
|	refreshfoco
	;

|vvv DEBUG  vvv

:stepdebug
	1 hcode 1 + .at

|	'outpad sp text ,cr
	dup "%h" .println

	" > " .print
|	'inpad 1024 input ,cr
	stackprintvm ,cr
	regb rega " RA:%h RB:%h " ,print
	|waitesc 
	;

:viewimm
	,cls 
	,cr ,cr ,cr
	here ( code> <? @+
		dup ,tokenprintc
		"   %h" ,print
		,cr
		) drop
	waitesc ;

|^^^ DEBUG ^^^

:execimm
	markcode
	0 'error !
	here dup 'code ! 'code> !
	'inpad dup 'src !
	allwords | see all words (not only exported)
	str2token
	error 1? ( execerr ; ) drop

	here immcode2run
	here ( code> <? @+
		tokenexec
|		stepdebug
		) drop

	emptycode
	0 'inpad !
	"Ok" 'outpad strcpy

|	refreshfoco
	;

:showip
	<<ip 0? ( drop "END" .print ; )
	dup @ "%h (%h)" .print
	<<bp 0? ( drop ; )
	dup @ " %h (%h)" .print
	;

:console
	1 hcode 1 + .at
    showip

	" > " .print
|	'inpad 1024 input ,cr
	stackprintvm cr
	regb rega " RA:%h RB:%h " ,print
	;


|-------- view screen
:waitf6
|	key >f6< =? ( exit ) drop 
	;

:viewscreen
	|xfb> 'waitf6 onshow 
	;

|-------------------------------
|----------- SAVE DEBUG
:,printword | adr --
  	adr>toklen
	( 1? 1 - swap
		d@+
		dup $ff and "%h " ,print
		dup 8 >> 1? ( dup "%h " ,print ) drop
		,tokenprintc ,cr
		swap ) 2drop ;

|------ MAIN
:modeshow
	emode
|	0 =? ( modeview )	
	1 =? ( modeview )
	drop ;

|--------------------- BOOT
: 	
	'name "mem/main.mem" load drop
|	'name .println
	
	'name r3debuginfo
	
	error 
	1? ( drop savedebug ; ) drop
	emptyerror
	
	here dup 'linecomm !
	"mem/infomap.db" load 
	0 $fff rot !+ !+ 
	dup 'linecomm> ! 
	'here !
	
	|savemap | save info in file for debug
	
	vm2run
	
	'name 'namenow strcpy

	.getconsoleinfo
	.alsb .ovec .cls
	
	mode!view 
	cntdef 1 - setword
	resetvm

|	gotosrc |*****
|	prevars | add vars to panel

	modeshow
	( getch $1B1001 <>? 'ckey !
		modeshow 
		) drop 
	.masb
	;

