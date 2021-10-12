| r3-gencode
| PHREDA 2018
|
^./r3base.r3
|^./r3cellana.r3

^./r3asm0.r3
|^./r3asm1.r3

#lastdircode

|----- division by constant
| http://www.flounder.com/multiplicative_inverse.htm

#ad		| d absoluto
#t #anc #p
#q1 #r1
#q2 #r2

#divm	| magic mult
#divs   | shift mult

:calcstep
	1 'p +!
	q1 1 << 'q1 ! r1 1 << 'r1 !
	r1 anc >=? ( 1 'q1 +! anc neg 'r1 +! ) drop
	q2 1 << 'q2 ! r2 1 << 'r2 !
	r2 ad >=? ( 1 'q2 +! ad neg 'r2 +! ) drop
	;

:calcmagic | d --
	dup abs 'ad !
    $80000000 over 31 >>> + 't !
    t dup 1 - swap ad mod - 'anc !
    31 'p !
    $80000000 anc / abs 'q1 !
    $80000000 q1 anc * - abs 'r1 !
	$80000000 ad / abs 'q2 !
	$80000000 q2 ad * - abs 'r2 !
	( calcstep
		ad r2 -	| delta
		q1 =? ( r1 0? ( swap 1 + swap ) drop )
		q1 >? drop ) drop
	q2 1 +
	swap -? ( drop neg 'divm ! p 'divs ! ; ) drop
	'divm ! p 'divs ! ;

| CLZ don't wrk on 64 bits!
:clzl
	0 swap
	$ffffffff00000000 nand? ( 32 << swap 32 + swap )
	$ffff000000000000 nand? ( 16 << swap 16 + swap )
	$ff00000000000000 nand? ( 8 << swap 8 + swap )
	$f000000000000000 nand? ( 4 << swap 4 + swap )
	$c000000000000000 nand? ( 2 << swap 2 + swap )
	$8000000000000000 nand? ( swap 1 + swap )
	drop ;

|--------------------------
#TKdup $23
#TKover $25
#TKswap $29
#TKand $35
#TK+ $38
#TK- $39
#TK* $3A
#TK<< $3C
#TK>> $3D
#TK>>> $3E
#TK*>> $42

|--- ajuste por signo
:signadj!+ | --
	TKdup code!+	| dup
	63 cte!+		| 63
	TK>>> code!+	| >>>
	TK+ code!+		| +
	;

|-----------------------------------
:idec | --
	getcte push.nro	2code!+ ;

:ihex | --
	getcte2 push.nro 2code!+ ;

:istr
	getval push.str 2code!+ ;

:idwor
	getval push.wrd 2code!+ ;

:idvar
	getval push.wrd 2code!+ ;

|----------- inline cte
:d1 8 >>> src + str>anro nip push.nro ;
:d2 8 >>> push.str ;
:d3 8 >>> push.wrd ;

#tcte d1 d1 d1 d1 d2 d3 d3 d3 d3

