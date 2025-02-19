| rcode vm
| PHREDA 2024
|-----------------
^r3/lib/mem.r3
^r3/lib/parse.r3
^r3/lib/console.r3

##terror | tipo error	
##serror | src error pos

##syswordd	| data stack
##sysworde	| vectors
##syswords	| strings

| code>(32) str(16) var/word(8) 
#dicc * 1024 | 128 entradas
#dicc>
#lastdic>

#src

#code:	| code ini
#code>	| code now

#state	| imm/compiling
#tlevel	| tokenizer level

|--------- VM
#IP 			
##TOS ##NOS ##RTOS 
#REGA #REGB
##STACK ##CODE ##DATA

| 'code
| stack (256) |##STACK * 256 | 32 cells 2 stack
| tokens
| 'code>

:iDUP		8 'NOS +! TOS NOS ! ;
:iOVER		iDUP NOS 8 - @ 'TOS ! ;
:iPICK2		iDUP NOS 16 - @ 'TOS ! ;
:iPICK3		iDUP NOS 24 - @ 'TOS ! ;
:iPICK4		iDUP NOS 32 - @ 'TOS ! ;
:i2DUP		iOVER iOVER ;
:i2OVER		iPICK3 iPICK3 ;
:iDROP		NOS @ 'TOS !	|iii
:iNIP		-8 'NOS +! ;
:i2NIP      -16 'NOS +! ;
:i2DROP		NOS 8 - @ 'TOS ! -16 'NOS +! ;
:i3DROP		NOS 16 - @ 'TOS ! -24 'NOS +! ;
:i4DROP		NOS 24 - @ 'TOS ! -32 'NOS +! ;
:i6DROP		NOS 40 - @ 'TOS ! -48 'NOS +! ;
:iSWAP		NOS @ TOS NOS ! 'TOS ! ;
:iROT		TOS NOS 8 - @ 'TOS ! NOS @ NOS 8 - !+ ! ;
:i2SWAP		TOS NOS @ NOS 8 - dup 8 - @ NOS ! @ 'TOS ! NOS 16 - !+ ! ;

:pushinro	iDUP 'TOS ! ;
:atoken		dup 8 - @ ;

:jmpr		atoken 32 >> + ;

:i;		drop RTOS @ 8 'RTOS +! ;
:i(		;
:i)		:i[		
	jmpr ;
:i]		8 'NOS +! TOS NOS ! w@+ + 'TOS ! ;
:iEX	-8 'RTOS +! RTOS ! TOS code + 8 'NOS +! NOS @ 'TOS ! ;

:NOSTOS	NOS @ 32 >> TOS 32 >> ;
:2NOTOS	NOS 8 - @ 32 >> NOS @ 32 >> TOS 32 >> ;
:TOS!	32 << TOS $ffffffff AND or 'TOS ! ;

|--- COND
:i0?	TOS 32 >> 1? ( drop jmpr ; ) drop ;
:i1?	TOS 32 >> 0? ( drop jmpr ; ) drop ;
:i+?	TOS 32 >> -? ( drop jmpr ; ) drop ;
:i-?	TOS 32 >> +? ( drop jmpr ; ) drop ;
:i=?	NOSTOS <>? ( drop jmpr iDROP ; ) drop iDROP ;
:i<?	NOSTOS >=? ( drop jmpr iDROP ; ) drop iDROP ;
:i>?	NOSTOS <=? ( drop jmpr iDROP ; ) drop iDROP ;
:i<=?	NOSTOS >? ( drop jmpr iDROP ; ) drop iDROP ;
:i>=?	NOSTOS <? ( drop jmpr iDROP ; ) drop iDROP ;
:i<>?	NOSTOS =? ( drop jmpr iDROP ; ) drop iDROP ;
:iAND?	NOSTOS nand? ( drop jmpr iDROP ; ) drop iDROP ;
:iNAND?	NOSTOS and? ( drop jmpr iDROP ; ) drop iDROP ;
:iIN?	2NOTOS in? ( drop jmpr idrop ; ) drop idrop ;

