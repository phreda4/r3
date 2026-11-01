| TUI IDE
| PHREDA 2025

^r3/util/tui.r3
^r3/util/tuiedit.r3
|^r3/lib/trace.r3

^r3/d4/r3token.r3
^r3/d4/helptxt.r3

#msg * 1024		| last line msg

#vwords 0 0
#vincs 0 0

#lwords

|---- change error mode
:moderror
	lerror tuiecursor! ;

|---- colors: the palette of the tui (util/tui.r3); the code ones are the colors of the editor (tcol)
:fBk 0 cfg ;					| dark text, for the badges of the mode
:bgBl 8 cbg ;	:bgPu 9 cbg ;	:bgGr 10 cbg ;	:bgRd 11 cbg ;

:printfname
	'filename .write .sp ;

:makelistwords
	here dup 'lwords !
	dic< 
	|dic
	( dic> <? | solo codigo principal
		dup dic - 4 >> 1+ rot w!+ swap
		16 + ) drop
	0 swap w!+ 'here ! ;

|---------- TAGS in code	
| $..............01 - code/data
| $..............02 - loc/ext
| $..............04	1 es usado con direccion
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva
| $..............40	1 si tiene anonimas
| $..............80	1 termina sin ;

:wordhead
	nro>dic @+ 
	1 and? ( 4 tcol .fc dic>name "#%w" ,print ,eol drop ; ) 
	3 tcol .fc 
	dup 
	dic>name ":%w | " ,print 
	|$5b1b ,w "30;1m" ,s "|" ,s
	swap @ 
	dup $ff and 8 << swap 8 >> $ff and or hw.effab ,s
	"  " ,s
	$10 and? ( ";" ,s )	| multiple
	$20 and? ( "R" ,s )	| recurse
	$80 and? ( "." ,s )	| no ;
	drop
	,eol ;
	
:xwriten.word | n --
	1- $ffff and 
	|cntdicc >=? ( drop "" lwrite ; ) 
	mark wordhead empty here lwrite ;
	
|---- helpword
#helpword * 32

:cpyhword | adr -- 
	'helpword 
	31 ( 1? 1- -rot		| copy word
		swap c@+ $ff and 
		32 <=? ( 2drop 0 swap c! drop ; )
		rot c!+ rot
		) drop
	0 swap c! 
	drop ;

:<<sp | adr -- adr' ; adr@=space
	( dup 1- c@ $ff and 32 >? drop 1- ) drop ;
	
:cpyhelpword
	fuente> <<sp cpyhword ;

:<<: | adr -- adr' ; adr@=:
	( fuente =? ( ; ) dup 1- c@ 
		$3a <>? | :
		$23 <>? | #
		drop 1- ) drop ;

:cpydefword 
	fuente> <<: cpyhword ;
	
:searchword | -- nro
	cntdef ( 1? 1-
		dup nro>dic @ dic>name
		'helpword =w 1? ( drop ; )
		drop ) ;
	
|---- screen
#nowword

:setcursoride
	vwords uiNindxn 1-
	dup 'nowword !
	nro>dic @
	|40 >> src + "%l" sprint 'msg strcpy 
	40 >>> fuente + |1- | :#
	tuiecursor!	
	;
		
|---- CHECKCODE
:cntlines | -- nrolin
	1 fuente 
	( lerror <?
		c@+ 13 =? ( rot 1+ -rot ) drop
		) drop ;
		
:coderror | error --
	.cl bgRd fBk lerror " %w | " .print
	.write cntlines " in line %d" .print 
	.eline
	'msg strcpybuf ;
	
:codeok
	.cl
	cnttok cntdef cntinc " OK | inc:%d words:%d tokens:%d" .print 
	.eline
	'msg strcpybuf ;

:checkcode
	TuSaveCode
	0 'msg !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop 
	codeok 
	;
	
|--- F3 Fx
#vanaly 0 0
#lanaly * $ffff

|#bmacro .l .l .word .wadr .var .vadr .str 

:tok2str | tok -- str
	$ff and 6 >? ( 7 - basename ; ) drop
	dup 40 >>> src + "%w" sprint
	|3 << 'bmacro + @ ex 
	;
	
:,scnt | str cnt --
	swap utf8count					| cnt str scount
	pick2 >? ( drop over ) swap	| cnt scnt str
	here pick2 utf8ncpy 'here !
	- ,nsp ;
	
:buildline | token --
	dup tok2str		| tok str
	20 ,scnt
	tokeninfo	
	wwinfo 
	dup 32 >> $f and swap
	
	16 >> $ff and |,ncar
	" %h %d" ,print 
	
	0 ,c
|	deltaD $ff and 8 << 
|	usoD $ff and or 8 << 
|	deltaR $ff and or ;
	;
	
:setanalysis
	mark
	'lanaly 'here !
	resetinfo
	nowword nro>dic
