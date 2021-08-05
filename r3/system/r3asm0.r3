| generate amd64 code
| BASIC GENERATOR
| - no stack memory, only look next code to generate optimizations
| PHREDA 2020
|-------------
^./r3base.r3

#stbl * 40 | 10 niveles ** falta inicializar si hay varias ejecuciones
#stbl> 'stbl

#nblock 0

:pushbl | -- block
	nblock
	dup 1 + 'nblock !
	dup stbl> !+ 'stbl> ! ;

:popbl | -- block
	-4 'stbl> +! stbl> @ ;

|--- @@
::getval | a -- a v
	dup 4 - @ 8 >>> ;

::getcte | a -- a v
	dup 4 - @ 8 >>> src + str>anro nip ;

::getcte2 | a -- a v
	dup 4 - @ 8 >>> 'ctecode + q@ ;

|--------------------------
:,DUP
	"add rbp,8" ,ln
	"mov [rbp],rax" ,ln ;
:,DROP
	"mov rax,[rbp]" ,ln
	"sub rbp,8" ,ln ;
:,NIP
	"sub rbp,8" ,ln ;
:,2DROP
	"mov rax,[rbp-8]" ,ln
	"sub rbp,8*2" ,ln ;
:,3DROP
	"mov rax,[rbp-8*2]" ,ln
	"sub rbp,8*3" ,ln ;
:,4DROP
	"mov rax,[rbp-8*3]" ,ln
	"sub rbp,8*4" ,ln ;
:,OVER
	,DUP "mov rax,[rbp-8]" ,ln ;
:,PICK2
	,DUP "mov rax,[rbp-8*2]" ,ln ;
:,PICK3
	,DUP "mov rax,[rbp-8*3]" ,ln ;
:,PICK4
	,DUP "mov rax,[rbp-8*4]" ,ln ;
:,SWAP
	"xchg rax,[rbp]" ,ln ;
:,ROT
	"mov rcx,[rbp]" ,ln
	"mov [rbp],rax" ,ln
	"mov rax,[rbp-8]" ,ln
	"mov [rbp-8],rcx" ,ln ;
:,2DUP
	"mov rcx,[rbp]" ,ln
	"mov [rbp+8],rax" ,ln
	"mov [rbp+8*2],rcx" ,ln
	"add rbp,8*2" ,ln ;
:,2OVER
	"mov [rbp+8],rax" ,ln
	"add rbp,8*2" ,ln
	"mov rbx,[rbp-8*4]" ,ln
	"mov [rbp],rbx" ,ln
	"mov rax,[rbp-8*3]" ,ln ;
:,2SWAP
	"xchg rax,[rbp-8]" ,ln
	"mov rcx,[rbp-8*2]" ,ln
	"xchg rcx,[rbp]" ,ln
	"mov [rbp-8*2],rcx" ,ln ;

|----------------------
:g;
	dup 8 - @ $ff and
	12 =? ( drop ; ) | tail call  call..ret?
	21 =? ( drop ; ) | tail call  EX
	drop
	"ret" ,ln ;

|--- IF/WHILE

::getiw | v -- iw
    3 << blok + @ $10000000 and ;

:g(
	getval getiw 0? ( pushbl 2drop ; ) drop
    pushbl
	"_i%h:" ,print ,cr ;		| while

:g)
	getval getiw
	popbl swap
	1? ( over "jmp _i%h" ,print ,cr ) drop	| while
	"_o%h:" ,print ,cr ;

:?? | -- nblock
	getval getiw
	0? ( drop nblock ; ) drop stbl> 4 - @ ;

|---- Optimization WORDS
#preval * 32
#prevale * 32
#prevalv 0

:,TOS	'preval ,s ;
:,TOSE	'prevale ,s ;
:>TOS   dup 'preval strcpy 'prevale strcpy ;
:>TOSE  'prevale strcpy ;

:varget
	"movsxd rbx," ,s ,TOS ,cr
	"rbx" >TOS
	"ebx" >TOSE ;

|-------------------------------------
:g[
	pushbl
	dup "jmp ja%h" ,print ,cr
	"anon%h:" ,print ,cr
	;
:g]
	popbl
	dup "ja%h:" ,print ,cr
	,DUP
	"mov rax,anon%h" ,print ,cr
	;

