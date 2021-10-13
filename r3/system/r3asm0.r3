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
	dup 8 - d@ $ff and
	12 =? ( drop ; ) | tail call  call..ret?
	21 =? ( drop ; ) | tail call  EX
	drop
	"ret" ,ln ;

|--- IF/WHILE

::getiw | v -- iw
    3 << blok + d@ $10000000 and ;

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
	0? ( drop nblock ; ) drop stbl> 4 - d@ ;


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
	"mov rbx," ,s ,TOS ,cr
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
	"mov rcx," ,s ,TOS ,cr
	dup @ $ff and
	16 <>? ( drop "call rcx" ,ln ; ) drop
	"jmp rcx" ,ln ;

:g0?
	"or rax,rax" ,ln
	?? "jnz _o%h" ,print ,cr ;

:g1?
	"or rax,rax" ,ln
	?? "jz _o%h;" ,print ,cr ;

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


:g>?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jle _o%h" ,print ,cr ;
:o>?
	"cmp rax," ,s ,TOS ,cr
	?? "jle _o%h" ,print ,cr ;

:g=?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jne _o%h" ,print ,cr ;
:o=?
	"cmp rax," ,s ,TOS ,cr
	?? "jne _o%h" ,print ,cr ;

:g>=?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jl _o%h" ,print ,cr ;
:o>=?
	"cmp rax," ,s ,TOS ,cr
	?? "jl _o%h" ,print ,cr ;

:g<=?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "jg _o%h" ,print ,cr ;
:o<=?
	"cmp rax," ,s ,TOS ,cr
	?? "jg _o%h" ,print ,cr ;

:g<>?
	"mov rbx,rax" ,ln
	,drop
	"cmp rax,rbx" ,ln
	?? "je _o%h" ,print ,cr ;
:o<>?
	"cmp rax," ,s ,TOS ,cr
	?? "je _o%h" ,print ,cr ;

:gAND?
	"mov rbx,rax" ,ln
	,drop
	"test rax,rbx" ,ln
	?? "jz _o%h" ,print ,cr ;
:oAND?
	"test rax," ,s ,TOS ,cr
	?? "jz _o%h" ,print ,cr ;

:gNAND?
	"mov rbx,rax" ,ln
	,drop
	"test rax,rbx" ,ln
	?? "jnz _o%h" ,print ,cr ;
:oNAND?
	"test rax," ,s ,TOS ,cr
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

:g>R	"push rax" ,ln ,drop ;
:gR>	,dup "pop rax" ,ln ;
:gR@	,dup "mov rax,[rsp]" ,ln ;

:gAND	"and rax,[rbp]" ,ln ,nip ;
:oAND	"and rax," ,s ,TOS ,cr ;

:gOR    "or rax,[rbp]" ,ln ,nip ;
:oOR	"or rax," ,s ,TOS ,cr ;

:gXOR   "xor rax,[rbp]" ,ln ,nip ;
:oXOR	"xor rax," ,s ,TOS ,cr ;

:gNOT	"not rax" ,ln ;

:gNEG   "neg rax" ,ln ;

:g+		"add rax,[rbp]" ,ln ,nip ;
:o+		"add rax," ,s ,TOS ,cr ;

:g-		"neg rax" ,ln "add rax,[rbp]" ,ln ,nip ;
:o-		"sub rax," ,s ,TOS ,cr ;

:g*		"imul rax,[rbp]" ,ln ,nip ;
:o*		"imul rax," ,s ,TOS ,cr ;

:g/
	"mov rbx,rax" ,ln
	,drop
	"cqo" ,ln
	"idiv rbx" ,ln	;
:o/
	"mov rbx," ,s ,TOS ,cr
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
	"add rbp,8" ,ln
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
	"mov rcx," ,s ,TOS ,cr
	"shl rax,cl" ,ln ;

:g>>
	"mov cl,al" ,ln ,drop
	"sar rax,cl" ,ln ;
:o>>
	"sar rax," ,s ,TOS ,cr ;
:o>>v
	"mov rcx," ,s ,TOS ,cr
	"sar rax,cl" ,ln ;

:g>>>
	"mov cl,al" ,ln
	,drop
	"shr rax,cl" ,ln ;
