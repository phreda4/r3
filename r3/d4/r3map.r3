| r3 map memory
| PHREDA 2024
^r3/lib/parse.r3
^r3/lib/str.r3

##filename * 1024
##r3path * 1024

|--------------------- token format
| ..............ff token nro
| ffffff.......... adr to src
| ......ffffffff.. value

|--------------------- MEMORY MAP
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
| 'name| 'firstdic(32<<)  'memsrc(+src)(32)
##inc * $fff
##inc> 'inc

##boot>>

##cntdef
##cnttok
##cntstr
##cntinc

##error
##lerror

::error! | adr "" --
	'error ! 'lerror ! ;

|  0     1    2     3     4    5     6
| .lits .lit .word .wadr .var .vadr .str ...
#r3base
";" "(" ")" "[" "]" "EX" "0?" "1?" "+?" "-?"
"<?" ">?" "=?" ">=?" "<=?" "<>?" "AND?" "NAND?" "IN?"
"DUP" "DROP" "OVER" "PICK2" "PICK3" "PICK4" "SWAP" "NIP" | 26..
"ROT" "-ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP" |34..
">R" "R>" "R@" "AND" "OR" "XOR" "NAND" "+" "-" "*" "/" "<<" ">>" ">>>" |41..
"MOD" "/MOD" "*/" "*>>" "<</" "NOT" "NEG" "ABS" "SQRT" "CLZ" |54..
"@" "C@" "W@" "D@" "@+" "C@+" "W@+" "D@+"
"!" "C!" "W!" "D!" "!+" "C!+" "W!+" "D!+" 
"+!" "C+!" "W+!" "D+!" 
">A" "A>" "A+" "A@" "A!" "A@+" "A!+" "CA@" "CA!" "CA@+" "CA!+" "DA@" "DA!" "DA@+" "DA!+"
">B" "B>" "B+" "B@" "B!" "B@+" "B!+" "CB@" "CB!" "CB@+" "CB!+" "DB@" "DB!" "DB@+" "DB!+" 
"AB[" "]BA"
"MOVE" "MOVE>" "FILL" "CMOVE" "CMOVE>" "CFILL" "DMOVE" "DMOVE>" "DFILL" 
"MEM" "LOADLIB" "GETPROC"
"SYS0" "SYS1" "SYS2" "SYS3" "SYS4" "SYS5" "SYS6" "SYS7" "SYS8" "SYS9" "SYS10" ( 0 )

	
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
| $............ff..	flag2
| $......ffffff....	-> tok+ -> code
| $ffffff.......... -> src+ -> src
|
| info2
| $..............ff - Data use		255
| $............ff.. - Data delta	-128..127
| $........ffff.... - calls			1024+
| $ffffffff........ - len in code/fmem+ in data (var place)

::dic>name | dic -- str
	40 >>> src + ;	
	
::dic>tok | dic -- tok
	16 >> $ffffff and 3 << tok + ;
	
::nro>dic | nro -- dic
	4 << dic + ;

::tok>dic | tok -- dic
	8 >> $ffffffff and 4 << dic + ;
	
::toklen | dic -- tok len
	dup @ 16 >> $ffffff and 3 << tok +
	swap 8 + @ 32 >>> ;

::toklend | dic -- tok len ; len for data
	dup @ 16 >> $ffffff and 		| dic itok
	dup 3 << tok + swap 			| dic tok itok
	rot 16 + @ 16 >> $ffffff and 
	swap -
	;
	
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
	
:align16 | mem -- mem ; align to 16
	$10 over $f and - $f and + ; 
	
::makemem
	|-- make mem
	here 
	align16
	dup 'dic ! dup 'dic> ! dup 'dic< !		| dicctionary
	cntdef 4 << +				| dicc size
	dup 'tok ! dup 'tok> !		| tokens 
	cnttok 3 << +				| tok size
	dup 'strm ! dup 'strm> ! 	| strings
	cntstr +					| str size
	align16
	dup 'fmem ! dup 'fmem> ! 	| memory const+var+free
	'here !	;

|-------------------------
:,dh | digit --
	$f and $30 + $39 >? ( 7 + ) ,c ;
	
