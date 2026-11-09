| r3 simple compiler - plain.r3 to assembler text (fasm)
| PHREDA 2026
|---------------------------------------------------------------
| the base words are made by r3vstk (virtual stack + descriptors) and r3opt1 (rbp folding)
| fragments here: only the words of the system (LOADLIB GETPROC SYS0..SYS10)
| input : r3/d4/gen/plain.r3 (made by r3plain.r3)
| output: asm/code.asm asm/data.asm asm/set.asm (see asm/r3fasm*.asm)
|
| registers
|   rax = TOS     rbp = data stack pointer, [rbp] = NOS (grows up)
|   rsp = return stack      r14 = A    r15 = B
|   rbx rcx rdx rsi rdi r8-r13 = scratch
|
| fragments: ';' separates instructions, '~' is the jump label
| labels: wN = word or var N (dic index), lN = token N, sN = string at strm+N
|---------------------------------------------------------------
^r3/lib/console.r3
^r3/d4/r3token.r3
^r3/d4/r3opt1.r3
^r3/d4/r3vstk.r3

#filename "r3/d4/gen/plain.r3"
#osnames "WIN" "LIN" "MAC" "RPI"

|---------------------------------------------------------------
| FRAGMENTS of the system words (names as in r3base)
|---------------------------------------------------------------
#fragwin
"LOADLIB" "cinvoke64 LoadLibraryA,rax"
"GETPROC" "cinvoke64 GetProcAddress,qword[rbp],rax;sub rbp,8"
"SYS0" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;CALL ^;add RSP,$20;mov rsp,[rsp]"
"SYS1" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;mov rcx,[rbp];call ^;sub rbp,8;add RSP,$20;mov rsp,[rsp]"
"SYS2" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;mov rdx,[rbp];mov rcx,[rbp-1*8];call ^;sub rbp,8*2;add RSP,$20;mov rsp,[rsp]"
"SYS3" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;mov r8,[rbp];mov rdx,[rbp-1*8];mov rcx,[rbp-2*8];call ^;sub rbp,8*3;add RSP,$20;mov rsp,[rsp]"
"SYS4" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$20;mov r9,[rbp];mov r8,[rbp-1*8];mov rdx,[rbp-2*8];mov rcx,[rbp-3*8];call ^;sub rbp,8*4;add RSP,$20;mov rsp,[rsp]"
"SYS5" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$30;mov rcx,[rbp];mov [rsp+$20],rcx;mov r9,[rbp-1*8];mov r8,[rbp-2*8];mov rdx,[rbp-3*8];mov rcx,[rbp-4*8];call ^;sub rbp,8*5;add RSP,$30;mov rsp,[rsp]"
"SYS6" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$30;mov rdx,[rbp];mov [rsp+$28],rdx;mov rcx,[rbp-1*8];mov [rsp+$20],rcx;mov r9,[rbp-2*8];mov r8,[rbp-3*8];mov rdx,[rbp-4*8];mov rcx,[rbp-5*8];call ^;sub rbp,8*6;add RSP,$30;mov rsp,[rsp]"
"SYS7" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$40;mov rcx,[rbp];mov [rsp+$30],rcx;mov rcx,[rbp-1*8];mov [rsp+$28],rcx;mov rcx,[rbp-2*8];mov [rsp+$20],rcx;mov r9,[rbp-3*8];mov r8,[rbp-4*8];mov rdx,[rbp-5*8];mov rcx,[rbp-6*8];call ^;sub rbp,8*7;add RSP,$40;mov rsp,[rsp]"
"SYS8" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$40;mov rcx,[rbp];mov [rsp+$38],rcx;mov rcx,[rbp-1*8];mov [rsp+$30],rcx;mov rcx,[rbp-2*8];mov [rsp+$28],rcx;mov rcx,[rbp-3*8];mov [rsp+$20],rcx;mov r9,[rbp-4*8];mov r8,[rbp-5*8];mov rdx,[rbp-6*8];mov rcx,[rbp-7*8];call ^;sub rbp,8*8;add RSP,$40;mov rsp,[rsp]"
"SYS9" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$50;mov rcx,[rbp];mov [rsp+$40],rcx;mov rcx,[rbp-1*8];mov [rsp+$38],rcx;mov rcx,[rbp-2*8];mov [rsp+$30],rcx;mov rcx,[rbp-3*8];mov [rsp+$28],rcx;mov rcx,[rbp-4*8];mov [rsp+$20],rcx;mov r9,[rbp-5*8];mov r8,[rbp-6*8];mov rdx,[rbp-7*8];mov rcx,[rbp-8*8];call ^;sub rbp,8*9;add RSP,$50;mov rsp,[rsp]"
"SYS10" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub RSP,$50;mov rcx,[rbp];mov [rsp+$48],rcx;mov rcx,[rbp-1*8];mov [rsp+$40],rcx;mov rcx,[rbp-2*8];mov [rsp+$38],rcx;mov rcx,[rbp-3*8];mov [rsp+$30],rcx;mov rcx,[rbp-4*8];mov [rsp+$28],rcx;mov rcx,[rbp-5*8];mov [rsp+$20],rcx;mov r9,[rbp-6*8];mov r8,[rbp-7*8];mov rdx,[rbp-8*8];mov rcx,[rbp-9*8];call ^;sub rbp,8*10;add RSP,$50;mov rsp,[rsp]"
( 0 )

