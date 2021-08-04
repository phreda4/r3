|MEM $ffff  | 64MB
| r3debug
| PHREDA 2020
|------------------
^./r3base.r3
^./r3pass1.r3
^./r3pass2.r3
^./r3pass3.r3
^./r3pass4.r3

^./r3vm.r3

^r3/lib/print.r3
^r3/lib/btn.r3
^r3/lib/input.r3
^r3/lib/fontm.r3
^media/fntm/droidsans13.fnt

#name * 1024
#namenow * 256

::r3debuginfo | str --
	r3name
	here dup 'src !
	'r3filename
	2dup load			|	"load" slog
	here =? ( 3drop "no src" 'error ! ; )
	src only13 0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	r3fullmode swap	|	"stage 1" slog
	r3-stage-1 error 1? ( drop ; ) drop	|	"stage 2" slog
	r3-stage-2 1? ( drop ; ) drop 		|	"stage 3" slog
	r3-stage-3			|	"stage 4" slog
	r3-stage-4			|	"stage ok" slog
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
	xcode wcode + gotox ccx 'xsele !
	xcode gotox ccx 'xseli !
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
	$ffff00 'ink !
	0 ( cntinc <?
		30 over 1 + gotoxy
		dup "%d " print
		dup 3 << 'inc + @+ swap @ "%h %l" print

		incnow =? ( " <" print )
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
	$ffffff 'ink !
	@ | dup
	tokenprintc
	;
:tokencode
	35 gotox
	dup $ff and "%h " print
	8 >> 0? ( drop ; ) "%d" print ;

:wordmap
	0 ( hcode <?
		cnttok <?
		3 over 2 + gotoxy
		dup token
		1 + ) drop ;

|---------
:printcode
	$ff0000 'ink !
	@+ " :%w " print
	drop ;

:printdata
	$ff00ff 'ink !
	@+ " #%w " print
	drop ;

:printword | nro --
	actword =? ( $222222 'ink ! backline )
	$888888 'ink !
	dup 1 + "%d." print
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

:modeview
	0 1 gotoxy
|	dicmap
|	incmap
	$ff0000 'ink !
	mark actword ,wordinfo empty
	here emits
	wordmap

	0 hcode 1 + gotoxy
	$0000AE 'ink !
	rows hcode - 1 - backlines
	0 rows 1 - gotoxy
	"CODE" "F10" btnf

	key
	>esc< =? ( mode!src )
	<f10> =? ( mode!src )

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
	$ff00ff 'ink ! ;

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
		cols 1 >> over 1 + gotoxy
		dup 2 << 'varlist + @
		dup dic>adr @ "%w " col_var print
		dic>tok @ @ "%d" $ffffff 'ink ! print
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

|------------- sourc code

:col_inc $ff7f00 'ink ! ;
:col_com $666666 'ink ! ;
:col_cod $ff0000 'ink ! ;
:col_dat $ff00ff 'ink ! ;
:col_str $ffffff 'ink ! ;
:col_adr $ffff 'ink ! ;
:col_nor $ff00 'ink ! ;
:col_nro $ffff00 'ink ! ;
:col_select $444444 'ink ! ;

#mcolor

:wcolor
	mcolor 1? ( drop ; ) drop
	over c@
	$5e =? ( drop col_inc ; )				| $5e ^  Include
	$7c =? ( drop col_com 1 'mcolor ! ; )	| $7c |	 Comentario
	$3A =? ( drop col_cod ; )				| $3a :  Definicion
	$23 =? ( drop col_dat ; )				| $23 #  Variable
	$27 =? ( drop col_adr ; )				| $27 ' Direccion
    drop
	over isNro 1? ( drop col_nro ; ) drop
	col_nor
	;

| "" logic
:strcol
	mcolor
	0? ( drop col_str 2 'mcolor ! ; )
	1 =? ( drop ; )
	drop
	over c@ $22 <>? ( drop
		mcolor 3 =? ( drop 2 'mcolor ! ; )
		drop 0 'mcolor ! ; ) drop
	mcolor 2 =? ( drop 3 'mcolor ! ; ) drop
	2 'mcolor !
	;

#xlineat

:iniline
	0 'mcolor !
	0 'xlineat !
	xlinea wcolor
	( 1? 1 - swap
		c@+ 0? ( drop nip 1 - ; )
		13 =? ( drop nip 1 - ; )
		9 =? ( wcolor 3 'xlineat +! )
		32 =? ( wcolor )
		$22 =? ( strcol )
		drop swap ) drop ;

:emitl
	9 =? ( drop gtab ; )
	emit ccx xsele <? ( drop ; ) drop
	( c@+ 1? 13 <>? drop ) drop 1 -		| eat line to cr or 0
	wcode xcode + gotox
	$ffffff 'ink ! "." print
	;

:drawline
	iniline
	( c@+ 1?
		13 =? ( drop ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		$22 =? ( strcol )
		emitl
		) drop 1 - ;

|..............................
:linenro | lin -- lin
	dup ylinea +
	ycursor =? ( $222222 'ink ! backline )
	$aaaaaa 'ink !
	 1 + .d 3 .r. emits sp ;

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
	9 =? ( drop 4 'xcursor +! ; )
	1 'xcursor +!
	noemit ;


:cursorpos
	ylinea 'ycursor ! 0 'xcursor !
	pantaini> ( fuente> <? c@+ emitcur ) drop
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea wcode + >=? ( dup wcode - 1 + 'xlinea ! )
	drop ;

:drawcursor
	cursorpos
	blink 1? ( drop ; ) drop
	xcode xlinea - xcursor + xlineat -
	ycode ylinea - ycursor + gotoxy
	ccx ccy xy>v >a
	cch ( 1? 1 -
		ccw ( 1? 1 -
			a@ not a!+
			) drop
		sw ccw - 2 << a+
		) drop ;

:drawcursorfix
	cursorpos
	xcode xlinea - xcursor + xlineat -
	ycode ylinea - ycursor + gotoxy
	ccx 1 - ccy 1 - over
	fuente> ( c@+ $ff and 32 >? drop swap ccw + swap ) 2drop	| to end of the word
	1 + over cch + 1 + | x1 y1 x2 y2
	blink 1? ( $ffffff or ) 'ink !
	rectbox
	;

|..............................
:drawcode
	fuente>
	( pantafin> >? scrolldw )
	( pantaini> <? scrollup )
	drop

	pantaini>
	0 ( hcode <?
		0 ycode pick2 + gotoxy
		linenro
		xcode gotox
		swap drawline
		swap 1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> !
	;

|------- TAG VIEWS
| tipo/y/x/ info
| tipo(ff)-x(fff)-y(fff)
| info-tipo

#taglist * $3fff
#taglist> 'taglist


:tagpos
	over 12 >> $fff and xcode + xlinea - xlineat -
	over ycode + ylinea - gotoxy ;

:tagdec
	tagpos pick2 @ "%d" $f0f000 bprint ;
:taghex
	tagpos pick2 @ "%h" $f0f000 bprint ;
:tagbin
	tagpos pick2 @ "%b" $f0f000 bprint ;
:tagfix
	tagpos pick2 @ "%f" $f0f000 bprint ;
:tagmem
	tagpos pick2 "'%h" $f0f0 bprint ;
:tagadr
	tagpos pick2 "'%h" $f0f0 bprint ;

:tagip	| ip
	tagpos
	$ffffff 'ink !
	pick2 @ ccw *
	ccx 1 - ccy 1 - rot pick2 + 2 + over cch + 2 +
 	box.dot ;

:tagbp	| breakpoint
	blink 0? ( drop ; ) drop
	tagpos
	pick2 @ ccw *
	ccx 1 - ccy 1 - rot pick2 + 2 + over cch + 2 +
	$ff0000 'ink !
 	rectbox ;


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
	count cols swap - 1 - gotox
	infocol bprint
	;

:tagnull
	;

#tt tagip tagbp taginfo tagdec taghex tagbin tagfix tagmem tagadr
tagnull tagnull tagnull tagnull tagnull tagnull tagnull

:drawtag | adr txy y -- adr txy y
	over 24 >> $f and 2 << 'tt + @ ex ;

:drawtags
	'taglist
	( taglist> <?
		@+ dup $fff and
		ylinea dup hcode + bt? ( drawtag )
		2drop 4 + ) drop ;


#cntcr	| cnt cr from src to first token

:addtag
	code2ixy 0? ( drop ; )
	dup 24 >> incnow <>? ( 2drop ; ) drop
	$ffffff and cntcr - $2000000 or
	taglist> !+
	over swap !+ 'taglist> ! | save >info,mov
	;

:calccrs | adr src -- adr
	over @ code2src
	0 'cntcr !
	swap ( over <? c@+
		13 =? ( 1 'cntcr +! )
		drop ) 2drop ;

:maketags
	'taglist 8 + >a
	$f000000 a!+ 0 a!+ 		| only ip+bp clear bp
	a> 'taglist> !
|	incnow 3 << 'inc + 4 + @	| firs src
	dicc ( dicc> <?
		@+ calccrs @+ addtag 8 + ) drop ;

|---------------------------------
:barratop
	home
	$B2B0B2 'ink ! backline
	$0 'ink !
	" D3bug " emits

|	"INSPECT" "F2" btnf
|	"MEMORY" "F3" btnf
|	"RUN" "F4" btnf

	'namenow printr
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
	refreshfoco
	;

|vvv DEBUG  vvv

:stepdebug
	0 hcode 1 + gotoxy
	$0000AE 'ink !
	rows hcode - 1 - backlines

	$ff00 'ink !
|	'outpad sp text cr
	dup "%h" print cr

	$ffffff 'ink !
	" > " emits
	'inpad 1024 input cr
	$ffff00 'ink !
	stackprintvm cr
	regb rega " RA:%h RB:%h " print
	waitesc ;

:viewimm
	cls home cr cr cr
	here ( code> <? @+
		dup tokenprintc
		"   %h" print
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

	refreshfoco
	;

:showip
	<<ip 0? ( drop "END" print ; )
	dup @ "%h (%h)" print
	<<bp 0? ( drop ; )
	dup @ " %h (%h)" print
	;

:console
|	xsele cch op
|	wcode hcode 1 + gotoxy
|	xsele ccy pline
|	sw ccy pline
|	sw cch pline
|	$040466 'ink !
|	poli

	0 hcode 1 + gotoxy
	$0000AE 'ink !
	rows hcode - 1 - backlines

	$ff00 'ink !
    showip
	'outpad sp text cr
	$ffffff 'ink !
	" > " emits
	'inpad 1024 input cr
	$ffff00 'ink !
	stackprintvm cr
	regb rega " RA:%h RB:%h " print
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
	$ffffff and 'taglist !
	code2src dup 'fuente> !
	getsrclen 'taglist 4 + ! ;

:setbp
	fuente> incnow src2code
	dup '<<bp !
	code2ixy
	$ffffff and $1000000 or
	'taglist 8 + !
	<<bp code2src getsrclen 'taglist 12 + ! ;
	;

:play2cursor
	fuente> incnow src2code
	dup '<<bp !
	code2ixy
	$ffffff and $1000000 or
	'taglist 8 + !
	<<bp code2src getsrclen 'taglist 12 + ! ;
	;


:codetoword
	fuente> incnow src2word setword ;

|-------- view screen
:waitf6
	key >f6< =? ( exit ) drop ;

:viewscreen
	xfb> 'waitf6 onshow ;

#statevars

|-------------------------------
:modesrc
	drawcode
	drawcursor
	drawtags
	statevars 1? ( showvars ) drop

	0 rows 1 - gotoxy
	$3465A4 'ink ! backline
	"IMM" "TAB" btnf
	"PLAY" "F1" btnf
	"PLAY2C" "F2" btnf
	"ANALYSIS" "F3" btnf

	"VIEW" "F6" btnf
	"STEP" "F7" btnf
	"STEPN" "F8" btnf

	showvstack

	key
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	>esc< =? ( exit )

	<f1> =? ( playvm gotosrc )
	<f2> =? ( play2cursor playvm gotosrc )

	<f3> =? ( mode!view codetoword ) | word analisys
|	<f10> =? ( mode!view 0 +word )

	<f5> =? ( setbp )
	>f6< =? ( viewscreen )
	<f7> =? ( stepvm gotosrc )
	<f8> =? ( stepvmn gotosrc )
	<f9> =? ( 1 statevars xor 'statevars ! )
	<tab> =? ( mode!imm )


	drop
	;


#ninclude

:modeimm
	drawcode
|	drawcursorfix
	console
	showvars

	0 rows 1 - gotoxy
	$989898 'ink ! backline
	"SRC" "TAB" btnf

	"PLAY2C" "F1" btnf
	"VIEW" "F6" btnf
	"STEP" "F7" btnf
	"STEPN" "F8" btnf

	key
	>esc< =? ( exit )
	<ret> =? ( execimm )
	<tab> =? ( mode!src )

	<f1> =? ( fuente> breakpoint playvm gotosrc )
|	<f2> =? ( fuente> incnow src2code drop )

	<f6> =? ( viewscreen )
	<f7> =? ( stepvm gotosrc )
	<f8> =? ( stepvmn gotosrc )

|	<f10> =? ( mode!view 0 +word )

	drop
	;


|------ MAIN
:debugmain
	cls gui
	barratop

	emode
	0 =? ( modeimm )
	1 =? ( modeview )
	2 =? ( modesrc )
	drop

	acursor ;

|----------- SAVE DEBUG
:,printword | adr --
  	adr>toklen
	( 1? 1 - swap
		@+
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
		dup 16 - ,printword
		,cr ) drop
	"block----------" ,ln
	blok cntblk ( 1? 1 - swap
		@+ "%h " ,print
		@+ "%h " ,print ,cr
		swap ) 2drop

	"mem/map.txt" savemem
	empty ;

|--------------------- BOOT
: mark
	'name "mem/main.mem" load drop
	'name r3debuginfo
	error 1? ( drop savedebug ; ) drop
	emptyerror

	savemap | save info in file for debug

	vm2run

	'fontdroidsans13 fontm
|	fonti

|	mode!view 0 +word

	calcselect
	'name 'namenow strcpy
	src setsource

|	mode!imm
	mode!src

| tags
	'taglist >a
	$f000000 a!+ 0 a!+ | IP
	$f000000 a!+ 0 a!+ | BP
	a> 'taglist> !

	cntdef 1 - 'actword !
	resetvm
	gotosrc

	prevars | add vars to panel

	'debugmain onshow
	;

