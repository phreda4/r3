| VM r3
| PHREDA 2020
|-------------
^./r3base.r3
^./r3stack.r3

^r3/util/sort.r3

##<<ip	| ip
##<<bp	| breakpoint
##code<

| dicc transform to
| src|code|info|mov  << CODE
| src|<mem>|info|mov << DATA

#memsrc		| mem token>src ; code to src
#memixy		| code to inc x y

#sortinc
#memvars	| mem vars		; real mem vars
#freemem	| free mem
#memaux

#srcnow
#sopx #sopy #sink

:**emu
|	sink 'ink !
|	sopx sopy op
|	xfb> 
	;

:emu**
|	>xfb
|	ink 'sink !
|	opx 'sopx ! opy 'sopy !
	;

|----------

##REGA 0 
##REGB 0 
##TOS 0 
##PSP * 1024
##NOS 'PSP
##RSP * 1024
##RTOS 'RSP

:getbig
	blok + @ ;

:.DUP
	8 'NOS +! TOS NOS ! ;

:PUSH.NRO | nro --
	.DUP 'TOS ! ;

:.OVER     .DUP NOS 8 - @ 'TOS ! ;
:.PICK2    .DUP NOS 16 - @ 'TOS ! ;
:.PICK3    .DUP NOS 24 - @ 'TOS ! ;
:.PICK4    .DUP NOS 32 - @ 'TOS ! ;
:.2DUP     .OVER .OVER ;
:.2OVER    .PICK3 .PICK3 ;
:.DROP		NOS @ 'TOS !	|...
:.NIP		-8 'NOS +! ;
:.2NIP      -16 'NOS +! ;
:.2DROP		NOS 8 - @ 'TOS ! -16 'NOS +! ;
:.3DROP		NOS 16 - @ 'TOS ! -24 'NOS +! ;
:.4DROP		NOS 24 - @ 'TOS ! -32 'NOS +! ;
:.6DROP		NOS 40 - @ 'TOS ! -48 'NOS +! ;
:.SWAP		NOS @ TOS NOS ! 'TOS ! ;
:.ROT		TOS NOS 8 - @ 'TOS ! NOS @ NOS 8 - !+ ! ;
:.2SWAP		TOS NOS @ NOS 8 - dup 8 - @ NOS ! @ 'TOS ! NOS 16 - !+ ! ;

:.dec2	dup 4 - d@ 8 >> getbig push.nro ;
:.bin2	dup 4 - d@ 8 >> getbig push.nro ;
:.hex2	dup 4 - d@ 8 >> getbig push.nro ;
:.fix2	dup 4 - d@ 8 >> getbig push.nro ;
:.wor2 4 - d@ 8 >> dic>tok @ ; | tail call

:.dec	dup 4 - d@ 8 >> push.nro ;
:.hex   dup 4 - d@ 8 >> push.nro ;
:.bin   dup 4 - d@ 8 >> push.nro ;
:.fix   dup 4 - d@ 8 >> push.nro ;
:.str   dup 4 - d@ 8 >> blok + push.nro ;
:.wor	dup 4 - d@ 8 >> dic>tok @ 8 'RTOS +! swap RTOS ! ;
:.var   dup 4 - d@ 8 >> dic>tok @ @ push.nro ;
:.dwor	dup 4 - d@ 8 >> dic>tok @ push.nro ;
:.dvar  dup 4 - d@ 8 >> dic>tok @ push.nro ;

:.;		RTOS @ nip -8 'RTOS +! ;

:.EX	TOS .DROP 8 'RTOS +! swap RTOS ! ;

:jmpr | adr' -- adrj
	dup 4 - d@ 8 >> + ;

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
:.B?	NOS 8 - @ NOS @ TOS bt? ( drop jmpr .2DROP ; ) drop .2DROP ;


:.AND		NOS @ TOS and .NIP 'TOS ! ;
:.OR		NOS @ TOS or .NIP 'TOS ! ;
:.XOR		NOS @ TOS xor .NIP 'TOS ! ;
:.NOT		TOS not 'TOS ! ;
:.+			NOS @ TOS + .NIP 'TOS ! ;
:.-			NOS @ TOS - .NIP 'TOS ! ;
:.*			NOS @ TOS * .NIP 'TOS ! ;
:./			NOS @ TOS / .NIP 'TOS ! ;
:.*/		NOS 8 - @ NOS @ TOS */ .2NIP 'TOS ! ;
:.*>>		NOS 8 - @ NOS @ TOS *>> .2NIP 'TOS ! ;  | need LSB (TOS is 32bits)
:.<</		NOS 8 - @ NOS @ TOS <</ .2NIP 'TOS ! ;  | need LSB (TOS is 32bits)
:./MOD		NOS @ TOS /mod 'TOS ! NOS ! ;
:.MOD		NOS @ TOS mod .NIP 'TOS ! ;
:.ABS		TOS abs 'TOS ! ;
:.NEG		TOS neg 'TOS ! ;
:.CLZ		TOS clz 'TOS ! ;
:.SQRT		TOS sqrt 'TOS ! ;
:.<<		NOS @ TOS << .NIP 'TOS ! ;     | need LSB (TOS is 32bits)
:.>>		NOS @ TOS >> .NIP 'TOS ! ;     | need LSB (TOS is 32bits)
:.>>>		NOS @ TOS >>> .NIP 'TOS ! ;    | need LSB (TOS is 32bits)

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

