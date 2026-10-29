| PHREDA 2018
| r3 lib string

^r3/lib/math.r3

|------ STRING LIB
	
::strcpyl | src des -- ndes ; copy string src (with its 0) to des, ndes = address after the final 0
	( swap c@+ 1? rot c!+ ) nip swap c!+ ;
::strcpy | src des -- ; copy string src (with its 0) to des
	strcpyl drop ;
::strcat | src des -- ; append string src to the end of string des
	( c@+ 1? drop ) drop 1- strcpy ;
::strcpylnl | src des -- ndes ; copy src to des up to CR, LF or 0, add a 0; ndes = address after it
	( swap c@+ 1? 
		10 =? ( 2drop 0 swap c!+ ; )
		13 =? ( 2drop 0 swap c!+ ; ) 
		rot c!+ ) nip swap c!+ ;
::strcpyln | src des -- ; copy a line of src to des (up to CR, LF or 0), add a 0
	strcpylnl drop ;

::copynom | dst src -- ; copy the first word of src (up to a char <= 32) to dst, add a 0
	( c@+ $ff and 32 >?
		rot c!+ swap ) 2drop
	0 swap c! ;

::copystr | dst src -- ; copy src to dst up to the first " (not included), add a 0
	( c@+ 34 <>?
		rot c!+ swap ) 2drop
	0 swap c! ;

::strpath | src dst -- ; copy the path of src to dst (all before the last /, without it)
	over swap
	strcpyl 
	( over =? ( 0 swap c! drop ; )
		dup c@ $2f <>? drop 1- ) drop 
	0 swap c! drop ;

::toupp | c -- C ; clear bit 5: a-z to A-Z, no range check (only for letters)
	$df and ;

::tolow | C -- c ; set bit 5: A-Z to a-z, no range check (only for letters)
	$20 or ;

::count | s1 -- s1 cnt ; string length in bytes, reading 8 bytes at a time
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

::count | s1 -- s1 cnt ; string length in bytes, one byte at a time
	0 over ( c@+ 1?
		drop swap 1+ swap ) 2drop ;

|---- UTF-8
::utf8c? | c -- flag ; 0 if c is a UTF-8 continuation byte (10xxxxxx), else not 0
	$80 xor $c0 and ;

::utf8len | c -- n ; length (1-4) of the UTF-8 sequence that starts with byte c, 0 if invalid
	$ff and
	$80 <? ( drop 1 ; ) $c0 <? ( drop 0 ; )
	$e0 <? ( drop 2 ; ) $f0 <? ( drop 3 ; )
	$f8 <? ( drop 4 ; ) drop 0 ;

::utf8skip | adr -- adr' ; skip the continuation bytes at adr
	( dup c@ utf8c? 0? drop 1+ ) drop ;

::utf8next | adr -- adr' ; address of the next UTF-8 character (stays at the final 0)
	dup c@ 0? ( drop ; ) drop
	1+ utf8skip ;

::utf8lead | adr -- adr' ; go back to the first byte of the character that contains adr
	( dup c@ utf8c? 0? drop 1- ) drop ;

::utf8prev | adr -- adr' ; address of the previous UTF-8 character
	1- utf8lead ;

:u8tail | adr n -- flag 
	( 1? 1- over c@ utf8c? 1? ( 3drop 0 ; ) drop swap 1+ swap ) 2drop 1 ;

:ucont | adr cp -- adr' cp'
	swap c@+ $3f and rot 6 << or ;

::utf8@+ | adr -- adr' cp ; read the UTF-8 character at adr as a code point; an invalid byte is returned as is
	c@+ $ff and
	$c0 <? ( ; )
	$e0 <? ( over 1 u8tail 0? ( drop ; ) drop $1f and ucont ; )
	$f0 <? ( over 2 u8tail 0? ( drop ; ) drop $0f and ucont ucont ; )
	$f8 <? ( over 3 u8tail 0? ( drop ; ) drop $07 and ucont ucont ucont ; )
	;

::utf8!+ | cp adr -- adr' ; write code point cp as UTF-8 (1 to 4 bytes) at adr, no 0
	swap
	$7f <=? ( swap c!+ ; )
	$7ff <=? (
		dup 6 >> $c0 or rot c!+ 
		swap $3f and $80 or swap c!+ ; )
	$ffff <=? (
		dup 12 >> $e0 or rot c!+ 
		swap dup 6 >> $3f and $80 or rot c!+ 
		swap $3f and $80 or swap c!+ ; )
	dup 18 >> $f0 or rot c!+ 
	swap dup 12 >> $3f and $80 or rot c!+ 
	swap dup 6 >> $3f and $80 or rot c!+ 
	swap $3f and $80 or swap c!+ ;

