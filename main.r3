| start program
| PHREDA 2025
|---------------
^r3/util/tui.r3
^r3/util/tuiedit.r3
^r3/term/filedirs.r3

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
	
:command
	;
|--------------------------------	

|------------
:paneleditor
	fuente c@ 0? ( drop ; ) drop
	.wbordec
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
	tuwin $1 " Dir " .wtitle
	1 1 flpad |$00 xalign
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
	.bblack .home |.cls 
	|___________
	4 flxN
	fx fy .at "[01R[023[03f[04o[05r[06t[07h" .awrite 
	|.tdebug
	2dup " %d %d " .print
	
	|___________
	1 flxS
	fx fy .at " |ESC| Exit |F1| Run |F2| Ide |F3| Search |F4| Clon |F5| New |F10| Help" .write
	|___________
	38 flxO
	dirpanel
	|-4 flxS		dirfile
	|___________
	|1 flxE
	-4 flxS
	paneleditor
	|___________
	flxRest	
	dirpad

	.flush 
	uikey
	[ENTER] =? ( filerun )
	[f1] =? ( filerun )
	[f2] =? ( fileedit )
|	[f3] =? ( filesearch )
|	[f4] =? ( fileclon )
|	[f5] =? ( filenew )
|	[f10] =? ( help )
	drop
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