:gEX
	"mov rcx,rax" ,ln
	,DROP
	dup @ $ff and
	16 <>? ( drop "call rcx" ,ln ; ) drop
	"jmp rcx" ,ln ;
:oEX
	dup @ $ff and
	16 <>? ( drop "call " ,s ,TOS ,cr ; ) drop
	"jmp " ,s ,TOS ,cr ;
:oEXv
	"mov ecx," ,s ,TOS ,cr
	dup @ $ff and
	16 <>? ( drop "call rcx" ,ln ; ) drop
	"jmp rcx" ,ln ;

:g0?
	"or rax,rax" ,ln
	?? "jnz _o%h" ,print ,cr ;

:g1?
	"or rax,rax" ,ln
	?? "jz _o%h" ,print ,cr ;

:g+?
	"or rax,rax" ,ln
	?? "js _o%h" ,print ,cr ;

:g-?
	"or rax,rax" ,ln
	?? "jns _o%h" ,print ,cr ;

:g<?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jge _o%h" ,print ,cr ;
:o<?
	"cmp rax," ,s ,TOS ,cr
	?? "jge _o%h" ,print ,cr ;
:o<?v
	"cmp eax," ,s ,TOS ,cr
	?? "jge _o%h" ,print ,cr ;


:g>?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jle _o%h" ,print ,cr ;
:o>?
	"cmp rax," ,s ,TOS ,cr
	?? "jle _o%h" ,print ,cr ;
:o>?v
	"cmp eax," ,s ,TOS ,cr
	?? "jle _o%h" ,print ,cr ;

:g=?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jne _o%h" ,print ,cr ;
:o=?
	"cmp rax," ,s ,TOS ,cr
	?? "jne _o%h" ,print ,cr ;
:o=?v
	"cmp eax," ,s ,TOS ,cr
	?? "jne _o%h" ,print ,cr ;

:g>=?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jl _o%h" ,print ,cr ;
:o>=?
	"cmp rax," ,s ,TOS ,cr
	?? "jl _o%h" ,print ,cr ;
:o>=?v
	"cmp eax," ,s ,TOS ,cr
	?? "jl _o%h" ,print ,cr ;

:g<=?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jg _o%h" ,print ,cr ;
:o<=?
	"cmp rax," ,s ,TOS ,cr
	?? "jg _o%h" ,print ,cr ;
:o<=?v
	"cmp eax," ,s ,TOS ,cr
	?? "jg _o%h" ,print ,cr ;

:g<>?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "je _o%h" ,print ,cr ;
:o<>?
	"cmp rax," ,s ,TOS ,cr
	?? "je _o%h" ,print ,cr ;
:o<>?v
	"cmp eax," ,s ,TOS ,cr
	?? "je _o%h" ,print ,cr ;

:gA?
	"mov rbx,rax" ,ln
	,drop
	"test rax,rbx" ,ln
	?? "jz _o%h" ,print ,cr ;
:oA?
	"test rax," ,s ,TOS ,cr
	?? "jz _o%h" ,print ,cr ;
:oA?v
	"test eax," ,s ,TOS ,cr
	?? "jz _o%h" ,print ,cr ;

:gN?
	"mov rbx,rax" ,ln
	,drop
	"test rax,rbx" ,ln
	?? "jnz _o%h" ,print ,cr ;
:oN?
	"test rax," ,s ,TOS ,cr
	?? "jnz _o%h" ,print ,cr ;
:oN?v
	"test eax," ,s ,TOS ,cr
	?? "jnz _o%h" ,print ,cr ;

:gB?
	"sub rbp,8*2" ,ln
	"mov rbx,[rbp+8]" ,ln
	"xchg rax,rbx" ,ln
	"cmp rax,[rbp+8*2]" ,ln
	?? "jge _o%h" ,print ,cr
	"cmp rax,rbx" ,ln
	?? "jle _o%h" ,print ,cr
	;

:g>R
	"push rax" ,ln ,drop ;

:gR>
	,dup "pop rax" ,ln ;

