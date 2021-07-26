| PHREDA 2018
| r3 lib string

^r3/lib/math.r3

|------ STRING LIB
::zcopy | destino fuente -- destino' con 0
	( @+ 1? rot !+ swap ) rot !+ nip ;
::strcat | src des --
	( c@+ 1? drop ) drop 1 -
::strcpy | src des --
	( swap c@+ 1? rot c!+ ) nip swap c! ;
::strcpyl | src des -- ndes
	( swap c@+ 1? rot c!+ ) rot c!+ nip ;
::strcpyln | src des --
	( swap c@+ 1? 13 =? ( 2drop 0 swap c! ; )
		rot c!+ ) rot c!+ drop ;

::copynom | sc s1 --
	( c@+ 32 >?
		rot c!+ swap ) 2drop
	0 swap c! ;

::copystr | sc s1 --
	( c@+ 34 <>?
		rot c!+ swap ) 2drop
	0 swap c! ;

::toupp | c -- C
	$df and ;

::tolow | C -- c
	$20 or ;

::count | s1 -- s1 cnt	v3
	dup >a
	0 ( da@+ dup $01010101 -
		swap not and
		$80808080 nand? drop 4 + )
	$80 and? ( drop ; )
	$8000 and? ( drop 1 + ; )
	$800000 and? ( drop 2 + ; )
	drop 3 + ;

::count | s1 -- s1 cnt
	0 over ( c@+ 1?
		drop swap 1 + swap ) 2drop  ;

::= | s1 s2 -- 1/0
	( swap c@+ 1?
		toupp rot c@+ toupp rot -
		1? ( 3drop 0 ; ) drop
		) 2drop
	c@ $ff and 33 <? ( drop 1 ; )
	drop 0 ;

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

|----------- find str
:=p | s1 s2 -- 1/0
	( c@+ 1?
		rot c@+ rot -
		1? ( 3drop 0 ; )
		drop swap )
	3drop 1 ;

::findstr | adr "texto" -- adr'
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
	'mbuff 64 + 0 over c! 1 - ;

:sign | adr sign -- adr'
	-? ( drop $2d over c! ; ) drop 1 + ;

::.d | val -- str
	dup abs
	-? ( 2drop "-9223372036854775808" ; )
	mbuffi swap
	( 10/mod $30 + pick2 c! swap 1 - swap 1? ) drop
	swap sign ;

::.b | bin -- str
	mbuffi swap
	( dup $1 and $30 + pick2 c! swap 1 - swap 1 >>> 1? ) drop
	1 + ;

::.h | hex -- str
	mbuffi swap
	( dup $f and $30 + $39 >? ( 7 + ) pick2 c! swap 1 - swap 4 >>> 1? ) drop
	1 + ;

::.o | oct -- str
	mbuffi swap
	( dup $7 and $30 + pick2 c! swap 1 - swap 3 >>> 1? ) drop
	1 + ;

::.f | fix -- str
 	mbuffi over
	$ffff and 10000 16 *>> 10000 +
	( 10/mod $30 + pick2 c! swap 1 - swap 1? ) drop
	1 + $2e over c! 1 -
	over abs 16 >>
	( 10/mod $30 + pick2 c! swap 1 - swap 1? ) drop
	swap sign ;

::.r. | b nro -- b
	'mbuff 64 + swap -
	swap ( over >?
		1 - $20 over c!
		) drop ;

|----------------------------------
::trim | adr -- adr'
	( c@+ 0? ( 33 + ) $ff and 33 <? drop ) drop 1 - ;

::trimc | car adr -- adr'
	( c@+ 0? pick2 =? ( drop nip 1 - ; ) drop ) drop nip 1 - ;

::trim" | adr -- adr'
	( c@+ 1? 34 =? ( drop c@+ 34 <>? ( drop 2 - ; ) ) drop ) drop 1 - ;

::>>cr | adr -- adr'
	( c@+ 1? 10 =? ( drop 1 - ; ) 13 =? ( drop 1 - ; ) drop ) drop 1 - ;

::>>0 | adr -- adr' ; pasa 0
	( c@+ 1? drop ) drop ;

::only13 | adr -- ; remove 10..reeplace with 13
	dup
	( c@+ 1?
		13 =? ( over c@	10 =? ( rot 1 + rot rot ) drop )
		10 =? ( drop c@+ 13 <>? ( drop 1 - 13 ) )
		rot c!+ swap ) nip
	swap c! ;

::>>sp | adr -- adr'	; next space
	( c@+ $ff and 32 >? drop ) drop 1 - ;
