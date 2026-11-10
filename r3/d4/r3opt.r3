| r3 optimizer
| PHREDA 2024
| r3 to r3 optimizer translator
| plan:
|
| + remove noname definitions
| - reorder stack?, minimice heigth ( 2 3 4 + + =>> 3 4 + 2 + )
|
| + reemplace constant
| + calculate pure words
| + inline words
| + folder constant
| + cte * transform
| + cte / transform
| + cte mod transform
| + cte /mod transform
| + cte *>> transform
| + cte <</ transform
|-----------------
^r3/d4/r3token.r3
^r3/d4/r3vmd.r3

|^r3/lib/trace.r3

##biglit * 2048 | 256 big literals (not fit in 56 bits) by word
##biglit>
##tokana * $3ffff | 32767 tokens by word (after inline)
##tokana>
##optovf 0	| 1 if tokana or biglit overflow: the output is not valid

##inlinelenmax 7	| words with more tokens than this are not inlined (0 = no inline)

##curword -1	| word in analysis (an anon that calls it can not be moved before it)
#anw
##wend			| end of the word in analysis (0 = unknown)

| the anon ended by the ] token at 'to' has in its body a call to word nro?
::anoninline? | nro to -- 0/1
	swap 'anw !
	dup @ 8 >> $ffffffff and 3 << tok +		| to from
	( over <? @+ 
		dup $ff and 2 3 in? ( 					| .word .wadr
			over 8 >> $ffffffff and anw =? ( 4drop drop 1 ; ) drop ) 
		2drop ) 
	2drop 0 ;

|-------------------------------- PRINT
|  0     1    2     3     4    5     6
| .lits .lit .word .wadr .var .vadr .str ...
:.lits	8 >> 'biglit + @ "$%h" sprint ;
:.lit	8 >> "$%h" sprint ; | literal in opt is bigger
:.name	8 >> $ffffffff and 4 << dic + @ dic>name ;
:.word	.name "%w" sprint ;
:.wadr	.name "'%w" sprint ;
:.var	.name "%w" sprint ;
:.vadr	.name "'%w" sprint ;
:.str	8 >> $ffffffff and strm + ;
	
#bmacro .lits .lit .word .wadr .var .vadr .str 

::tokenstr | tok -- str
	dup $ff and 
	6 >? ( 7 - basename nip ; )
	3 << 'bmacro + @ ex ;

|-------------------------------- NAME >> NUMBER

:.word	8 >> $ffffffff and "w%h" sprint ;
:.wadr	8 >> $ffffffff and "'w%h" sprint ;
:.var	8 >> $ffffffff and "w%h" sprint ;
:.vadr	8 >> $ffffffff and "'w%h" sprint ;

#bmacro .lits .lit .word .wadr .var .vadr .str 

:base
	11 =? ( drop 8 >> $ffffffff and 0? ( drop "]" ; ) "'a%h" sprint ; )
	7 - basename nip ;
	
::tokenstrw | tok -- str
	dup $ff and 
	6 >? ( base ; )
	3 << 'bmacro + @ ex ;

|-------------------------------- NAME >> NUMBER
:.lits	8 >> 'biglit + @ "$%h" ,print ;
:.lit	8 >> -? ( "%d" ,print ; ) "$%h" ,print ; 
:.word	8 >> $ffffffff and "w%h" ,print ;
:.wadr	8 >> $ffffffff and "'w%h" ,print ;
:.var	8 >> $ffffffff and "w%h" ,print ;
:.vadr	8 >> $ffffffff and "'w%h" ,print ;
:.str	8 >> $ffffffff and strm + 34 ,c 
		( c@+ 1? 34 =? ( dup ,c ) ,c ) 2drop
		34 ,c ;
	
#bmacro .lits .lit .word .wadr .var .vadr .str 

::,tokenstrw | tok --
	dup $ff and 
	11 =? ( drop 8 >> $ffffffff and 0? ( drop "]" ,s ; ) "'a%h" ,print ; )	
	6 >? ( 7 - basename ,s drop ; )
	3 << 'bmacro + @ ex ;
	

:.l	40 >>> src + "%w" ,print ;

#bmacro .l .l .word .wadr .var .vadr .str 
	
::,tokenstrd
	dup $ff and 
|	dup "%h" .println .input
	6 >? ( 7 - basename ,s drop ; )
	3 << 'bmacro + @ ex ;
		

|--------------------------------	

:reseta	
	'tokana 'tokana> ! 
	'biglit 'biglit> ! 
	0 'wend ! ;
	
:,back | --
	-8 'tokana> +! ;
	
:,t	| tok --
	tokana> 'tokana $3fff8 + >=? ( 2drop 1 'optovf ! ; ) drop
	tokana> !+ 'tokana> !  ;
	
:,tlit | lit --
	8 << 1 or ,t ;
	
:,nlit | nro --
	dup 8 << 8 >> =? ( ,tlit ; ) | fit in 56bits
	biglit> 'biglit $7f8 + >=? ( 2drop 1 'optovf ! ; ) drop
	biglit> !+ 'biglit> !
	biglit> 'biglit - 8 - 8 << ,t | big nro  0 in token
	;
		
:,lit | token --
	40 >> src + str>anro nip | get the number from src
	,nlit ;
	
:1lit?	||||  LIT --
	tokana> 8 - 'tokana <? ( drop 0 ; ) 
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
	
:01lit?	||||  LIT NRO -- 
	tokana> 16 - 'tokana <? ( drop 0 ; ) 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop
	@ $ff and 2 =? ( drop 0 ; )  | no call
	6 >? ( drop 0 ; ) drop 1 ;
	
:2lit?	||||  LIT LIT --
	tokana> 16 - 'tokana <? ( drop 0 ; ) 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
	
:3lit?	||||  LIT LIT LIT --
	tokana> 24 - 'tokana <? ( drop 0 ; ) 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 	
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
	
:13lit?	||||  LIT NRO LIT --
	tokana> 24 - 'tokana <? ( drop 0 ; ) 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 
	@+ $ff and 2 =? ( drop 0 ; ) | no call
	6 >? ( 2drop 0 ; ) drop 
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
	