:gR@
	,dup "mov rax,[rsp]" ,ln ;


:gAND	"and rax,[rbp]" ,ln ,nip ;
:oAND	"and rax," ,s ,TOS ,cr ;
:oANDv	varget "and rax," ,s ,TOS ,cr ;

:gOR    "or rax,[rbp]" ,ln ,nip ;
:oOR	"or rax," ,s ,TOS ,cr ;
:oORv	varget "or rax," ,s ,TOS ,cr ;

:gXOR   "xor rax,[rbp]" ,ln ,nip ;
:oXOR	"xor rax," ,s ,TOS ,cr ;
:oXORv	varget "xor rax," ,s ,TOS ,cr ;

:gNOT	"not rax" ,ln ;

:gNEG   "neg rax" ,ln ;

:g+		"add rax,[rbp]" ,ln ,nip ;
:o+		"add rax," ,s ,TOS ,cr ;
:o+v	varget "add rax," ,s ,TOS ,cr ;

:g-		"neg rax" ,ln "add rax,[rbp]" ,ln ,nip ;
:o-		"sub rax," ,s ,TOS ,cr ;
:o-v	varget "sub rax," ,s ,TOS ,cr ;

:g*		"imul rax,[rbp]" ,ln ,nip ;
:o*		"imul rax," ,s ,TOS ,cr ;
:o*v	varget "imul rax," ,s ,TOS ,cr ;

:g/
	"mov rbx,rax" ,ln
	,drop
	"cqo" ,ln
	"idiv rbx" ,ln	;
:o/
	"mov rbx," ,s ,TOS ,cr
	"cqo" ,ln
	"idiv rbx" ,ln ;
:o/v
	"movsxd rbx," ,s ,TOS ,cr
	"cqo" ,ln
	"idiv rbx" ,ln ;

:g*/
	"mov rbx,rax" ,ln
	"mov rcx,[rbp]" ,ln
	,2drop
	"cqo" ,ln
	"imul rcx" ,ln
	"idiv rbx" ,ln 	;
:o*/
	"mov rbx," ,s ,TOS ,cr
	"cqo" ,ln
	"imul qword[rbp]" ,ln
	"idiv rbx" ,ln
	"sub rbp,8" ,ln ;
:o*/v
	"movsxd rbx," ,s ,TOS ,cr
	"cqo" ,ln
	"imul qword[rbp]" ,ln
	"idiv rbx" ,ln
	"sub rbp,8" ,ln ;

:g/MOD
	"mov rbx,rax" ,ln
	"mov rax,[rbp]" ,ln
	"cqo" ,ln
	"idiv rbx" ,ln
	"mov [rbp],rax" ,ln
	"xchg rax,rdx" ,ln 	;
:o/MOD
	"mov rbx," ,s ,TOS ,cr
	"cqo" ,ln
	"idiv rbx" ,ln
	"add ebp,8" ,ln
	"mov [rbp],rax" ,ln
	"mov rax,rdx" ,ln ;
:o/MODv
	"movsxd rbx," ,s ,TOS ,cr
	"cqo" ,ln
	"idiv rbx" ,ln
	"add ebp,8" ,ln
	"mov [rbp],rax" ,ln
	"mov rax,rdx" ,ln ;

:gMOD
	"mov rbx,rax" ,ln
	,drop
	"cqo" ,ln
	"idiv rbx" ,ln
	"mov rax,rdx" ,ln ;
:oMOD
	"mov rbx," ,s ,TOS ,cr
	"cqo" ,ln
	"idiv rbx" ,ln
	"mov rax,rdx" ,ln ;
:oMODv
	"movsxd rbx," ,s ,TOS ,cr
	"cqo" ,ln
	"idiv rbx" ,ln
	"mov rax,rdx" ,ln ;

:gABS
	"cqo" ,ln
	"add rax,rdx" ,ln
	"xor rax,rdx" ,ln ;

:gSQRT
	"cvtsi2sd xmm0,rax" ,ln
	"sqrtsd xmm0,xmm0" ,ln
	"cvtsd2si rax,xmm0" ,ln ;