|	dup "%d >> " ,print
|	dup @ dic>name "%w" ,print 0 ,c
	toklen | tok len
	( 1? 1- swap
		@+ buildline
		swap ) 2drop
	0 ,c
	empty
	0 'vanaly !	
	;
	
#modefx
:fxlist
	cols 2/ flxE | 1/4 of screen
	.reset bg1 fPu
	tuwina $1 " Rx " .wtitle fTx 1 1 flpad .wfill 
	'xwriten.word xwriten!
	'vwords lwords tuListn | 'var list --
	tuX? 1? ( setcursoride ) drop
	xwrite.reset
	;

:fxword
	cols 2/ flxE
	.reset bg1 fPu
	tuwina $1 " Word " .wtitle fTx 1 1 flpad .wfill 
	'vanaly 'lanaly tuList | 'var list --
|	tuX? 1? ( setcursoride ) drop
	;

#modelfx fxlist fxword


:rxmode | -- "text" ; the mode of F3: the list of the words or the analysis of one
	modefx 0? ( drop " F3 RX list " ; ) drop " F3 RX word " ;

:fxwin
	.reset
	1 flxN 
	bg3 fTx fhome
	bgPu fBk rxmode .write bg3 fTx .sp
	printfname 
	" | " .write tuecursor. .write .sp
	'helpword .write
	.eline
	
	1 flxS 
	bg3 fhome 
	fPr " ESC" .write fTx " Exit" .write 
	fPr " ENTER" .write fTx " Word" .write 
	fPr " BACK" .write fTx " Dicc" .write 
	fTx " | " .write 'helpword .write " | " .write
	'msg .write
	.eline
	
	modefx 3 << 'modelfx + @ ex
	
	flxRest 
	tuReadCode
	
	uiKey
	[esc] =? ( exit ) 
	[enter] =? ( setanalysis 1 'modefx ! )
	[back] =? ( modefx 0? ( exit ) drop 0 'modefx ! )
	drop ;

:setvwords | nrow --
	lwords ( w@+ 1?
		pick2 =? ( drop nip lwords - 1 >> 'vwords ! ; ) 
		drop ) 2drop 
	0 'vwords ! ;
	
:fxcode
	checkcode error 1? ( drop moderror ; ) drop
	cpydefword
	'helpword c@ 0? ( drop "DEFINITION NOT FOUND" 'helpword strcpy ; ) drop
	makelistwords
	searchword dup 'nowword ! setvwords
	setanalysis
	0 'modefx !
	'fxwin onTui
	0 'uikey !
	tuR!
	;
	
|-------------------------------	
:runcode
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls .flush
	'filename r3run
	.reterm .alsb .flush
	|here dup "error.log" load over =? ( 2drop ; ) 0 swap c!
	|drop "** error **" 'msg strcpy
	tuR!
	;

:debugcode
	checkcode error 1? ( drop moderror ; ) drop
	|.masb .reset .cls .flush
	"r3/d4/r3debug.r3" r3run
	.reterm .alsb .flush 
	tuR! ;

|------- old
:fileplain
	checkcode error 1? ( drop moderror ; ) drop
	"r3/editor/r3plain.r3" r3run
	tuR! ;
|------- old

:fileplaino
	checkcode error 1? ( drop moderror ; ) drop
	"r3/d4/r3plain.r3" r3run
|	.reterm .alsb .flush 
	"r3/d4/gen/plain.r3" r3run | exec
	tuR! ;

:filecompile
	checkcode error 1? ( drop moderror ; ) drop
	"r3/system/r3compiler.r3" r3run
	|.reterm .alsb .flush 
	tuR! ;

:filecompileo
	checkcode error 1? ( drop moderror ; ) drop
	|"r3/d4/r3plain.r3" r3run
	"r3/d4/r3wincomp.r3" r3run
	|.reterm .alsb .flush 
	tuR! ;

|-------------------------------

:compile
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls
	"Building" .println
	"Code: " .write 'filename .write .cr .cr
	cntinc " includes:%d |" .print
	cntdef " words:%d |" .print
	cnttok " tokens:%d" .println
	.cr .cr
	cols .hline
	"[f2] Win64exe [f3] Plain " .write .cr
	cols .hline
	.reset .cr
	getch 
	[f2] =? ( filecompile )
	[f4] =? ( filecompileo )
	
	[f3] =? ( fileplaino ) 
	[f5] =? ( fileplain ) | dev
	
	drop
	.alsb
	;
	

|--- F2 help: the help lines of the word under the cursor (helptxt.r3, meta/mhelp.txt)
#infohelp * 128
#hwlist * 256		| the lines of the word (the same name can be in more than one library)
#hwcnt 0
#hweff * 128

:hwword | -- "word" ; the word under the cursor, without the ' of an address
	'helpword c@ $ff and $27 =? ( drop 'helpword 1+ ; ) drop 'helpword ;

:hwadd | n -- n
	hwcnt 32 >=? ( drop ; ) drop
	dup hwcnt 3 << 'hwlist + ! 1 'hwcnt +! ;

:hwfind | -- ; the lines of the word
	0 'hwcnt !
	hwword hw.find
	( +? hwadd hwword swap hw.next ) drop ;

:hwdesc | n -- n ; the description of the line, if it has one
	dup hline hw.desc dup c@ $ff and 0? ( 2drop ; ) drop
	fMu "  %s" sprint .lw ;

:helpone | n -- ; name  effect  < library, and the description
	fTx dup hline 'hweff 100 hw.eff
	dup hw.where 'hweff pick2 hline "%w  %s   < %s" sprint .lw
	hwdesc fcr drop ;

:helplist | -- ; the lines of the word, 3 rows each
	hw.count 0? ( drop fMu "mhelp.txt is not ready (run metabuild.r3 and metahelp.r3)" .lw ; ) drop
	hwcnt 0? ( drop fMu 'helpword "no help for: %s" sprint .lw ; ) drop
	fh 3 / hwcnt min
	0 ( over <? dup 3 << 'hwlist + @ helpone 1+ ) 2drop ;


:helpc
	.reset
	1 flxN 
	bg3 fTx fhome
	bgBl fBk " F2 HELP " .write bg3 fTx .sp
	printfname 
	" | " .write tuecursor. .write 
	.eline
	
	1 flxS 
	bg3 fhome
	fPr " ESC" .write fTx " Exit help" .write 
	fTx " | " .write 'helpword .write " | " .write
	'infohelp .write
	'msg .write
	.eline
	rows 2 >> flxN | 1/4 of screen
	tuReadCode
	flxRest
	.reset bg1 fBl
	tuwina $1 " Help " .wtitle fTx 1 1 flpad .wfill 
	fhome helplist
	
	uiKey
	[esc] =? ( exit ) 
	drop ;

:helpcode
	cpyhelpword hwfind
	hwcnt "found: %d" sprint 'infohelp strcpy
	'helpc onTui ;
	
:helpdlg
	"r3IDE Help" 52 17 tuDlg
	fcr
	"F2 Word help   F3 Rx analysis" .cw
	"F4/ctrl+R Run   F5/ctrl+D Debug   F10 Build" .cw
	fcr
	"ctrl+F Find   ctrl+N Next   ctrl+P Prev" .cw
	"ctrl+W Find the word under the cursor" .cw
	"ctrl+G Go to definition   ctrl+T Back" .cw
	"(the places are in a stack: back:n in the bar)" .cw
	fcr
	"ctrl+X Cut   ctrl+C Copy   ctrl+V Paste" .cw
	"ctrl+Z Undo   ctrl+Y Redo" .cw
	fcr
	"ctrl+H Help   ctrl+Q or ESC Quit" .cw
	tuDlgEnd
	uikey
	[esc] =? ( exit )
	drop ;
	
|-------------------------------
#barx 0 #bary 0 #barw 0

:stackind | -- ; the state of the return stack (ctrl+T), at the right end of the bottom bar
	barw 64 <? ( drop ; ) drop
	barx barw + 9 - bary .at
	bg3 fDi tuejdepth 1? ( fPr ) drop
	"back:" .write
	tuejdepth "%d" sprint .write ;

:main
	.reset
	1 flxN 
	bg3 fTx fhome
	bgGr fBk " EDIT " .write bg3 fTx " r3IDE | " .write printfname 
	" | " .write tuecursor. .write 
	|'helpword .write
	" | " .write 'msg .write
	.eline
	
	1 flxS 
	bg3 fhome
	fx 'barx ! fy 'bary ! fw 'barw !
	fPr " ^R" .write fTx "un" .write 
	fPr " ^D" .write fTx "ebug" .write 
	fPr " F10" .write fTx " build" .write 
	fPr " ^F" .write fTx "ind" .write 
	fPr " ^W" .write fTx "ord" .write 
	fPr " ^G" .write fTx "oto" .write 
	fPr " ^T" .write fTx "back" .write 
	fPr " ^H" .write fTx "elp" .write 
	.eline
	flxRest
	tuEditCode
	stackind
	
	uiKey
	[f2] =? ( helpcode )
	[f3] =? ( fxcode )
	[f4] =? ( runcode )
	[f5] =? ( debugcode )
	[f6] =? ( cpyhelpword )
	[f10] =? ( compile )
	
	| ctrl
	|$2 =? ( buildcode ) 	|+b
	
	$4 =? ( debugcode ) 		| ctrl+d debug
	$8 =? ( 'helpdlg onTui )	| ctrl+H Help	
	|$B =? ( ) |K	
	$11 =? ( exit )				| ctrl+q quit
	$12 =? ( runcode )	| ctrl+r run	
	[esc] =? ( exit ) 
	drop ;

|-----------------------------------
: 
	.alsb
	'filename "mem/menu.mem" load drop
	|"r3/test/testasm.r3" 'filename strcpy
	
	hw.load drop
	
	'filename TuLoadCode
	|TuNewCode
	mark
	5 tuEditLN!
	'main onTui 
	TuSaveCode 
;