::utf8count | str -- str count ; number of UTF-8 characters of str
	0 over ( c@+ 1? 
		utf8c? 1? ( rot 1+ -rot ) drop ) 2drop ;

::utf8ncpy | str 'dst cnt -- 'end ; copy cnt UTF-8 chars of str to 'dst; 'end is after the last byte, no 0 added
	ab[
	swap >a swap >b | a=dst b=src
	( 1? 1-
		cb@+ ca!+
		( cb@ utf8c? 0? drop cb@+ ca!+ ) drop
		) drop
	a>
	]ba ;
	
::utf8bytes | str cnt -- str bytes ; byte length of the first cnt UTF-8 chars of str (up to the final 0)
	over | str cnt p
	( swap 1? 1- swap
		c@+ 0? ( drop 1- nip over - ; ) drop
		utf8skip
		) drop
	over - ;	
		
|----- Compare	
::= | s1 s2 -- 1/0 ; 1 if s1 equals s2 ignoring case; s2 may continue after a blank
	( swap c@+ 1?
		toupp rot c@+ toupp rot -
		1? ( 3drop 0 ; ) drop
		) 2drop
	c@ $ff and 33 <? ( drop 1 ; )
	drop 0 ;

::cmpstr | a b -- n ; compare strings (case-sensitive): <0 if a<b, 0 if equal, >0 if a>b
	( c@+ 1? $ff and rot	| a ac b 
		c@+ $ff and rot -	| a b bc-ac
		-? ( nip nip ; )
		1- 
		+? ( nip nip 1+ ; )	| 0 pasa
		drop swap )
	rot c@ - 0? ( nip ; )	| a bS b1 a1
	2drop 1 ;


::=s | s1 s2 -- 1/0 ; 1 if the first word of s1 equals the first word of s2, ignoring case
	( c@+ $ff and 32 >? toupp >r | s1 s2  r:c2
		swap c@+ $ff and toupp r> | s2 s1 c1 c2
		<>? ( 3drop 0 ; ) drop
		swap ) drop
	swap c@ $ff and 32 >? ( 2drop 0 ; )
	2drop 1 ;


::=w | s1 s2 -- 1/0 ; like =s but ASCII only: a byte >= 128 ends the word (use =s for UTF-8)
	( c@+ 32 >?
		toupp rot c@+ toupp rot -
		1? ( 3drop 0 ; )
		drop swap ) 2drop
	c@ $ff and 33 <? ( drop 1 ; )
	drop 0 ;

::=pre | adr "str" -- adr 1/0 ; 1 if the string at adr starts with "str", ignoring case
	over swap
	( c@+ 1?  | adr adr' "str" c
		toupp rot c@+ toupp rot
		<>? ( 3drop 0 ; )
		drop swap ) 3drop
	1 ;

::=pos | s1 ".pos" -- s1 1/0 ; 1 if s1 ends with ".pos", ignoring case
	over count
	rot count | s1 s1 cs1 "" c"
	rot swap - | s1 s1 "" dc
	rot + | s1 "" s1.
	= ;

::=lpos | lstr ".pos" -- lstr 1/0 ; like =pos, lstr = address of the final 0 of the string
	count		| str ".pos" cnt 
	pick2 swap - | str ".pos" str-4 
	= ;
	

::findchar | adr char -- adr'/0 ; address of the first char in the string at adr, 0 if not found
	swap
	( c@+ 0? ( nip nip ; )
		pick2 <>? drop ) drop nip
	1- ;

:findbyte | v64 char -- check
	$ff and dup 8 << or dup 16 << or dup 32 << or | $0101010101010101 *
	xor	dup  $0101010101010101 - swap neg and $8080808080808080 and ;
	
|----------- find str
:=p | s1 s2 -- 1/0
	( c@+ 1?
		rot c@+ rot -
		1? ( 3drop 0 ; )
		drop swap )
	3drop 1 ;

::findstr | adr "text" -- adr'/0 ; address of the first "text" in the string at adr, 0 if not found
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

::findstri | adr "text" -- adr'/0 ; like findstr ignoring case
	( 2dup =pi 0?
		drop swap c@+
		0? ( nip nip ; )
		drop swap )
	2drop ;

::rfindstri | start "text" adr -- adr'/0 ; search "text" backwards from adr down to start, ignoring case; 0 if none
	( dup pick2 =pi 0? drop
		1- pick2 <? ( 3drop 0 ; ) 
		) drop nip nip ;

|---- convert to number
#mbuff * 64

:mbuffi | -- adr
	'mbuff 63 + 0 over c! 1- ;

:sign | adr sign -- adr'
	-? ( drop $2d over c! ; ) drop 1+ ;

::.d | val -- str ; signed integer to decimal string (shared buffer, valid until the next .d .b .h .o .f call)
	dup abs
	-? ( 2drop "-9223372036854775808" ; )
	mbuffi swap
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	swap sign ;

