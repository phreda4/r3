| start program
| PHREDA 2025
|---------------
^r3/util/tui.r3
^r3/util/tuiedit.r3
^r3/util/filedirs.r3

|^r3/lib/trace.r3

|--------------------------------	
#basepath "r3/"
#fullpath * 1024

#nameaux * 1024

#vfolder 0 0
#scratchpad * 1024
#info * 64

|---------------------
:loadm
	'nameaux "mem/menu.mem" load
	'nameaux =? ( drop ; )
	'nameaux dup c@ 0? ( 2drop ; ) drop
	dup 'fullpath strcpy
	flOpenFullPath 'vfolder !
	'fullpath 
	".r3" =pos 1? ( drop TuLoadCode ; ) 
	2drop
	tuNewCode ;	

:savem
	'fullpath 1024 "mem/menu.mem" save ;

|---------------------------
:banner
	.cls "[01R[023[03f[04o[05r[06t[07h" .awrite .cr .cr .cr .cr .flush ;
	
:runcheck
	banner
	here dup "mem/errorm.mem" load
	over =? ( 2drop ; ) 
	0 swap c!
	.cr .bred .white " * ERROR * " .write .cr
	.reset .write .cr
	.bblue .white " Any key to continue... " .write .cr
	.flush 
	waitkey ;

:filerun
	fuente c@ 0? ( drop ; ) drop
	banner
	savem
	"mem/errorm.mem" delete
	'fullpath
|WIN| 	"cmd /c r3 ""%s"" 2>mem/errorm.mem"
|LIN| 	"./r3lin ""%s"" 2>mem/errorm.mem"
	sprint sys | run
	.reterm .alsb .flush
	runcheck
	tuR! ;
	
:fileedit	
	fuente c@ 0? ( drop ; ) drop
	.masb .flush
	savem
||WIN| 	"r3 r3/editor/code-edit.r3"
||LIN| 	"./r3lin r3/editor/code-edit.r3"

|WIN| 	"r3 r3/d4/r3ide.r3"
|LIN| 	"./r3lin r3/d4/r3ide.r3"
	sys 
	.reterm .alsb .flush
	tuR! ;
	
:filenew
	;
	
:filesearch
	;

#padcomm
:command
	|___________
	4 flxS
	fx fy .at 
	|" |ESC| Exit |F1| Run |F2| Ide |F3| Search |F4| Clon |F5| New |F10| Help" .write
	fw .hline
	1 1 flpad 
	'padcomm fw tuInputLine
	;
|--------------------------------	

|------------
:paneleditor
	fuente c@ 0? ( drop ; ) drop
	tuwin $1 'fullpath .wtitle
	1 1 flpad 
|	tuEditCode
	tuReadCode
	;
	
|------------
:changefiles
	vfolder flTreePath
	'basepath 'fullpath strcpyl 1- strcpy
	'fullpath c@ 0? ( drop tuNewCode ; ) drop |
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
	tuwin $1 "" .wtitle
	1 1 flpad 
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
	.reset |	tuwin $1 " Command " .wtitle
	.wbordec
	1 1 flpad 
	fx fy .at 

|	'scratchpad	1024 tuInputline
|	tuX? 1? ( setcmd ) drop	
	'fullpath .write | flcr
	;

|------------	
:scrmain
	.bblack .cls
	
	|___________
	4 flxN
	fx fy .at "[01R[023[03f[04o[05r[06t[07h" .awrite 
	|.tdebug |2dup " %d %d " .print

	4 .bc 7 .fc	
	1 flxS
	fx fy .at fw .nsp
	" ^[7m F2 ^[27mHelp ^[7m F3 ^[27mSearch ^[7m F5/ENTER ^[27mRun ^[7m F6/SPC ^[27mEdit " 	.printe
	|___________
	38 flxO
	dirpanel
	|___________
	flxRest	
	paneleditor

	uikey
		
|	[f2] =? ( help )		| H
|	[f3] =? ( filesearch )	| S

	[f5] =? ( filerun )		| R
	[ENTER] =? ( filerun )
	
	[f6] =? ( fileedit )	| E
	$20 =? ( fileedit )
	
|	$43 =? ( fileclon )	| C
|	$4e =? ( filenew )	| N

	drop
	;

|-----------------------------------
:main
	'basepath flScanFullDir
	
	TuNewCode 	|"main.r3" TuLoadCode
	loadm
	'scrmain onTui 
	savem
	;

: .alsb main .masb .free ;
