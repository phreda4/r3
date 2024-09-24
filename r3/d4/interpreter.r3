| TEST r3stack.r3
| PHREDA 2021

^r3/lib/console.r3
^r3/system/r3stack.r3
^r3/system/r3base.r3
^r3/system/r3pass1.r3
^r3/system/r3pass2.r3
^r3/system/r3pass4.r3
^r3/d4/meta/metalibs.r3

::r3debuginfo | str --
	r3name
	here dup 'src !
	'r3filename load
	here =? ( drop "no source code." .println  ; )
	0 swap c! 
	src only13 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	src
	r3-stage-1 error 1? ( 2drop ; ) drop	
	r3-stage-2 1? ( 2drop ; ) drop 		
	r3-stage-4-full
	drop	
	;
	
:.stack
	mark ,printvstk ,eol empty here .write ;

#.bye 0

|-----------------
:ibye 1 '.bye ! "bye!" .write .cr ;

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
"ROT" "-ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP"
"AND" "OR" "XOR" "NAND"
"+" "-" "*" "/"
"<<" ">>" ">>>"
"MOD" "/MOD" "*/" "*>>" "<</"
"NOT" "NEG" "ABS" "SQRT" "CLZ"
"bye" "istack" "inormal" 0

#insc 
.dup .drop .over .pick2 .pick3 .pick4 .swap .nip
.rot .-rot .2dup .2drop .3drop .4drop .2over .2swap 
.and .or .xor .nand
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
	
|---------------------------------	
| input line
#padh * 8192
#padh> 'padh
|#pad * 256

#cmax 1000
#padi>	| inicio
#padf>	| fin
#pad>	| cursor

:lins  | c -- ;
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1 - padf> over - 1 + cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> >? (
		dup padi> - cmax >=? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
:0lin 0 padf> c! ;

:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> padi> <=? ( drop ; ) dup 1 - swap padf> over - 1 + cmove -1 'padf> +! -1 'pad> +! ;

:kder pad> padf> <? ( 1 + ) 'pad> ! ;
:kizq pad> padi> >? ( 1 - ) 'pad> ! ;

:kup
	pad> ( padi> >?
		1 - dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1 - 'pad> ! ;

#modo 'lins

:keye
	$53 =? ( kdel )
|	$48 =? ( karriba ) 
|	$50 =? ( kabajo )
	$4d =? ( kder ) $4b =? ( kizq )
	$47 =? ( padi> 'pad> ! ) 
	$4f =? ( padf> 'pad> ! )
|	$49 =? ( kpgup ) 
|	$51 =? ( kpgdn )
	
	$52 =? (  modo | ins
			'lins =? ( drop 'lover 'modo ! .ovec ; )
			drop 'lins 'modo ! .insc )
|	$1d =? ( controlon ) 
	
|	$2a =? ( 1 'mshift ! ) $102a =? ( 0 'mshift ! ) | shift der
|	$36 =? ( 1 'mshift ! ) $1036 =? ( 0 'mshift ! ) | shift izq 

|	$3b =? ( runfile ) | F1
|	$3c =? ( debugfile ) | F2
|	$3d =? ( profiler ) | F3
|	$3e =? ( mkplain ) | F4
|	$3f =? ( compile ) | F5
	drop ;
	
:.char
	$1000 and? ( drop ; ) | upkey
	$ff0000 nand? ( keye ; ) 
	16 >> $ff and 
	8 =? ( drop kback ; )
	9 =? ( modo ex ; )
	
	27 =? ( 1 '.bye ! ; )
	
|	13 =? ( clearinfo modo ex ; )
	32 <? ( drop ; )
	modo ex 		
	;
	
:.pline
	padi> pad> over - type
	"s" .[ | save cursor position
	pad> padf> over - type
	.eline
	"u" .[ | restore cursor	
	;

#xc #yc
::.inputline
	getcursorpos 'yc ! 'xc !
	.eline
	'pad dup 'padi> ! dup 'padf> ! dup 'pad> !	
	0 swap c!
	'lins 'modo !
	( getch $D001C <>? .char 
		.hidec xc yc .at .pline .showc
		) drop ;

|---------------------------------	
:main
	.getconsoleinfo 
	.cls
	"r3d4 - r3 interactive" .write .cr
	.cr
	
	( .bye 0? drop
		2 20 .at
		.stack " > " .write 
		.inputline
		.cr .cr
		.eline
		'pad interprete		
		.cr
		) drop ;
		
: main ;