:gCLZ
	"bsr rax,rax" ,ln
	"xor rax,63" ,ln ;

:g<<
	"mov cl,al" ,ln
	,drop "shl rax,cl" ,ln ;
:o<<
	"shl rax," ,s ,TOS ,cr ;
:o<<v
	"mov ecx," ,s ,TOS ,cr
	"shl rax,cl" ,ln ;

:g>>
	"mov cl,al" ,ln ,drop
	"sar rax,cl" ,ln ;
:o>>
	"sar rax," ,s ,TOS ,cr ;
:o>>v
	"mov ecx," ,s ,TOS ,cr
	"sar rax,cl" ,ln ;

:g>>>
	"mov cl,al" ,ln
	,drop
	"shr rax,cl" ,ln ;
:o>>>
	"shr rax," ,s ,TOS ,cr ;
:o>>>v
	"mov ecx," ,s ,TOS ,cr
	"shr rax,cl" ,ln ;

:g*>>
	"mov rcx,rax" ,ln
	,DROP
	"cqo" ,ln
	"imul qword[rbp]" ,ln
	"shrd rax,rdx,cl" ,ln
	"sar rdx,cl" ,ln
	"and ecx,64" ,ln
	"cmovne	rax,rdx" ,ln
	,NIP ;

:o*>>
	"cqo" ,ln
	"imul qword[rbp]" ,ln
	,NIP
	prevalv
	64 <? ( "shrd rax,rdx," ,s ,d ,cr ; )
	64 >? ( "sar rdx," ,s dup 64 - ,d ,cr )
	drop
	"mov rax,rdx" ,ln ;

:o*>>v
	"mov ecx," ,s ,TOS ,cr
	"cqo" ,ln
	"imul qword[rbp]" ,ln
	,NIP
	"shrd rax,rdx,cl" ,ln
	"sar rdx,cl" ,ln
	"and ecx,64" ,ln
	"cmovne rax,rdx" ,ln
	;

:g<</
	"mov rcx,rax" ,ln
	"mov rbx,[rbp]" ,ln
	,2DROP
	"cqo" ,ln
    "shld rdx,rax,cl" ,ln
	"shl rax,cl" ,ln
	"idiv rbx" ,ln ;
:o<</
	"mov rbx,rax" ,ln
	,DROP
	"cqo" ,ln
	"shld rdx,rax," ,s prevalv ,d ,cr
	"shl rax," ,s prevalv ,d ,cr
	"idiv rbx" ,ln ;
:o<</v
	"mov ecx," ,s ,TOS ,cr
	"mov rbx,rax" ,ln
	,DROP
	"cqo" ,ln
	"shld rdx,rax,cl" ,ln
	"shl rax,cl" ,ln
	"idiv rbx" ,ln ;

:g@
	"movsxd rax,dword [rax]" ,ln ;
:o@
	,dup "movsxd rax,dword [" ,s ,TOS "]" ,ln ;
:o@v
	varget
	,dup "movsxd rax,dword [" ,s ,TOS "]" ,ln ;

:gC@
	"movsx rax,byte [rax]" ,ln ;
:oC@
	,dup "movsx rax,byte [" ,s ,TOS "]" ,ln ;
:oC@v
	varget
	,dup "movsx rax,byte [" ,s ,TOS "]" ,ln ;

:gQ@
	"mov rax,qword[rax]" ,ln ;
:oQ@
	,dup "mov rax,qword[" ,s ,TOS "]" ,ln ;
:oQ@v
	varget
	,dup "mov rax,qword[" ,s ,TOS "]" ,ln ;

:g@+
	"movsxd rbx,dword [rax]" ,ln
	"add rax,4" ,ln
	,dup
	"mov rax,rbx" ,ln ;
:o@+
	,dup
	"mov rbx," ,s ,TOS ,cr
	"movsxd rax,dword [rbx]" ,ln
	"add rbx,4" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;
:o@+v
	,dup
	"movsxd rbx," ,s ,TOS ,cr
	"movsxd rax,dword [rbx]" ,ln
	"add rbx,4" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;

:gC@+
	"movsx rbx,byte [rax]" ,ln
	"add rax,1" ,ln
	,dup
	"mov rax,rbx" ,ln ;
