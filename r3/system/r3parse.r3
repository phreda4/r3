| Parse words
| PHREDA 2018
|-----------------
^r3/lib/mem.r3

::>>0 | adr -- adr' ; pasa 0
	( c@+ 1? drop ) drop ;

::>>cr | adr -- adr'
	( c@+ 1? 10 =? ( drop 1 - ; ) 13 =? ( drop 1 - ; ) drop ) drop 1 - ;

::>>sp | adr -- adr'
	( c@+ 1? $ff and 33 <? ( drop 1 - ; ) drop ) drop 1 - ;

::>>" | adr -- adr'
	( c@+ 1? 34 =? ( drop c@+ 34 <>? ( drop 1 - ; ) ) drop ) drop 1 - ;

::trimcar | adr -- adr' c
	( c@+ $ff and 33 <? 0? ( swap 1 - swap ; ) drop ) ;


| cantidad de pila usada en formato print "%d.."
#controc 1  1  1  1  1  1  1  1  1  1  1  1  1  0  0  1

:count
	$25 <>? ( drop ; ) drop
	c@+ $f and 2 << 'controc + @
	rot + swap
	;

::strusestack | "" -- n
	0 swap ( c@+ 1?
		34 =? ( drop c@+ 34 <>? ( 2drop ; ) )
		count ) 2drop ;