:iAND	NOSTOS and iNIP TOS! ;
:iOR	NOSTOS or iNIP TOS! ;
:iXOR	NOSTOS xor iNIP TOS! ;
:iNOT	TOS 32 >> not TOS! ;
:i+		NOSTOS + iNIP TOS! ;
:i-		NOSTOS - iNIP TOS! ;
:i*		NOSTOS * iNIP TOS! ;
:i/		NOSTOS / iNIP TOS! ;
:i*/	2NOTOS */ i2NIP TOS! ;
:i*>>	2NOTOS *>> i2NIP TOS! ;  | need LSB (TOS is 32bits)
:i<</	2NOTOS <</ i2NIP TOS! ;  | need LSB (TOS is 32bits)
:i/MOD	NOSTOS /mod 'TOS ! NOS ! ;
:iMOD	NOSTOS mod iNIP TOS! ;
:iABS	TOS 32 >> abs TOS! ;
:iNEG	TOS 32 >> neg TOS! ;
:iCLZ	TOS 32 >> clz TOS! ;
:iSQRT	TOS 32 >> sqrt TOS! ;
:i<<	NOSTOS << iNIP TOS! ;     | need LSB (TOS is 32bits)
:i>>	NOSTOS >> iNIP TOS! ;     | need LSB (TOS is 32bits)
:i>>>	NOSTOS >>> iNIP TOS! ;    | need LSB (TOS is 32bits)

|--- R
:i>R	8 'RTOS +! TOS RTOS ! iDROP ;
:iR>	iDUP RTOS dup @ 'TOS ! 8 - 'RTOS ! ;
:iR@	iDUP RTOS @ 'TOS ! ;

|--- REGA
:i>A	TOS 'REGA ! iDROP ;
:iA>	'REGA @ PUSHiNRO ;
:iA+	TOS 'REGA +! iDROP ;

:iA@	REGA code + @ PUSHiNRO ;
:iA!	TOS REGA code + ! iDROP ;
:iA@+	REGA dup 8 + 'REGA ! code + @ PUSHiNRO ;
:iA!+	TOS REGA dup 8 + 'REGA ! code + ! iDROP ;


|--- REGB
:i>B	TOS 'REGB ! iDROP ;
:iB>	'REGB @ PUSHiNRO ;
:iB+	TOS 'REGB +! iDROP ;
:iB@	REGB code + @ PUSHiNRO ;
:iB!	TOS REGB code + ! iDROP ;
:iB@+	REGB dup 8 + 'REGB ! code + @ PUSHiNRO ;
:iB!+	TOS REGB dup 8 + 'REGB ! code + ! iDROP ;


:i@		TOS code + d@ 'TOS ! ;
:iC@	TOS code + c@ 'TOS ! ;
:i@+    TOS code + d@+ 'TOS ! code - 8 'NOS +! NOS ! ;
:iC@+	TOS code + c@+ 'TOS ! code - 8 'NOS +! NOS ! ;
:i!		NOS @ TOS code + d! NOS dup 8 - @ 'TOS ! 16 - 'NOS ! ;
:iC!	NOS @ TOS code + c! NOS dup 8 - @ 'TOS ! 16 - 'NOS ! ;
:i!+	NOS @ TOS code + d!+ code - 'TOS ! -8 'NOS ! ;
:iC!+	NOS @ TOS code + c!+ code - 'TOS ! -8 'NOS ! ;
:i+!	NOS @ TOS code + d+! NOS dup 8 - @ 'TOS ! 16 - 'NOS ! ;
:iC+!	NOS @ TOS code + c+! NOS dup 8 - @ 'TOS ! 16 - 'NOS ! ;

:iMOVE		NOS 8 - @ NOS @ TOS move i3DROP ;
:iMOVE>		NOS 8 - @ NOS @ TOS move> i3DROP ;
:iFILL		NOS 8 - @ NOS @ TOS fill i3DROP ;
:iCMOVE		NOS 8 - @ NOS @ TOS cmove i3DROP ;
:iCMOVE>	NOS 8 - @ NOS @ TOS cmove> i3DROP ;
:iCFILL		NOS 8 - @ NOS @ TOS cfill i3DROP ;
:iDMOVE		NOS 8 - @ NOS @ TOS dmove i3DROP ;
:iDMOVE>	NOS 8 - @ NOS @ TOS dmove> i3DROP ;
:iDFILL		NOS 8 - @ NOS @ TOS dfill i3DROP ;

