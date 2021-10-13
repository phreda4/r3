| generate amd64 code
| OPT 1 GENERATOR
| - The stack is virtual
| PHREDA 2020
|-------------
^./r3base.r3
^./r3stack.r3

#stbl * 40 | 10 niveles ** falta inicializar si hay varias ejecuciones
#stbl> 'stbl

#nblock 0

:pushbl | -- block
	nblock
	dup 1 + 'nblock !
	dup stbl> d!+ 'stbl> ! ;

:popbl | -- block
	-4 'stbl> +! stbl> d@ ;

#lastdircode 0 | ultima direccion de codigo

:codtok	dup 'lastdircode ! ;

|--- @@
::getval | a -- a v
	dup 4 - d@ 8 >>> ;

::getcte | a -- a v
	dup 4 - d@ 8 >>> src + str>anro nip ;

::getcte2 | a -- a v
	dup 4 - d@ 8 >>> 'ctecode + @ ;

|--- END
:g;
	dup 8 - d@ $ff and
	12 =? ( drop ; ) | tail call  call..ret?
	21 =? ( drop ; ) | tail call  EX
	drop
|	stk.normal
	"ret" ,ln ;

|--- IF/WHILE

::getiw | v -- iw
    3 << blok + d@ $10000000 and ;

:g(
|	stk.resolve
|	stk.push
	getval getiw 0? ( pushbl 2drop ; ) drop
	pushbl
	"_i%h:" ,print ,cr ;		| while

:g)
	dup 8 - d@ $ff and
|	16 <>? ( stk.conv ) | tail call  call..ret?
	drop

|	stk.pop
	getval getiw
	popbl swap
	1? ( over "jmp _i%h" ,print ,cr ) drop	| while
	"_o%h:" ,print ,cr ;

:?? | -- nblock
	getval getiw
	0? ( drop nblock ; ) drop
|	stk.drop stk.push
	stbl> 4 - @ ;

|---
:g[		|  this disapear when pre process the word
	pushbl
	dup "jmp ja%h" ,print ,cr
	"anon%h:" ,print ,cr
	;
:g]		|  this disapear when pre process the word
	popbl
	dup "ja%h:" ,print ,cr
	push.ano
	;

:gEX
	'TOS cellR
	"mov rcx,#0" ,asm .drop
	stk.normal	| normalize

   	lastdircode dic>du drop stk.2normal | exit stack calc

	dup d@ $ff and
	16 <>? ( drop "call rcx" ,ln ; ) drop
	"jmp rcx" ,ln ;

:g0?
	'TOS cellR
	"or #0,#0" ,asm
	?? "jnz _o%h" ,print ,cr ;

:g1?
	'TOS cellR
	"or #0,#0" ,asm
	?? "jz _o%h" ,print ,cr ;

:g+?
	'TOS cellR
	"or #0,#0" ,asm
	?? "js _o%h" ,print ,cr ;

:g-?
	'TOS cellR
	"or #0,#0" ,asm
	?? "jns _o%h" ,print ,cr ;

:g<?
	'TOS cellA
	NOS cellR
	"cmp #1,#0" ,asm
	.drop
	?? "jge _o%h" ,print ,cr ;

:g>?
	'TOS cellA
	NOS cellR
	"cmp #1,#0" ,asm
	.drop
	?? "jle _o%h" ,print ,cr ;

:g=?
	'TOS cellA
	NOS cellR
	"cmp #1,#0" ,asm
	.drop
	?? "jne _o%h" ,print ,cr ;

:g>=?
	'TOS cellA
	NOS cellR
	"cmp #1,#0" ,asm
	.drop
	?? "jl _o%h" ,print ,cr ;

:g<=?
	'TOS cellA
	NOS cellR
	"cmp #1,#0" ,asm
	.drop
	?? "jg _o%h" ,print ,cr ;

:g<>?
	'TOS cellA
	NOS cellR
	"cmp #1,#0" ,asm
	.drop
	?? "je _o%h" ,print ,cr ;

:gA?
	'TOS cellA
	NOS cellR
	"test #1,#0" ,asm
	.drop
	?? "jz _o%h" ,print ,cr ;

:gN?
	'TOS cellA
	NOS cellR
	"test #1,#0" ,asm
	.drop
	?? "jnz _o%h" ,print ,cr ;

