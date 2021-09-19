| r3pass4.txt
| pass4 - static stack analisys
| PHREDA 2019
|---------------------------------
^./r3base.r3

#MAXINLINE 8

#nivel	0

#usoD	0
#deltaD	0	| pila de datos
#deltaD1fin | pila de datos en el 1er fin
#deltaR	0	| pila de retorno
##maxdepth

#flags	0
#cntfin
#pano		| anonima
#cano


| uso dD dR tipo
#deltainternos (
0 0 0 0		|0
0 0 0 0		|1 :  | --  define codigo
0 0 0 0		|2 :: | --  define codigo
0 0 0 0		|3 #  | --  define variable
0 0 0 0		|4 ## | --  define variable
0 0 0 0		|5 |  | -- comentario
0 0 0 0		|6 ^  | -- include
0 1 0 0		|7 1  | -- n 	numero decimal
0 1 0 0		|8 $  | -- n	numero hexa
0 1 0 0		|9 %  | -- n	numero binario
0 1 0 0		|A .  | -- n	numero punto fijo
0 1 0 9		|B "  | -- n	string
0 0 0 1		|C w  | x -- x  word <---- debe ser calculado
0 1 0 11	|D v  | -- n  var
0 1 0 11	|E 'w | -- n  dir word
0 1 0 11	|F 'v | -- n  dir var
			|------------------------- ) #deltamacros (
0 0 0 7		|; | fin de palabra (12)
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

1 0 0 0		|@      a -- b
1 0 0 0		|C@     a -- b
1 0 0 0		|W@     a -- b
1 0 0 0		|D@     a -- b

1 1 0 0		|@+     a -- bc
1 1 0 0		|C@+    a -- bc
1 1 0 0		|W@+    a -- bc
1 1 0 0		|D@+    a -- bc

2 -2 0 0	|!     ab --
2 -2 0 0	|C!    ab --
2 -2 0 0	|W!    ab --
2 -2 0 0	|D!    ab --

2 -1 0 0	|!+    ab -- c
2 -1 0 0	|C!+   ab -- c
2 -1 0 0	|W!+   ab -- c
2 -1 0 0	|D!+   ab -- c

2 -2 0 0	|+!    ab --
2 -2 0 0	|C+!   ab --
2 -2 0 0	|W+!   ab --
2 -2 0 0	|D+!   ab --

1 -1 0 0	|>A
0 1 0 0		|A>
1 -1 0 0	|A+

0 1 0 0		|A@
1 -1 0 0 	|A!
0 1 0 0		|A@+
1 -1 0 0	|A!+

0 1 0 0		|cA@
1 -1 0 0 	|cA!
0 1 0 0		|cA@+
1 -1 0 0	|cA!+

0 1 0 0		|dA@
1 -1 0 0 	|dA!
0 1 0 0		|dA@+
1 -1 0 0	|dA!+

1 -1 0 0	|>B
0 1 0 0		|B>
1 -1 0 0	|B+

0 1 0 0		|B@
1 -1 0 0 	|B!
0 1 0 0		|B@+
1 -1 0 0	|B!+

0 1 0 0		|cB@
1 -1 0 0 	|cB!
0 1 0 0		|cB@+
1 -1 0 0	|cB!+

0 1 0 0		|dB@
1 -1 0 0 	|dB!
0 1 0 0		|dB@+
1 -1 0 0	|dB!+

3 -3 0 0	|MOVE  abc --
3 -3 0 0	|MOVE> abc --
3 -3 0 0	|FILL abc --

3 -3 0 0	|CMOVE abc --
3 -3 0 0	|CMOVE> abc --
3 -3 0 0	|CFILL abc --

3 -3 0 0	|DMOVE abc --
3 -3 0 0	|DMOVE> abc --
3 -3 0 0	|DFILL abc --

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

|------------- recorre cada palabra
#pilaint * 1024
#pilaint> 'pilaint

:pushvar
	deltaD deltaR
	pilaint> w!+ w!+ 'pilaint> ! ;

:popvar
	pilaint> 4 - dup 'pilaint> !
	w@+ 'deltaR ! w@ 'deltaD ! ;

:dropvar
	-4 'pilaint> +! ;

|---- Anonimas
:es[
	pushvar
	1 'pano +! 1 'cano +! ;

:es]
	popvar
    -1 'pano +!
	1 'deltad +! ; | deja direccion en pila

:es(
	pushvar ;
:es)
	popvar ;

:es??
	dup 4 - d@
	8 >> 3 << blok + d@
	$10000000 nand? ( drop ; ) drop
	dropvar
	pushvar
	;
