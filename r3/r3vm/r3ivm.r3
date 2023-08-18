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

:dic>tok ;

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
:getbig		blok + @ ;

:idec2	dup 4 - d@ 8 >> getbig pushinro ;
:ibin2	dup 4 - d@ 8 >> getbig pushinro ;
:ihex2	dup 4 - d@ 8 >> getbig pushinro ;
:ifix2	dup 4 - d@ 8 >> getbig pushinro ;
:iwor2	4 - d@ 8 >> dic>tok @ ; | tail call

:idec	dup 4 - d@ 8 >> pushinro ;
:ihex   dup 4 - d@ 8 >> pushinro ;
:ibin   dup 4 - d@ 8 >> pushinro ;
:ifix   dup 4 - d@ 8 >> pushinro ;
:istr   dup 4 - d@ 8 >> blok + pushinro ;
:iwor	dup 4 - d@ 8 >> dic>tok @ 8 'RTOS +! swap RTOS ! ;
:ivar   dup 4 - d@ 8 >> dic>tok @ @ pushinro ;
:idwor	dup 4 - d@ 8 >> dic>tok @ pushinro ;
:idvar  dup 4 - d@ 8 >> dic>tok @ pushinro ;

:i;		RTOS @ nip -8 'RTOS +! ;

:iEX	TOS iDROP 8 'RTOS +! swap RTOS ! ;

:jmpr | adr' -- adrj
	dup 4 - d@ 8 >> + ;

:i( 	;
:i)		dup 4 - d@ 8 >> + ;  | 0=no effect
:i[		jmpr ;
:i]		dup 4 - d@ 8 >> PUSHiNRO ;

|--- COND
:i0?	TOS 1? ( drop jmpr ; ) drop ;
:i1?	TOS 0? ( drop jmpr ; ) drop ;
:i+?	TOS -? ( drop jmpr ; ) drop ;
:i-?	TOS +? ( drop jmpr ; ) drop ;
:i=?	NOS @ TOS <>? ( drop jmpr iDROP ; ) drop iDROP ;
:i<?	NOS @ TOS >=? ( drop jmpr iDROP ; ) drop iDROP ;
:i>?	NOS @ TOS <=? ( drop jmpr iDROP ; ) drop iDROP ;
:i<=?	NOS @ TOS >? ( drop jmpr iDROP ; ) drop iDROP ;
:i>=?	NOS @ TOS <? ( drop jmpr iDROP ; ) drop iDROP ;
:i<>?	NOS @ TOS =? ( drop jmpr iDROP ; ) drop iDROP ;
:iAND?	NOS @ TOS nand? ( drop jmpr iDROP ; ) drop iDROP ;
:iNAND?	NOS @ TOS and? ( drop jmpr iDROP ; ) drop iDROP ;
:iIN?	NOS 8 - @ NOS @ TOS bt? ( drop jmpr i2DROP ; ) drop i2DROP ;


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

:iA@	REGA @ PUSHiNRO ;
:iA!	TOS REGA ! iDROP ;
:iA@+	REGA dup 8 + 'REGA ! @ PUSHiNRO ;
:iA!+	TOS REGA dup 8 + 'REGA ! ! iDROP ;
:icA@	REGA c@ PUSHiNRO ;
:icA!	TOS REGA c! iDROP ;
:icA@+	REGA dup 1 + 'REGA ! c@ PUSHiNRO ;
:icA!+	TOS REGA dup 1 + 'REGA ! c! iDROP ;
:idA@	REGA d@ PUSHiNRO ;
:idA!	TOS REGA d! iDROP ;
:idA@+	REGA dup 4 + 'REGA d! @ PUSHiNRO ;
:idA!+	TOS REGA dup 4 + 'REGA ! d! iDROP ;

|--- REGB
:i>B	TOS 'REGB ! iDROP ;
:iB>	'REGB @ PUSHiNRO ;
:iB+	TOS 'REGB +! iDROP ;
:iB@	REGB @ PUSHiNRO ;
:iB!	TOS REGB ! iDROP ;
:iB@+	REGB dup 8 + 'REGB ! @ PUSHiNRO ;
:iB!+	TOS REGB dup 8 + 'REGB ! ! iDROP ;
:icB@	REGB c@ PUSHiNRO ;
:icB!	TOS REGB c! iDROP ;
:icB@+	REGB dup 1 + 'REGB ! c@ PUSHiNRO ;
:icB!+	TOS REGB dup 1 + 'REGB ! c! iDROP ;
:idB@	REGB d@ PUSHiNRO ;
:idB!	TOS REGB d! iDROP ;
:idB@+	REGB dup 4 + 'REGB ! d@ PUSHiNRO ;
:idB!+	TOS REGB dup 4 + 'REGB ! d! iDROP ;

:i@		TOS @ 'TOS ! ;
:iC@	TOS c@ 'TOS ! ;
:iW@	TOS w@ 'TOS ! ;
:iD@	TOS d@ 'TOS ! ;
:i!		NOS @ TOS ! i2DROP ;
:iC!	NOS @ TOS c! i2DROP ;
:iW!	NOS @ TOS w! i2DROP ;
:iD!	NOS @ TOS d! i2DROP ;
:i+!	NOS @ TOS +! i2DROP ;
:iC+!	NOS @ TOS c+! i2DROP ;
:iW+!	NOS @ TOS w+! i2DROP ;
:iD+!	NOS @ TOS d+! i2DROP ;
:i@+	TOS @ 8 'TOS +! PUSHiNRO ;
:i!+	NOS @ TOS ! iNIP 8 'TOS +! ;
:iC@+	TOS c@ 1 'TOS +! PUSHiNRO ;
:iC!+	NOS @ TOS c! iNIP 1 'TOS +! ;
:iW@+	TOS w@ 2 'TOS +! PUSHiNRO ;
:iW!+	NOS @ TOS w! iNIP 2 'TOS +! ;
:iD@+	TOS d@ 4 'TOS +! PUSHiNRO ;
:iD!+	NOS @ TOS d! iNIP 4 'TOS +! ;

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

