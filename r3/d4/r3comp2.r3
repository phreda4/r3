| r3 simple compiler 2 - plain.r3 to assembler text (fasm)
|   copy of r3comp.r3 ( that one is not changed ) : with instrumentation of the normalization
|   and ( prototype ) registers in the virtual stack across conditions and loops
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
^r3/d4/r3vstk2.r3

#filename "mem/plain.r3"
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
#lxt	| 1 byte for each token, 1 if it is the exit of a loop ( the token after the jump back )
#wclob #wflg #wvr #wvm #rowb #wcur #rok #wrc #wfn #rcn #rcu #rco
#lvp	| 1 byte for each token: head of a loop with variables in registers ( not in loop mode ) = slot
#lve	| 1 byte for each token: exit of a loop with variables in registers = slot
#lhd	| 1 byte for each token: 1 = head of a loop
#vesc	| 1 byte for each word: 1 = the address of the variable is used as something else than ( 'v @ ) ( 'v ! ) ( 'v +! )
#lrt	| rotated loops: in the jump back the tokens of the test ( the jump included ), in the jump of the test $80
#lri	| rotated loops: number of the loop in the jump back and in the jump of the test
#rfok * 64	| rotated loops: 0 = not rotated, else the mode of the jump of the test ( 1 the state goes on , 2 canonical )
#rotal 16		| align of the body of the rotated loops ( 0 = none )
#rotlp 1		| 0 = no rotated loops
#rcon 1		| 0 = no call by registers
#rotn 0 #rotall 0
#ldep	| 1 byte for each token, the loops that contain the token
#lpm	| 1 qword for each token: head of a loop with the cells in registers = cells | exit<<8
#lpdt	| 1 byte for each token: depth of the jumps to the labels inside the loop
#lpnum 0	| loops with the cells in registers
#lpall 0	| loops
#lpen 1		| 0 = no loops in registers
#pw 1 10 100 1000 10000 100000 1000000 10000000

:,lf 10 ,c ;
:,tab 9 ,c ;
:,wlab "w" ,s ,h ;
:,lab "l_" ,s ,h ;

:,asmc | char --
	$3b =? ( drop ie opt.ins ib ; )		| ;
	$7e =? ( drop "l_" ,s jt ,h ; )		| ~
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


|---------------------------------------------------------------
| LOOPS WITH THE CELLS OF THE STACK IN REGISTERS
|---------------------------------------------------------------
| the loop must have only tokens that the virtual stack makes ( no calls, no EX, no SYS ),
| the loops inside are part of it ( only the outermost is marked ), the jumps only to the exit or to labels inside, the same depth in
| the jump and in the label and at the jump back, and few cells ( the cell j is in G_j ).
#ph #pc #pok #pcu #pdp #pmx #pex #pty #pi #psv #ptt #ptsv

:tkat | idx -- addr
	3 << tok + ;
:prej 0 'pok ! ;

