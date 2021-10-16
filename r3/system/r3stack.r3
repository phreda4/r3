| r3STACK 2018
| virtual stack
| PHREDA
|--------------------

^r3/lib/trace.r3
^r3/system/r3base.r3

|-------------- buffer code
| -make code for generate code, last step
| -save after modification (inline, folding, etc..)
| -all tokencodes are 32bits

##bcode * 8192
##bcode> 'bcode

| memory space for store numbers
| for constant folding.

##ctecode * 8192
##ctecode> 'ctecode

::codeini
	'bcode 'bcode> d!
	'ctecode 'ctecode> d!
	;

| compile a token
::code!+ | tok --		
	bcode> d!+ 'bcode> d! ;

| compile the same token from source
::2code!+ | adr -- adr
	dup 4 - d@ code!+ ;

| back one token
::code<< | --
	-4 'bcode> +! ;

| size of code
::ncode | -- n
	bcode> 'bcode - 2 >> ;

| store a literal number (for calculate)
::cte!+ | val --
	ctecode>
	dup 'ctecode - 8 << 8 or | token hex are generated
	code!+
	!+ 'ctecode> ! ;

|--- virtual stack
| TOS in var
| format cell 32 bits
| type-- $0000000f
| $0 nro	33
| $1 cte    XRES
| $2 str    s01
| $3 wrd    w32
| $4 [wrd]	[w33]
| $5 reg	rax rbx
| $6 stk	[rbp] [rbp+8] ...

| $7 [cte]	[FREEMEM]
| $8 anon
 

##TOS 0
##PSP * 1024
##NOS 'PSP
##RSP * 1024
##RTOS 'RSP

|-------------------------------
| store 64bits value for stack
#stkvalue * 2048  | 256 of 64bits
#stkvalue# 0

:newval | -- newval
	stkvalue# dup 1 + $ff and 'stkvalue# ! ;

|-------------------------------
::.DUP		
	4 'NOS +! TOS NOS ! ;

::PUSH.NRO | nro --
	.DUP
	newval dup 8 << 'TOS !
	3 << 'stkvalue + ! ;

::TOS.NRO! | nro --
	TOS	8 >> 3 << 'stkvalue + ! ;

::PUSH.CTE	| ncte --
	.DUP 8 << 1 or 'TOS ! ;
::PUSH.STR	| vstr --
	.DUP 8 << 2 or 'TOS ! ;
::PUSH.WRD	| vwor --
	.DUP 8 << 3 or 'TOS ! ;
::PUSH.VAR	| var --
	.DUP 8 << 4 or 'TOS ! ;
::PUSH.REG	| reg --
	.DUP 8 << 5 or 'TOS ! ;
::PUSH.STK	| stk --
	.DUP 8 << 6 or 'TOS ! ;
::PUSH.CTEM	| ncte --
	.DUP 8 << 7 or 'TOS ! ;
::PUSH.ANO	| anon --
	.DUP 8 << 8 or 'TOS ! ;

::.POP | -- nro
	TOS NOS d@ 'TOS ! -4 'NOS +! ;

:STKval	8 >> 3 << 'stkvalue + @ ;

:aTOS	TOS 8 >> 3 << 'stkvalue + ;
:aNOS	NOS d@ 8 >> 3 << 'stkvalue + ;

::vTOS	TOS STKval ;
::vNOS	NOS d@ STKval ;
:vPK2	NOS 4 - d@ STKval ;
:vPK3	NOS 8 - d@ STKval ;
:vPK4	NOS 12 - d@ STKval ;
:vPK5	NOS 16 - d@ STKval ;

