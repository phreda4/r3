| r3 map memory
| PHREDA 2024
^r3/lib/parse.r3
^r3/lib/str.r3

##filename * 1024
##r3path * 1024

|------------- MEMORY MAP
##src	| src code
##dic	| dicctionary
##dic>
##dic<	
##tok	| tokens
##tok>
##strm	| string
##strm>
##fmem	| var + freemem
##fmem>

|---- includes
| 'name|'memsrc
##inc * $fff
##inc> 'inc

##boot>>

##cntdef
##cnttok
##cntstr

##error
##lerror

##flag
##datac

#r3base
";" "(" ")" "[" "]" "EX" "0?" "1?" "+?" "-?"
"<?" ">?" "=?" ">=?" "<=?" "<>?" "AND?" "NAND?" "BT?"
"DUP" "DROP" "OVER" "PICK2" "PICK3" "PICK4" "SWAP" "NIP"
"ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP"
">R" "R>" "R@" "AND" "OR" "XOR" "+" "-" "*" "/" "<<" ">>" ">>>"
"MOD" "/MOD" "*/" "*>>" "<</" "NOT" "NEG" "ABS" "SQRT" "CLZ"
"@" "C@" "W@" "D@" "@+" "C@+" "W@+" "D@+"
"!" "C!" "W!" "D!" "!+" "C!+" "W!+" "D!+" 
"+!" "C+!" "W+!" "D+!" 
">A" "A>" "A+" "A@" "A!" "A@+" "A!+" "CA@" "CA!" "CA@+" "CA!+" "DA@" "DA!" "DA@+" "DA!+"
">B" "B>" "B+" "B@" "B!" "B@+" "B!+" "CB@" "CB!" "CB@+" "CB!+" "DB@" "DB!" "DB@+" "DB!+" 
"MOVE" "MOVE>" "FILL" "CMOVE" "CMOVE>" "CFILL" "DMOVE" "DMOVE>" "DFILL" 
"MEM" "LOADLIB" "GETPROC"
"SYS0" "SYS1" "SYS2" "SYS3" "SYS4" "SYS5" "SYS6" "SYS7" "SYS8" "SYS9" "SYS10" ( 0 )

| uso-dData-dRet-FLAG
| FLAG 
| %0001 mem
| %0010 A
| %0100 B


#r3basemov (
0 0 0 0		| ; | fin de palabra (12)
0 0 0 2		| (
0 0 0 4		| )
0 0 0 5		| [
0 1 0 6		| ]
1 -1 0 10	| EX  x/0 --
1 0 0 3		|0? a -- a
1 0 0 3		|1? a -- a
1 0 0 3		|+? a -- a
1 0 0 3		|-? a -- a
2 -1 0 3	|<?  ab -- a
2 -1 0 3	|>?  ab -- a
2 -1 0 3	|=?  ab -- a
2 -1 0 3	|>=? ab -- a
2 -1 0 3	|<=? ab -- a
2 -1 0 3	|<>? ab -- a
2 -1 0 3	|and?  ab -- a
2 -1 0 3	|nand? ab -- a
3 -2 0 3	|BTW? abc -- a
1  1 0 0	|DUP    a -- aa
1 -1 0 0	|DROP  a --
2 1 0 0		|OVER   ab -- aba
3 1 0 0		|PICK2  abc -- abca
4 1 0 0		|PICK3  abcd -- abcda
5 1 0 0		|PICK4  abcde -- abcdea
2 0 0 0		|SWAP   ab -- ba
2 -1 0 0	|NIP   ab -- b
3 0 0 0		|ROT	abc -- bca
2 2 0 0		|2DUP   ab -- abab
2 -2 0 0	|2DROP ab --
3 -3 0 0	|3DROP abc --
4 -4 0 0	|4DROP abcd --
4 2 0 0		|2OVER  abcd -- abcdab
4 0 0 0		|2SWAP  abcd -- cdab
1 -1 1 8	|>R    a -- R: -- a
0 1 -1 8	|R>    -- a R: a --
0 1 0 8		|R@      -- a R: a -- a
2 -1 0 0	|AND	ab -- c
2 -1 0 0	|OR    ab -- c
2 -1 0 0	|XOR   ab -- c
2 -1 0 0	|+		ab -- c
2 -1 0 0	|-     ab -- c
2 -1 0 0	|*     ab -- c
2 -1 0 0	|/     ab -- c
2 -1 0 0	|<<    ab -- c
2 -1 0 0	|>>    ab -- c
2 -1 0 0	|>>>    ab -- c
2 -1 0 0	|MOD    ab -- c
2 0 0 0		|/MOD   ab -- cd
3 -2 0 0	|*/    abc -- d
3 -2 0 0	|*>>   abc -- d
3 -2 0 0	|<</	abc -- d
1 0 0 0		|NOT    a -- b
1 0 0 0		|NEG    a -- b
1 0 0 0		|ABS    a -- b
1 0 0 0		|SQRT	a -- b
1 0 0 0		|CLZ	a -- b
1 0 0 1		|@      a -- b
1 0 0 1		|C@     a -- b
1 0 0 1		|W@     a -- b
1 0 0 1		|D@     a -- b
1 1 0 1		|@+     a -- bc
1 1 0 1		|C@+    a -- bc
1 1 0 1		|W@+    a -- bc
1 1 0 1		|D@+    a -- bc
2 -2 0 1	|!     ab --
2 -2 0 1	|C!    ab --
2 -2 0 1	|W!    ab --
2 -2 0 1	|D!    ab --
2 -1 0 1	|!+    ab -- c
2 -1 0 1	|C!+   ab -- c
2 -1 0 1	|W!+   ab -- c
2 -1 0 1	|D!+   ab -- c
2 -2 0 1	|+!    ab --
2 -2 0 1	|C+!   ab --
2 -2 0 1	|W+!   ab --
2 -2 0 1	|D+!   ab --
1 -1 0 2	|>A
0 1 0 2		|A>
1 -1 0 2	|A+
0 1 0 3		|A@
1 -1 0 3 	|A!
0 1 0 3		|A@+
1 -1 0 3	|A!+

