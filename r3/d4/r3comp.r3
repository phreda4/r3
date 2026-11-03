| r3 simple compiler - plain.r3 to assembler text (fasm)
| PHREDA 2026
|---------------------------------------------------------------
| one fragment of code for each base word, no optimization.
| input : r3/d4/gen/plain.r3 (made by r3plain.r3)
| output: asm/code.asm asm/data.asm asm/set.asm (see asm/r3fasm*.asm)
|
| registers
|   rax = TOS     rbp = data stack pointer, [rbp] = NOS (grows up)
|   rsp = return stack      r14 = A    r15 = B
|   rbx rcx rdx rsi rdi r8-r11 = scratch
|
| fragments: ';' separates instructions, '~' is the jump label
| labels: wN = word or var N (dic index), lN = token N, sN = string at strm+N
|---------------------------------------------------------------
^r3/lib/console.r3
^r3/d4/r3token.r3

#filename "r3/d4/gen/plain.r3"
#osnames "WIN" "LIN" "MAC" "RPI"

|---------------------------------------------------------------
| FRAGMENTS (names as in r3base)
|---------------------------------------------------------------
#fragc
"EX" "mov rcx,rax;mov rax,[rbp];sub rbp,8;or rcx,rcx;jz @f;call rcx;@@:"
"0?" "or rax,rax;jnz ~"
"1?" "or rax,rax;jz ~"
"+?" "or rax,rax;js ~"
"-?" "or rax,rax;jns ~"
"<?" "mov rbx,rax;mov rax,[rbp];sub rbp,8;cmp rax,rbx;jge ~"
">?" "mov rbx,rax;mov rax,[rbp];sub rbp,8;cmp rax,rbx;jle ~"
"=?" "mov rbx,rax;mov rax,[rbp];sub rbp,8;cmp rax,rbx;jne ~"
">=?" "mov rbx,rax;mov rax,[rbp];sub rbp,8;cmp rax,rbx;jl ~"
"<=?" "mov rbx,rax;mov rax,[rbp];sub rbp,8;cmp rax,rbx;jg ~"
"<>?" "mov rbx,rax;mov rax,[rbp];sub rbp,8;cmp rax,rbx;je ~"
"AND?" "mov rbx,rax;mov rax,[rbp];sub rbp,8;test rax,rbx;jz ~"
"NAND?" "mov rbx,rax;mov rax,[rbp];sub rbp,8;test rax,rbx;jnz ~"
"IN?" "mov rdx,rax;mov rbx,[rbp];mov rax,[rbp-8];sub rbp,16;mov rcx,rax;sub rdx,rbx;sub rcx,rbx;cmp rcx,rdx;ja ~"
"DUP" "add rbp,8;mov [rbp],rax"
"DROP" "mov rax,[rbp];sub rbp,8"
"OVER" "add rbp,8;mov [rbp],rax;mov rax,[rbp-8]"
"PICK2" "add rbp,8;mov [rbp],rax;mov rax,[rbp-16]"
"PICK3" "add rbp,8;mov [rbp],rax;mov rax,[rbp-24]"
"PICK4" "add rbp,8;mov [rbp],rax;mov rax,[rbp-32]"
"SWAP" "xchg rax,[rbp]"
"NIP" "sub rbp,8"
"ROT" "mov rcx,[rbp];mov [rbp],rax;mov rax,[rbp-8];mov [rbp-8],rcx"
"-ROT" "mov rcx,[rbp-8];mov [rbp-8],rax;mov rax,[rbp];mov [rbp],rcx"
"2DUP" "mov rcx,[rbp];mov [rbp+8],rax;mov [rbp+16],rcx;add rbp,16"
"2DROP" "mov rax,[rbp-8];sub rbp,16"
"3DROP" "mov rax,[rbp-16];sub rbp,24"
"4DROP" "mov rax,[rbp-24];sub rbp,32"
"2OVER" "mov [rbp+8],rax;add rbp,16;mov rbx,[rbp-32];mov [rbp],rbx;mov rax,[rbp-24]"
"2SWAP" "xchg rax,[rbp-8];mov rcx,[rbp-16];xchg rcx,[rbp];mov [rbp-16],rcx"
">R" "push rax;mov rax,[rbp];sub rbp,8"
"R>" "add rbp,8;mov [rbp],rax;pop rax"
"R@" "add rbp,8;mov [rbp],rax;mov rax,[rsp]"
"AND" "and rax,[rbp];sub rbp,8"
"OR" "or rax,[rbp];sub rbp,8"
"XOR" "xor rax,[rbp];sub rbp,8"
"+" "add rax,[rbp];sub rbp,8"
"NAND" "not rax;and rax,[rbp];sub rbp,8"
"-" "neg rax;add rax,[rbp];sub rbp,8"
"*" "imul rax,[rbp];sub rbp,8"
"/" "mov rbx,rax;mov rax,[rbp];sub rbp,8;cqo;idiv rbx"
"MOD" "mov rbx,rax;mov rax,[rbp];sub rbp,8;cqo;idiv rbx;mov rax,rdx"
"/MOD" "mov rbx,rax;mov rax,[rbp];cqo;idiv rbx;mov [rbp],rax;xchg rax,rdx"
"<<" "mov cl,al;mov rax,[rbp];sub rbp,8;shl rax,cl"
">>" "mov cl,al;mov rax,[rbp];sub rbp,8;sar rax,cl"
">>>" "mov cl,al;mov rax,[rbp];sub rbp,8;shr rax,cl"
"*/" "mov rbx,rax;mov rcx,[rbp];mov rax,[rbp-8];sub rbp,16;cqo;imul rcx;idiv rbx"
"*>>" "mov rcx,rax;mov rax,[rbp];sub rbp,8;cqo;imul qword[rbp];shrd rax,rdx,cl;sar rdx,cl;and rcx,64;cmovne rax,rdx;sub rbp,8"
"<</" "mov rcx,rax;mov rbx,[rbp];mov rax,[rbp-8];sub rbp,16;cqo;shld rdx,rax,cl;shl rax,cl;idiv rbx"
"NOT" "not rax"
"NEG" "neg rax"
"ABS" "cqo;add rax,rdx;xor rax,rdx"
"SQRT" "cvtsi2sd xmm0,rax;sqrtsd xmm0,xmm0;cvttsd2si rax,xmm0"
"CLZ" "bsr rax,rax;xor rax,63"
"@" "mov rax,qword[rax]"
"@+" "mov rbx,qword[rax];add rax,8;add rbp,8;mov [rbp],rax;mov rax,rbx"
"!" "mov rcx,[rbp];mov [rax],rcx;mov rax,[rbp-8];sub rbp,16"
"!+" "mov rcx,[rbp];mov [rax],rcx;add rax,8;sub rbp,8"
"+!" "mov rcx,[rbp];add [rax],rcx;mov rax,[rbp-8];sub rbp,16"
">A" "mov r14,rax;mov rax,[rbp];sub rbp,8"
"A>" "add rbp,8;mov [rbp],rax;mov rax,r14"
"A+" "add r14,rax;mov rax,[rbp];sub rbp,8"
"A@" "add rbp,8;mov [rbp],rax;mov rax,qword[r14]"
"A!" "mov qword[r14],rax;mov rax,[rbp];sub rbp,8"
"A@+" "add rbp,8;mov [rbp],rax;mov rax,qword[r14];add r14,8"
"A!+" "mov qword[r14],rax;add r14,8;mov rax,[rbp];sub rbp,8"
">B" "mov r15,rax;mov rax,[rbp];sub rbp,8"
"B>" "add rbp,8;mov [rbp],rax;mov rax,r15"
"B+" "add r15,rax;mov rax,[rbp];sub rbp,8"
"B@" "add rbp,8;mov [rbp],rax;mov rax,qword[r15]"
"B!" "mov qword[r15],rax;mov rax,[rbp];sub rbp,8"
"B@+" "add rbp,8;mov [rbp],rax;mov rax,qword[r15];add r15,8"
"B!+" "mov qword[r15],rax;add r15,8;mov rax,[rbp];sub rbp,8"
"C@" "movsx rax,byte[rax]"
"C@+" "movsx rbx,byte[rax];add rax,1;add rbp,8;mov [rbp],rax;mov rax,rbx"
"C!" "mov rcx,[rbp];mov [rax],cl;mov rax,[rbp-8];sub rbp,16"
"C!+" "mov rcx,[rbp];mov [rax],cl;add rax,1;sub rbp,8"
"C+!" "mov rcx,[rbp];add [rax],cl;mov rax,[rbp-8];sub rbp,16"
"CA@" "add rbp,8;mov [rbp],rax;movsx rax,byte[r14]"
"CA!" "mov byte[r14],al;mov rax,[rbp];sub rbp,8"
"CA@+" "add rbp,8;mov [rbp],rax;movsx rax,byte[r14];add r14,1"
"CA!+" "mov byte[r14],al;add r14,1;mov rax,[rbp];sub rbp,8"
"CB@" "add rbp,8;mov [rbp],rax;movsx rax,byte[r15]"
"CB!" "mov byte[r15],al;mov rax,[rbp];sub rbp,8"
"CB@+" "add rbp,8;mov [rbp],rax;movsx rax,byte[r15];add r15,1"
"CB!+" "mov byte[r15],al;add r15,1;mov rax,[rbp];sub rbp,8"
"W@" "movsx rax,word[rax]"
"W@+" "movsx rbx,word[rax];add rax,2;add rbp,8;mov [rbp],rax;mov rax,rbx"
"W!" "mov rcx,[rbp];mov [rax],cx;mov rax,[rbp-8];sub rbp,16"
"W!+" "mov rcx,[rbp];mov [rax],cx;add rax,2;sub rbp,8"
"W+!" "mov rcx,[rbp];add [rax],cx;mov rax,[rbp-8];sub rbp,16"
"WA@" "add rbp,8;mov [rbp],rax;movsx rax,word[r14]"
"WA!" "mov word[r14],ax;mov rax,[rbp];sub rbp,8"
"WA@+" "add rbp,8;mov [rbp],rax;movsx rax,word[r14];add r14,2"
"WA!+" "mov word[r14],ax;add r14,2;mov rax,[rbp];sub rbp,8"
"WB@" "add rbp,8;mov [rbp],rax;movsx rax,word[r15]"
"WB!" "mov word[r15],ax;mov rax,[rbp];sub rbp,8"
"WB@+" "add rbp,8;mov [rbp],rax;movsx rax,word[r15];add r15,2"
"WB!+" "mov word[r15],ax;add r15,2;mov rax,[rbp];sub rbp,8"
"D@" "movsxd rax,dword[rax]"
"D@+" "movsxd rbx,dword[rax];add rax,4;add rbp,8;mov [rbp],rax;mov rax,rbx"
"D!" "mov rcx,[rbp];mov [rax],ecx;mov rax,[rbp-8];sub rbp,16"
"D!+" "mov rcx,[rbp];mov [rax],ecx;add rax,4;sub rbp,8"
"D+!" "mov rcx,[rbp];add [rax],ecx;mov rax,[rbp-8];sub rbp,16"
"DA@" "add rbp,8;mov [rbp],rax;movsxd rax,dword[r14]"
"DA!" "mov dword[r14],eax;mov rax,[rbp];sub rbp,8"
"DA@+" "add rbp,8;mov [rbp],rax;movsxd rax,dword[r14];add r14,4"
"DA!+" "mov dword[r14],eax;add r14,4;mov rax,[rbp];sub rbp,8"
"DB@" "add rbp,8;mov [rbp],rax;movsxd rax,dword[r15]"
"DB!" "mov dword[r15],eax;mov rax,[rbp];sub rbp,8"
"DB@+" "add rbp,8;mov [rbp],rax;movsxd rax,dword[r15];add r15,4"
"DB!+" "mov dword[r15],eax;add r15,4;mov rax,[rbp];sub rbp,8"
"AB[" "push r14;push r15"
"]BA" "pop r15;pop r14"
"MOVE" "mov rcx,rax;mov rsi,qword[rbp];mov rdi,qword[rbp-8];rep movsq;mov rax,[rbp-16];sub rbp,24"
"MOVE>" "mov rcx,rax;mov rsi,qword[rbp];mov rdi,qword[rbp-8];lea rsi,[rsi+rcx*8-8];lea rdi,[rdi+rcx*8-8];std;rep movsq;cld;mov rax,[rbp-16];sub rbp,24"
"FILL" "mov rcx,rax;mov rax,qword[rbp];mov rdi,qword[rbp-8];rep stosq;mov rax,[rbp-16];sub rbp,24"
"CMOVE" "mov rcx,rax;mov rsi,qword[rbp];mov rdi,qword[rbp-8];rep movsb;mov rax,[rbp-16];sub rbp,24"
"CMOVE>" "mov rcx,rax;mov rsi,qword[rbp];mov rdi,qword[rbp-8];lea rsi,[rsi+rcx-1];lea rdi,[rdi+rcx-1];std;rep movsb;cld;mov rax,[rbp-16];sub rbp,24"
"CFILL" "mov rcx,rax;mov rax,qword[rbp];mov rdi,qword[rbp-8];rep stosb;mov rax,[rbp-16];sub rbp,24"
"DMOVE" "mov rcx,rax;mov rsi,qword[rbp];mov rdi,qword[rbp-8];rep movsd;mov rax,[rbp-16];sub rbp,24"
"DMOVE>" "mov rcx,rax;mov rsi,qword[rbp];mov rdi,qword[rbp-8];lea rsi,[rsi+rcx*4-4];lea rdi,[rdi+rcx*4-4];std;rep movsd;cld;mov rax,[rbp-16];sub rbp,24"
"DFILL" "mov rcx,rax;mov rax,qword[rbp];mov rdi,qword[rbp-8];rep stosd;mov rax,[rbp-16];sub rbp,24"
"MEM" "add rbp,8;mov [rbp],rax;mov rax,[FREE_MEM]"
( 0 )

