| PHREDA 2018
| r3 lib string

^r3/lib/math.r3

|------ STRING LIB
	
::strcpyl | src des -- ndes
	( swap c@+ 1? rot c!+ ) nip swap c!+ ;
::strcpy | src des --
	strcpyl drop ;
::strcat | src des --
	( c@+ 1? drop ) drop 1- strcpy ;
::strcpylnl | src des -- ndes
	( swap c@+ 1? 
		10 =? ( 2drop 0 swap c!+ ; )
		13 =? ( 2drop 0 swap c!+ ; ) 
		rot c!+ ) nip swap c!+ ;
::strcpyln strcpylnl drop ;

::copynom | sc s1 -- ; copy until space
	( c@+ $ff and 32 >?
		rot c!+ swap ) 2drop
	0 swap c! ;

::copystr | sc s1 -- ; copy until "
	( c@+ 34 <>?
		rot c!+ swap ) 2drop
	0 swap c! ;

::strpath | src dst -- ; copy path only (need /)
	over swap
	strcpyl 
	( over =? ( 0 swap c! drop ; )
		dup c@ $2f <>? drop 1- ) drop 
	0 swap c! drop ;

::toupp | c -- C
	$df and ;

::tolow | C -- c
	$20 or ;

::count | s1 -- s1 cnt ; naive version (not used)
	0 over ( c@+ 1?
		drop swap 1+ swap ) 2drop ;

::count | s1 -- s1 cnt ; version 3 - 8 bytes
	0 over ( @+ dup $0101010101010101 -
		swap nand $8080808080808080 nand? 
		drop swap 8 + swap )
	$80 and? ( 2drop ; )
	$8000 and? ( 2drop 1+ ; )
	$800000 and? ( 2drop 2 + ; )
	$80000000 and? ( 2drop 3 + ; )	
	$8000000000 and? ( 2drop 4 + ; )
	$800000000000 and? ( 2drop 5 + ; )
	$80000000000000 and? ( 2drop 6 + ; )	
	2drop 7 + ;

|---- UTF-8	
::utf8count | str -- str count
	0 over ( c@+ 1? $c0 and 
		$80 <>? ( rot 1+ -rot )
		drop ) 2drop ;

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
	
::utf8bytes | str cnt  -- str bytes
	over | str cnt rec
	( swap 1? 1- swap
		c@+ 
		$80 and? ( drop c@+ 
			$80 and? ( $40 and? ( drop c@+ 
				$80 and? ( $40 and? ( drop c@+ ) )
					) )
			) drop
		 ) drop
	over - ;	
		
|----- Compare	
::= | s1 s2 -- 1/0
	( swap c@+ 1?
		toupp rot c@+ toupp rot -
		1? ( 3drop 0 ; ) drop
		) 2drop
	c@ $ff and 33 <? ( drop 1 ; )
	drop 0 ;

| a<b -- -
| a=b -- 0
| a>b -- +
::cmpstr | a b -- n
	( c@+ 1? $ff and rot	| a ac b 
		c@+ $ff and rot -	| a b bc-ac
		-? ( nip nip ; )
		1- 
		+? ( nip nip 1+ ; )	| 0 pasa
		drop swap )
	rot c@ - 0? ( nip ; )	| a bS b1 a1
	2drop 1 ;


::=s | s1 s2 -- 0/1
	( c@+ $ff and 32 >? toupp >r | s1 s2  r:c2
		swap c@+ $ff and toupp r> | s2 s1 c1 c2
		<>? ( 3drop 0 ; ) drop
		swap ) drop
	swap c@ $ff and 32 >? ( 2drop 0 ; )
	2drop 1 ;


::=w | s1 s2 -- 1/0
	( c@+ 32 >?
		toupp rot c@+ toupp rot -
		1? ( 3drop 0 ; )
		drop swap ) 2drop
	c@ $ff and 33 <? ( drop 1 ; )
	drop 0 ;

::=pre | adr "str" -- adr 1/0
	over swap
	( c@+ 1?  | adr adr' "str" c
		toupp rot c@+ toupp rot
		<>? ( 3drop 0 ; )
		drop swap ) 3drop
	1 ;

::=pos | s1 ".pos" -- s1 1/0
	over count
	rot count | s1 s1 cs1 "" c"
	rot swap - | s1 s1 "" dc
	rot + | s1 "" s1.
	= ;

