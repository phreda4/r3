| start program
| PHREDA 2025
|---------------
^./tui.r3
^./filedirs.r3
^./tuiedit.r3

^r3/lib/trace.r3

|--------------------------------	
#basepath "r3/"
#fullpath * 1024
#filename * 1024

#nameaux * 1024

:runcheck
	.cls 
	"[01R[023[03f[04o[05r[06t[07h" .awrite .cr .cr .cr .cr .flush
	mark
	here dup "mem/error.mem" load
	over =? ( 2drop empty ; ) 
	0 swap c!
	.cr .bred .white 
	" * ERROR * " .println
	.reset
	.println
	.bblue .white
	"<ESC> to continue..." .println
	.flush waitesc
	empty
	;

:filerun
	| savename
	| runcheck
	|"mem/error.mem" delete
	'fullpath
	|'filename
|WIN| 	"cmd /c r3 ""%s"" " |2>mem/error.mem"
|LIN| 	"./r3lin ""%s"" 2>mem/error.mem"
	sprint sys
	.reterm 
	tuR!
	;
	
:fileedit	
	| savename
|WIN| 	"r3 r3/term/r3ide.r3"
|LIN| 	"./r3lin r3/term/r3ide.r3"
	sys 
	.reterm
	tuR!
	;
	
:filenew
	;
	
:filesearch
	;
	
:command
	;
|--------------------------------	
#vfolder 0 0
#scratchpad * 1024
#info * 64

|------------
:paneleditor
	tuwin 
|	.wborded
	$1 " CODE " .wtitle
	1 1 flpad 
	tuEditCode
|	tuReadCode
	;
	
|------------
:changefiles
	vfolder flTreePath
	'basepath 'fullpath strcpyl 1- strcpy
	'fullpath c@ 0? ( drop ; ) drop |
	'fullpath 
	".r3" =pos 1? ( drop TuLoadCode ; ) 
	2drop
	tuNewCode ;
	
:setcolor | str -- str
	"/" =pos 1? ( drop 7 .fc ; ) drop
	".r3" =pos 1? ( drop 11 .fc ; ) drop	
	14 .fc ;
	
:filecolor	
	setcolor lwrite ;
	
:dirpanel
	.reset
	'filecolor xwrite!
	tuwin $1 " Dir " .wtitle
	1 1 flpad $00 xalign
	'vfolder uiDirs tuTree
	xwrite.reset
	tuX? 1? ( changefiles ) drop
	;

|------------
:setcmd
	0 'scratchpad ! tuRefocus
	"command" 'info strcpy
	;
	
:dirpad
	.reset
	tuwin $1 " Command " .wtitle
	|1 1 flpad $00 xalign
	'scratchpad	1024 tuInputline
	tuX? 1? ( setcmd ) drop	
|	'nameaux .write flcr
|	'info .write flcr
	flcr 'fullpath .write flcr
|	'filename .write flcr
	;

|------------	
:scrmain
	.bblack .cls 
	|___________
	4 flxN
	fx fy .at "[01R[023[03f[04o[05r[06t[07h" .awrite 
	|.tdebug
	2dup "%d %d " .print
	vfolder "<<%d>>" .print
	|___________
	2 flxS
	fx fy .at "|ESC| Exit |F1| Run |F2| Edit |F3| Search |F4| Help" .write
	
	|___________
	38 flxO		dirpanel
	|-4 flxS		dirfile
	1 flxE
	-4 flxN		paneleditor
	flxFill		
	dirpad

	.flush 
	uikey
	[f1] =? ( filerun )
	[f2] =? ( fileedit )
|	[f3] =? ( filesearch )
|	[f4] =? ( help )
	drop
	;

|---------------------
:loadm
	'nameaux "mem/menu.mem" load
	'nameaux =? ( drop ; )
	'nameaux dup c@ 0? ( 2drop ; ) drop
	dup 'filename strcpy
	dup 'fullpath strcpy
	flOpenFullPath 'vfolder !
	changefiles
	;

|-----------------------------------
:main
	'basepath flScanFullDir
	
	TuNewCode 	|"main.r3" TuLoadCode
	loadm
	
	33 | <<< debug
	'scrmain onTui 
	drop
	
	|savem
	;

: .alsb main .masb .free ;