:o>>>
	"shr rax," ,s ,TOS ,cr ;
:o>>>v
	"mov rcx," ,s ,TOS ,cr
	"shr rax,cl" ,ln ;

:g*>>
	"mov rcx,rax" ,ln
	,DROP
	"cqo" ,ln
	"imul qword[rbp]" ,ln
	"shrd rax,rdx,cl" ,ln
	"sar rdx,cl" ,ln
	"and rcx,64" ,ln
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
	"mov rcx," ,s ,TOS ,cr
	"cqo" ,ln
	"imul qword[rbp]" ,ln
	,NIP
	"shrd rax,rdx,cl" ,ln
	"sar rdx,cl" ,ln
	"and rcx,64" ,ln
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
	"mov rcx," ,s ,TOS ,cr
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
	"movsx rax,word [rax]" ,ln ;
:oW@
	,dup "movsx rax,word [" ,s ,TOS "]" ,ln ;
:oW@v
	varget
	,dup "movsx rax,word [" ,s ,TOS "]" ,ln ;

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
	"mov rbx," ,s ,TOS ,cr
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
	"mov rbx," ,s ,TOS ,cr
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
	"mov rbx," ,s ,TOS ,cr
	"movsxd rax,dword [rbx]" ,ln
	"add rbx,4" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;

:gW@+
	"movsx rbx,word [rax]" ,ln
	"add rax,2" ,ln
	,dup
	"mov rax,rbx" ,ln ;
:oW@+
	,dup
	"mov rbx," ,s ,TOS ,cr
	"movsx rax,word [rbx]" ,ln
	"add rbx,2" ,ln
	,dup
	"mov [rbp],rbx" ,ln ;
:oW@+v
	,dup
	"movs rbx," ,s ,TOS ,cr
	"movsx rax,word [rbx]" ,ln
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
	"mov word[rax],cx" ,ln ,2DROP ;
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
	"mov [" ,s ,TOS "],rax" ,ln
	"add " ,s ,TOS ",8" ,ln
	"mov rax," ,s ,TOS ,cr ;

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
	"mov byte[" ,s ,TOS "],al" ,ln
	"add " ,s ,TOS ",1" ,ln
	"mov rax," ,s ,TOS ,cr ;

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
	"mov word[" ,s ,TOS "],ax" ,ln
	"add " ,s ,TOS ",4" ,ln
	"mov rax," ,s ,TOS ,cr ;

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
	"mov dword[" ,s ,TOS "],eax" ,ln
	"add " ,s ,TOS ",4" ,ln
	"mov rax," ,s ,TOS ,cr ;


:g+!
	"mov rcx,[rbp]" ,ln
	"add [rax],rcx" ,ln ,2DROP ;
:o+!
	"add [" ,s ,TOS "],rax" ,ln ,DROP ;
:o+!v
	varget
	"add [" ,s ,TOS "],rax" ,ln ,DROP ;

:gC+!
	"mov rcx,[rbp]" ,ln
	"add byte [rax],cl" ,ln ,2DROP ;
:oC+!
	"add byte[" ,s ,TOS "],al" ,ln ,DROP ;
:oC+!v
	varget
	"add byte[" ,s ,TOS "],rax" ,ln ,DROP ;

:gW+!
	"mov rcx,[rbp]" ,ln
	"add word[rax],cx" ,ln ,2DROP ;
:oW+!
	"add word[" ,s ,TOS "],ax" ,ln ,DROP ;
:oW+!v
	varget
	"add word[" ,s ,TOS "],ax" ,ln ,DROP ;

:gD+!
	"mov rcx,[rbp]" ,ln
	"add dword[rax],ecx" ,ln ,2DROP ;
:oD+!
	"add dword[" ,s ,TOS "],eax" ,ln ,DROP ;
:oD+!v
	varget
	"add dword[" ,s ,TOS "],eax" ,ln ,DROP ;


:g>A	"mov r14,rax" ,ln ,drop ;
:o>A	"mov r14," ,s ,TOS ,cr ;

:gA>	,dup "mov rax,r14" ,ln ;

:gA+	"add r14,rax" ,ln ,drop ;
:oA+	"add r14," ,s ,TOS ,cr ;

