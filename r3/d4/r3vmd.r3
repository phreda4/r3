| VM token interpreter
| debugger
| PHREDA 2023
|-------------
^r3/d4/r3map.r3

##<<ip	| ip
##<<bp	| breakpoint

##REGA 0 
##REGB 0 

##TOS 0 
##PSP * 1024
##NOS 'PSP
##RSP * 1024
##RTOS 'RSP

::,stack
	'PSP 8 + ( NOS <=? @+ "%d " ,print ) drop
	'PSP NOS <=? ( TOS "%d " ,print ) drop ; 

| token format
| ..............ff token nro
| ffffff.......... adr to src
| ......ffffffff.. value

:.DUP	8 'NOS +! TOS NOS ! ;

::NPUSH	.DUP 'TOS ! ;

:jmpr	dup 8 - @ 24 << 32 >> + ;
:dic@	dup 8 - @ 8 >> $ffffffff and 4 << dic + @ dic>tok ;
:dic@v	dup 8 - @ 8 >> $ffffffff and 4 << dic + 8 + @ 32 >>> fmem + ;

:.blit	dup 8 - @ 40 >>> src + str>anro nip npush ; | big literal, get from src
:.lit	dup 8 - @ 24 << 32 >> npush ;

:.code	dic@ 8 'RTOS +! swap RTOS ! ;
:.acode dic@ npush ;
:.data  dic@v @ npush ; 
:.adata dic@v npush ;

:.str   dup 8 - @ 8 >> $ffffffff and strm + npush ;

:.OVER	.DUP NOS 8 - @ 'TOS ! ;
:.PICK2	.DUP NOS 16 - @ 'TOS ! ;
:.PICK3	.DUP NOS 24 - @ 'TOS ! ;
:.PICK4	.DUP NOS 32 - @ 'TOS ! ;
:.2DUP	.OVER .OVER ;
:.2OVER	.PICK3 .PICK3 ;
::.DROP	NOS @ 'TOS !	|...
:.NIP	-8 'NOS +! ;
::.2DROP	NOS 8 - @ 'TOS ! -16 'NOS +! ;
:.3DROP	NOS 16 - @ 'TOS ! -24 'NOS +! ;
:.4DROP	NOS 24 - @ 'TOS ! -32 'NOS +! ;
:.SWAP	NOS @ TOS NOS ! 'TOS ! ;
:.ROT	TOS NOS 8 - @ 'TOS ! NOS @ NOS 8 - !+ ! ;
:.-ROT	TOS NOS 8 - @+ swap @ 'TOS ! swap NOS 8 - !+ ! ;
:.2SWAP	TOS NOS @ NOS 8 - dup 8 - @ NOS ! @ 'TOS ! NOS 16 - !+ ! ;
	
:.;		RTOS @ nip -8 'RTOS +! ;
:.EX	TOS .DROP 8 'RTOS +! swap RTOS ! ;
:.( 	;
:.)		jmpr ;  | 0=no effect
:.[		jmpr ;
:.]		dup 8 - @ 24 << 32 >> npush ; |**

|--- COND
:.0?	TOS 1? ( drop jmpr ; ) drop ;
:.1?	TOS 0? ( drop jmpr ; ) drop ;
:.+?	TOS -? ( drop jmpr ; ) drop ;
:.-?	TOS +? ( drop jmpr ; ) drop ;
:.=?	NOS @ TOS <>? ( drop jmpr .DROP ; ) drop .DROP ;
:.<?	NOS @ TOS >=? ( drop jmpr .DROP ; ) drop .DROP ;
:.>?	NOS @ TOS <=? ( drop jmpr .DROP ; ) drop .DROP ;
:.<=?	NOS @ TOS >? ( drop jmpr .DROP ; ) drop .DROP ;
:.>=?	NOS @ TOS <? ( drop jmpr .DROP ; ) drop .DROP ;
:.<>?	NOS @ TOS =? ( drop jmpr .DROP ; ) drop .DROP ;
:.A?	NOS @ TOS nand? ( drop jmpr .DROP ; ) drop .DROP ;
:.N?	NOS @ TOS and? ( drop jmpr .DROP ; ) drop .DROP ;
:.B?	NOS 8 - @+ swap @ TOS in? ( drop jmpr .2DROP ; ) drop .2DROP ;

