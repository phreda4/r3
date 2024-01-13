|
| PHREDA 2019

^r3/lib/math.r3
^r3/lib/str.r3

|----------------------------------
#basen

:signo | str -- str signo
	dup c@
	$2b =? ( drop 1 + 0 ; )	| + $2b
	$2d =? ( drop 1 + 1 ; )	| - $2d
	drop 0 ;

:dighex | c --  dig / -1
	$3A <? ( $30 - ; )			| 0..9
	$60 >? ( $57 - $f >? ( drop -1 ) ; )			| a
	$40 >? ( $37 - $f >? ( drop -1 ) ; )			| A
	drop -1 ;

::str$>nro | adr -- adr' nro
	0 ( swap c@+ $2f >?
		dighex -? ( drop 1 - swap ; )
		rot 4 << + )
	drop 1 - swap ;

::str%>nro | adr -- adr' nro
	0 ( swap c@+ $2e >=?
		$31 >? ( drop 1 - swap ; )
		$30 - $1 and rot 1 << + )
	drop 1 - swap ;

::str>nro | adr -- adr' nro ;1234 $12f %101 -12
	signo
	over c@ 33 <? ( 2drop 1 - 0 ; ) | caso + y - solos
	swap  1? ( [ neg ; ] >r ) drop
	$24 =? ( drop 1 + 16 'basen ! str$>nro ; )	| $ hexa $24
	$25 =? ( drop 1 + 2 'basen ! str%>nro ; ) 	| % bin  $25
	drop 10 'basen !
	0 ( swap c@+ $2f >? 	| 0 adr car
		$39 >? ( drop 1 - swap ; )			| 0..9
		$30 - rot 10* + )
	drop 1 - swap ;

::?sint | adr -- adr' nro
	signo swap
	0 ( swap c@+ $2f >? $39 <=?
		$30 - rot 10* + )
	drop swap
	rot 0? ( drop ; ) drop neg ;

|-----
::?numero | str -- 0 / str' nro 1
	str>nro over c@ 33 <? ( drop 1 ; )
	3drop 0 ;

|----- lee punto fijo ( -43.04 ==> 104 -43 t>fix16  --> $00eedddd
#parte0

::?fnumero | str -- 0/ str' fix 1		; b
	10 'basen !
	signo swap
	dup c@ 33 <? ( 3drop 0 ; ) drop
|	dup 1 + c@ que pasa con .0?
	0 ( over c@ 32 >?				| -1 str 0 dig
		$2e =? ( drop 'parte0 ! 1 over c@ ) 	| 1.33 .. parte0=1 retorna 133
	    $30 <? ( 4drop 0 ; )
	    $39 >? ( 4drop 0 ; )
	    $30 - swap 10* +
		swap 1 + swap )
	drop 1 =? ( parte0 0? ( 4drop 0 ; ) drop ) | casos -. y
	rot >r
	parte0
	16 << $10000 rot
	1 over ( 1 >? 10/ swap 10* swap ) drop
	*/ $ffff and or
	r> 1? ( drop neg 1 ; )
	drop 1 ;

::str>fix | adr -- adr' fix
	dup ?fnumero 0? ( ; ) drop
	rot drop ;
|------------------ NRO
#f | fraccion
#e | exponente

:getfrac | nro adr' char -- nro adr' char
	drop
	1 swap | nro 1 adr'
	( c@+ $2f >?
		$39 >? ( rot 'f ! ; )
		$30 - rot 10* + 
		$1000000 >? ( 'f ! 
			( c@+ $2f >? $3a <? drop ) ; ) 
		swap )
	rot 'f ! ;

::getnro | adr -- adr' nro
	trim
	signo
	over c@ 33 <? ( 2drop 1 - 0 ; ) drop | caso + y - solos
	1? ( [ neg ; ] >r ) drop
	0 swap ( c@+ $2f >? 	| 0 adr car
		$39 >? ( drop 1 - swap ; )			| 0..9
		$30 - rot 10* + swap )
	drop swap ;

::str>fnro | adr -- adr fnro
	0 'f !
	trim signo
	over c@ 33 <? ( 2drop 1 - 0 ; ) drop | caso + y - solos
	1? ( [ neg ; ] >r ) drop
	0 swap ( c@+ $2f >?	| 0 adr car
		$39 >? ( drop 1 - swap ; )			| 0..9
		$30 - rot 10* + swap )
	$2e =? ( getfrac )
	drop 1 - swap
	16 << $10000 f
	1 over ( 1 >? 10/ swap 10* swap ) drop
	*/ $ffff and or
	;

::str>anro | adr -- adr anro
	dup str>nro over c@ 
	33 <? ( drop rot drop ; ) 3drop
	str>fnro ;

:gete
	$65 <>? ( $45 <>? ( ; ) ) drop
	getnro dup 'e ! ;

::getfenro | adr -- adr fnro
	0 'f ! 0 'e !
	trim signo
	over c@ 33 <? ( 2drop 1 - 0 ; ) drop | caso + y - solos
	1? ( [ neg ; ] >r ) drop
	0 swap ( c@+ $2f >? 	| 0 adr car
		$39 >? ( drop 1 - swap ; )			| 0..9
		$30 - rot 10* + swap )
	$2e =? ( getfrac gete )
	drop 1 - swap
	16 << $10000 f
	1 over ( 1 >? 10/ swap 10* swap ) drop
	*/ $ffff and or
	e 0? ( drop ; )
	+? ( ( 1? 1 - swap 10* swap ) drop ; )
	( 1? 1 + swap 10/ swap ) drop
	;

|----- test solo si es numero (sin calcular)
::isHex |adr -- 3/0
	( c@+ $2f >?
		dighex -? ( 2drop 0 ; )
		drop )
	33 <? ( 2drop 3 ; ) 2drop 0 ;

::isBin | adr -- 2/0
	( c@+ $2e >=?
		$31 >? ( 2drop 0 ; )
		drop )
	33 <? ( 2drop 2 ; ) 2drop 0 ;

::isNro | adr - t/0 ; 1-dec 2-bin 3-hex 4-fix
	c@+
	$2b =? ( drop c@+ )		| + $2b
	$2d =? ( drop c@+ )		| - $2d
	33 <? ( 2drop 0 ; )
	$24 =? ( drop isHex ; )	| $ hexa $24
	$25 =? ( drop isBin ; ) | % bin  $25
	( $30 >=?
		$39 >? ( 2drop 0 ; )
		drop c@+ )
	$2e =? ( drop c@+
		( $30 >=?
			$39 >? ( 2drop 0 ; )
			drop c@+ )
		33 <? ( 2drop 4 ; )
		)
	33 <? ( 2drop 1 ; )
	2drop 0 ;


|------------- parseo
::scanp | adr "str" -- adr'/0
	( c@+ 1?  | d1 d2 c
		rot c@+ | d2 c d1 c
		rot <>? ( 3drop 0 ; )
		drop | d2 d1
		swap )
	2drop ;

::scanstr | adr 'str -- adr'
	swap 0? ( nip ; )
	( c@+ $ff and 31 >?
		rot c!+ swap ) drop
	1 - nip ;

::scannro | adr 'nro -- adr'
	over trim ?numero 0? ( 2drop ; ) drop
	rot ! nip ;

::scanc | c adr -- adr'/0
	0? ( nip ; )
	( c@+ 1?
		pick2 =? ( drop nip 1 - ; )
		drop )
	nip nip ;

::scann | adr "str" -- adr'
 	c@+ rot scanc
	0? ( nip ; )
	1 + swap | adr' "tr"
	( c@+ 1?      | adr r t
		rot c@+      | r t adr a
		rot <>? ( 3drop 0 ; ) | r adr a
		drop swap )
	2drop ;
	
