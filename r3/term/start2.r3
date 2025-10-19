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

:run
	.cls 
	"[01R[023[03f[04o[05r[06t[07h" .awrite .cr .cr .cr .cr .flush
	msec
	|"mem/error.mem" delete
	|'fullpath
	'filename
|WIN| 	"cmd /c r3 ""%s"" " | 2>mem/error.mem"
|LIN| 	"./r3lin ""%s"" 2>mem/error.mem"
	sprint sys
	.reterm 
	msec swap - "%d ms" .fprint
	;
	
|--------------------------------	
#vfolder 0 0
#vfile 0 0
#scratchpad * 1024
#info * 64

|------------
:setfile
	vfile uiNindx 
	'fullpath 'filename strcpyl 1- 
	flcpy
	|loadcodigo	
	'filename 'info strcpy
	;

:dirfile
	tuwin $1 " Files " .wtitle
	1 1 flpad $00 xalign
	'vfile uiFiles tuList
	tuX? 1? ( setfile ) drop	
	;

:paneleditor
|	tuwin 
|	.wborded
	|$1 " CODE " .wtitle
	|1 1 flpad 
	tuEditCode
|	tuReadCode
	;
	
|------------
:loadcode
	'fullpath TuLoadCode
	;
	
:changefiles
	vfolder flTreePath
	'basepath 'fullpath strcpyl 1- strcpy
	'fullpath dup c@ 0? ( 2drop ; ) drop
	count + 1- 0 swap c! | quita \
	'fullpath 
	".r3" =pos 1? ( loadcode ) 
	2drop
|	'fullpath flGetFiles
	;
	
:dirpanel
	.reset
	tuwin $1 " Dir " .wtitle
	1 1 flpad $00 xalign
	'vfolder uiDirs tuTree
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
	1 1 flpad $00 xalign
	'scratchpad	1024 tuInputline
	tuX? 1? ( setcmd ) drop	flcr
	'nameaux .write flcr
	'info .write flcr
	'fullpath .write flcr
	'filename .write flcr
	;

|------------	
:scrmain
	.bblack .cls 
	|___________
	4 flxN
	fx fy .at "[01R[023[03f[04o[05r[06t[07h" .awrite 
	|.tdebug
	2over 2over "%d %d %d %d" .print

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
	[f1] =? ( run )
	drop
	;

|---------------------
:next/ | adr -- adr'
	( c@+ 1? $2f =? ( drop ; ) drop ) nip ;	
	
:removefile
	'fullpath ( dup next/ 1? nip ) drop 0 swap c! ;

:loadm
	'nameaux "mem/menu.mem" load
	'nameaux =? ( drop ; )
	'nameaux dup c@ 0? ( 2drop ; ) drop
	dup 'filename strcpy
	'fullpath strcpy
	removefile
	
	12 'vfolder !
	'fullpath flGetFiles
	;

|-----------------------------------

:main
	'basepath flScanFullDir
	
	|uiDirs <<memmap
|	loadm
|	changefiles

	TuNewCode
	|"main.r3" TuLoadCode
	33 
	'scrmain onTui 
	|savem
	;

: .alsb main .masb .free ;