:gA@	,dup "mov rax,qword[r14]" ,ln ;

:gA!	"mov qword[r14],rax" ,ln ,drop ;
:oA!	"mov qword[r14]," ,s ,TOS ,cr ;
:oA!v	varget "mov qword[r14]," ,s ,TOS ,cr ;

:gA@+	,dup "mov rax,qword[r14]" ,ln "add r14,8" ,ln ;
:gA!+	"mov qword[r14],rax" ,ln "add r14,8" ,ln ,drop ;
:oA!+	"mov qword[r14]," ,s ,TOS ,cr "add r14,8" ,ln ;
:oA!+v	varget "mov qword[r14]," ,s ,TOS ,cr  "add r14,8" ,ln ;

:gCA@	,dup "movsx rax,byte[r14]" ,ln ;

:gCA!	"mov byte[r14],al" ,ln ,drop ;
:oCA!	"mov byte[r14]," ,s ,TOSB ,cr ;
:oCA!v	varget "mov byte[r14],bl" ,ln ;

:gCA@+	,dup "movsx rax,byte[r14]" ,ln "add r14,1" ,ln ;
:gCA!+	"mov byte[r14],al" ,ln "add r14,1" ,ln ,drop ;
:oCA!+	"mov byte[r14]," ,s ,TOSB ,cr "add r14,1" ,ln ;
:oCA!+v	varget "mov byte[r14],bl" ,ln "add r14,1" ,ln ;

:gDA@	,dup "movsxd rax,dword[r14]" ,ln ;

:gDA!	"mov dword[r14],eax" ,ln ,drop ;
:oDA!	"mov dword[r14]," ,s ,TOSE ,cr ;
:oDA!v	varget "mov dword[r14],ebx" ,ln ;

:gDA@+	,dup "movsxd rax,dword[r14]" ,ln "add r14,4" ,ln ;
:gDA!+	"mov dword[r14],eax" ,ln "add r14,4" ,ln ,drop ;
:oDA!+	"mov dword[r14]," ,s ,TOSE ,cr "add r14,4" ,ln ;
:oDA!+v	varget "mov dword[r14],ebx" ,ln "add r14,4" ,ln ;

:g>B	"mov r15,rax" ,ln ,drop ;
:o>B	"mov r15," ,s ,TOS ,cr ;

:gB>	,dup "mov rax,r15" ,ln ;

:gB+	"add r15,rax" ,ln ,drop ;
:oB+	"add r15," ,s ,TOS ,cr ;

:gB@	,dup "mov rax,qword[r15]" ,ln ;

:gB!	"mov qword[r15],rax" ,ln ,drop ;
:oB!	"mov qword[r15]," ,s ,TOS ,cr ;
:oB!v	varget "mov qword[r15],rbx" ,ln ;

:gB@+	,dup "mov rax,qword[r15]" ,ln "add r15,8" ,ln ;

:gB!+	"mov qword[r15],rax" ,ln "add r15,8" ,ln ,drop ;
:oB!+	"mov qword[r15]," ,s ,TOS ,cr "add r15,8" ,ln ;
:oB!+v	varget "mov qword[r15],rbx" ,ln "add r15,8" ,ln ;

:gDB@	,dup "movsxd rax,dword[r15]" ,ln ;

:gDB!	"mov dword[r15],eax" ,ln ,drop ;
:oDB!	"mov dword[r15]," ,s ,TOSE ,cr ;
:oDB!v	varget "mov dword[r15],ebx" ,ln ;

:gDB@+	,dup "movsxd rax,dword[r15]" ,ln "add r15,4" ,ln ;

:gDB!+	"mov dword[r15],eax" ,ln "add r15,4" ,ln ,drop ;
:oDB!+	"mov dword[r15]," ,s ,TOSE ,cr "add r15,4" ,ln ;
:oDB!+v	varget "mov dword[r15],ebx" ,ln "add r15,4" ,ln ;

:gCB@	,dup "movsx rax,byte[r15]" ,ln ;

:gCB!	"mov byte[r15],al" ,ln ,drop ;
:oCB!	"mov byte[r15]," ,s ,TOSB ,cr ;
:oCB!v	varget "mov byte[r15],bl" ,ln ;

