| r3build - build center: target, inline level, plain / compile
| the code is the one selected in main.r3 (mem/menu.mem)
| PHREDA 2026
|
| options (buildopt.r3) are saved in mem/build.mem for r3plain.r3

^r3/util/tui.r3
^r3/d4/r3token.r3
^r3/d4/buildopt.r3

#bfile * 1024		| source file
#msg * 128			| last message

#osn "WIN" "LIN" "MAC" "RPI"

|---- info of the loaded code
#ncode #ndata #nrec #nanon #nshort
#lastinl -1

:statword | nro --
	nro>dic @+ swap @ 32 >>>		| info1 len
	swap 1 and? ( 2drop 1 'ndata +! ; )
	$20 and? ( 1 'nrec +! )
	$40 and? ( 1 'nanon +! )
	drop
	bo.inline <=? ( bo.inline 1? ( 1 'nshort +! ) drop )
	drop 1 'ncode +! ;

:calcstats
	0 'ncode ! 0 'ndata ! 0 'nrec ! 0 'nanon ! 0 'nshort !
	0 ( cntdef <? dup statword 1+ ) drop
	bo.inline 'lastinl ! ;

|---- includes: inc table = 'name | first definition (32<<) + source offset
:incfirst | e -- n ; first definition of the file
	4 << 'inc + 8 + @ 32 >>> ;

:incend | e -- n ; first definition after the file
	1+ cntinc <? ( incfirst ; ) drop cntdef ;

:incname | e -- str
	4 << 'inc + @ ;

:ndefin | e -- n ; definitions of the file
	dup incend swap incfirst - ;

:incline | e --
	here over incname ,word here swap -
	30 swap - 1 max ,nsp
	ndefin "%d" ,print ,eol ;

#lincs 0			| list of includes (main file first)
#lwords 0			| list of words (w) of the selected include
#wmark 0
#vincs 0 0
#vwords 0 0
#lastinc -1

:makeincs
	here 'lincs !
	cntinc 1- ( 0 >=? dup incline 1- ) drop
	,eol ;

:makewords
	wmark 'here !
	here 'lwords !
	cntinc 1- vincs -
	dup incfirst swap incend swap
	( over <? dup 1+ ,w 1+ ) 2drop
	0 ,w
	0 'vwords ! 0 'vwords 8 + ! ;

|---- text of a definition
:wordtxt | nro --
	nro>dic @+ | 'wd wf
	":#" over 1 and + c@ ,c | 'wd wf
	dup dic>name ,word 2 ,nsp | 'wd wf
	1 and? ( drop 8 - toklend nip "%d tk" ,print ; ) 
	over 8 - toklen nip " %d tk" ,print
	swap @ 16 >> $ffff and " %d cl" ,print
	$10 and? ( " ;" ,s ) 
	$20 and? ( " R" ,s ) 
	$40 and? ( " []" ,s ) 
	$80 and? ( " ." ,s ) 
	drop ;
		
:xword | w n --
	1- mark wordtxt ,eol empty here lwrite ;

:curword | -- nro+1 (0 none)
	lwords 0? ( ; ) vwords 1 << + w@ ;

|---- load
:loadinfo
	0 0 error!
	'bfile r3load
	0 'ncode ! 0 'ndata ! 0 'nrec ! 0 'nanon ! 0 'nshort !
	0 'lwords ! -1 'lastinc !
	0 'vincs ! 0 'vincs 8 + !
	error 1? ( drop ; ) drop
	calcstats
	makeincs
	here 'wmark ! ;

:reload
	empty empty mark
	loadinfo ;

|---- build
:backtui
	.reterm .alsb .flush tuR! ;

:genplain
	bo.save
	"r3/d4/gen/plain.r3" delete
	.masb .reset .cls .flush
	"r3/d4/r3plain.r3" r3run ;

:plainok? | -- 0/1
	"r3/d4/gen/plain.r3" filexist ;

:doplain
	error 1? ( drop ; ) drop
	genplain
	.reterm .cr
	plainok? 0? ( drop "plain.r3 FAILED" 'msg strcpy ; ) drop
	"plain.r3 generated" 'msg strcpy
	'msg .println
|	"press any key to continue..." .println
|	waitkey
	"r3/d4/gen/plain.r3" r3run
	backtui ;

:docompile
	bo.target 1? ( drop "Compile: only the WIN target for now" 'msg strcpy ; ) drop
	error 1? ( drop ; ) drop
	genplain
	plainok? 0? ( drop
		.reterm .cr "plain.r3 FAILED - press any key..." .println waitkey
		"plain.r3 FAILED" 'msg strcpy
		backtui ; ) drop
	"r3/d4/r3comp.r3" r3run
	"compile done" 'msg strcpy
	backtui ;

|---- focus by panel: Tab / Shift+Tab change panel, up / down move inside the first four
|     widgets of each panel, in draw order: Target 0-3, Inline 4-8, Budget 9-12, Build 13-14, Files 15, Definitions 16
#pstart 0 4 9 13 15 16 17

:pstart@ | n -- id
	3 << 'pstart + @ ;

:npanels | -- n		; Files and Definitions are not drawn when the code has an error
	error 1? ( drop 4 ; ) drop 6 ;

:curpanel | -- n
	0 ( dup 1+ pstart@ tuFocus <=? drop 1+ ) drop ;

:gopanel | n --
	pstart@ tuFocus! ;

:ptab | dir --
	curpanel +
	-? ( drop npanels 1- gopanel ; )
	npanels >=? ( drop 0 gopanel ; )
	gopanel ;

:pstep | dir --
	curpanel 4 >=? ( 2drop ; )
	dup pstart@ swap 1+ pstart@ rot tuFocus +
	pick2 <? ( drop 1- nip tuFocus! ; )
	over >=? ( 2drop tuFocus! ; )
	nip nip tuFocus! ;

|---- screen
:lbl | "" --
	fMu .write fTx ;

:cntlines | -- line
	1 src ( lerror <? c@+ 13 =? ( rot 1+ -rot ) drop ) drop ;

:errinfo
	fRd error .write fcr
	fTx "line " .write cntlines .d .write
	"  near: " .write lerror "%w" .print fcr ;

:srcinfo
	"Source" pan
	'bfile .write fcr
	error 1? ( drop errinfo ; ) drop
	"target " lbl 'osn bo.target n>>0 .write
	"   inline <= " lbl bo.inline "%d tokens" .print
	"   budget x" lbl bo.budget "%d" .print
	bo.unroll 1? ( "   unroll formats" lbl ) drop fcr
	"files " lbl cntinc "%d" .print
	"   code " lbl ncode "%d" .print
	"   data " lbl ndata "%d" .print fcr
	"tokens " lbl cnttok "%d" .print
	"   strings " lbl cntstr "%d" .print
	"   recursive " lbl nrec "%d" .print
	"   with [] " lbl nanon "%d" .print fcr
	"short words (<= inline) " lbl nshort "%d" .print fcr
	curword 0? ( drop ; )
	1- mark wordtxt ,eol empty
	here .write fcr ;

:panelTarget
	.wborde tuWin $1 " Target " .wtitle
	1 1 flpad
	0 'bo.target "Windows (WIN)" tuRadio
	1 'bo.target "Linux   (LIN)" tuRadio
	2 'bo.target "Mac     (MAC)" tuRadio
	3 'bo.target "RPi     (RPI)" tuRadio ;

:panelInline
	.wborde tuWin $1 " Inline " .wtitle
	1 1 flpad
	0 'bo.inline "0   none" tuRadio
	4 'bo.inline "4   low" tuRadio
	7 'bo.inline "7   normal" tuRadio
	12 'bo.inline "12  high" tuRadio
	20 'bo.inline "20  max" tuRadio ;

:panelBudget
	.wborde tuWin $1 " Inline budget " .wtitle
	1 1 flpad
	1 'bo.budget "1   tight" tuRadio
	2 'bo.budget "2   normal" tuRadio
	4 'bo.budget "4   loose" tuRadio
	'bo.unroll "unroll formats" tuCheck ;

:panelActions
	.wborde tuWin $1 " Build " .wtitle
	1 1 flpad
	'docompile "Compile        F2" tuBtn
	'doplain "Plain          F3" tuBtn
	;
	
:panelIncs
	.wborde tuWin $1 " Files " .wtitle
	1 1 flpad
	'vincs lincs tuList ;

:chkincs
	vincs lastinc <>? ( dup 'lastinc ! makewords ) drop ;

:panelWords
	.wborde tuWin $1 " Definitions " .wtitle
	1 1 flpad
	'xword xwriten!
	'vwords lwords tuListN
	xwriten.reset ;

:head
	fhome bg3 fPr .Bold " BUILD " .write .NBold fTx .eline ;

:foot
	fhome bg3
	fPr " TAB" .write fTx " Panel " .write
	fPr "F2" .write fTx " Compile " .write
	fPr "F3" .write fTx " Plain " .write
	fPr "ESC" .write fTx " Exit " .write
	fMu 'msg .write .eline ;


:keys
	uikey
	[tab] =? ( 1 ptab ) [shift+tab] =? ( -1 ptab )
	[dn] =? ( 1 pstep ) [up] =? ( -1 pstep )
	[f2] =? ( docompile )
	[f3] =? ( doplain )
	[esc] =? ( tuiexit )
	drop
	bo.target osgen <>? ( 'osgen ! reload tuR! ; ) drop
	bo.inline lastinl <>? ( calcstats tuR! ) drop ;

:screen
	.reset bg0 fTx .cls
	1 flxN head
	1 flxS foot
	36 flxO
	flxpush
	6 flxN panelTarget
	7 flxN panelInline
	6 flxN panelBudget
	5 flxN panelActions
	flxpop
	flxRest
	error 0? ( chkincs ) drop
	10 flxN srcinfo
	flxRest
	error 1? ( drop keys ; ) drop
	fw 2/ 44 min flxO panelIncs
	flxRest panelWords
	keys ;

|-----------------------------------
:
	'bfile "mem/menu.mem" load drop
	osgen 'bo.target !
	bo.load
	bo.target 'osgen !
	mark
	loadinfo
	.alsb
	'screen onTui
	bo.save ;