:iMEM	mem pushinro ;

:iLITd :iLITh :iLITb :iLITf	:iLITs
	iDUP atoken 'TOS ! ;	

:iWORD	atoken 32 >> code: + swap -8 'RTOS +! RTOS ! ;		| 32 bits
:iAWORD	8 'NOS +! TOS NOS ! atoken 'TOS ! ;	| 32 bits (iLIT)
:iVAR	8 'NOS +! TOS NOS ! atoken 32 >> code: + @ 'TOS ! ;	| 32 bits
:iAVAR	8 'NOS +! TOS NOS ! atoken 'TOS ! ;	| 32 bits (iLIT)

#tokenx
iLITd iLITb iLITh iLITf iLITs 
iWORD iAWORD iVAR iAVAR |0-8

| isys
i; i( i) i[ i] iEX i0? i1? i+? i-? 				|9-18
i<? i>? i=? i>=? i<=? i<>? iAND? iNAND? iIN? 	|19-27
iDUP iDROP iOVER iPICK2 iPICK3 iPICK4 iSWAP iNIP 	|28-35
iROT i2DUP i2DROP i3DROP i4DROP i2OVER i2SWAP 	|36-42
i@ iC@ i@+ iC@+ i! iC! i!+ iC!+ i+! iC+! 		|43-52
i>A iA> iA@ iA! iA+ iA@+ iA!+ 					|53-59
i>B iB> iB@ iB! iB+ iB@+ iB!+ 					|60-66
iNOT iNEG iABS iSQRT iCLZ						|67-71
iAND iOR iXOR i+ i- i* i/ iMOD					|72-79
i<< i>> i>>> i/MOD i*/ i*>> i<</				|80-86
iMOVE iMOVE> iFILL iCMOVE iCMOVE> iCFILL			|87-92

#toknames 
";" "(" ")" "[" "]" "ex" "0?" "1?" "+?" "-?"				|9-18
"<?" ">?" "=?" ">=?" "<=?" "<>?" "and?" "nand?" "in?"		|19-27
"dup" "drop" "over" "pick2" "pick3" "pick4" "swap" "nip"	|28-35
"rot" "2dup" "2drop" "3drop" "4drop" "2over" "2swap"		|36-42
"@" "c@" "@+" "c@+" "!" "c!" "!+" "c!+" "+!" "c+!"			|43-52
">a" "a>" "a@" "a!" "a+" "a@+" "a!+"						|53-59
">b" "b>" "b@" "b!" "b+" "b@+" "b!+"						|60-66
"not" "neg" "abs" "sqrt" "clz"								|67-71
"and" "or" "xor" "+" "-" "*" "/" "mod"						|72-79
"<<" ">>" ">>>" "/mod" "*/" "*>>" "<</"						|80-86
"move" "move>" "fill" "cmove" "cmove>" "cfill"				|87-92
0

#INTWORDS 9

|iLITd iLITb iLITh iLITf iLITs iWORD iAWORD iVAR iAVAR |0-8
#tokmov (
$10 $10 $10 $10 $10 -1 $10 $10 $10
0 0 0 0 0 $f1 $1 $1 $1 $1
$f2 $f2 $f2 $f2 $f2 $f2 $f2 $f2 $e3
$11 $f1 $12 $13 $14 $15 $02 $f2
$03 $24 $e2 $d3 $c4 $24 $04
$01 $01 $11 $11 $e2 $e2 $f2 $f2 $e2 $e2
$f1 $20 $10 $f1 $f1 $10 $f0
$f1 $20 $10 $f1 $f1 $10 $f0
$01 $01 $01 $01 $01
$f2 $f2 $f2 $f2 $f2 $f2 $f2 $f2
$f2 $f2 $f2 $02 $e3 $e3 $e3
$d3 $d3 $d3 $d3 $d3 $d3
0 )

#tokname * 1024
	
|--------- token 2 string	
#auxstr * 8

