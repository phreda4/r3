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

::r3debuginfo | str --
	r3name
	here dup 'src !
	'r3filename load
	here =? ( drop "no source code." .println  ; )
	0 swap c! 
	src only13 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	src
	r3-stage-1 error 1? ( 2drop ; ) drop	
	r3-stage-2 1? ( 2drop ; ) drop 		
	r3-stage-3			
	r3-stage-4			
	drop	
	;

:savedebug
	mark
	error ,s ,cr
	lerror src - ,d ,cr
	"mem/debuginfo.db" savemem
	empty ;

:emptyerror
 	"mem/debuginfo.db" delete ;

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
 
:mode!src
	2 'emode !
	rows 4 - 'hcode !
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
	@+ " :%w " ,print
	drop ;

:printdata
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
	$3d =? ( mode!src ) | <f4> -- vie src
	drop

	mark
	,hidec ,reset ,cls
	dicmap
	incmap
	
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
#varlist * $ffff
#varlistc

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
		dup dic>adr @ "#%w " ,print
		dic>tok @ @ "%d" ,print
		,cr
		1 + ) drop ;

|------ CODE VIEW
#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor

#pantaini>	| comienzo de pantalla
#pantafin>	| fin de pantalla
#fuente  	| fuente editable
#fuente> 	| cursor
#$fuente	| fin de texto

|------ Color line
#colornow 0