#fragwin
"LOADLIB" "cinvoke64 LoadLibraryA,rax"
"GETPROC" "cinvoke64 GetProcAddress,qword[rbp],rax;sub rbp,8"
"SYS0" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;CALL rax;add RSP,$20;mov rsp,[rsp]"
"SYS1" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;mov rcx,[rbp];call rax;sub rbp,8;add RSP,$20;mov rsp,[rsp]"
"SYS2" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;mov rdx,[rbp];mov rcx,[rbp-1*8];call rax;sub rbp,8*2;add RSP,$20;mov rsp,[rsp]"
"SYS3" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;mov r8,[rbp];mov rdx,[rbp-1*8];mov rcx,[rbp-2*8];call rax;sub rbp,8*3;add RSP,$20;mov rsp,[rsp]"
"SYS4" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;mov r9,[rbp];mov r8,[rbp-1*8];mov rdx,[rbp-2*8];mov rcx,[rbp-3*8];call rax;sub rbp,8*4;add RSP,$20;mov rsp,[rsp]"
"SYS5" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$30;mov rcx,[rbp];mov [rsp+$20],rcx;mov r9,[rbp-1*8];mov r8,[rbp-2*8];mov rdx,[rbp-3*8];mov rcx,[rbp-4*8];call rax;sub rbp,8*5;add RSP,$30;mov rsp,[rsp]"
"SYS6" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$30;mov rdx,[rbp];mov [rsp+$28],rdx;mov rcx,[rbp-1*8];mov [rsp+$20],rcx;mov r9,[rbp-2*8];mov r8,[rbp-3*8];mov rdx,[rbp-4*8];mov rcx,[rbp-5*8];call rax;sub rbp,8*6;add RSP,$30;mov rsp,[rsp]"
"SYS7" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$40;mov rcx,[rbp];mov [rsp+$30],rcx;mov rcx,[rbp-1*8];mov [rsp+$28],rcx;mov rcx,[rbp-2*8];mov [rsp+$20],rcx;mov r9,[rbp-3*8];mov r8,[rbp-4*8];mov rdx,[rbp-5*8];mov rcx,[rbp-6*8];call rax;sub rbp,8*7;add RSP,$40;mov rsp,[rsp]"
"SYS8" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$40;mov rcx,[rbp];mov [rsp+$38],rcx;mov rcx,[rbp-1*8];mov [rsp+$30],rcx;mov rcx,[rbp-2*8];mov [rsp+$28],rcx;mov rcx,[rbp-3*8];mov [rsp+$20],rcx;mov r9,[rbp-4*8];mov r8,[rbp-5*8];mov rdx,[rbp-6*8];mov rcx,[rbp-7*8];call rax;sub rbp,8*8;add RSP,$40;mov rsp,[rsp]"
"SYS9" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$50;mov rcx,[rbp];mov [rsp+$40],rcx;mov rcx,[rbp-1*8];mov [rsp+$38],rcx;mov rcx,[rbp-2*8];mov [rsp+$30],rcx;mov rcx,[rbp-3*8];mov [rsp+$28],rcx;mov rcx,[rbp-4*8];mov [rsp+$20],rcx;mov r9,[rbp-5*8];mov r8,[rbp-6*8];mov rdx,[rbp-7*8];mov rcx,[rbp-8*8];call rax;sub rbp,8*9;add RSP,$50;mov rsp,[rsp]"
"SYS10" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$50;mov rcx,[rbp];mov [rsp+$48],rcx;mov rcx,[rbp-1*8];mov [rsp+$40],rcx;mov rcx,[rbp-2*8];mov [rsp+$38],rcx;mov rcx,[rbp-3*8];mov [rsp+$30],rcx;mov rcx,[rbp-4*8];mov [rsp+$28],rcx;mov rcx,[rbp-5*8];mov [rsp+$20],rcx;mov r9,[rbp-6*8];mov r8,[rbp-7*8];mov rdx,[rbp-8*8];mov rcx,[rbp-9*8];call rax;sub rbp,8*10;add RSP,$50;mov rsp,[rsp]"
( 0 )