:icte | adr word -- adr
	"; INLINE CTE" ,ln
	dic>tok @
	d@ dup dup $ff and 7 -
	0 8 bt? ( 3 << 'tcte + @ ex code!+ ; )

|*************   #v1 #v2 ..if v1 is cte then crash!!
|	"inline 0" slog

	3drop
	0 push.nro
	0 cte!+
	;

:ivar
	getval
	dup dic>inf @
	$8 and? ( drop icte ; ) drop | inline VAR
	push.var
	2code!+ ;

|------------
:i;	2code!+	;
:i( 2code!+ stk.push ;
:i) 2code!+ stk.pop	;

:i[ 2code!+ stk.push ;
:i] 2code!+ stk.pop 1 push.wrd ;

:iex
	lastdircode dic>du
	dup ( 1? 1 - .drop ) drop
	+ ( 1? 1 - dup push.reg ) drop
	2code!+ ;

:gwhilejmp
	getval getiw
	1? ( stk.drop stk.push ) | while
	drop ;

:i0? :i1? :i+? :i-?
	2code!+
	gwhilejmp ;

:i<? :i>? :i=? :i>=? :i<=? :i<>? :iAND? :iNAND?
	2code!+ .drop
	gwhilejmp ;

:iBT?
	2code!+ .2drop
	gwhilejmp ;

:iDUP	2code!+ .dup ;
:iDROP	2code!+ .drop ;
:iOVER	2code!+ .over ;
:iPICK2	2code!+ .pick2 ;
:iPICK3	2code!+ .pick3 ;
:iPICK4	2code!+ .pick4 ;
:iSWAP	2code!+ .swap ;
:iNIP	2code!+ .nip ;
:iROT	2code!+ .rot ;
:i2DUP	2code!+ .2dup ;
:i2DROP	2code!+ .2drop ;
:i3DROP	2code!+ .3drop ;
:i4DROP	2code!+ .4drop ;
:i2OVER	2code!+ .2over ;
:i2SWAP	2code!+ .2swap ;

:i>R .drop 2code!+ ;
:iR> .dup 2code!+ ;
:iR@ .dup 2code!+ ;

:1stk | --1/0 ok
	bcode> 4 -
	'bcode <? ( -1 nip ; )
	@ $ff and 8 >? ( -1 nip ; ) drop
	0 ;

:2stk | --1/0 ok
	bcode> 8 -
	'bcode <? ( -1 nip ; )
	@ $ff and 8 >? ( -1 nip ; ) drop
	bcode> 4 - @ $ff and 8 >? ( -1 nip ; ) drop
	0 ;

:3stk | --1/0
	bcode> 12 -
	'bcode <? ( -1 nip ; )
	@ $ff and 8 >? ( -1 nip ; ) drop
	bcode> 8 - @ $ff and 8 >? ( -1 nip ; ) drop
	bcode> 4 - @ $ff and 8 >? ( -1 nip ; ) drop
	0 ;

:code<<<cte
	code<< code<< code<< vTOS cte!+ ;

:code<<cte
	code<< code<< vTOS cte!+ ;

:code<cte
	code<< vTOS cte!+ ;

:code<<2cte
	code<< code<< vNOS cte!+ vTOS cte!+ ;

:iAND
	2stk 0? ( drop .AND code<<cte ; ) drop
	2code!+ .drop ;
:iOR
	2stk 0? ( drop .OR code<<cte ; ) drop
	2code!+ .drop ;
:iXOR
	2stk 0? ( drop .XOR code<<cte ; ) drop
	2code!+ .drop ;
:iNOT
	1stk 0? ( drop .NOT code<cte ; ) drop
	2code!+ ;
:iNEG
	1stk 0? ( drop .NEG code<cte ; ) drop
	2code!+ ;
:i+
	2stk 0? ( drop .+ code<<cte ; ) drop
	2code!+ .drop ;
:i-
	2stk 0? ( drop .- code<<cte ; ) drop
	2code!+ .drop ;

|---------------- *
| 8 * --> 3 <<
:*pot
	code<<
	63 swap clzl - cte!+
	TK<< code!+ ;

| 7 * --> dup 3 << swap -
:*pot-1
	code<<
	TKdup code!+	| dup
	64 swap clzl - cte!+
	TK<<	code!+	| <<
	TKswap	code!+	| swap
	TK- code!+ | -
	;

:*nro
	vTOS
	dup 1 - nand? ( *pot ; )
	dup 1 + nand? ( *pot-1 ; )
	drop
	2code!+ .drop ;

:i*
	2stk 0? ( drop .* code<<cte ; ) drop
	1stk 0? ( drop *nro ; ) drop
	2code!+ .drop ;

|---- cte / --> divm divs *>> dup 63 >> -
:/cte
	calcmagic
	divm cte!+
	divs cte!+
	TK*>> code!+ 	| *>>
	signadj!+ ;

|----  2 / --> dup 63 >> + 2/
:/cte2
	TKdup code!+	| dup
	63 cte!+		| 63
	TK>>> code!+	| >>>
	TK+	code!+		| +
	1 cte!+
	TK>> code!+		| 2/
	;

|----  4 / --> dup 63 >> 30 >>> + 2 >>
:/nro
	code<<
	vTOS
	dup 1 - and? ( /cte ; )
	2 =? ( drop /cte2 ; )
	TKdup code!+ | dup
	63 cte!+
	TK>> code!+ | >>

	65 64 pick2 clzl - - cte!+
	TK>>> code!+ | >>>

	TK+	code!+	| +
	63 swap clzl - cte!+ | 2
	TK>> code!+ | >>
	;

:i/
	2stk 0? ( drop ./ code<<cte ; ) drop
	1stk 0? ( drop /nro ; ) drop
	2code!+ .drop ;
:i<<
	2stk 0? ( drop .<< code<<cte ; ) drop
	2code!+ .drop ;
:i>>
	2stk 0? ( drop .>> code<<cte ; ) drop
	2code!+ .drop ;
:i>>>
	2stk 0? ( drop .>>> code<<cte ; ) drop
	2code!+ .drop ;

|---------------- */
:i*/
	3stk 0? ( drop .*/ code<<<cte ; ) drop
	2code!+ .2drop ;

|---------------- /MOD
:/MODcte | val --
	dup calcmagic
	TKdup code!+	| dup
	divm cte!+
	divs cte!+
	TK*>> code!+ 	| *>>
	signadj!+
	TKswap code!+	| swap
	TKover code!+	| over
	cte!+			| NRO
	TK*	code!+		| *
	TK-	code!+		| -
	;

|----  8 /mod --> dup / swap mod
:/MODnro
	code<<
	vTOS
	dup 1 - and? ( /MODcte ; )
	swap
    TKdup code!+ 	| dup
	TKdup code!+	| dup
    63 cte!+ 		| 31
	TK>> code!+ 	| >>

	65 64 pick2 clzl - - cte!+ |30
	TK>>> code!+ 	| >>>

	TK+	code!+		| +

	63 over clzl - cte!+ 	| 2
	TK>> code!+ 	| >>

	TKswap code!+	| swap
	TKdup code!+ 	| dup
	63 cte!+ 		|31
	TK>> code!+ 	| >>

	65 64 pick2 clzl - - cte!+
	TK>>> code!+	| >>>

	TKswap	code!+	| swap
	TKover	code!+	| over
	TK+	code!+		| +
	1 - cte!+  		| mask
	TKand code!+	| AND
	TKswap	code!+	| swap
	TK-	code!+		| -
	;

:i/MOD
	2stk 0? ( drop ./MOD code<<2cte ; ) drop
	1stk 0? ( drop /MODnro ; ) drop
	2code!+ ;

|---------------- MOD
:MODcte
	dup calcmagic
	TKdup code!+	| dup
	divm cte!+
	divs cte!+
	TK*>> code!+	| *>>
	signadj!+
	cte!+			| NRO
	TK*	code!+		| *
	TK-	code!+		| -
	;


| from https://lemire.me/blog/2019/02/08/faster-remainders-when-the-divisor-is-a-constant-beating-compilers-and-libdivide/
|uint32_t d = ...;// your divisor > 0
|uint64_t c = UINT64_C(0xFFFFFFFFFFFFFFFF) / d + 1;
|// fastmod computes (n mod d) given precomputed c
|uint32_t fastmod(uint32_t n ) {
|  uint64_t lowbits = c * n;
|  return ((__uint128_t)lowbits * d) >> 64;
|}


|----  8 mod --> $7 and
|	dup 63 >> (33-4)29 >>> swap over + 7 and swap -
:MODnro
    code<<
	vTOS
	dup 1 - and? ( modcte ; )
	TKdup code!+ 	| dup 31
	63 cte!+
	TK>> code!+ 	| >>
	65 64 pick2 clzl - - cte!+
	TK>>> code!+	| >>>
	TKswap	code!+	| swap
	TKover	code!+	| over
	TK+	code!+		| +
	1 - cte!+ 		| mask
	TKand code!+	| AND
	TKswap	code!+	| swap
	TK-	code!+		| -
	;

:iMOD
	2stk 0? ( drop .MOD code<<cte ; ) drop
	1stk 0? ( drop MODnro ; ) drop
	2code!+ .drop ;

|------------------
:iABS
	1stk 0? ( drop .ABS code<cte ; ) drop
	2code!+ ;
:iSQRT
	1stk 0? ( drop .SQRT code<cte ; ) drop
	2code!+ ;
:iCLZ
	1stk 0? ( drop .CLZ code<cte ; ) drop
	2code!+ ;
:i*>>
	3stk 0? ( drop .*>> code<<<cte ; ) drop
	2code!+ .2drop ;
:i<</
	3stk 0? ( drop .<</ code<<<cte  ; ) drop
	2code!+ .2drop ;

:i@ :iC@ :iW@ :iD@		2code!+ ;
:i@+ :iC@+ :iW@+ :iD@+	2code!+ .dup ;
:i! :iC! :iW! :iD!		2code!+ .2drop ;
:i!+ :iC!+ :iW!+ :iD!+	2code!+ .drop ;
:i+! :iC+! :iW+! :iD+!	2code!+ .2drop ;

:i>A	2code!+ .drop ;
:iA>	2code!+ .dup ;
:iA+    2code!+ .drop ;
:iA@	2code!+ .dup ;
:iA!	2code!+ .drop ;
:iA@+   2code!+ .dup ;
:iA!+   2code!+ .drop ;
:iCA@	2code!+ .dup ;
:iCA!	2code!+ .drop ;
:iCA@+   2code!+ .dup ;
:iCA!+   2code!+ .drop ;
:iDA@	2code!+ .dup ;
:iDA!	2code!+ .drop ;
:iDA@+   2code!+ .dup ;
:iDA!+   2code!+ .drop ;

:i>B    2code!+ .drop ;
:iB>    2code!+ .dup ;
:iB+    2code!+ .drop ;
:iB@    2code!+ .dup ;
:iB!    2code!+ .drop ;
:iB@+   2code!+ .dup ;
:iB!+   2code!+ .drop ;
:iCB@    2code!+ .dup ;
:iCB!    2code!+ .drop ;
:iCB@+   2code!+ .dup ;
:iCB!+   2code!+ .drop ;
:iDB@    2code!+ .dup ;
:iDB!    2code!+ .drop ;
:iDB@+   2code!+ .dup ;
:iDB!+   2code!+ .drop ;

:iMOVE :iMOVE> :iFILL
:iCMOVE :iCMOVE> :iCFILL
:iDMOVE :iDMOVE> :iDFILL
	2code!+ .3drop ;

:iMEM 0 push.cte 2code!+ ;

:iLOADLIB 2code!+ ;
:iGETPROC 2code!+ .drop ;
:iSYS0 2code!+ ;
:iSYS1 2code!+ .drop ;
:iSYS2 2code!+ .2drop ;
:iSYS3 2code!+ .3drop ;
:iSYS4 2code!+ .4drop ;
:iSYS5 2code!+ .4drop .drop ;
:iSYS6 2code!+ .4drop .2drop ;
:iSYS7 2code!+ .4drop .3drop ;
:iSYS8 2code!+ .4drop .4drop ;
:iSYS9 2code!+ .4drop .4drop .drop ;
:iSYS10 2code!+ .4drop .4drop .2drop ;

|----------- inline word
#tocodeex 0

:inlinew
|	"; INLINE WORD " ,s dup dic>adr @ "%w" ,print ,cr

	dic>toklen 1 - | cut ;
	( 1? 1 - swap
		d@+ tocodeex ex |code!+
		swap ) 2drop ;

:iwor
	getval
	dup dic>inf @ $100 and? ( drop inlinew ; ) drop

	dic>du
	dup ( 1? 1 - .drop ) drop
	+ ( 1? 1 -  dup push.reg ) drop
	2code!+ ;

#vmc
0 0 0 0 0 0 0 idec ihex idec idec istr iwor ivar idwor idvar
i; i( i) i[ i] iEX i0? i1? i+? i-?
i<? i>? i=? i>=? i<=? i<>? iand? inand? iBT?
iDUP iDROP iOVER iPICK2 iPICK3 iPICK4 iSWAP iNIP
iROT i2DUP i2DROP i3DROP i4DROP i2OVER i2SWAP
i>R iR> iR@
iAND iOR iXOR
i+ i- i* i/
i<< i>> i>>>
iMOD i/MOD i*/ i*>> i<</
iNOT iNEG iABS iSQRT iCLZ
i@ iC@ iW@ iD@
i@+ iC@+ iW@+ iD@+
i! iC! iW! iD!
i!+ iC!+ iW!+ iD!+ |85 88
i+! iC+! iW+! iD+!
i>A iA> iA+
iA@ iA! iA@+ iA!+
iCA@ iCA! iCA@+ iCA!+
iDA@ iDA! iDA@+ iDA!+
i>B iB> iB+
iB@ iB! iB@+ iB!+
iCB@ iCB! iCB@+ iCB!+
iDB@ iDB! iDB@+ iDB!+
iMOVE iMOVE> iFILL
iCMOVE iCMOVE> iCFILL
iDMOVE iDMOVE> iDFILL
iMEM
iLOADLIB iGETPROC
iSYS0 iSYS1 iSYS2 iSYS3 iSYS4 iSYS5
iSYS6 iSYS7 iSYS8 iSYS9 iSYS10
0

|------------------------------------------
:tocode | adr token -- adr
"; " ,s over "%h:" ,print dup ,tokenprint 9 ,c ,printstka ,cr
|"asm/code.asm" savemem | debug
	$ff and 3 << 'vmc + @ ex ;

:,header | adr -- adr
    ";--------------------------" ,s ,cr
    "; " ,s
	dup dicc - 5 >> ,codeinfo
	,cr
	dicc> 32 - =? ( "INICIO:" ,s ,cr ; )
	
| dup @ ":%w " .print
	
	dup adr>dicname ,s
	":" ,s ,cr ;

:multientry | w adr len -- w adr len
	pick2 16 + @ | now word
	$81 and? ( drop ; ) drop | no multientry
	pick2 32 + | next word
	dup 16 + @ 12 >> $fff and 0? ( 2drop ; ) drop | no calls
	nip
	8 + @ 		| code
	pick2 8 + @ | codeant
	- 2 >> 		| real length
	;

|-----------------------------
:gencode | adr --
	dup 16 + @
	1 and? ( 2drop ; )	| code
	$100 and? ( over 32 + dicc> <? ( 3drop ; ) drop ) | inline
	12 >> $fff and 0? ( 2drop ; )	| no calls
	drop
	codeini
	,header
	dup 24 + @ $f and
	DeepStack

";---------OPT" ,ln |----- generate buffer
|"asm/code.asm" savemem | debug
	dup adr>toklen | w adr len
	multientry
	( 1? 1 - swap
		d@+ tocode
		swap ) 2drop

";---------ANA" ,ln |----- cell analisys
|"asm/code.asm" savemem | debug

|	dup 12 + @ $f and
|	anaDeepStack
|	'bcode ( bcode> <?
|		@+

||		"; " ,s dup ,tokenprint 9 ,c ,printstka ,cr
||		"asm/code.asm" savemem | debug

|		anastep
|		) drop
|   anaend

|	cellinfo
    ";---------GEN" ,ln |----- generate code
	24 + @ $f and	| use
	genasmcode
	
	;

|----------------------------
:debugblok
	";---- bloques ----" ,s
	blok >a
	,cr
	nbloques ( 1? 1 -
		nbloques over - "; %h. " ,print
		da@+ dup 28 >>>
		swap $ffffff and
		da@+
		"%d %d %d" ,print ,cr
		) drop ;

|----------------------------
::r3-gencode
	'tocode 'tocodeex !
	mark
	";---r3 compiler code.asm" ,ln
	"; " ,s 'r3filename ,s ,cr

|	"asm/code.asm" savemem
|	debugblok

	dicc ( dicc> <?
		dup gencode
|		sizemem 10 >> "; %d kb" ,print ,cr
|		"asm/code.asm" savememinc
		32 + ) drop

	0 ,c
	"asm/code.asm" savemem
	empty ;

