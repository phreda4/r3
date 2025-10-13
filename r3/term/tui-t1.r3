| TUI 
| PHREDA 2025
^./tui.r3
^./tuiedit.r3

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

#pad * 256

:botones
	16 flxO
	tuwin $1 " Options " .wtitle
	1 1 flpad |1 b.hgrid
	5 'fh ! 'exit "Salir" tuBtn | 'ev "" --
	1 'fy +! 'exit "Coso" tuBtn | 'ev "" --
	;
:main
	.reset .cls 
	|-----------
	1 flxN
	fx fy .at 
	.rever .eline
	" R3forth" .write

	|-----------
	1 flxS
	fx fy .at .eline " |ESC| Exit " .write
	
	|-----------
	.reset
	3 flxS 1 0 flpad 
	tuWin $1 " Command " .wtitle
	2 1 flpad
|	'pad fw 2 - tuInputLine
|	tuX? 1? ( 0 'pad ! tuRefocus ) drop	
	|-----------
	18 flxE tuWin
	$1 "Info" .wtitle
	|.bordel
	
	|-----------
	flxFill |	tuWin 
	$1 " Editor " .wtitle
	$4 'filename .wtitle
	1 1 flpad 
	tuEditCode

	
	;
	
|-----------------------------------
: 
	"main.r3" TuLoadCode
	'main onTui 
	.free 
;
