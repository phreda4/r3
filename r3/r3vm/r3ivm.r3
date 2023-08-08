| r3i virtual machine
| simplest encoding  - 1 byte token
| PHREDA 2021

| IP,BOOT
| TOS,NOS,RTOS,RA,RB
| CODE CODE>
##IP ##TOS ##NOS ##RTOS ##RA ##RB
##CODE ##CODE>

| 'code
|  stack (256) |##STACK * 256 | 64 cells
| tokens
| 'code>
| free
| io


#exsys 0

:i;		drop RTOS @ 4 'RTOS +! ;
|		drop RTOS @ 4 'RTOS +! 0? ( r> drop ) ; | *** REPEAT
:i(		;
:i)		@+ 48 << 48 >> + 2 - ;
:i[		@+ 48 << 48 >> + ;
:i]		4 'NOS +! TOS NOS ! @+ 48 << 48 >> + 'TOS ! ;
:iEX	-4 'RTOS +! RTOS ! TOS code + 4 'NOS +! NOS @ 'TOS ! ;
:i0?	TOS 1? ( drop @+ 48 << 48 >> + 2 - ; ) drop 2 + ; | +4 (16bit)+
:i1?    TOS 0? ( drop @+ 48 << 48 >> + 2 - ; ) drop 2 + ;
:i+?    TOS -? ( drop @+ 48 << 48 >> + 2 - ; ) drop 2 + ;
:i-?	TOS +? ( drop @+ 48 << 48 >> + 2 - ; ) drop 2 + ;
:i<?    NOS @ TOS >=? ( 'TOS ! -4 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -4 'NOS +! 2 + ;
:i>?	NOS @ TOS <=? ( 'TOS ! -4 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -4 'NOS +! 2 + ;
:i=?    NOS @ TOS <>? ( 'TOS ! -4 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -4 'NOS +! 2 + ;
:i>=?	NOS @ TOS <? ( 'TOS ! -4 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -4 'NOS +! 2 + ;
:i<=?	NOS @ TOS >? ( 'TOS ! -4 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -4 'NOS +! 2 + ;
:i<>?	NOS @ TOS =? ( 'TOS ! -4 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -4 'NOS +! 2 + ;
:iAND?	NOS @ TOS NAND? ( 'TOS ! -4 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -4 'NOS +! 2 + ;
:iNAND?	NOS @ TOS AND? ( 'TOS ! -4 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -4 'NOS +! 2 + ;
:iBT?	NOS dup 4 - @ swap @ TOS BT? ( 'TOS ! -8 'NOS +! @+ 48 << 48 >> + 2 - ; ) 'TOS ! -8 'NOS +! 2 + ;
:iDUP	4 'NOS +! TOS NOS ! ;
:iDROP	NOS dup @ 'TOS ! 4 - 'NOS ! ;
:iOVER	4 'NOS +! TOS NOS ! NOS 4 - @ 'TOS ! ;
:iPICK2	4 'NOS +! TOS NOS ! NOS 8 - @ 'TOS ! ;
:iPICK3	4 'NOS +! TOS NOS ! NOS 12 - @ 'TOS ! ;
:iPICK4	4 'NOS +! TOS NOS ! NOS 16 - @ 'TOS ! ;
:iSWAP  NOS @ TOS NOS ! 'TOS ! ;
:iNIP	-4 'NOS +! ;
:iROT	TOS NOS 4 - @ 'TOS ! NOS @ NOS 4 - !+ ! ;
:i2DUP  iOVER iOVER ;
:i2DROP	NOS dup 4 - @ 'TOS ! 8 - 'NOS ! ;
:i3DROP	NOS dup 8 - @ 'TOS ! 12 - 'NOS ! ;
:i4DROP	NOS dup 12 - @ 'TOS ! 16 - 'NOS ! ;
:i2OVER iPICK2 iPICK2 ;
:i2SWAP	TOS NOS @ NOS 4 - dup 4 - @ NOS ! @ 'TOS ! NOS 8 - !+ ! ;
:i@		TOS code + @ 'TOS ! ;
:iC@	TOS code + c@ 'TOS ! ;
:i@+    TOS code + @+ 'TOS ! code - 4 'NOS +! NOS ! ;
:iC@+	TOS code + c@+ 'TOS ! code - 4 'NOS +! NOS ! ;
:i!		NOS @ TOS code + ! NOS dup 4 - @ 'TOS ! 8 - 'NOS ! ;
:iC!	NOS @ TOS code + c! NOS dup 4 - @ 'TOS ! 8 - 'NOS ! ;
:i!+	NOS @ TOS code + !+ code - 'TOS ! -4 'NOS ! ;
:iC!+	NOS @ TOS code + c!+ code - 'TOS ! -4 'NOS ! ;
:i+!	NOS @ TOS code + +! NOS dup 4 - @ 'TOS ! 8 - 'NOS ! ;
:iC+!	NOS @ TOS code + c+! NOS dup 4 - @ 'TOS ! 8 - 'NOS ! ;
:i>A	TOS 'RA ! NOS dup @ 'TOS ! 4 - 'NOS ! ;
:iA>	4 'NOS +! TOS NOS ! RA 'TOS ! ;
:iA@	4 'NOS +! TOS NOS ! RA code + @ 'TOS ! ;
:iA!	TOS RA code + ! NOS dup @ 'TOS ! 4 - 'NOS ! ;
:iA+	TOS 'RA +! NOS dup @ 'TOS ! 4 - 'NOS ! ;
:iA@+	4 'NOS +! TOS NOS ! RA code + @ 'TOS 4 'RA +! ;
:iA!+   TOS RA code + ! 4 'RA +! NOS dup @ 'TOS ! 4 - 'NOS ! ;
:i>B    TOS 'RB ! NOS dup @ 'TOS ! 4 - 'NOS ! ;
:iB>    4 'NOS +! TOS NOS ! RB 'TOS ! ;
:iB@	4 'NOS +! TOS NOS ! RB code + @ 'TOS ! ;
:iB!	TOS RB code + ! NOS dup @ 'TOS ! 4 - 'NOS ! ;
:iB+	TOS 'RB +! NOS dup @ 'TOS ! 4 - 'NOS ! ;
:iB@+	4 'NOS +! TOS NOS ! RB code + @ 'TOS 4 'RB +! ;
:iB!+	TOS RB code + ! 4 'RB +! NOS dup @ 'TOS ! 4 - 'NOS ! ;
:iNOT	TOS not 'TOS ! ;
:iNEG	TOS neg 'TOS ! ;
:iABS	TOS abs 'TOS ! ;
:iSQRT	TOS sqrt 'TOS ! ;
:iCLZ	TOS clz 'TOS ! ;
:iAND	NOS @ TOS AND 'TOS ! -4 'NOS +! ;
:iOR	NOS @ TOS OR 'TOS ! -4 'NOS +! ;
:iXOR	NOS @ TOS XOR 'TOS ! -4 'NOS +! ;
:i+		NOS @ TOS + 'TOS ! -4 'NOS +! ;
:i-		NOS @ TOS - 'TOS ! -4 'NOS +! ;
:i*		NOS @ TOS * 'TOS ! -4 'NOS +! ;
:i/		NOS @ TOS / 'TOS ! -4 'NOS +! ;
:iMOD	NOS @ TOS MOD 'TOS ! -4 'NOS +! ;
:i<<	NOS @ TOS << 'TOS ! -4 'NOS +! ;
:i>>	NOS @ TOS >> 'TOS ! -4 'NOS +! ;
:i>>>	NOS @ TOS >>> 'TOS ! -4 'NOS +! ;
:i/MOD	NOS @ TOS /MOD 'TOS ! NOS ! ;
:i*/	NOS dup 4 - @ swap @ TOS */ 'TOS ! -8 'NOS +! ;
:i*>>	NOS dup 4 - @ swap @ TOS *>> 'TOS ! -8 'NOS +! ;
:i<</	NOS dup 4 - @ swap @ TOS <</ 'TOS ! -8 'NOS +! ;

:iMOV	NOS dup 4 - @ swap @ TOS  move NOS dup 8 - @ 'TOS ! 12 - 'NOS ! ;
:iMOV>	NOS dup 4 - @ swap @ TOS  move> NOS dup 8 - @ 'TOS ! 12 - 'NOS ! ;
:iFILL	NOS dup 4 - @ swap @ TOS  fill NOS dup 8 - @ 'TOS ! 12 - 'NOS ! ;
:iCMOV	NOS dup 4 - @ swap @ TOS  cmove NOS dup 8 - @ 'TOS ! 12 - 'NOS ! ;
:iCMOV>	NOS dup 4 - @ swap @ TOS  cmove> NOS dup 8 - @ 'TOS ! 12 - 'NOS ! ;
:iCFILL NOS dup 4 - @ swap @ TOS  cfill NOS dup 8 - @ 'TOS ! 12 - 'NOS ! ;

:iLIT1	4 'NOS +! TOS NOS ! @+ 48 << 48 >> 'TOS ! 2 - ; | 16 bits
:iLIT2	4 'NOS +! TOS NOS ! @+ 'TOS ! ;	| 32 bits
:iLITs	4 'NOS +! TOS NOS ! c@+ over code - 'TOS ! $ff and + ;	| 8+s bits
:iCOM   c@+ -1 =? ( drop c@+ 2 << exsys + @ ex ; ) $ff and + ;
:iJMPR  @ 48 << 48 >> + ; 				| 16 bits
:iJMP   @ code + ;						| 32 bits
:iCALL	@+ code + swap -4 'RTOS +! RTOS ! ; 	| 32 bits
:iADR	4 'NOS +! TOS NOS ! @+ 'TOS ! ;	| 32 bits (iLIT)
:iVAR	4 'NOS +! TOS NOS ! @+ code + @ 'TOS ! ;	| 32 bits


#r3maci
iLIT1 iLIT2 iLITs iCOM iJMPR iJMP iCALL iADR iVAR	|0-8
i; i( i) i[ i] iEX i0? i1? i+? i-? 				|9-18
i<? i>? i=? i>=? i<=? i<>? iAND? iNAND? iBT? 	|19-27
iDUP iDROP iOVER iPICK2 iPICK3 iPICK4 iSWAP iNIP 	|28-35
iROT i2DUP i2DROP i3DROP i4DROP i2OVER i2SWAP 	|36-42
i@ iC@ i@+ iC@+ i! iC! i!+ iC!+ i+! iC+! 		|43-52
i>A iA> iA@ iA! iA+ iA@+ iA!+ 					|53-59
i>B iB> iB@ iB! iB+ iB@+ iB!+ 					|60-66
iNOT iNEG iABS iSQRT iCLZ						|67-71
iAND iOR iXOR i+ i- i* i/ iMOD					|72-79
i<< i>> i>>> i/MOD i*/ i*>> i<</				|80-86
iMOV iMOV> iFILL iCMOV iCMOV> iCFILL			|87-92
			|92-127

:exlit | 7 bit number
	4 'NOS +! TOS NOS !
	57 << 57 >> 'TOS ! ; | 7 to 64 bits // in 32bits 25 <<

::vmstep | ip -- ip'
	0? ( ; )
	c@+ $80 and? ( exlit ; )
	3 << 'r3maci + @ ex ;

::vmrun | ip -- ip'
	( 1? | *** avoid with REPEAT
		vmstep ) ;

::vmreset
	code 4 - 'NOS ! 0 'TOS !
::vmresetr
	code 252 + 0 over ! 'RTOS !
	;

::vecsys! 'exsys ! ;

::vmdeep | -- stack
	NOS code - 2 >> 1 + ;

::vmpop | -- t
	TOS
	NOS dup @ 'TOS ! 4 - 'NOS ! ;

::vmpush | v --
	4 'NOS +! TOS NOS !
	'TOS ! ;

::vm@ | 'vm --	; get vm current
    'IP swap 8 move	;
::vm! | 'vm --	; store vm
	'IP 8 move ;

::vmcpu | ram -- 'adr
	here
	8 2 << over +	| IP,TOS,NOS,RTOS,RA,RB,CODE,CODE>
	dup 'code !
	256 +		| stacks
	dup 'code> !
	rot + 'here !
	dup vm!
	;
