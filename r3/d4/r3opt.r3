| r3 optimizer
| PHREDA 2024
| r3 to r3 optimizer translator
| plan:
|
| x remove noname definitions
| - reorder stack?, minimice heigth ( 2 3 4 + + =>> 3 4 + 2 + )
|
| + reemplace constant
| + calculate pure words
| + inline words
| + folder constant
| + cte * transform
| + cte / transform
| - cte mod transform
|-----------------
^r3/d4/r3token.r3
^r3/d4/r3vmd.r3


##biglit * 80 | 10 bigliteral !!!!!!!
##biglit>
##tokana * $ffff | 8192 tokens !!!!!!!
##tokana>

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
	11 =? ( drop 8 >> $ffffffff and tok - 3 >> "'a%h" sprint ; )
	7 - basename nip ;
	
::tokenstrw | tok -- str
	dup $ff and 
	6 >? ( base ; )
	3 << 'bmacro + @ ex ;

|-------------------------------- NAME >> NUMBER
:.lits	8 >> 'biglit + @ "$%h" ,print ;
:.lit	8 >> -? ( neg "-$%h" ,print ; ) "$%h" ,print ; | literal in opt is bigger
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
	11 =? ( drop 8 >> $ffffffff and tok - 3 >> "'a%h" ,print ; )	
	6 >? ( 7 - basename ,s drop ; )
	3 << 'bmacro + @ ex ;
	

:.l	40 >>> src + "%w" ,print ;

#bmacro .l .l .word .wadr .var .vadr .str 
	
::,tokenstrd
	dup $ff and 
|	dup "%h" .println
|	.input
	6 >? ( 7 - basename ,s drop ; )
	3 << 'bmacro + @ ex ;
		

|--------------------------------	

:reseta	
	'tokana 'tokana> ! 
	'biglit 'biglit> ! ;
:,<< | --
	-8 'tokana> +! 
	| big? -8 'biglit> +! | reuse bigliteral 
	;
:,t	| tok --
	tokana> !+ 'tokana> !  ;
:,tlit | lit --
	8 << 1 or ,t ;
	
:,nlit | nro --
	dup 8 << 8 >> =? ( ,tlit ; ) | fit in 56bits
	biglit> !+ 'biglit> !
	biglit> 'biglit - 8 - 8 << ,t | big nro  0 in token
	;
		
:,lit | token --
	40 >> src + str>anro nip | get the number from src
	,nlit ;
	
:1lit?	
	tokana> 8 - 'tokana <? ( drop 0 ; ) 
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
:2lit?	
	tokana> 16 - 'tokana <? ( drop 0 ; ) 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
:3lit?	
	tokana> 24 - 'tokana <? ( drop 0 ; ) 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 	
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
:nlit? | n -- n 0/1
	tokana> over 3 << - 'tokana <? ( drop 0 ; ) | n tok
	over ( 1? 1 - swap							| n n tok
		@+ $ff and 1 >? ( 3drop 0 ; ) drop		| n n tok 
		swap ) 2drop 1 ; 						| n 1

:litpush | tok --
	dup $ff and 1? ( drop 8 >> ; ) 
	drop 8 >> 'biglit + @ ;

:getTOS | -- TOSV
	tokana> 8 - @ litpush ;
	
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
	swap ( 1? 1 - swap
		@+ litpush NPUSH swap ) 2drop ;

:,TOSLIT | -- ; TOS to tokana>
	TOS ,nlit .drop ;
:,2TOSLIT | --
	NOS @ ,nlit TOS ,nlit .2drop ;
:,ntoslit | n --
	0? ( drop ; )
	NOS over 2 - 3 << - over | n NOS n
	( 1 - 1? swap @+ ,nlit swap ) 2drop
	TOS ,nlit
	( 1? 1 - .drop ) drop ;
	
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
:,inlinecode | ; inline code ?
	dup dic@ $38 and 1? ( drop ,t ; ) drop	| not inlline
	dup dic@len 7 >? ( drop ,t ; ) drop		| min len inline
	deferinline ex ;
	
:,code | tok --
	dup dic@ $100 and? ( drop ,inlinecode ; ) drop	| no pure code -> normal tokenizer
	dup dic@use										| tok stack use
	nlit? 0? ( 2drop ,inlinecode ; ) drop			| all are literal?
	nlitpush		| push the numbers in virtual stack
	dup exncode		| exec code in compile time
	dic@loa ,ntoslit		| pop the numbers to code
	;
	