|----------------------
:esFin
	pano 1? ( drop ; ) drop
	cntfin 0? ( deltaD 'deltaD1fin ! ) drop
	1 'cntfin +! ;

|--------------------
:usoDcalc | u --
	deltaD swap -
	usoD min 'usoD ! ;

| adr adrt t tabla
:esPal | palabra
	dup 4 - d@ 8 >>>	| obtener palabra
	pick3 =? ( drop flags $20 or 'flags ! ; ) | es recursiva?
    dup dic>inf @

	$100 and? ( flags $400 or 'flags ! )

	24 >> 1 + 'nivel !

	dic>mov @
	dup $f and neg usoDcalc
	55 << 59 >> 'deltaD +!
	;

:esStr | calcula deltaD de string
	dup 4 - d@ 8 >>> src + | string
	strusestack neg 'deltaD +! ;

#lastdircode

:esExe | calcular deltaD de palabra llamada
	lastdircode	| averiguar palabra en pila !!!

	dup dic>inf @ 24 >> 1 + 'nivel !

	dic>mov @
	dup $f and neg usoDcalc
	55 << 59 >> 'deltaD +!
	;

:esWordV | guarda ultima referencia para exec,
	dup 4 - d@ 8 >> 'lastdircode ! ;

:V0 ;

#acct v0 esPal es( es?? es) es[ es] esFin v0 esStr esExe esWordV

:prosstoken | t --
	2 << 'deltainternos +
	c@+ usoDcalc
	c@+ 'deltaD +!
	deltaD maxdepth max 'maxdepth !
	c@+ 'deltaR +!
	c@ 3 << 'acct + @ ex
	;

::getuso | nro -- uso delta
	2 << 'deltainternos +
	c@+
	swap c@ ;

|-----------------------------
:resetvars | --
	0 dup 'usoD ! dup 'deltaD ! dup 'deltaR !
	dup 'nivel ! dup 'flags ! dup 'cntfin !
	dup 'pano ! 'cano !
	'pilaint 'pilaint> !
	0 'maxdepth !
	;

|	dup 1 >> $1 and "le" + c@ ,c	| export/local
|	dup 2 >> $1 and " '" + c@ ,c	| /adress used
|	dup 3 >> $1 and " r" + c@ ,c	| /rstack mod
|	dup 4 >> $1 and " ;" + c@ ,c	| /multi;
|	dup 5 >> $1 and " R" + c@ ,c	| /recurse
|	dup 6 >> $1 and " [" + c@ ,c	| /anon
|	dup 7 >> $1 and " ." + c@ ,c	| /no ;
|	dup 8 >> $1 and " i" + c@ ,c	| /inline

:inlinemark | word inf flags -- word inf flags
	%1111100 and? ( ; )
	pick2 dic>len@ MAXINLINE >? ( drop ; ) drop
	$100 or ;

:setvars | nro -- nro
	cntfin 1 >? ( $10 flags or 'flags ! ) drop	| +1;
	cano 1? ( $40 flags or 'flags ! ) drop 		| anon
	deltaR 1? ( $8 flags or 'flags ! ) drop

	nivel 24 << flags $fff and or
	over dic>inf dup @ rot or
	inlinemark
	swap !

	deltaD1fin
	cntfin 0? ( nip deltaD swap ) drop
	$1f and 4 << usoD neg $f and or
	over dic>mov dup @ rot or swap !
	;

|----------------------------
|----- analiza codigo
|----------------------------
:analisiscode | nro -- nro
	resetvars
	dup dic>toklen
	( 1? 1 - swap
		d@+ $ff and
		prosstoken
		swap ) 2drop
	setvars
	;

|----------------------------
|----- analiza variable
|----------------------------
#cntdv     | dir vars
#cntdc     | dir codigo
#cnts      | string
#cntn0     | no ceros (0 puede ser direccion)
#deltaS

:copydeltaS | ar v -- ar v
	over 4 - d@ 8 >> dic>mov @ $1ff and 'deltaS ! ;

:sumavars | adr c -- adr
	$6 >? ( $b <? ( 1 'cntn0 +! ) )  	| NRO
	$b =? ( 1 'cnts +! )				| string
	$c =? ( 1 'cntdc +! copydeltaS )
	$e =? ( 1 'cntdc +! copydeltaS )	| word y dir word
	$d =? ( 1 'cntdv +! )
	$f =? ( 1 'cntdv +! )				| var y dir var
	$3c =? (  1 'flags ! )				| *
	drop ;

|--- info de variables
| valor               0
| direccion           1
| direccion codigo    2
| string              3
| lista valores       4
| lista direcciones   5
| lista dir codigos   6
| lista strings       7
| estructura multiple 8
| buffer			  9
|--------------------
:decodeinfov | len -- len iv
	flags 1? ( drop 9 ; ) drop
	cntdv cntdc or cnts or
	0? ( drop 3 <? ( 0 ; ) 4 ; ) drop | todos numeros
	cntdv cntdc or
	0? ( drop 3 <? ( 3 ; ) 7 ; ) drop | hay string, no dv ni dc
	cntdv
	0? ( drop 3 <? ( 2 ; ) 6 ; ) drop | direccion de codigo
	3 <? ( 1 ; )
	5 ;                 | direccion de dato

:resetvars
	0 'deltaS !
	0 'cntdv ! 0 'cntdc !
	0 'cnts ! 0 'cntn0 !
	0 'flags !
	;

:setvars | nro -- nro
	dup dic>len@ decodeinfov nip
	24 << over dic>inf dup @ rot or
|	$f000004 nand? ( $8 or )	| solo nros??
	$4 nand? ( $8 or )
	swap !

	deltaS over dic>mov dup @ rot or swap !	| stack mov of vectors in var
	;

:analisisvar |  nro -- nro
	resetvars
	dup dic>toklen
	( 1? 1 - swap
		@+ $ff and sumavars
		swap ) 2drop
	setvars ;

|--------------------
:everyword | n -- n
	dup dic>call@ 0? ( drop ; ) drop

|	dup dic>adr @ "::%w" .println

	dup dic>inf @ 1 and? ( drop analisisvar ; ) drop
	analisiscode
	;

::r3-stage-4
	0 ( cntdef <?
		everyword
		1 + ) drop ;
