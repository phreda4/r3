| r3build - build center: target, inline level, plain / compile
| the code is the one selected in main.r3 (mem/menu.mem)
| PHREDA 2026
|
| options are saved in mem/build.mem ( target, inlinelenmax ) for r3plain.r3

^r3/util/tui.r3
^r3/d4/r3token.r3

#bfile * 1024		| source file
#msg * 128			| last message

|---- options (keep together, saved as 2 qwords in mem/build.mem)
#target 0			| 0 WIN, 1 LIN, 2 MAC, 3 RPI (osgen)
#inline 7			| max tokens of a word to inline (0 = no inline)

#optbuf * 64
#osn "WIN" "LIN" "MAC" "RPI"

:saveopts
	'target 16 "mem/build.mem" save ;

:loadopts
	'optbuf "mem/build.mem" load 'optbuf - 16 <>? ( drop ; ) drop
	'optbuf @ $3 and 'target !
	'optbuf 8 + @ 0 max 99 min 'inline ! ;

|---- info of the loaded code
#ncode #ndata #nrec #nanon #nshort
#lastinl -1

:statword | nro --
	nro>dic @+ swap @ 32 >>>		| info1 len
	swap 1 and? ( 2drop 1 'ndata +! ; )
	$20 and? ( 1 'nrec +! )
	$40 and? ( 1 'nanon +! )
	drop
	inline <=? ( inline 1? ( 1 'nshort +! ) drop )
	drop 1 'ncode +! ;

:calcstats
	0 'ncode ! 0 'ndata ! 0 'nrec ! 0 'nanon ! 0 'nshort !
	0 ( cntdef <? dup statword 1+ ) drop
	inline 'lastinl ! ;

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
#wd #wf
:wlen | -- n
	wf 1 and? ( drop wd toklend nip ; ) drop wd toklen nip ;

:kind | -- str
	wf 1 and 1? ( drop "#" ; ) drop ":" ;

:flagtxt
	wf $10 and? ( " ;" ,s ) $20 and? ( " R" ,s ) $40 and? ( " []" ,s ) $80 and? ( " ." ,s ) drop ;

:wordtxt | nro --
	nro>dic 'wd !
	wd @ 'wf !
	kind ,s
	here wd @ dic>name ,word here swap -
	22 swap - clamp0 ,nsp
	wf 1 and? ( drop wlen "%d tok" ,print ; ) drop
	wd 8 + @ 16 >> $ffff and wlen "%d tok %d calls" ,print
	flagtxt ;

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
	saveopts
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
	"press any key to continue..." .println
	waitkey
	backtui ;

:docompile
	target 1? ( drop "Compile: only the WIN target for now" 'msg strcpy ; ) drop
	error 1? ( drop ; ) drop
	genplain
	plainok? 0? ( drop
		.reterm .cr "plain.r3 FAILED - press any key..." .println waitkey
		"plain.r3 FAILED" 'msg strcpy
		backtui ; ) drop
	"r3/d4/r3wincomp.r3" r3run
	"compile done" 'msg strcpy
	backtui ;

:docompileo
	target 1? ( drop "Compile (old): only the WIN target for now" 'msg strcpy ; ) drop
	error 1? ( drop ; ) drop
	saveopts
	.masb .reset .cls .flush
	"r3/system/r3compiler.r3" r3run
	"compile (old) done" 'msg strcpy
	backtui ;

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
	"target " lbl 'osn target n>>0 .write
	"   inline <= " lbl inline "%d tokens" .print fcr
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
	.wborde $1 " Target " .wtitle
	1 1 flpad
	0 'target "Windows (WIN)" tuRadio
	1 'target "Linux   (LIN)" tuRadio
	2 'target "Mac     (MAC)" tuRadio
	3 'target "RPi     (RPI)" tuRadio ;

:panelInline
	.wborde $1 " Inline " .wtitle
	1 1 flpad
	0 'inline "0   none" tuRadio
	4 'inline "4   low" tuRadio
	7 'inline "7   normal" tuRadio
	12 'inline "12  high" tuRadio
	20 'inline "20  max" tuRadio
	fhome fMu "max tokens of an inlined word" .write ;

:panelActions
	.wborde $1 " Build " .wtitle
	1 1 flpad
	'doplain "Plain          F3" tuBtn
	'docompile "Compile        F2" tuBtn
	'docompileo "Compile (old)  F4" tuBtn ;

:panelIncs
	.wborde $1 " Files " .wtitle
	1 1 flpad
	'vincs lincs tuList ;

:chkincs
	vincs lastinc <>? ( dup 'lastinc ! makewords ) drop ;

:panelWords
	.wborde $1 " Definitions " .wtitle
	1 1 flpad
	'xword xwriten!
	'vwords lwords tuListN
	xwriten.reset ;

:head
	fhome bg3 fPr .Bold " r3build " .write .NBold fTx
	cols rows "%dx%d" sprint .write .eline ;

:foot
	fhome bg3
	fPr " F2" .write fTx " Compile " .write
	fPr "F3" .write fTx " Plain " .write
	fPr "F4" .write fTx " Compile(old) " .write
	fPr "ESC" .write fTx " Exit " .write
	fMu 'msg .write .eline ;

:small
	1 1 .at "terminal too small (min 70x24)" .write ;

:screen
	.reset bg0 fTx .cls
	cols 70 <? ( drop small ; ) drop
	rows 24 <? ( drop small ; ) drop
	1 flxN head
	1 flxS foot
	36 flxO
	flxpush
	6 flxN panelTarget
	8 flxN panelInline
	5 flxN panelActions
	flxpop
	flxRest
	error 0? ( chkincs ) drop
	10 flxN srcinfo
	flxRest
	error 1? ( drop ; ) drop
	fw 2/ 44 min flxO panelIncs
	flxRest panelWords
	uikey
	[f2] =? ( docompile )
	[f3] =? ( doplain )
	[f4] =? ( docompileo )
	[esc] =? ( tuiexit )
	drop
	target osgen <>? ( 'osgen ! reload tuR! ; ) drop
	inline lastinl <>? ( calcstats tuR! ) drop ;

|-----------------------------------
:
	'bfile "mem/menu.mem" load drop
	osgen 'target !
	loadopts
	target 'osgen !
	mark
	loadinfo
	.alsb
	'screen onTui
	saveopts ;
