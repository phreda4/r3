| TUI 
| PHREDA 2025
^./tui.r3

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
#ttablecol ( 10 $0 20 $1 15 $2 0 0 ) 
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
	fx fy .at
	fx .col 'ttable1 table.head .cr 
	'dtable1 
	( dup c@ 1? drop
		fx .col dup table.row .cr 
		>>0 ) 2drop
	;

#pad * 256

:main
	.reset .cls 
	
	1 flxS
	2 fy .at "|ESC| Exit " .write
	
	3 flxN
	2 0 flpad 
	tuWin $1 " Command " .wtitle
	2 1 flpad
	'pad fw 2 - tuInputLine
	tuX? 1? ( 0 'pad ! tuRefocus ) drop	
	
|	16 flxO
|	tuwin $1 " Options " .wtitle
|	1 1 flpad |1 b.hgrid
|	5 'fh ! 'exit "Salir" tuBtn | 'ev "" --
|	1 'fy +! 'exit "Coso" tuBtn | 'ev "" --
	8 flxS
	.wborde	fx fy .at cols rows "%d %d" .print
	
	15 flxN
	.wborde
	1 1 flpad 
	'vtable tuTable

	flxFill	
	1 1 flpad
"Texto muy largo
y con varias lineas
para ver como se comporta
cuando cambia de tamanio"
	$11 tuText
	;
	
|-----------------------------------
: 
	'main onTui 
	.free 
;
