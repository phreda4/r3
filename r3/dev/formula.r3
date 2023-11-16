| infix to postfix notation
| PHREDA 2023
^r3/win/console.r3
^r3/lib/parse.r3

#ops "+" "-" "*" "/" 0
#opv ( 1 1 2 2 )

:
:.nro
	"NN " .print
	>>sp 	
	;
	
:wrd2token | str -- str'
	( dup c@ $ff and 33 <?
		0? ( nip ; ) drop 1 + )	| trim0
	over "%w " .print |** debug
	$5e =? ( drop >>cr ; )	| $5e ^  In
	drop
	dup isNro 1? ( drop .nro ; ) drop		| numero
|	dup ?base 0 >=? ( .base ; ) drop		| macro
|	?word 1? ( .word ; ) drop		| palabra
|	drop 0

	>>sp
	;
	
::str2token | str --
	( wrd2token 1? ) drop ;
	
:infix2postfix
	str2token
	;

#demo "a + b * ( c * d - e ) / ( f + g * h ) - i"

:
.cls
'demo .println
"--->" .println
'demo infix2postfix
.input
;
