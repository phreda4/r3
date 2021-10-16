| r3STACK 2018
| virtual stack
| PHREDA
|--------------------

^r3/lib/trace.r3
^r3/system/r3base.r3

|-------------- buffer code
| -make code for generate code, last step
| -save after modification (inline, folding, etc..)

##bcode * 8192
##bcode> 'bcode

| calculated number
| for constant folding.

##ctecode * 8192
##ctecode> 'ctecode

::codeini
	'bcode 'bcode> d!
	'ctecode 'ctecode> d!
	;

::code!+ | tok --
	bcode> d!+ 'bcode> d! ;

::2code!+ | adr -- adr
	dup 4 - @ code!+ ;

::code<< | --
	-4 'bcode> +! ;

::ncode | -- n
	bcode> 'bcode - 2 >> ;

::cte!+ | val --
	ctecode>
	dup 'ctecode - 8 << 8 or | token hex are generated
	code!+
	!+ 'ctecode> ! ;

|--- virtual stack
##TOS 0
##PSP * 1024
##NOS 'PSP
##RSP * 1024
##RTOS 'RSP

| format cell
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

|-------------------------------
| store 64bits value in stack
#stkvalue * 1024  | 128 of 64bits
#stkvalue# 0

:newval | -- newval
	stkvalue# dup 1 + $7f and 'stkvalue# ! ;

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

|-------- constantes del sistema
#syscons "FREE_MEM" | << no used
#sysconm "[FREE_MEM]" 

#sysregr "rax" "rbx" "rcx" "rdx" "r8"  "r9"  "r10"  "r11"  "r12"  "r13"  "r14"  "r15"  "rdi" "rsi"
#sysregs "eax" "ebx" "ecx" "edx" "r8d" "r9d" "r10d" "r11d" "r12d" "r13d" "r14d" "r15d" "edi" "esi"
#sysregw  "ax"  "bx"  "cx"  "dx" "r8w" "r9w" "r10w" "r11w" "r12w" "r13w" "r14w" "r15w" "di"  "si"
#sysregb  "al"  "bl"  "cl"  "dl" "r8b" "r9b" "r10b" "r11b" "r12b" "r13b" "r14b" "r15b" "dil" "sil"

:list2str | nro 'list -- str
	swap ( 1? 1 - swap >>0 swap ) drop ;

|---- imprime celda
:value 8 >> ;

:mt0 value 3 << 'stkvalue + @ ,d ;	|--	0 nro 	33

:mt1 value 'syscons list2str ,s ;	|--	0 cte	XRES
:mt2 value "str" ,s ,h ;			|--	2 str   "hola"
:mt3 value "w" ,s ,h ;				|--	3 word  'word
:mt4 value "dword[w" ,s ,h "]" ,s ;	|--	4 var   [var]

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

#needword 0

::,celld | nro --
	dup $f and 3 << 'tiposrm + @ ex ;

::,cell | val --
	needword 1? ( drop ,celld ; ) drop
	dup $f and 3 << 'tiposrmq + @ ex ;

::,cellb | nro --
	dup $f and 3 << 'tiposrmb + @ ex ;

::,cellw | nro --
	dup $f and 3 << 'tiposrmw + @ ex ;


:mt4p value "[w" ,s ,h "]" ,s ;	|--	4 var   [var]
:mt6p value "[rbp" ,s
	0? ( drop "]" ,s ; )
	+? ( "+" ,s ) ,d "]" ,s ;


#tiposrmqp mt0 mt1 mt2 mt3 mt4p mt5r mt6p mt7 mt8

::,cellp | val -- : cell print
	dup $f and 3 << 'tiposrmqp + @ ex ;

|---------- ASM
| "add #1,#0" --> add rax,rbx
| "add #1,#0" --> add eax,dword[w1] ... change rax>>eax because dword[]

:,cstackd | adr -- adr
	c@+
	$30 -
	0? ( drop TOS ,celld ; )
	1 - 2 << NOS swap - d@ ,celld ;

:,cstack | adr -- adr
	c@+
	$30 -
	0? ( drop TOS ,cell ; )
	1 - 2 << NOS swap - d@ ,cell ;

:,cstackb | adr -- adr
	c@+
	$30 -
	0? ( drop TOS ,cellb ; )
	1 - 2 << NOS swap - d@ ,cellb ;
	
:,cstackw | adr -- adr
	c@+
	$30 -
	0? ( drop TOS ,cellw ; )
	1 - 2 << NOS swap - d@ ,cellw ;

