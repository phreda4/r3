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
	dup stbl> d!+ 'stbl> ! ;

:popbl | -- block
	-4 'stbl> +! stbl> d@ ;

|--- @@
::getval | a -- a v
	dup 4 - d@ 8 >>> ;

::getcte | a -- a v
	dup 4 - d@ 8 >>> src + str>anro nip ;

::getcte2 | a -- a v
	dup 4 - d@ 8 >>> 'ctecode + @ ;

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
#prevalb * 32
#prevalv 0

:,TOS	'preval ,s ;
:,TOSE	'prevale ,s ;
:,TOSB	'prevalb ,s ;
:>TOS   dup 'preval strcpy dup 'prevale strcpy 'prevalb strcpy ;
:>TOSE  'prevale strcpy ;
:>TOSB  'prevalb strcpy ;

:varget
	"movsxd rbx," ,s ,TOS ,cr
	"rbx" >TOS
	"ebx" >TOSE 
	"bl" >TOSB 
	;

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

:gAND?
	"mov rbx,rax" ,ln
	,drop
	"test rax,rbx" ,ln
	?? "jz _o%h" ,print ,cr ;
:oAND?
	"test rax," ,s ,TOS ,cr
	?? "jz _o%h" ,print ,cr ;
:oAND?v
	"test eax," ,s ,TOS ,cr
	?? "jz _o%h" ,print ,cr ;

:gNAND?
	"mov rbx,rax" ,ln
	,drop
	"test rax,rbx" ,ln
	?? "jnz _o%h" ,print ,cr ;
:oNAND?
	"test rax," ,s ,TOS ,cr
	?? "jnz _o%h" ,print ,cr ;
:oNAND?v
	"test eax," ,s ,TOS ,cr
	?? "jnz _o%h" ,print ,cr ;

:gBT?
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
	"mov rax,qword[rax]" ,ln ;
:o@
	,dup "mov rax,qword[" ,s ,TOS "]" ,ln ;
:o@v
	varget
	,dup "mov rax,qword[" ,s ,TOS "]" ,ln ;

:gC@
	"movsx rax,byte [rax]" ,ln ;
:oC@
	,dup "movsx rax,byte [" ,s ,TOS "]" ,ln ;
:oC@v
	varget
	,dup "movsx rax,byte [" ,s ,TOS "]" ,ln ;

:gW@
	"movsxd rax,word [rax]" ,ln ;
:oW@
	,dup "movsxd rax,word [" ,s ,TOS "]" ,ln ;
:oW@v
	varget
	,dup "movsxd rax,word [" ,s ,TOS "]" ,ln ;

:gD@
	"movsxd rax,dword [rax]" ,ln ;
:oD@
	,dup "movsxd rax,dword [" ,s ,TOS "]" ,ln ;
:oD@v
	varget
	,dup "movsxd rax,dword [" ,s ,TOS "]" ,ln ;

:g@+
	"mov rbx,[rax]" ,ln
	"add rax,8" ,ln
	,dup
	"mov rax,rbx" ,ln ;
:o@+
	,dup
	"mov rbx," ,s ,TOS ,cr
	"mov rax,[rbx]" ,ln
	"add rbx,8" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;
:o@+v
	,dup
	"movsxd rbx," ,s ,TOS ,cr
	"mov rax,[rbx]" ,ln
	"add rbx,8" ,ln
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


:gD@+
	"movsxd rbx,dword [rax]" ,ln
	"add rax,4" ,ln
	,dup
	"mov rax,rbx" ,ln ;
:oD@+
	,dup
	"mov rbx," ,s ,TOS ,cr
	"movsxd rax,dword [rbx]" ,ln
	"add rbx,4" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;
:oD@+v
	,dup
	"movsxd rbx," ,s ,TOS ,cr
	"movsxd rax,dword [rbx]" ,ln
	"add rbx,4" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;

:gW@+
	"movsxd rbx,word [rax]" ,ln
	"add rax,2" ,ln
	,dup
	"mov rax,rbx" ,ln ;
:oW@+
	,dup
	"mov rbx," ,s ,TOS ,cr
	"movsxd rax,word [rbx]" ,ln
	"add rbx,2" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;
:oW@+v
	,dup
	"movsxd rbx," ,s ,TOS ,cr
	"movsxd rax,word [rbx]" ,ln
	"add rbx,2" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;


:g!
	"mov rcx,[rbp]" ,ln
	"mov qword[rax],rcx" ,ln ,2DROP ;
:o!
	"mov qword[" ,s ,TOS "],rax" ,ln ,DROP ;