::.AND	NOS @ TOS and .NIP 'TOS ! ;
::.OR	NOS @ TOS or .NIP 'TOS ! ;
::.XOR	NOS @ TOS xor .NIP 'TOS ! ;
::.NAND	NOS @ TOS nand .NIP 'TOS ! ;
::.NOT	TOS not 'TOS ! ;
::.+	NOS @ TOS + .NIP 'TOS ! ;
::.-	NOS @ TOS - .NIP 'TOS ! ;
::.*	NOS @ TOS * .NIP 'TOS ! ;
::./	NOS @ TOS / .NIP 'TOS ! ;
::.*/	NOS 8 - @+ swap @ TOS */ -16 'NOS +! 'TOS ! ;
::.*>>	NOS 8 - @+ swap @ TOS *>> -16 'NOS +! 'TOS ! ;  | need LSB (TOS is 32bits)
::.<</	NOS 8 - @+ swap @ TOS <</ -16 'NOS +! 'TOS ! ;  | need LSB (TOS is 32bits)
::./MOD	NOS @ TOS /mod 'TOS ! NOS ! ;
::.MOD	NOS @ TOS mod .NIP 'TOS ! ;
::.ABS	TOS abs 'TOS ! ;
::.NEG	TOS neg 'TOS ! ;
::.CLZ	TOS clz 'TOS ! ;
::.SQRT	TOS sqrt 'TOS ! ;
::.<<	NOS @ TOS << .NIP 'TOS ! ;     | need LSB (TOS is 32bits)
::.>>	NOS @ TOS >> .NIP 'TOS ! ;     | need LSB (TOS is 32bits)
::.>>>	NOS @ TOS >>> .NIP 'TOS ! ;    | need LSB (TOS is 32bits)

|--- R
:.>R	8 'RTOS +! TOS RTOS ! .DROP ;
:.R>	.DUP RTOS dup @ 'TOS ! 8 - 'RTOS ! ;
:.R@	.DUP RTOS @ 'TOS ! ;

|--- REGA
:.>A	TOS 'REGA ! .DROP ;
:.A>	'REGA @ npush ;
:.A+	TOS 'REGA +! .DROP ;
:.A@	REGA @ npush ;
:.A!	TOS REGA ! .DROP ;
:.A@+	REGA dup 8 + 'REGA ! @ npush ;
:.A!+	TOS REGA dup 8 + 'REGA ! ! .DROP ;
:.cA@	REGA c@ npush ;
:.cA!	TOS REGA c! .DROP ;
:.cA@+	REGA dup 1 + 'REGA ! c@ npush ;
:.cA!+	TOS REGA dup 1 + 'REGA ! c! .DROP ;
:.dA@	REGA d@ npush ;
:.dA!	TOS REGA d! .DROP ;
:.dA@+	REGA dup 4 + 'REGA d! @ npush ;
:.dA!+	TOS REGA dup 4 + 'REGA ! d! .DROP ;

|--- REGB
:.>B	TOS 'REGB ! .DROP ;
:.B>	'REGB @ npush ;
:.B+	TOS 'REGB +! .DROP ;
:.B@	REGB @ npush ;
:.B!	TOS REGB ! .DROP ;
:.B@+	REGB dup 8 + 'REGB ! @ npush ;
:.B!+	TOS REGB dup 8 + 'REGB ! ! .DROP ;
:.cB@	REGB c@ npush ;
:.cB!	TOS REGB c! .DROP ;
:.cB@+	REGB dup 1 + 'REGB ! c@ npush ;
:.cB!+	TOS REGB dup 1 + 'REGB ! c! .DROP ;
:.dB@	REGB d@ npush ;
:.dB!	TOS REGB d! .DROP ;
:.dB@+	REGB dup 4 + 'REGB ! d@ npush ;
:.dB!+	TOS REGB dup 4 + 'REGB ! d! .DROP ;

:.@		TOS @ 'TOS ! ;
:.C@	TOS c@ 'TOS ! ;
:.W@	TOS w@ 'TOS ! ;
:.D@	TOS d@ 'TOS ! ;
:.!		NOS @ TOS ! .2DROP ;
:.C!	NOS @ TOS c! .2DROP ;
:.W!	NOS @ TOS w! .2DROP ;
:.D!	NOS @ TOS d! .2DROP ;
:.+!	NOS @ TOS +! .2DROP ;
:.C+!	NOS @ TOS c+! .2DROP ;
:.W+!	NOS @ TOS w+! .2DROP ;
:.D+!	NOS @ TOS d+! .2DROP ;
:.@+	TOS @ 8 'TOS +! npush ;
:.!+	NOS @ TOS ! .NIP 8 'TOS +! ;
:.C@+	TOS c@ 1 'TOS +! npush ;
:.C!+	NOS @ TOS c! .NIP 1 'TOS +! ;
:.W@+	TOS w@ 2 'TOS +! npush ;
:.W!+	NOS @ TOS w! .NIP 2 'TOS +! ;
:.D@+	TOS d@ 4 'TOS +! npush ;
:.D!+	NOS @ TOS d! .NIP 4 'TOS +! ;