:,car
	$23 =? ( drop ,cstack ; ) | # qword reg
	$24 =? ( drop ,cstackb ; ) | $ byte reg
	$2A =? ( drop ,cstackd ; ) | * dword reg
	$26 =? ( drop ,cstackw ; ) | & word reg
	$3b =? ( drop ,cr ; ) | ;
	,c ;

::,asm | str --
	( c@+ 1? ,car ) 2drop
	,cr
	0 'needword ! ;

::cell?dword | 'cell --
	$fff and
	$207 $607 bt? ( 1 'needword ! )
	$f and
	4 =? ( 1 'needword ! )
	drop ;

|--------- DEBUG

::,printstka
	"; [ " ,s
	'PSP 8 + ( NOS <=? d@+ 8 >> "%h " ,print ) drop
	'PSP NOS <? ( TOS 8 >> "%h " ,print ) drop
	"] " ,s ;

::,printstk
	"; [ " ,s
	'PSP 8 + ( NOS <=? d@+ ,cellp ,sp ) drop
	'PSP NOS <? ( TOS ,cellp ) drop
	" ] " ,s ; 

::,printvstk
	"| " ,s
	'PSP 8 + ( NOS <=? d@+ ,cellp ,sp ) drop
	'PSP NOS <? ( TOS ,cellp ) drop ; 


|-------------------------------------------
##stacknow

#stks * 512 		| stack of stack 64 levels
#stks> 'stks

#memstk * $fff	| stack memory
#memstk> 'memstk

::stack.cnt | -- cnt
	NOS 'PSP - 3 >> ;


:pstk | adr --
	@+ "sn:" ,s ,d " (" ,s
	@+ 2 >> ( 1? 1 -
		swap d@+ ,cellp ,sp swap ) 2drop
	;

::stk.printstk
	,cr
	'stks ( stks> <?
		"* " ,s d@+ pstk
		,cr ) drop
	,cr
	;
|--------- DEBUG

::stk.push
	memstk> dup stks> !+ 'stks> !
	>a
	stacknow a!+
	NOS 'PSP - a!+
	'PSP 8 + ( NOS <=? d@+ da!+ ) drop
	'PSP NOS <? ( TOS a!+ ) drop
	a> 'memstk> !

|	"; PUSHSTK " ,s stk.printstk |,printstk ,cr
	;

::stk.pop
	-8 'stks> +!
	stks> @ dup 'memstk> !
	>a
	a@+ 'stacknow !
	a@+ 'PSP + 'NOS !
	'PSP 8 + ( NOS <=? da@+ swap d!+ ) drop
	'PSP NOS <? ( a@+ 'TOS ! ) drop

|	"; POPSTK " ,s stk.printstk |,printstk ,cr
	;
	
::stk.drop
	stks> 8 - 'stks <? (
		dup "ERROR stk.drop %h" ,print
		"asm/code.asm" savemem
		)
	'stks> !
	stks> @ 'memstk> !

|	"; DROPSTK " ,s ,cr
	;
|---------- map cells in stack
::stackmap | xx vector -- xx  ; LAST...TOS
	>a 'PSP 16 +
	( NOS <=? dup >r	| xx 'cell
		a> ex
		r> 8 + ) drop
	'PSP NOS >=? ( drop ; ) drop
	'TOS a> ex ;

::stackmap-1 | xx vector -- xx ; LAST..NOS
	>a 'PSP 16 +
	( NOS <=? dup >r	| xx 'cell
		a> ex
		r> 8 + ) drop ;

::stackmap-2 | xx vector -- xx ; LAST..NOS-1
	>a 'PSP 16 +
	( NOS 8 - <=? dup >r	| xx 'cell
		a> ex
		r> 8 + ) drop ;

::stackmap-3 | xx vector -- xx ; LAST..NOS-2
	>a 'PSP 16 +
	( NOS 8 - <=? dup >r	| xx 'cell
		a> ex
		r> 8 + ) drop ;

::stackmap-4 | xx vector -- xx ; LAST..NOS-2
	>a 'PSP 16 +
	( NOS 24 - <=? dup >r	| xx 'cell
		a> ex
		r> 8 + ) drop ;

|-------- registers used
##maskreg 0

:usereg | 'cell --
	@ dup $f and
	5 <>? ( 2drop ; ) drop
	1 swap 8 >> <<
	maskreg or 'maskreg ! ;