::=lpos | lstr ".pos" -- str 1/0 ; lstr is the last adr in string
	count		| str ".pos" cnt 
	pick2 swap - | str ".pos" str-4 
	= ;
	

::findchar | adr char -- adr'/0
	swap
	( c@+ 0? ( nip nip ; )
		pick2 <>? drop ) drop nip
	1- ;

|----------- find str
:=p | s1 s2 -- 1/0
	( c@+ 1?
		rot c@+ rot -
		1? ( 3drop 0 ; )
		drop swap )
	3drop 1 ;

::findstr | adr "texto" -- adr'/0
	( 2dup =p 0?
		drop swap c@+
		0? ( nip nip ; )
		drop swap )
	2drop ;

:=pi | s1 s2 -- 1/0
	( c@+ 1?
		toupp rot c@+ toupp rot -
		1? ( 3drop 0 ; )
		drop swap )
	3drop 1 ;

::findstri | adr "texto" -- adr'/0
	( 2dup =pi 0?
		drop swap c@+
		0? ( nip nip ; )
		drop swap )
	2drop ;

|---- convert to number
#mbuff * 65

:mbuffi | -- adr
	'mbuff 64 + 0 over c! 1- ;

:sign | adr sign -- adr'
	-? ( drop $2d over c! ; ) drop 1+ ;

::.d | val -- str
	dup abs
	-? ( 2drop "-9223372036854775808" ; )
	mbuffi swap
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	swap sign ;

::.b | bin -- str
	mbuffi swap
	( dup $1 and $30 + pick2 c! swap 1- swap 1 >>> 1? ) drop
	1+ ;

::.h | hex -- str
	mbuffi swap
	( dup $f and $30 + $39 >? ( 7 + ) pick2 c! swap 1- swap 4 >>> 1? ) drop
	1+ ;

::.o | oct -- str
	mbuffi swap
	( dup $7 and $30 + pick2 c! swap 1- swap 3 >>> 1? ) drop
	1+ ;

:.f!
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	1+ $2e over c! 1-
	over abs 16 >>>
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	swap sign ;

::.f | fix -- str
 	mbuffi over	abs $ffff and 10000 16 *>> 10000 + .f! ;

::.f2 | fix -- str
 	mbuffi over	abs $ffff and 100 16 *>> 100 + .f! ;

::.f1 | fix -- str
 	mbuffi over abs $ffff and 10 16 *>> 10 + .f! ;

::.r. | b nro -- b ; right spaces
	'mbuff 64 + swap -
	swap ( over >?
		1- $20 over c!
		) drop ;

|----------------------------------
::trim | adr -- adr'
	( c@+ 1? $ff and 33 <? drop ) drop 1- ;

::trimc | car adr -- adr'
	( c@+ 1? pick2 =? ( drop nip 1- ; ) drop ) drop nip 1- ;
	
::trimcar | adr -- adr' c
	( c@+ $ff and 33 <? 0? ( swap 1- swap ; ) drop ) ;	

::trimstr | adr -- adr'
	( c@+ 1? 34 =? ( drop c@+ 34 <>? ( drop 2 - ; ) ) drop ) drop 1- ;

::>>cr | adr -- adr'
	( c@+ 1? 10 =? ( drop 1- ; ) 13 =? ( drop 1- ; ) drop ) drop 1- ;

::>>0 | adr -- adr' ; skip 0
	( c@+ 1? drop ) drop ;

::l0count | list -- cnt
	0 ( swap dup c@ 1? drop >>0 swap 1+ ) 2drop ;
	
::n>>0 | adr n -- adr' 
	( 1? swap >>0 swap 1- ) drop ;

::only13 | adr -- 'adr ; remove 10..reeplace with 13
	dup
	( c@+ 1?
		13 =? ( over c@	10 =? ( rot 1+ -rot ) drop )
		10 =? ( drop c@+ 13 <>? ( drop 1- 13 ) )
		rot c!+ swap ) nip
	swap c!+ ;

::>>sp | adr -- adr'	; next space
	( c@+ $ff and 32 >? drop ) drop 1- ;

::>>str | adr -- adr'	; next single quote
	( c@+ 1? 34 =? ( drop c@+ 34 <>? ( drop 1- ; ) ) drop ) drop 1- ;