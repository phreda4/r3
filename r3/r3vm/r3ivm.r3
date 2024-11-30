| r3i virtual machine
| simplest encoding  - 1 byte token
| PHREDA 2021
^r3/lib/mem.r3

| IP,BOOT
| TOS,NOS,RTOS,RA,RB
| CODE CODE>
##IP ##TOS ##NOS ##RTOS ##REGA ##REGB
##CODE ##CODE>

| 'code
|  stack (256) |##STACK * 256 | 64 cells
| tokens
| 'code>
| free
| io
#blok
#exsys 0

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
:jmpr		w@+ + ;

:i;		drop RTOS @ 8 'RTOS +! ;
:i(		;
:i)		jmpr ;
:i[		jmpr ;
:i]		8 'NOS +! TOS NOS ! w@+ + 'TOS ! ;
:iEX	-8 'RTOS +! RTOS ! TOS code + 8 'NOS +! NOS @ 'TOS ! ;

|--- COND
:i0?	TOS 1? ( drop jmpr ; ) drop 2 + ;
:i1?	TOS 0? ( drop jmpr ; ) drop 2 + ;
:i+?	TOS -? ( drop jmpr ; ) drop 2 + ;
:i-?	TOS +? ( drop jmpr ; ) drop 2 + ;
:i=?	NOS @ TOS <>? ( drop jmpr iDROP ; ) drop iDROP 2 + ;
:i<?	NOS @ TOS >=? ( drop jmpr iDROP ; ) drop iDROP 2 + ;
:i>?	NOS @ TOS <=? ( drop jmpr iDROP ; ) drop iDROP 2 + ;
:i<=?	NOS @ TOS >? ( drop jmpr iDROP ; ) drop iDROP 2 + ;
:i>=?	NOS @ TOS <? ( drop jmpr iDROP ; ) drop iDROP 2 + ;
:i<>?	NOS @ TOS =? ( drop jmpr iDROP ; ) drop iDROP 2 + ;
:iAND?	NOS @ TOS nand? ( drop jmpr iDROP ; ) drop iDROP 2 + ;
:iNAND?	NOS @ TOS and? ( drop jmpr iDROP ; ) drop iDROP 2 + ;
:iIN?	NOS 8 - @ NOS @ TOS in? ( drop jmpr i2DROP ; ) drop i2DROP 2 + ;

:iAND	NOS @ TOS and iNIP 'TOS ! ;
:iOR	NOS @ TOS or iNIP 'TOS ! ;
:iXOR	NOS @ TOS xor iNIP 'TOS ! ;
:iNOT	TOS not 'TOS ! ;
:i+		NOS @ TOS + iNIP 'TOS ! ;
:i-		NOS @ TOS - iNIP 'TOS ! ;
:i*		NOS @ TOS * iNIP 'TOS ! ;
:i/		NOS @ TOS / iNIP 'TOS ! ;
:i*/	NOS 8 - @ NOS @ TOS */ i2NIP 'TOS ! ;
:i*>>	NOS 8 - @ NOS @ TOS *>> i2NIP 'TOS ! ;  | need LSB (TOS is 32bits)
:i<</	NOS 8 - @ NOS @ TOS <</ i2NIP 'TOS ! ;  | need LSB (TOS is 32bits)
:i/MOD	NOS @ TOS /mod 'TOS ! NOS ! ;
:iMOD	NOS @ TOS mod iNIP 'TOS ! ;
:iABS	TOS abs 'TOS ! ;
:iNEG	TOS neg 'TOS ! ;
:iCLZ	TOS clz 'TOS ! ;
:iSQRT	TOS sqrt 'TOS ! ;
:i<<	NOS @ TOS << iNIP 'TOS ! ;     | need LSB (TOS is 32bits)
:i>>	NOS @ TOS >> iNIP 'TOS ! ;     | need LSB (TOS is 32bits)
:i>>>	NOS @ TOS >>> iNIP 'TOS ! ;    | need LSB (TOS is 32bits)

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

:iMEM mem pushinro ;

:iLIT1	8 'NOS +! TOS NOS ! w@+ 'TOS ! ;	| 16 bits
:iLIT2	8 'NOS +! TOS NOS ! d@+ 'TOS ! ;	| 32 bits
:iLITs	8 'NOS +! TOS NOS ! c@+ over code - 'TOS ! $ff and + ;	| 8+s bits
:iCOM   c@+ -1 =? ( drop c@+ 3 << exsys + @ ex ; ) $ff and + ;
:iJMPR  w@ + ; 				| 16 bits
:iJMP   d@ code + ;			| 32 bits
:iCALL	d@+ code + swap -8 'RTOS +! RTOS ! ; 	| 32 bits
:iADR	8 'NOS +! TOS NOS ! d@+ 'TOS ! ;	| 32 bits (iLIT)
:iVAR	8 'NOS +! TOS NOS ! d@+ code + d@ 'TOS ! ;	| 32 bits

#r3maci
iLIT1 iLIT2 iLITs iCOM iJMPR iJMP iCALL iADR iVAR	|0-8
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
| (0|1|2|3|4|5|6|7) << 'var + @ ! c@ c! w@ w! d@ d!
| call;
| minilit 'var! d! w! c!
| 'var+! d+! w+! c+!
|

:exlit | 7 bit number
	8 'NOS +! TOS NOS !
	57 << 57 >> 'TOS ! ; | 7 to 64 bits // in 32bits 25 <<

::vmstep | ip -- ip'
	0? ( ; )
	c@+ $80 and? ( exlit ; )
	3 << 'r3maci + @ ex ;

::vmrun | to ip -- ip'
	( over <>? vmstep ) ;

::vmreset
	code 8 - 'NOS ! 0 'TOS !
::vmresetr
	code 248 + 0 over ! 'RTOS ! | 512-8 
	;

::vecsys! 'exsys ! ;

::vmdeep | -- stack
	NOS code - 3 >> 1 + ;

::vmpop | -- t
	TOS
	NOS dup @ 'TOS ! 8 - 'NOS ! ;

::vmpush | v --
	8 'NOS +! TOS NOS !
	'TOS ! ;

::vm@ | 'vm --	; get vm current
    'IP swap 8 move	;
::vm! | 'vm --	; store vm
	'IP 8 move ;

::vmcpu | ram -- 'adr
	here
	8 3 << over +	| IP,TOS,NOS,RTOS,RA,RB,CODE,CODE>
	dup 'code !
	256 +		| stacks  (64stack cell)
	dup 'code> !
	rot + 'here !
	dup vm!
	vmreset
	;