:01swap |||| a b -- b a
	tokana> 16 - @+ swap @ | [nos] tos
	tokana> 16 - !+ ! ;	

:12swap |||| a b c -- b a c
	tokana> 24 - @+ swap @ | [nos-1] [nos]
	tokana> 24 - !+ ! ;

|-----------------------	
:nlit? | n -- n 0/1
	tokana> over 3 << - 'tokana <? ( drop 0 ; ) | n tok
	over ( 1? 1- swap							| n n tok
		@+ $ff and 1 >? ( 3drop 0 ; ) drop		| n n tok 
		swap ) 2drop 1 ; 						| n 1

:litpush | tok -- value
	dup $ff and 1? ( drop 8 >> ; ) 
	drop 8 >> 'biglit + @ ;

:getTOS | -- TOSV
	tokana> 8 - @ litpush ;

:getNOS | -- NOSV
	tokana> 16 - @ litpush ;
	
:1litpush
	tokana> 8 - dup 'tokana> !
	@ litpush NPUSH ;	
:2litpush
	tokana> 16 - dup 'tokana> !
	@+ litpush NPUSH @ litpush NPUSH ;
:3litpush
	tokana> 24 - dup 'tokana> !
	@+ litpush NPUSH @+ litpush NPUSH @ litpush NPUSH ;
	
:nlitpush | n --
	tokana> over 3 << - dup 'tokana> !
	swap ( 1? 1- swap
		@+ litpush NPUSH swap ) 2drop ;

:,TOSLIT | -- ; TOS to tokana>
	TOS ,nlit .drop ;
:,2TOSLIT | --
	NOS @ ,nlit TOS ,nlit .2drop ;
:,ntoslit | n --
	0? ( drop ; )
	NOS over 2 - 3 << - over | n NOS n
	( 1- 1? swap @+ ,nlit swap ) 2drop
	TOS ,nlit
	( 1? 1- .drop ) drop ;
	
:dic@	| tok -- info1
	8 >> $ffffffff and 4 << dic + @ ;
:dic@use | tok -- usestack
	8 >> $ffffffff and 4 << dic + 8 + @ $ff and ;
:dic@loa | tok -- loadstack
	8 >> $ffffffff and 4 << dic + 8 + @ 
	dup $ff and swap 48 << 56 >> + ;
:dic@len | tok -- len
	8 >> $ffffffff and 4 << dic + 8 + @ 32 >>> ;
	
#deferinline
	
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva	

|--- strlen of a string literal: the count loop is evaluated at compile time
|--- the string is found in the virtual stack (tokana) even if there is code
|--- between the string and the count that does not touch its slot

#slpat ( 1 28 8 71 14 27 32 2 32 9 37 7 )	| 0 OVER ( C@+ 1? DROP SWAP 1+ SWAP ) 2DROP ;
#sa

:strlen? | tok -- 0/1 ; the word is the byte count loop (any name)
	dup dic@len 12 <>? ( 2drop 0 ; ) drop
	8 >> $ffffffff and nro>dic toklen drop 'sa !
	0 ( 12 <?
		dup 3 << sa + @ $ff and
		over 'slpat + c@ $ff and <>? ( 2drop 0 ; ) drop
		1+ ) drop
	sa @ 40 >> src + str>anro nip 1? ( drop 0 ; ) drop	| first literal is 0
	sa 56 + @ 8 >> $ffffffff and nro>dic @ dic>name "1+" =s ;

#fsS #ft #fq #fu #fsn #fsp

:tokuq | tok -- u q ; items used and produced in the data stack (u=-1 unknown)
	dup $ff and
	7 12 in? ( 2drop -1 0 ; )			| ; ( ) [ ] EX : not straight code
	2 =? ( drop dup dic@use swap dic@loa ; )
	6 <=? ( 2drop 0 1 ; )				| literals, addresses, vars, strings
	nip r3ainfo dup c@ $ff and swap 1+ c@ 56 << 56 >> over + ;

