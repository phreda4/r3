| edit-code
| PHREDA 2007
|---------------------------------------
^r3/win/console.r3
^r3/win/mconsole.r3
^r3/lib/math.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

^r3/lib/trace.r3

^r3/d4/r3edit.r3
^r3/d4/r3token.r3
^r3/d4/r3imm.r3

#hashfile 
#srcname * 1024

|----- scratchpad
#outpad * 2048

#lerror 0
#cerror 0

#statfile 0 | 0:no info 1:error 2:info
#modoe 0	| modo edit
#escnow 0

#iniinc
#nowinc
#inidic 0
#nowdic

:dic+! | v --
	nowdic + cntdef 1 - clamp0max 
	inidic <? ( dup 'inidic ! )
	inidic hcode + 1 - >=? ( dup hcode - 1 + 'inidic ! ) 
	'nowdic !
	;

:inc+! | v --
	nowinc + cntinc 1 - clamp0max 
	iniinc <? ( dup 'iniinc ! )
	iniinc hcode + 1 - >=? ( dup hcode - 1 + 'iniinc ! ) 
	'nowinc !
	;
|------------------------------------------------
##path * 1024

:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
:loadtxt | -- ; cargar texto
	fuente 'srcname load 0 swap c!
	fuente only13 1 - '$fuente !	|-- queda solo cr al fin de linea
	fuente dup 'pantaini> ! simplehash 'hashfile !
	;

:savetxt | -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	
	fuente ( c@+ 1? 13 =? ( ,c 10 ) ,c ) 2drop
	'srcname savemem
	empty ;

|----------------------------------
:loadinfo
	linecomm "mem/infomap.db" load 
	0 $fff rot !+ !+ 'linecomm> ! ;
	
:clearinfo
	linecomm 8 +
	0 $fff rot !+ !+ 'linecomm> ! ;

:linetocursor | -- ines
	0 fuente ( fuente> <? c@+
		13 =? ( rot 1 + rot rot ) drop ) drop ;
		
:r3info
	rows 1 - 'hcode !
	0 'outpad !
	0 'cerror !
	
	mark
|... load file info.
	here "mem/debuginfo.db" load 0 swap c!
	here >>cr trim str>nro 'cerror ! drop
	empty

	loadinfo
	cerror 0? ( drop ; ) drop
|... enter error mode
	fuente cerror + 'fuente> !
	linetocursor 'lerror !
	here >>cr 0 swap c!
	fuente> lerror 1 + here
	" %s in line %d (%w)" sprint 'outpad strcpy
	
	rows 2 - 'hcode !
	;
	

:runfile
	savetxt
	.masb .reset .cls
	mark
|WIN|	"r3 "
|LIN|	"./r3lin "
|RPI|	"./r3rpi "
	,s 'srcname ,s ,eol
	empty here sysnew | <<<<<<<<< new terminal
	.reset .alsb ;


:mkplain
	.masb .reset .cls
	savetxt
|WIN| "r3 r3/d4/r3plain.r3"
	sys
	.alsb
|WIN|	"r3 r3/d4/gen/plain.r3"
|LIN|	"./r3lin r3/d4/gen/plain.r3"
|RPI|	"./r3rpi r3/d4/gen/plain.r3"
	sys
	;

:compile
	.masb .reset .cls
	savetxt
|WIN| "r3 r3/system/r3compiler.r3"
|LIN| "./r3lin r3/system/r3compiler.r3"
|RPI| "./r3rpi r3/system/r3compiler.r3"
	sys
	.alsb
|	r3info
	;

|-------------------------------------------
#incnow
#srcstack * $fff
#srcstsck> 'srcstack

:pushcode | inc --
	4 << 'inc + 8 + @ 
	$ffffffff and src + 
	code-set
	;

:popcode
	|code-set
	;
	
:tok2inc | tok -- tok srcinc
	'inc ( inc> <?
		8 + @+
		dup 32 >> 
		) drop
	src
	;
	
:cursor2ip
	<<ip 0? ( drop ; )
	
	@ 40 >>> src + 'fuente> ! ;

| statfile 0:no data 1:error 2:ok-allinfo

:tokensrc
	empty mark
	fuente 'srcname r3loadmem
	error 1? ( drop 1 'statfile ! ; ) drop
	2 'statfile ! 
|	lidiset
|	liinset
|	$ffff 'here +!
	resetvm
	cursor2ip
	
	cntinc 1 - 'nowinc !
	cntdef 1 - 'nowdic !

|	mark
|	'srcname ,s ,cr ,cr
|	debugmemmap
|	"r3/d4/gen/map.txt" savemem
|	empty
	;	
	
:tokensrc?
	statfile 2 =? ( drop ; ) drop
	tokensrc ;
	
:modoclear
	0 'statfile ! 
	;
	
|----------------------
|#modolist modoeditor mododictionary modoimmediate mododebug

:modoedit
	rows 1 - 'hcode !
	0 'modoe !
	;
	
:mododic
	tokensrc?
	rows 8 - 'hcode !	
	0 dic+!
	0 inc+!	
	1 'modoe !
	;
	
:modoimm
	tokensrc?
	rows 8 - 'hcode !
	2 'modoe ! 
	'pad immset
	;

:mododeb
	tokensrc?
	rows 8 - 'hcode !
	3 'modoe ! 
	'pad immset
	;
	
|-------------
| Edit CtrE
|-------------
:posfijo? | adr -- desde/0
	( c@+ 1?
		46 =? ( drop ; )
		drop )
	nip ;

:editvalid | adr -- adr 1/0
    "ico" =pre 1? ( ; ) drop
    "bmr" =pre 1? ( ; ) drop
    "vsp" =pre 1? ( ; ) drop
    "spr" =pre
	;

#ncar
:controle
	savetxt
	fuente> ( dup 1 - c@ $ff and 32 >? drop 1 - ) drop | busca comienzo
	dup c@
	$5E <>? ( 2drop ; ) | no es ^
	drop
	dup fuente - 'ncar !
	dup 2 + posfijo? 0? ( 2drop ; )
	editvalid 0? ( 3drop ; ) drop
	swap 1 + | ext name
	mark
	dup c@ 46 =? ( swap 2 + 'path ,s ) drop
	,word
|	dup "mem/inc-%w.mem" sprint savemem
	empty
|	"r4/system/inc-%w.txt" sprint run
	drop
	;

|-------------
:controlc | copy
	copysel ;

|-------------
:controlx | move
	controlc
	borrasel ;

|-------------
:controlv | paste
	clipboard clipboard> over - 0? ( 3drop ; ) | clip cnt
	fuente> dup pick2  + swap | clip cnt 'f+ 'f
	$fuente over - 1 + cmove>	| clip cnt
	fuente> rot rot | f clip cnt
	dup '$fuente +!
	cmove
	clipboard> clipboard - 'fuente> +!
	;

|-------------
:controlz | undo
	undobuffer>
	undobuffer =? ( drop ; )
	1 - dup c@
	9 =? ( drop 1 - dup c@ [ -1 'fuente> +! ; ] >r )
	lins 'undobuffer> ! ;

|-------------
:=w | w1 w2 -- 1/0
	( c@+ 32 >?
		toupp rot c@+ toupp rot - 1? ( 3drop 0 ; ) drop swap ) 3drop 1 ;

:exactw | adr 1c act cc -- adr 1c act 1/0
	drop dup pick3 =w ;

:setcur | adr 1c act 1
	drop nip nip 'fuente> ! ;

:findprev | -- ;find prev
	'pad
	dup c@ $ff and
	0? ( 2drop ; )
	toupp
	fuente> 1 - | adr 1c act
	( fuente >?
		dup c@ toupp pick2 =? ( exactw 1? ( setcur ; ) )
		drop 1 - ) 3drop ;

:findnext | -- ;find next
	'pad
	dup c@ $ff and
	0? ( drop ; )
	toupp
	fuente> 1 + | adr 1c act
	( $fuente <?
		dup c@ toupp pick2 =? ( exactw 1? ( setcur ; ) )
		drop 1 + ) 3drop ;

:cursorwstart | -- pos>
	fuente> 
	dup c@ $ff and 32 <=? ( drop trim ; ) drop 
	( fuente =? ( ; )
		dup 1 - c@ $ff and 32 >? drop 1 - ) drop | busca comienzo
	;
	
| current word to search
:controls
	'pad cursorwstart copynom
	findprev
	;
	
|-------------
:controld | buscar definicion
	;

:controln  | new
	| si no existe esta definicion
	| ir justo antes de la definicion
	| agregar palabra :new  ;
	;
	
|-------------- panel control
#panelcontrol

:controlon	1 'panelcontrol ! ;
:controloff 0 'panelcontrol ! ;

|---------- manejo de teclado
:buscapad
	fuente 'pad findstri
	0? ( drop ; ) 'fuente> ! ;

:findmodekey
	1 hcode 1 + .at .eline
	" > " .write .input
	findnext
	;

|------------------------
:barraf | F+
	" ^[7mF1^[27m Run ^[7mF2^[27m Debug ^[7mF3^[27m Profile ^[7mF4^[27m Plain ^[7mF5^[27m Compile" ,printe ;

:barrac | control+
	" ^[7mX^[27mCut ^[7mC^[27mopy ^[7mV^[27mPaste ^[7mF^[27mind | " ,printe
	" ^[7mD^[27mefinition ^[7m<-^[27m ^[7m->^[27m | " ,printe
	" ^[7mQ^[27m<File ^[7mW^[27m>Fike " ,printe	
	'pad
	dup c@ 0? ( 2drop ; ) drop
	" [%s]" ,print ;

:botbar
	1 hcode 2 + ,at ,bblue ,white ,eline
	panelcontrol
	0? ( drop barraf ; ) drop
	barrac ;

| statfile 0:no data 1:error 2:ok-allinfo
:topbar
	1 1 ,at 
	,bblue ,white ,eline
	" r3d4 " ,s
	statfile "^[4%dm" ,printe | show color mode in name
	,sp 'srcname ,s ,sp ,bblue
	
	ycursor xcursor " %d:%d " ,print 
	$fuente fuente - " %d " ,print 
	clipboard> clipboard - " %d " ,print
	mshift " %d " ,print
	| error-
	cerror 0? ( drop ; ) drop
	1 hcode 3 + ,at ,bred ,white ,eline 'outpad ,s
	;

#exit 0

| SCANCODES
| Q : $10 ..
| A : $1e ..
| Z : $2c ..
:controlkey
	$101d =? ( controloff ) |>ctrl<
	$1000 and? ( drop ; )	| upkey
	$ff and
	$2c =? ( controlz )	| Z-Undo
	$2d =? ( controlx )	| x-cut
	$2e =? ( controlc )	| c-copy
	$2f =? ( controlv )	| v-paste
	
	$12 =? ( controle ) | E-Edit
|	$23 =? ( controlh ) | H-Help
	
| A - HELP?
	$10 =? ( modoimm controloff )
	$11 =? ( mododic controloff )
	$12 =? ( mododeb controloff ) 
	
	$1f =? ( controls ) | S - Search word
	$20 =? ( controld ) | D- search definition
	$21 =? ( findmodekey )	| f-find text
| Q - prev file
| W - next file	
	$31 =? ( controln ) | N-New
|	$32 =? ( controlm ) | M-Mode
	$48 =? ( findprev )		| up-prev find
	$50 =? ( findnext )		| dn-next find
	drop
	;

:evkey	
	evtkey
	$1B1001 =? ( escnow 1? ( 0 'escnow ! 2drop ; ) drop 1 'exit ! )
	panelcontrol 1? ( drop controlkey ; ) drop
	
	code-key

	$1d =? ( controlon ) 
	
	$2a =? ( 1 'mshift ! ) $102a =? ( 0 'mshift ! ) | shift der
	$36 =? ( 1 'mshift ! ) $1036 =? ( 0 'mshift ! ) | shift izq 

	$3b =? ( tokensrc )		| f1 - compiler/run
|	$3c =? ( debugfile )	| f2 -
|	$3d =? ( profiler )		| f3 -
	$3e =? ( mkplain )		| f4 -
	$3f =? ( compile )		| f5 -
	drop ;
	
::>>cr | adr -- adr'
	( c@+ 1? 13 =? ( drop ; ) drop ) drop 1 - ;
	
:xycursor | x y -- cursor
	pantaini> | x y c
	( swap 1? 1- swap >>cr ) drop | x c
	swap 5 - clamp0 swap
	( swap 1? 1- swap c@+
		9 =? ( rot 2 - clamp0 rot rot )
		13 =? ( 0 nip )
		0? ( drop nip 1 - ; ) 
		drop ) drop ;
		
:evmouse
	evtmb $0 =? ( drop ; ) drop 
	evtmxy 1 <? ( 2drop ; )
	1 - xycursor 'fuente> ! ;

:evsize	
	.getconsoleinfo
	rows 1 - 'hcode !
	cols 7 - 'wcode !
	;

:modoeditor
	mark			| buffer in freemem
	,hidec ,reset ,cls
	topbar code-draw botbar
	cursorpos ,showc
	memsize type	| type buffer
	empty			| free buffer
	getevt
	$1 =? ( evkey )
	$2 =? ( evmouse )
	$4 =? ( evsize )
	drop 
	;


|--------------- DICC

#colpal ,red ,magenta

::,col "%dG" sprint ,[ ; | x y -- 

:info1 | n --
	|dup "%h " ,print
	,reset
	" " ,s
	dup 1 and 3 << 'colpal + @ ex
	|dup $3 and 1 << " ::: ###" + c@+ ,c c@ ,c
	dup 40 >>> src + "%w " ,print
	
	|dup 16 >> $ffffff and pick2 8 + @ 16 >> $ffffff and swap - "%d " ,print
	drop
	;
	
:info2 | n --
	,reset dup "| " ,s ,mov 
	
|	dup $ff and "%d " ,print		| duse unsigned
|	dup 48 << 56 >> "%d " ,print	| ddelta signed	
|	40 ,col
	dup 16 >> $ffff and " %d " ,print	| calls
|	9 ,c
|	dup 32 >> " %d " ,print			| len
	drop
|	dup @ 16 >> $ffffff and over 16 - @ 16 >> $ffffff and - "%d " ,print
|	dup 16 - toklend nip " %d" ,print | len for data
	;
	
:dicword | nro --
	cntdef >=? ( drop ; )
	,reset
	nowdic =? ( ,rever )
	dup " %d." ,print
	4 << dic + 
	@+ info1
	@+ info2
	drop
	;

:incline
	cntinc >=? ( drop ; )
	,reset
	nowinc =? ( ,rever )
	dup 4 << 'inc + @ " %w " ,print | name
	dup 4 << 'inc + 8 + @ " %h" ,print | name
	drop
	| cntwords
	;

:evkey | key -- key
	evtkey
	$1B0001 =? ( modoedit 1 'escnow ! )
	$1000 and? ( drop ; )	| upkey
	$ff and	
	$48 =? ( -1 dic+! )		| up
	$50 =? ( 1 dic+! )		| dn
	$49 =? ( -1 inc+! )		| pgup
	$51 =? ( 1 inc+! )		| pgdn
	
	$3b =? ( nowinc pushcode modoedit ) | f1
	$3c =? ( popcode )
	drop ;

	
:mododictionary
	mark			| buffer in freemem
	,hidec ,reset ,cls
	topbar 
	0 ( hcode <?
		1 over 2 + ,at
		dup inidic + dicword
		1+ ) drop
	0 ( hcode <? 
		wcode 1 >> over 2 + ,at
		dup iniinc + incline
		1+ ) drop
		
	,showc
	memsize type	| type buffer
	empty			| free buffer
	getevt
	$1 =? ( evkey )
|	$2 =? ( evmouse )
	$4 =? ( evsize )
	drop 	
	;

|--------------- MAIN IMMEDIATE
:enterline
|	'pad vmparse
|	vmclear
|	vmrun
	immclear
	;
	
:evkey | key -- key
	evtkey
	$1000 and? ( drop ; )	| upkey	
	$1B0001 =? ( modoedit 1 'escnow ! )
	immevkey 
	$1c =? ( enterline )
	drop ;
	
:modoimmediate
	mark			| buffer in freemem
	,hidec ,reset ,cls
	topbar code-draw 
	botbar
	cursorpos 
	1 hcode 3 + ,at
	,reset
	regb rega <<ip "IP:%h RA:%h RB:%h " ,print ,nl
	"D) " ,s ,stack ,nl
	"> " ,s ,immline 
	,showc
	memsize type	| type buffer
	empty			| free buffer
	getevt
	$1 =? ( evkey ) 
|	$2 =? ( evmouse )
	$4 =? ( evsize )
	drop 	
	;

|--------------- DEBUG
	
:evkey | key -- key
	evtkey
	$1000 and? ( drop ; )	| upkey	
	$1B0001 =? ( modoedit 1 'escnow ! )
|	immevkey 
|	$1c =? ( enterline )
	$3b =? ( stepvm cursor2ip ) |f1
	$3c =? ( stepvmn cursor2ip ) |f2
	drop ;

:mododebug
	mark			| buffer in freemem
	,hidec ,reset ,cls
	topbar code-draw 
	botbar
	cursorpos 
	1 hcode 3 + ,at
	,reset
	regb rega <<ip "IP:%h RA:%h RB:%h " ,print ,nl
	"D) " ,s ,stack ,nl
	"> " ,s ,immline 
	,showc
	memsize type	| type buffer
	empty			| free buffer
	getevt
	$1 =? ( evkey ) 
|	$2 =? ( evmouse )
	$4 =? ( evsize )
	drop 	
	;
	
|--------------- MAIN EDITOR
#modolist modoeditor mododictionary modoimmediate mododebug

:runeditor
	0 'statfile !
	rows 1 - 'hcode !
	cols 7 - 'wcode !
	( exit 0? drop 
		modoe 3 << 'modolist + @ ex
		) drop ;

|---- Mantiene estado del editor
:ram
	code-ram
	modoedit
	loadtxt
	
	fuente code-set
|	loadinfo
	mark 
	;

|----------- principal
:
	'srcname "mem/main.mem" load drop
	ram
	evtmouse
	.getconsoleinfo
	.alsb .showc .insc
	runeditor
	.masb
|	savetxt |  save only main?
	;