:.MOVE		NOS 8 - @ NOS @ TOS move .3DROP ;
:.MOVE>		NOS 8 - @ NOS @ TOS move> .3DROP ;
:.FILL		NOS 8 - @ NOS @ TOS fill .3DROP ;
:.CMOVE		NOS 8 - @ NOS @ TOS cmove .3DROP ;
:.CMOVE>	NOS 8 - @ NOS @ TOS cmove> .3DROP ;
:.CFILL		NOS 8 - @ NOS @ TOS cfill .3DROP ;
:.DMOVE		NOS 8 - @ NOS @ TOS dmove .3DROP ;
:.DMOVE>	NOS 8 - @ NOS @ TOS dmove> .3DROP ;
:.DFILL		NOS 8 - @ NOS @ TOS dfill .3DROP ;

:.MEM mem push.nro ;

:.LOADLIB TOS loadlib .DROP 'TOS ! ;
:.GETPROC NOS @ TOS getproc .NIP 'TOS ! ;
:.SYS0 TOS sys0 'TOS ! ;
:.SYS1 NOS @ TOS sys0 'TOS ! ;
:.SYS2 NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
:.SYS3 NOS 16 - @ NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
:.SYS4 NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
:.SYS5 NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
:.SYS6 NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
:.SYS7 NOS 48 - @ NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
:.SYS8 NOS 56 - @ NOS 48 - @ NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
:.SYS9 NOS 64 - @ NOS 56 - @ NOS 48 - @ NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
:.SYS10 NOS 72 - @ NOS 64 - @ NOS 56 - @ NOS 48 - @ NOS 40 - @ NOS 32 - @ NOS 24 - @ NOS 16 - @ NOS 8 - @ NOS @ TOS sys0 'TOS ! ;
	
#vmc
0 .dec2 .bin2 .hex2 .fix2 0 .wor2 .dec .bin .hex .fix .str .wor .var .dwor .dvar
.; .( .) .[ .] 
.EX .0? .1? .+? .-? 
.<? .>? .=? .>=? .<=? .<>? .A? .N? .B? 
.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP 
.ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP 
.>R .R> .R@ 
.AND .OR .XOR 
.+ .- .* ./ 
.<< .>> .>>> 
.MOD ./MOD .*/ .*>> .<</ 
.NOT .NEG .ABS .SQRT .CLZ 
.@ .C@ .W@ .D@ 
.@+ .C@+ .W@+ .D@+ 
.! .C! .W! .D! 
.!+ .C!+ .W!+ .D!+ 
.+! .C+! .W+! .D+! 
.>A .A> .A+ 
.A@ .A! .A@+ .A!+ 
.cA@ .cA! .cA@+ .cA!+ 
.dA@ .dA! .dA@+ .dA!+ 
.>B .B> .B+ 
.B@ .B! .B@+ .B!+ 
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

|------ for locate include from src
:sortincludes
	here 'sortinc !
	'inc >a
	0 ( cntinc <?
		8 a+ a@+ ,q
		dup ,q
		1 + ) drop
	cntinc 1 + sortinc shellsort ;

::findinclude | adr -- nro
	sortinc >a
	0 ( cntinc <?
		over a@+ <? ( 3drop a> 16 - @ ; ) drop
		8 a+
		1 + ) 2drop
	a> 8 - @ ;

|---------- generate include/position in src from tokens

#posnow

