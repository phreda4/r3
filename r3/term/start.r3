| start program
| PHREDA 2025
|---------------
^./tui.r3
^./filedirs.r3
^r3/lib/trace.r3

|--------------------------------	
#basepath "r3/"
#fullpath * 1024
#filename * 1024

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
	1 1 flpad xleft
	'vfile uiFiles tuList
	tuX? 1? ( setfile ) drop	
	;

|------------
:changefiles
	vfolder flTreePath
	'basepath 'fullpath strcpyl 1- strcpy
	'fullpath flGetFiles
	;
	
:dirpanel
	.reset
	tuwin $1 " Dir " .wtitle
	1 1 flpad  xleft
	'vfolder uiDirs tuTree
	tuX? 1? ( changefiles ) drop
	;

|------------
:setcmd
	0 'scratchpad ! tuRefocus
	"command" 'info strcpy
	;
	
:dirpad
	tuwin $1 " Command " .wtitle
	1 1 flpad
	'scratchpad	1024 tuInputline
	tuX? 1? ( setcmd ) drop	
	flcr
	'info .write flcr
	'fullpath .write flcr
	'filename .write flcr
	msec "%d" .print

	;

|------------	
:scrmain
	.reset .cls 
	4 flxN
	fx fy .at "[01R[023[03f[04o[05r[06t[07h" .awrite 
|	.tdebug

	1 flxS
	fx fy .at "|ESC| Exit |F1| Run |F2| Edit |F3| Search |F4| Help" .write
	
	30 flxO		dirpanel
	-4 flxN		dirfile
	flxFill		dirpad

	.flush 
	uikey
	[f1] =? ( run )
	drop
	;

|-----------------------------------
:main
	'basepath flScanDir
	|setfile	
	changefiles
	|"r3/audio" FlGetFiles
	'scrmain onTui 
	;

: 
.term .alsb
main 
.masb .free ;
