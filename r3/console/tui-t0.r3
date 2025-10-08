| TUI debug
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
	2 1 .at
	"[01T[02est" xwrite 
	.reset 58 3 .at .tdebug
	w0 w1 w2
	1 rows .at 
	" |ESC| Exit" .write .cr 
	;
	
|-----------------------------------
: 
	.console 
	'main onTui 
	.free 
;