:,bh | byte --
	dup 4 >> ,dh ,dh ;
	
:,mem | memend memini --
	( over <? 
		dup "%h:" ,print
		dup 32 ( 1? 1 - swap c@+ ,bh swap ) 2drop ": " ,s
		32 ( 1? 1 - swap c@+ 32 <? ( $2e nip ) ,c swap ) drop ,cr
		32 + ) 2drop ;

::debugmemmap
	"----dic " ,s dic> dic - "(%d)" ,print
	,cr
	dic> dic ,mem ,cr
	"----tok " ,s cnttok 3 << tok> tok - "(%d %d)" ,print
	,cr
	tok> tok ,mem ,cr
	"----str " ,s cntstr strm> strm - "(%d %d)" ,print
	,cr
	strm> strm ,mem ,cr
	"----var " ,s fmem> fmem - "(%d)" ,print
	,cr
	fmem> fmem ,mem ,cr
	;
	
| FLAG2
| $01 mem access
| $02 >A
| $04 A
| $08 >B
| $10 B
|
| use deltad deltaR flag2
#r3basemov (
0 1 0 0		| .lits 
0 1 0 0		| .lit
0 0 0 0		| .word
0 1 0 0		| .wadr		need calc UD
0 1 0 1		| .var
0 1 0 0		| .vadr
0 1 0 0		| .str		need "%d"!! | mem?