:oC@+
	,dup
	"mov rbx," ,s ,TOS ,cr
	"movsx rax,byte [rbx]" ,ln
	"add rbx,1" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;
:oC@+v
	,dup
	"movsxd rbx," ,s ,TOS ,cr
	"movsx rax,byte [rbx]" ,ln
	"add rbx,1" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;

:gQ@+
	"mov rbx,[rax]" ,ln
	"add rax,8" ,ln
	,dup
	"mov rax,rbx" ,ln ;
:oQ@+
	,dup
	"mov rbx," ,s ,TOS ,cr
	"mov rax,[rbx]" ,ln
	"add rbx,8" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;
:oQ@+v
	,dup
	"movsxd rbx," ,s ,TOS ,cr
	"mov rax,[rbx]" ,ln
	"add rbx,8" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;

:g!
	"mov rcx,[rbp]" ,ln
	"mov dword[rax],ecx" ,ln ,2DROP ;
:o!
	"mov dword[" ,s ,TOS "],eax" ,ln ,DROP ;
:o!v
	varget
	"mov dword[" ,s ,TOS "],eax" ,ln ,DROP ;

:gC!
	"mov rcx,[rbp]" ,ln
	"mov byte[rax],cl" ,ln ,2DROP ;
:oC!
	"mov byte[" ,s ,TOS "],al" ,ln ,DROP ;
:oC!v
	varget
	"mov byte[" ,s ,TOS "],al" ,ln ,DROP ;

:gQ!
	"mov rcx,[rbp]" ,ln
	"mov qword[rax],rcx" ,ln ,2DROP ;
:oQ!
	"mov qword[" ,s ,TOS "],rax" ,ln ,DROP ;
:oQ!v
	varget
	"mov qword[" ,s ,TOS "],rax" ,ln ,DROP ;

:g!+
	"mov rcx,[rbp]" ,ln
	"mov dword[rax],ecx" ,ln
	"add rax,4" ,ln ,NIP ;
:o!+
	"mov rcx," ,s ,TOS ,cr
	"mov dword[rcx],eax" ,ln
	"add rcx,4" ,ln
	"mov rax,rcx" ,ln ;
:o!+v
	varget
	"mov dword[rbx],eax" ,ln
	"add rbx,4" ,ln
	"mov rax,rbx" ,ln ;

:gC!+
	"mov rcx,[rbp]" ,ln
	"mov byte[rax],cl" ,ln
	"add rax,1" ,ln ,NIP ;
:oC!+
	"mov rcx," ,s ,TOS ,cr
	"mov byte[rcx],al" ,ln
	"add rcx,1" ,ln
	"mov rax,rcx" ,ln ;
:oC!+v
	varget
	"mov byte[rbx],al" ,ln
	"add rbx,1" ,ln
	"mov rax,rbx" ,ln ;

:gQ!+
	"mov rcx,[rbp]" ,ln
	"mov [rax],rcx" ,ln
	"add rax,8" ,ln ,NIP ;
:oQ!+
	"mov rcx," ,s ,TOS ,cr
	"mov [rcx],rax" ,ln
	"add rcx,8" ,ln
	"mov rax,rcx" ,ln ;
:oQ!+v
	varget
	"mov [rcx],rax" ,ln
	"add rcx,8" ,ln
	"mov rax,rcx" ,ln ;

:g+!
	"mov rcx,[rbp]" ,ln
	"add dword[rax],ecx" ,ln ,2DROP ;
:o+!
	"add dword[" ,s ,TOS "],eax" ,ln ,DROP ;
:o+!v
	varget
	"add dword[rbx],eax" ,ln ,DROP ;

:gC+!
	"mov rcx,[rbp]" ,ln
	"add byte [rax],cl" ,ln ,2DROP ;
:oC+!
	"add byte[" ,s ,TOS "],al" ,ln ,DROP ;
:oC+!v
	varget
	"add byte[rbx],eax" ,ln ,DROP ;

:gQ+!
	"mov rcx,[rbp]" ,ln
	"add [rax],rcx" ,ln ,2DROP ;