:gCB@+	,dup "movsx rax,byte[r15]" ,ln "add r15,1" ,ln ;

:gCB!+	"mov byte[r15],al" ,ln "add r15,1" ,ln ,drop ;
:oCB!+	"mov byte[r15]," ,s ,TOSB ,cr "add r15,1" ,ln ;
:oCB!+v	varget "mov byte[r15],bl" ,ln "add r15,1" ,ln ;


:gDMOVE
	"mov rcx,rax" ,ln
	"mov rsi,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"rep movsd" ,ln
	,3DROP ;

:gDMOVE>
	"mov rcx,rax" ,ln
	"mov rsi,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"lea rsi,[rsi+rcx*4-4]" ,ln
	"lea rdi,[rdi+rcx*4-4]" ,ln
	"std" ,ln
	"rep movsd" ,ln
	"cld" ,ln
	,3DROP ;

:gDFILL
	"mov rcx,rax" ,ln
	"mov rax,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"rep stosd" ,ln
	,3DROP ;

:gCMOVE
	"mov rcx,rax" ,ln
	"mov rsi,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"rep movsb" ,ln
	,3DROP ;

:gCMOVE>
	"mov rcx,rax" ,ln
	"mov rsi,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"lea rsi,[rsi+rcx-1]" ,ln
	"lea rdi,[rdi+rcx-1]" ,ln
	"std" ,ln
	"rep movsb" ,ln
	"cld" ,ln
	,3DROP ;

:gCFILL
	"mov rcx,rax" ,ln
	"mov rax,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"rep stosb" ,ln
	,3DROP ;

:gMOVE
	"mov rcx,rax" ,ln
	"mov rsi,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"rep movsq" ,ln
	,3DROP ;

:gMOVE>
	"mov rcx,rax" ,ln
	"mov rsi,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"lea rsi,[rsi+rcx*8-8]" ,ln
	"lea rdi,[rdi+rcx*8-8]" ,ln
	"std" ,ln
	"rep movsq" ,ln
	"cld" ,ln
	,3DROP ;

:gFILL
	"mov rcx,rax" ,ln
	"mov rax,qword[rbp]" ,ln
	"mov rdi,qword[rbp-8]" ,ln
	"rep stosq" ,ln
	,3DROP ;

:gMEM
	,dup "mov rax,[FREE_MEM]" ,ln ;

|The x64 ABI considers the registers RAX, RCX, RDX, R8, R9, R10, R11, and XMM0-XMM5 
|volatile. When present, the upper portions of YMM0-YMM15 and ZMM0-ZMM15 are also |volatile. On AVX512VL, the ZMM, YMM, and XMM registers 16-31 are also volatile. 
|Consider volatile registers destroyed on function calls unless otherwise 
|safety-provable by analysis such as whole program optimization.

|The x64 ABI considers registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, R15, and 
|XMM6-XMM15 nonvolatile. They must be saved and restored by a function that uses them.


:gLOADLIB | "" -- aa
	"cinvoke64 LoadLibraryA,rax" ,ln	;

:oLOADLIB | "" -- aa
	"cinvoke64 LoadLibraryA," ,s ,TOS ,cr ;
	
	
:gGETPROC | aa "" -- dd
	"cinvoke64 GetProcAddress,qword[rbp],rax" ,ln 
	"sub rbp,8" ,ln ;
	
:oGETPROC | aa "" -- dd
	"cinvoke64 GetProcAddress,rax," ,s ,TOS ,cr ;


:vGETPROC | aa "" -- dd
	varget 
	"cinvoke64 GetProcAddress,rax,rbx" ,ln ;

:preA16
	"PUSH RSP" ,ln 
	"PUSH qword [RSP]" ,ln 
	"ADD RSP,8" ,ln 
	"AND SPL,$F0" ,ln ;
	
:posA16
	"POP RSP" ,ln  ;
	
:gSYS0  | a -- b
	preA16	
	"sub RSP,$20" ,ln 	
	"CALL rax" ,ln 
	"add RSP,$20" ,ln 	
	posA16 ;
	
