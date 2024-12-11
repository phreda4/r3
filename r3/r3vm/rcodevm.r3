| rcode vm
| PHREDA 2024
^r3/lib/mem.r3


#wordd | data stack
#worde | vectors
##words | strings

#dicc * 1024
#dicc>

|------ VM
#IP 			
##TOS #NOS #RTOS 
#REGA #REGB
##STACK #CODE #DATA

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
:i)		jmpr ;
:i[		jmpr ;
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


:iLITd :iLITh :iLITb
:iLITs
	iDUP atoken 'TOS ! ;
:iCOM	;
:iWORD	d@+ code + swap -8 'RTOS +! RTOS ! ; 	| 32 bits
:iAWORD	8 'NOS +! TOS NOS ! d@+ 'TOS ! ;	| 32 bits (iLIT)
:iVAR	8 'NOS +! TOS NOS ! d@+ code + d@ 'TOS ! ;	| 32 bits
:iAVAR	8 'NOS +! TOS NOS ! d@+ 'TOS ! ;	| 32 bits (iLIT)

#tokenx
iLITd iLITh iLITb iLITs 
iCOM iWORD iAWORD iVAR iAVAR |0-8

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


::vmstep | ip -- ip'
	@+
	$80 and? ( $7f and 3 << worde + @ ex ; ) 
	$7f and 3 << 'tokenx + @ ex ;

::vmrun | to ip -- ip'
	( over <>? vmstep ) ;


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

|iLITd iLITh iLITb iLITs iLITf iWORD iAWORD iVAR iAVAR |0-8
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
	
:ilitd 32 >> "%d" sprint ;
:ilith 32 >> "$%h" sprint ;
:ilitb 32 >> "%b" sprint ;
:ilits 32 >> """%d""" sprint ;
:ilitf 32 >> "%f" sprint ;
:iword 
:iaword 
:ivar 
:iavar "w%h" sprint ;
	
#tokbig ilitd ilith ilitb ilits ilitf iword iaword ivar iavar 

::vmtokstr | tok -- ""
	$80 and? ( $7f and 3 << words + @ ; ) 
	dup $7f and 
	8 >? ( nip 9 - 3 << 'tokname + @ ; )
	3 << 'tokbig + @ ex ;
	
::vmtokmov | tok -- usr
	$80 and? ( $7f and wordd + c@ ; ) 
	$7f and 
	
	'tokmov + c@ ;

::vmdeep | -- stack
	NOS stack - 3 >> 1 + ;

::vmcell | tok -- ""
	dup $f and 3 << 'tokbig + @ ex ;

|--------------- IO
::vmpop | -- t
	TOS
	NOS dup @ 'TOS ! 8 - 'NOS ! ;

::vmpush | v --
	8 'NOS +! TOS NOS !
	'TOS ! ;

::vmcpuio | 'words 'exwords 'skwords -- 
	'wordd ! | data stack
	'worde ! | vectors
	'words ! | strings
	;

|--------------- CPU
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
	here
	dup
	9 3 << over +	| IP,TOS,NOS,RTOS,RA,RB,STACK,CODE,DATA
	dup 'stack !
	256 +			| stacks  (32 stack cell)
	dup 'data !
	rot 3 << +		| data space, variables
	'here !
	swap 'code !
	vmreset
	dup vm!			| store in vm
	;
	
|--------------- CHECK CODE
#lev
#while
##usod
##deld
##terror

:error
	1 'terror !
	;
	
:is?? | adr token -- adr token
	a> pick2 - 8 - 32 << 	| adr tok dist
	pick2 @ $ffff and or 
	pick2 !
	1 'while !
	;
	
:patch?? | now -- now
	0 'while !
	a> 8 - 		| adr
	( dup @ lev 8 << 10 or <>?		| adr token
		$ffff <? ( $ff and 15 27 in? ( is?? ) )
		drop 8 - 
		) drop | now adr(10)
	while 1? ( drop a> - 8 + 32 << lev 8 << or 11 or a> 8 - ! ; ) drop
	8 - 
	dup @ $ff and 15 <? ( error 2drop ; ) 27 >? ( error 2drop ; ) drop
	dup @ $ffff and a> pick2 - 8 - 32 << or swap !
	;
	
:clearlev
	9 <? ( swap $ff00 nand ; )
	swap $ff and ;
	
::vmcheckcode | cnt 'adr --
	0 'lev ! 0 'terror !
	0 'usod ! 0 'deld !
	>a
	0 ( over <?
		a@ 
		| calc mov stack
		dup vmtokmov dup 
		$f and deld swap - neg clamp0 usod max 'usod !
		56 << 60 >> 'deld +!
		| check level
		dup $7f and 
		10 =? ( 1 'lev +! )
		clearlev
		lev 8 << or a!+
		11 =? ( patch?? -1 'lev +! )
		drop
		1+ ) 2drop ;
		
::vmcheckjmp | cnt 'adr --
	>a
	0 ( over <?
		a@+ dup 
		$7f and 15 27 in? ( swap 32 >> 0? ( error ) )
		2drop
		1+ ) 2drop ;

::vmlistok | 'list 'str --
	swap >a ( dup c@ 1? drop dup a!+ >>0 ) a! drop ;
	
| here 
: |---------- init
	'tokname 'toknames vmlistok ;