:pjump | --			| jump of a condition
	psv jtarget 'ptt !
	ptt ph <=? ( prej ) drop
	ptt pc 1+ >? ( prej ) drop
	ptt pc 1+ =? ( 1 'pex +! ) drop
	ptt pc 1+ <? ( pdp 64 + ptt lpdt + c! ) drop ;

:plabel | --			| depth of the label : the first time is saved
	pi lpdt + c@
	0? ( drop pdp 64 + pi lpdt + c! ; )
	pdp 64 + <>? ( prej ) drop ;

:pscan1 | idx --
	'pi ! pok 0? ( drop ; ) drop
	pi tkat dup 'tcur ! @ dup 'psv ! $ff and 'pty !
	pty vs.pure? 0? ( prej ) drop
	pi lbl + c@ 1? ( plabel ) drop
	pty 9 =? ( psv tkv 1? ( psv jtarget lpdt + c@ pdp 64 + <>? ( prej ) drop ) drop ) drop
	pty r3ainfo dup c@ swap 1+ c@ 56 << 56 >>		| use delta
	swap pdp - dup pcu >? ( dup 'pcu ! ) 2drop
	pdp + dup 'pdp ! pmx max 'pmx !
	pty 13 25 in? ( pjump ) drop
	pi pc =? ( pdp 1? ( prej ) drop ) drop ;

|---------------------------------------------------------------
| VARIABLES IN REGISTERS : in a loop with the cells in registers ( no calls ) the variables that only have direct uses
| are in registers G_j ( j after the cells ): loaded before the head, written in the exits if the loop writes them.
|---------------------------------------------------------------
#pvc * 128	| the variables of the loop
#pvk * 128	| the uses
#pvw * 128	| 1 = written
#pvu 0 #pvi #pvv1 #pvm1 #pvres #pvnf #pvch #pvsa
#pvs * 8192	| 256 slots of 4 qwords: var+1 | write<<32 | register<<40 , the 4th: head | exit<<32
#pvsn 0 #pvtot 0 #pvloops 0
#pgr ( 3 6 7 8 9 10 11 )
#pvmin 2		| uses of a variable in the loop to put it in a register

:pvsrch | v -- i
	-1 'pvres !
	0 ( pvu <? dup 3 << 'pvc + @ pick2 =? ( over 'pvres ! ) drop 1+ ) drop drop pvres ;

:pvnew | --
	pvu 'pvi ! 1 'pvu +!
	pvv1 pvi 3 << 'pvc + !
	0 pvi 3 << 'pvk + ! 0 pvi 3 << 'pvw + ! ;

:btest | i row -- f		| bit i of the bitmap
	over 3 >> + c@ swap 7 and >> 1 and ;

#pvcl * 192	| the words that the loop calls
#pvnc 0 #pvcm 0	| how many , the registers that they write
#pvrg * 24 #pvnr 0

:pvcall | c --
	dup wcur =? ( 2drop 0 'rok ! ; ) drop
	dup 3 << wrc + @ 1? ( pvcm $39 or 'pvcm ! ) drop
	pvnc 24 >=? ( 2drop 0 'rok ! ; ) drop
	dup 3 << wclob + @ -1 =? ( 2drop 0 'rok ! ; )
	pvcm or 'pvcm !
	pvnc 3 << 'pvcl + ! 1 'pvnc +! ;

:pvtouch? | var -- f		| a word that the loop calls reads or writes the variable ( or runs an unknown word )
	'pvv1 ! 0 'pvres !
	0 ( pvnc <? dup 3 << 'pvcl + @
		dup 3 << wflg + @ 4 and 1? ( 1 'pvres ! ) drop
		dup pvv1 swap rowb * wvr + btest
		over pvv1 swap rowb * wvm + btest or 1? ( 1 'pvres ! ) drop
		drop 1+ ) drop pvres ;

:pvr1 | i --
	'pgr + c@ dup 1 swap << pvcm and 1? ( 2drop ; ) drop
	pvnr 3 << 'pvrg + ! 1 'pvnr +! ;

:pvregs | --		| registers for the variables of a loop that is not in loop mode: the ones that the calls do not write
	0 'pvnr ! 6 ( 0 >=? dup pvr1 1- ) drop ;

:pvadd | var mod --
	'pvm1 ! 'pvv1 !
	pvv1 vesc + c@ 1? ( drop ; ) drop
	pvnc 0 >? ( pvv1 pvtouch? 1? ( 2drop ; ) drop ) drop
	pvv1 pvsrch 'pvi !
	pvi 0 <? ( pvu 16 <? ( pvnew ) drop ) drop
	pvi -? ( drop ; ) drop
	1 pvi 3 << 'pvk + +!
	pvm1 1? ( 1 pvi 3 << 'pvw + ! ) drop ;

:pvtok | idx --
	dup tkat @ dup $ff and
	4 =? ( drop tkv 0 pvadd drop ; )
	5 =? ( drop tkv swap 1+ tkat @ $ff and
		74 =? ( drop 1 pvadd ; ) 82 =? ( drop 1 pvadd ; ) 66 =? ( drop 0 pvadd ; ) 2drop ; )
	3drop ;

:pvsel | i --
	pvch pvnf >=? ( 2drop ; ) drop
	dup 3 << 'pvk + @ pvmin <? ( 2drop ; ) drop
	dup 3 << 'pvc + @ 1+
	over 3 << 'pvw + @ 32 << or
	pvch 3 << 'pvrg + @ 40 << or
	pvsa pvch 3 << + !
	1 'pvch +! drop ;

:pvdecide | -- slot		| 0 = none ( ph pc pvnf pvbase pvdir are set )
	0 'pvu !
	pvnf 1 <? ( drop 0 ; ) drop
	pvsn 255 >? ( drop 0 ; ) drop
	ph ( pc <=? dup pvtok 1+ ) drop
	pvsn 5 << 'pvs + 'pvsa !
	0 pvsa ! 0 pvsa 8 + ! 0 pvsa 16 + ! ph pc 1+ 32 << or pvsa 24 + !
	0 'pvch !
	0 ( pvu <? dup pvsel 1+ ) drop
	pvch 0? ( ; ) drop
	1 'pvsn +!
	pvsn ;

:pvput | e --
	dup $ffffffff and 1- pvn 3 << 'pvl + !
	dup 32 >> 1 and pvn 3 << 'pvm + !
	40 >> $ff and pvn 3 << 'pvr + !
	1 'pvn +! ;

:pvsetup | slot --		| the variables of the loop for the code
	0 'pvn !
	0? ( drop ; )
	1- 5 << 'pvs + 'pvsa !
	0 ( 3 <? dup 3 << pvsa + @ 1? ( dup pvput ) drop 1+ ) drop
	pvsa 24 + @ 32 >> $7fffffff and lhd + c@ 1? ( drop 0 'pvn ! ; ) drop
	pvn 'pvtot +! 1 'pvloops +! ;

:lpclr | idx --			| the loop inside is part of the outer
	0 over lvp + c! 0 over lve + c!
	3 << lpm + dup @ 0? ( 2drop ; ) drop
	0 swap ! -1 'lpnum +! ;

:chkloop | head close --
	'pc ! 'ph !
	1 'pok ! 0 'pdp ! 0 'pcu ! 0 'pmx ! 0 'pex !
	1 'lpall +!
	ph ( pc 1+ <=? dup lpdt + 0 swap c! 1+ ) drop
	ph ( pc <=? dup pscan1 1+ ) drop
	pok 0? ( drop ; ) drop
	pcu 2 <? ( drop ; ) drop
	pcu pmx + 7 >? ( drop ; ) drop
	pex 1 <? ( drop ; ) drop
	pex 14 >? ( drop ; ) drop
	pc 1+ lbl + c@ 0? ( drop ; ) drop
	ph 1+ ( pc <=? dup lpclr 1+ ) drop
	6 pcu - pmx - 3 min 'pvnf !
	0 ( 3 <? dup pcu + pmx + 'pgr + c@ over 3 << 'pvrg + ! 1+ ) drop
	0 'pvnc ! 0 'pvcm !
	pvdecide dup pc 1+ lve + c!
	48 << pc 1+ 8 << or pcu or ph 3 << lpm + !
	1 'lpnum +! ;

:mkloop | tok --			| a jump back : the loop is ( jtarget .. tkidx )
	lpen 0? ( 2drop ; ) drop
	dup $ff and 9 <>? ( 2drop ; ) drop
	dup tkv 0? ( 2drop ; ) drop
	tcur 'ptsv ! jtarget tkidx chkloop ptsv 'tcur ! ;

:mkdep | tok --			| loop depth : the tokens of a loop ( head .. back jump )
	dup $ff and 9 <>? ( 2drop ; ) drop
	dup tkv 0? ( 2drop ; ) drop
	tkidx 1+ lxt + 1 swap c!
	jtarget tkidx
	( over >=? dup ldep + 1 swap +! 1- ) 2drop ;

:weight! | --			| weight of the token for the instrumentation
	tkidx ldep + c@ 7 min 3 << 'pw + @ 'nweight ! ;

|---------------------------------------------------------------
| ROTATED LOOPS : the test at the head is copied at the end ( one jump by iteration instead of two )
| the test: the pure tokens from the head to the first jump of a condition, that must go to the exit of the loop.
| the head makes the test and the jump to the exit, the body begins in the state that the test leaves ( label t_ ),
| the end of the body makes the same test and jumps to the body when the condition is true.
|---------------------------------------------------------------
#rid #rh #rb #rn #rd #rcur #rn2 #rh2 #rid2 #rmode #rsv #rj2 #gtk

:jtgt | idx -- target		| the token after the jump of the token idx
	dup tkat @ tks 3 >> + 1+ ;

:rstep | i --		| one token of the test
	rok 0? ( 2drop ; ) drop
	rd 1? ( 2drop ; ) drop
	rh + dup rb >=? ( 2drop 0 'rok ! ; ) drop
	dup rh >? ( dup lbl + c@ 1? ( 0 'rok ! ) drop ) drop
	dup tkat @ $ff and
	dup vs.pure? 0? ( 0 'rok ! ) drop
	13 25 in? ( drop dup jtgt rb 1+ <>? ( 0 'rok ! ) drop dup rh - 1+ 'rn ! 1 'rd ! drop ; )
	7 12 in? ( 0 'rok ! ) 2drop ;

:mkrot | tok --			| the jump back of a loop: is the test rotable?
	dup $ff and 9 <>? ( 2drop ; ) drop
	dup tkv 0? ( 2drop ; ) drop
	rid 63 >? ( 2drop ; ) drop
	rotlp 0? ( 2drop ; ) drop
	jtarget 'rh ! tkidx 'rb !
	rh 3 << lpm + @ 1? ( drop ; ) drop
	1 'rok ! 0 'rd ! 0 'rn !
	0 ( 8 <? dup rstep 1+ ) drop
	rok 0? ( drop ; ) drop
	rd 0? ( drop ; ) drop
	rn rb lrt + c!
	rid rb lri + c!
	rh rn + 1- 'rj2 !
	$80 rj2 lrt + c!
	rid rj2 lri + c!
	0 rid 'rfok + c!
	1 'rid +! 1 'rotall +! ;

:rotlab | --			| after the jump of the test of a rotated loop: the label of the body
	rotb 1? ( drop ; ) drop
	lpon 1? ( drop ; ) drop
	tkidx lrt + c@ $80 and 0? ( drop ; ) drop
	tkidx lri + c@ 'rcur !
	0 rcur 'rfok + c!
	rcur vs.rsave 0? ( drop ; ) drop
	jmode rcur 'rfok + c!
	rotal 1? ( ib "align " ,s rotal ,d ie opt.label ) drop
	ib "t_" ,s tkidx ,h ":" ,s ie opt.label ;

|---------------------------------------------------------------
| VARIABLES IN REGISTERS in the loops that are not in loop mode ( and have no calls ): the head loads them, the exit label writes them.
|---------------------------------------------------------------
:mklhd | tok --			| heads of the loops
	dup $ff and 9 <>? ( 2drop ; ) drop
	dup tkv 0? ( 2drop ; ) drop
	jtarget lhd + 1 swap c! ;

:pvchk1 | tok --
	dup $ff and
	2 =? ( drop tkv pvcall ; )
	7 =? ( 2drop 0 'rok ! ; )
	10 12 in? ( 2drop 0 'rok ! ; )
	vs.pure? 0? ( pvcm $3f7 or 'pvcm ! ) 2drop ;

:pvchk | idx --		| the loop has no returns, no anonymous words, no loops in loop mode
	dup tkat @ pvchk1
	dup rh >? ( dup 3 << lpm + @ 1? ( 0 'rok ! ) drop ) 2drop ;

:mkpv | tok --
	dup $ff and 9 <>? ( 2drop ; ) drop
	dup tkv 0? ( 2drop ; ) drop
	jtarget 'rh ! tkidx 'rb !
	rh 3 << lpm + @ 1? ( drop ; ) drop
	1 'rok ! 0 'pvnc ! 0 'pvcm !
	rh ( rb <=? dup pvchk 1+ ) drop
	rok 0? ( drop ; ) drop
	rh 'ph ! rb 'pc !
	pvregs pvnr 3 min 'pvnf !
	pvdecide 0? ( drop ; )
	rh 1+ ( rb <=? dup lpclr 1+ ) drop
	dup rh lvp + c! rb 1+ lve + c! ;

:markword | nro --
	nro>dic toklen
	( 1? 1- swap
		dup 'tcur ! @+ dup mkdep dup marktok dup mkloop dup mklhd dup mkrot mkpv
		swap ) 2drop ;

|---------------------------------------------------------------
| WORD INFO : the facts that the next steps need ( call by registers, variables in registers )
|   wclob[w]  registers written by the word and by the words that it calls: bit r of vstk
|             ( 0 rax 1 rcx 2 rdx 3 rbx 4 rsi 5 rdi 6 r8 .. 11 r13 , 12 r14 = A , 13 r15 = B ), $3fff = all.
|             It is read from the text that the word has when it is made ( the words are defined before they are used ).
|   wflg[w]   bit 2 = EX : the word, or a word that it calls, executes an unknown word.
|             recursive ( $20 ) and address taken ( $04 ) are the flags of the dictionary
|   wvr wvm   bitmaps of the variables that the word and the words that it calls read / write
|   vesc[v]   1 = the address of the variable is used as something else than ( 'v @ ) ( 'v ! ) ( 'v +! ) ..
|---------------------------------------------------------------
#wrr #wrm #pnx #plen #wst #wsa #wsb #wsm
#wdump 0		| 1 = asm/winfo.txt
#lnb * 256
#rpt "ax" "cx" "dx" "bx" "si" "di" "al" "cl" "dl" "bl" ( 0 )
#rpa #rpp #wai #bsrc #bdst

:bset | i row --		| set the bit i of the bitmap
	over 3 >> + dup c@ rot 7 and 1 swap << or swap c! ;

:bor | src dst --		| dst = dst or src
	'bdst ! 'bsrc !
	0 ( rowb <?
		dup bsrc + @ over bdst + dup @ rot or swap !
		8 + ) drop ;

:rowaddr | n base -- addr
	swap rowb * + ;

:wfl! | f --
	wcur 3 << wflg + dup @ rot or swap ! ;

:vesc! | v --
	vesc + 1 swap c! ;

:varadr | v --		| the address of the variable v is pushed: only ( 'v @ ) ( 'v ! ) ( 'v +! ) are direct uses
	plen 0? ( drop vesc! ; ) drop
	pnx 8 + @ $ff and
	66 =? ( drop wrr bset ; )
	74 =? ( drop dup wrr bset wrm bset ; )
	82 =? ( drop dup wrr bset wrm bset ; )
	drop vesc! ;

:callrow | n --		| the word n is called: its variables are mine
	dup wcur =? ( 2drop ; ) drop
	dup rowb * wvr + wrr bor
	dup rowb * wvm + wrm bor
	dup nro>dic @ $20 and? ( 64 wfl! ) drop
	dup 3 << wflg + @ 64 and? ( 64 wfl! ) drop
	3 << wflg + @ 4 and 0? ( drop ; ) drop 4 wfl! ;

:anatok | t --
	dup $ff and
	2 =? ( drop tkv callrow ; )
	4 =? ( drop tkv wrr bset ; )
	5 =? ( drop tkv varadr ; )
	7 =? ( 2drop wcur wfn + dup c@ 1+ swap c! ; )
	12 =? ( 2drop 20 wfl! ; )
	10 11 in? ( 2drop 32 wfl! ; )
	2drop ;

:anaword | nro --
	dup 'wcur !
	dup wvr rowaddr 'wrr !
	wvm rowaddr 'wrm !
	wcur nro>dic toklen
	( 1? 1- dup 'plen ! swap dup 'pnx ! @+ anatok swap ) 2drop ;

:vdtok | t --		| the address of a variable in the data of a word: it escapes
	dup $ff and 5 =? ( drop tkv vesc! ; ) 2drop ;

:anadata1 | nro --
	nro>dic toklend ( 1? 1- swap @+ vdtok swap ) 2drop ;

:rcelig? | nro -- f		| the word uses the call by registers
	'rcn !
	rcn nro>dic @ $ac and? ( drop 0 ; ) drop
	rcn 3 << wflg + @ $70 and? ( drop 0 ; ) drop
	rcn wfn + c@ 1 <>? ( drop 0 ; ) drop
	rcn nro>dic 8 + @ dup $ff and 'rcu ! 8 >> 56 << 56 >> rcu + 'rco !
	rcu 4 >? ( drop 0 ; ) drop
	rco 0 <? ( drop 0 ; ) drop
	rco 4 >? ( drop 0 ; ) drop
	rcu 2 <? ( rco 2 <? ( 2drop 0 ; ) drop ) drop
	1 ;

:rcset | nro --		| wrc = 256 | results<<4 | arguments
	dup nro>dic 8 + @ dup $ff and 'rcu !
	8 >> 56 << 56 >> rcu + 4 << rcu or 256 or
	swap 3 << wrc + ! ;

#rcon_dummy 0
:anarc | --
	rcon 0? ( drop ; ) drop
	0 ( cntdef 1- <?
		dup nro>dic @ 1 and 0? ( over rcelig? 1? ( pick2 rcset ) drop ) drop
		1+ ) drop ;

:anainfo | --
	cntdef 63 + 6 >> 3 << 'rowb !
	here dup 'wclob ! cntdef 3 << + 'here !
	wclob -1 cntdef fill
	here dup 'wflg ! cntdef 3 << + 'here !
	wflg 0 cntdef fill
	here dup 'vesc ! cntdef + 'here !
	vesc 0 cntdef cfill
	here dup 'wfn ! cntdef + 'here !
	wfn 0 cntdef cfill
	here dup 'wrc ! cntdef 3 << + 'here !
	wrc 0 cntdef fill
	here dup 'wvr ! cntdef rowb * + 'here !
	wvr 0 cntdef rowb * 3 >> fill
	here dup 'wvm ! cntdef rowb * + 'here !
	wvm 0 cntdef rowb * 3 >> fill
	0 ( cntdef <? dup nro>dic @ 1 and 0? ( over anaword ) 1? ( over anadata1 ) drop 1+ ) drop
	anarc ;

|--- registers written by the text of a word ( the instructions are lines that begin with a tab )
:regnum | adr -- bit		| r8 .. r15
	1+ str>nro nip 8 15 in? ( 2 - ; ) drop -1 ;

:regpair | adr -- bit		| ax cx dx bx si di al cl dl bl
	'rpa ! 'rpt 'rpp !
	0 ( 10 <?
		rpa rpp =pre nip 1? ( drop 6 >=? ( 6 - ) ; ) drop
		rpp >>0 'rpp !
		1+ ) drop -1 ;

:regname | adr -- bit		| -1 = not a register ( rbp rsp too )
	dup c@
	$72 =? ( drop dup 1+ c@ $30 $39 in? ( drop regnum ; ) drop 1+ regpair ; )
	$65 =? ( drop 1+ regpair ; )
	drop regpair ;

:bitm | bit -- mask
	-? ( drop 0 ; ) 1 swap << ;

:callmask | n -- mask
	wcur =? ( drop $3fff ; ) 3 << wclob + @ ;

:insmask | -- mask		| the instruction in lnb
	'lnb
	"call w" =pre 1? ( drop 6 + str$>nro nip callmask ; ) drop
	"jmp w" =pre 1? ( drop 5 + str$>nro nip callmask ; ) drop
	"call qword[" =pre 1? ( 2drop $3f7 ; ) drop
	"call" =pre 1? ( 2drop $3fff ; ) drop
	"jmp rcx" =pre 1? ( 2drop $3fff ; ) drop
	"acall" =pre 1? ( 2drop $3f7 ; ) drop
	"cinvoke" =pre 1? ( 2drop $3f7 ; ) drop
	"syscall" =pre 1? ( 2drop $3fff ; ) drop
	"j" =pre 1? ( 2drop 0 ; ) drop
	"cmp" =pre 1? ( 2drop 0 ; ) drop
	"test" =pre 1? ( 2drop 0 ; ) drop
	"push" =pre 1? ( 2drop 0 ; ) drop
	"ret" =pre 1? ( 2drop 0 ; ) drop
	"rep" =pre 1? ( 2drop $32 ; ) drop
	"cqo" =pre 1? ( 2drop 4 ; ) drop
	"cdq" =pre 1? ( 2drop 4 ; ) drop
	"idiv" =pre 1? ( 2drop 5 ; ) drop
	"div" =pre 1? ( 2drop 5 ; ) drop
	"mul" =pre 1? ( 2drop 5 ; ) drop
	"imul" =pre 1? ( drop 44 findchar 1? ( drop 'lnb >>sp trim regname bitm ; ) drop 5 ; ) drop
	"xchg" =pre 1? ( drop >>sp trim dup regname bitm swap 44 findchar 1+ regname bitm or ; ) drop
	>>sp trim regname bitm ;

:wscan | a b -- mask		| the registers written by the instructions of the text a..b
	'wsb ! 'wsa ! 0 'wsm !
	( wsa wsb <?
		dup c@ 9 =? ( over 1+ 'lnb strcpyln insmask wsm or 'wsm ! ) drop
		>>cr 1+ 'wsa ! )
	drop wsm ;

|---------------------------------------------------------------
|--- push
:,push "add rbp,8;mov [rbp],rax" ,ins ;
:,movax ib "mov rax," ,s ;
:,iend ie opt.ins ;
:gk2 ib "call " ,s tkv ,wlab ,iend ;		| word
:gk11 | tok --  ] push address of the anonymous
	,push ,movax "l_" ,s tkv ,h ,iend ;

:gfrag | n --
	7 - 3 << 'ftab + @
	0? ( drop "; ERROR: no fragment" ,ins ; )
	,ins ;

:lpown? | -- f		| the token is the jump back of the loop in registers
	lpon 0? ( ; ) drop
	tkidx lpxit 1- =? ( drop 1 ; ) drop 0 ;

:lpclose | --			| after the jump back of the loop in registers : the stubs of the exits
	lpown? 1? ( drop vs.lpend ; ) drop ;

:genrot | -- f		| the jump back of a rotated loop: the test again and jump to the body ( 0 = not rotated )
	lpon 1? ( drop 0 ; ) drop
	tkidx lrt + c@ 'rn2 !
	rn2 0? ( ; ) drop
	tkidx lri + c@ 'rid2 !
	rid2 'rfok + c@ dup 'rmode ! 0? ( ; ) drop
	tcur 'rsv !
	tcur @ jtarget 'rh2 !
	0 ( rn2 1- <? dup rh2 + tkat dup 'tcur ! @ gtk ex 1+ ) drop
	rmode 'rotm ! 1 'rotb ! rh2 rn2 + 1- 'rotj !
	rotj tkat dup 'tcur ! @ gtk ex
	0 'rotb !
	rid2 vs.rcmp 0? ( "ERROR_ROTATED_LOOP_STATE" ,ins ) drop
	vs.norm
	rsv 'tcur !
	tkidx 1+ 'jt !
	tkidx 1+ vs.sxany? 1? ( "jmp ~" ,ins ) drop
	1 'rotn +! 1 ;


:gbase | tok n --
	7 =? ( 2drop "ret" ,ins ; )
	8 =? ( 2drop ; )
	9 =? ( drop dup tkv 0? ( 2drop ; ) drop jtarget 'jt ! genrot 0? ( "jmp ~" ,ins ) drop lpclose tkidx 1+ vs.sxend ; )
	10 =? ( drop jtarget 'jt ! "jmp ~" ,ins ; )
	11 =? ( drop gk11 ; )
	swap drop gfrag ;

:rcgen | tok -- f		| the call of a word that uses the call by registers
	dup $ff and 2 <>? ( 2drop 0 ; ) drop
	dup tkv 3 << wrc + @ 0? ( 2drop 0 ; )
	dup $f and vs.torc
	swap gk2
	4 >> $f and vs.postrc 1 ;

:rcret | tok -- f			| the ; of a word that uses the call by registers
	$ff and 7 <>? ( drop 0 ; ) drop
	wcur 3 << wrc + @ 0? ( ; )
	4 >> $f and vs.torc 1 ;

:gentoken | tok --
	dup $ff and 13 25 in? ( over jtarget dup 'jt ! lxt + c@ 'jxit ! ) drop
	8 'ncause ! dup vs.tok 1? ( 2drop rotlab ; ) drop
	4 'ncause ! dup $ff and 9 =? ( 3 'ncause ! ) drop
	dup rcgen 1? ( 2drop ; ) drop
	dup rcret 1? ( 2drop "ret" ,ins ; ) drop
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

:deadprev? | -- f		| the token before is a jump back ( the label is reached only by jumps )
	tkidx 0? ( ; ) drop
	tkidx 1- tkat @ dup $ff and 9 <>? ( 2drop 0 ; ) drop tkv 0 <>? ( drop 1 ; ) drop 0 ;

:dolabel | --			| label of the current token
	2 'ncause !
	tkidx 3 << lpm + @ 1? ( dup 48 >>> pvsetup dup $ff and swap 8 >> $ffffffffff and vs.lpbegin ib tkidx ,lab ":" ,s ie opt.label ; ) drop
	lpon 1? ( drop deadprev? 1? ( drop tkidx lpdt + c@ 64 - lpcu + vs.lpset ib tkidx ,lab ":" ,s ie opt.label ; ) ) drop
	tkidx lvp + c@ 1? ( pvsetup vs.pvbegin ib tkidx ,lab ":" ,s ie opt.label ; ) drop
	vs.norm ib tkidx ,lab ":" ,s ie opt.label
	tkidx lve + c@ 1? ( vs.pvend ) drop ;

:genword | nro --
	opt.flush here 'wst ! dup 'wcur !
	dup nro>dic @ dic>name ,rem
	dup cntdef 1- =? ( "INICIO:" opt.label ) drop
	0 'ncause ! 1 'nweight ! vs.norm ib dup ,wlab ":" ,s ie opt.label
	vs.reset
	dup 3 << wrc + @ 1? ( dup $f and vs.entryrc ) drop
	0 'rid ! dup markword
	dup nro>dic toklen
	( 1? 1- swap
		dup 'tcur ! weight!
		tkidx lbl + c@ 1? ( dolabel ) drop
		@+ gentoken
		swap ) 2drop
	6 'ncause ! 1 'nweight ! vs.norm drop
	opt.flush wst here wscan
	wcur nro>dic @ $20 and? ( nip $3fff swap ) drop
	wcur 3 << wclob + ! ;

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
		dup strm - "s_%h:" ,print ,lf
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

|--- listing ( wdump )
:vlist | row --		| names of the variables of the bitmap
	0 ( cntdef <?
		2dup 3 >> + c@ over 7 and >> 1 and 1? ( " w" ,s over ,h ) drop
		1+ ) 2drop ;

:dumpw | nro --
	'wcur !
	wcur 3 << wclob + @
	wcur 3 << wflg + @ 2 >> 1 and
	wcur nro>dic @ 2 >> 1 and
	wcur nro>dic @ 5 >> 1 and
	wcur nro>dic @ dic>name
	wcur
	"w%h %w rec=%d adr=%d ex=%d clob=%h R:" ,print
	wcur wvr rowaddr vlist
	" M:" ,s wcur wvm rowaddr vlist
	,lf ;

:filewinfo | --
	mark
	"; word info: name rec adr ex clob R:read M:written, then the escaped variables" ,s ,lf
	0 ( cntdef <? dup nro>dic @ 1 and 0? ( over dumpw ) drop 1+ ) drop
	"escaped:" ,s
	0 ( cntdef <? dup vesc + c@ 1? ( " w" ,s over ,h ) drop 1+ ) drop
	,lf
	"asm/winfo.txt" savefile ;


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
	'gentoken 'gtk !
	targetplain
	selos 'osfrag ! buildtab
	checktab
	here dup 'lbl ! cnttok + 'here !
	lbl 0 cnttok cfill
	here dup 'ldep ! cnttok + 'here !
	ldep 0 cnttok cfill
	here dup 'lxt ! cnttok + 'here !
	lxt 0 cnttok cfill
	here dup 'lvp ! cnttok + 'here !
	lvp 0 cnttok cfill
	here dup 'lve ! cnttok + 'here !
	lve 0 cnttok cfill
	here dup 'lhd ! cnttok + 'here !
	lhd 0 cnttok cfill
	here dup 'lrt ! cnttok + 'here !
	lrt 0 cnttok cfill
	here dup 'lri ! cnttok + 'here !
	lri 0 cnttok cfill
	here dup 'lpm ! cnttok 3 << + 'here !
	lpm 0 cnttok fill
	here dup 'lpdt ! cnttok + 'here !
	lpdt 0 cnttok cfill
	0 'lpnum ! 0 'lpall !
	vs.stat0
	mapstrs
	anainfo
	filecode
	wdump 1? ( drop filewinfo ) drop
	filedata
	fileset
	cnttok cntdef "words:%d tokens:%d" .println
	nout nins "instructions: %d -> %d" .println
	lpall lpnum "loops in registers: %d of %d" .println
	rotall rotn "loops rotated: %d of %d" .println
	0 'rcn ! 0 ( cntdef <? dup 3 << wrc + @ 1? ( 1 'rcn +! ) drop 1+ ) drop rcn "words with call by registers: %d" .println
	pvloops pvtot "variables in registers: %d in %d loops" .println
	vs.stats ;

:
	.reset
	"r3 simple compiler 2" .println
	'osnames osgen $3 and 2 << + "target: %s" .println
	'filename r3load
	error 1? ( .println drop ; ) drop
	compiling..
	
|WIN|	"asm\compile.bat" sys "r3fasm.exe" sys	
|LIN|	"./asm/compilelin.sh" sys "./r3forth" sys
	;