:findstrtos | -- stok/0 ; .str token that pushed the TOS, if untouched since
	0 'fsS ! 48 'fsn !
	tokana> 8 -
	( 'tokana >=?
		-1 'fsn +! fsn -? ( 2drop 0 ; ) drop
		dup @ 'ft !
		ft tokuq 'fq ! 'fu !
		fu -? ( 2drop 0 ; ) drop
		fsS fq <? ( over 'fsp ! 2drop ft $ff and 6 <>? ( drop 0 ; ) drop ft ; )
		drop fsS fq - fu + 'fsS !
		8 - )
	drop 0 ;

:,strlen | tok -- tok 0/1 ; count of a string literal -> literal
	dup strlen? 0? ( ; ) drop
	findstrtos 0? ( ; )
	8 >> $ffffffff and strm + count nip ,nlit 1 ;

|--- format strings: a call to ,print with a known format is unrolled
|--- "%d;%dH" ,print  ->  ,d $3B ,c ,d $48 ,c   (%d %h %b %k %% %. only)
|--- the wrappers (.print sprint ...) are inlined when they reach ,print with a known format

#prpat ( 8 71 14 2 9 37 7 )		| ( C@+ 1? ,emit ) 2DROP ;
#tkd #tkh #tkb #tkc #tks #fmtbad 1
#xcode								| address of ,code (defined later)
##fmtunroll 0						| 0 = do not unroll formats

:wtok | "name" -- tok/0 ; last definition with this name
	cntdef ( 1? 1-
		over over nro>dic @ dic>name =s 1? ( drop nip 8 << 2 or ; ) drop
		) 2drop 0 ;

:fmtinit
	",d" wtok 'tkd ! ",h" wtok 'tkh ! ",b" wtok 'tkb ! ",c" wtok 'tkc ! ",s" wtok 'tks !
	0 'fmtbad !
	tkd 0? ( 1 'fmtbad ! ) drop tkh 0? ( 1 'fmtbad ! ) drop tkb 0? ( 1 'fmtbad ! ) drop
	tkc 0? ( 1 'fmtbad ! ) drop tks 0? ( 1 'fmtbad ! ) drop
	fmtunroll 0? ( 1 'fmtbad ! ) drop ;

:isprint? | tok -- 0/1 ; the word is the ,print loop (any name)
	dup dic@len 7 <>? ( 2drop 0 ; ) drop
	8 >> $ffffffff and nro>dic toklen drop 'sa !
	0 ( 7 <?
		dup 3 << sa + @ $ff and
		over 'prpat + c@ $ff and <>? ( 2drop 0 ; ) drop
		1+ ) drop
	sa 24 + @ 8 >> $ffffffff and nro>dic @ dic>name ",emit" =s ;

#axt #axt2

:chk | t -- flag
	dup $ff and 2 <>? ( 2drop 0 ; ) drop axt ex ;
:chk2 | t -- flag
	dup $ff and 2 <>? ( 2drop 0 ; ) drop axt2 ex ;

:anycall | tok xt -- flag ; some call in the body satisfies xt
	'axt ! 8 >> $ffffffff and nro>dic toklen
	( 1? 1- swap @+ chk 1? ( drop 2drop 1 ; ) drop swap ) 2drop 0 ;
:anycall2 | tok xt -- flag
	'axt2 ! 8 >> $ffffffff and nro>dic toklen
	( 1? 1- swap @+ chk2 1? ( drop 2drop 1 ; ) drop swap ) 2drop 0 ;

:callsp1? | tok -- flag
	'isprint? anycall ;

#fe #fspec #fchunk #fok

:femit | tok --
	fe 0? ( 2drop ; ) drop xcode ex ;
:fnlit | n --
	fe 0? ( 2drop ; ) drop ,nlit ;
:fs | tok --
	1 'fspec +! femit ;
:fchar | c --
	1 'fchunk +! fchunk 8 >? ( 0 'fok ! ) drop
	$ff and fnlit tkc femit ;
:fspec1 | c --
	0 'fchunk !
	$64 =? ( drop tkd fs ; )
	$68 =? ( drop tkh fs ; )
	$62 =? ( drop tkb fs ; )
	$6B =? ( drop tkc fs ; )
	$25 =? ( drop $25 fnlit tkc femit ; )
	$2E =? ( drop 13 fnlit tkc femit ; )
	drop 0 'fok ! ;
:fone | ptr c -- ptr'
	$25 <>? ( fchar ; ) drop
	c@+ 0? ( 0 'fok ! swap 1- swap ) fspec1 ;
:fmtwalk | str -- ok
	0 'fspec ! 0 'fchunk ! 1 'fok !
	( c@+ 1? fone ) 2drop fok ;

:haspct? | str -- 0/1
	( c@+ 1? $25 =? ( 2drop 1 ; ) drop ) 2drop 0 ;

:fmtinfo | -- str/0 ; known format in the TOS that can be unrolled
	findstrtos 0? ( ; )
	8 >> $ffffffff and strm +
	dup haspct? 0? ( 2drop 0 ; ) drop
	0 'fe ! dup fmtwalk 0? ( 2drop 0 ; ) drop
	fspec 6 >? ( 2drop 0 ; ) drop ;

:fmtwrap? | tok -- 0/1 ; call to a word that reaches ,print and the TOS is a known format
	fmtbad 1? ( 2drop 0 ; ) drop
	dup dic@len 20 >? ( 2drop 0 ; ) drop
	dup isprint? 1? ( 2drop 0 ; ) drop
	dup 'isprint? anycall 0? ( drop dup 'callsp1? anycall2 ) 0? ( 2drop 0 ; ) drop
	drop fmtinfo 1? ( drop 1 ; ) ;

:deltok | ptr --
	( dup 8 + tokana> <? @ over ! 8 + ) 2drop -8 'tokana> +! ;

:,fmt | tok -- tok 0/1
	fmtbad 1? ( drop 0 ; ) drop
	dup isprint? 0? ( ; ) drop
	findstrtos 0? ( ; )
	8 >> $ffffffff and strm +				| tok str
	dup haspct? 0? ( 2drop tks xcode ex 1 ; ) drop		| no %: ,print -> ,s (drop the flag and the str)
	0 'fe ! dup fmtwalk 0? ( 2drop 0 ; ) drop
	fspec 6 >? ( 2drop 0 ; ) drop
	fsp deltok
	1 'fe ! fmtwalk drop 1 ;

|--- inline policy: inlinelenmax is the limit, but a word that grows the code
|--- is only inlined in a loop (hot) or if the growth is under the budget
|--- growth = (calls-1)*(len-1), budget = inlinebudget * inlinelenmax
##inlinebudget 2

:dic@calls | tok -- n
	8 >> $ffffffff and 4 << dic + 8 + @ 16 >> $ffff and ;

#lb #lp #lt

:isloop | -- 0/1 ; the block ( is a loop when it does not follow a condition
	lp 13 <? ( drop 1 ; ) 25 >? ( drop 1 ; ) drop 0 ;

:inloop? | -- 0/1 ; the end of tokana is inside a loop block
	0 'lb ! 0 'lp !
	'tokana ( tokana> <?
		@+ $ff and 'lt !
		lt 8 =? ( lb 1 << isloop or 'lb ! ) drop
		lt 10 =? ( lb 1 << 'lb ! ) drop
		lt 9 =? ( lb 1 >> 'lb ! ) drop
		lt 11 =? ( lb 1 >> 'lb ! ) drop
		lt 'lp ! ) drop
	lb 1? ( drop 1 ; ) drop 0 ;

:inlinecost? | tok -- 0/1 ; inline this call here?
	dup dic@len 1-					| tok n  (tokens without ;)
	2 <=? ( 2drop 1 ; )				| tiny: never bigger than the call
	over dic@calls
	1 <=? ( 3drop 1 ; )				| only one call: the word disappears
	1- over 1- *					| tok n growth
	inlinebudget inlinelenmax * <=? ( 3drop 1 ; ) drop
	2drop inloop? ;

:,inlinecode | ; inline code ?
	dup dic@ $78 and 1? ( drop ,t ; ) drop	| not inline (r desbalanceada, varios ;, recursiva, anonimas)
	dup fmtwrap? 1? ( drop deferinline ex ; ) drop	| format known: inline to unroll ,print
	dup dic@len inlinelenmax >? ( drop ,t ; ) drop	| max len inline
	dup inlinecost? 0? ( drop ,t ; ) drop
	deferinline ex ;
	
:,code | tok --
	,fmt 1? ( 2drop ; ) drop
	,strlen 1? ( 2drop ; ) drop
	dup dic@ $3f00 and? ( drop ,inlinecode ; ) drop	| no pure code -> normal tokenizer
	dup dic@use										| tok stack use
	nlit? 0? ( 	2drop ,inlinecode ; ) drop			| all are literal?
	
	nlitpush				| push the numbers in virtual stack
	dup exncode				| exec code in compile time
	dic@loa ,ntoslit		| pop the numbers to code
	;
	
| $..............10	var not int, is not a cte
| $............2000 definition has address

:,data | tok --
	dup dic@ 
	$14 and? ( drop ,t ; ) 			| real var
	$2000 and? ( dic>tok @ ,t drop ; )	| cte var with address: copy its address token (and drop tok)
	drop	
	|--- var is cte but is and address (***)
	|dup dic@ dic>tok @ $ff and		| tipo del token guardado en el cuerpo de la var
	|3 =? ( drop dic@ dic>tok @ ,t ; )	| .wadr -- cte es direccion de codigo
	|5 =? ( drop dic@ dic>tok @ ,t ; )	| .vadr -- cte es direccion de var
	|drop	
	|---------------
	dic@len fmem + @ ,nlit		| detect cte var (number)
	;

#TKdup 26 #TKover 28 #TKswap 32
#TKand 45 #TK+ 49 #TK- 50 #TK* 51 #TK/ 52
#TK<< 53 #TK>> 54 #TK>>> 55 
#TK*/ 58 #TK*>> 59 #TK<</ 60
#TKnot 61 #TKneg 62
#TKmod 56 #TK/mod 57
#TKor 46 #TKxor 47

|--- the result is a constant (x 0 and / x -1 or / x 0 *): the value below the literal is replaced
| it is only removed when the previous token just pushes a value (not a call or an operation)
:pushtok? | -- 0/1
	tokana> 'tokana <=? ( drop 0 ; ) drop
	tokana> 8 - @ $ff and
	2 =? ( drop 0 ; ) 6 >? ( drop 0 ; ) drop 1 ;

:,konst | v -- ; the TOS literal is removed, v is 0 or -1
	,back
	pushtok? 1? ( drop ,back ,nlit ; ) drop
	0? ( drop 0 ,tlit TKand ,t ; )
	drop -1 ,tlit TKor ,t ;


|----------------------- chains of literals
| x a op b op --> x (a op b) op      ( + - * and or xor )
| x a << b <<  -->  x a+b <<         ( << >> >>> when a+b < 64 )

#ck
:chain? | tk -- 0/1 ; tokana ends with: LIT tk LIT
	'ck !
	tokana> 24 - 'tokana <? ( drop 0 ; )
	@+ $ff and 1 >? ( 2drop 0 ; ) drop
	@+ $ff and ck <>? ( 2drop 0 ; ) drop
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;

:combine | l1 l2 tk -- v
	TK* =? ( drop * ; )
	TKand =? ( drop and ; )
	TKor =? ( drop or ; )
	drop xor ;

:chainmerge | tk -- ; LIT tk LIT --> LIT
	tokana> 24 - @ litpush getTOS rot combine
	-24 'tokana> +! ,nlit ;

:shmerge? | tk -- 0/1 ; LIT sh LIT --> LIT (a+b < 64)
	dup chain? 0? ( 2drop 0 ; ) drop
	tokana> 24 - @ litpush getTOS
	2dup or -? ( 4drop 0 ; ) drop
	+ 63 >? ( 2drop 0 ; )
	-24 'tokana> +! ,nlit drop 1 ;

:maskchain? | tk -- 0/1 ; LIT tk LIT with the same literal (1..63)
	chain? 0? ( ; ) drop
	tokana> 24 - @ litpush getTOS <>? ( drop 0 ; )
	1 <? ( drop 0 ; ) 63 >? ( drop 0 ; ) drop 1 ;

|--- + and - are a group: x a + b -  -->  x a-b +
:addchain? | -- 0/1 ; tokana ends with: LIT (+ or -) LIT
	tokana> 24 - 'tokana <? ( drop 0 ; )
	@+ $ff and 1 >? ( 2drop 0 ; ) drop
	@+ $ff and 49 <? ( 2drop 0 ; ) 50 >? ( 2drop 0 ; ) drop
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;

:sgnv | op v -- v' ; + v  /  - -v
	swap TK- =? ( drop neg ; ) drop ;

:addmerge | cur -- ; LIT p LIT --> LIT (+ or -)
	getTOS sgnv
	tokana> 24 - @ litpush
	tokana> 16 - @ $ff and swap sgnv
	+ -24 'tokana> +!
	0? ( drop ; )
	-? ( dup neg -? ( drop ,nlit TK+ ,t ; ) nip ,nlit TK- ,t ; )
	,nlit TK+ ,t ;


:,lAND
	getTOS 
	0? ( 2drop 0 ,konst ; ) 
	-1 =? ( 2drop ,back ; ) 
	drop ,t ;
:,AND
	2lit? 1? ( 2drop 2litpush .AND ,TOSLIT ; ) drop
	TKand chain? 1? ( drop TKand chainmerge ,AND ; ) drop
	1lit? 1? ( drop ,lAND ; ) drop	
	01lit? 1? ( drop 01swap ,lAND ; ) drop
	,t ;
	
:,lOR
	getTOS
	0? ( 2drop ,back ; ) 
	-1 =? ( 2drop -1 ,konst ; ) 
	drop ,t ;
:,OR
	2lit? 1? ( 2drop 2litpush .OR ,TOSLIT ; ) drop
	TKor chain? 1? ( drop TKor chainmerge ,OR ; ) drop
	1lit? 1? ( drop ,lOR ; ) drop	
	01lit? 1? ( drop 01swap ,lOR ; ) drop	
	,t ;

:,lXOR
	getTOS 
	0? ( 2drop ,back ; ) 
	-1 =? ( 2drop ,back TKnot ,t ; )
	drop ,t ;
:,XOR
	2lit? 1? ( 2drop 2litpush .XOR ,TOSLIT ; ) drop 
	TKxor chain? 1? ( drop TKxor chainmerge ,XOR ; ) drop
	1lit? 1? ( drop ,lXOR ; ) drop		
	01lit? 1? ( drop 01swap ,lXOR ; ) drop
	,t ;

:,lNAND
	getTOS 
	0? ( 2drop ,back ; )
	-1 =? ( 2drop 0 ,konst ; ) 
	drop ,t ;
:,NAND
	2lit? 1? ( 2drop 2litpush .NAND ,TOSLIT ; ) drop
	1lit? 1? ( drop ,lNAND ; ) drop	
	01lit? 1? ( drop 01swap ,lNAND ; ) drop	
	,t ;
	
:,l+
	getTOS 
	0? ( 2drop ,back ; ) 
	drop ,t	;
:,+
	2lit? 1? ( 2drop 2litpush .+ ,TOSLIT ; ) drop 
	addchain? 1? ( drop TK+ addmerge drop ; ) drop	| x a + b + --> x (a+b) +
	1lit? 1? ( drop ,l+ ; ) drop
	01lit? 1? ( drop 01swap ,l+ ; ) drop | lit nro + --> nro lit +
	,t ;
	
:,- 
	2lit? 1? ( 2drop 2litpush .- ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,back ; ) drop ) drop
	addchain? 1? ( drop TK- addmerge drop ; ) drop	| x a + b - --> x (a-b) +
	,t ;
	
|----------------------- *	
|>>>> 8 * --> 3 <<	
:,*pot | tos --
	,back
	msb ,tlit TK<< ,t ;
	
|>>>> 9 * --> dup 3 << +
:,*pot+1 | tos --
	,back TKdup ,t
	msb ,tlit TK<< ,t TK+ ,t ;
	
|>>>> 7 * --> dup 3 << swap -
:,*pot-1 | tos --	; tos = 2^k-1 : msb(tos) = k-1
	,back TKdup ,t
	msb 1+ ,tlit TK<< ,t TKswap ,t TK- ,t ;
	
:,lit* 	
	getTOS
	0? ( drop 0 ,konst ; ) 
	1 =? ( drop ,back ; ) 	| 1 * --> _
	-1 =? ( drop ,back tkneg ,t ; )
	dup 1- nand? ( ,*pot ; )
	dup 1- dup 1- nand? (  drop ,*pot+1 ; ) drop
	dup 1+ nand? ( ,*pot-1 ; )
	drop
	TK* ,t ;

:,* 
	2lit? 1? ( 2drop 2litpush .* ,TOSLIT ; ) drop 
	TK* chain? 1? ( drop TK* chainmerge ,* ; ) drop	| x a * b * --> x (a*b) *
	1lit? 1? ( 2drop ,lit* ; ) drop
	01lit? 1? ( 2drop 01swap ,lit* ; ) drop
	,t ;
	
|----------------------- /
|----- division by constant
| http://www.flounder.com/multiplicative_inverse.htm

#ad		| d abs
#anc 

#divm	| magic mult
#divs   | shift mult

:calcmagic | d --
	dup abs 'ad !
    $4000000000000000 over 62 >>> +
    dup 1- swap ad mod - 'anc !
    $4000000000000000 anc / abs
    $4000000000000000 over anc * - abs
	$4000000000000000 ad / abs
	$4000000000000000 over ad * - abs
	62 | cnt bits
	( 1+ >r | q1 r1 q2 r2
		2swap |  q2 r2 q1 r1
		2* swap 2* swap
		anc >=? ( swap 1+ swap anc - ) 
		2swap |  q1 r1 q2 r2 
		2* swap 2* swap
		ad >=? ( swap 1+ swap ad - ) 
		ad over -
		pick4 =? ( pick3 0? ( swap 1+ swap ) drop ) 
		pick4 >? drop 
		r>
		) drop
	drop 1+ nip nip | d q2
	swap -? ( drop neg 'divm ! r> 'divs ! ; ) drop
	'divm ! r> 'divs ! ;
	
|--- ajuste por signo: the magic quotient rounds toward -inf, add 1 if negative (trunc)
:,sigadj | --
	TKdup ,t 63 ,tlit TK>> ,t TK- ,t ;

|--- power of 2 (d=2^k): the VM truncates toward 0, so a bias is added before the shift
| x -- x+bias ; bias = (x<0) ? d-1 : 0
:,bias+ | d --
	TKdup ,t 63 ,tlit TK>> ,t 1- ,nlit TKand ,t TK+ ,t ;

|>>>> x / 2^k  -->  dup 63 >> (d-1) and + k >>
:,divpot | d --
	dup ,bias+ msb ,tlit TK>> ,t ;

|--- division by a constant d>=3 (not power of 2) : multiply by the magic number
:,divmagic | d --
	calcmagic divm ,nlit divs ,tlit TK*>> ,t ,sigadj ;

|--- d>=2 : x -- x/d
:,divp | d --
	dup 1- nand? ( ,divpot ; )
	,divmagic ;

|--- x / literal : 0 error, 1 nothing, -1 neg, d<0 --> -(x/|d|)
:,lit/ | --
	getTOS ,back
	0? ( drop 0 "0 division" error! ; )
	1 =? ( drop ; )
	-1 =? ( drop TKneg ,t ; )
	-? ( dup neg -? ( drop ,nlit TK/ ,t ; )		| minint: keep the division
		nip ,divp TKneg ,t ; )
	,divp ;

:,/ 
	2lit? 1? ( 2drop 2litpush ./ ,TOSLIT ; ) drop 
	1lit? 1? ( 2drop ,lit/ ; ) drop
	,t ;
	
|------------------------	
:maskgo | adr tok mask -- adr ; LIT sh LIT --> mask and
	-24 'tokana> +! ,nlit drop TKand ,AND ;

:,<< 
	2lit? 1? ( 2drop 2litpush .<< ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,back ; ) drop ) drop
	TK>> maskchain? 1? ( drop -1 getTOS << maskgo ; ) drop		| x n >> n << --> x -2^n and
	TK>>> maskchain? 1? ( drop -1 getTOS << maskgo ; ) drop
	TK<< shmerge? 1? ( drop ,<< ; ) drop						| x a << b << --> x a+b <<
	,t ;
:,>> 
	2lit? 1? ( 2drop 2litpush .>> ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,back ; ) drop ) drop
	TK>> shmerge? 1? ( drop ,>> ; ) drop						| x a >> b >> --> x a+b >>
	,t ;
:,>>>	
	2lit? 1? ( 2drop 2litpush .>>> ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,back ; ) drop ) drop
	TK<< maskchain? 1? ( drop -1 getTOS >>> maskgo ; ) drop		| x n << n >>> --> x (-1 >>> n) and
	TK>>> shmerge? 1? ( drop ,>>> ; ) drop					| x a >>> b >>> --> x a+b >>>
	,t ;
	
|----------------------- mod
| the sign of the result follows x (as in the VM)

|>>>> x mod 2^k  -->  dup dup 63 >> (d-1) and + -d and -
:,modpot | d --
	TKdup ,t dup ,bias+ neg ,nlit TKand ,t TK- ,t ;

|--- x mod d  d>=3 not pot :  x - (x/d)*d
:,modmagic | d --
	dup calcmagic
	TKdup ,t divm ,nlit divs ,tlit TK*>> ,t ,sigadj
	,nlit TK* ,t TK- ,t ;

:,modp | d -- ; d>=2
	dup 1- nand? ( ,modpot ; )
	,modmagic ;

:,litmod | --
	getTOS ,back
	0? ( drop 0 "0 division" error! ; )
	-? ( dup neg -? ( drop ,nlit TKmod ,t ; )	| x mod -d = x mod d
		nip )
	1 =? ( drop 0 ,tlit TKand ,t ; ) 
	,modp ;

:,mod
	2lit? 1? ( 2drop 2litpush .mod ,TOSLIT ; ) drop 
	1lit? 1? ( 2drop ,litmod ; ) drop
	,t ;

|----------------------------
| x d /mod --> q r   (q=x/d truncated, r has the sign of x)

|>>>> x 2^k /mod  -->  dup dup 63 >> (d-1) and + k >> swap over k << -
:,divmodpot | d --
	TKdup ,t dup ,bias+ 			| x y
	dup msb ,tlit TK>> ,t			| x q
	TKswap ,t TKover ,t				| q x q
	msb ,tlit TK<< ,t TK- ,t ;		| q r

:,divmodmagic | d --
	dup calcmagic
	TKdup ,t 
	divm ,nlit divs ,tlit TK*>> ,t ,sigadj
	TKswap ,t TKover ,t
	,nlit TK* ,t TK- ,t ;

:,divmodp | d -- ; d>=2
	dup 1- nand? ( ,divmodpot ; )
	,divmodmagic ;

:,lit/mod | -- 
	getTOS ,back
	0? ( drop 0 "0 division" error! ; )
	1 =? ( drop 0 ,tlit ; )
	-1 =? ( drop TKneg ,t 0 ,tlit ; )
	-? ( dup neg -? ( drop ,nlit TK/mod ,t ; )	| x /mod -d = -q r
		nip ,divmodp TKswap ,t TKneg ,t TKswap ,t ; )
	,divmodp ;
	
:,/mod
	2lit? 1? ( 2drop 2litpush ./mod ,2TOSLIT ; ) drop
	1lit? 1? ( 2drop ,lit/mod ; ) drop
	,t ;
	
|----------------------------
| x b c */ --> x*b/c   (b c literals)
:gcd | a b -- gcd
	( 1? swap over mod ) drop ;
	
:,lit*/ | -- ; a(runtime) b c(TOS) literales -- a*b/c
	getTOS ,back
	0? ( drop 0 "0 division" error! ; ) 			| c==0
	getTOS ,back 									| c b
	2dup abs swap abs gcd 							| c b gcd
	rot over / -rot /								| c' b'		; reduzco
	swap											| b' c'
	-? ( neg swap neg swap )						| c'>0
	over 0? ( 3drop 0 ,tlit TKand ,t ; ) drop		| b'=0 --> 0
	1 =? ( drop ,nlit ,lit* ; )						| c'=1 --> a*b'
	over 1 =? ( drop nip ,nlit ,lit/ ; ) drop		| b'=1 --> a/c'
	over -1 =? ( drop nip ,nlit ,lit/ TKneg ,t ; ) drop	| b'=-1 --> -(a/c')
	swap ,nlit ,nlit TK*/ ,t ;						| no exact division (b' first, then c')

:,*/
	3lit? 1? ( 2drop 3litpush .*/ ,TOSLIT ; ) drop
	2lit? 1? ( 2drop ,lit*/ ; ) drop
	13lit? 1? ( 2drop 12swap ,lit*/ ; ) drop
	,t ;

|----------------------------
| x b c *>> --> (x*b)>>c  : arithmetic shift (floor), no sigadj here!
:,shr | c -- ; x >> c
	0? ( drop ; )
	,tlit TK>> ,t ;

:,lit2pot*>> | c b -- ; b=2^k
	msb -							| c-k
	-? ( neg ,tlit TK<< ,t ; )		| x << (k-c)
	,shr ;							| x >> (c-k)

:,lit2pot0*>> | c d cp -- ;  4.0 16 *>> -->  4 * --> 2 << 
	drop swap >> ,nlit ,lit* ;

:2lit*>>	
	getTOS ,back      | c
	getTOS ,back      | c b
	0? ( 2drop 0 ,tlit TKand ,t ; )
	1 =? ( drop ,shr ; )						| x >> c
	-1 =? ( drop TKneg ,t ,shr ; )				| neg x >> c
	dup 1- nand? ( ,lit2pot*>> ; )				| b = 2^k
	dup neg dup 1- nand? ( nip TKneg ,t ,lit2pot*>> ; ) drop	| b = -2^k
	dup ctz pick2 >=? ( ,lit2pot0*>> ; ) drop	| b = m*2^c --> x*m
	,nlit ,tlit TK*>> ,t ;
	
:,*>> 
	3lit? 1? ( 2drop 3litpush .*>> ,TOSLIT ; ) drop
	2lit? 1? ( 2drop 2lit*>> ; ) drop	
	13lit? 1? ( 2drop 12swap 2lit*>> ; ) drop	| lit any lit --> any lit lit
	,t ;
	
|----------------------------	
| x b c <</ --> (x<<c)/b
:,shl | c -- ; x << c
	0? ( drop ; )
	,tlit TK<< ,t ;

:,lit2pot<</ | c b -- ; b=2^k
	msb -							| c-k
	-? ( neg 1 swap << ,divpot ; )	| x / 2^(k-c)
	,shl ;							| x << (c-k)

:,lit2<<p | c d -- ; d>=2
	dup 1- nand? ( ,lit2pot<</ ; )
	2dup nip calcmagic
	divs pick2 <? ( drop ,nlit ,tlit TK<</ ,t ; ) drop	| no room for the shift: keep <</
	drop divm ,nlit divs swap - ,tlit TK*>> ,t ,sigadj ;

:,lit2<</ | -- 
	getTOS ,back      | c
	getTOS ,back      | c b
	0? ( 2drop 0 "0 division" error! ; )
	1 =? ( drop ,shl ; )						| (a<<c)/1 = a<<c
	-1 =? ( drop ,shl TKneg ,t ; )				| (a<<c)/-1 = -(a<<c)
	-? ( dup neg -? ( drop ,nlit ,tlit TK<</ ,t ; )	| (a<<c)/-d = -((a<<c)/d)
		nip ,lit2<<p TKneg ,t ; )
	,lit2<<p ;
	
:,<</
	3lit? 1? ( 2drop 3litpush .<</ ,TOSLIT ; ) drop
	2lit? 1? ( 2drop ,lit2<</ ; ) drop	
	,t ;

|----------------------------
:,NOT 
	1lit? 1? ( 2drop 1litpush .not ,TOSLIT ; ) drop 
	,t ;
:,NEG 
	1lit? 1? ( 2drop 1litpush .neg ,TOSLIT ; ) drop 
	,t ;
:,ABS 
	1lit? 1? ( 2drop 1litpush .abs ,TOSLIT ; ) drop 
	,t ;
:,SQRT 
	1lit? 1? ( 2drop 1litpush .sqrt ,TOSLIT ; ) drop 
	,t ;
:,CLZ 
	1lit? 1? ( 2drop 1litpush .clz ,TOSLIT ; ) drop 
	,t ;
	
:,[ | adr tok -- adr'
	over over 24 << 32 >> +			| adr tok to ( the ] token )
	dup curword swap anoninline? 
	1? ( 2drop ,t ; ) drop			| the anon calls this word, keep [ ... ] inline
	nip nip ;						| skip the body, it is a word apart (:aN)

:,] | adr tok -- adr'
	over 8 - curword swap anoninline? 
	1? ( drop drop 11 ,t ; ) drop	| inline anon: ] without index
	,t ;
	
