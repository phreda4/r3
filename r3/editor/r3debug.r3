| r3debug
| PHREDA 2020
|------------------
^r3/win/console.r3

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
	r3-stage-1 error 1? ( "ERROR %s" .println lerror "%l" .println ; ) drop	
	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println
	
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

:mode!src
	2 'emode !
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

:incmap
	0 ( cntinc <?
		40 over 2 + .at
		incnow =? ( .rever )
		dup "%d " .print
		dup 4 << 'inc + @+ swap @ "%h %l" .print
		incnow =? ( .reset )
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
	tokenprint
	;
	
:wordmap
	1 18 .at
	actword dic>adr
	dup 16 + @ 1 and ":#" + c@ emit
	@ "%w" .print cr
	0 ( cnttok <?
		dup token sp
		1 + ) drop ;

|-------------------------------------------
:printcode
	@+ " :%w " .print
	drop ;

:printdata
	@+ " #%w " .print
	drop ;

:printword | nro --
	actword =? ( .rever )
	dup 1 + "%d." .print
	5 << dicc +
	dup 16 + @ 1 nand? ( drop printcode ; ) drop
	printdata 
	;

:dicmap
	.reset
	0 ( 15 <?
		1 over 2 + .at
		dup iniword +
		printword
		.reset
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

:btnf | txt tecla -- ***
	.print sp .print ;
	
:modeview
	.cls
	dicmap
	incmap
	
|	mark actword ,wordinfo ,eol empty
|	here .print
	
	wordmap

	1 rows 1 + .at .rever
	cnttokens cntdef cntinc "inc:%d def:%d tokens:%d " .print
	actword "%d" .print
	.reset
	
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
		cols 1 >> over 1 + .at
		dup 2 << 'varlist + d@
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
		1 ycode pick2 + .at
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
	ycode ylinea - ycursor + .at 
	;


|---------------------------------
:barratop
	.cls
	"^[37mr3Debug ^[7mF1^[27m INFO ^[7mF2^[27m DICC ^[7mF3^[27m WORD ^[7mF4^[27m MEM ^[7mF5^[27m SRC  " .printe 
	;

:infobottom
	1 rows 1 + .at
	"^[7m info ^[0m" .printe
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
	dup 'fuente> !
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
	|maketags
	;

:getsrclen | adr -- len
	dup ( c@+ $ff and 32 >? drop ) drop 1 - swap - ;

:gotosrc
	<<ip 0? ( drop ; )
	0 'xlinea !
	dup code2ixy
	dup 24 >> $ff and srcnow
	|$ffffff and 'taglist d!
	code2src dup 'fuente> !
	|getsrclen 'taglist 4 + d! 
	;

:setbp
	fuente> incnow src2code
	dup '<<bp !
	code2ixy
|	$ffffff and $1000000 or 'taglist 8 + d!
|	<<bp code2src getsrclen 'taglist 12 + d! ;
	;

:play2cursor
	fuente> incnow src2code
	dup '<<bp !
	code2ixy
|	$ffffff and $1000000 or 'taglist 8 + d!
|	<<bp code2src getsrclen 'taglist 12 + d! ;
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
	.hidec
	barratop
	drawcode

	infobottom

|	drawtags
|	statevars 1? ( showvars ) drop
|	showvstack

	cursorpos
	.showc

	ckey 
	$48 =? ( karriba ) 
	$50 =? ( kabajo )
	$4d =? ( kder ) 
	$4b =? ( kizq )
	$47 =? ( khome ) 
	$4f =? ( kend )
	$49 =? ( kpgup ) 
	$51 =? ( kpgdn )

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
	"inc-----------" ,print ,cr
	'inc ( inc> <?
		@+ "%w " ,print
		@+ "%h " ,print ,cr
		) drop
	
	"dicc-----------" ,print ,cr
	dicc ( dicc> <?
		@+ "%w " ,print
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

	"mem/map.txt" savemem
	empty ;

|------ MAIN
:modeshow
	emode
	1 =? ( modeview )
	2 =? ( modesrc )
	drop ;

|--------------------- BOOT
: 	
	'name "mem/main.mem" load drop
	'name .println
	
	'name r3debuginfo
	
	error 
	1? ( drop savedebug ; ) drop
	emptyerror
	
	|savemap | save info in file for debug
	
	vm2run
	
	'name 'namenow strcpy
	src setsource

	.getconsoleinfo
|	.alsb .ovec
	
|	mode!imm
|	mode!src
	mode!view 
	
	cntdef 1 - setword
	
|	resetvm

|	gotosrc |*****
|	prevars | add vars to panel

	modeshow
	( getch $1B1001 <>? 'ckey !
		modeshow 
		) drop 
	|.masb
	;