#fraglin
"LOADLIB" "mov  rdi, rax;mov  rsi, 2;acall dlopen"
"GETPROC" "mov  rdi, [rbp];mov  rsi, rax;sub  rbp, 8;acall dlsym"
"SYS0" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;call rax;mov rsp,[rsp]"
"SYS1" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov rdi,[rbp];call rax;sub rbp,8;mov rsp,[rsp]"
"SYS2" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov rsi,[rbp];mov rdi,[rbp-1*8];call rax;sub rbp,8*2;mov rsp,[rsp]"
"SYS3" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov rdx,[rbp];mov rsi,[rbp-1*8];mov rdi,[rbp-2*8];call rax;sub rbp,8*3;mov rsp,[rsp]"
"SYS4" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov rcx,[rbp];mov rdx,[rbp-1*8];mov rsi,[rbp-2*8];mov rdi,[rbp-3*8];call rax;sub rbp,8*4;mov rsp,[rsp]"
"SYS5" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov r8,[rbp];mov rcx,[rbp-1*8];mov rdx,[rbp-2*8];mov rsi,[rbp-3*8];mov rdi,[rbp-4*8];call rax;sub rbp,8*5;mov rsp,[rsp]"
"SYS6" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov r9,[rbp];mov r8,[rbp-1*8];mov rcx,[rbp-2*8];mov rdx,[rbp-3*8];mov rsi,[rbp-4*8];mov rdi,[rbp-5*8];call rax;sub rbp,8*6;mov rsp,[rsp]"
"SYS7" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub rsp,16;mov r10,[rbp];mov [rsp],r10;mov r9,[rbp-1*8];mov r8,[rbp-2*8];mov rcx,[rbp-3*8];mov rdx,[rbp-4*8];mov rsi,[rbp-5*8];mov rdi,[rbp-6*8];call rax;add rsp,16;sub rbp,8*7;mov rsp,[rsp]"
"SYS8" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub rsp,16;mov r10,[rbp];mov [rsp+8],r10;mov r10,[rbp-1*8];mov [rsp],r10;mov r9,[rbp-2*8];mov r8,[rbp-3*8];mov rcx,[rbp-4*8];mov rdx,[rbp-5*8];mov rsi,[rbp-6*8];mov rdi,[rbp-7*8];call rax;add rsp,16;sub rbp,8*8;mov rsp,[rsp]"
"SYS9" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub rsp,32;mov r10,[rbp];mov [rsp+16],r10;mov r10,[rbp-1*8];mov [rsp+8],r10;mov r10,[rbp-2*8];mov [rsp],r10;mov r9,[rbp-3*8];mov r8,[rbp-4*8];mov rcx,[rbp-5*8];mov rdx,[rbp-6*8];mov rsi,[rbp-7*8];mov rdi,[rbp-8*8];call rax;add rsp,32;sub rbp,8*9;mov rsp,[rsp]"
"SYS10" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub rsp,32;mov r10,[rbp];mov [rsp+24],r10;mov r10,[rbp-1*8];mov [rsp+16],r10;mov r10,[rbp-2*8];mov [rsp+8],r10;mov r10,[rbp-3*8];mov [rsp],r10;mov r9,[rbp-4*8];mov r8,[rbp-5*8];mov rcx,[rbp-6*8];mov rdx,[rbp-7*8];mov rsi,[rbp-8*8];mov rdi,[rbp-9*8];call rax;add rsp,32;sub rbp,8*10;mov rsp,[rsp]"
( 0 )