:gB?
	NOS 4 - cellR
	NOS cellA
	TOS cellA
	"cmp #2,#0" ,asm
	?? "jge _o%h" ,print ,cr
	"cmp #2,#1" ,asm
	?? "jle _o%h" ,print ,cr
	.2drop ;

:g>R
	"push #0" ,asm .drop ;

:gR>
	.dupnew
	"pop #0" ,asm ;

:gR@
	.dupnew
	"mov #0,[rsp]" ,asm ;

:gAND
	NOS cellR
	'TOS cellA
	"and #1,#0" ,asm .drop ;

:gOR
	NOS cellR
	'TOS cellA
	"or #1,#0" ,asm .drop ;

:gXOR
	NOS cellR
	'TOS cellA
	"xor #1,#0" ,asm .drop ;

:gNOT
	'TOS cellR
	"not #0" ,asm ;

:gNEG
	'TOS cellR
	"neg #0" ,asm ;

:g+
	NOS cellR
	'TOS cellA
	"add #1,#0" ,asm .drop ;

:g-
	NOS cellR
	'TOS cellA
	"sub #1,#0" ,asm .drop ;

:g*
	NOS cellR
	'TOS cellA
	"imul #1,#0" ,asm .drop ;

:g/
	stk.AR
	"cqo;idiv #0" ,asm .drop ;

:g*/
	stk.ARR
	"cqo;imul #1;idiv #0" ,asm .2drop ;

:g/MOD
	stk.AR
	"cqo;idiv #0" ,asm
	;

:gMOD
	stk.AR
	"cqo;idiv #0" ,asm .drop
	;

:gABS
	'TOS cellR freeD
	"mov rdx,#0;sar rdx,63;add #0,rdx;xor #0,rdx" ,asm ;

:gSQRT
	'TOS cellR
	"cvtsi2sd xmm0,#0;sqrtsd xmm0,xmm0;cvtsd2si #0,xmm0" ,asm ;

:gCLZ
	'TOS cellR
	"bsr #0,#0;xor #0,63" ,asm ;

:g<<
	stk.RC
	"shl #1,$0" ,asm .drop ;

:g>>
	stk.RC
	"sar #1,$0" ,asm .drop ;

:g>>>
	stk.RC
	"shr #1,$0" ,asm .drop ;

:v*>>
	"cqo;imul #1" ,asm
	vTOS
	64 <? ( drop "shrd rax,rdx,$0" ,asm .2drop ; )
	64 >? ( "sar rdx," ,s dup 64 - ,d ,cr )
	drop
	"mov rax,rdx" ,ln
	.2drop ;

:g*>>
	stk.ARC2RAC
	TOS $ff and 0? ( drop v*>> ; ) drop
	"cqo;imul #1;shrd rax,rdx,$0" ,asm
    .2drop ;

:g<</
	stk.ARC
    "cqo;shld rdx,rax,$0;shl rax,$0;idiv #1" ,asm
	.2drop ;

:g@
	'TOS cellI
	"mov #0,qword[#0]" ,asm ;

:gC@
	'TOS cellI
	"movsx #0,byte[#0]" ,asm ;

:gW@
	'TOS cellI
	"movsx #0,word[#0]" ,asm ;

:gD@
	'TOS cellI
	"movsxd #0,dword[#0]" ,asm ;

:g@+
	'TOS cellR
	.dupnew
	"mov #0,[#1];add #1,8" ,asm ;

:gC@+
	'TOS cellR
	.dupnew
	"movsx #0,byte[#1];add #1,1" ,asm ;

:gW@+
	'TOS cellR
	.dupnew
	"movsx #0,word[#1];add #1,2" ,asm ;

:gD@+
	'TOS cellR
	.dupnew
	"movsxd #0,dword[#1];add #1,4" ,asm ;

:g!
	'TOS cellI
	NOS cellI
	"mov qword[#0],#1" ,asm .2DROP ;

:gC!
	'TOS cellI
	NOS cellI
	"mov byte[#0],$1" ,asm .2DROP ;

:gW!
	'TOS cellI
	NOS cellI
	"mov word[#0],&1" ,asm .2DROP ;

:gD!
	'TOS cellI
	NOS cellI
	"mov dword[#0],*1" ,asm
	.2DROP ;