::cell.fillreg
	0 'maskreg ! 'usereg stackmap ;

::cell.fillreg2
	0 'maskreg ! 'usereg stackmap-2 ;

::cell.freeACD
	%1101 maskreg or 'maskreg ! ;

::cell.freeD
	%1000 maskreg or 'maskreg ! ;

::setreg | reg --
	1 swap << maskreg or 'maskreg ! ;

::newreg | -- reg
	0 maskreg
	( 1 and? 1 >> swap 1 + swap ) drop
	dup setreg ;

::.dupNEW
	.dup
	cell.fillreg | search unused reg
	newreg 8 << 5 or 'TOS ! ;

::.dupNEWR | maskor --
	.dup
	cell.fillreg | search unused reg
	maskreg or 'maskreg ! | ni A ni C ni D
	newreg 8 << 5 or 'TOS ! ;

|------- convert to normal ; xxx --> ... [rbp-8] rax
#stacknormal * 256

:fillnormal | deep --
	-? ( ";fillnormal -" ,ln drop ; ) |trace drop ; )
	'stacknormal >a
	dup a!+	| stacknow
	dup 2 << a!+
	0? ( drop ; )
	1 - ( 1? 1 - dup neg 8 << 6 or a!+ )
	5 or a!+ ;

|-----------------
|; convert to normal
|-----------------

:cellRBP | deltap 'cell -- deltap
	dup @ $f and 6 <>? ( 2drop ; ) drop | STK?
	over 8 << swap +! ;

:shiftRBP | deltap --	; corre rbp a nuevo lugar
	0? ( drop ; )
	dup neg
	"add rbp," ,s ,d "*8" ,s ,cr
    'cellRBP stackmap drop ;

|-------------------
:reeplaceall | cnt to' to from -- cnt to' to from
	pick3 a> 			| cnt 'from
	( swap 1? 1 - swap
		@+ pick4 =? ( pick3 pick2 4 - ! )
		drop ) 2drop ;

:needreg | from -- from
	dup $f and
	5 =? ( drop ; )
	drop
	newreg 8 << 5 or	| from reg
	"mov " ,s dup ,cell "," ,s swap ,cell ,cr
	;

:cellregu | cnt to' to from -- cnt to'
	reeplaceall
	over a> 4 - !
	swap
	"xor " ,s ,cell "," ,s ,cell ,cr
	;

:cellstku | cnt to' to from -- cnt to'
	needreg
	reeplaceall
	over a> 4 - !
	swap
	"xor " ,s ,cell "," ,s ,cell ,cr
	;

:cellused | cnt to' to from -- cnt to'
	over $f and
	5 =? ( drop cellregu ; )
	6 =? ( drop cellstku ; )
	drop
	"error" ,s ,cr
	;

:cellreg | cnt to' to from -- cnt to'
	over a> 4 - !
	swap
	"mov " ,s ,cell "," ,s ,cell ,cr
	;
:cellstk | cnt to' to from -- cnt to'
	needreg
	over a> 4 - !
	swap
	"mov " ,s ,cell "," ,s ,cell ,cr
	;

:cellcpy | cnt to' to from -- cnt to'
	over =? ( 2drop ; )
	pick3 a>
	( swap 1? 1 - swap
		@+ pick4 =? ( 3drop cellused ; )
		drop ) 2drop
	over $f and
	5 =? ( drop cellreg ; )
	6 =? ( drop cellstk ; )
	drop
	"error" ,s ,cr
	;

:stk.cnv | 'adr --
	cell.fillreg
	@+ stacknow over - shiftrbp 'stacknow !
	TOS NOS 4 + ! 	| TOS in PSP
	@+ 2 >> |	NOS 'PSP - <>? ( ; )	| diferent size
	'PSP 8 + >a
	( 1? 1 - swap
		@+ a@+ cellcpy 		| to from
|		">>" ,s	,printstk ,cr
		swap ) 2drop
	NOS 4 + @ 'TOS !
	;

::stk.conv | --
	"; CONV " ,s ,cr
	stks> 4 - @ stk.cnv ;

::IniStack
	'PSP 'NOS !
	'RSP 'RTOS !
	0 'stkvalue# !
	'stks 'stks> !
	'memstk 'memstk> !
	;

::DeepStack | deep --
	IniStack
	( 1? 1 -
|		dup "%h " .println
		dup PUSH.REG
		) drop ;

