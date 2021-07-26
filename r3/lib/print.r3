|---------------
| PRINT LIB
| PHREDA 2018
|---------------
^r3/lib/sys.r3
^r3/lib/mem.r3

^r3/lib/fonti.r3
|^r3/lib/fontpc.r3

##rows 40
##cols 80		| filas/columnas texto

##cch 12 | 16
##ccw 8

##charrom
##charsiz
##charlin

|#_charemit 'char8pc
|#_charsize 'size8pc

#_charemit 'char8i
#_charsize 'size8i

::calcrowcol
	sw ccw / 'cols !
	sh cch / 'rows !
	;

::font! | 'vemit 'vsize --
  '_charsize ! '_charemit !
  calcrowcol ;

::fonti
|	8 'ccw ! 16 'cch !
|	'char8pc 'size8pc font!
	8 'ccw ! 12 'cch !
	'char8i 'size8i font!
	calcrowcol ;

::noemit | c --
	$ff and _charsize ex 'ccx +! ;

::emit | c --
	$ff and dup
	_charemit ex
	_charsize ex 'ccx +! ;

::sp
	32 emit ;
::nsp | cnt --
	( 1? 32 emit 1 - ) drop ;
::cr
	cch 'ccy +! 0 'ccx ! ;
::lf
	0 'ccx ! ;
::tab
	4 nsp ;
::gtab
	ccw 2 << 'ccx +! ;

::swprint | "" -- "" size
	0 over ( c@+ 1?
		$ff and _charsize ex rot + swap ) 2drop ;

::emitsize | c -- size
	$ff and _charsize ex ;

::home
	0 'ccx ! 0 'ccy ! ;

::emits | "" --
	( c@+ 1? emit ) 2drop ;

::print | s..s "" --
	sprint emits ;

::printc | "" --
	swprint 1 >> sw 1 >> swap - 'ccx !
	emits ;

::printr | "" --
	swprint sw swap - 'ccx !
	emits ;

::cntprint | "" cnt --
	( 1? 1 - swap c@+
		0? ( drop 1 - 32 )
		emit swap ) 2drop ;

::cntprintr | "" cnt --
	swap count swap -
	nsp emits ;

::lprint | str --
	( c@+ 1? $ff and
  		10 =? ( 2drop ; )
		13 =? ( 2drop ; )
		emit ) 2drop ;

:ctext
	13 =? ( drop cr ; ) emit ;

::text | str --
	( c@+ 1? ctext ) 2drop ;


::gotoxy | x y --
	cch * 'ccy !
::gotox | x --
	ccw * 'ccx ! ;

::atxy | x y --
	'ccy ! 'ccx ! ;

|--- fill back

::backprint | "" -- ""
	swprint cch ccx ccy fillrect ;

::backline | --
	sw cch 0 ccy fillrect ;

::backlines | cnt --
	sw swap cch * 0 ccy fillrect ;

::backfill | x y x y --
	cch * swap ccw * swap 2swap
	cch * swap ccw * swap fillbox ;

|--- print with back, 2color is RrGgBg

::bprint | "" 2color --	; "black over white" $f0f0f0 bprint
	dup 4 >> $f0f0f and over $f0f0f0 and or 'ink ! swap backprint
	over 4 << $f0f0f0 and rot $f0f0f and or 'ink ! print ;

|--- emit with screen limits, cr and scroll
::scrollup
	cch neg 'ccy +!
	vframe sw cch * 2 << over + sw sh cch - * move
	vframe sw ccy * 2 << + 0 sw cch * fill
	;

::emits?cr | str --
	swprint ccx + sw >? ( cr ccy sh cch - >? ( scrollup ) drop ) drop
	emits
	;
