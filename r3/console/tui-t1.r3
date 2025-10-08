| TUI 
| PHREDA 2025
^./tui.r3

|--------------------------------	
:w0
	.reset 2 8 24 8 tuwin
	$1 "uno" .wtitle .wstart
	tuiw .bc 1 .wm .wfill .reset
	.wat@ 2 + swap 3 + swap .at tuif "%d" sprint xwrite
	.reset 
	;
:w1 
	.reset 18 18 24 8 tuwin
	$4 "dos" .wtitle .wstart
	tuiw .bc 1 .wm .wfill .reset
	.wat@ 2 + swap 3 + swap .at tuif "%d" sprint xwrite
	;
:w2	
	.reset 34 8 24 8 tuwin
	$3 "tres" .wtitle .wstart
	tuiw .bc 1 .wm .wfill .reset	
	.wat@ 2 + swap 3 + swap .at tuif "%d" sprint xwrite
	;
	
:main
	tui	
	.reset .cls 
	1 rows .at "|ESC| Exit |F1| " .write
	cols 7 8 * - 2/ 1 .at
	"[01R[023[03f[04o[05r[06t[07h" xwrite 
	
	1 5 cols 3 .win .wborde
	$1 " Command " .wtitle
	3 6 .at ">" .write 
	5 6 tuat pad cols 4 - tuInputLine
	

	;
	
|-----------------------------------
: 
	.console 
	'main onTui 
	.free 
;
