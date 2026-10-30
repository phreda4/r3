|
| PHREDA 2019

^r3/lib/math.r3
^r3/lib/str.r3

|----------------------------------
#basen

:signo | str -- str signo
	dup c@
	$2b =? ( drop 1+ 0 ; )	| + $2b
	$2d =? ( drop 1+ 1 ; )	| - $2d
	drop 0 ;

:dighex | c --  dig / -1 | :;<=>?@ ... Z[\]^_' ... 3456789
	$3A <? ( $30 - ; ) 
	tolow $57 - $f >? ( neg ) ;

::str$>nro | adr -- adr' nro ; hexadecimal digits at adr (no $ prefix), stops at the first other char; adr' = that char
	0 ( swap c@+ $2f >?
		dighex -? ( drop 1- swap ; )
		rot 4 << + )
	drop 1- swap ;

::str%>nro | adr -- adr' nro ; binary digits at adr (no % prefix; also . counts as 0 and / as 1), stops at the first other char
	0 ( swap c@+ $2e >=?
		$31 >? ( drop 1- swap ; )
		$30 - $1 and rot 1 << + )
	drop 1- swap ;

::str>nro | adr -- adr' nro ; number at adr: 1234 $12f %101 -12 (no leading blanks); adr' = first char after it, nro = 0 if there is none
	signo
	over c@ 33 <? ( 2drop 1- 0 ; ) | caso + y - solos
	swap 1? ( [ neg ; ] >r ) drop
	$24 =? ( drop 1+ 16 'basen ! str$>nro ; )	| $ hexa $24
	$25 =? ( drop 1+ 2 'basen ! str%>nro ; ) 	| % bin  $25
	drop 10 'basen !
	0 ( swap c@+ $2f >? 	| 0 adr car
		$39 >? ( drop 1- swap ; )			| 0..9
		$30 - rot 10* + )
	drop 1- swap ;

::?sint | adr -- adr' nro ; signed decimal integer at adr (+ or - optional); adr' = first char after the digits
	signo swap
	0 ( swap c@+ $2f >? $3a <?
		$30 - rot 10* + )
	drop swap
	rot 0? ( drop ; ) drop neg ;

|-----
::?numero | str -- str' nro flag ; like str>nro, flag = 1 if the number ends at a blank or the end of the string, else 0
	str>nro over c@ 33 <? ( drop 1 ; ) drop 0 ;

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

::getnro | adr -- adr' nro ; skip blanks, then a decimal integer (+ or - optional); no $ or % forms
	trim
	signo
	over c@ 33 <? ( 2drop 1- 0 ; ) drop | caso + y - solos
	1? ( [ neg ; ] >r ) drop
	0 swap ( c@+ $2f >? $3a <?	| 0 adr car
		$30 - rot 10* + swap )
	drop 1- swap ;
	
::str>fnro | adr -- adr' fix ; skip blanks, then a decimal number with optional fraction (-43.04) as 48.16 fixed point
	0 'f !
	trim 
	dup c@ 0? ( ; ) drop
	signo
	over c@ 33 <? ( 2drop 1- 0 ; ) drop | caso + y - solos
	1? ( [ neg ; ] >r ) drop
	0 swap ( c@+ $2f >? $3a <? | 0..9
		$30 - rot 10* + swap )
	$2e =? ( getfrac )
	drop 1- swap
	16 << $10000 f
	1 over ( 1 >? 10/ swap 10* swap ) drop
	*/ $ffff and or
	;

::str>fix | adr -- adr' fix ; same as str>fnro: 48.16 fixed point (-43.04 gives $ffffffffffd4f5c3)
	str>fnro ;

::str>anro | adr -- adr' n ; any number: an integer (decimal, $hex, %bin) if it ends at a blank, else a decimal with fraction as 48.16 fixed point
	dup str>nro over c@ 
	33 <? ( drop rot drop ; ) 3drop
	str>fnro ;

:gete
	$65 <>? ( $45 <>? ( ; ) ) drop
	getnro dup 'e ! ;

::getfenro | adr -- adr' fix ; skip blanks, decimal with fraction and optional exponent (1.5e3, the . is required before the e) as 48.16 fixed point
	0 'f ! 0 'e !
	trim signo
	over c@ 33 <? ( 2drop 1- 0 ; ) drop | caso + y - solos
	1? ( [ neg ; ] >r ) drop
	0 swap ( c@+ $2f >? 	| 0 adr car
		$39 >? ( drop 1- swap ; )			| 0..9
		$30 - rot 10* + swap )
	$2e =? ( getfrac gete )
	drop 1- swap
	16 << $10000 f
	1 over ( 1 >? 10/ swap 10* swap ) drop
	*/ $ffff and or
	e 0? ( drop ; )
	+? ( ( 1? 1- swap 10* swap ) drop ; )
	( 1? 1+ swap 10/ swap ) drop
	;

|----- test solo si es numero (sin calcular)
::isHex | adr -- 3/0 ; 3 if the chars at adr (just after the $) are hex digits up to a blank or the end, else 0
	( c@+ $2f >?
		dighex -? ( 2drop 0 ; )
		drop )
	33 <? ( 2drop 3 ; ) 2drop 0 ;

::isBin | adr -- 2/0 ; 2 if the chars at adr (just after the %) are binary digits up to a blank or the end, else 0
	( c@+ $2e >=?
		$31 >? ( 2drop 0 ; )
		drop )
	33 <? ( 2drop 2 ; ) 2drop 0 ;

::isNro | adr -- type/0 ; type of the number at adr (up to a blank or the end): 1 decimal, 2 binary, 3 hexadecimal, 4 fixed point, 0 not a number
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
::scanp | adr "str" -- adr'/0 ; adr' = address after "str" if the text at adr starts with it, 0 if not
	( c@+ 1?  | d1 d2 c
		rot c@+ | d2 c d1 c
		rot <>? ( 3drop 0 ; )
		drop | d2 d1
		swap )
	2drop ;

::scanstr | adr 'str -- adr' ; copy the chars at adr to 'str up to a control char (<= 31), no 0 added; adr' = that char; 0 if adr is 0
	swap 0? ( nip ; )
	( c@+ $ff and 31 >?
		rot c!+ swap ) drop
	1- nip ;

::scannro | adr 'nro -- adr' ; skip blanks, read a number (see ?numero) and store it at 'nro; adr' = address after it, adr itself if there is no number
	over trim ?numero 0? ( 4drop ; ) drop
	rot ! nip ;

::scanc | c adr -- adr'/0 ; address of the first char c found at adr, 0 if not found (or adr is 0)
	0? ( nip ; )
	( c@+ 1?
		pick2 =? ( drop nip 1- ; )
		drop )
	nip nip ;

::scann | adr "str" -- adr'/0 ; address after "str" found at adr; only the first occurrence of the first char of str is tried; 0 if not found
 	c@+ rot scanc
	0? ( nip ; )
	1+ swap | adr' "tr"
	( c@+ 1?      | adr r t
		rot c@+      | r t adr a
		rot <>? ( 3drop 0 ; ) | r adr a
		drop swap )
	2drop ;
	
