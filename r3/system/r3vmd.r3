| VM  token interpreter
| debugger
| PHREDA 2023
|-------------

##<<ip	| ip
##<<bp	| breakpoint
##code<

|----------

##REGA 0 
##REGB 0 
##TOS 0 
##PSP * 1024
##NOS 'PSP
##RSP * 1024
##RTOS 'RSP

:.DUP		8 'NOS +! TOS NOS ! ;
:.OVER     .DUP NOS 8 - @ 'TOS ! ;
:.PICK2    .DUP NOS 16 - @ 'TOS ! ;
:.PICK3    .DUP NOS 24 - @ 'TOS ! ;
:.PICK4    .DUP NOS 32 - @ 'TOS ! ;
:.2DUP     .OVER .OVER ;
:.2OVER    .PICK3 .PICK3 ;
:.DROP		NOS @ 'TOS !	|...
:.NIP		-8 'NOS +! ;
:.2DROP		NOS 8 - @ 'TOS ! -16 'NOS +! ;
:.3DROP		NOS 16 - @ 'TOS ! -24 'NOS +! ;
:.4DROP		NOS 24 - @ 'TOS ! -32 'NOS +! ;
:.6DROP		NOS 40 - @ 'TOS ! -48 'NOS +! ;
:.SWAP		NOS @ TOS NOS ! 'TOS ! ;
:.ROT		TOS NOS 8 - @ 'TOS ! NOS @ NOS 8 - !+ ! ;
:.2SWAP		TOS NOS @ NOS 8 - dup 8 - @ NOS ! @ 'TOS ! NOS 16 - !+ ! ;

:push.nro	.DUP 'TOS ! ;

:jmpr | adr' -- adrj
	dup 4 - d@ 8 >> + ;
	
:.;		RTOS @ nip -8 'RTOS +! ;
:.EX	TOS .DROP 8 'RTOS +! swap RTOS ! ;
:.( 	;
:.)		dup 4 - d@ 8 >> + ;  | 0=no effect
:.[		jmpr ;
:.]		dup 4 - d@ 8 >> PUSH.NRO ;

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
:.B?	NOS 8 - @+ swap @ TOS bt? ( drop jmpr .2DROP ; ) drop .2DROP ;

:.AND	NOS @ TOS and .NIP 'TOS ! ;
:.OR	NOS @ TOS or .NIP 'TOS ! ;
:.XOR	NOS @ TOS xor .NIP 'TOS ! ;
:.NOT	TOS not 'TOS ! ;
:.+		NOS @ TOS + .NIP 'TOS ! ;
:.-		NOS @ TOS - .NIP 'TOS ! ;
:.*		NOS @ TOS * .NIP 'TOS ! ;
:./		NOS @ TOS / .NIP 'TOS ! ;
:.*/	NOS 8 - @+ swap @ TOS */ -16 'NOS +! 'TOS ! ;
:.*>>	NOS 8 - @+ swap @ TOS *>> -16 'NOS +! 'TOS ! ;  | need LSB (TOS is 32bits)
:.<</	NOS 8 - @+ swap @ TOS <</ -16 'NOS +! 'TOS ! ;  | need LSB (TOS is 32bits)
:./MOD	NOS @ TOS /mod 'TOS ! NOS ! ;
:.MOD	NOS @ TOS mod .NIP 'TOS ! ;
:.ABS	TOS abs 'TOS ! ;
:.NEG	TOS neg 'TOS ! ;
:.CLZ	TOS clz 'TOS ! ;
:.SQRT	TOS sqrt 'TOS ! ;
:.<<	NOS @ TOS << .NIP 'TOS ! ;     | need LSB (TOS is 32bits)
:.>>	NOS @ TOS >> .NIP 'TOS ! ;     | need LSB (TOS is 32bits)
:.>>>	NOS @ TOS >>> .NIP 'TOS ! ;    | need LSB (TOS is 32bits)

|--- R
:.>R	8 'RTOS +! TOS RTOS ! .DROP ;
:.R>	.DUP RTOS dup @ 'TOS ! 8 - 'RTOS ! ;
:.R@	.DUP RTOS @ 'TOS ! ;