:,data | tok --
	dup dic@ $4 and? ( drop ,t ; ) drop | real var
	dic@len fmem + @ ,nlit		| detect cte var
	;

#tkdup 26 #Tkover 28 #tkswap 32
#TKand 44 #tk+ 47 #tk- 48 #tk* 49 
#tk<< 51 #TK>> 52 #TK>>> 53 #TK*>> 57
#tknot 59 #tkneg 60

:,lAND
	getTOS -1 =? ( 2drop ,<< ; ) drop ,t ;
:,AND
	2lit? 1? ( 2drop 2litpush .AND ,TOSLIT ; ) drop
	1lit? 1? ( drop ,lAND ; ) drop	
	,t ;
	
:,lOR
	getTOS 0? ( 2drop ,<< ; ) drop ,t ;
:,OR
	2lit? 1? ( 2drop 2litpush .OR ,TOSLIT ; ) drop
	1lit? 1? ( drop ,lOR ; ) drop	
	,t ;

:,lXOR
	getTOS 
	0? ( 2drop ,<< ; ) 
	-1 =? ( 2drop ,<< TKnot ,t ; )
	drop ,t ;
:,XOR
	2lit? 1? ( 2drop 2litpush .XOR ,TOSLIT ; ) drop 
	1lit? 1? ( drop ,lXOR ; ) drop		
	,t ;

:,+
	2lit? 1? ( 2drop 2litpush .+ ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,<< ; ) drop ) drop
	,t ;
	
:,- 
	2lit? 1? ( 2drop 2litpush .- ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,<< ; ) drop ) drop
	,t ;
	
|----------------------- *	
|>>>> 8 * --> 3 <<	
:,*pot | tok tos --
	nip ,<<
	63 swap clz - ,tlit
	TK<< ,t ;
|>>>> 9 * --> dup 3 << +
:,*pot+1 | tok tos --
	nip ,<< TKdup ,t
	64 swap clz - 1 - ,tlit
	TK<< ,t TK+ ,t ;
|>>>> 7 * --> dup 3 << swap -
:,*pot-1 | tok tos --
	nip ,<< TKdup ,t
	64 swap clz - ,tlit
	TK<< ,t TKswap ,t TK- ,t ;
:,lit* 	
	getTOS
	0? ( 2drop TKand ,t ; ) 
	1 =? ( 2drop ,<< ; ) 	| 1 * --> _
	-1 =? ( 2drop ,<< tkneg ,t ; )
	dup 1 - nand? ( ,*pot ; )
	dup 1 - dup 1 - nand? (  drop ,*pot+1 ; ) drop
	dup 1 + nand? ( ,*pot-1 ; )
	drop
	,t ;
	
:,* 
	2lit? 1? ( 2drop 2litpush .* ,TOSLIT ; ) drop 
	1lit? 1? ( drop ,lit* ; ) drop
	,t ;
	
|----------------------- /
|----- division by constant
| http://www.flounder.com/multiplicative_inverse.htm

#ad		| d absoluto
#t #anc #p #q1 #r1 #q2 #r2

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
	
|--- ajuste por signo
:,sigadj | --
	TKdup ,t 63 ,tlit TK>> ,t TK- ,t ;
	
|>>>> n / 	log(n) >> dup 63 >> - ; | shift and adjust
:,/pot | tok tos --
	nip ,<<
	63 swap clz - ,tlit
	TK>> ,t ,sigadj ;	
	
:,lit/
	getTOS
	0? ( 2drop 0 "0 division" error! ; )
	1 =? ( 2drop ,<< ; ) 
	-1 =? ( 2drop ,<< tkneg ,t ; )
	dup 1 - nand? ( ,/pot ; )	
	nip ,<< 
	calcmagic
	divm ,tlit divs ,tlit TK*>> ,t ,sigadj ;
	
:,/ 
	2lit? 1? ( 2drop 2litpush ./ ,TOSLIT ; ) drop 
	1lit? 1? ( drop ,lit/ ; ) drop
	,t ;
	
|------------------------	
:,<< 
	2lit? 1? ( 2drop 2litpush .<< ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,<< ; ) drop ) drop
	,t ;
:,>> 
	2lit? 1? ( 2drop 2litpush .>> ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,<< ; ) drop ) drop	
	,t ;
:,>>>	
	2lit? 1? ( 2drop 2litpush .>>> ,TOSLIT ; ) drop 
	1lit? 1? ( getTOS 0? ( 3drop ,<< ; ) drop ) drop	
	,t ;
	
|----------------------- mod	
:,litmod | *****
	getTOS