::.b | bin -- str ; binary string of val, unsigned (shared buffer)
	mbuffi swap
	( dup $1 and $30 + pick2 c! swap 1- swap 1 >>> 1? ) drop
	1+ ;

::.h | hex -- str ; hexadecimal string of val, uppercase, no prefix, unsigned (shared buffer)
	mbuffi swap
	( dup $f and $30 + $39 >? ( 7 + ) pick2 c! swap 1- swap 4 >>> 1? ) drop
	1+ ;

::.o | oct -- str ; octal string of val, unsigned (shared buffer)
	mbuffi swap
	( dup $7 and $30 + pick2 c! swap 1- swap 3 >>> 1? ) drop
	1+ ;

:.f!
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	1+ $2e over c! 1-
	swap 16 >>> 
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	swap sign ;

::.f | fix -- str ; 48.16 fixed point to decimal string with 4 decimals, rounded (shared buffer)
	dup abs 3 + mbuffi | 3 = 0.00005
	over $ffff and 10000 16 *>> 10000 + .f! ; 

::.f2 | fix -- str ; 48.16 fixed point to decimal string with 2 decimals, rounded (shared buffer)
	dup abs 328 + mbuffi | 328 = 0.005
	over $ffff and 100 16 *>> 100 + .f! ;

::.f1 | fix -- str ; 48.16 fixed point to decimal string with 1 decimal, rounded (shared buffer)
	dup abs 3277 + mbuffi | 3277 = 0.05
	over $ffff and 10 16 *>> 10 + .f! ;

::.r. | str width -- str' ; pad on the left with spaces up to width chars; str comes from .d .h .f ...
	'mbuff 63 + swap -
	swap ( over >?
		1- $20 over c!
		) drop ;
		
:.f!
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	1+ $2e over c! 1-
	swap 32 >>> 
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	swap sign ;
	
::.fd | fix -- str ; 32.32 fixed point to decimal string with 8 decimals, rounded (shared buffer)
	dup abs 21 + mbuffi | 0.000000005
	over $ffffffff and 100000000 32 *>> 100000000 + .f! ;		

|----------------------------------
::trim | adr -- adr' ; skip chars <= 32; adr' is the first one > 32 or the final 0
	( c@+ 1? $ff and 33 <? drop ) drop 1- ;

::trimc | char adr -- adr' ; address of the first char found, or of the final 0 if none
	( c@+ 1? pick2 =? ( drop nip 1- ; ) drop ) drop nip 1- ;
	
::trimcar | adr -- adr' c ; skip chars <= 32 and read the next char c (0 at the end); adr' is after c
	( c@+ $ff and 33 <? 0? ( swap 1- swap ; ) drop ) ;	

::trimstr | adr -- adr' ; address of the closing " of the string text at adr ("" is an escaped quote)
	( c@+ 1? 34 =? ( drop c@+ 34 <>? ( drop 2 - ; ) ) drop ) drop 1- ;

::>>cr | adr -- adr' ; address of the next CR or LF, or of the final 0
	( c@+ 1? 10 =? ( drop 1- ; ) 13 =? ( drop 1- ; ) drop ) drop 1- ;

::>>0 | adr -- adr' ; address after the next 0 (the next string of a list of strings)
	( c@+ 1? drop ) drop ;

::l0count | list -- cnt ; number of strings of a list of 0-terminated strings (the list ends with an empty string)
	0 ( swap dup c@ 1? drop >>0 swap 1+ ) 2drop ;
	
::n>>0 | adr n -- adr' ; skip n strings of a list of 0-terminated strings
	( 1? swap >>0 swap 1- ) drop ;

::only10 | adr -- 'end ; in place, change CRLF, CR and LFCR to LF; 'end is after the final 0
	dup
	( c@+ 1?
		10 =? ( over c@	13 =? ( rot 1+ -rot ) drop )
		13 =? ( drop c@+ 10 <>? ( drop 1- 10 ) )
		rot c!+ swap ) nip
	swap c!+ ;

::only13 | adr -- 'end ; in place, change CRLF, LF and LFCR to CR; 'end is after the final 0
	dup
	( c@+ 1?
		13 =? ( over c@	10 =? ( rot 1+ -rot ) drop )
		10 =? ( drop c@+ 13 <>? ( drop 1- 13 ) )
		rot c!+ swap ) nip
	swap c!+ ;

::>>sp | adr -- adr' ; address of the next char <= 32 (blank), or of the final 0
	( c@+ $ff and 32 >? drop ) drop 1- ;

::>>str | adr -- adr' ; address after the closing " of the string text at adr ("" is an escaped quote)
	( c@+ 1? 34 =? ( drop c@+ 34 <>? ( drop 1- ; ) ) drop ) drop 1- ;