::stk.2normal | d --
	'PSP 'NOS !
	'RSP 'RTOS !
	0 'stkvalue# !
	stacknow + dup 'stacknow !
	0? ( drop ; )
	1 - ( 1? 1 - dup neg push.stk )
	push.reg ;
	;

|------- ini stack in ; ... [rbp-8] rax
::stk.start | deep --
	IniStack
	dup 'stacknow !
	0? ( drop ; )
	1 - ( 1? 1 - dup neg push.stk )
	push.reg ;

:stk.setnormal | deep --
	'PSP 'NOS !
	'RSP 'RTOS !
	dup 'stacknow !
	0? ( drop ; )
	1 - ( 1? 1 - dup neg push.stk )
	push.reg ;

::stk.normal | --
	stack.cnt fillnormal
	'stacknormal stk.cnv ;

|------------------------------------
| remove stack constant to register

:allreg | 'cell --
	dup @ $ff and
	5 =? ( 2drop ; ) | es registro
	6 =? ( 2drop ; )
	drop
	newreg 8 << 5 or
	"mov " ,s dup ,cell "," ,s over @ ,cell ,cr
	swap !
	;

::stk.resolve | --
	cell.fillreg
	'allreg stackmap
	;

|--------------------------------
| $0 nro	33
| $1 cte    RESX
| $2 str    s01
| $3 wrd    w32
| $4 [wrd]	[w33]
| $5 re	rax rbx
| $6 stk	[rbp] [rbp+8] ...
| $7 ctem   [FREEMEM]
| $8 anon	anon1
|---------------
|	N nro
|   R register
|	A rax.reg
|	C rcx.reg/Value
|	G Register/Value
|	D rdi
|	S rsi
|   df rdx.free
|
| NOT	R
| +   	RG
| /   	AR           df
| mod	AR -> D      df
| /mod  AR -> AD     df
| */  	AGR          df
| >>  	RC
| *>> 	AGC          df
| /<< 	ARC          df
| !     GG
| @		G
| MOVE	DSC
| normal
| normal-1 (ex)


:needvar32
	cell.fillreg
	newreg 8 << 5 or
	"movsxd " ,s dup ,cell "," ,s over @ ,cell ,cr
	swap ! ;

#cc
|...............
:changereg | nreg 'cell -- nreg
	dup @ NOS 4 - @ <>? ( 2drop ; ) drop
	1 'cc !
	over swap ! ;

:changeregt | nreg 'cell -- nreg
	dup @ NOS @ <>? ( 2drop ; ) drop
	1 'cc !
	over swap ! ;

:freeregtos
	0 'cc !
	.dupnew
 	TOS 'changeregt stackmap-2 drop
	cc 1? ( "mov #0,#1" ,asm ) drop
	.drop ;

|...............
:changeA | nreg 'cell -- nreg
	dup @ $005 <>? ( 2drop ; ) drop
	1 'cc !
	over swap ! ;

:freeA
	0 'cc !
	.dupnew
 	TOS 'changeA stackmap drop
	cc 1? ( "mov #0,rax" ,asm ) drop
	.drop ;


|||||||||||||||||||||||||||||||||||||||||||||||||||
| stk:  a a b -> c a b ..op.. c a'
|...............
:changeR | ndes nreg 'cell -- ndes nreg
	dup @ pick2 <>? ( 2drop ; ) drop
	1 'cc !
	pick2 swap ! ;

:stk.TOSnocpy
	0 'cc !
	.dupnew
 	TOS NOS @ 'changeR stackmap-2 2drop
	cc 1? ( "mov #0,#1" ,asm ) drop
	.drop ;

:stk.NOSnocpy
	0 'cc !
	.dupnew
 	TOS NOS 4 - @ 'changeR stackmap-3 2drop
	cc 1? ( "mov #0,#2" ,asm ) drop
	.drop ;

:stk.NOS2nocpy
	0 'cc !
	.dupnew
 	TOS NOS 8 - @ 'changeR stackmap-4 2drop
	cc 1? ( "mov #0,#3" ,asm ) drop
	.drop ;

|------------------------
:needCR
	"xchg rcx,#0" ,asm
 	-1 TOS 'changeR stackmap-1 2drop
 	TOS $205 'changeR stackmap-1 2drop
 	$205 -1 'changeR stackmap-1 2drop
	$205 'TOS !
	;