|----------------------- conditions
| + condition with literals and a ( ) block: false --> the block is removed
|                                            true  --> the block is inlined
| + x 0 =? --> 0?    x 0 <>? --> 1?    x 0 <? --> -?    x 0 >=? --> +?
| tokens: 0? 1? +? -? <? >? =? >=? <=? <>? AND? NAND? (13..24) ; IN? is not changed

#xana				| ,ana (defined later)
#ctk #cadr #ctok #cres #cend #csemi
#bd #bpos #bsemi #tb

:evalc1 | v t -- 0/1
	13 =? ( drop 0? ( drop 1 ; ) drop 0 ; )
	14 =? ( drop 1? ( drop 1 ; ) drop 0 ; )
	15 =? ( drop +? ( drop 1 ; ) drop 0 ; )
	drop -? ( drop 1 ; ) drop 0 ;

:evalc2 | a b t -- 0/1
	17 =? ( drop <? ( drop 1 ; ) drop 0 ; )
	18 =? ( drop >? ( drop 1 ; ) drop 0 ; )
	19 =? ( drop =? ( drop 1 ; ) drop 0 ; )
	20 =? ( drop >=? ( drop 1 ; ) drop 0 ; )
	21 =? ( drop <=? ( drop 1 ; ) drop 0 ; )
	22 =? ( drop <>? ( drop 1 ; ) drop 0 ; )
	23 =? ( drop and? ( drop 1 ; ) drop 0 ; )
	drop nand? ( drop 1 ; ) drop 0 ;

