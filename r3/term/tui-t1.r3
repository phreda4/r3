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
:w1 
	.reset 18 18 24 8 tuwin
	$4 "dos" .wtitle .wstart
	tuiw .bc 1 .wm .wfill .reset
	.wat@ 2 + swap 3 + swap .at tuif "%d" sprint .xwrite
	;
:w2	
	.reset 34 8 24 8 tuwin
	$3 "tres" .wtitle .wstart
	tuiw .bc 1 .wm .wfill .reset	
	.wat@ 2 + swap 3 + swap .at tuif "%d" sprint .xwrite
	;

|----------- tables


::utf8ncpy | str 'dst cnt  -- 'dst
	ab[
	swap >a swap >b | a=dst b=src
	( 1? 1-
		cb@+
		$80 and? ( ca!+ cb@+ 
			$80 and? ( $40 and? ( ca!+ cb@+ 
				$80 and? ( $40 and? ( ca!+ cb@+ ) )
				) )
			)
		ca!+ ) drop
	a>
	]ba ;

::utf8cpy | cnt  --
	( 1? 1-
		cb@+
		$80 and? ( ca!+ cb@+ 
			$80 and? ( $40 and? ( ca!+ cb@+ 
				$80 and? ( $40 and? ( ca!+ cb@+ ) )
				) )
			)
		ca!+ ) drop ;

:place | count flags -- lenout count lenin
	$100000000 and? (  )
	$200000000 and? ( )
	$400000000 and? ( )
	;
| "uno|dos|tre" "cua|cinco|s"
| JMMAAACCC
:tab.col | modo+cnt str --
	ab[
	utf8count | flag str count
	-rot >b | from
	here >a | to
	place | lenout count lenin
	( 1? 1- 32 ca!+ ) drop
	utf8cpy
	( 1? 1- 32 ca!+ ) drop
	0 ca!
	]ba
	here .write
	;
	
| a> string	
:table.col | len just -- 
	
	here 32 pick3 cfill | dvc
	0 here pick3 + c!
dup "%d" .fprint waitesc
	
	0? ( drop | left
		a> utf8count min
		here a> rot cmove ; | dsc
|		)
|	1 =? ( drop 
2dup "%d %d" .fprint waitesc
	drop
		a> utf8count over min | len count
		- 2/ here +
		a> rot
		cmove ; 
|		)
	drop | right
	a> utf8count over min | len strc
	swap | count len
	over - here +
	a> rot
	cmove | dsc
	;
	
:table.head | 't --
	"|" .write
	>a ( ca@+ 1? ca@+ 
		table.col
		here .write
		a> >>0 >a
		"|" .write
		) drop ;
	
:table.row | 'l --
	drop
	;
:table.foot
	;
	
|---------	
#ttable1 ( 10 $0 ) "col1" ( 20 $1 ) "col2" ( 10 $2 ) "col3" 0
#dtable1 "uno|uno|uno" "dos1|dos2|dos3" "cuatro|tres|dos" "diez|once|doce" "diecisite|dieciocho|veinti uno" 0

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
	
	4 11 .at
	'ttable1 table.head
	
	'dtable1 table.row
	;
	
|-----------------------------------
: 
	.term 
	'main onTui 
	.free 
;