::.OVER     .DUP NOS 4 - d@ 'TOS ! ;
::.PICK2    .DUP NOS 8 - d@ 'TOS ! ;
::.PICK3    .DUP NOS 12 - d@ 'TOS ! ;
::.PICK4    .DUP NOS 16 - d@ 'TOS ! ;
::.2DUP     .OVER .OVER ;
::.2OVER    .PICK3 .PICK3 ;
::.DROP		NOS d@ 'TOS !	|...
::.NIP      -4 'NOS +! ;
::.2NIP		-8 'NOS +! ;
::.2DROP	NOS 4 - d@ 'TOS ! -8 'NOS +! ;
::.3DROP	NOS 8 - d@ 'TOS ! -12 'NOS +! ;
::.4DROP	NOS 12 - d@ 'TOS ! -16 'NOS +! ;
::.5DROP	NOS 16 - d@ 'TOS ! -20 'NOS +! ;
::.6DROP	NOS 20 - d@ 'TOS ! -24 'NOS +! ;
::.7DROP	NOS 24 - d@ 'TOS ! -28 'NOS +! ;
::.8DROP	NOS 28 - d@ 'TOS ! -32 'NOS +! ;
::.9DROP	NOS 32 - d@ 'TOS ! -36 'NOS +! ;
::.10DROP	NOS 36 - d@ 'TOS ! -40 'NOS +! ;

::.SWAP     NOS d@ TOS NOS d! 'TOS ! ;
::.ROT      TOS NOS 4 - d@ 'TOS ! NOS d@ NOS 4 - d!+ d! ;
::.2SWAP    TOS NOS d@ NOS 4 - dup 4 - d@ NOS d! d@ 'TOS ! NOS 8 - d!+ d! ;

::.>R		4 'RTOS +! TOS RTOS d! .DROP ;
::.R>		.DUP RTOS dup d@ 'TOS ! 4 - 'RTOS d! ;
::.R@		.DUP RTOS d@ 'TOS ! ;

::.AND		vNOS vTOS and .NIP TOS.NRO! ;
::.OR		vNOS vTOS or .NIP TOS.NRO! ;
::.XOR		vNOS vTOS xor .NIP TOS.NRO! ;
::.NOT		vTOS not TOS.NRO! ;
::.+		vNOS vTOS + .NIP TOS.NRO! ;
::.-		vNOS vTOS - .NIP TOS.NRO! ;
::.*		vNOS vTOS * .NIP TOS.NRO! ;
::./		vNOS vTOS / .NIP TOS.NRO! ;
::.*/		vPK2 vNOS vTOS */ .2NIP TOS.NRO! ;
::.*>>		vPK2 vNOS vTOS *>> .2NIP TOS.NRO! ;
::.<</		vPK2 vNOS vTOS <</ .2NIP TOS.NRO! ;
::./MOD		vNOS vTOS /mod swap .2DROP PUSH.NRO PUSH.NRO ;
::.MOD		vNOS vTOS mod .NIP TOS.NRO! ;
::.ABS		vTOS abs TOS.NRO! ;
::.NEG		vTOS neg TOS.NRO! ;
::.CLZ		vTOS clz TOS.NRO! ;
::.SQRT		vTOS sqrt TOS.NRO! ;
::.<<		vNOS vTOS << .NIP TOS.NRO! ;
::.>>		vNOS vTOS >> .NIP TOS.NRO! ;
::.>>>		vNOS vTOS >>> .NIP TOS.NRO! ;

|-------- system constan (now have only 1)
#syscons "FREE_MEM" | << no used
#sysconm "[FREE_MEM]" 

|-------- registers in 64,32,16,8 bits
#sysregr "rax" "rbx" "rcx" "rdx" "r8"  "r9"  "r10"  "r11"  "r12"  "r13"  "r14"  "r15"  "rdi" "rsi"
#sysregs "eax" "ebx" "ecx" "edx" "r8d" "r9d" "r10d" "r11d" "r12d" "r13d" "r14d" "r15d" "edi" "esi"
#sysregw  "ax"  "bx"  "cx"  "dx" "r8w" "r9w" "r10w" "r11w" "r12w" "r13w" "r14w" "r15w" "di"  "si"
#sysregb  "al"  "bl"  "cl"  "dl" "r8b" "r9b" "r10b" "r11b" "r12b" "r13b" "r14b" "r15b" "dil" "sil"

:list2str | nro 'list -- str
	swap ( 1? 1 - swap >>0 swap ) drop ;

|---- print cell stack
:value 8 >> ;

:mt0 value 3 << 'stkvalue + @ ,d ;	|--	0 nro 	33

:mt1 value 'syscons list2str ,s ;	|--	0 cte	XRES
:mt2 value "str" ,s ,h ;			|--	2 str   "hola"
:mt3 value "w" ,s ,h ;				|--	3 word  'word
:mt4 value "qword[w" ,s ,h "]" ,s ;	|--	4 var   [var]

