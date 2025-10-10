| start program
| PHREDA 2025
|---------------
^./tui.r3

|--------------------------------	
#filename "matrix.r3"
#path "r3/term"

:run
	'filename
	'path
|WIN| 	"cmd /c r3 ""%s/%s"" " |2>mem/error.mem"
|LIN| 	"./r3lin ""%s/%s"" 2>mem/error.mem"
	sprint 
	sysnew |sys
	;
	
|--------------------------------	
#vfolder 0 0
#vfile 0 0
#scratchpad * 1024
#info * 64

:changefiles
	"changefiles" 'info strcpy
	;
:setfile	
	"filenow" 'info strcpy
	;
:setcmd
	"command" 'info strcpy
	;

:dirpanel
	.reset
	tuwin $1 " Dir " .wtitle
	1 1 flpad  xleft
	'vfolder uiDirs tuTree
	tuX? 1? ( changefiles ) drop
	;
:dirfile
	tuwin $1 " Files " .wtitle
	1 1 flpad xleft
	'vfile uiFiles tuList
	tuX? 1? ( setfile ) drop	
	;
:dirpad
	tuwin $1 " Command " .wtitle
	1 1 flpad
	'scratchpad	1024 tuInputline
	tuX? 1? ( setcmd ) drop	
	flcr
	'info .write
	;
	
:scrmain
	tui	
	.reset .cls 
	4 flxN
	fx fy .at "[01R[023[03f[04o[05r[06t[07h" .awrite 
	.tdebug

	1 flxS
	fx fy .at "|ESC| Exit |F1| Run |F2| Edit |F3| Search |F4| Help" .write
	
	30 flxO		dirpanel
	-4 flxN		dirfile
	flxFill		dirpad

	.flush 
	;

|-----------------------------------
:main
	"r3" scandir
	"r3/audio" scanfiles
	'scrmain onTui 
	;

: 
.term 
main 
.free ;