|	0? ( 2drop 0 "0 division" error! ; )
|	1 =? ( 2drop ,<< ; ) 
|	-1 =? ( 2drop ,<< tkneg ,t ; )
|	dup 1 - nand? ( ,modpot ; )	
	nip ,<< 
	dup calcmagic 
	TKdup ,t divm ,tlit	divs ,tlit TK*>> ,t ,sigadj
	,tlit TK* ,t TK- ,t 
	;

:,mod
	2lit? 1? ( 2drop 2litpush .mod ,TOSLIT ; ) drop 
	|1lit? 1? ( drop ,litmod ; ) drop
	,t ;
	
:,/mod
	2lit? 1? ( 2drop 2litpush ./mod ,2TOSLIT ; ) drop
|	1lit? 1? ( ) drop
	,t ;
	
:,*/
	3lit? 1? ( 2drop 3litpush .*/ ,TOSLIT ; ) drop
|	2lit? 1? ( ) drop
|	1lit? 1? ( ) drop
	,t ;
:,*>> 
	3lit? 1? ( 2drop 3litpush .*>> ,TOSLIT ; ) drop
|	2lit? 1? ( ) drop	
|	1lit? 1? ( ) drop
	,t ;
:,<</
	3lit? 1? ( 2drop 3litpush .<</ ,TOSLIT ; ) drop
|	2lit? 1? ( ) drop	
|	1lit? 1? ( ) drop
	,t ;
	
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
	24 << 32 >> + ;
:,]
	,t ;
	
#optw
,LIT ,LIT ,CODE ,t ,DATA ,t ,t 	|.lit .lit .code .acode .data .adata .str
,t ,t ,t ,[ ,] 				|.; .( .) .[ .] 
,t ,t ,t ,t ,t 				|.EX .0? .1? .+? .-? 
,t ,t ,t ,t ,t ,t ,t ,t ,t 	|.<? .>? .=? .>=? .<=? .<>? .A? .N? .B? 
,t ,t ,t ,t ,t ,t ,t ,t 	|.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP 
,t ,t ,t ,t ,t ,t ,t 		|.ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP 
,t ,t ,t 					|.>R .R> .R@ 
,AND ,OR ,XOR ,+ ,- ,* ,/ ,<< ,>> ,>>>
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
,t ,t ,t 			|.MOVE .MOVE> .FILL 
,t ,t ,t 			|.CMOVE .CMOVE> .CFILL 
,t ,t ,t 			|.DMOVE .DMOVE> .DFILL 
,t ,t ,t 			|.MEM .LOADLIB .GETPROC
,t ,t ,t ,t ,t ,t 	|.SYS0 .SYS1 .SYS2 .SYS3 .SYS4 .SYS5
,t ,t ,t ,t ,t 		|.SYS6 .SYS7 .SYS8 .SYS9 .SYS10 
0	
	
:,ana | nro --
|	dup 40 >> src + "%w " .print
	dup $ff and 3 << 'optw + @ ex ;
	
|--------------
:lenword | dicc - toklast tokini
	toklend 3 << over + swap ;

:lenwor | dicc - toklast tokini
	toklen 3 << over + swap ;
	
:dataw | dicc --
	lenword ( over <? @+ ,ana ) 2drop ;
	
:codew | dicc --
	lenwor ( over <? @+ ,ana ) 2drop ;
		
:inlineword | tok --
	tok>dic toklen 1 - | ini cnt | remove ;
	3 << over + swap 
	( over <? @+ ,ana ) 2drop ;

|<<<< need the call once before all
::deferwi
	'inlineword 'deferinline ! ;
	
::wordanalysis | nro --
	reseta
	4 << dic + 
	dup @ 1 and? ( drop dataw ; ) drop
	codew ;
	
::wordanon | tok> tok --
	reseta
	( over <? @+ ,ana ) 2drop ;

| $..............04	1 es usado con direccion
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva	
| $3c and 1?
::worduse? | nro -- 0/1
	4 << dic + dup 8 + @  | dicc dicinfo2
	dup 16 >> $ffff and 0? ( nip nip ; ) drop	| no calls-> NOT need code
	32 >>> 7 >? ( 2drop 1 ; ) drop				| larger for inline -> need code
	@ $3c and 1? ( drop 1 ; ) drop				| not inline-> need code
	0 ;

::datause? | nro -- 0/1
	4 << dic + dup 8 + @
	16 >> $ffff and 0? ( nip ; ) drop	| no calls-> NOT need code
	@ $4 and? ( ; ) drop 0 ;
