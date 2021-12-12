| r3debug
| PHREDA 2020
|------------------
^r3/win/console.r3

^./r3base.r3
^./r3pass1.r3
^./r3pass2.r3
^./r3pass3.r3
^./r3pass4.r3

^./r3vm.r3

#ckey 
#name * 1024
#namenow * 256

::r3debuginfo | str --
	.reset .cls 
	r3name
	here dup 'src !
	'r3filename
	dup "load %s" .println
	2dup load			|	"load" slog
	here =? ( "no source code." .println  ; )
	src only13 0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	swap	
	"stage 1" .println
	r3-stage-1 error 1? ( "ERROR %s" .println lerror "%l" .println ; ) drop	
	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println
	
	"stage 2" .println
	r3-stage-2 1? ( drop ; ) drop 		
	"stage 3" .println
	r3-stage-3			
	"stage 4" .println
	r3-stage-4			
	"stage ok" .println
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
#ycode 1
#wcode 40
#hcode 25

#xseli	| x ini win
#xsele	| x end win

|------ MODES
:calcselect
|	xcode wcode + gotox
|	ccx 'xsele !
|	xcode gotox ccx 'xseli !
	;

:mode!imm
	0 'emode !
	rows 7 - 'hcode !
	cols 1 >> 'wcode !
	calcselect ;

:mode!view
	1 'emode !
	rows 2 - 'hcode !
	cols 7 - 'wcode !
	calcselect ;

:mode!src
	2 'emode !
	rows 2 - 'hcode !
	cols 7 - 'wcode !
	calcselect ;

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
		30 over 1 + .at
		dup "%d " .print
		dup 3 << 'inc + @+ swap @ "%h %l" .print

		incnow =? ( " <" .print )
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
	@ | dup
	tokenprintc
	;
	
:wordmap
	0 ( hcode <?
		cnttok <?
		3 over 2 + .at
		dup token
		1 + ) drop ;

|---------
:printcode
	@+ " :%w " .print
	drop ;

:printdata
|	$ff00ff 'ink !
	@+ " #%w " .print
	drop ;