:o!v
	varget
	"mov qword[" ,s ,TOS "],rax" ,ln ,DROP ;

:gC!
	"mov rcx,[rbp]" ,ln
	"mov byte[rax],cl" ,ln ,2DROP ;
:oC!
	"mov byte[" ,s ,TOS "],al" ,ln ,DROP ;
:oC!v
	varget
	"mov byte[" ,s ,TOS "],al" ,ln ,DROP ;

:gW!
	"mov rcx,[rbp]" ,ln
	"mov word[rax],ecx" ,ln ,2DROP ;
:oW!
	"mov word[" ,s ,TOS "],ax" ,ln ,DROP ;
:oW!v
	varget
	"mov word[" ,s ,TOS "],ax" ,ln ,DROP ;

:gD!
	"mov rcx,[rbp]" ,ln
	"mov dword[rax],ecx" ,ln ,2DROP ;
:oD!
	"mov dword[" ,s ,TOS "],eax" ,ln ,DROP ;
:oD!v
	varget
	"mov dword[" ,s ,TOS "],eax" ,ln ,DROP ;


:g!+
	"mov rcx,[rbp]" ,ln
	"mov [rax],rcx" ,ln
	"add rax,8" ,ln ,NIP ;
:o!+
	"mov rcx," ,s ,TOS ,cr
	"mov [rcx],rax" ,ln
	"add rcx,8" ,ln
	"mov rax,rcx" ,ln ;
:o!+v
	varget
	"mov [rcx],rax" ,ln
	"add rcx,8" ,ln
	"mov rax,rcx" ,ln ;

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

:gW!+
	"mov rcx,[rbp]" ,ln
	"mov word[rax],cx" ,ln
	"add rax,2" ,ln ,NIP ;
:oW!+
	"mov rcx," ,s ,TOS ,cr
	"mov word[rcx],ax" ,ln
	"add rcx,2" ,ln
	"mov rax,rcx" ,ln ;
:oW!+v
	varget
	"mov word[rbx],ax" ,ln
	"add rbx,4" ,ln
	"mov rax,rbx" ,ln ;

:gD!+
	"mov rcx,[rbp]" ,ln
	"mov dword[rax],ecx" ,ln
	"add rax,4" ,ln ,NIP ;
:oD!+
	"mov rcx," ,s ,TOS ,cr
	"mov dword[rcx],eax" ,ln
	"add rcx,4" ,ln
	"mov rax,rcx" ,ln ;
:oD!+v
	varget
	"mov dword[rbx],eax" ,ln
	"add rbx,4" ,ln
	"mov rax,rbx" ,ln ;


:g+!
	"mov rcx,[rbp]" ,ln
	"add [rax],rcx" ,ln ,2DROP ;
:o+!
	"add [" ,s ,TOS "],rax" ,ln ,DROP ;
:o+!v
	varget
	"add [rbx],eax" ,ln ,DROP ;

:gC+!
	"mov rcx,[rbp]" ,ln
	"add byte [rax],cl" ,ln ,2DROP ;
:oC+!
	"add byte[" ,s ,TOS "],al" ,ln ,DROP ;
:oC+!v
	varget
	"add byte[rbx],eax" ,ln ,DROP ;

:gW+!
	"mov rcx,[rbp]" ,ln
	"add word[rax],cx" ,ln ,2DROP ;
:oW+!
	"add word[" ,s ,TOS "],ax" ,ln ,DROP ;
:oW+!v
	varget
	"add word[rbx],ax" ,ln ,DROP ;

:gD+!
	"mov rcx,[rbp]" ,ln
	"add dword[rax],ecx" ,ln ,2DROP ;
:oD+!
	"add dword[" ,s ,TOS "],eax" ,ln ,DROP ;
:oD+!v
	varget
	"add dword[rbx],eax" ,ln ,DROP ;


:g>A	"mov r8,rax" ,ln ,drop ;
:o>A	"mov r8," ,s ,TOS ,cr ;
:o>Av	varget "mov r8," ,s ,TOS ,cr ;

:gA>	,dup "mov rax,r8" ,ln ;

:gA+	"add r8,rax" ,ln ,drop ;
:oA+	"add r8," ,s ,TOS ,cr ;
:oA+v	varget "add r8," ,s ,TOS ,cr ;

:gA@	,dup "movs rax,qword[r8]" ,ln ;

:gA!	"mov qword[r8],rax" ,ln ,drop ;
:oA!	"mov qword[r8]," ,s ,TOS ,cr ;
:oA!v	varget "mov qword[r8],rbx" ,ln ;