:iLOADLIB TOS loadlib 'TOS ! ;
:iGETPROC NOS @ TOS getproc iNIP 'TOS ! ;
:iSYS0 TOS sys0 'TOS ! ;
:iSYS1 NOS @ TOS sys1 'TOS ! -8 'NOS +! ;
:iSYS2 NOS 8 - @ NOS @ TOS sys2 'TOS ! -16 'NOS +! ;
:iSYS3 NOS 16 - @ NOS 8 - @ NOS @ TOS sys3 'TOS ! -24 'NOS +! ;
:iSYS4 NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys4 'TOS ! -32 'NOS +! ;
:iSYS5 NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys5 'TOS ! -40 'NOS +! ;
:iSYS6 NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys6 'TOS ! -48 'NOS +! ;
:iSYS7 NOS 48 - @ NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys7 'TOS ! -56 'NOS +! ;
:iSYS8 NOS 56 - @ NOS 48 - @ NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys8 'TOS ! -64 'NOS +! ;
:iSYS9 NOS 64 - @ NOS 56 - @ NOS 48 - @ NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys9 'TOS ! -72 'NOS +! ;
:iSYS10 NOS 72 - @ NOS 64 - @ NOS 56 - @ NOS 48 - @ NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys10 'TOS ! -80 'NOS +! ;
	

:iLIT1	8 'NOS +! TOS NOS ! @+ 48 << 48 >> 'TOS ! 2 - ; | 16 bits
:iLIT2	8 'NOS +! TOS NOS ! @+ 'TOS ! ;	| 32 bits
:iLITs	8 'NOS +! TOS NOS ! c@+ over code - 'TOS ! $ff and + ;	| 8+s bits
:iCOM   c@+ -1 =? ( drop c@+ 2 << exsys + @ ex ; ) $ff and + ;
:iJMPR  @ 48 << 48 >> + ; 				| 16 bits
:iJMP   @ code + ;						| 32 bits
:iCALL	@+ code + swap -4 'RTOS +! RTOS ! ; 	| 32 bits
:iADR	8 'NOS +! TOS NOS ! @+ 'TOS ! ;	| 32 bits (iLIT)
:iVAR	8 'NOS +! TOS NOS ! @+ code + @ 'TOS ! ;	| 32 bits

:ioAND 	
:ioOR 
:ioXOR		
:io+ 
:io- 
:io* 
:io/
:io<< 
:io>> 
:io>>>
:ioMOD 
:io/MOD 
:io*/ 
:io*>> 
:io<<
:io<? 
:io>? 
:io=? 
:io>=? 
:io<=? 
:io<>? 
:ioAN? 
:ioNA?

#vmc
i; i( i) i[ i] iEX i0? i1? i+? i-? 				
i<? i>? i=? i>=? i<=? i<>? iAND? iNAND? iIN? 	
iDUP iDROP iOVER iPICK2 iPICK3 iPICK4 iSWAP iNIP 	
iROT i2DUP i2DROP i3DROP i4DROP i2OVER i2SWAP 	
i>R iR> iR@ 
iAND iOR iXOR 
i+ i- i* i/ 
i<< i>> i>>> 
iMOD i/MOD i*/ i*>> i<</ 
iNOT iNEG iABS iSQRT iCLZ 
i@ iC@ iW@ iD@ 
i@+ iC@+ iW@+ iD@+ 
i! iC! iW! iD! 
i!+ iC!+ iW!+ iD!+ 
i+! iC+! iW+! iD+! 
i>A iA> iA+ 
iA@ iA! iA@+ iA!+ 
icA@ icA! icA@+ icA!+ 
idA@ idA! idA@+ idA!+ 
i>B iB> iB+ 
iB@ iB! iB@+ iB!+ 
icB@ icB! icB@+ icB!+ 
idB@ idB! idB@+ idB!+ 
iMOVE iMOVE> iFILL 
iCMOVE iCMOVE> iCFILL 
iDMOVE iDMOVE> iDFILL 
iMEM
iLOADLIB iGETPROC
iSYS0 iSYS1 iSYS2 iSYS3 iSYS4 iSYS5
iSYS6 iSYS7 iSYS8 iSYS9 iSYS10 
#vmc_int
iLIT1 iLIT2 iLITs iCOM iJMPR iJMP iCALL iADR iVAR	
#vmc_opt | OPTIMIZATION WORDS
ioAND ioOR ioXOR		
io+ io- io* io/
io<< io>> io>>>
ioMOD io/MOD io*/ io*>> io<<
io<? io>? io=? io>=? io<=? io<>? ioAN? ioNA?
0
| (0|1|2|3|4|5|6|7) << 'var + @ ! c@ c! w@ w! d@ d!
| call;
| minilit 'var! d! w! c!
| 'var+! d+! w+! c+!
|

::vmstep | ip -- ip'
	d@+ $ff and 3 << 'vmc + @ ex ; | ip val -- ip

::vmrun | to ip -- ip'
	( over <>? vmstep ) ;

::vmreset
	code 8 - 'NOS ! 0 'TOS !
::vmresetr
	code 504 + 0 over ! 'RTOS ! | 512-8 
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
	512 +		| stacks  (64stack cell)
	dup 'code> !
	rot + 'here !
	dup vm!
	;