0 1 0 3		|cA@
1 -1 0 3 	|cA!
0 1 0 3		|cA@+
1 -1 0 3	|cA!+

0 1 0 3		|dA@
1 -1 0 3 	|dA!
0 1 0 3		|dA@+
1 -1 0 3	|dA!+

1 -1 0 4	|>B
0 1 0 4		|B>
1 -1 0 4	|B+

0 1 0 5		|B@
1 -1 0 5 	|B!
0 1 0 5		|B@+
1 -1 0 5	|B!+

0 1 0 5		|cB@
1 -1 0 5 	|cB!
0 1 0 5		|cB@+
1 -1 0 5	|cB!+

0 1 0 5		|dB@
1 -1 0 5 	|dB!
0 1 0 5		|dB@+
1 -1 0 5	|dB!+

3 -3 0 1	|MOVE  abc --
3 -3 0 1	|MOVE> abc --
3 -3 0 1	|FILL abc --

3 -3 0 1	|CMOVE abc --
3 -3 0 1	|CMOVE> abc --
3 -3 0 1	|CFILL abc --

3 -3 0 1	|DMOVE abc --
3 -3 0 1	|DMOVE> abc --
3 -3 0 1	|DFILL abc --
0 1 0 0		|MEM	-- a
1 0 0 0		|LOADLIB a -- a
2 -1 0 0	|GETPROC ab -- a
1 0 0 0		|SYS0 a -- a 
2 -1 0 0	|SYS1 ab -- a
3 -2 0 0	|SYS2 abc -- a
4 -3 0 0	|SYS3 abcd -- a
5 -4 0 0	|SYS4 abcde -- a
6 -5 0 0	|SYS5 abcdef -- a
7 -6 0 0	|SYS6 abcdefg -- a 
8 -7 0 0	|SYS7 abcdefgh -- a
9 -8 0 0	|SYS8 abcdefghi -- a
10 -9 0 0	|SYS9 abcdefghij -- a
11 -10 0 0	|SYS10 abcdefghijk -- a
)
	
::?base | adr -- nro+1/0
	0 'r3base			| adr 0 'r3base
	( dup c@ 1? drop
		pick2 over =s 1? ( 2drop nip 1+ ; ) drop
		>>0 swap 1+ swap ) 4drop
	0 ;

::basename | nro -- str
	'r3base swap
	( 1? 1 - swap >>0 swap ) drop ;
	
|---- dicc
| info1
| $..............01 - code/data
| $..............02 - loc/ext
| $..............04	1 es usado con direccion
| $..............08	1 r esta desbalanceada		| var cte
| $..............10	0 un ; 1 varios ;
| $..............20	1 si es recursiva
| $..............40	1 si tiene anonimas
| $..............80	1 termina sin ;
| $......ffffffff..	-> tok+/fmem+ -> code/mem
| $ffffff.......... -> src+ -> src
|
| info2
| $..............ff - Data use		255
| $............ff.. - Data delta	-128..127
| $.........fff.... - calls			1024+
| $........f....... - +info: inline,constant,exec,only stack
| $ffffffff........ - len

	
::dic>name | dic -- str
	40 >>> src + ;	
::dic>tok | dic -- tok
	8 >> $ffffffff and 3 << tok + ;
::dic>mem | dic -- mem
	8 >> $ffffffff and fmem + ;
	
::nro>dic | nro -- dic
	4 << dic + ;
	
::?word | adr -- adr nro+1/0
	dic> 16 -
	( dic >=?
		dup @ dic>name pick2			| str ind pal str
		=s 1? ( drop
			dup @ %10 and? ( drop dic - 4 >> 1 + ; ) drop | export
			dic< >=? ( dic - 4 >> 1 + ; ) dup | local
			) drop
		16 - ) drop
	0 ;
	
::makemem
	|-- make mem
	here 
	dup 'dic ! dup 'dic> ! dup 'dic< !		| dicctionary
	cntdef 4 << +				| dicc size
	dup 'tok ! dup 'tok> !		| tokens 
	cnttok 3 << +				| tok size
	dup 'strm ! dup 'strm> ! 	| strings
	cntstr +					| str size
	dup 'fmem ! dup 'fmem> ! 	| memory const+var+free
	'here !	;