:getsrcxyinc | adr -- adr ; incremental
	posnow
	( over <? c@+
		1 'sopx +!
		9 =? ( 3 'sopx +! )
		13 =? ( 1 'sopy +! 0 'sopx ! )
		drop ) drop
	dup 'posnow ! ;

:getsrcxy | adr -- adr
	0 'sopx ! 0 'sopy !
	sink 3 << 'inc + 8 + @ | start of include
	'posnow !
	getsrcxyinc ;

:>>next
	dup c@
	34 =? ( drop 1 + >>" trim ; ) | next in string
	drop
	>>sp trim
	( dup c@ $7c =? drop >>cr trim ) | avoid comments
	drop
	;

|---------- PREPARE CODE FOR RUN
:tokvalue | 'adr tok -- 'adr tok value
	over 4 - d@ 8 >> ;

:valstr
	( c@+ 1?
		34 =? ( drop c@+ 34 <>? ( 2drop ; ) )
		,c ) 2drop ;

:blwhile? | -- fl
	tokvalue 3 << blok + d@ $10000000 and ;

:blini | -- end?
	tokvalue 3 << blok + d@  $fffffff and 2 << code + ;

:blend | -- end?
	tokvalue 3 << blok + 4 + d@ 2 << code + ;

:patch! | adr tok value -- adr tok
	pick2 4 - dup d@ $ff and rot or swap d! ;

:transfcond | adr' tok -- adr' tok | ; 22..34
	blend pick2 - 4 + 8 << patch! ;

:trwor
	over d@ $ff and
	16 <>? ( drop ; ) drop
	over 4 - dup d@ $ff not and 6 or swap ! | call tail call
	;

:tr( | adr' tok -- adr' tok
	0 patch! ;	| not need but..

:tr) | adr' tok -- adr' tok
	blwhile? 0? ( drop 0 patch! ; ) drop
	blini pick2 - 4 + 8 << patch! ;

:tr[ | adr' tok -- adr' tok
	blend pick2 - 8 << patch! ;

:tr] | adr' tok -- adr' tok
	blini 8 << patch! ;

|---  transform 1 use Block and release

:transform1 | adr' -- adr'
	srcnow
	getsrcxyinc
	sopy sopx 12 << or sink 24 << or
	pick2 code - memixy + !
	over code - memsrc + !
	srcnow >>next 'srcnow !
	d@+ $ff and
|	12 =? ( trwor ) | call
	17 =? ( tr( )
	18 =? ( tr) )
	19 =? ( tr[ )
	20 =? ( tr] )
	22 34 bt? ( transfcond )
	drop ;

:code2mem1 | adr -- adr
	dup 16 + @ 1 and? ( drop ; ) drop	| code only
	"1" .println
	dup @ findinclude 'sink ! | include
	"2" .println
	dup @ >>next getsrcxy 'srcnow !
	"3" .println
	dup adr>toklenreal
	"4" .println
	( 1? 1 - swap
		transform1
		swap ) 2drop ;

:sameinc | adr -- adr
	dup @
	dup findinclude
	sink =? ( drop >>next 'srcnow ! ; )
	|---first word in include

	'sink !
	>>next getsrcxy 'srcnow !
	;

:code2mem1 | adr -- adr
	dup 16 + @ 1 and? ( drop ; ) drop	| code only
	sameinc
	dup adr>toklenreal
	( 1? 1 - swap
		transform1
		swap ) 2drop ;

|---  transform 2 need memory

:storebig | adr tok type big -- adr' tok
	memaux !
	6 -
	memaux blok - 8 << or pick2 4 - d!
	8 'memaux +!
	;

:transflit | adr' tok -- adr' tok | ; 7..10
	tokvalue src +		| string in src
	dup isNro 0? ( 1 + ) 6 + | 7-dec,8-bin,9-hex,10-fix ..
	swap str>anro nip
	dup 40 << 40 >> <>? ( storebig ; )
	8 << or pick2 4 - d! ;

:trstr
	mark
	memaux 'here !
	over 4 - d@ 8 >> src + valstr 0 ,c
	memaux blok - 8 << 11 or pick2 4 - d!
	here 'memaux !
	empty
	;

:transform2 | adr' -- adr'
	d@+ $ff and
	7 10 bt? ( transflit )
	11 =? ( trstr ) | str
	drop ;

:code2mem2 | adr -- adr
	dup 16 + @ 1 and? ( drop ; ) drop	| code only
	dup adr>toklenreal
	( 1? 1 - swap
		transform2
		swap ) 2drop ;

|--------
::code2run
	-1 'sink ! | include nr
	dicc ( dicc> <?
		code2mem1
		32 + ) drop
	blok 'memaux !
	dicc ( dicc> <?
		code2mem2
		32 + ) drop	
	;

|------- IMM CODE
:transformimm
	@+ $ff and
	7 10 bt? ( transflit )
	11 =? ( trstr ) | str
|	12 =? ( trwor ) | call
	17 =? ( tr( )
	18 =? ( tr) )
	19 =? ( tr[ )
	20 =? ( tr] )
	22 34 bt? ( transfcond )
	drop ;

::immcode2run | adr --
	0 'nbloques !	| reuse blocks
	( code> <?
		transformimm
	 	) drop ;

|------ PREPARE DATA FOR RUN
#gmem ',q

:memlit
	tokvalue src + str>anro nip gmem ex ;

:resbyte | reserve memory
	'here +! ;

:memstr | store string
	over 4 - d@ 8 >> src + valstr 0 ,c ;

:memwor
	tokvalue dic>tok @ ,q ;

:getvarmem
	d@+ $ff and
	7 10 bt? ( memlit )
	11 =? ( memstr ) | str
	12 15 bt? ( memwor )
	17 =? ( ',c 'gmem ! )	| (
	18 =? ( ',q 'gmem ! )	| )
	19 =? ( ', 'gmem ! )	| [
	20 =? ( ',q 'gmem ! )	| ]
	58 =? ( 'resbyte 'gmem ! ) | *
	drop
	;

:var2mem | adr -- adr
	dup 16 + @ 1 nand? ( drop ; ) drop	| data only
	dup adr>toklen
	here pick3 4 + !	| save mem place
	0? ( ,q drop ; )
	',q 'gmem ! 			| save dword default
	( 1? 1 - swap
		getvarmem
		swap ) 2drop ;

::data2mem
	dicc ( dicc> <?
		var2mem
		32 + ) drop ;


|------ PREPARE 2 RUN
::vm2run
|	iniXFB
	sortincludes
	here dup 'memsrc !			| array code to source
	code> code - + 'memixy !	| array code to include/X/Y
	code> code - 1 << 'here +!
	code2run
	here 'memvars !
	data2mem
	here 'freemem !
	;

::code2src | code -- src
	code - memsrc + @ ;

::code2ixy | code -- ixy
	code - memixy + @ ;

:backsrc | adr -- adr
	4 - ( dup @ 0? drop 4 - ) drop ;

::src2code | src incnow -- code
	memixy
	( @+ 24 >> pick2 <>?
		drop ) drop nip
	4 - memixy - memsrc + |	first code from include
	( @+ ( 0? drop @+ )
		pick2 <=? drop ) drop	| search src
	nip
	backsrc backsrc	| back 2
	memsrc - code +
	;

::src2word | src incnow -- word
	src2code
	dicc>
	( 16 - dicc >=?
		dup 4 + @ pick2 <? (  drop nip dicc - 4 >> ; )
		drop ) 2drop
	0 ;

::breakpoint | cursor --
	src2code '<<bp !
	;

::dumpmm
	|cls home
	|$ff00 'ink !
	|memsrc dumpd 
	;

|-------------------------------
| palabras de interaccion
|-------------------------------

::resetvm | --
	'PSP 'NOS !
	'RSP 'RTOS !
	0 'TOS !
	0 RTOS !
	<<boot '<<ip !
	**emu
|	$ffffff 'ink !
|	cls
	emu**
	;

::tokenexec | adr+ token -- adr+
	$ff and 2 << 'vmc + @ ex ;

::stepvm
	<<ip 0? ( drop resetvm ; )
	**emu
	@+ $ff and 2 << 'vmc + @ ex
	'<<ip !
	emu**
	;

::stepvmn | --
	<<ip 0? ( drop resetvm ; )
	dup @ $ff and $c <>? ( 2drop stepvm ; ) drop
	**emu
	dup 4 + swap
	( over <>?
		@+ $ff and 2 << 'vmc + @ ex
		1? ) nip
	'<<ip !
	emu** ;

::playvm | --
	<<ip 0? ( drop resetvm ; )
	**emu
	( <<bp <>?
		@+ $ff and 2 << 'vmc + @ ex
		1? )
	'<<ip !
	emu** ;

::stackprintvm
	" D) " .print
	'PSP 16 + ( NOS <=?
		@+ "%d " .print
		) drop
	'PSP NOS <? (
		TOS "%d " .print
		) drop
	cr
	" R) " .print
	'RSP 8 +
	( RTOS <=?
		@+ "%h " .print
		) drop 	;

:printpila
	@ " %d " .print ;

::showvstack
	NOS 16 +
	NOS TOS over 8 + ! 'PSP - 3 >>
	14 min
	( 1? swap 8 -
		cols 20 - rows 1 - pick3 - .at
		dup printpila
		swap 1 - ) 2drop

	RTOS 8 +
	RTOS 'RSP - 3 >>
	14 min
	( 1? swap 8 -
		cols 3 - rows 1 - pick3 - .at
		" r " .print
|		dup printpila
		swap 1 - ) 2drop
|	cols 34 - rows 1 - gotoxy
|	regb rega " A:%h B:%h" .print

	;