:needCU
	TOS
	$ff and 5 =? ( drop needCR ; )
	drop
	.dupnew
	"mov #0,#1;xchg rcx,#0" ,asm
	TOS 'changereg stackmap-1 drop
	.drop
	$205 'TOS ! ;

:TOS>CN | --
	TOS
	$205 =? ( drop ; )
	$ff and 0? ( drop ; )
	drop
	maskreg %100 and? ( drop needCU ; ) drop
	"mov rcx,#0" ,asm
	$205 'TOS ! ;

::freeD
	.dupnew
	0 'cc !
 	TOS $305 'changeR stackmap 2drop
	cc 1? ( "mov #0,rdx" ,asm ) drop
	.drop ;

|--------------------------------------
|--------------------------------------
:bignumber | 'cell --
	dup @ $ff and
	1? ( 2drop ; ) drop
	dup @ 8 >> 3 << 'stkvalue + @
	dup 32 << 32 >>
	=? ( 2drop ; )
	cell.fillreg | search unused reg
	newreg 8 << 5 or | 'cell val reg
	"mov " ,s dup ,cell ",$" ,s swap ,h ,cr
	swap !
	;

::stk.RC | ; rxx RCX/N
	TOS>CN
	NOS @
	$ff and 5 =? ( drop stk.NOSnocpy ; ) drop
	.dupnew
	"mov #0,#2" ,asm
	.swap .rot .drop ;


::stk.AR | ; RAX rxx
	cell.fillreg cell.freeD
	NOS @
	$005 <>? ( freeA "mov rax,#1" ,asm $005 NOS ! ) drop
	stk.NOSnocpy
	TOS $ff and $5 <>? ( freeregtos ) drop
	freeD
	;

::stk.ARC2RAC | ..
	NOS @ $005 =? ( .rot .rot .swap .rot ) drop | RAC->ARC

::stk.ARC | ; RAX rxx RCX/N
	TOS>CN
	NOS 4 - @
	$005 <>? ( freeA "mov rax,#2" ,asm $005 NOS 4 - ! ) drop
	stk.NOS2nocpy
	NOS @
	$ff and 5 <>? ( %1000 .dupnewr "mov #0,#2" ,asm .rot .drop .swap )
	drop
	;

::stk.ARR
	NOS @ $005 =? ( .rot .rot .swap .rot ) drop | RAR->ARR
	NOS 4 - @
	$005 <>? ( freeA "mov rax,#2" ,asm $005 NOS 4 - ! ) drop
	stk.NOS2nocpy
	NOS @
	$ff and 5 <>? ( %1000 .dupnewr "mov #0,#2" ,asm .rot .drop .swap )
	drop
	TOS
	$ff and 5 <>? ( %1000 .dupnewr "mov #0,#1" ,asm .nip )
	drop
	;

:freereg | nroreg mask -- nroreg mask
	pick2 .dupnewr
	0 'cc !
 	TOS pick2 8 << 5 or 'changeR stackmap-1 2drop
	cc 1? ( pick2 push.reg "mov #1,#0" ,asm .drop ) drop
	.drop ;

::stk.freereg | mask --
	0 over ( 1?
		1 and? ( freereg )
		1 >> swap 1 + swap ) 3drop ;

| type cell------
| I $0 nro	33
| I $1 cte	RESX
| I $2 str	s01
| I $3 wrd	w32
| M $4[wrd]	dword[w33]
| R $5 reg	rax rbx
| M $6 stk	[rbp] [rbp+8] ...
| M $7 ctem	[FREEMEM] dword[penx]
| I $8 anon	anon1
|---------------
| R 	rax
| I/R	33 rax
| M/R   [w1] rax
|

:cell2reg | 'cell --
	newreg 8 << 5 or | 'cell reg
	"mov " ,s dup ,cell "," ,s over ,cell ,cr
	swap !
	;

::cellR	| 'cell -- ; only register
	dup d@ $ff and
	5 =? ( 2drop ; )
	drop
	cell2reg ;

::cellI | 'cell -- ; imm or register
	dup d@ $ff and
	4 <? ( 2drop ; )
	5 =? ( 2drop ; )
	7 >? ( 2drop ; )
	drop
	dup cell?dword
    cell2reg ;

::cellM | 'cell -- ; mem or register
	dup d@ $ff and
	4 7 bt? ( 2drop ; )
	drop
	dup cell?dword
    cell2reg ;

::cellA | 'cell -- ; all but see dword
	cell?dword ;