:oQ+!
	"add [" ,s ,TOS "],rax" ,ln ,DROP ;
:oQ+!v
	varget
	"add [rbx],eax" ,ln ,DROP ;

:g>A
	"mov r8,rax" ,ln ,drop ;
:o>A
	"mov r8," ,s ,TOS ,cr ;
:o>Av
	varget "mov r8," ,s ,TOS ,cr ;

:gA>
	,dup "mov rax,r8" ,ln ;

:gA@
	,dup "movsxd rax,dword[r8]" ,ln ;

:gA!
	"mov dword[r8],eax" ,ln ,drop ;
:oA!
	"mov dword[r8]," ,s ,TOSE ,cr ;
:oA!v
	varget "mov dword[r8],ebx" ,ln ;

:gA+
	"add r8,rax" ,ln ,drop ;
:oA+
	"add r8," ,s ,TOS ,cr ;
:oA+v
	varget "add r8," ,s ,TOS ,cr ;

:gA@+
	,dup "movsxd rax,dword[r8]" ,ln
	"add r8,4" ,ln ;

:gA!+
	"mov dword[r8],eax" ,ln
	"add r8,4" ,ln ,drop ;
:oA!+
	"mov dword[r8]," ,s ,TOSE ,cr
	"add r8,4" ,ln ;
:oA!+v
	varget
	"mov dword[r8],ebx" ,ln
	"add r8,4" ,ln ;

:g>B
	"mov r9,rax" ,ln ,drop ;
:o>B
	"mov r9," ,s ,TOS ,cr ;
:o>Bv
	varget "mov r9," ,s ,TOS ,cr ;

:gB>
	,dup "mov rax,r9" ,ln ;

:gB@
	,dup "movsxd rax,dword[r9]" ,ln ;

:gB!
	"mov dword[r9],eax" ,ln ,drop ;
:oB!
	"mov dword[r9]," ,s ,TOSE ,cr ;
:oB!v
	varget "mov dword[r9],ebx" ,ln ;

:gB+
	"add r9,rax" ,ln ,drop ;
:oB+
	"add r9," ,s ,TOS ,cr ;
:oB+v
	varget "add r9," ,s ,TOS ,cr ;

:gB@+
	,dup "movsxd rax,dword[r9]" ,ln
	"add r9,4" ,ln ;

:gB!+
	"mov dword[r9],eax" ,ln
	"add r9,4" ,ln ,drop ;
:oB!+
	"mov dword[r9]," ,s ,TOSE ,cr
	"add r9,4" ,ln ;
:oB!+v
	varget
	"mov dword[r9],ebx" ,ln
	"add r9,4" ,ln ;

:gMOVE
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep movsd" ,ln
	,3DROP ;

:gMOVE>
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"lea rsi,[rsi+rcx*4-4]" ,ln
	"lea rdi,[rdi+rcx*4-4]" ,ln
	"std" ,ln
	"rep movsd" ,ln
	"cld" ,ln
	,3DROP ;

:gFILL
	"mov rcx,rax" ,ln
	"movsxd rax,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep stosd" ,ln
	,3DROP ;

:gCMOVE
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep movsb" ,ln
	,3DROP ;

:gCMOVE>
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"lea rsi,[rsi+rcx-1]" ,ln
	"lea rdi,[rdi+rcx-1]" ,ln
	"std" ,ln
	"rep movsb" ,ln
	"cld" ,ln
	,3DROP ;

:gCFILL
	"mov rcx,rax" ,ln
	"movsxd rax,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep stosb" ,ln
	,3DROP ;

:gQMOVE
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep movsq" ,ln
	,3DROP ;

:gQMOVE>
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"lea rsi,[rsi+rcx*8-8]" ,ln
	"lea rdi,[rdi+rcx*8-8]" ,ln
	"std" ,ln
	"rep movsq" ,ln
	"cld" ,ln
	,3DROP ;

:gQFILL
	"mov rcx,rax" ,ln
	"movsxd rax,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep stosq" ,ln
	,3DROP ;

:gMEM
	,dup "mov rax,[FREE_MEM]" ,ln ;
:gSW
	,dup "mov rax,XRES" ,ln ;