:g!+
	'TOS cellR
	NOS cellA
	"mov qword[#0],#1;add #0,8" ,asm .NIP ;

:gC!+
	'TOS cellR
	NOS cellA
	"mov byte[#0],$1;add #0,1" ,asm .NIP ;

:gW!+
	'TOS cellR
	NOS cellA
	"mov word[#0],&1;add #0,2" ,asm .NIP ;

:gD!+
	'TOS cellR
	NOS cellA
	"mov dword[#0],*1;add #0,4" ,asm .NIP ;


:g+!
	'TOS cellR
	NOS cellA
	"add [#0],#1" ,asm .2DROP ;

:gC+!
	'TOS cellR
	NOS cellA
	"add byte[#0],$1" ,asm .2DROP ;

:gW+!
	'TOS cellR
	NOS cellA
	"add word[#0],&1" ,asm .2DROP ;

:gD+!
	'TOS cellR
	NOS cellA
	"add dword[#0],*1" ,asm .2DROP ;

:g>A
	"mov rsi,#0" ,asm .drop ;

:gA>
	.dupnew
	 "mov #0,rsi" ,asm ;

:gA+
	'TOS cellI
	"add rsi,#0" ,asm .drop ;

:gCA@
	.dupnew
	"movsxd #0,byte[rsi]" ,asm ;

:gCA!
	'TOS cellI
	"mov dword[rsi],$0" ,asm .drop ;

:gDA@
	.dupnew
	"movsxd #0,dword[rsi]" ,asm ;

:gDA!
	'TOS cellI
	"mov dword[rsi],*0" ,asm .drop ;

:gA@
	.dupnew
	"mov #0,qword[rsi]" ,asm ;

:gA!
	'TOS cellI
	"mov qword[rsi],#0" ,asm .drop ;

:gDA@+
	.dupnew
	"movsxd #0,dword[rsi];add rsi,4" ,asm ;

:gDA!+
	'TOS cellI
	"mov dword[rsi],*0;add rsi,4" ,asm .drop ;

:gCA@+
	.dupnew
	"movsxd #0,byte[rsi];add rsi,1" ,asm ;

:gCA!+
	'TOS cellI
	"mov byte[rsi],$0;add rsi,1" ,asm .drop ;

:gA@+
	.dupnew
	"movs #0,qword[rsi];add rsi,8" ,asm ;

:gA!+
	'TOS cellI
	"mov qword[rsi],#0;add rsi,8" ,asm .drop ;

:g>B
	"mov rdi,#0" ,asm .drop ;

:gB>
	.dupnew
	"mov #0,rdi" ,asm ;

:gB+
	'TOS cellI
	"add rdi,#0" ,asm .drop ;

:gCB@
	.dupnew
	"movsxd #0,byte[rdi]" ,asm ;

:gCB!
	'TOS cellI
	"mov byte[rdi],$0" ,asm .drop ;

:gDB@
	.dupnew
	"movsxd #0,dword[rdi]" ,asm ;

:gDB!
	'TOS cellI
	"mov dword[rdi],*0" ,asm .drop ;

:gB@
	.dupnew
	"mov #0,qword[rdi]" ,asm ;

:gB!
	'TOS cellI
	"mov qword[rdi],#0" ,asm .drop ;

:gCB@+
	.dupnew
	"movsxd $0,byte[rdi];add rdi,1" ,asm ;

:gCB!+
	'TOS cellI
	"mov byte[rdi],$0;add rdi,1" ,asm .drop ;

:gDB@+
	.dupnew
	"movsxd #0,dword[rdi];add rdi,4" ,asm ;

:gDB!+
	'TOS cellI
	"mov dword[rdi],*0;add rdi,4" ,asm .drop ;

:gB@+
	.dupnew
	"mov #0,qword[rdi];add rdi,8" ,asm ;

:gB!+
	'TOS cellI
	"mov qword[rdi],#0;add rdi,8" ,asm .drop ;


:gDMOVE
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RSI RCX
	"rep movsd" ,ln
	.3DROP ;

:gDMOVE>
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RSI RCX
	"lea rsi,[rsi+rcx*4-4]" ,ln
	"lea rdi,[rdi+rcx*4-4]" ,ln
	"std" ,ln
	"rep movsd" ,ln
	"cld" ,ln
	.3DROP ;

