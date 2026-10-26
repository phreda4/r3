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
| $40 writes memory (! +! A! B! MOVE FILL ...)
|
| use deltad deltaR flag2
| the comment of each row is the help line of the word: | NAME effect ; description   (metahelp.r3 makes meta/mhelp.r3 from it)
#r3basemov (
0 1 0 0		| .lits 
0 1 0 0		| .lit
0 0 0 0		| .word
0 1 0 0		| .wadr		need calc UD
0 1 0 1		| .var
0 1 0 0		| .vadr
0 1 0 0		| .str		need "%d"!! | mem?

0 0 0 0	| ; -- ; end of the word, return to the caller
0 0 0 0	| ( -- ; begin a block: the body of a conditional or a loop
0 0 0 0	| ) -- ; end of the block
0 0 0 0	| [ -- a ; begin an anonymous word; ] leaves its address
0 1 0 0	| ] -- a ; end of the anonymous word, push its address
1 -1 0 0	| EX a -- ; execute the word whose address is a (0 does nothing)
1 0 0 0	| 0? a -- a ; run the block if a = 0
1 0 0 0	| 1? a -- a ; run the block if a <> 0
1 0 0 0	| +? a -- a ; run the block if a >= 0
1 0 0 0	| -? a -- a ; run the block if a < 0
2 -1 0 0	| <? a b -- a ; run the block if a < b
2 -1 0 0	| >? a b -- a ; run the block if a > b
2 -1 0 0	| =? a b -- a ; run the block if a = b
2 -1 0 0	| >=? a b -- a ; run the block if a >= b
2 -1 0 0	| <=? a b -- a ; run the block if a <= b
2 -1 0 0	| <>? a b -- a ; run the block if a <> b
2 -1 0 0	| AND? a b -- a ; run the block if a AND b <> 0
2 -1 0 0	| NAND? a b -- a ; run the block if a AND b = 0
3 -2 0 0	| IN? a b c -- a ; run the block if b <= a <= c
1  1 0 0	| DUP a -- a a ; duplicate TOS
1 -1 0 0	| DROP a -- ; remove TOS
2 1 0 0	| OVER a b -- a b a ; copy NOS to top
3 1 0 0	| PICK2 a b c -- a b c a ; copy 3rd element to top
4 1 0 0	| PICK3 a b c d -- a b c d a ; copy 4th element to top
5 1 0 0	| PICK4 a b c d e -- a b c d e a ; copy 5th element to top
2 0 0 0	| SWAP a b -- b a ; exchange TOS and NOS
2 -1 0 0	| NIP a b -- b ; remove NOS
3 0 0 0	| ROT a b c -- b c a ; rotate 3 elements left
3 0 0 0	| -ROT a b c -- c a b ; rotate 3 elements right
2 2 0 0	| 2DUP a b -- a b a b ; duplicate top two
2 -2 0 0	| 2DROP a b -- ; remove top two
3 -3 0 0	| 3DROP a b c -- ; remove top three
4 -4 0 0	| 4DROP a b c d -- ; remove top four
4 2 0 0	| 2OVER a b c d -- a b c d a b ; copy 3rd and 4th to top
4 0 0 0	| 2SWAP a b c d -- c d a b ; exchange two pairs
1 -1 1 0	| >R a -- (r: -- a) ; push to return stack
0 1 -1 0	| R> -- a (r: a --) ; pop from return stack
0 1 0 0	| R@ -- a (r: a -- a) ; copy top of return stack (non-destructive)
2 -1 0 0	| AND a b -- c ; c = a AND b (bitwise)
2 -1 0 0	| OR a b -- c ; c = a OR b
2 -1 0 0	| XOR a b -- c ; c = a XOR b
2 -1 0 0	| NAND a b -- c ; c = NOT (a AND b)
2 -1 0 0	| + a b -- c ; c = a + b
2 -1 0 0	| - a b -- c ; c = a - b
2 -1 0 0	| * a b -- c ; c = a * b
2 -1 0 0	| / a b -- c ; c = a / b (integer)
2 -1 0 0	| << a b -- c ; c = a << b (left shift)
2 -1 0 0	| >> a b -- c ; c = a >> b (signed right shift)
2 -1 0 0	| >>> a b -- c ; c = a >>> b (unsigned right shift)
2 -1 0 0	| MOD a b -- c ; c = a mod b
2 0 0 0	| /MOD a b -- c d ; c = a/b, d = a mod b
3 -2 0 0	| */ a b c -- d ; d = a*b/c (no intermediate overflow)
3 -2 0 0	| *>> a b c -- d ; d = (a*b)>>c (no overflow)
3 -2 0 0	| <</ a b c -- d ; d = (a<<c)/b (no overflow)
1 0 0 0	| NOT a -- b ; b = NOT a (all bits flipped)
1 0 0 0	| NEG a -- b ; b = -a
1 0 0 0	| ABS a -- b ; b = absolute value of a
1 0 0 0	| SQRT a -- b ; b = integer square root of a
1 0 0 0	| CLZ a -- b ; b = count leading zeros of a
1 0 0 1	| @ a -- [a] ; fetch qword
1 0 0 1	| C@ a -- byte[a] ; fetch byte
1 0 0 1	| W@ a -- word[a] ; fetch word
1 0 0 1	| D@ a -- dword[a] ; fetch dword
1 1 0 1	| @+ a -- b [a] ; fetch qword and increment
1 1 0 1	| C@+ a -- b byte[a] ; fetch byte and increment
1 1 0 1	| W@+ a -- b word[a] ; fetch word and increment
1 1 0 1	| D@+ a -- b dword[a] ; fetch dword and increment
2 -2 0 $41	| ! a b -- ; store A at address B
2 -2 0 $41	| C! a b -- ; store byte A at address B
2 -2 0 $41	| W! a b -- ; store word A at address B
2 -2 0 $41	| D! a b -- ; store dword A at address B
2 -1 0 $41	| !+ a b -- c ; store A at B and increment
2 -1 0 $41	| C!+ a b -- c ; store byte A at B and increment
2 -1 0 $41	| W!+ a b -- c ; store word A at B and increment
2 -1 0 $41	| D!+ a b -- c ; store dword A at B and increment
2 -2 0 $41	| +! a b -- ; add A to value at address B
2 -2 0 $41	| C+! a b -- ; add A to byte at address B
2 -2 0 $41	| W+! a b -- ; add A to word at address B
2 -2 0 $41	| D+! a b -- ; add A to dword at address B
1 -1 0 2	| >A a -- ; load register A
0 1 0 4	| A> -- a ; push register A
1 -1 0 4	| A+ a -- ; add to register A
0 1 0 5	| A@ -- a ; fetch qword from A
1 -1 0 $45	| A! a -- ; store qword at A
0 1 0 5	| A@+ -- a ; fetch qword from A and increment
1 -1 0 $45	| A!+ a -- ; store qword at A and increment
0 1 0 5	| CA@ -- a ; fetch byte from A
1 -1 0 $45	| CA! a -- ; store byte at A
0 1 0 5	| CA@+ -- a ; fetch byte from A and increment
1 -1 0 $45	| CA!+ a -- ; store byte at A and increment
0 1 0 5	| DA@ -- a ; fetch dword from A
1 -1 0 $45	| DA! a -- ; store dword at A
0 1 0 5	| DA@+ -- a ; fetch dword from A and increment
1 -1 0 $45	| DA!+ a -- ; store dword at A and increment
1 -1 0 8	| >B a -- ; load register B
0 1 0 $10	| B> -- a ; push register B
1 -1 0 $10	| B+ a -- ; add to register B
0 1 0 $11	| B@ -- a ; fetch qword from B
1 -1 0 $51	| B! a -- ; store qword at B
0 1 0 $11	| B@+ -- a ; fetch qword from B and increment
1 -1 0 $51	| B!+ a -- ; store qword at B and increment
0 1 0 $11	| CB@ -- a ; fetch byte from B
1 -1 0 $51	| CB! a -- ; store byte at B
0 1 0 $11	| CB@+ -- a ; fetch byte from B and increment
1 -1 0 $51	| CB!+ a -- ; store byte at B and increment
0 1 0 $11	| DB@ -- a ; fetch dword from B
1 -1 0 $51	| DB! a -- ; store dword at B
0 1 0 $11	| DB@+ -- a ; fetch dword from B and increment
1 -1 0 $51	| DB!+ a -- ; store dword at B and increment
0 0 2 0	| AB[ -- ; save A and B to return stack
0 0 -2 0	| ]BA -- ; restore B and A from return stack
3 -3 0 $41	| MOVE d s c -- ; copy c qwords from s to d
3 -3 0 $41	| MOVE> d s c -- ; copy c qwords, reverse direction
3 -3 0 $41	| FILL d v c -- ; fill d with c qwords of value v
3 -3 0 $41	| CMOVE d s c -- ; copy c bytes from s to d
3 -3 0 $41	| CMOVE> d s c -- ; copy c bytes, reverse direction
3 -3 0 $41	| CFILL d v c -- ; fill d with c bytes of value v
3 -3 0 $41	| DMOVE d s c -- ; copy c dwords from s to d
3 -3 0 $41	| DMOVE> d s c -- ; copy c dwords, reverse direction
3 -3 0 $41	| DFILL d v c -- ; fill d with c dwords of value v
0 1 0 1	| MEM -- a ; start of free memory
1 0 0 1	| LOADLIB "name" -- liba ; load dynamic library
2 -1 0 1	| GETPROC liba "name" -- aa ; get function address
1 0 0 1	| SYS0 aa -- r ; call with 0 parameters
2 -1 0 1	| SYS1 a aa -- r ; call with 1 parameter
3 -2 0 1	| SYS2 a b aa -- r ; call with 2 parameters
4 -3 0 1	| SYS3 a b c aa -- r ; call with 3 parameters
5 -4 0 1	| SYS4 a b c d aa -- r ; call with 4 parameters
6 -5 0 1	| SYS5 a b c d e aa -- r ; call with 5 parameters
7 -6 0 1	| SYS6 a b c d e f aa -- r ; call with 6 parameters
8 -7 0 1	| SYS7 a b c d e f g aa -- r ; call with 7 parameters
9 -8 0 1	| SYS8 a b c d e f g h aa -- r ; call with 8 parameters
10 -9 0 1	| SYS9 a b c d e f g h i aa -- r ; call with 9 parameters
11 -10 0 1	| SYS10 a b c d e f g h i j aa -- r ; call with 10 parameters
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
