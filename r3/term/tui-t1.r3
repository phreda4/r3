| TUI 
| PHREDA 2025
^./tui.r3

|--------------------------------	
:w0
	.reset 2 8 24 8 tuwin
	$1 "uno" .wtitle .wstart
	tuiw .bc 1 .wm .wfill .reset
	.wat@ 2 + swap 3 + swap .at tuif "%d" sprint .xwrite
	.reset 
	;

|---------------------------------------
	
:table.col | len just -- 
	0? ( drop a> lalign ; ) 
	1 =? ( drop a> calign ; ) 
	drop a> ralign ;
	
|-----------------------------
#linedef "║"
#tablesep 'linedef
#tablenow
	
:table.head | 't --
	dup 'tablenow !
	ab[
	tablesep .write
	>a ( ca@+ 1? ca@+ 
		table.col
		here .write tablesep .write
		a> >>0 >a
		) drop 
	]ba ;
	
:table.row | 'l --
	mark ab[
	here >a
	tablenow >b
	( c@+ 1? $7c =? ( 0 nip ) ,c ) ,c drop
	tablesep .write
	( cb@+ 1? cb@+
		table.col
		here .write tablesep .write 
		a> >>0 >a b> >>0 >b	
		) drop
	]ba empty ;
	
	
:flfull ;
:flSize 2drop ;	
|---------	
#ttable1 ( 10 $0 ) "col1" ( 20 $1 ) "col2" ( 10 $2 ) "col3" 0
#dtable1 
 "uno|uno|uno"
 "dos1|señor español|dos3"
 "cuatro|tres|ñoño"
 "diez oncemil||doce mil setecientos"
 "diecisite|dieciocho|veinti uno"
 0

#vtable 'ttable1 'dtable1 0

:tuTable | 'var --
	drop
	1 11 .at
	5 .col 'ttable1 table.head .cr 
	'dtable1 
	( dup c@ 1? drop
		5 .col dup table.row .cr 
		>>0 ) 2drop
	;


:main
	tui	
	.reset .cls 
	2 rows .at "|ESC| Exit |F1| " .write
	cols 7 8 * - 2/ 1 .at
	"[01R[023[03f[04o[05r[06t[07h" .awrite 
	
	1 5 cols 3 .win .wborde
	$1 " Command " .wtitle
	3 6 .at ">" .write 
	5 6 tuat pad cols 5 - tuInputLine
	
	.reset
	3 10 cols 4 - rows 10 - .win .wborde
	
		
	10 3 flSize
	'exit "Salir" tuBtn

	flFull
	'vtable tuTable

	;
	
|-----------------------------------
: 
	.term 
	'main onTui 
	.free 
;