:gA@+	,dup "movs rax,qword[r8]" ,ln "add r8,8" ,ln ;
:gA!+	"mov qword[r8],rax" ,ln "add r8,8" ,ln ,drop ;
:oA!+	"mov qword[r8]," ,s ,TOS ,cr "add r8,8" ,ln ;
:oA!+v	varget "mov qword[r8],rbx" ,ln "add r8,8" ,ln ;

:gCA@	,dup "movsxd rax,byte[r8]" ,ln ;

:gCA!	"mov byte[r8],al" ,ln ,drop ;
:oCA!	"mov byte[r8]," ,s ,TOSB ,cr ;
:oCA!v	varget "mov byte[r8],bl" ,ln ;

:gCA@+	,dup "movsxd rax,byte[r8]" ,ln "add r8,1" ,ln ;
:gCA!+	"mov byte[r8],al" ,ln "add r8,1" ,ln ,drop ;
:oCA!+	"mov byte[r8]," ,s ,TOSB ,cr "add r8,1" ,ln ;
:oCA!+v	varget "mov byte[r8],bl" ,ln "add r8,1" ,ln ;

:gDA@	,dup "movsxd rax,dword[r8]" ,ln ;

:gDA!	"mov dword[r8],eax" ,ln ,drop ;
:oDA!	"mov dword[r8]," ,s ,TOSE ,cr ;
:oDA!v	varget "mov dword[r8],ebx" ,ln ;

:gDA@+	,dup "movsxd rax,dword[r8]" ,ln "add r8,4" ,ln ;
:gDA!+	"mov dword[r8],eax" ,ln "add r8,4" ,ln ,drop ;
:oDA!+	"mov dword[r8]," ,s ,TOSE ,cr "add r8,4" ,ln ;
:oDA!+v	varget "mov dword[r8],ebx" ,ln "add r8,4" ,ln ;

:g>B	"mov r9,rax" ,ln ,drop ;
:o>B	"mov r9," ,s ,TOS ,cr ;
:o>Bv	varget "mov r9," ,s ,TOS ,cr ;

:gB>	,dup "mov rax,r9" ,ln ;

:gB+	"add r9,rax" ,ln ,drop ;
:oB+	"add r9," ,s ,TOS ,cr ;
:oB+v	varget "add r9," ,s ,TOS ,cr ;

:gB@	,dup "movsxd rax,qword[r9]" ,ln ;

:gB!	"mov qword[r9],rax" ,ln ,drop ;
:oB!	"mov qword[r9]," ,s ,TOS ,cr ;
:oB!v	varget "mov qword[r9],rbx" ,ln ;

:gB@+	,dup "movs rax,qword[r9]" ,ln "add r9,8" ,ln ;

:gB!+	"mov qword[r9],rax" ,ln "add r9,8" ,ln ,drop ;
:oB!+	"mov qword[r9]," ,s ,TOS ,cr "add r9,8" ,ln ;
:oB!+v	varget "mov qword[r9],rbx" ,ln "add r9,8" ,ln ;

:gDB@	,dup "movsxd rax,dword[r9]" ,ln ;

:gDB!	"mov dword[r9],eax" ,ln ,drop ;
:oDB!	"mov dword[r9]," ,s ,TOSE ,cr ;
:oDB!v	varget "mov dword[r9],ebx" ,ln ;

:gDB@+	,dup "movsxd rax,dword[r9]" ,ln "add r9,4" ,ln ;

:gDB!+	"mov dword[r9],eax" ,ln "add r9,4" ,ln ,drop ;
:oDB!+	"mov dword[r9]," ,s ,TOSE ,cr "add r9,4" ,ln ;
:oDB!+v	varget "mov dword[r9],ebx" ,ln "add r9,4" ,ln ;

:gCB@	,dup "movsxd rax,byte[r9]" ,ln ;

:gCB!	"mov byte[r9],al" ,ln ,drop ;
:oCB!	"mov byte[r9]," ,s ,TOSB ,cr ;
:oCB!v	varget "mov byte[r9],bl" ,ln ;

:gCB@+	,dup "movsxd rax,byte[r9]" ,ln "add r9,1" ,ln ;

:gCB!+	"mov byte[r9],al" ,ln "add r9,1" ,ln ,drop ;
:oCB!+	"mov byte[r9]," ,s ,TOSB ,cr "add r9,1" ,ln ;
:oCB!+v	varget "mov byte[r9],bl" ,ln "add r9,1" ,ln ;


:gDMOVE
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep movsd" ,ln
	,3DROP ;