:gSYS0v
	"sub RSP,$20" ,ln 
	preA16	
	"CALL " ,s ,TOS ,cr
	posA16 
	"add RSP,$20" ,ln 
	;
	
:gSYS1 | a b -- c
	preA16
	"sub RSP,$20" ,ln 
	"mov rcx,[rbp]" ,ln
	"call rax" ,ln 
	"sub rbp,8" ,ln 	
	"add RSP,$20" ,ln 
	posA16 ;

:gSYS1v
	,DUP
	"sub RSP,$20" ,ln 
	preA16
	"mov rcx,[rbp]" ,ln
	"call " ,s ,TOS ,cr
	|"sub rbp,8" ,ln 	
	posA16 
	"add RSP,$20" ,ln 
	;
	
:gSYS2 
	preA16
	"sub RSP,$20" ,ln 
	"mov rdx,[rbp]" ,ln
	"mov rcx,[rbp-1*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*2" ,ln 		
	"add RSP,$20" ,ln 
	posA16 	;
	
:gSYS3 
	preA16
	"sub RSP,$20" ,ln 
	"mov r8,[rbp]" ,ln
	"mov rdx,[rbp-1*8]" ,ln
	"mov rcx,[rbp-2*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*3" ,ln 	
	"add RSP,$20" ,ln 
	posA16 	;

:gSYS4 
	preA16
	"sub RSP,$20" ,ln 
	"mov r9,[rbp]" ,ln
	"mov r8,[rbp-1*8]" ,ln
	"mov rdx,[rbp-2*8]" ,ln
	"mov rcx,[rbp-3*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*4" ,ln 	
	"add RSP,$20" ,ln 
	posA16 	;

:gSYS5
	preA16
	"sub RSP,$30" ,ln 
	"mov rcx,[rbp]" ,ln
	"mov [rsp+$20],rcx" ,ln
	"mov r9,[rbp-1*8]" ,ln
	"mov r8,[rbp-2*8]" ,ln
	"mov rdx,[rbp-3*8]" ,ln
	"mov rcx,[rbp-4*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*5" ,ln 	
	"add RSP,$30" ,ln 
	posA16 	;

:gSYS6 
	preA16
	"sub RSP,$30" ,ln 
	"mov rdx,[rbp]" ,ln
	"mov [rsp+$28],rdx" ,ln	
	"mov rcx,[rbp-1*8]" ,ln	
	"mov [rsp+$20],rcx" ,ln
	"mov r9,[rbp-2*8]" ,ln
	"mov r8,[rbp-3*8]" ,ln
	"mov rdx,[rbp-4*8]" ,ln
	"mov rcx,[rbp-5*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*6" ,ln 	
	"add RSP,$30" ,ln 
	posA16 	;

:gSYS7 
	preA16
	"sub RSP,$40" ,ln 
	"mov rcx,[rbp]" ,ln
	"mov [rsp+$30],rcx" ,ln
	"mov rcx,[rbp-1*8]" ,ln
	"mov [rsp+$28],rcx" ,ln
	"mov rcx,[rbp-2*8]" ,ln
	"mov [rsp+$20],rcx" ,ln
	"mov r9,[rbp-3*8]" ,ln
	"mov r8,[rbp-4*8]" ,ln
	"mov rdx,[rbp-5*8]" ,ln
	"mov rcx,[rbp-6*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*7" ,ln 	
	"add RSP,$40" ,ln 
	posA16 	;

:gSYS8 
	preA16
	"sub RSP,$40" ,ln 
	"mov rcx,[rbp]" ,ln
	"mov [rsp+$38],rcx" ,ln
	"mov rcx,[rbp-1*8]" ,ln
	"mov [rsp+$30],rcx" ,ln
	"mov rcx,[rbp-2*8]" ,ln
	"mov [rsp+$28],rcx" ,ln
	"mov rcx,[rbp-3*8]" ,ln
	"mov [rsp+$20],rcx" ,ln
	"mov r9,[rbp-4*8]" ,ln
	"mov r8,[rbp-5*8]" ,ln
	"mov rdx,[rbp-6*8]" ,ln
	"mov rcx,[rbp-7*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*8" ,ln 
	"add RSP,$40" ,ln 
	posA16 	;
	
