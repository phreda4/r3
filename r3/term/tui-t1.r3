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

|---
:utfmove | 'd 's c --
	ab[
	swap >b swap >a | a=dst b=src
	( 1? 1-
		cb@+
		$80 and? ( ca!+ cb@+ 
			$80 and? ( $40 and? ( ca!+ cb@+ 
				$80 and? ( $40 and? ( ca!+ cb@+ ) )
				) )
			)
		ca!+ ) drop
	]ba ;

|---------------------------------------
::utf8-count | str -- char bytes
	0 0 rot
	( c@+ 1?
		$c0 and $80 <>? ( rot 1+ -rot ) drop
		rot 1+ -rot
		) 2drop ;

::utf8-bytes | maxchar str -- bytes |(const char* str, int max_chars) {
	>a
	0 0 rot | bytes chars max
	( over >? 
		ca@+ 1? ( 3drop ; ) | all
		$c0 and $80 <>? ( rot 1+ -rot ) drop
		rot 1+ -rot
		) 2drop 
	-1 a+
	ca@ $c0 and $80 =? ( drop
		( ca@ $c0 and $80 =? drop 1- )
		) drop ;


|char* justify_string_utf8(const char* str, int width, Alignment align) 
|{
|    int char_count, byte_count;
|    utf8_count(str, &char_count, &byte_count);
|    int bytes_to_copy = byte_count;
|    int effective_chars = char_count;
	
|    // Si el string es más largo que el ancho, truncar correctamente
|    if (char_count > width) {
|        bytes_to_copy = utf8_bytes_for_chars(str, width);
|        effective_chars = width;
|    }
|    // Calcular espacios necesarios
|    int spaces_needed = width - effective_chars;
|    int total_bytes = bytes_to_copy + spaces_needed;
    

|    int left_spaces = 0;
|    int right_spaces = spaces_needed;
|    switch (align) {
|        case LEFT:    left_spaces = 0;            right_spaces = spaces_needed;            break;
|        case CENTER:  left_spaces = spaces_needed / 2;   right_spaces = spaces_needed - left_spaces;            break;
|        case RIGHT:   left_spaces = spaces_needed;       right_spaces = 0;     break;
|    // Construir el resultado de forma eficiente
|    char* ptr = result;
|    // Espacios a la izquierda
|    if (left_spaces > 0) {
|        memset(ptr, ' ', left_spaces);
|        ptr += left_spaces;
|    }
|    // Copiar el string
|    memcpy(ptr, str, bytes_to_copy);
|    ptr += bytes_to_copy;
|    // Espacios a la derecha
|    if (right_spaces > 0) {
|        memset(ptr, ' ', right_spaces);
|        ptr += right_spaces;
|    }
|    *ptr = '\0';
|    return result;
	
|----------- tables, no utf8
:table.col | len just -- 
	here 32 pick3 cfill | dvc
	0 here pick3 + c!
	0? ( drop | left
		a> count rot min	| str count
		here -rot cmove ; | dsc
		)
	1 =? ( drop | center
		a> utf8count pick2 min | len str rcount
		rot over - 2/ 
		here + -rot cmove ;
		) drop | right
	a> count pick2 min | len strc
	rot over -
	here + -rot cmove ; | dsc

|-----------------------------
::utf8count | str -- str count
	0 over ( c@+ 1? $c0 and 
		$80 <>? ( rot 1+ -rot )
		drop ) 2drop ;

::utf8ncpy | str 'dst cnt  -- 'dst
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
	;

:table.col8
	;

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
#dtable1 "uno|uno|uno" "dos1|señor español|dos3" "cuatro|tres|ñoño" "diez oncemil||doce mil setecientos" "diecisite|dieciocho|veinti uno" 0

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