:printword | nro --
	|actword =? ( |$222222 'ink !  backline )
	|$888888 'ink !
	dup 1 + "%d." .print
	4 << dicc +
	dup 8 + @ 1 nand? ( drop printcode ; ) drop
	printdata ;

:dicmap
	0 ( hcode <?
		dup iniword +
		printword cr
		1 + ) drop ;

:+word | d --
	actword +
	cntdef 1 - clamp0max
	iniword <? ( dup 'iniword ! )
	iniword hcode + >=? ( dup hcode - 1 + 'iniword ! )
	'actword !
	wordanalysis
	actword dic>adr @ findinclude 'incnow !
	;

:setword | w --
	cntdef 1 - clamp0max

|	iniword <? ( dup 'iniword ! )
|	iniword hcode + >=? ( dup hcode - 1 + 'iniword ! )

	'actword !
	wordanalysis
	actword dic>adr @ findinclude 'incnow !
	;

:btnf | txt tecla -- ***
	.print .print
	;
	
:modeview
	0 1 .at
	dicmap
	incmap
	
	|$ff0000 'ink !
	mark actword ,wordinfo empty
	here .print
	wordmap

	0 hcode 1 + .at
|	$0000AE 'ink !
|	rows hcode - 1 - backlines
	0 rows 1 - .at
	"CODE" "F10" btnf

	ckey 16 >>
	$27 =? ( mode!src ) |>esc< 
	$45 =? ( mode!src ) |<f10> 

|	<up> =? ( -1 +word )
|	<dn> =? ( 1 +word )
|	<home> =? ( cntdef neg +word )
|	<end> =? ( cntdef +word )
|	<pgup> =? ( hcode neg +word )
|	<pgdn> =? ( hcode +word )

	drop
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
		dup 8 + @ 1 and? ( over dicc - 4 >> a!+ ) drop
		16 + ) drop
	a> 'varlist - 2 >>
	'varlistc ! ;

:showvars
	0 ( hcode <?
		varlistc >=? ( drop ; )
		cols 1 >> over 1 + .at
		dup 2 << 'varlist + @
		dup dic>adr @ "%w " col_var .print
		dic>tok @ @ "%d" 
		|$ffffff 'ink ! 
		.print
		cr
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

:,esc $1b ,c $5b ,c	;
:,fcolor ,esc "38;5;%dm" ,print ;
:,bcolor ,esc "48;5;%dm" ,print ;
:,eline  ,esc "K" ,s ; | erase line from cursor

:,tcolor colornow ,fcolor ;

:iniline
	xlinea wcolor
	( 1? 1 - swap
		c@+ 0? ( drop nip 1 - ; )
		13 =? ( drop nip 1 - ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		drop swap ) drop ;
	
:strword
	,c
	( c@+ 1?
		$22 =? (
			over c@  $22 <>? ( drop ; )
			,c swap 1 + swap )
		,c	) drop 1 - ;
	
:endline
	,c ( c@+ 1? 
			13 <>? ,c )	1? ( drop ; ) drop 1 - ;
	
:parseline 
	,tcolor
	( c@+ 1? 13 <>?  | 0 o 13 sale
		9 =? ( wcolor ,tcolor )
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
	ycursor =? ( ">" ,s ; ) 32 ,c ;
	
:linenro | lin -- lin
	dup ylinea + linenow 1 + .d 3 .r. ,s 32 ,c ; 

:drawline | adr line -- line adr'
	mark 
	,esc "0m" ,s ,esc "37m" ,s ,eline | reset,white,clear
	linenro	swap 
	iniline
	parseline 
	here
	empty
	here dup rot rot - type ;
|..............................

:<<13 | a -- a
	( fuente >=?
		 dup c@
		13 =? ( drop ; )
		drop 1 - ) ;

:>>13 | a -- a
	( $fuente <?
		 dup c@
		13 =? ( drop 1 - ; ) | quitar el 1 -
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
:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 3 'xcursor +! ; )
	drop 1 'xcursor +! ;

|..............................
:drawcode
	fuente>
	( pantafin> >? scrolldw )
	( pantaini> <? scrollup )
	drop

	pantaini>
	0 ( hcode <?
		0 ycode pick2 + .at
		drawline
		swap 1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> !
	;

|------- TAG VIEWS
| tipo/y/x/ info
| tipo(ff)-x(fff)-y(fff) (32)
| info-tipo (32)
| 
#taglist * $3fff
#taglist> 'taglist


:tagpos
	over 12 >> $fff and xcode + xlinea - |xlineat -
	over ycode + ylinea - .at ;

:tagdec
	tagpos pick2 @ "%d" .print ;
:taghex
	tagpos pick2 @ "%h" .print ;
:tagbin
	tagpos pick2 @ "%b" .print ;
:tagfix
	tagpos pick2 @ "%f" .print ;
:tagmem
	tagpos pick2 "'%h" .print ;
:tagadr
	tagpos pick2 "'%h" .print ;

:tagip	| ip
	tagpos
|	$ffffff 'ink !
|	pick2 @ ccw *
|	ccx 1 - ccy 1 - rot pick2 + 2 + over cch + 2 +
| box.dot 
	"*" .print
	;

:tagbp	| breakpoint
|	blink 0? ( drop ; ) drop
	tagpos
|	pick2 @ ccw *
|	ccx 1 - ccy 1 - rot pick2 + 2 + over cch + 2 +
|	$ff0000 'ink !
| 	rectbox 
	"?" .print
	;


#infostr * 256
#infocol

:,ncar | n car -- car
	( swap 1? 1 - swap dup ,c 1 + ) drop ;

:,mov | mov --
	97 >r	| 'a'
	dup $f and " " ,s
	dup r> ,ncar >r "--" ,s
	swap 55 << 59 >> + | deltaD
	-? ( ,d r> drop ; ) | error en analisis!!
	r> ,ncar drop " " ,s ;

:buildinfo | infmov -- str
	mark
	'infostr 'here !
	$f000 'infocol !
	@+
	$20 and? ( "R" ,s )		| recurse
	$80 nand? ( "."  ,s	)	| no ;
	12 >> $fff and 0? ( $f00000 'infocol ! ) | calls?
	drop @ ,mov
	,eol
	empty
	'infostr
	;

:taginfo | infoword
	tagpos
	pick2 @ buildinfo
|	count cols swap - 1 - gotox
	.print
	;

:tagnull
	;

#tt tagip tagbp taginfo tagdec taghex tagbin tagfix tagmem tagadr
tagnull tagnull tagnull tagnull tagnull tagnull tagnull

:drawtag | adr txy y -- adr txy y
	over 24 >> $f and 3 << 'tt + @ ex ;

:drawtags
	'taglist
	( taglist> <?
		d@+ dup $fff and
		ylinea dup hcode + bt? ( drawtag )
		2drop 4 + ) drop ;


#cntcr	| cnt cr from src to first token

:addtag
	code2ixy 0? ( drop ; )
	dup 24 >> incnow <>? ( 2drop ; ) drop
	$ffffff and cntcr - $2000000 or
	taglist> d!+
	over swap d!+ 'taglist> ! | save >info,mov
	;

:calccrs | adr src -- adr
	over @ code2src
	0 'cntcr !
	swap ( over <? c@+
		13 =? ( 1 'cntcr +! )
		drop ) 2drop ;

:maketags
	'taglist 8 + >a
	$f000000 da!+ 0 a!+ 		| only ip+bp clear bp
	a> 'taglist> !
|	incnow 3 << 'inc + 4 + @	| firs src
	dicc ( dicc> <?
		@+ calccrs @+ addtag 16 + ) drop ;

|---------------------------------
:barratop
	.cls
	"r3Debug ^[7mF1^[27m INFO ^[7mF2^[27m DICC ^[7mF3^[27m WORD ^[7mF4^[27m MEM ^[7mF5^[27m SRC  " .printe 

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
	0 hcode 1 + .at
|	$0000AE 'ink !
|	rows hcode - 1 - backlines

|	$ff00 'ink !
|	'outpad sp text cr
	dup "%h" .println

|	$ffffff 'ink !
	" > " .print
|	'inpad 1024 input cr
|	$ffff00 'ink !
	stackprintvm cr
	regb rega " RA:%h RB:%h " .print
	|waitesc 
	;

:viewimm
	.cls 
	cr cr cr
	here ( code> <? @+
		dup tokenprintc
		"   %h" .print
		cr
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
|	xsele cch op
|	wcode hcode 1 + .at
|	xsele ccy pline
|	sw ccy pline
|	sw cch pline
|	$040466 'ink !
|	poli

	0 hcode 1 + .at
|	$0000AE 'ink !
|	rows hcode - 1 - backlines

    showip
|	'outpad sp text cr

	" > " .print
|	'inpad 1024 input cr
	stackprintvm cr
	regb rega " RA:%h RB:%h " .print
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
	count + '$fuente !
	0 'xlinea !
	0 'ylinea !
	setpantafin
	;

:srcnow | nro --
	incnow =? ( drop ; ) dup 'incnow !
	3 << 'inc +
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
	getsrclen 'taglist 4 + d! ;

:setbp
	fuente> incnow src2code
	dup '<<bp !
	code2ixy
	$ffffff and $1000000 or
	'taglist 8 + d!
	<<bp code2src getsrclen 'taglist 12 + d! ;
	;

:play2cursor
	fuente> incnow src2code
	dup '<<bp !
	code2ixy
	$ffffff and $1000000 or
	'taglist 8 + d!
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
	drawcode
|drawcursor
	drawtags
	statevars 1? ( showvars ) drop

	0 rows 1 - .at
|	$3465A4 'ink ! 
|	backline
	"IMM" "TAB" btnf
	"PLAY" "F1" btnf
	"PLAY2C" "F2" btnf
	"ANALYSIS" "F3" btnf

	"VIEW" "F6" btnf
	"STEP" "F7" btnf
	"STEPN" "F8" btnf

	showvstack

	ckey 32 >>
	$48 =? ( karriba ) 
	$50 =? ( kabajo )
	$4d =? ( kder ) 
	$4b =? ( kizq )
	$47 =? ( khome ) 
	$4f =? ( kend )
	$49 =? ( kpgup ) 
	$51 =? ( kpgdn )

|	27 =? ( exit )

	$3b =? ( playvm gotosrc )
	$3c =? ( play2cursor playvm gotosrc )

	$3d =? ( mode!view codetoword ) | word analisys
|	<f10> =? ( mode!view 0 +word )

	$3f =? ( setbp )
|	>f6< =? ( viewscreen )
|	<f7> =? ( stepvm gotosrc )
|	<f8> =? ( stepvmn gotosrc )
|	<f9> =? ( 1 statevars xor 'statevars ! )
|	<tab> =? ( mode!imm )


	drop
	;


#ninclude

:modeimm
	drawcode
|	drawcursorfix
	console
	showvars

	0 rows 1 - .at
|	$989898 'ink ! backline
	"SRC" "TAB" btnf

	"PLAY2C" "F1" btnf
	"VIEW" "F6" btnf
	"STEP" "F7" btnf
	"STEPN" "F8" btnf

	ckey
|	>esc< =? ( exit )
|	<ret> =? ( execimm )
|	<tab> =? ( mode!src )

|	<f1> =? ( fuente> breakpoint playvm gotosrc )
|	<f2> =? ( fuente> incnow src2code drop )

|	<f6> =? ( viewscreen )
|	<f7> =? ( stepvm gotosrc )
|	<f8> =? ( stepvmn gotosrc )

|	<f10> =? ( mode!view 0 +word )

	drop
	;


|------ MAIN
:modeshow
	barratop
	emode
	0 =? ( modeimm )
	1 =? ( modeview )
	2 =? ( modesrc )
	drop ;
	
:debugmain
	modeshow
	( getch $1B1001 <>? 'ckey !
		modeshow ) drop ;

|----------- SAVE DEBUG
:,printword | adr --
  	adr>toklen
	( 1? 1 - swap
		d@+
		dup $ff and "%h " ,print
		dup 8 >> 1? ( dup "%h " ,print ) drop
		,tokenprintc ,cr
		swap ) 2drop ;

:savemap
	mark
	"inc-----------" ,ln
	'inc ( inc> <?
		@+ "%w " ,print
		@+ "%h " ,print ,cr
		) drop
	
	"dicc-----------" ,ln
	dicc ( dicc> <?
		@+ "%w " ,print
		@+ "%h " ,print
		@+ "%h " ,print
		@+ "%h " ,print ,cr
		dup 32 - ,printword
		,cr ) drop
	
	"block----------" ,ln
	blok cntblk ( 1? 1 - swap
		d@+ "%h " ,print
		d@+ "%h " ,print ,cr
		swap ) 2drop

	"mem/map.txt" savemem
	empty ;

|--------------------- BOOT
: 	
	'name "mem/main.mem" load drop
	'name .println
	
	'name r3debuginfo
	error 
	1? ( drop savedebug ; ) drop
	emptyerror
	savemap | save info in file for debug
	vm2run
	
|	mode!view 0 +word
	calcselect
	'name 'namenow strcpy
	src setsource
	
|	mode!imm
|	mode!src

	1 'emode ! 

| tags
	'taglist >a
	$f000000 da!+ 0 da!+ | IP
	$f000000 da!+ 0 da!+ | BP
	a> 'taglist> !

	cntdef 1 - 'actword !
	resetvm
	
	|gotosrc

	prevars | add vars to panel

	debugmain 
	;