:gSYS9 
	preA16
	"sub RSP,$50" ,ln 
	"mov rcx,[rbp]" ,ln
	"mov [rsp+$40],rcx" ,ln
	"mov rcx,[rbp-1*8]" ,ln
	"mov [rsp+$38],rcx" ,ln
	"mov rcx,[rbp-2*8]" ,ln
	"mov [rsp+$30],rcx" ,ln
	"mov rcx,[rbp-3*8]" ,ln
	"mov [rsp+$28],rcx" ,ln
	"mov rcx,[rbp-4*8]" ,ln
	"mov [rsp+$20],rcx" ,ln
	"mov r9,[rbp-5*8]" ,ln
	"mov r8,[rbp-6*8]" ,ln
	"mov rdx,[rbp-7*8]" ,ln
	"mov rcx,[rbp-8*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*9" ,ln 
	"add RSP,$50" ,ln 
	posA16 	;
	
:gSYS10
	preA16
	"sub RSP,$50" ,ln 
	"mov rcx,[rbp]" ,ln
	"mov [rsp+$48],rcx" ,ln
	"mov rcx,[rbp-1*8]" ,ln
	"mov [rsp+$40],rcx" ,ln
	"mov rcx,[rbp-2*8]" ,ln
	"mov [rsp+$38],rcx" ,ln
	"mov rcx,[rbp-3*8]" ,ln
	"mov [rsp+$30],rcx" ,ln
	"mov rcx,[rbp-4*8]" ,ln
	"mov [rsp+$28],rcx" ,ln
	"mov rcx,[rbp-5*8]" ,ln
	"mov [rsp+$20],rcx" ,ln
	"mov r9,[rbp-6*8]" ,ln
	"mov r8,[rbp-7*8]" ,ln
	"mov rdx,[rbp-8*8]" ,ln
	"mov rcx,[rbp-9*8]" ,ln
	"call rax" ,ln 
	"sub rbp,8*10" ,ln 
	"add RSP,$50" ,ln 
	posA16 	;
	
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
oLOADLIB oGETPROC 
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
	"mov qword[w" ,s dup d@ 8 >>> ,h "]," ,s ,TOSE ,cr
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
	"mov qword[w" ,s
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
:stropt
	"; OPTS " ,s over d@ ,tokenprint ,cr
	swap dup 4 - d@ 8 >>> "str%h" sprint >TOS
	4 + swap ex ;
	
:gstr
	dup d@ $ff and 3 << 'vmc1 + @ 1? ( stropt ; ) drop
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
0 0 0 0 0 oEXv 0 0 0 0 o<? o>? o=? o>=? o<=? o<>?
oAND? oNAND? 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 oAND oOR oXOR o+ o- o* o/ o<<v o>>v o>>>v oMOD
o/MOD o*/ o*>>v o<</v 0 0 0 0 0 
o@v oC@v oW@v oD@v 
o@+v oC@+v oW@+v oD@+v 
o!v oC!v oW!v oD!v 
o!+v oC!+v oW!+v oD!+v 
o+!v oC+!v oW+!v oD+!v 
o>A 0 oA+ 
0 oA!v 0 oA!+v 
0 oCA!v 0 oCA!+v 
0 oDA!v 0 oDA!+v 
o>B 0 oB+
0 oB!v 0 oB!+v 
0 oCB!v 0 oCB!+v 
0 oDB!v 0 oDB!+v 
0 0 0 
0 0 0 
0 0 0 
0
0 vGETPROC 
|gSYS0v 
0 0 |gSYS1v 
0 0 0 0 
0 0 0 0 0 

:varopt
	"; OPTV " ,s over @ ,tokenprint ,cr
	swap getval "qword[w%h]" sprint >TOS
	4 + swap ex ;

:gvar
	dup d@ $ff and 3 << 'vmc2 + @ 1? ( varopt ; ) drop
	,DUP "mov rax,qword[w" ,s getval ,h "]" ,ln ;	|--	[var]


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
|	dup " %h " ,print
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
|		dup "%h " .print
        ,tokenprinto
|		"asm/code.asm" savemem
		codestep
		) drop ;