#osfrag 0	| list of the os (SYS, LOADLIB, GETPROC)
#ftab * 2048	| base word index -> fragment

| name list -- fragment/0
:findfrag
	( dup c@ 1? drop
		over over =s 1? ( drop nip >>0 ; ) drop
		>>0 >>0 )
	3drop 0 ;

#bn
:setfrag | i --
	dup basename 'bn !
	bn osfrag findfrag 0? ( drop bn 'fragc findfrag )
	swap 3 << 'ftab + ! ;

:buildtab
	0 ( dup basename c@ 1? drop dup setfrag 1+ ) 2drop ;

|---------------------------------------------------------------
| OUTPUT
|---------------------------------------------------------------
#jt		| jump label of the current token
#tcur	| address of the current token
#lbl	| 1 byte for each token, 1 if it is a jump target

:,lf 10 ,c ;
:,tab 9 ,c ;
:,wlab "w" ,s ,h ;
:,lab "l" ,s ,h ;

:,asmc | char --
	$3b =? ( drop 10 ,c 9 ,c ; )		| ;
	$7e =? ( drop "l" ,s jt ,h ; )		| ~
	,c ;

:,asm | "a;b;c" --
	,tab ( c@+ 1? ,asmc ) 2drop ;

:,ins ,asm ,lf ;

:,num | n -- ; decimal if it is an int32, else hex
	dup 32 << 32 >> <>? ( "$" ,s ,h ; ) ,d ;

|---------------------------------------------------------------
| TOKENS
|---------------------------------------------------------------
:tkv 8 >> $ffffffff and ;		| value
:tks 24 << 32 >> ;				| signed value
:tkidx tcur tok - 3 >> ;		| index of the current token
:jtarget | tok -- idx			| token after the jump
	tks 3 >> tkidx + 1+ ;

:lblset | idx --
	lbl + 1 swap c! ;

:marktok | tok --
	dup $ff and
	9 =? ( drop dup tkv 0? ( 2drop ; ) drop jtarget lblset ; )
	10 =? ( drop jtarget lblset ; )
	11 =? ( drop tkv lblset ; )
	13 25 in? ( drop jtarget lblset ; )
	2drop ;

:markword | nro --
	nro>dic toklen
	( 1? 1- swap
		dup 'tcur ! @+ marktok
		swap ) 2drop ;

|--- push
:,push "add rbp,8;mov [rbp],rax" ,ins ;
:,movax ,tab "mov rax," ,s ;
:,pushl | n --
	,push ,movax ,num ,lf ;

:gk0 40 >>> src + str>anro nip ,pushl ;		| big literal
:gk1 tks ,pushl ;							| literal
:gk2 ,tab "call " ,s tkv ,wlab ,lf ;		| word
:gk3 ,push ,movax "w" ,s tkv ,h ,lf ;		| 'word
:gk4 ,push ,movax "qword[w" ,s tkv ,h "]" ,s ,lf ;	| var
:gk5 gk3 ;									| 'var
:gk6 ,push ,movax "s" ,s tkv ,h ,lf ;		| "string"

#gtype 'gk0 'gk1 'gk2 'gk3 'gk4 'gk5 'gk6

:gk11 | tok --  ] push address of the anonymous
	,push ,movax "l" ,s tkv ,h ,lf ;

