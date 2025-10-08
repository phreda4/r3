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

:dirpanel
	.reset
	1 5 30 rows 11 - tuwin
	$1 " Dir " .wtitle
	1 .wmargin
	.wstart
	'vfolder wh 2 - uiDirs tuTree
	;
:dirfile
	31 5 cols 30 - rows 11 - tuwin
	$1 " Files " .wtitle
	1 .wmargin
	.wstart
	'vfile wh 2 - uiFiles tuList
	;
:dirpad
	1 rows 6 - cols 6 tuwin
	$1 " Command " .wtitle
	1 .wmargin .wstart
	'scratchpad	1024 tuInputline	
	;
	
:scrmain
	tui	
	.reset .cls 
	2 1 .at "[01R[023[03F[04o[05r[06t[07h" .awrite
	
	dirpanel
	dirfile
	dirpad
	2 rows .at 
	"|ESC| Exit |F1| Run |F2| Edit |F3| Search |F4| Help" .write .cr 
	.flush ;

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