0 0 0 0		| ; | fin de palabra (12)
0 0 0 0		| (
0 0 0 0		| )
0 0 0 0		| [
0 1 0 0		| ]
1 -1 0 0	| EX	x/0 --
1 0 0 0		|0?		a -- a
1 0 0 0		|1?		a -- a
1 0 0 0		|+?		a -- a
1 0 0 0		|-?		a -- a
2 -1 0 0	|<?		ab -- a
2 -1 0 0	|>?		ab -- a
2 -1 0 0	|=?		ab -- a
2 -1 0 0	|>=?	ab -- a
2 -1 0 0	|<=?	ab -- a
2 -1 0 0	|<>?	ab -- a
2 -1 0 0	|and?	ab -- a
2 -1 0 0	|nand?	ab -- a
3 -2 0 0	|BTW?	abc -- a
1  1 0 0	|DUP	a -- aa
1 -1 0 0	|DROP	a --
2 1 0 0		|OVER	ab -- aba
3 1 0 0		|PICK2	abc -- abca
4 1 0 0		|PICK3	abcd -- abcda
5 1 0 0		|PICK4	abcde -- abcdea
2 0 0 0		|SWAP	ab -- ba
2 -1 0 0	|NIP	ab -- b
3 0 0 0		|ROT	abc -- bca
3 0 0 0		|-ROT	abc -- cab
2 2 0 0		|2DUP	ab -- abab
2 -2 0 0	|2DROP	ab --
3 -3 0 0	|3DROP	abc --
4 -4 0 0	|4DROP	abcd --
4 2 0 0		|2OVER	abcd -- abcdab
4 0 0 0		|2SWAP	abcd -- cdab
1 -1 1 0	|>R		a -- R: -- a
0 1 -1 0	|R>		-- a R: a --
0 1 0 0		|R@		-- a R: a -- a
2 -1 0 0	|AND	ab -- c
2 -1 0 0	|OR		ab -- c
2 -1 0 0	|XOR	ab -- c
2 -1 0 0	|NAND	ab -- c
2 -1 0 0	|+		ab -- c
2 -1 0 0	|-		ab -- c
2 -1 0 0	|*		ab -- c
2 -1 0 0	|/		ab -- c
2 -1 0 0	|<<		ab -- c
2 -1 0 0	|>>		ab -- c
2 -1 0 0	|>>>	ab -- c
2 -1 0 0	|MOD	ab -- c
2 0 0 0		|/MOD	ab -- cd
3 -2 0 0	|*/		abc -- d
3 -2 0 0	|*>>	abc -- d
3 -2 0 0	|<</	abc -- d
1 0 0 0		|NOT	a -- b
1 0 0 0		|NEG	a -- b
1 0 0 0		|ABS	a -- b
1 0 0 0		|SQRT	a -- b
1 0 0 0		|CLZ	a -- b
1 0 0 1		|@		a -- b
1 0 0 1		|C@		a -- b
1 0 0 1		|W@		a -- b
1 0 0 1		|D@		a -- b
1 1 0 1		|@+		a -- bc
1 1 0 1		|C@+	a -- bc
1 1 0 1		|W@+	a -- bc
1 1 0 1		|D@+	a -- bc
2 -2 0 1	|!		ab --
2 -2 0 1	|C!		ab --
2 -2 0 1	|W!		ab --
2 -2 0 1	|D!		ab --
2 -1 0 1	|!+		ab -- c
2 -1 0 1	|C!+	ab -- c
2 -1 0 1	|W!+	ab -- c
2 -1 0 1	|D!+	ab -- c
2 -2 0 1	|+!		ab --
2 -2 0 1	|C+!	ab --
2 -2 0 1	|W+!	ab --
2 -2 0 1	|D+!	ab --
1 -1 0 2	|>A
0 1 0 4		|A>
1 -1 0 4	|A+
0 1 0 5		|A@
1 -1 0 5 	|A!
0 1 0 5		|A@+
1 -1 0 5	|A!+
0 1 0 5		|cA@
1 -1 0 5 	|cA!
0 1 0 5		|cA@+
1 -1 0 5	|cA!+
0 1 0 5		|dA@
1 -1 0 5 	|dA!
0 1 0 5		|dA@+
1 -1 0 5	|dA!+
1 -1 0 8	|>B
0 1 0 $10	|B>
1 -1 0 $10	|B+
0 1 0 $11	|B@
1 -1 0 $11 	|B!
0 1 0 $11	|B@+
1 -1 0 $11	|B!+
0 1 0 $11	|cB@
1 -1 0 $11	|cB!
0 1 0 $11	|cB@+
1 -1 0 $11	|cB!+
0 1 0 $11	|dB@
1 -1 0 $11	|dB!
0 1 0 $11	|dB@+
1 -1 0 $11	|dB!+
0 0 2 0		|AB[		R: -- AB
0 0 -2 0	|]BA		R: BA --
3 -3 0 1	|MOVE  abc --
3 -3 0 1	|MOVE> abc --
3 -3 0 1	|FILL abc --
3 -3 0 1	|CMOVE abc --
3 -3 0 1	|CMOVE> abc --
3 -3 0 1	|CFILL abc --
3 -3 0 1	|DMOVE abc --
3 -3 0 1	|DMOVE> abc --
3 -3 0 1	|DFILL abc --
0 1 0 1		|MEM	-- a
1 0 0 1		|LOADLIB a -- a
2 -1 0 1	|GETPROC ab -- a
1 0 0 1		|SYS0 a -- a 
2 -1 0 1	|SYS1 ab -- a
3 -2 0 1	|SYS2 abc -- a
4 -3 0 1	|SYS3 abcd -- a
5 -4 0 1	|SYS4 abcde -- a
6 -5 0 1	|SYS5 abcdef -- a
7 -6 0 1	|SYS6 abcdefg -- a 
8 -7 0 1	|SYS7 abcdefgh -- a
9 -8 0 1	|SYS8 abcdefghi -- a
10 -9 0 1	|SYS9 abcdefghij -- a
11 -10 0 1	|SYS10 abcdefghijk -- a
)

::r3ainfo | n -- a
	2 << 'r3basemov + ;

|--- dibuja movimiento pilas
| mov
| $ff - movs delta -128..127 uso:0..255

:,ncar | n car -- car
	( swap 1? 1 - swap dup ,c 1 + ) drop ;

::,mov | mov --
	97 >r	| 'a'
	dup $ff and
	dup r> ,ncar >r
	" -- " ,s
	swap 48 << 56 >> + | deltaD
	-? ( ,d r> drop " ]" ,s ; ) | error en analisis!!
	r> ,ncar drop
	;
::,movd
	dup $ff and "%d " ,print
	48 << 56 >>  | deltaD
	"%d " ,print ;