:gfrag | n --
	7 - 3 << 'ftab + @
	0? ( drop "; ERROR: no fragment" ,ins ; )
	,ins ;

:gbase | tok n --
	7 =? ( 2drop "ret" ,ins ; )
	8 =? ( 2drop ; )
	9 =? ( drop dup tkv 0? ( 2drop ; ) drop jtarget 'jt ! "jmp ~" ,ins ; )
	10 =? ( drop jtarget 'jt ! "jmp ~" ,ins ; )
	11 =? ( drop gk11 ; )
	13 25 in? ( swap jtarget 'jt ! gfrag ; )
	swap drop gfrag ;

:gentoken | tok --
	dup $ff and
	6 >? ( gbase ; )
	3 << 'gtype + @ ex ;

|---------------------------------------------------------------
| CODE
|---------------------------------------------------------------
:genword | nro --
	dup cntdef 1- =? ( "INICIO:" ,s ,lf ) drop
	dup ,wlab ":" ,s ,lf
	dup markword
	dup nro>dic toklen
	( 1? 1- swap
		dup 'tcur !
		tkidx lbl + c@ 1? ( tkidx ,lab ":" ,s ,lf ) drop
		@+ gentoken
		swap ) 2drop
	drop ;

:gencode1 | nro --
	dup nro>dic @ 1 and? ( 2drop ; ) drop
	genword ;

:gencode
	0 ( cntdef <? dup gencode1 1+ ) drop ;

|---------------------------------------------------------------
| DATA
|---------------------------------------------------------------
#cc
:,scch | ch --
	cc 60 >=? ( 2drop ; ) drop
	32 <? ( drop $2e ) ,c 1 'cc +! ;

:,scom | str --
	"; " ,s 0 'cc ! ( c@+ 1? ,scch ) 2drop ;

:,sbytes | str -- str'
	,tab "db " ,s
	( c@+ 1? ,d "," ,s ) drop
	"0" ,s ,lf ;

:genstrings
	strm ( strm> <?
		dup ,scom ,lf
		dup strm - "s%h:" ,print ,lf
		,sbytes )
	drop ;

#dsz 8	| size of the item 8 4 1, 0 = reserve
#dop -1	| directive of the open line
#dn 0	| items in the open line

:dflush
	dn 1? ( ,lf ) drop
	0 'dn ! -1 'dop ! ;

:dline | size --
	dop =? ( dn 16 <? ( drop drop 1 'dn +! "," ,s ; ) drop )
	dflush
	dup 'dop ! 1 'dn !
	,tab
	1 =? ( "db " ,s drop ; )
	4 =? ( "dd " ,s drop ; )
	"dq " ,s drop ;

:drb | n --
	dflush ,tab "rb " ,s ,d ,lf ;

:ditemn | n --
	dsz 0? ( drop drb ; ) dline ,num ;

:ditemw | idx --
	dsz 4 =? ( dline ,wlab ; ) drop 8 dline ,wlab ;

:ditems | str --
	dflush ,sbytes drop ;

:gdtoken | tok --
	dup $ff and
	0 =? ( drop 40 >>> src + str>anro nip ditemn ; )
	1 =? ( drop tks ditemn ; )
	3 =? ( drop tkv ditemw ; )
	5 =? ( drop tkv ditemw ; )
	6 =? ( drop tkv strm + ditems ; )
	8 =? ( 2drop 1 'dsz ! ; )
	9 =? ( 2drop 8 'dsz ! ; )
	10 =? ( 2drop 4 'dsz ! ; )
	11 =? ( 2drop 8 'dsz ! ; )
	51 =? ( 2drop 0 'dsz ! ; )
	2drop ;

:gendata | nro --
	"; " ,s dup nro>dic @ dic>name ,word ,lf
	dup ,wlab ":" ,s ,lf
	8 'dsz ! dflush
	dup nro>dic toklend
	0? ( 3drop 8 dline "0" ,s dflush ; )
	( 1? 1- swap @+ gdtoken swap ) 2drop
	drop dflush ;

:gendata1 | nro --
	dup nro>dic @ 1 and? ( drop gendata ; ) 2drop ;

:gendatas
	0 ( cntdef <? dup gendata1 1+ ) drop ;

|---------------------------------------------------------------
| FILES
|---------------------------------------------------------------
:savefile | "file" --
	savemem empty ;

:filecode
	mark
	"; r3 simple compiler - code" ,s ,lf
	gencode
	"asm/code.asm" savefile ;

:filedata
	mark
	"; r3 simple compiler - data" ,s ,lf
	genstrings
	"; vars" ,s ,lf
	gendatas
	"asm/data.asm" savefile ;

:fileset
	mark
	"; r3 simple compiler - settings" ,s ,lf
	switchmem 20 << "MEMSIZE equ 0x%h" ,print ,lf
	"VEROPT equ 1" ,s ,lf
	"asm/set.asm" savefile ;

|---------------------------------------------------------------
| the target is in the header of plain.r3 ( | target LIN )
:targetplain
	src "| target " findstr 0? ( drop ; )
	9 + 0
	( 4 <?
		over over 2 << 'osnames + =pre
		1? ( pick2 'osgen ! ) 2drop
		1+ ) 2drop ;

:selos | -- adr
	osgen 0? ( drop 'fragwin ; ) drop 'fraglin ;

:checktab
	5 ( dup basename c@ 1? drop
		dup 3 << 'ftab + @ 0? ( over basename "no fragment: %s" .println ) drop
		1+ ) 2drop ;

:compiling..
	targetplain
	selos 'osfrag ! buildtab
	checktab
	here dup 'lbl ! cnttok + 'here !
	lbl 0 cnttok cfill
	filecode
	filedata
	fileset
	cnttok cntdef "words:%d tokens:%d" .println ;

:
	.reset
	"r3 simple compiler" .println
	'osnames osgen $3 and 2 << + "target: %s" .println
	'filename r3load
	error 1? ( .println drop ; ) drop
	compiling..
	
|WIN|	"asm\compile.bat" sys "r3fasm.exe" sys	
|LIN|	".\asm\compilelin.sh" sys
	;