:gSH
	,dup "mov rax,YRES" ,ln ;
:gFRAMEV
	,dup "mov rax,[SYSFRAME]" ,ln ;
:gXYPEN
	,dup "mov eax,dword[SYSXM]" ,ln
	,dup "mov eax,dword[SYSYM]" ,ln ;
:gBPEN
	,dup "mov eax,dword[SYSBM]" ,ln ;
:gKEY
	,dup "mov eax,dword[SYSKEY]" ,ln ;
:gCHAR
	,dup "mov eax,dword[SYSCHAR]" ,ln ;
:gUPDATE
	"call SYSREDRAW" ,ln ;
:gREDRAW
	"call SYSUPDATE" ,ln ;
:gMSEC
	"call SYSMSEC" ,ln ;
:gTIME
	"call SYSTIME" ,ln ;
:gDATE
	"call SYSDATE" ,ln ;
:gLOAD
	"call SYSLOAD" ,ln ;
:gSAVE
	"call SYSSAVE" ,ln ;
:gAPPEND
	"call SYSAPPEND" ,ln ;
:gFFIRST
	"call SYSFFIRST" ,ln ;
:gFNEXT
	"call SYSFNEXT" ,ln ;
:gSYS
	"call SYSYSTEM" ,ln ;
:gSLOAD
	"call SYSSLOAD" ,ln ;
:gSFREE
	"call SYSSFREE" ,ln ;
:gSPLAY
	"call SYSSPLAY" ,ln ;
:gMLOAD
	"call SYSMLOAD" ,ln ;
:gMFREE
	"call SYSMFREE" ,ln ;
:gMPLAY
	"call SYSMPLAY" ,ln ;


|---------------------------------
#vmc1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oEX 0 0 0 0 o<? o>? o=? o>=? o<=? o<>?
oA? oN? 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oAND oOR oXOR o+ o- o* o/ o<< o>> o>>> oMOD
o/MOD o*/ o*>> o<</ 0 0 0 0 0 o@ oC@ oQ@ o@+ oC@+ oQ@+ o!
oC! oQ! o!+ oC!+ oQ!+ o+! oC+! oQ+! o>A 0 0 oA! oA+ 0 oA!+ o>B
0 0 oB! oB+ 0 oB!+ 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0

|----------- Number
:number | value --
	dup 'prevalv !
	dup 32 << 32 >>
	=? ( "%d" sprint >TOS ; )
	"mov rbx,%d" sprint ,s ,cr
	"rbx" >TOS
	"ebx" >TOSE ;

:decopt
	"; OPTN " ,s over @ ,tokenprint ,cr
	swap getcte number
	4 + swap ex ;

:val'var! | especial case "nro 'var !"
	getcte number
	"mov dword[w" ,s dup @ 8 >>> ,h "]," ,s ,TOSE ,cr
	8 + ;

::getval | a -- a v
	dup 4 - @ 8 >>> ;