:gDFILL
	"mov rcx,rax" ,ln
	"movsxd rax,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RAX RCX
	"rep stosd" ,ln
	.3DROP ;

:gCMOVE
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RSI RCX
	"rep movsb" ,ln
	.3DROP ;

:gCMOVE>
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RSI RCX
	"lea rsi,[rsi+rcx-1]" ,ln
	"lea rdi,[rdi+rcx-1]" ,ln
	"std" ,ln
	"rep movsb" ,ln
	"cld" ,ln
	.3DROP ;

:gCFILL
	"mov rcx,rax" ,ln
	"movsxd rax,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RAX RCX
	"rep stosb" ,ln
	.3DROP ;

:gMOVE
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RSI RCX
	"rep movsq" ,ln
	.3DROP ;

:gMOVE>
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RSI RCX
	"lea rsi,[rsi+rcx*8-8]" ,ln
	"lea rdi,[rdi+rcx*8-8]" ,ln
	"std" ,ln
	"rep movsq" ,ln
	"cld" ,ln
	.3DROP ;

:gFILL
	"mov rcx,rax" ,ln
	"movsxd rax,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
|.................... RDI RAX RCX
	"rep stosq" ,ln
	.3DROP ;


:gMEM
	0 PUSH.CTEM ;

:gLOADLIB | aa "" -- aa
	"cinvoke64 LoadLibraryA,#0" ,asm 
	| rax=tos
	;
	
:gGETPROC | aa "" -- dd
	"cinvoke64 GetProcAddress,#0,#1" ,asm .drop 
	| rax=tos
	;

:preA16
	"PUSH RSP;PUSH qword [RSP];ADD RSP,8;AND SPL,$F0" ,asm ;
	
:posA16
	"POP RSP" ,asm ;
	
:gSYS0  | a -- b
	preA16	
	"sub RSP,$20" ,ln 	
	"CALL #0" ,asm
	"add RSP,$20" ,ln 	
	posA16 
	;
	
:gSYS1 | a b -- c
	preA16
	"sub RSP,$20" ,ln 
	"mov rcx,#1;call #0" ,asm
	"add RSP,$20" ,ln 
	posA16 	
	.drop ;

:gSYS2 
	preA16
	"sub RSP,$20" ,ln 
	"mov rdx,#1;mov rcx,#2;call #0" ,asm
	"add RSP,$20" ,ln 
	posA16 	
	.2drop ;
	
:gSYS3 
	preA16
	"sub RSP,$20" ,ln 
	"mov r8,#1;mov rdx,#2;mov rcx,#3'call #0" ,asm
	"add RSP,$20" ,ln 
	posA16 	
	.3drop ;

:gSYS4 
	preA16
	"sub RSP,$20" ,ln 
	"mov r9,#1;mov r8,#2;mov rdx,#3;mov rcx,#4;call #0" ,asm
	"add RSP,$20" ,ln 
	posA16 	
	.4drop ;

:gSYS5
	preA16
	"sub RSP,$30" ,ln 
	"mov [rsp+$20],#1" ,asm
	"mov r9,#2;mov r8,#3;mov rdx,#4;mov rcx,#5;call #0" ,asm
	"add RSP,$30" ,ln 
	posA16 	
	.5drop ;

:gSYS6 
	preA16
	"sub RSP,$30" ,ln 
	"mov [rsp+$28],#1" ,asm
	"mov [rsp+$20],#2" ,asm
	"mov r9,#3;mov r8,#4;mov rdx,#5;mov rcx,#6;call #0" ,asm
	"add RSP,$30" ,ln 
	posA16 	
	.6drop ;

:gSYS7 
	preA16
	"sub RSP,$40" ,ln 
	"mov [rsp+$30],#1" ,asm
	"mov [rsp+$28],#2" ,asm
	"mov [rsp+$20],#2" ,asm
	"mov r9,#4;mov r8,#5;mov rdx,#6;mov rcx,#7;call #0" ,asm
	"add RSP,$40" ,ln 
	posA16 	
	.7drop ;