#fraglin
"LOADLIB" "mov  rdi, rax;mov  rsi, 2;acall dlopen"
"GETPROC" "mov  rdi, [rbp];mov  rsi, rax;sub  rbp, 8;acall dlsym"
"SYS0" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;call ^;mov rsp,[rsp]"
"SYS1" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov rdi,[rbp];call ^;sub rbp,8;mov rsp,[rsp]"
"SYS2" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov rsi,[rbp];mov rdi,[rbp-1*8];call ^;sub rbp,8*2;mov rsp,[rsp]"
"SYS3" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov rdx,[rbp];mov rsi,[rbp-1*8];mov rdi,[rbp-2*8];call ^;sub rbp,8*3;mov rsp,[rsp]"
"SYS4" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov rcx,[rbp];mov rdx,[rbp-1*8];mov rsi,[rbp-2*8];mov rdi,[rbp-3*8];call ^;sub rbp,8*4;mov rsp,[rsp]"
"SYS5" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov r8,[rbp];mov rcx,[rbp-1*8];mov rdx,[rbp-2*8];mov rsi,[rbp-3*8];mov rdi,[rbp-4*8];call ^;sub rbp,8*5;mov rsp,[rsp]"
"SYS6" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;mov r9,[rbp];mov r8,[rbp-1*8];mov rcx,[rbp-2*8];mov rdx,[rbp-3*8];mov rsi,[rbp-4*8];mov rdi,[rbp-5*8];call ^;sub rbp,8*6;mov rsp,[rsp]"
"SYS7" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub rsp,16;mov r10,[rbp];mov [rsp],r10;mov r9,[rbp-1*8];mov r8,[rbp-2*8];mov rcx,[rbp-3*8];mov rdx,[rbp-4*8];mov rsi,[rbp-5*8];mov rdi,[rbp-6*8];call ^;add rsp,16;sub rbp,8*7;mov rsp,[rsp]"
"SYS8" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub rsp,16;mov r10,[rbp];mov [rsp+8],r10;mov r10,[rbp-1*8];mov [rsp],r10;mov r9,[rbp-2*8];mov r8,[rbp-3*8];mov rcx,[rbp-4*8];mov rdx,[rbp-5*8];mov rsi,[rbp-6*8];mov rdi,[rbp-7*8];call ^;add rsp,16;sub rbp,8*8;mov rsp,[rsp]"
"SYS9" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub rsp,32;mov r10,[rbp];mov [rsp+16],r10;mov r10,[rbp-1*8];mov [rsp+8],r10;mov r10,[rbp-2*8];mov [rsp],r10;mov r9,[rbp-3*8];mov r8,[rbp-4*8];mov rcx,[rbp-5*8];mov rdx,[rbp-6*8];mov rsi,[rbp-7*8];mov rdi,[rbp-8*8];call ^;add rsp,32;sub rbp,8*9;mov rsp,[rsp]"
"SYS10" "mov rdx,rsp;sub rsp,8;and rsp,-16;mov [rsp],rdx;sub rsp,32;mov r10,[rbp];mov [rsp+24],r10;mov r10,[rbp-1*8];mov [rsp+16],r10;mov r10,[rbp-2*8];mov [rsp+8],r10;mov r10,[rbp-3*8];mov [rsp],r10;mov r9,[rbp-4*8];mov r8,[rbp-5*8];mov rcx,[rbp-6*8];mov rdx,[rbp-7*8];mov rsi,[rbp-8*8];mov rdi,[rbp-9*8];call ^;add rsp,32;sub rbp,8*10;mov rsp,[rsp]"
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
	bn osfrag findfrag
	swap 3 << 'ftab + ! ;

