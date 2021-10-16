| TEST r3stack.r3
| PHREDA 2021

^r3/win/console.r3
^r3/system/r3stack.r3

:.stack
	mark ,printvstk ,eol empty here .println ;

#.bye 0

|-----------------
:ibye 1 '.bye ! "bye!" .write cr ;

:iini 
	8 stk.start
	;
	
:inormal 
	mark
	stk.normal 
	,eol empty
	here .println
	;

#inst 
"DUP" "DROP" "OVER" "PICK2" "PICK3" "PICK4" "SWAP" "NIP"
"ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP"
"AND" "OR" "XOR" 
"+" "-" "*" "/"
"<<" ">>" ">>>"
"MOD" "/MOD" "*/" "*>>" "<</"
"NOT" "NEG" "ABS" "SQRT" "CLZ"
"bye" "istack" "inormal" 0

#insc 
.dup .drop .over .pick2 .pick3 .pick4 .swap .nip
.rot .2dup .2drop .3drop .4drop .2over .2swap 
.and .or .xor
.+ .- .* ./
.<< .>> .>>>
.mod ./mod .*/ .*>> .<</
.not .neg .abs .sqrt .clz
'ibye 'iini 'inormal 0

:interp | adr -- ex/0
	'insc >a
	'inst ( dup c@ 1? drop
		2dup =w 1? ( 3drop a> ; ) drop
		>>0 8 a+ ) nip nip ;
	
:interprete | adr --
	trim dup c@ 0? ( drop ; ) drop
	dup isNro 1? ( drop dup str>anro PUSH.NRO >>sp interprete ; ) drop
	dup interp 0? ( drop " %w ???" .println ; )
	@ ex 
	>>sp interprete ;
	
:main
	.cls
	"r3 test vstack - PHREDA 2021" .write cr
	cr
	( .bye 0? drop
		"> " .write .input cr
		'pad interprete
		.stack
		) drop ;
		
: main ;