:gdec
	dup @ $ff and 2 << 'vmc1 + @ 1? ( decopt ; ) drop
	dup @ $ff and 15 =? ( drop 			| nro 'var
		dup 4 + @ $ff and 79 =? ( drop  | nro 'var !
			val'var! ; )
		) drop
	,DUP
	getcte 0? ( drop "xor rax,rax" ,ln ; )
	"mov rax," ,s ,d ,cr  ;

|----------- Calculate Number
:hexopt
	"; OPTC " ,s over @ ,tokenprint ,cr
	swap getcte2 number
	4 + swap ex ;

:cal'var! | especial case "nro 'var !"
	"mov dword[w" ,s
	dup @ 8 >>> ,h
	"]," ,s
	getcte2 number ,TOS ,cr
	8 + ;

:ghex  | really constant folding number
	dup @ $ff and 2 << 'vmc1 + @ 1? ( hexopt ; ) drop
	dup @ $ff and 15 =? ( drop 			| nro 'var
		dup 4 + @ $ff and 79 =? ( drop  | nro 'var !
			cal'var! ; )
		) drop
	,DUP "mov rax," ,s getcte2 ,d ,cr ;

|----------- adress string
:gstr
	,DUP "mov rax,str" ,s
	dup 4 - @ 8 >>> ,h ,cr
	;

|----------- adress word
:sworopt
	"; OPTAW " ,s over @ ,tokenprint ,cr
	swap getval	"w%h" sprint >TOS
	4 + swap ex ;

:gdwor
	dup @ $ff and 2 << 'vmc1 + @ 1? ( sworopt ; ) drop
	,DUP "mov rax,w" ,s getval ,h ,cr ;		|--	'word

|----------- adress var
:dvaropt
	"; OPTAV " ,s over @ ,tokenprint ,cr
	swap getval	"w%h" sprint >TOS
	4 + swap ex ;

:gdvar
	dup @ $ff and 2 << 'vmc1 + @ 1? ( dvaropt ; ) drop
	,DUP "mov rax,w" ,s getval ,h ,cr ;		|--	'var

|----------- var
#vmc2
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oEXv 0 0 0 0 o<?v o>?v o=?v o>=?v o<=?v o<>?v
oA?v oN?v 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oANDv oORv oXORv o+v o-v o*v o/v o<<v o>>v o>>>v oMODv
o/MODv o*/v o*>>v o<</v 0 0 0 0 0 o@v oC@v oQ@v o@+v oC@+v oQ@+v o!v
oC!v oQ!v o!+v oC!+v oQ!+v o+!v oC+!v oQ+!v o>Av 0 0 oA!v oA+v 0 oA!+v o>Bv
0 0 oB!v oB+v 0 oB!+v 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0

:varopt
	"; OPTV " ,s over @ ,tokenprint ,cr
	swap getval "dword[w%h]" sprint >TOS
	4 + swap ex ;

:gvar
	dup @ $ff and 2 << 'vmc2 + @ 1? ( varopt ; ) drop
	,DUP "movsxd rax,dword[w" ,s getval ,h "]" ,ln ;	|--	[var]


|----------- call word
:gwor
	dup @ $ff and
	16 =? ( drop getval "jmp w%h" ,print ,cr ; ) drop | ret?
	getval "call w%h" ,print ,cr ;

|-----------------------------------------
#vmc
0 0 0 0 0 0 0 gdec ghex gdec gdec gstr gwor gvar gdwor gdvar
g; g( g) g[ g] gEX g0? g1? g+? g-? g<? g>? g=? g>=? g<=? g<>?
gA? gN? gB? ,DUP ,DROP ,OVER ,PICK2 ,PICK3 ,PICK4 ,SWAP ,NIP ,ROT ,2DUP ,2DROP ,3DROP ,4DROP
,2OVER ,2SWAP g>R gR> gR@ gAND gOR gXOR g+ g- g* g/ g<< g>> g>>> gMOD
g/MOD g*/ g*>> g<</ gNOT gNEG gABS gSQRT gCLZ g@ gC@ gQ@ g@+ gC@+ gQ@+ g!
gC! gQ! g!+ gC!+ gQ!+ g+! gC+! gQ+! g>A gA> gA@ gA! gA+ gA@+ gA!+ g>B
gB> gB@ gB! gB+ gB@+ gB!+ gMOVE gMOVE> gFILL gCMOVE gCMOVE> gCFILL gQMOVE gQMOVE> gQFILL gUPDATE
gREDRAW gMEM gSW gSH gFRAMEV gXYPEN gBPEN gKEY gCHAR gMSEC gTIME gDATE gLOAD gSAVE gAPPEND
gFFIRST gFNEXT gSYS
gSLOAD gSFREE gSPLAY
gMLOAD gMFREE gMPLAY

|----------------
:ctetoken
	8 >>> 'ctecode + q@ "$%h ; calc" sprint ,s ,cr
	;

::,tokenprinto
	"; " ,s
	dup dup $ff and 8 =? ( drop ctetoken ; ) drop
	,tokenprint ,cr
	;
|----------------

:codestep | token --
	$ff and 2 << 'vmc + @ ex ;

::genasmcode | duse --
	drop
	'bcode ( bcode> <?
		@+
        ,tokenprinto
|		"asm/code.asm" savemem
		codestep
		) drop ;