:buildtab
	0 ( dup basename c@ 1? drop dup setfrag 1+ ) 2drop ;

|---------------------------------------------------------------
| OUTPUT
|---------------------------------------------------------------
#tcur	| address of the current token
#lbl	| 1 byte for each token, 1 if it is a jump target

:,lf 10 ,c ;
:,tab 9 ,c ;
:,wlab "w" ,s ,h ;
:,lab "l" ,s ,h ;

:,asmc | char --
	$3b =? ( drop ie opt.ins ib ; )		| ;
	$7e =? ( drop "l" ,s jt ,h ; )		| ~
	$5e =? ( drop ,sysfn ; )			| ^ the function of the SYS
	,c ;

:,asm | "a;b;c" -- ; each instruction goes to the optimizer
	ib ( c@+ 1? ,asmc ) 2drop ie opt.ins ;

:,ins ,asm ;

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
:,movax ib "mov rax," ,s ;
:,iend ie opt.ins ;
:gk2 ib "call " ,s tkv ,wlab ,iend ;		| word
:gk11 | tok --  ] push address of the anonymous
	,push ,movax "l" ,s tkv ,h ,iend ;

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
	swap drop gfrag ;

:gentoken | tok --
	dup $ff and 13 25 in? ( over jtarget 'jt ! ) drop
	dup vs.tok 1? ( 2drop ; ) drop
	vs.norm
	dup $ff and
	6 >? ( gbase ; )
	drop gk2 ;			| only the call of a word is made here

|---------------------------------------------------------------
| CODE
|---------------------------------------------------------------
|--- the comment that plain.r3 has over each word: | :name | stack --
:backcr | adr -- adr'	| the CR before adr
	( 1- dup c@ 13 <>? drop ) drop ;

:,rem | name --			| name = the name of the word in plain.r3
	dup backcr dup backcr 1+		| name end start
	dup c@ $7c <>? ( 3drop "; " ,s ,word ,lf ; ) drop
	59 ,c 1+					| ; instead of |
	( over <? c@+ 92 =? ( drop 47 ) ,c ) 3drop ,lf ;

:genword | nro --
	opt.flush dup nro>dic @ dic>name ,rem
	dup cntdef 1- =? ( "INICIO:" opt.label ) drop
	vs.norm ib dup ,wlab ":" ,s ie opt.label
	vs.reset
	dup markword
	dup nro>dic toklen
	( 1? 1- swap
		dup 'tcur !
		tkidx lbl + c@ 1? ( vs.norm ib tkidx ,lab ":" ,s ie opt.label ) drop
		@+ gentoken
		swap ) 2drop
	vs.norm drop ;

:gencode1 | nro --
	dup nro>dic @ 1 and? ( 2drop ; ) drop
	genword ;

:gencode
	0 ( cntdef <? dup gencode1 1+ ) drop ;

|---------------------------------------------------------------
| DATA
|---------------------------------------------------------------
#strsrc		| strm offset -> the string in the source ( 0 = unknown )

:ssrc | tok -- adr			| first char of the string in the source ( after the " )
	40 >>> src + 1+ ;

:cpycadsrc | adr --			| the text as in the source, control chars as numbers
	( c@+ 1?
		34 =? ( drop c@+
			34 <>? ( 2drop ; )
			"""," ,s dup ,d "," ,s )
		$ff and 32 <? ( """," ,s ,d "," ,s 34 )
		,c ) 2drop ;

:,srcstr | adr --			| "text",0
	34 ,c cpycadsrc 34 ,c ",0" ,s ,lf ;

:,sbytes | str -- str'		| bytes, only if the source of the string is unknown
	,tab "db " ,s
	( c@+ 1? ,d "," ,s ) drop
	"0" ,s ,lf ;

:,sstr | str -- str'		| string of strm, the text of the source if is known
	dup strm - 3 << strsrc + @
	1? ( ,tab "db " ,s ,srcstr >>0 ; ) drop
	,sbytes ;

:genstrings
	strm ( strm> <?
		dup strm - "s%h:" ,print ,lf
		,sstr )
	drop ;

|--- the source of each string of the code
:mapstr1 | tok --
	dup $ff and 6 <>? ( 2drop ; ) drop
	dup tkv 3 << strsrc + dup @ 1? ( 3drop ; ) drop
	swap ssrc swap ! ;

:mapstrw | nro --
	nro>dic toklen
	( 1? 1- swap @+ mapstr1 swap ) 2drop ;

:mapstr1w | nro --
	dup nro>dic @ 1 and? ( 2drop ; ) drop mapstrw ;

:mapstrs
	here dup 'strsrc ! strm> strm - 3 << + 'here !
	strsrc 0 strm> strm - fill
	0 ( cntdef <? dup mapstr1w 1+ ) drop ;

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

:ditems | adr --
	dflush ,tab "db " ,s ,srcstr ;

:gdtoken | tok --
	dup $ff and
	0 =? ( drop 40 >>> src + str>anro nip ditemn ; )
	1 =? ( drop tks ditemn ; )
	3 =? ( drop tkv ditemw ; )
	5 =? ( drop tkv ditemw ; )
	6 =? ( drop ssrc ditems ; )
	8 =? ( 2drop 1 'dsz ! ; )
	9 =? ( 2drop 8 'dsz ! ; )
	10 =? ( 2drop 4 'dsz ! ; )
	11 =? ( 2drop 8 'dsz ! ; )
	51 =? ( 2drop 0 'dsz ! ; )
	2drop ;

:gendata | nro --
	dup nro>dic @ dic>name ,rem
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
	opt.reset vs.reset
	gencode
	opt.end
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
		dup 3 << 'ftab + @ 0?
			( over vs.handled? 0? ( pick2 basename "no handler or fragment: %s" .println ) drop )
		drop
		1+ ) 2drop ;

:compiling..
	targetplain
	selos 'osfrag ! buildtab
	vs.init
	checktab
	here dup 'lbl ! cnttok + 'here !
	lbl 0 cnttok cfill
	mapstrs
	filecode
	filedata
	fileset
	cnttok cntdef "words:%d tokens:%d" .println
	nout nins "instructions: %d -> %d" .println ;

:
	.reset
	"r3 simple compiler" .println
	'osnames osgen $3 and 2 << + "target: %s" .println
	'filename r3load
	error 1? ( .println drop ; ) drop
	compiling..
	
|WIN|	"asm\compile.bat" sys "r3fasm.exe" sys	
|LIN|	"./asm/compilelin.sh" sys "./r3forth" sys
	;
