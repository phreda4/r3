| TUI Example
| PHREDA 2025

^./tui.r3

|--------------------------------	
:w0
	.reset
	2 8 38 8 tuwin
	$1 "1" .wtitle .wstart
	tuiw .bc 1 .wm .wfill .reset
	.wat@ 2 + swap 2 + swap .at tuif "%d" sprint xwrite
	
	;
:w1 
	12 18 38 8 tuwin
	$1 "2" .wtitle .wstart
	.wat@ 1+ swap 1+ swap .at tuiw "%d " .print 
	.wat@ 2 + swap 2 + swap .at tuif "%d" sprint xwrite
	;
:w2	
	22 28 38 8 tuwin
	$1 "2" .wtitle .wstart
	.wat@ 1+ swap 1+ swap .at tuiw "%d " .print
	.wat@ 2 + swap 2 + swap .at tuif "%d" sprint xwrite
	;
	
:main
	tui	
	.reset .cls 
	2 1 .at
	"[01R[023[03F[04o[05r[06t[07h" xwrite .reset
	58 2 .at 2over 2over "%d %d %d %d" .print
	58 3 .at .tdebug
	.reset 
	w0 w1 w2
	
	1 rows .at 
	" |ESC| Exit |F1| Run |F2| Edit |F3| Search |F4| Help" .write .cr 
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
