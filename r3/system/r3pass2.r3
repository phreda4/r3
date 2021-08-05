| r3 compiler
| pass 2 - tokenizer
| PHREDA 2018
|----------------
^r3/lib/parse.r3

^./r3base.r3

#flag

::,, | n --
	code> !+ 'code> ! ;

:.com
|WIN|	"|WIN|" =pre 1? ( drop 5 + ; ) drop | Compila para WINDOWS
|LIN|	"|LIN|" =pre 1? ( drop 5 + ; ) drop | Compila para LINUX
	>>cr
	;

#codeini

|-----
#sst * 1024 	| stack of blocks
#sst> 'sst
:sst!	sst> !+ 'sst> ! ;
:sst@   -4 'sst> +! sst> @ ;
:nivel 	sst> 'sst xor ;

:callen
	code> codeini - 2 >> | code_length
	$fffff and 12 <<
	dicc> 4 - ! | info in wordnow
	code> 4 - @ $10 <>? ( drop ; ) drop
	$80 dicc> 8 - +!
	;

:inidef
	nivel 1? ( drop
		'lerror !
		"missing )" 'error !
		0 ; ) drop
	codeini 1? ( callen ) drop
	code> 'codeini !
	;

:.def
	inidef 0? ( ; )
	0 'flag !
	1 + dup c@
	33 <? ( code> '<<boot ! )
	$3A =? ( swap 1 + swap 2 'flag ! ) |::
	drop
	0 flag code> pick3 word!+
    >>sp ;

:.var
	inidef 0? ( ; )
	1 'flag !
	1 + dup c@
	$23 =? ( swap 1 + swap 3 'flag ! ) | ##
	drop
	0 flag code> pick3 word!+
    >>sp ;

:.str
	1 + dup src - 8 <<
	11 or ,,
	>>" ;

:.nro
	dup src - 8 << 7 or ,,	| all de src numbers are token 'dec'
	>>sp ;

|---------------------------------
#iswhile

:blockIn
	1 'nbloques +!
	code> code - 2 >>
	nbloques dup sst!
	3 << blok + !
	nbloques 8 << +  | #block in (
	;

:cond | bl from to adr+ -- bl from to adr
	dup $ff and
	$16 <? ( 2drop ; )
	$22 >? ( 2drop ; )
	swap 8 >> 1? ( 2drop ; ) drop
	pick4 8 << or over 4 - ! | ?? set block
	1 'iswhile !
	;

:blockOut | tok -- tok
	0 'iswhile !
	sst@ dup dup
	3 << blok + @
	2 << code +		| 2code
	code> | bl from to
	dup code - 2 >> pick3 3 << blok + 4 + !
	over ( over <? @+ cond ) 2drop | bl from
	swap         | tok from bl
	iswhile 0? ( drop
				8 << swap 4 - +! | ?? set block
				8 << + ; ) drop nip
	3 << blok +
	$10000000 swap +!	| marca while
	8 << +				| #block in )
	;

:anonIn
	1 'nbloques +!
	code> code - 2 >>
	nbloques dup sst!
	3 << blok + !
	nbloques 8 << +  | #block in [
	;
:anonOut
	sst@ dup dup
	3 << blok + @
	2 << code +		| 2code
	code> | bl from to
	dup code - 2 >> pick3 3 << blok + 4 + !
	3drop
	8 << +				| #block in ]
	;

:blocks
	flag 1 and? ( drop ; ) drop
	1 =? ( blockIn ; )	| (
	2 =? ( blockOut ; )	| )
	3 =? ( anonIn ; )	| [
	4 =? ( anonOut ; )	| ]
	;

:.base | nro --
	blocks
	16 + ,,
	>>sp ;

:.word | adrwor --
	dup 8 + @ 1 and 12 + | 12 call 13 var
	swap adr>dic 8 << or ,,
	>>sp ;

:.adr | adrwor --
	dup 8 + @ 1 and 14 + | 14 dcode 15 ddata
	swap adr>dic 8 << or ,,
	>>sp ;

:wrd2token | str -- str'
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1 + )	| trim0
|	over "%w" slog | debug
	$5e =? ( drop >>cr ; )	| $5e ^  Include
	$7c =? ( drop .com ; )	| $7c |	 Comentario
	$3A =? ( drop .def ; )	| $3a :  Definicion
	$23 =? ( drop .var ; )	| $23 #  Variable
	$22 =? ( drop .str ; )	| $22 "	 Cadena
	$27 =? ( drop 			| $27 ' Direccion
		dup ?base 0 >=? ( .base ; ) drop
		1 + ?word 1? ( .adr ; ) drop
		"Addr not exist" 'error !
		dup 1 - 'lerror !
		drop 0 ; )
	drop
	dup isNro 1? ( drop .nro ; ) drop		| numero
	dup ?base 0 >=? ( .base ; ) drop		| macro
	?word 1? ( .word ; ) drop		| palabra
 	"Word not found" 'error !
	dup 'lerror !
	drop 0 ;

::str2token | str --
	'sst sst> !		| reuse stackblock
	( wrd2token 1? ) drop
	;

:contword | dicc -- dicc
	dup 8 + @
	$81 and? ( drop ; ) | code sin ;
	drop
	dup 28 + @ $fffff000 and
	over 12 + +!
	;

::r3-stage-2 | -- err/0
	cntdef allocdic
	here dup 'code ! 'code> !
	cnttokens 2 << 'here +!
	here 'blok !
	cntblk 3 << 'here +!
	0 'nbloques !
	0 'codeini !
	'inc ( inc> <?
|		dup @ "%w" slog
		4 + @+
		str2token
		error 1? ( nip ; ) drop
		inc> <? ( dicc> 'dicc< ! ) | main source code mark
		) drop
	callen
	| real length
	dicc> 16 -
	( dicc >? 16 - contword ) drop
	0 ;