:gDMOVE>
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"lea rsi,[rsi+rcx*4-4]" ,ln
	"lea rdi,[rdi+rcx*4-4]" ,ln
	"std" ,ln
	"rep movsd" ,ln
	"cld" ,ln
	,3DROP ;

:gDFILL
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

:gMOVE
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep movsq" ,ln
	,3DROP ;

:gMOVE>
	"mov rcx,rax" ,ln
	"movsxd rsi,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"lea rsi,[rsi+rcx*8-8]" ,ln
	"lea rdi,[rdi+rcx*8-8]" ,ln
	"std" ,ln
	"rep movsq" ,ln
	"cld" ,ln
	,3DROP ;

:gFILL
	"mov rcx,rax" ,ln
	"movsxd rax,dword[rbp]" ,ln
	"movsxd rdi,dword[rbp-8]" ,ln
	"rep stosq" ,ln
	,3DROP ;

:gMEM
	,dup "mov rax,[FREE_MEM]" ,ln ;

:gLOADLIB | "" -- aa
	"cinvoke LoadLibraryA," ,s ,TOS ,cr	;
	
:gGETPROC | aa "" -- dd
	"cinvoke GetProcAddress," ,s ,NOS "," ,s ,TOS ,cr ;
	
:gSYS0  | a -- b
	"cinvoke " ,s ,TOS ,cr ;
:gSYS1 
	"cinvoke " ,s ,TOS "," ,NOS ,cr ;
:gSYS2 
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 ,cr ;
:gSYS3 
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 "," ,NOS3 ,cr ;
:gSYS4 
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 "," ,NOS3 "," ,NOS4 ,cr ;
:gSYS5
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 "," ,NOS3 "," ,NOS4 "," ,NOS5 ,cr ;
:gSYS6 
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 "," ,NOS3 "," ,NOS4 "," ,NOS5 "," ,NOS6 ,cr ;
:gSYS7 
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 "," ,NOS3 "," ,NOS4 "," ,NOS5 "," ,NOS6 "," ,NOS7 ,cr ;
:gSYS8 
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 "," ,NOS3 "," ,NOS4 "," ,NOS5 "," ,NOS6 "," ,NOS7 "," ,NOS8 ,cr ;
:gSYS9 
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 "," ,NOS3 "," ,NOS4 "," ,NOS5 "," ,NOS6 "," ,NOS7 "," ,NOS8 "," ,NOS9 ,cr ;
:gSYS10
	"cinvoke " ,s ,TOS "," ,NOS "," ,NOS2 "," ,NOS3 "," ,NOS4 "," ,NOS5 "," ,NOS6 "," ,NOS7 "," ,NOS8 "," ,NOS9 "," ,NOS10 ,cr ;
	
|---------------------------------
#vmc1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oEX 0 0 0 0 o<? o>? o=? o>=? o<=? o<>?
oAND? oNAND? 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oAND oOR oXOR o+ o- o* o/ o<< o>> o>>> oMOD
o/MOD o*/ o*>> o<</ 0 0 0 0 0 
o@ oC@ oW@ oD@ 
o@+ oC@+ oW@+ oD@+ 
o! oC! oW! oD! 
o!+ oC!+ oW!+ oD!+ 
o+! oC+! oW+! oD+! 
o>A 0 oA+ 
0 oA! 0 oA!+ 
0 oCA! 0 oCA!+ 
0 oDA! 0 oDA!+ 
o>B 0 oB+ 
0 oB! 0 oB!+ 
0 oCB! 0 oCB!+ 
0 oDB! 0 oDB!+ 
0 0 0 
0 0 0 
0 0 0 
0
0 0 
0 0 0 0 0 0 0 0 0 0 0 


|----------- Number
:number | value --
	dup 'prevalv !
	dup 32 << 32 >>
	=? ( "%d" sprint >TOS ; )
	"mov rbx,%d" sprint ,s ,cr
	"rbx" >TOS
	"ebx" >TOSE 
	"bl" >TOSB 
	;

:decopt
	"; OPTN " ,s over d@ ,tokenprint ,cr
	swap getcte number
	4 + swap ex ;

:val'var! | especial case "nro 'var !"
	getcte number
	"mov dword[w" ,s dup d@ 8 >>> ,h "]," ,s ,TOSE ,cr
	8 + ;