:strcpyn | src cnt dest -- 
	>a ( 1? 1- swap c@+ 
		34 =? ( 0 nip )
		0? ( ca! 2drop ; ) ca!+ swap ) ca! drop ;
	
:ilitd 32 >> "%d" sprint ;
:ilitb 32 >> "%%%b" sprint ;
:ilith 32 >> "$%h" sprint ;
:ilitf 32 >> "%f" sprint ;
:ilits 16 >> $ffff and src + 1+ 7 'auxstr strcpyn 'auxstr ; | *** a memoria data o code

:iword |16 >> $ffff and src + "%w" sprint ;
:iaword |16 >> $ffff and src + "%w" sprint ;
:ivar |16 >> $ffff and src + "%w" sprint ;
:iavar 16 >> $ffff and src + "%w" sprint ;
	
#tokbig ilitd ilitb ilith ilitf ilits iword iaword ivar iavar  

::vmtokstr | tok -- ""
	$80 and? ( $7f and 3 << syswords + @ ; ) 
	dup $7f and 
	$7f =? ( 2drop "#" ; )
	INTWORDS >=? ( nip INTWORDS - 3 << 'tokname + @ ; )
	3 << 'tokbig + @ ex ;
	
::vmcell | tok -- ""
	dup $f and 3 << 'tokbig + @ ex ;

#tokcol ( $7 $7 $7 $7 $6 $d $5 $c $2 )

::vmcellcol	| tok -- tok col
	dup $f and 'tokcol + c@ ;

|------ RUN
::vmdeep | -- stack
	NOS stack - 3 >> 1 + ;

::vmtokmov | tok -- usr
	$80 and? ( $7f and syswordd + c@ ; ) 
	dup $7f and 
	5 =? ( drop 8 >> $ff and ; ) | WORD
	nip 'tokmov + c@ ;

::vmchecktok
	tokmov $f and
	vmdeep >? ( 6 'terror ! )
	drop
	;

::vmstep | ip -- ip'
	@+
	$80 and? ( $7f and 3 << sysworde + @ ex ; ) 
	$7f and 3 << 'tokenx + @ ex ;

::vmstepck | ip -- ip'
	@+
	dup vmtokmov $f and 
	vmdeep >? ( 6 'terror ! 2drop ; ) 
	drop
	$80 and? ( $7f and 3 << sysworde + @ ex ; ) 
	$7f and 3 << 'tokenx + @ ex ;

::vmrun | to ip -- ip'
	( over <>? vmstep ) ;

::vm2src | code --src
	@ 16 >> $ffff and src + ;
	
|------- IO
::vmpop | -- t
	TOS 
	NOS dup @ 'TOS ! 8 - 'NOS ! ;

::vmpush | v --
	8 'NOS +! TOS NOS ! 'TOS ! ;

::vmcpuio | 'words 'exwords 'skwords -- 
	'syswordd ! | data stack
	'sysworde ! | vectors
	'syswords ! | strings
	;

|--------- TOKENIZER / COMPILER
#blk * 64
#blk> 'blk

:pushbl code: - blk> w!+ 'blk> ! ;	| store diff with code:
:popbl -2 'blk> +! blk> w@ code: + ;

:,i	code> !+ 'code> ! ;
	
:endef
	tlevel 1? ( 2 'terror ! ) drop
	'blk 'blk> !
	0 'tlevel !
	;

:newentry | adr -- 'adr
	endef
	code> code: - 32 << 
	over src - 16 << or  
	dicc> !+ 'dicc> !
	>>sp ;

:.def | adr -- adr' | :
	1+ newentry 
	1 'state ! ;

:.var | adr -- adr' | #
	1+ newentry
	2 'state !
	$100
	dicc> 8 - +!	| store flag
	| store var in code
	dup src - 16 <<
	$7f or 
|	swap trim "* " =pre 1? ( rot $2 or -rot ) drop	
	,i ;


:.lit | adr -- adr
	state
	2 =? ( drop str>anro ,i ; )
	drop
	dup str>anro 32 <<
	rot src - 16 << or
	,i
	| falta hex/bin/fix
	;		

:.com | adr -- adr'
	>>cr 
	; | don't save comment

:.str | adr -- adr'
	state
	2 =? ( drop ; ) |,cpystr ; )	| data .. en data ***
	drop
	dup src - 16 <<
|	over 1+ >>str pick2 - 32 << or | len string
	4 or | str
	,i
	1+ >>str
	;

:?dicc | adr dicc -- nro+1/0
	swap over | dicc adr dicc
	( @+ 1?
		pick2 =w 1? ( drop rot - 3 >> nip ; )
		drop ) 
	4drop 0 ;

:?core	'tokname ?dicc ;
:?sys	syswords ?dicc ;

:?word | adr -- adr/0
	dicc>
	( 8 - 'dicc >=?
		dup @ 	| adr dic entry
		16 >> $ffff and src + pick2 
		=w 1? ( drop nip ; )
		drop ) 2drop 0 ;
	
|---------------------------------
| static analisys
#sana * 64
#sana> 'sana

#lev
#usoD
#delD

:pushvar 
	delD 8 << 
	usoD $ff and or
	sana> w!+ 'sana> ! ;	| store diff with code:
	
:popvar 
	-2 'sana> +! sana> w@ 
	dup $ff and 'usoD ! 
	8 >> 'delD ! ;
	
:dropvar
	sana> 'sana =? ( drop ; ) drop | error!!
	-2 'sana> +! ;

|****** falta calcular multiple ; 
|";" "(" ")" "[" "]" "ex" "0?" "1?" "+?" "-?"				|9-18
|"<?" ">?" "=?" ">=?" "<=?" "<>?" "and?" "nand?" "in?"		|19-27
:checkword | --
	0 'lev ! 0 'usod ! 0 'deld !
	'sana 'sana> ! 
	dicc> 8 - @ 32 >> code: +
	( code> <? @+
		dup vmtokmov dup	| calc mov stack
		$f and deld swap - neg clamp0 usod max 'usod !
		56 << 60 >> 'deld +!
		$1ff and 			| check level
		10 =? ( 1 'lev +! pushvar )
		11 =? ( -1 'lev +! popvar ) | check IF prev=next
		$10f $11b in? ( dropvar pushvar ) | while dropvar pushvar
		drop
		) drop 
|	lev "lev:%d" .println		
|	usod "uso D:%d" .println
|	deld "delta D:%d" .println
	;

:core;
	tlevel 1? ( drop ; ) drop
|	dicc> 8 - @ 16 >> $ffff and src + "::%w " .println
	checkword
	
	deld 4 << usod or $ff and 8 << |dup ">>%h<<" .println
	dicc> 8 - +!	| stack delta-use
	
	0 'state !
	;

#iswhile

:core(  | --
	1 'tlevel +!
	code> pushbl ;

:cond?? | adr t -- adr 
	$ffffff00 nand						| remove src
	15 <? ( drop ; ) 27 >? ( drop ; )	| cond without fix
	drop
	code> over - 32 << 
	$100 or | mark while
	over 8 - +!
	1 'iswhile ! ;

:core) | --
	-1 'tlevel +!
	0 'iswhile !
	popbl dup
	( code> <? @+ cond??  ) drop	| search ??
	iswhile 1? ( drop				| patch WHILE
		code> - 32 << code> 8 - +!  | marca while
		; ) drop
	|dup 8 - 	( ) drop				| patch REPEAT
	code> over - 8 + 32 << swap 16 - +!	| path IF
	;

:core[
	1 'tlevel +!
	code> pushbl
	;

:core]
	-1 'tlevel +!
	popbl code> over -
	32 << 12 or swap ! ;
	
:.core	| nro --
	state
	2 =? ( 2drop 3 'terror ! ; )
	drop
	1-
	dup INTWORDS + 
	pick2 src - 16 << or
	,i
	0? ( drop core; >>sp ; )
	1 =? ( drop core( >>sp ; )
	2 =? ( drop core) >>sp ; )
	3 =? ( drop core[ >>sp ; )
	4 =? ( drop core] >>sp ; )
	drop 
	>>sp ; 

:.sys
	1- $80 or 
	over src - 16 << or 
	,i >>sp ;
	
:.word
	state
	2 =? ( drop @ ,i ; )	| data **
	drop
	@ $ffff0000 nand
	over src - 16 << or
	$100 and? ( 
		7 or 
		,i >>sp ; )  	| var
	5 or 
	,i >>sp ; 			| code
	
:.adr
	state
	2 =? ( drop @ ,i ; )	| data **
	drop
	@ $ffff0000 nand
	over src - 16 << or
	$100 and? ( 
		8 or 
		,i >>sp ; )		| var
	6 or 
	,i >>sp ;			| code
	
:wrd2token | str -- str'
	( dup c@ $ff and 33 <? 
		0? ( drop 1 'terror ! ; ) drop 1+ )	| trim0
	$7c =? ( drop .com ; )	| $7c |	 Comentario
	$3A =? ( drop .def ; )	| $3a :  Definicion
	$23 =? ( drop .var ; )	| $23 #  Variable
	$22 =? ( drop .str ; )	| $22 "	 Cadena
	$27 =? ( drop 			| $27 ' Direccion
		dup 1 + ?word 1? ( .adr ; ) drop
		3 'terror ! ; )
	drop
	dup isNro 1? ( drop .lit ; ) drop	| number
	dup ?core 1? ( .core ; ) drop		| core
	dup ?word 1? ( .word ; ) drop		| word
	dup ?sys 1? ( .sys ; ) drop
 	5 'terror ! ;

::vmtokreset
	'dicc 'dicc> !
	0 'lastdic> !
	;
	
::vmtokenizer | str code -- code' 
	0 'terror !
	dup 'code: ! 'code> !
	dup 'src !
	0 ( drop wrd2token
		terror 0? ) drop
	'serror !
	code> ;
	
::vmboot
	dicc> 8 - @ 32 >> code: + ;
	
::vmcode2src
	16 >> $ffff and src + ;
	
|--------- CHECK CODE
::vmcheckjmp | cnt 'adr --
	>a
	0 ( over <?
		a@+ dup 
		$7f and 15 27 in? ( swap 32 >> 0? ( 7 'terror ! ) )
		2drop
		1+ ) 2drop ;

::vmlistok | 'list 'str --
	swap >a ( dup c@ 1? drop dup a!+ >>0 ) a! drop ;

|--------- CPU
::vmreset
	stack 8 - 'NOS ! 0 'TOS !
	stack 256 8 - + 0 over ! 'RTOS !  
	code 'ip !
	;

::vm@ | 'vm --	; get vm current
    'IP swap 9 move	;
::vm! | 'vm --	; store vm
	'IP 9 move ;

|#IP 			
|#TOS #NOS #RTOS 
|#REGA #REGB
|#STACK #CODE #DATA

::vmcpu | CODE RAM -- 'adr ; ram, cnt of vars
	here dup		| code ram here here
	9 3 << +		| IP,TOS,NOS,RTOS,RA,RB,STACK,CODE,DATA
	dup 'stack !
	256 +			| stacks  (32 stack cell)
	dup 'data !
	rot 3 << +		| data space, variables
	'here !
	swap 'code !
	vmreset
	dup vm!			| store in vm
	;
	
	
|--------- ERROR 	
#msgerror 
"Ok"
"Block bad close"
"Core word without adress"
"Addr not exist"
"Word not found"

"stack empty"		|6
"conditional alone"	|7
"unbalanced stack"	|8
"div by 0"			|9
"no data adress"	|10
"no code adress"	|11

::vmerror | -- str
	terror 0? ( ; )
	1- 'msgerror 
	( swap 1? 1- swap >>0 ) drop ;

::vmdicc
	vmerror .println .cr
	'dicc ( dicc> <?
		@+ |"%h" .println 
		dup "%h " .print
		dup 16 >> $ffff and src + "%w " .print		
		8 >> $ff and dup "(%h)" .print
		dup $f and swap 56 << 60 >>  " d:%d u:%d" .print
		.cr
		) drop
	.cr		
	code: ( code> <?
		@+ dup "%h " .print vmtokstr .println
		) drop
	;
	
|--------- INIT
: 'tokname 'toknames vmlistok ;