:wcolor
	over c@
	$22 =? ( drop 15 'colornow ! ; )	| $22 " string
	$5e =? ( drop 3 'colornow ! ; )	| $5e ^  Include
	$7c =? ( drop 8 'colornow ! ; )	| $7c |	 Comentario
	$3A =? ( drop 9 'colornow ! ; )	| $3a :  Definicion
	$23 =? ( drop 13 'colornow ! ; )	| $23 #  Variable
	$27 =? ( drop 14 'colornow ! ; )	| $27 ' Direccion
    drop
	over isNro 1? ( drop 11 'colornow ! ; ) 
	drop 10 'colornow ! ;

:,tcolor colornow ,fcolor ;

:iniline
	xlinea wcolor
	( 1? 1 - swap
		c@+ 0? ( drop nip 1 - ; )
		13 =? ( drop nip 1 - ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		drop swap ) drop ;
	
:,ct
	9 =? ( ,sp ,sp 32 nip ) ,c ;
	
:strword
	,c
	( c@+ 1?
		$22 =? (
			over c@ $22 <>? ( drop ; )
			,c swap 1 + swap )
		,ct	) drop 1 - ;
	
:endline
	,c ( c@+ 1? 13 <>? ,ct )	
	1? ( drop ; ) drop 1 - ;
	
:parseline 
	,tcolor
	( c@+ 1? 13 <>?  | 0 o 13 sale
		9 =? ( wcolor ,tcolor ,sp ,sp drop 32 )
		32 =? ( wcolor ,tcolor )
		$22 =? ( strword ) 		| $22 " string
		$5e =? ( endline ; )	| $5e ^  Include
		$7c =? ( endline ; )	| $7c |	 Comentario
		,c
		) 
	1? ( drop ; ) drop
	1 - ;

|..............................
:linenow
	ycursor =? ( $3e ,c ; ) 32 ,c ;
	
:linenro | lin -- lin
	dup ylinea + linenow 1 + .d 3 .r. ,s 32 ,c ; 

:drawline | adr line -- line adr'
	,esc "0m" ,s ,esc "37m" ,s ,eline | reset,white,clear
	linenro	swap 
	iniline
	parseline 
|	prntcom
	;
	
|..............................

:<<13 | a -- a
	( fuente >=?
		dup c@ 13 =? ( drop ; )
		drop 1 - ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@ 13 =? ( drop 1 - ; ) | quitar el 1 -
		drop 1 + )
	drop $fuente 2 - ;

:khome
	fuente> 1 - <<13 1 + 'fuente> ! ;
:kend
	fuente> >>13  1 + 'fuente> ! ;

:scrollup | 'fuente -- 'fuente
	pantaini> 1 - <<13 1 - <<13  1 + 'pantaini> !
	ylinea 1? ( 1 - ) 'ylinea ! ;

:scrolldw
	pantaini> >>13 2 + 'pantaini> !
	pantafin> >>13 2 + 'pantafin> !
	1 'ylinea +! ;

:colcur
	fuente> 1 - <<13 swap - ;

:karriba
	fuente> fuente =? ( drop ; )
	dup 1 - <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1 - <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> !
	;

:kabajo
	fuente> $fuente >=? ( drop ; )
	dup 1 - <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1 +    | cnt cura
	dup 1 + >>13 1 + 	| cnt cura curb
	over -
	rot min +
	'fuente> !
	;

:kder
	fuente> $fuente <? ( 1 + 'fuente> ! ; ) drop ;

:kizq
	fuente> fuente >? ( 1 - 'fuente> ! ; ) drop ;

:kpgup
	20 ( 1? 1 - karriba ) drop ;

:kpgdn
	20 ( 1? 1 - kabajo ) drop ;

|..............................
:drawcode
	fuente>
	( pantafin> >? scrolldw )
	( pantaini> <? scrollup )
	drop

	,reset
|	inicomm
	pantaini>
	0 ( hcode <?
		1 ycode pick2 + ,at
		drawline
		swap 1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> !
	;

:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 3 'xcursor +! ; )
	drop 1 'xcursor +! ;

:cursorpos
	ylinea 'ycursor ! 0 'xcursor !
	pantaini> ( fuente> <? c@+ emitcur ) drop
	| hscroll
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea wcode + >=? ( dup wcode - 1 + 'xlinea ! )
	drop 
	xcode xlinea - xcursor +
	ycode ylinea - ycursor + ,at 
	| draw code
	|,rever <<ip code2src "%w" ,print
	;

|------- TAG VIEWS
| tipo/y/x/ info
| tipo(ff)-x(fff)-y(fff) (32)
| info-tipo (32)
| 
#taglist * $3fff
#taglist> 'taglist

:tagpos
	over 12 >> $fff and xcode + xlinea - 
	over ycode + ylinea - ,at ;

:tagdec
	tagpos pick2 @ "%d" ,print ;
:taghex
	tagpos pick2 @ "%h" ,print ;
:tagbin
	tagpos pick2 @ "%b" ,print ;
:tagfix
	tagpos pick2 @ "%f" ,print ;
:tagmem
	tagpos pick2 "'%h" ,print ;
:tagadr
	tagpos pick2 "'%h" ,print ;

:tagip	| ip
	tagpos
|	"*" ,print
	,byellow ,black
	<<ip code2src "%w" ,print
	,Reset
	;

:tagbp	| breakpoint
	tagpos
	,bred ,black
	">" ,print
	;

|---------- TAGS in code	
:,ncar | n -- 
	97 ( swap 1? 1 - swap dup ,c 1 + ) 2drop ;

:buildinfo | infmov --
	,bcyan 
	dup $f and ,sp
	dup ,ncar " -- " ,s
	over 55 << 59 >> + | deltaD
	,ncar ,sp 
	,reset ,sp ,bcyan ,black
	$1000000000 and? ( ";"  ,s	)	| multiple
	$2000000000 and? ( "R" ,s )		| recurse
	$8000000000 nand? ( "."  ,s	)	| no ;
	drop
	;

	
|:prntcom | line adr' -- line adr'
|	linecommnow @ $fff and 
|	pick2 ylinea + 
|	>? ( drop ; ) drop
|	,sp
|	linecommnow 8 +
|	@+ swap 'linecommnow !
|	dup 12 32 + >> $ff and 
|	0? ( 2drop ,bred ,white "<< NOT USED >>" ,s ; ) drop
|	,black
|	buildinfo
|	prntcom
|	;

:taginfo | infoword
	tagpos
|	pick2 @ buildinfo
|	count cols swap - 1 - gotox
	"??" ,print
	
|	@+ swap 'linecommnow !
|	dup 12 32 + >> $ff and 
|	0? ( 2drop ,bred ,white "<< NOT USED >>" ,s ; ) drop
|	,black
|	buildinfo	
	;

:tagnull
	;

#tt tagip tagbp taginfo tagdec taghex tagbin tagfix tagmem tagadr
tagnull tagnull tagnull tagnull tagnull tagnull tagnull

:drawtag | adr txy y -- adr txy y
	over 24 >> $f and 
|	dup ">>%d" .println
	3 << 'tt + @ ex ;

:drawtags
	'taglist
	( taglist> <?
|		dup "tag:%h" .println
		d@+ dup $fff and
		ylinea dup hcode + in? ( drawtag )
		2drop 4 + ) drop ;


#cntcr	| cnt cr from src to first token

:addtag | 'code --
	code2ixy 0? ( drop ; )
	dup 24 >> incnow <>? ( 2drop ; ) drop
|	"." .println
	$ffffff and cntcr - $2000000 or | first code minus 
	taglist> d!+
	over swap d!+ 
	'taglist> ! | save >info,mov
	;

:calccrs | adr src -- adr
	over @ code2src
	0 'cntcr !
	swap ( over <? c@+
		13 =? ( 1 'cntcr +! )
		drop ) 2drop ;

:maketags
	'taglist 8 + >a
	$f000000 da!+ 0 da!+ 		| only ip+bp clear bp
	a> 'taglist> !
|	incnow 4 << 'inc + 8 + @	| firs src
|	dicc ( dicc> <?
|		@+ calccrs @+ addtag 16 + ) drop 
		;
		
|---------------------------------
:barratop
	,bblue ,white ,eline
	" " ,s 'namenow ,s
|	"^[37mr3Debug ^[7mF1^[27m INFO ^[7mF2^[27m DICC ^[7mF3^[27m WORD ^[7mF4^[27m MEM ^[7mF5^[27m SRC  " ,printe 
	
|	"^[37mr3Debug ^[7mF1^[27mPLAY2C ^[7mF6^[27mVIEW ^[7mF7^[27mSTEP ^[7mF8^[27mSTEPN" ,printe 
|	"^[37mr3Debug ^[7mF4^[27mVIEWW " ,printe 
	
	;

:infobottom
	1 hcode 2 + ,at 
	,bblue ,white ,eline
	"^[37mr3Debug ^[7mF1^[27mRUN ^[7mF2^[27mRUN2C ^[7mF5^[27mSTEP ^[7mF6^[27mSTEPN ^[7mF7^[27mBP ^[7mF9^[27mVAR" ,printe ,nl
|	" info ^[7mF1^[27m " ,printe ,nl
	,reset ,bblack
	regb rega <<ip "IP:%h RA:%h RB:%h " ,print ,nl
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

	1 hcode 1 + .at .eline

    showip regb rega " RA:%h RB:%h " .print .cr
|	'outpad sp text ,cr

	" > " .print
	|'inpad 1024 input ,cr
	stackprintvm .cr

	;

|------ search code in includes
:setpantafin
	pantaini>
	0 ( hcode <?
		swap >>cr 1 + swap
		1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> ! ;

:setsource | src --
	dup 'pantaini> !
	dup 'fuente !
	dup 'fuente> !
	count + '$fuente !
	0 'xlinea !
	0 'ylinea !
	setpantafin
	;

:srcnow | nro --
	incnow =? ( drop ; ) dup 'incnow !
	4 << 'inc + | ??
	@+ "%l" sprint 'namenow strcpy | warning ! is IN the source code
	@ setsource
	maketags
	;

:getsrclen | adr -- len
	dup ( c@+ $ff and 32 >? drop ) drop 1 - swap - ;

:gotosrc
	<<ip 0? ( drop ; )
	0 'xlinea !
	dup code2ixy
	dup 24 >> $ff and srcnow
	$ffffff and 'taglist d!
	code2src dup 'fuente> !
	getsrclen 'taglist 4 + d! 
	;

:setbp
	fuente> incnow src2code
	dup '<<bp !
	code2ixy
	$ffffff and $1000000 or 'taglist 8 + d!
	<<bp code2src getsrclen 'taglist 12 + d! ;
	;

:play2cursor
	fuente> incnow src2code
	dup '<<bp !
	code2ixy
	$ffffff and $1000000 or 'taglist 8 + d!
	<<bp code2src getsrclen 'taglist 12 + d! ;
	;

:codetoword
	fuente> incnow src2word setword ;

|-------- view screen
:waitf6
|	key >f6< =? ( exit ) drop 
	;

:viewscreen
	|xfb> 'waitf6 onshow 
	;

#statevars

|-------------------------------

:modesrc
	ckey 
	$48 =? ( karriba ) $50 =? ( kabajo )
	$4d =? ( kder ) $4b =? ( kizq )
	$47 =? ( khome ) $4f =? ( kend )
	$49 =? ( kpgup ) $51 =? ( kpgdn )
	
	$3b =? ( playvm gotosrc ) |f1
	$3c =? ( play2cursor playvm gotosrc ) |f2
	$3d =? ( mode!view codetoword ) | f3 word analisys
	| $3e f4
	$3f =? ( stepvm gotosrc )	| f5
	$40 =? ( stepvmn gotosrc )	| f6
	$41 =? ( setbp ) | f7

	$43 =? ( 1 statevars xor 'statevars ! ) | f9

|	<f10> =? ( mode!view 0 +word )
|	>f6< =? ( viewscreen )
	$9000F =? ( mode!imm ) | tab
	drop

	mark
	,hidec ,cls
	barratop
	drawcode
	infobottom
	drawtags

	statevars 1? ( showvars ) drop

	cursorpos
	
	,showc
	memsize type	| type buffer
	empty			| free buffer
	;


|----------- SAVE DEBUG
:,printword | adr --
  	adr>toklen
	( 1? 1 - swap
		dup "%h : " ,print
		d@+
		dup $ff and "%h " ,print
		dup 8 >> 1? ( dup "%h " ,print ) drop
		,tokenprintc ,cr
		swap ) 2drop ;

:savemap
	mark
	"inc-----------" ,print ,cr
	'inc ( inc> <?
		@+ "%w " ,print
		@+ "%h " ,print ,cr
		) drop
	
	"dicc-----------" ,print ,cr
	dicc ( dicc> <?
		@+ "#:%w " ,print
		@+ "%h " ,print
		@+ "%h " ,print
		@+ "%h " ,print ,cr
		dup 32 - ,printword
		,cr ) drop
	
	"block----------" ,print ,cr
	blok cntblk ( 1? 1 - swap
		d@+ "%h " ,print
		d@+ "%h " ,print ,cr
		swap ) 2drop

	"runmap ----------" ,print ,cr
|	code ( code> <? 
|		dup code2src "%w " ,print
|		dup code2ixy "%h " ,println
|		4 + ) drop

	"tag ----------" ,print ,cr
	'taglist
	( taglist> <?
		d@+ "%h " ,print
		d@+ "%h " ,println
		) drop 


	"mem/map.txt" savemem
	empty ;


|------ MAIN
:modeshow
	emode
	0 =? ( console )
	1 =? ( modeview )
	2 =? ( modesrc )
	drop ;

|--------------------- BOOT
: 	
	'name "mem/main.mem" load drop
	'name r3debuginfo
	
	error 
	1? ( drop savedebug ; ) drop
	emptyerror
	
	vm2run

	'name 'namenow strcpy
	src setsource

	.getconsoleinfo
	.alsb .ovec .cls
	
|	mode!imm
	mode!src
|	mode!view 
	
	cntdef 1 - setword
	resetvm
| tags
	'taglist >a
	$f000000 da!+ 0 da!+ | IP
	$f000000 da!+ 0 da!+ | BP
	a> 'taglist> !
	maketags

|	savemap | save info in file for debug
	
	gotosrc
	prevars | add vars to panel
	modeshow
	( getch $1B1001 <>? 'ckey !
		modeshow 
		) drop 
	.masb
	;