:gdec
	dup d@ $ff and 3 << 'vmc1 + @ 1? ( decopt ; ) drop
	dup d@ $ff and 15 =? ( drop 			| nro 'var
		dup 4 + d@ $ff and 79 =? ( drop  | nro 'var !
			val'var! ; )
		) drop
	,DUP
	getcte 0? ( drop "xor rax,rax" ,ln ; )
	"mov rax," ,s ,d ,cr  ;

|----------- Calculate Number
:hexopt
	"; OPTC " ,s over d@ ,tokenprint ,cr
	swap getcte2 number
	4 + swap ex ;

:cal'var! | especial case "nro 'var !"
	"mov dword[w" ,s
	dup d@ 8 >>> ,h
	"]," ,s
	getcte2 number ,TOS ,cr
	8 + ;

:ghex  | really constant folding number
	dup d@ $ff and 3 << 'vmc1 + @ 1? ( hexopt ; ) drop
	dup d@ $ff and 15 =? ( drop 			| nro 'var
		dup 4 + d@ $ff and 79 =? ( drop  | nro 'var !
			cal'var! ; )
		) drop
	,DUP "mov rax," ,s getcte2 ,d ,cr ;

|----------- adress string
:gstr
	,DUP "mov rax,str" ,s
	dup 4 - d@ 8 >>> ,h ,cr
	;

|----------- adress word
:sworopt
	"; OPTAW " ,s over @ ,tokenprint ,cr
	swap getval	"w%h" sprint >TOS
	4 + swap ex ;

:gdwor
	dup d@ $ff and 3 << 'vmc1 + @ 1? ( sworopt ; ) drop
	,DUP "mov rax,w" ,s getval ,h ,cr ;		|--	'word

|----------- adress var
:dvaropt
	"; OPTAV " ,s over @ ,tokenprint ,cr
	swap getval	"w%h" sprint >TOS
	4 + swap ex ;

:gdvar
	dup d@ $ff and 3 << 'vmc1 + @ 1? ( dvaropt ; ) drop
	,DUP "mov rax,w" ,s getval ,h ,cr ;		|--	'var

|----------- var
#vmc2
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oEXv 0 0 0 0 o<?v o>?v o=?v o>=?v o<=?v o<>?v
oAND?v oNAND?v 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oANDv oORv oXORv o+v o-v o*v o/v o<<v o>>v o>>>v oMODv
o/MODv o*/v o*>>v o<</v 0 0 0 0 0 
o@v oC@v oW@v oD@v 
o@+v oC@+v oW@+v oD@+v 
o!v oC!v oW!v oD!v 
o!+v oC!+v oW!+v oD!+v 
o+!v oC+!v oW+!v oD+!v 
o>Av 0 oA+v 
0 oA!v 0 oA!+v 
0 oCA!v 0 oCA!+v 
0 oDA!v 0 oDA!+v 
o>Bv 0 oB+v 
0 oB!v 0 oB!+v 
0 oCB!v 0 oCB!+v 
0 oDB!v 0 oDB!+v 
0 0 0 
0 0 0 
0 0 0 
0
0 0 
0 0 0 0 0 0 0 0 0 0 0 

:varopt
	"; OPTV " ,s over @ ,tokenprint ,cr
	swap getval "dword[w%h]" sprint >TOS
	4 + swap ex ;

:gvar
	dup d@ $ff and 3 << 'vmc2 + @ 1? ( varopt ; ) drop
	,DUP "movsxd rax,dword[w" ,s getval ,h "]" ,ln ;	|--	[var]


|----------- call word
:gwor
	dup d@ $ff and
	16 =? ( drop getval "jmp w%h" ,print ,cr ; ) drop | ret?
	getval "call w%h" ,print ,cr ;

|-----------------------------------------
#vmc
0 0 0 0 0 0 0 gdec ghex gdec gdec gstr gwor gvar gdwor gdvar
g; g( g) g[ g] gEX g0? g1? g+? g-?
g<? g>? g=? g>=? g<=? g<>? gand? gnand? gBT?
,DUP ,DROP ,OVER ,PICK2 ,PICK3 ,PICK4 ,SWAP ,NIP
,ROT ,2DUP ,2DROP ,3DROP ,4DROP ,2OVER ,2SWAP
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

|----------------
:ctetoken
	8 >>> 'ctecode + @ "$%h ; calc" sprint ,s ,cr
	;

::,tokenprinto
	"; " ,s
	dup dup $ff and 8 =? ( drop ctetoken ; ) drop
	,tokenprint ,cr
	;
|----------------

:codestep | token --
	$ff and 3 << 'vmc + @ ex ;

::genasmcode | duse --
	drop
	'bcode ( bcode> <?
		d@+
        ,tokenprinto
|		"asm/code.asm" savemem
		codestep
		) drop ;