| TUI 
| PHREDA 2025
^r3/util/tui.r3

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

#vlist 0 0 
#llist
#v1
#v2
#v3

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
	
	20 flxO
	flxpush
	32 flxS
	tuwin $1 " Options " .wtitle
	1 1 flpad 
	5 'fh ! 
	'exit "Salir" tuBtn | 'ev "" --
	|1 'fy +! 
	[ 1 'v3 +! ; ] "Coso" tuBtn | 'ev "" --
	flcr
	'v1 "op1" tuCheck
	0 'v2 "opr1" tuRadio
	1 'v2 "opr2" tuRadio
	flcr
	'v3 0 100 tuSlider
	v3 tuProgress
	
	flxrest
	tuwin $1 " List " .wtitle
	1 1 flpad
	'vlist llist tuList
	flxpop
	6 flxS
	.wborde	fx fy .at cols rows "%d %d" .print
	
	8 flxN
	.wborde
	1 1 flpad 
	'vtable tuTable

	flxRest	
	1 1 flpad
"Texto muy largo
y con varias lineas
para ver como se comporta
cuando cambia de tamanio"
	$11 tuText
	;
	
|-----------------------------------
: 
	here 'llist !
	"1 uno" ,s ,eol
	"2 uno" ,s ,eol
	"3 uno" ,s ,eol
	"4 uno" ,s ,eol
	"5 uno" ,s ,eol
	"6 uno" ,s ,eol
	"7 uno" ,s ,eol
	,eol
	
	.alsb 
	'main onTui 
	.masb .free 
;