:.MOVE		NOS 8 - @+ swap @ TOS move .3DROP ;
:.MOVE>		NOS 8 - @+ swap @ TOS move> .3DROP ;
:.FILL		NOS 8 - @+ swap @ TOS fill .3DROP ;
:.CMOVE		NOS 8 - @+ swap @ TOS cmove .3DROP ;
:.CMOVE>	NOS 8 - @+ swap @ TOS cmove> .3DROP ;
:.CFILL		NOS 8 - @+ swap @ TOS cfill .3DROP ;
:.DMOVE		NOS 8 - @+ swap @ TOS dmove .3DROP ;
:.DMOVE>	NOS 8 - @+ swap @ TOS dmove> .3DROP ;
:.DFILL		NOS 8 - @+ swap @ TOS dfill .3DROP ;

:.MEM 		fmem> npush ; | last memory used! (mem in base)

:.LOADLIB	TOS loadlib 'TOS ! ;
:.GETPROC	NOS @ TOS getproc .NIP 'TOS ! ;
:.SYS0 TOS sys0 'TOS ! ;
:.SYS1 NOS @ TOS sys1 'TOS ! -8 'NOS +! ;
:.SYS2 NOS 8 - @+ swap @ TOS sys2 'TOS ! -16 'NOS +! ;
:.SYS3 NOS 16 - @+ swap @+ swap @ TOS sys3 'TOS ! -24 'NOS +! ;
:.SYS4 NOS 24 - @+ swap @+ swap @+ swap @ TOS sys4 'TOS ! -32 'NOS +! ;
:.SYS5 NOS 32 - @+ swap @+ swap @+ swap @+ swap @ TOS sys5 'TOS ! -40 'NOS +! ;
:.SYS6 NOS 40 - @+ swap @+ swap @+ swap @+ swap @+ swap @ TOS sys6 'TOS ! -48 'NOS +! ;
:.SYS7 NOS 48 - @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @ TOS sys7 'TOS ! -56 'NOS +! ;
:.SYS8 NOS 56 - @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @ TOS sys8 'TOS ! -64 'NOS +! ;
:.SYS9 NOS 64 - @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @ TOS sys9 'TOS ! -72 'NOS +! ;
:.SYS10 NOS 72 - @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @+ swap @ TOS sys10 'TOS ! -80 'NOS +! ;
	
#vmc
.blit .lit .code .acode .data .adata .str
.; .( .) .[ .] 
.EX .0? .1? .+? .-? 
.<? .>? .=? .>=? .<=? .<>? .A? .N? .B? 
.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP 
.ROT .-ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP 
.>R .R> .R@ 
.AND .OR .XOR .NAND 
.+ .- .* ./ .<< .>> .>>> 
.MOD ./MOD .*/ .*>> .<</ 
.NOT .NEG .ABS .SQRT .CLZ 
.@ .C@ .W@ .D@ 
.@+ .C@+ .W@+ .D@+ 
.! .C! .W! .D! 
.!+ .C!+ .W!+ .D!+ 
.+! .C+! .W+! .D+! 
.>A .A> .A+ .A@ .A! .A@+ .A!+ 
.cA@ .cA! .cA@+ .cA!+ 
.dA@ .dA! .dA@+ .dA!+ 
.>B .B> .B+ .B@ .B! .B@+ .B!+ 
.cB@ .cB! .cB@+ .cB!+ 
.dB@ .dB! .dB@+ .dB!+ 
.MOVE .MOVE> .FILL 
.CMOVE .CMOVE> .CFILL 
.DMOVE .DMOVE> .DFILL 
.MEM
.LOADLIB .GETPROC
.SYS0 .SYS1 .SYS2 .SYS3 .SYS4 .SYS5
.SYS6 .SYS7 .SYS8 .SYS9 .SYS10 
0

| exec word from token
::exncode | tok --
	8 >> $ffffffff and 4 << dic + @ dic>tok | store call word
	8 'RTOS +! 0 RTOS ! 
	( 1?
		@+ $ff and 3 << 'vmc + @ ex
		) drop ;
	
|-------------------------------
::resetvm | --
	'PSP 8 - 'NOS ! 'RSP 'RTOS !
	0 'TOS ! 0 RTOS !
	boot>> 4 << dic + @ dic>tok '<<ip ! | first word to tok adress
	;

::tokenexec | adr+ token -- adr+
	$ff and 3 << 'vmc + @ ex ;

::stepvm
	<<ip 0? ( drop resetvm ; )
|	2dup "<<%h %h" .println |*** DEBUG
	@+ $ff and 3 << 'vmc + @ ex
|	2dup ">>%h %h" .println |*** DEBUG
	'<<ip ! ;

::stepvmn | --
	<<ip 0? ( drop resetvm ; )
	dup @ $ff and 2 <>? ( 2drop stepvm ; ) drop
	dup 8 + swap
	( over <>?
		@+ $ff and 3 << 'vmc + @ ex
		1? ) nip
	'<<ip ! ;

::playvm | --
	<<ip 0? ( drop resetvm ; )
	( <<bp <>?
		@+ $ff and 3 << 'vmc + @ ex
		1? )
	'<<ip ! ;	
	
		