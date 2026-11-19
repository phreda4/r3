| r3 simple compiler 3 - plain.r3 to assembler text (fasm)
|   tier 0: every word of the base is a canonical fragment ( r3cf.r3 ), no virtual stack.
|   it begins as a copy of r3comp.r3 , that one is not changed
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
^r3/d4/r3opt1.r3
^r3/d4/r3cf.r3
^r3/d4/r3ssa.r3

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


:,sysfn "rax" ,s ;		| the function of the SYS is in rax

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
	bn osfrag findfrag 0? ( drop bn 'fragcf findfrag ) 
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

#irlim 1000	| debug: the words >= irlim are made with tier 0
#irw 1		| the IR is used in the current word
#looprg 1	| debug: 0 = no cells in registers

|---------------------------------------------------------------
| LOOPS WITH THE CELLS OF THE STACK IN REGISTERS
|---------------------------------------------------------------
| a loop ( ... ) that has only tokens of the IR ( no calls ) and where the stack has the same
| depth in all the boundaries of the blocks has the cells 1..k in registers ( rsi rdi r8 r9 ),
| the cell 0 is in rax as always. Before the head the cells are loaded ( the jump back goes to
| the label p ) and at the exit label they are stored.
#lpn 0
#lpL * 512
#lpE * 512
#lpK * 512
#lpX * 512
#sl0 #wn0 #cl #ce #ci #cty #cdp #cu #cok #cuse #cdel #ctg #ctk2 #ck2 #pk

:tkat | idx -- addr
	3 << tok + ;
:rej 0 'cok ! ;
:jump? | -- f ; the token jumps
	cty 9 =? ( drop ctk2 tkv 1? ( drop 1 ; ) drop 0 ; )
	10 =? ( drop 1 ; ) 13 25 in? ( drop 1 ; ) drop 0 ;

:chkone | i --
	'ci !
	cok 0? ( drop ; ) drop
	ci tkat dup 'tcur ! @ 'ctk2 !
	ctk2 $ff and 'cty !
	ci lbl + c@ 1? ( cdp 1? ( rej ) drop ) drop
	cty ssa.ok? 0? ( rej ) drop
	cty 9 =? ( ctk2 tkv 1? ( ci ce <>? ( rej ) drop ) drop ) drop
	cty r3ainfo dup c@ 'cuse ! 1+ c@ 'cdel !
	cuse cdp - dup cu >? ( dup 'cu ! ) 2drop
	cdel 'cdp +!
	jump? 1? (
		ctk2 jtarget 'ctg !
		ctg cl =? ( cty 9 <>? ( rej ) drop ) drop
		ctg cl <? ( rej ) drop
		ctg ce 1+ >? ( rej ) drop
		cty 9 =? ( ctg cl <>? ( rej ) drop ) drop
		cty 13 25 in? ( cdp 1? ( rej ) drop ) drop
		cty 9 =? ( cdp 1? ( rej ) drop ) drop
		) drop ;

:outside? | -- f
	ci cl <? ( drop 1 ; ) drop ci ce >? ( drop 1 ; ) drop 0 ;
:chkout1 | idx --
	'ci ! outside? 0? ( drop ; ) drop
	ci tkat dup 'tcur ! @ dup 'ctk2 ! $ff and 'cty !
	jump? 0? ( drop ; ) drop
	ctk2 jtarget 'ctg !
	ctg cl >? ( ctg ce 1+ <=? ( rej ) drop ) drop ;

:chkloop | L E --
	'ce ! 'cl !
	0 'cdp ! 0 'cu ! 1 'cok !
	lpn 60 >=? ( rej ) drop
	cl ( ce 1+ <? dup chkone 1+ ) drop
	ce 1+ lbl + c@ 0? ( rej ) drop
	sl0 ( sl0 wn0 + <? dup chkout1 1+ ) drop
	cok 0? ( drop ; ) drop
	cu 1- 4 >? ( drop 4 ) 'ck2 !
	ck2 1 <? ( drop ; ) drop
	cl lpn 3 << 'lpL + ! ce lpn 3 << 'lpE + !
	ck2 lpn 3 << 'lpK + ! ce 1+ lpn 3 << 'lpX + !
	1 'lpn +! ;

:try1 | tokv --
	dup $ff and 9 <>? ( 2drop ; ) drop
	dup tkv 0? ( 2drop ; ) drop
	jtarget tkidx chkloop ;

:scanloops | ptr n --
	0 'lpn !
	looprg 0? ( drop 2drop ; ) drop
	irw 0? ( drop 2drop ; ) drop
	'wn0 ! dup tok - 3 >> 'sl0 !
	drop
	sl0 ( sl0 wn0 + <? dup tkat dup 'tcur ! @ try1 1+ ) drop ;

:findhead | idx -- n ; -1 if none
	0 ( lpn <?
		dup 3 << 'lpL + @ pick2 =? ( drop nip ; ) drop
		1+ ) 2drop -1 ;
:findexit | idx -- n
	0 ( lpn <?
		dup 3 << 'lpX + @ pick2 =? ( drop nip ; ) drop
		1+ ) 2drop -1 ;

:ldcell | j -- ; mov R_j,[cell j]
	ib "mov " ,s dup 3 + ssa.,reg ",qword[rbp" ,s 1- 3 << neg ssa.,off "]" ,s ,iend ;
:stcell | j -- ; mov [cell j],R_j
	ib "mov qword[rbp" ,s dup 1- 3 << neg ssa.,off "]," ,s 3 + ssa.,reg ,iend ;
:promote | n --
	3 << 'lpK + @ 'pk !
	1 ( pk <=? dup ldcell 1+ ) drop ;
:unpromote | n --
	3 << 'lpK + @ 'pk !
	1 ( pk <=? dup stcell 1+ ) drop ;

:atlabel | --
	ssa.flush
	ib tkidx ,lab ":" ,s ie opt.label
	tkidx findexit 0 >=? ( dup unpromote 0 ssa.promote ) drop
	tkidx findhead 0 >=? ( dup promote
		ib "p" ,s tkidx ,h ":" ,s ie opt.label
		dup 3 << 'lpK + @ ssa.promote ) drop ;

:gbase | tok n --
	7 =? ( 2drop "ret" ,ins ; )
	8 =? ( 2drop ; )
	9 =? ( drop dup tkv 0? ( 2drop ; ) drop jtarget 'jt ! jt findhead 0 >=? ( drop ib "jmp p" ,s jt ,h ,iend ; ) drop "jmp ~" ,ins ; )
	10 =? ( drop jtarget 'jt ! "jmp ~" ,ins ; )
	11 =? ( drop gk11 ; )
	swap drop gfrag ;

:,pushax "add rbp,8;mov [rbp],rax" ,ins ;
:gl0 | tok -- ; literal as in the source ( 1.5 )
	,pushax 40 >>> src + str>anro nip ib "mov rax," ,s ,num ,iend ;
:gl1 | tok --
	,pushax tks ib "mov rax," ,s ,num ,iend ;
:gl3 | tok -- ; address of a word or var
	,pushax ib "mov rax," ,s tkv ,wlab ,iend ;
:gl4 | tok -- ; value of a var
	,pushax ib "mov rax,qword[" ,s tkv ,wlab "]" ,s ,iend ;
:gl6 | tok -- ; address of a string
	,pushax ib "mov rax,s" ,s tkv ,h ,iend ;

:gentoken | tok --
	dup $ff and 13 25 in? ( over jtarget 'jt ! ) drop
	irw 1? ( drop dup ssa.tok 1? ( 2drop ; ) ) drop
	ssa.flush
	dup $ff and
	0 =? ( drop gl0 ; )
	1 =? ( drop gl1 ; )
	2 =? ( drop gk2 ; )
	3 =? ( drop gl3 ; )
	4 =? ( drop gl4 ; )
	5 =? ( drop gl3 ; )
	6 =? ( drop gl6 ; )
	gbase ;

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

:irok | nro --
	irlim <? ( drop 1 'irw ! ; ) drop 0 'irw ! ;

:genword | nro --
	dup irok
	ssa.flush opt.flush dup nro>dic @ dic>name ,rem
	dup cntdef 1- =? ( "INICIO:" opt.label ) drop
	ib dup ,wlab ":" ,s ie opt.label
	dup markword
	dup nro>dic toklen scanloops
	dup nro>dic toklen
	( 1? 1- swap
		dup 'tcur !
		tkidx lbl + c@ 1? ( atlabel ) drop
		@+ gentoken
		swap ) 2drop
	ssa.flush drop ;

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
	opt.reset ssa.begin
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

:compiling..
	targetplain
	selos 'osfrag ! buildtab
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
	"r3 simple compiler 3 ( tier 0 )" .println
	'osnames osgen $3 and 2 << + "target: %s" .println
	'filename r3load
	error 1? ( .println drop ; ) drop
	compiling..
	
|WIN|	"asm\compile.bat" sys "r3fasm.exe" sys	
|LIN|	"./asm/compilelin.sh" sys "./r3forth" sys
	;