:gSYS8 
	preA16
	"sub RSP,$40" ,ln 
	"mov [rsp+$38],#1" ,asm
	"mov [rsp+$30],#2" ,asm
	"mov [rsp+$28],#3" ,asm
	"mov [rsp+$20],#4" ,asm
	"mov r9,#5;mov r8,#6;mov rdx,#7;mov rcx,#8;call #0" ,asm
	"add RSP,$40" ,ln 
	posA16 	
	.8drop ;
	
:gSYS9 
	preA16
	"sub RSP,$50" ,ln 
	"mov [rsp+$40],#1" ,asm
	"mov [rsp+$38],#2" ,asm
	"mov [rsp+$30],#3" ,asm
	"mov [rsp+$28],#4" ,asm
	"mov [rsp+$20],#5" ,asm
	"mov r9,#6;mov r8,#7;mov rdx,#8;mov rcx,#9;call #0" ,asm
	"add RSP,$50" ,ln 
	posA16 	
	.9drop ;

	
:gSYS10
	preA16
	"sub RSP,$50" ,ln 
	"mov [rsp+$48],#1" ,asm
	"mov [rsp+$40],#2" ,asm
	"mov [rsp+$38],#3" ,asm
	"mov [rsp+$30],#4" ,asm
	"mov [rsp+$28],#5" ,asm
	"mov [rsp+$20],#6" ,asm
	"mov r9,#7;mov r8,#8;mov rdx,#9;mov rcx,#:;call #0" ,asm
	"add RSP,$50" ,ln 
	posA16 	
	.10drop ;
	
|----------- Number
:gdec
	getcte PUSH.NRO ;

|----------- Calculate Number
:ghex  | really constant folding number
	getcte2 PUSH.NRO ;

|----------- adress string
:gstr
	dup 4 - d@ 8 >>> PUSH.STR ;

|----------- adress word
:gdwor
	getval codtok PUSH.WRD ;	|--	'word

|----------- adress var
:gdvar
	getval codtok PUSH.WRD ;	|--	'var

|----------- var
:gvar
    getval codtok PUSH.VAR		|--	[var]
	.dupnew "mov *0,#1" ,asm .nip ;

|----------- call word
:gwor
	stk.normal
	dup d@ $ff and
	16 =? ( drop getval "jmp w%h" ,print ,cr ; ) drop | ret?
	getval
	dup "call w%h" ,print ,cr
	dic>du drop stk.2normal | exit stack calc
	;

|-----------------------------------------
#vmc
0 0 0 0 0 0 0 gdec ghex gdec gdec gstr gwor gvar gdwor gdvar
g; g( g) g[ g] gEX g0? g1? g+? g-? 
g<? g>? g=? g>=? g<=? g<>? gA? gN? gB? 
.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP 
.ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP 
g>R gR> gR@ 
gAND gOR gXOR g+ g- g* g/ 
g<< g>> g>>> gMOD g/MOD g*/ g*>> g<</ 
gNOT gNEG gABS gSQRT gCLZ 
g@ gC@ gW@ gD@
g@+ gC@+ gW@+ gD@+
g! gC! gW! gD!
g!+ gC!+ gW!+ gD!+ |85 88
g+! gC+! gW+! gD+!
g>A gA> gA+
gA@ gA! gA@+ gA!+
gCA@ gCA! gCA@+ gCA!+
gDA@ gDA! gDA@+ gDA!+
g>B gB> gB+
gB@ gB! gB@+ gB!+
gCB@ gCB! gCB@+ gCB!+
gDB@ gDB! gDB@+ gDB!+
gMOVE gMOVE> gFILL
gCMOVE gCMOVE> gCFILL
gDMOVE gDMOVE> gDFILL
gMEM 
gLOADLIB gGETPROC
gSYS0 gSYS1 gSYS2 gSYS3 gSYS4 gSYS5
gSYS6 gSYS7 gSYS8 gSYS9 gSYS10


:ctetoken
	8 >>> 'ctecode + @ "$" ,s ,h ;

::,tokenprinto
	dup dup $ff and 8 =? ( drop ctetoken ; ) drop
	,tokenprint ;

:codestep | token --
	"; " ,s ,tokenprinto 9 ,c ,printstk ,cr
	"asm/code.asm" savemem
	$ff and 3 << 'vmc + @ ex ;


::genasmcode | duse --
|	0? ( 1 + ) | if empty, add TOS for not forget!!
	1 +
	stk.start
	'bcode ( bcode> <?
		d@+ codestep ) drop ;