:mt5 value 'sysregs list2str ,s ;	|-- 5 reg 	eax
:mt5b value 'sysregb list2str ,s ;	|-- 5 regb 	al
:mt5w value 'sysregw list2str ,s ;	|-- 5 regw 	ax
:mt5r value 'sysregr list2str ,s ;	|-- 5 reg 	rax

:mt6 value "qword[rbp" ,s
	0? ( drop "]" ,s ; )
	+? ( "+" ,s ) ,d "*8]" ,s ;

:mt7 value 'sysconm list2str ,s ;	|--	7 ctem [FREE_MEM]
:mt8 value "anon" ,s ,h ;			|--	8 anon

#tiposrm mt0 mt1 mt2 mt3 mt4 mt5 mt6 mt7 mt8
#tiposrmb mt0 mt1 mt2 mt3 mt4 mt5b mt6 mt7 mt8
#tiposrmw mt0 mt1 mt2 mt3 mt4 mt5w mt6 mt7 mt8
#tiposrmq mt0 mt1 mt2 mt3 mt4 mt5r mt6 mt7 mt8

|--- cell like qword (64bits)
::,cell | val --
	dup $f and 3 << 'tiposrmq + @ ex ;

|--- cell like dword (32bits)
::,celld | nro --
	dup $f and 3 << 'tiposrm + @ ex ;

|--- cell like word (16bits)
::,cellw | nro --
	dup $f and 3 << 'tiposrmw + @ ex ;

|--- cell like byte (8bits)
::,cellb | nro --
	dup $f and 3 << 'tiposrmb + @ ex ;

|---------- ASM
| - generate text for assembly
| - reeplace with stack values/register/memory
| "add #1,#0" --> add rax,rbx
| "add #1,#0" --> add eax,dword[w1] ... change rax>>eax because dword[]

:,cstackd | adr -- adr
	c@+ $30 -
	0? ( drop TOS ,celld ; )
	1 - 2 << NOS swap - d@ ,celld ;

:,cstack | adr -- adr
	c@+ $30 -
	0? ( drop TOS ,cell ; )
	1 - 2 << NOS swap - d@ ,cell ;

:,cstackb | adr -- adr
	c@+ $30 -
	0? ( drop TOS ,cellb ; )
	1 - 2 << NOS swap - d@ ,cellb ;
	
:,cstackw | adr -- adr
	c@+ $30 -
	0? ( drop TOS ,cellw ; )
	1 - 2 << NOS swap - d@ ,cellw ;

:,car
	$23 =? ( drop ,cstack ; ) | # qword reg
	$24 =? ( drop ,cstackb ; ) | $ byte reg
	$2A =? ( drop ,cstackd ; ) | * dword reg
	$26 =? ( drop ,cstackw ; ) | & word reg
	$3b =? ( drop ,cr ; ) | ;
	,c ;

|--------- MAIN WORD
::,asm | str --
	( c@+ 1? ,car ) 2drop
	,cr ;

|--------- DEBUG, print the stack
::,printstka
	"; [ " ,s
	'PSP 8 + ( NOS <=? d@+ 8 >> "%h " ,print ) drop
	'PSP NOS <? ( TOS 8 >> "%h " ,print ) drop
	"] " ,s ;

::,printstk
	"; [ " ,s
	'PSP 8 + ( NOS <=? d@+ ,cell ,sp ) drop
	'PSP NOS <? ( TOS ,cell ) drop
	" ] " ,s ; 


|----------- STK manipulation
#stacknow | <--where is TOS

::,printvstk
	stacknow "%d " .print 
	"D) " ,s
	'PSP 8 + ( NOS <=? d@+ ,cell ,sp ) drop
	'PSP NOS <? ( TOS ,cell ) drop ; 

::stk.reset
	'PSP 'NOS !
	'RSP 'RTOS !
	0 'stkvalue# !
	;
	
|------- ini stack in ; ... [rbp-8] rax
::stk.start | deep --
	stk.reset
	dup 'stacknow !
	0? ( drop ; )
	1 - ( 1? 1 - dup neg push.stk )
	push.reg ;

|------- convert to normal
::stk.normal 
	;
