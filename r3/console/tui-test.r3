| TUI Example
| PHREDA 2025

^./tui.r3

|--------------------------------	
#vfolder 0 0
#vfile 0 0
#scratchpad "Prueba de texto" * 1024
#help "" * 1024

:dirpanel
	.reset
	1 5 30 rows 11 - tuwin |.win .wborde
	$1 "[ Dir ]" .wtitle
	1 .wmargin .wstart
	'vfolder wh 2 - uiDirs tuTree
	;
:dirfile
	31 5 cols 30 - rows 11 - tuwin |.win |.wborde
	1 .wmargin 
	inwin? dup .bc 
	3 << 32 + 6 7 3 .boxf .reset |.wfill
	$1 "[ demo ]" .wtitle
	.reset
	;

:dirpad
	1 rows 6 - cols 6 tuwin | .win |.wborde
	$1 "[ Command ]" .wtitle
	1 .wmargin .wstart
	'scratchpad	1024 tuInputline
	;
	
:main
	tui
	
	.reset .cls 
	2 1 xat
	"[01R[023[03F[04o[05r[06t[07h" xwrite  .reset
	|.White " matrix.r3" xwrite
	58 2 .at 2over 2over "%d %d %d %d" .print
	58 3 .at .tdebug
	|48 3 .at padi> 1? ( dup .write ) drop
	.reset 
	dirpanel
	dirfile
	dirpad
	1 rows .at 
	" |ESC| Exit |F1| Run |F2| Edit |F3| Search |F4| Help" .write .cr 
	'help .print
	;
	
|-----------------------------------
: 
	.console |.tuistart
	.cls
	"r3" scandir
	"r3/audio" scanfiles
	33
	'main onTui 
	.free 
;
