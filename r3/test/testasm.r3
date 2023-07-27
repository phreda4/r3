| code
^r3/win/console.r3
^r3/lib/parse.r3

#errorstr "-0.0049316500123161647,-0.264892578125,"

|------------------ NRO
#f | fraccion
#e | exponente

:signo | str -- str signo
	dup c@
	$2b =? ( drop 1 + 0 ; )	| + $2b
	$2d =? ( drop 1 + 1 ; )	| - $2d
	drop 0 ;

:getfrac | nro adr' char -- nro adr' char
	drop
	1 swap | nro 1 adr'
	( c@+ $2f >?
		$39 >? ( rot 'f ! ; )
		$30 - rot 10* + 
		$1000000 >? ( 'f ! 
			( c@+ $2f >? $3a <? drop ) 
			; )
		swap )
	rot 'f ! ;

::str>fnro | adr -- adr fnro
	0 'f !
	trim
	signo
	over c@ 33 <? ( 2drop 1 - 0 ; ) | caso + y - solos
	swap 1? ( [ neg ; ] >r ) drop
	drop
	0 swap ( c@+ $2f >?	| 0 adr car
		$39 >? ( drop 1 - swap ; )			| 0..9
		$30 - rot 10* + swap )
	pick2 "%d " .println
	$2e =? ( getfrac )
	f "%d " .println
	drop 1 - swap
	16 << $10000 f
	1 over ( 1 >? 10 / swap 10* swap ) drop
	pick2 pick2 pick2 "%d %d %d " .println
	*/ $ffff and or
	;
	
::waitesc
	( getch	$1B1001 <>? drop ) drop ;
	
:test
	"test" .println
	'errorstr str>fnro "%f" .println
	waitesc
	;

: test ;