|--- REGA
:.>A	TOS 'REGA ! .DROP ;
:.A>	'REGA @ PUSH.NRO ;
:.A+	TOS 'REGA +! .DROP ;
:.A@	REGA @ PUSH.NRO ;
:.A!	TOS REGA ! .DROP ;
:.A@+	REGA dup 8 + 'REGA ! @ PUSH.NRO ;
:.A!+	TOS REGA dup 8 + 'REGA ! ! .DROP ;
:.cA@	REGA c@ PUSH.NRO ;
:.cA!	TOS REGA c! .DROP ;
:.cA@+	REGA dup 1 + 'REGA ! c@ PUSH.NRO ;
:.cA!+	TOS REGA dup 1 + 'REGA ! c! .DROP ;
:.dA@	REGA d@ PUSH.NRO ;
:.dA!	TOS REGA d! .DROP ;
:.dA@+	REGA dup 4 + 'REGA d! @ PUSH.NRO ;
:.dA!+	TOS REGA dup 4 + 'REGA ! d! .DROP ;

|--- REGB
:.>B	TOS 'REGB ! .DROP ;
:.B>	'REGB @ PUSH.NRO ;
:.B+	TOS 'REGB +! .DROP ;
:.B@	REGB @ PUSH.NRO ;
:.B!	TOS REGB ! .DROP ;
:.B@+	REGB dup 8 + 'REGB ! @ PUSH.NRO ;
:.B!+	TOS REGB dup 8 + 'REGB ! ! .DROP ;
:.cB@	REGB c@ PUSH.NRO ;
:.cB!	TOS REGB c! .DROP ;
:.cB@+	REGB dup 1 + 'REGB ! c@ PUSH.NRO ;
:.cB!+	TOS REGB dup 1 + 'REGB ! c! .DROP ;
:.dB@	REGB d@ PUSH.NRO ;
:.dB!	TOS REGB d! .DROP ;
:.dB@+	REGB dup 4 + 'REGB ! d@ PUSH.NRO ;
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
:.@+	TOS @ 8 'TOS +! PUSH.NRO ;
:.!+	NOS @ TOS ! .NIP 8 'TOS +! ;
:.C@+	TOS c@ 1 'TOS +! PUSH.NRO ;
:.C!+	NOS @ TOS c! .NIP 1 'TOS +! ;
:.W@+	TOS w@ 2 'TOS +! PUSH.NRO ;
:.W!+	NOS @ TOS w! .NIP 2 'TOS +! ;
:.D@+	TOS d@ 4 'TOS +! PUSH.NRO ;
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

:.MEM mem push.nro ;

:.LOADLIB TOS loadlib 'TOS ! ;
:.GETPROC NOS @ TOS getproc .NIP 'TOS ! ;
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


|***
#blok
:dic>tok ;
|***

:getbig		blok + @ ;

:.lit	dup 4 - d@ 8 >> getbig push.nro ;
:.word	dup 4 - d@ 8 >> dic>tok @ 8 'RTOS +! swap RTOS ! ;
:.word2	dup 4 - d@ 8 >> dic>tok @ 8 'RTOS +! swap RTOS ! ;
:.adr 
:.adr2 
:.wadr
:.str   dup 4 - d@ 8 >> blok + push.nro ;
:.var   dup 4 - d@ 8 >> dic>tok @ @ push.nro ;
	
#vmc
0 .lit .word .word2 .adr .adr2 .wadr .str .var
.; .( .) .[ .] 
.EX .0? .1? .+? .-? 
.<? .>? .=? .>=? .<=? .<>? .A? .N? .B? 
.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP 
.ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP 
.>R .R> .R@ 
.AND .OR .XOR .+ .- .* ./ .<< .>> .>>> 
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

|-------------------------------
| palabras de interaccion
|-------------------------------
::resetvm | --
	'PSP 'NOS !
	'RSP 'RTOS !
	0 'TOS !
	0 RTOS !
	|<<boot dic>tok @ '<<ip !
	;

::tokenexec | adr+ token -- adr+
	$ff and 3 << 'vmc + @ ex ;

::stepvm
	<<ip 0? ( drop resetvm ; )
	d@+ $ff and 3 << 'vmc + @ ex
	'<<ip ! ;

::stepvmn | --
	<<ip 0? ( drop resetvm ; )
	dup d@ $ff and $c <>? ( 2drop stepvm ; ) drop
	dup 4 + swap
	( over <>?
		d@+ $ff and 3 << 'vmc + @ ex
		1? ) nip
	'<<ip ! ;

::playvm | --
	<<ip 0? ( drop resetvm ; )
	( <<bp <>?
		d@+ $ff and 3 << 'vmc + @ ex
		1? )
	'<<ip ! ;
		