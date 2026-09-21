| DEBUGER
| PHREDA 2026

^r3/util/tui.r3

:main
	.reset .cls 
	
	1 flxN
	0 fy .at 7 .fc 8 .bc .eline 
	"DBG" .write
	
	1 flxS
	0 fy .at 7 .fc 8 .bc .eline  
	"|ESC| Exit " .write

	.reset
	8 flxS
	fx fy .at fw .hline 
	fx fy .at "MEM" .write
	
	20 flxO
	fx fw + 1- fy .at fh .vline 
	
	flxpush
	fx fy .at fw 1- .hline 
	fx fy .at "WATCH" .write
	
	14 flxS
	fx fy .at fw 1- .hline 
	fx fy .at "RET" .write 
	flxpop

	6 flxS
	fx fy .at fw .hline 
	fx fy .at "IP" .write
	flxRest
	fx fy .at "CODE" .write
	;
	
: 
.alsb 
'main onTui 
.masb .free 
;