:condval | -- 0/1/-1 ; value of the condition (-1: it is not constant)
	ctk 16 <=? ( drop 1lit? 0? ( drop -1 ; ) drop getTOS ctk evalc1 ; ) drop
	ctk 24 <=? ( drop 2lit? 0? ( drop -1 ; ) drop getNOS getTOS ctk evalc2 ; ) drop
	-1 ;

:hasblock? | -- 0/1 ; the condition is followed by a ( ) block
	cadr @ $ff and 8 =? ( drop 1 ; ) drop 0 ;

:blockscan | adr -- adr' semi ; adr is a ( : the address after its ) and the first ; at its top level
	0 'bd ! 0 'bsemi !
	( dup 'bpos ! @+ $ff and
		7 =? ( bd 1 =? ( bsemi 0? ( bpos 'bsemi ! ) drop ) drop )
		8 =? ( 1 'bd +! ) 10 =? ( 1 'bd +! )
		9 =? ( -1 'bd +! ) 11 =? ( -1 'bd +! )
		drop bd 1? drop ) drop
	bsemi ;

:depth0? | -- 0/1 ; there is no open ( or [ in tokana
	0 'tb !
	'tokana ( tokana> <? @+ $ff and
		8 =? ( 1 'tb +! ) 10 =? ( 1 'tb +! )
		9 =? ( -1 'tb +! ) 11 =? ( -1 'tb +! ) drop ) drop
	tb 0? ( drop 1 ; ) drop 0 ;

:procrange | end adr -- ; analyse the tokens from adr to end
	( over <? @+ xana ex ) 2drop ;

:popops | -- ; the compare literal of a two operands condition is not needed
	ctk 16 >? ( -8 'tokana> +! ) drop ;

:condblk | res -- adr/0 ; condition with literals and a block (0: not changed)
	'cres !
	cadr blockscan 'csemi ! 'cend !
	cres 0? ( drop popops cend ; ) drop						| false: the block is removed
	csemi 0? ( drop popops cend 8 - cadr 8 + procrange cend ; ) drop	| true: only the block
	wend 0? ( drop 0 ; ) drop								| true with ; : the rest of the word is dead
	depth0? 0? ( drop 0 ; ) drop
	popops csemi cadr 8 + procrange csemi @ ,t wend ;

:cond0tk | t -- t'/0 ; condition with 0 as compare literal
	19 =? ( drop 13 ; ) 22 =? ( drop 14 ; ) 17 =? ( drop 16 ; ) 20 =? ( drop 15 ; )
	drop 0 ;

:condred | -- adr/0 ; x 0 =? --> 0?
	ctk cond0tk 0? ( ; )
	1lit? 0? ( 2drop 0 ; ) drop
	getTOS 1? ( 2drop 0 ; ) drop
	,back ,t cadr ;

:condconst | -- adr/0 ; condition with literals and a block
	hasblock? 0? ( ; ) drop
	condval -1 =? ( drop 0 ; )
	condblk ;

:,cond | adr tok -- adr
	dup $ff and 'ctk ! 'ctok ! 'cadr !
	condconst 1? ( ; ) drop
	condred 1? ( ; ) drop
	cadr ctok ,t ;

#optw
,LIT ,LIT ,CODE ,t ,DATA ,t ,t 	|.lit .lit .code .acode .data .adata .str
,t ,t ,t ,[ ,] 				|.; .( .) .[ .] 
,t ,cond ,cond ,cond ,cond 	|.EX .0? .1? .+? .-? 
,cond ,cond ,cond ,cond ,cond ,cond ,cond ,cond ,t 	|.<? .>? .=? .>=? .<=? .<>? .A? .N? .IN? 
,t ,t ,t ,t ,t ,t ,t ,t 	|.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP 
,t ,t ,t ,t ,t ,t ,t ,t 	|.ROT .-ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP 
,t ,t ,t 					|.>R .R> .R@ 
,AND ,OR ,XOR ,NAND 
,+ ,- ,* ,/ ,<< ,>> ,>>>
,MOD ,/MOD ,*/ ,*>> ,<</ 			
,NOT ,NEG ,ABS ,SQRT ,CLZ 
,t ,t ,t ,t 		|.@ .C@ .W@ .D@ 
,t ,t ,t ,t 		|.@+ .C@+ .W@+ .D@+ 
,t ,t ,t ,t 		|.! .C! .W! .D! 
,t ,t ,t ,t 		|.!+ .C!+ .W!+ .D!+ 
,t ,t ,t ,t 		|.+! .C+! .W+! .D+! 
,t ,t ,t ,t ,t ,t ,t |.>A .A> .A+ .A@ .A! .A@+ .A!+ 
,t ,t ,t ,t 		|.cA@ .cA! .cA@+ .cA!+ 
,t ,t ,t ,t 		|.dA@ .dA! .dA@+ .dA!+ 
,t ,t ,t ,t ,t ,t ,t |.>B .B> .B+ .B@ .B! .B@+ .B!+ 
,t ,t ,t ,t 		|.cB@ .cB! .cB@+ .cB!+ 
,t ,t ,t ,t 		|.dB@ .dB! .dB@+ .dB!+ 
,t ,t				| ab[ ]ba
,t ,t ,t 			|.MOVE .MOVE> .FILL 
,t ,t ,t 			|.CMOVE .CMOVE> .CFILL 
,t ,t ,t 			|.DMOVE .DMOVE> .DFILL 
,t ,t ,t 			|.MEM .LOADLIB .GETPROC
,t ,t ,t ,t ,t ,t 	|.SYS0 .SYS1 .SYS2 .SYS3 .SYS4 .SYS5
,t ,t ,t ,t ,t 		|.SYS6 .SYS7 .SYS8 .SYS9 .SYS10 
0	
	
:,ana | nro --
	|dup 40 >> src + "%w " filelog
	dup $ff and 
	|dup "(%d)%." filelog
	3 << 'optw + @ ex ;
	
|--------------
:lenword | dicc - toklast tokini
	toklend 3 << over + swap ;

:lenwor | dicc - toklast tokini
	toklen 3 << over + swap ;
	
:dataw | dicc --
	lenword ( over <? @+ ,ana 
		| error?
		) 2drop ;
	
:codew | dicc --
	lenwor over 'wend ! ( over <? @+ ,ana 
		| error?
		) 2drop ;
		
:inlineword | tok --
	tok>dic toklen 1- | ini cnt | remove ;
	3 << over + swap 
	( over <? @+ ,ana ) 2drop ;

|<<<< need the call once before all
::deferwi
	'inlineword 'deferinline !
	',code 'xcode !
	',ana 'xana !
	fmtinit ;
	
::wordanalysis | nro --
	reseta
	dup 'curword !
	4 << dic + 
	dup @ 1 and? ( drop dataw "DATA" .println ; ) drop |******** !!! no analizar
	codew ;
	
::wordanon | tok> tok --
	reseta -1 'curword !
	( over <? @+ ,ana ) 2drop ;

| $..............04	1 es usado con direccion
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva	
| $3c and 1?
::worduse? | nro -- 0/1
	4 << dic + dup 8 + @  | dicc dicinfo2
	dup 16 >> $ffff and 0? ( nip nip ; ) drop	| no calls-> NOT need code
	32 >>> inlinelenmax >? ( 2drop 1 ; ) drop		| larger for inline -> need code
	@ $7c and 1? ( drop 1 ; ) drop				| not inline-> need code (misma mascara + 'adr)
	0 ;

::datause? | nro -- 0/1
	4 << dic + dup 8 + @
	16 >> $ffff and 0? ( nip ; ) drop	| no calls-> NOT need code
	@ 
	$14 and? ( ; ) | not init var or used in adress
	drop 0 ;
