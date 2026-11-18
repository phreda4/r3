| r3ir - the instructions of a word before r3opt1 ( stage 1 of the register allocation )
| PHREDA 2026
|---------------------------------------------------------------
| ir.ins "text"     an instruction of the word ( the same call that was opt.ins )
| ir.label "l:"     a label ( the same call that was opt.label )
| ir.word           the word is complete: the lines go, in the same order, to r3opt1
|
| for each instruction: the registers that it reads ( fxu ) and writes ( fxd ), from a table
| ( made by test/irgen.py from the model of test/irverify.py ), and an online check:
| a register that is read must have been written since the label or the call
| ( only rax r14 r15 rbp rsp are alive there )
|---------------------------------------------------------------
^r3/lib/console.r3
^r3/lib/mem.r3
^r3/lib/str.r3
^r3/d4/r3opt1.r3

|---------------------------------------------------------------
| TABLE BEGIN ( made by test/irgen.py , do not edit )
#mnames
"mov" "movsx" "movsxd" "movzx" "lea" "bsr" "cvttsd2si" "cvtsi2sd" "sqrtsd" "add" "sub" "and" "or" "xor" "imul" "shl" "shr" "sar" "shld" "shrd" "cmovne" "cmove" "cmovl" "cmovg" "cmp" "test" "neg" "not" "push" "pop" "cqo" "idiv" "div" "imul1" "repmovs" "repstos" "std" "cld" "call" "acall" "ret" "jmp" ( 0 )
#mkind 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 2 3
#mroles 6 6 6 6 6 6 6 5 5 7 7 7 7 7 7 7 7 7 23 23 7 7 7 7 5 5 3 3 1 2 0 1 1 1 0 0 0 0 1 0 0 1
#mimpu 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 5 1 194 131 0 0 0 192 1 0
#mimpd 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 5 5 5 194 130 0 0 0 0 0 0
| TABLE END

#regnames
"rax" "rcx" "rdx" "rbx" "rsp" "rbp" "rsi" "rdi" "r8" "r9" "r10" "r11" "r12" "r13" "r14" "r15"
"eax" "ecx" "edx" "ebx" "esp" "ebp" "esi" "edi" "r8d" "r9d" "r10d" "r11d" "r12d" "r13d" "r14d" "r15d"
"ax" "cx" "dx" "bx" "sp" "bp" "si" "di" "r8w" "r9w" "r10w" "r11w" "r12w" "r13w" "r14w" "r15w"
"al" "cl" "dl" "bl" "spl" "bpl" "sil" "dil" "r8b" "r9b" "r10b" "r11b" "r12b" "r13b" "r14b" "r15b" ( 0 )

|---------------------------------------------------------------
| the text of an instruction
#tkb * 40		| a token
#mnb * 40		| the mnemonic
#opb * 256		| the operands ( 4 x 64 )
#opk * 32		| operand kind: 0 none 1 register 2 memory 3 immediate 4 xmm
#opm * 32		| registers of the operand ( bit n = register n )
#opw * 32		| register width: 0 64  1 32  2 16  3 8 bits
#nop 0 #nopn 0 #ocur 0 #dep 0 #rst 0
##fxu 0 ##fxd 0 ##fxk 0	| registers read, registers written, kind: 0 ins 1 call 2 ret 3 jmp 4 jcc
##ir.nunk 0

:alnum? | c -- 0/1
	$30 $39 in? ( drop 1 ; ) $61 $7a in? ( drop 1 ; ) $41 $5a in? ( drop 1 ; )
	$5f =? ( drop 1 ; ) drop 0 ;

:gettok | adr -- adr'		; the alnum run goes to tkb
	'tkb >b
	( dup c@ alnum? 1? drop c@+ cb!+ ) drop
	0 cb!+ ;

:skipnon | adr -- adr'
	( dup c@ 1? alnum? 0? drop 1+ ) drop ;

#lki
:lookup | 'buf 'list -- n/-1	; position of the string in a list of strings
	0 'lki !
	( dup c@ 1?
		drop over over =s 1? ( 3drop lki ; ) drop
		>>0 1 'lki +! )
	3drop -1 ;

:regidx | -- n/-1		; the register of the token in tkb
	'tkb 'regnames lookup ;

#rmk
:addreg | n --
	-? ( drop ; ) $f and 1 swap << rmk or 'rmk ! ;

:regmask | adr -- mask		; the registers named in a text
	0 'rmk !
	( skipnon dup c@ 1?
		drop gettok regidx addreg )
	2drop rmk ;

|--- the operands
:opbuf | i -- adr
	6 << 'opb + ;

:setop | kind mask width --
	ocur 3 << dup 'opw + rot swap ! dup 'opm + rot swap ! 'opk + ! ;

:opclass | adr --		; kind, registers and width of the operand ocur
	trim
	dup $5b findchar 1? ( nip regmask 2 swap 0 setop ; ) drop
	gettok drop regidx
	-? ( drop 'tkb "xmm" =pre 1? ( 2drop 4 0 0 setop ; ) 2drop 3 0 0 setop ; )
	dup $f and 1 swap << swap 4 >> 1 -rot setop ;

:endop | --
	0 cb!+
	nop 2 <? ( drop 1 'nop +! nop opbuf >b ; ) drop ;

:putc | c --
	$2c =? ( dep 0? ( 2drop endop ; ) drop )
	$5b =? ( 1 'dep +! ) $5d =? ( -1 'dep +! )
	cb!+ ;

:splitops | adr --		; the text after the mnemonic -> the operands
	0 'nop ! 0 'dep ! 0 'nopn !
	trim dup c@ 0? ( 2drop ; ) drop
	'opb >b
	( c@+ 1? putc )
	2drop 0 cb!+ nop 1+ 'nopn ! ;

:doops | --
	0 'ocur !
	( ocur nopn <? drop ocur opbuf opclass 1 'ocur +! ) drop ;

:getmn | adr -- adr'		; the mnemonic goes to mnb
	trim gettok 'tkb 'mnb strcpy trim ;

:mnidx | -- n/-1
	'mnb 'mnames lookup ;

|--- what an instruction does with the registers
:fxuse | mask --
	fxu or 'fxu ! ;
:fxdef | mask --
	fxd or 'fxd ! ;
:okind ocur 3 << 'opk + @ ;
:omask ocur 3 << 'opm + @ ;
:owid ocur 3 << 'opw + @ ;

:applyrole | role --		; 1 read  2 write  3 modify , on the operand ocur
	1 =? ( drop omask fxuse ; )
	2 =? ( drop okind
		1 =? ( drop omask fxdef owid 2 >=? ( drop omask fxuse ; ) drop ; )
		2 =? ( drop omask fxuse ; ) drop ; )
	3 =? ( drop omask fxuse okind 1 =? ( omask fxdef ) drop ; )
	drop ;

:doroles | roles --
	0 'ocur !
	( ocur nopn <? drop dup ocur 1 << >> $3 and applyrole 1 'ocur +! )
	2drop ;

:isjcc? | -- 0/1		; jz jne jl ... ( all the j, but jmp )
	'mnb c@ $6a <>? ( drop 0 ; ) drop
	'mnb "jmp" =s 1? ( drop 0 ; ) drop 1 ;

:fixrep | --			; rep movsq -> repmovs , rep stosq -> repstos
	'mnb "rep" =s 0? ( drop ; ) drop
	rst gettok drop
	'tkb "movs" =pre 1? ( 2drop "repmovs" 'mnb strcpy "" 'rst ! ; ) 2drop
	"repstos" 'mnb strcpy "" 'rst ! ;

:fiximul | --			; imul with one operand
	'mnb "imul" =s 0? ( drop ; ) drop
	nopn 1 <>? ( drop ; ) drop
	"imul1" 'mnb strcpy ;

#mnk
::ir.fx | str --		; registers read and written by the instruction
	0 'fxu ! 0 'fxd ! 0 'fxk ! -1 'mnk !
	getmn 'rst !
	isjcc? 1? ( drop 4 'fxk ! ; ) drop
	fixrep
	rst splitops doops fiximul
	mnidx -? ( drop 1 'ir.nunk +! ; )
	'mnk !
	mnk 3 << 'mroles + @ doroles
	mnk 3 << 'mimpu + @ fxuse
	mnk 3 << 'mimpd + @ fxdef
	mnk 3 << 'mkind + @ 'fxk ! ;

#ra.nu
:ir.fxq | str --		; ir.fx without counting the unknown ones again
	ir.nunk 'ra.nu ! ir.fx ra.nu 'ir.nunk ! ;

|---------------------------------------------------------------
| the lines of the word, and the online check
#irrec			| 16384 records ( 8 bytes ): kind | offset in the pool << 8   ( kind 0 ins , 1 label )
#irpool			| the text of the lines ( 256 Kb ) , both in the memory of the compiler ( here )
#nrec 0 #pool> 0
##ir.name 0			| the name of the word ( for the messages )
##ir.ninst 0 ##ir.nviol 0
#vdef $C031			| registers that were written ( -1 = unreachable code )
#vsav $C031			| the state at jz @f

:vviol | text mask --
	ir.nviol 1+ dup 'ir.nviol !
	11 <? ( drop swap ir.name "IR violation in %w: %s reads registers not written ( mask $%h )" .println ; )
	drop 2drop ;

:vchk | text mask --
	0? ( 2drop ; ) vviol ;

:vcheck | text --
	vdef -1 =? ( 2drop ; ) drop
	fxk 4 =? ( over $40 findchar 1? ( vdef 'vsav ! ) drop ) drop
	fxu vdef not and vchk
	vdef fxd or 'vdef !
	fxk 1 =? ( $C031 fxd or 'vdef ! ) 2 =? ( -1 'vdef ! ) 3 =? ( -1 'vdef ! ) drop ;

:vlabel | text --
	c@ $40 =? ( drop vdef -1 =? ( drop vsav 'vdef ! ; ) vsav and 'vdef ! ; )
	drop $C031 'vdef ! ;

|---------------------------------------------------------------
| STAGE 2 : the registers of a block ( webs ), stores up, copies out
|  block = the lines between a label and a call / jmp / ret ( only rax is alive at the begin and at the end )
|  web = a value in a register: a write of the register begins a web, a modify keeps it
|  1) mov [rbp+k],reg goes up to just after the write of reg ( the register is free before )
|  2) a copy  mov d,s  with s dying there is deleted if d and s can have the same register
|---------------------------------------------------------------
#ra.POOL $3FCF			| rax rcx rdx rbx rsi rdi r8..r13
#ra.iK #ra.iFl #ra.iO0 #ra.iNo #ra.iU #ra.iD #ra.iCp #ra.iDel #ra.iSl #ra.iSt #ra.iRec #ra.ord
#ra.oR #ra.oW #ra.oRl #ra.oFx #ra.oS #ra.oE #ra.oWu #ra.oWd
#ra.wC #ra.wD #ra.wU #ra.wP #ra.wL #ra.wFM #ra.wLM #ra.wCF #ra.wCP
#ra.pmask 0			| the promoted registers of the block ( alive in all the block )
#ra.bm 0 #ra.cm 0		| the same , of the lines that are in the block
#ra.src 0 #ra.srcn 0 #ra.msrc 0	| the lines that the block pass reads ( records , number , masks )
#ra.rnp #ra.irout #ra.irpool2
#ra.curw * 128
##ir.ra 1				| 0 = the lines go as they are
##ir.dbg 0				| 1 = the lines are written to the console ( tests )
##ra.nmov 0 ##ra.nup 0 ##ra.nblk 0 ##ra.nskip 0
#ra.bn 0 #ra.nocc 0 #ra.nweb 0 #ra.nout 0 #ra.bok 1 #ra.bskip 0 #ra.pool2 0
#ra.pid 0 #ra.ptx 0 #ra.sop 0 #ra.sdp 0 #ra.shf 0 #ra.sp0 0 #ra.ocx 0

:ra.MAXI 1024 ;
:ra.MAXO 4096 ;
:ra.MAXW 2048 ;
:ra.NOSLOT $7fffffff ;
:ra.BARSLOT $7ffffff0 ;

:rg | i 'arr -- v
	@ swap 3 << + @ ;
:rs | v i 'arr --
	@ swap 3 << + ! ;
:ra.arr | n -- ptr		; memory of the compiler
	here swap 3 << over + 'here ! ;
:ra.opk | i -- kind
	3 << 'opk + @ ;

|--- the instruction ( id ) : registers of the text, with their role
:ra.impu | -- mask
	mnk 0 <? ( drop 0 ; ) 3 << 'mimpu + @ ra.POOL and ;
:ra.impd | -- mask
	mnk 0 <? ( drop 0 ; ) 3 << 'mimpd + @ ra.POOL and ;

:ra.isshift? | -- f
	'mnb "shl" =s 1? ( ; ) drop 'mnb "shr" =s 1? ( ; ) drop 'mnb "sar" =s 1? ( ; ) drop
	'mnb "shld" =s 1? ( ; ) drop 'mnb "shrd" =s ;
:ra.ismov? | -- f
	'mnb "mov" =s ;

:ra.rolefor | w -- role		; the role of a register of the operand sop: 1 read 2 write 3 modify
	ra.sop ra.opk 1 <>? ( 2drop 1 ; ) drop
	mnk 0 <? ( 2drop 1 ; ) drop
	mnk 3 << 'mroles + @ ra.sop 1 << >> $3 and
	0? ( 2drop 1 ; )
	2 =? ( over 2 >=? ( 3drop 3 ; ) drop )
	nip ;

:ra.fixfor | -- reg/-1		; the count of a shift is cl
	ra.shf 0? ( drop -1 ; ) drop
	ra.sop 1 <? ( drop -1 ; ) drop
	'tkb "cl" =s 0? ( drop -1 ; ) drop 1 ;

:ra.occ | start n --		; a register in the text
	dup $f and 1 swap << ra.POOL and 0? ( 3drop ; ) drop
	dup $f and ra.nocc 'ra.oR rs
	dup 4 >> ra.nocc 'ra.oW rs
	over ra.ptx - ra.nocc 'ra.oS rs
	ra.sp0 ra.ptx - ra.nocc 'ra.oE rs
	4 >> ra.rolefor ra.nocc 'ra.oRl rs
	drop
	ra.fixfor ra.nocc 'ra.oFx rs
	-1 ra.nocc 'ra.oWu rs -1 ra.nocc 'ra.oWd rs
	1 'ra.nocc +!
	ra.pid 'ra.iNo rg 1+ ra.pid 'ra.iNo rs ;

:ra.tokat | --			; a token begins at sp0
	ra.sp0 dup gettok 'ra.sp0 !
	regidx -? ( 2drop ; )
	ra.occ ;

:ra.ch | c --
	$5b =? ( drop 1 'ra.sdp +! 1 'ra.sp0 +! ; )
	$5d =? ( drop -1 'ra.sdp +! 1 'ra.sp0 +! ; )
	$2c =? ( drop ra.sdp 0? ( 1 'ra.sop +! ) drop 1 'ra.sp0 +! ; )
	alnum? 1? ( drop ra.tokat ; ) drop
	1 'ra.sp0 +! ;

:ra.scan | --
	ra.nocc ra.pid 'ra.iO0 rs  0 ra.pid 'ra.iNo rs
	ra.isshift? 'ra.shf !
	ra.ptx trim ( dup c@ alnum? 1? drop 1+ ) drop trim 'ra.sp0 !
	0 'ra.sop ! 0 'ra.sdp !
	( ra.sp0 c@ 1? ra.ch ) drop ;

:ra.isd? | c -- f
	$30 $39 in? ( drop 1 ; ) drop 0 ;
#ra.sp #ra.dv #ra.mv #ra.sg
:ra.dg | -- v/-1			; decimal digits at sp
	-1 'ra.dv !
	( ra.sp c@ ra.isd? 1? drop
		ra.dv 0 <? ( drop 0 ) 10 * ra.sp c@ + $30 - 'ra.dv !
		1 'ra.sp +! ) drop
	ra.dv ;
:ra.mulnum | -- v/-1			; n or n*m at sp
	ra.dg -? ( ; ) 'ra.mv !
	ra.sp c@ $2a <>? ( drop ra.mv ; ) drop
	1 'ra.sp +! ra.dg -? ( ; ) ra.mv * ;
:ra.slv | -- key
	ra.mulnum -? ( drop ra.BARSLOT ; )
	ra.sp c@ $5d <>? ( 2drop ra.BARSLOT ; ) drop
	ra.sg * ;
:ra.slot | -- key		; [rbp+k] [rbp-k] [rbp+n*m] -> k , other memory with rbp -> BARSLOT , none -> NOSLOT
	ra.ptx $5b findchar 0? ( drop ra.NOSLOT ; )
	1+ "rbp" =pre 0? ( 2drop ra.NOSLOT ; ) drop
	3 + dup c@ $5d =? ( 2drop 0 ; )
	$2b =? ( drop 1+ 'ra.sp ! 1 'ra.sg ! ra.slv ; )
	$2d =? ( drop 1+ 'ra.sp ! -1 'ra.sg ! ra.slv ; )
	2drop ra.BARSLOT ;

:ra.slotok? | key -- f
	ra.NOSLOT =? ( drop 0 ; ) ra.BARSLOT =? ( drop 0 ; ) drop 1 ;

:ra.copy? | -- f
	ra.ismov? 0? ( ; ) drop
	nopn 2 <>? ( drop 0 ; ) drop
	0 ra.opk 1 <>? ( drop 0 ; ) drop
	1 ra.opk 1 <>? ( drop 0 ; ) drop
	ra.pid 'ra.iNo rg 2 <>? ( drop 0 ; ) drop
	ra.pid 'ra.iO0 rg dup 'ra.oW rg 0 <>? ( 2drop 0 ; ) drop
	1+ 'ra.oW rg 0 <>? ( drop 0 ; ) drop
	1 ;

:ra.store? | -- f
	ra.ismov? 0? ( ; ) drop
	nopn 2 <>? ( drop 0 ; ) drop
	0 ra.opk 2 <>? ( drop 0 ; ) drop
	1 ra.opk 1 <>? ( drop 0 ; ) drop
	ra.pid 'ra.iSl rg ra.slotok? 0? ( ; ) drop
	ra.pid 'ra.iNo rg 1 <>? ( drop 0 ; ) drop
	ra.pid 'ra.iO0 rg 'ra.oW rg 0 <>? ( drop 0 ; ) drop
	1 ;

:ra.addsub? | -- f
	'mnb "add" =s 1? ( ; ) drop 'mnb "sub" =s 1? ( ; ) drop 'mnb "lea" =s ;
:ra.rbpmod? | -- f
	ra.addsub? 0? ( ; ) drop
	0 opbuf "rbp" =s ;

#ra.fl
:ra.fladd | bit --
	ra.fl or 'ra.fl ! ;
:ra.flags | -- flags		; 1 '@' ( jz @f )  2 memory ( call qword[w] )  4 acall  8 changes rbp  16 rep std cld
	0 'ra.fl !
	ra.ptx $40 findchar 1? ( 1 ra.fladd ) drop
	ra.ptx $5b findchar 1? ( 2 ra.fladd ) drop
	'mnb "acall" =s 1? ( 4 ra.fladd ) drop
	ra.rbpmod? 1? ( 8 ra.fladd ) drop
	'mnb "repmovs" =s 1? ( 16 ra.fladd ) drop
	'mnb "repstos" =s 1? ( 16 ra.fladd ) drop
	'mnb "std" =s 1? ( 16 ra.fladd ) drop
	'mnb "cld" =s 1? ( 16 ra.fladd ) drop
	ra.fl ;

:ra.parse | id str --
	'ra.ptx ! 'ra.pid !
	ra.ptx ir.fxq
	fxk ra.pid 'ra.iK rs
	ra.impu ra.pid 'ra.iU rs
	ra.impd ra.pid 'ra.iD rs
	ra.scan
	ra.flags ra.pid 'ra.iFl rs
	ra.copy? ra.pid 'ra.iCp rs
	0 ra.pid 'ra.iDel rs
	ra.slot ra.pid 'ra.iSl rs
	ra.store? ra.pid 'ra.iSt rs ;

|--- the webs of the block ( the instructions in the order ra.ord )
:ra.cur@ | p -- w
	3 << 'ra.curw + @ ;
:ra.cur! | w p --
	3 << 'ra.curw + ! ;

#ra.gc #ra.gd #ra.gw
:ra.wnew | color pos -- w
	'ra.gd ! 'ra.gc !
	ra.nweb ra.MAXW 2 - >=? ( 0 'ra.bok ! ) drop
	ra.nweb ra.MAXW 2 - min 'ra.gw !
	ra.gc ra.gw 'ra.wC rs  ra.gd ra.gw 'ra.wD rs  ra.gd ra.gw 'ra.wU rs
	0 ra.gw 'ra.wP rs  0 ra.gw 'ra.wL rs
	$3fffffff ra.gw 'ra.wFM rs  -1 ra.gw 'ra.wLM rs  -1 ra.gw 'ra.wCF rs  -1 ra.gw 'ra.wCP rs
	ra.gw ra.gc ra.cur!
	1 'ra.nweb +!
	ra.gw ;

:ra.pinw | w mask --
	over 'ra.wP rg or swap 'ra.wP rs ;

#ra.gp #ra.gi #ra.gpin
:ra.wuse | p pos pin -- w
	'ra.gpin ! 'ra.gi ! 'ra.gp !
	ra.gp ra.cur@ 0 <? ( drop
		ra.gp 0 <>? ( 0 'ra.bok ! ) drop
		ra.gp -1 ra.wnew dup 1 ra.gp << ra.pinw )
	dup 'ra.wU rg ra.gi max over 'ra.wU rs
	ra.gpin 0 >=? ( over 1 ra.gpin << ra.pinw ) drop ;

#ra.bid #ra.bpos
:ra.use1 | k --
	ra.bid 'ra.iO0 rg + 'ra.ocx !
	ra.ocx 'ra.oRl rg 2 =? ( drop ; ) drop
	ra.ocx 'ra.oR rg ra.bpos ra.ocx 'ra.oFx rg ra.wuse ra.ocx 'ra.oWu rs ;

:ra.impu1 | p --
	ra.bid 'ra.iU rg over >> 1 and 0? ( 2drop ; ) drop
	ra.bpos over ra.wuse drop ;

:ra.pinreg | p --
	dup ra.cur@ 0 <? ( 2drop ; ) drop
	ra.bpos over ra.wuse drop ;

:ra.pm1 | mask p --
	over over >> 1 and 0? ( 3drop ; ) drop
	nip ra.pinreg ;
:ra.pinmask | mask --
	0 ( 16 <? over over ra.pm1 1+ ) 2drop ;

:ra.callpins | --
	ra.bid 'ra.iK rg 1 <>? ( drop ; ) drop
	ra.bid 'ra.iFl rg 4 and 1? ( drop $C0 ra.pinmask ; ) drop
	ra.bid 'ra.iFl rg 2 and 1? ( $3C6 ra.pinmask ) drop
	0 ra.pinreg ;

:ra.retpin | --
	ra.bid 'ra.iK rg
	2 =? ( drop 0 ra.pinreg ; )
	3 =? ( drop 0 ra.pinreg ; )
	4 =? ( drop ra.bid 'ra.iFl rg 1 and 0? ( drop 0 ra.pinreg ; ) drop ; )
	drop ;

|--- at a jcc the promoted registers are alive ( the jump goes to a label of the region )
:ra.jccp | --
	ra.bid 'ra.iK rg 4 <>? ( drop ; ) drop
	ra.bid 'ra.iFl rg 1 and 1? ( drop ; ) drop
	ra.pmask ra.pinmask ;

:ra.def1 | k --
	ra.bid 'ra.iO0 rg + 'ra.ocx !
	ra.ocx 'ra.oRl rg
	2 =? ( drop ra.ocx 'ra.oR rg ra.bpos ra.wnew dup ra.ocx 'ra.oWd rs
		ra.ocx 'ra.oFx rg 0 <? ( 2drop ; ) 1 swap << ra.pinw ; )
	3 =? ( drop ra.ocx 'ra.oWu rg dup ra.ocx 'ra.oWd rs
		dup 'ra.wLM rg ra.bpos max over 'ra.wLM rs
		dup 'ra.wFM rg ra.bpos min over 'ra.wFM rs
		dup 'ra.wU rg ra.bpos max swap 'ra.wU rs ; )
	drop ;

:ra.impd1 | p --
	ra.bid 'ra.iD rg over >> 1 and 0? ( 2drop ; ) drop
	dup ra.bpos ra.wnew 1 rot << ra.pinw ;

#ra.cs2 #ra.cd2
:ra.cprel | --			; the web of the copy knows its source
	ra.bid 'ra.iO0 rg dup 'ra.oWd rg swap 1+ 'ra.oWu rg
	'ra.cs2 ! 'ra.cd2 !
	ra.cs2 ra.cd2 'ra.wCF rs  ra.bpos ra.cd2 'ra.wCP rs ;

:ra.bins | pos --
	'ra.bpos ! ra.bpos 'ra.ord rg 'ra.bid !
	0 ( ra.bid 'ra.iNo rg <? dup ra.use1 1+ ) drop
	0 ( 16 <? dup ra.impu1 1+ ) drop
	ra.callpins ra.retpin ra.jccp
	0 ( ra.bid 'ra.iNo rg <? dup ra.def1 1+ ) drop
	0 ( 16 <? dup ra.impd1 1+ ) drop
	ra.bid 'ra.iCp rg 1? ( ra.cprel ) drop ;

|--- the promoted registers : a web alive in all the block
:ra.pw1 | p --
	ra.pmask over >> 1 and 0? ( 2drop ; ) drop
	dup -1 ra.wnew 1 rot << ra.pinw ;
:ra.pend1 | p --
	ra.pmask over >> 1 and 0? ( 2drop ; ) drop
	ra.cur@ 0 <? ( drop ; )
	dup 1 swap 'ra.wL rs dup 'ra.wC rg 1 swap << ra.pinw ;

:ra.build | -- ok
	0 'ra.nweb ! 1 'ra.bok !
	0 ( 16 <? dup -1 swap ra.cur! 1+ ) drop
	0 ( 16 <? dup ra.pw1 1+ ) drop
	0 ( ra.bn <? dup ra.bins 1+ ) drop
	0 ra.cur@ 0 >=? ( dup 1 swap 'ra.wL rs dup 1 ra.pinw ) drop
	0 ( 16 <? dup ra.pend1 1+ ) drop
	ra.bok ;

|--- the stores go up
#ra.hs #ra.hp #ra.hj #ra.hw #ra.ht #ra.hs0 #ra.hid
:ra.wr1 | k --
	ra.hj 'ra.iO0 rg + dup 'ra.oRl rg 2 <? ( 2drop ; ) drop
	'ra.oR rg ra.hp <>? ( drop ; ) drop 1 'ra.hw ! ;
:ra.wr? | -- f			; the instruction writes the register of the store
	0 'ra.hw !
	0 ( ra.hj 'ra.iNo rg <? dup ra.wr1 1+ ) drop
	ra.hw ;

:ra.blk | J -- f		; the store can not go over the instruction J
	'ra.hj !
	ra.hj 'ra.iK rg 0 >? ( drop 1 ; ) drop
	ra.hj 'ra.iFl rg $18 and 1? ( drop 1 ; ) drop
	ra.hj 'ra.iSl rg ra.hs =? ( drop 1 ; ) ra.BARSLOT =? ( drop 1 ; ) drop
	ra.hj 'ra.iD rg ra.hp >> 1 and 1? ( drop 1 ; ) drop
	ra.wr? ;

:ra.up | s -- t
	'ra.ht !
	( ra.ht 0 >? drop ra.ht 1- 'ra.ord rg ra.blk 0? drop -1 'ra.ht +! ) drop
	ra.ht ;

:ra.move | t --
	ra.hs0 ( over >? dup 1- 'ra.ord rg over 'ra.ord rs 1- ) drop
	ra.hid swap 'ra.ord rs ;

:ra.hoist1 | s --
	dup 'ra.hs0 ! 'ra.ord rg 'ra.hid !
	ra.hid 'ra.iSt rg 0? ( drop ; ) drop
	ra.hid 'ra.iSl rg 'ra.hs !
	ra.hid 'ra.iO0 rg 'ra.oR rg 'ra.hp !
	ra.hs0 ra.up
	ra.hs0 <? ( dup ra.move 1 'ra.nup +! ) drop ;

:ra.hoist | --
	0 ( ra.bn <? dup ra.hoist1 1+ ) drop ;

|--- the copies are deleted when both webs can have the same register
:ra.wa | w -- a
	'ra.wD rg 1 << 1+ ;
:ra.wb | w -- b
	dup 'ra.wL rg 1? ( 2drop ra.bn 1 << 2 + ; ) drop
	dup 'ra.wU rg over 'ra.wD rg >? ( 1 << nip ; ) drop
	ra.wa ;

|--- two webs of a copy do not interfere if they keep the same value while both are alive
#ra.s2 #ra.d2 #ra.i2 #ra.t2 #ra.so #ra.sw #ra.fo
:ra.ue | w -- u			; last position ( the end of the block if it is alive out )
	dup 'ra.wL rg 1? ( 2drop ra.bn ; ) drop 'ra.wU rg ;
:ra.shr2 | d s -- f
	'ra.s2 ! 'ra.d2 !
	ra.d2 'ra.wCP rg 'ra.i2 !
	|ra.s2 ra.ue ra.d2 ra.ue min 'ra.t2 !
	ra.s2 ra.ue 'ra.t2 !
	ra.s2 'ra.wLM rg ra.i2 >? ( drop 0 ; ) drop
	ra.d2 'ra.wFM rg ra.t2 <? ( drop 0 ; ) drop
	1 ;
:ra.share? | w o -- f
	'ra.so ! 'ra.sw !
	ra.sw 'ra.wCF rg ra.so =? ( drop ra.sw ra.so ra.shr2 ; ) drop
	ra.so 'ra.wCF rg ra.sw =? ( drop ra.so ra.sw ra.shr2 ; ) drop
	0 ;

#ra.fw #ra.fc #ra.fa #ra.fb #ra.a2 #ra.b2 #ra.fbad
:ra.fit1 | o --
	dup 'ra.fo !
	ra.fw =? ( drop ; )
	dup 'ra.wC rg ra.fc <>? ( 2drop ; ) drop
	dup ra.wa 'ra.a2 ! ra.wb 'ra.b2 !
	ra.fa ra.b2 >? ( drop ; ) drop
	ra.a2 ra.fb >? ( drop ; ) drop
	ra.fw ra.fo ra.share? 1? ( drop ; ) drop
	1 'ra.fbad ! ;
:ra.fits | w c -- f
	'ra.fc ! 'ra.fw !
	ra.fw ra.wa 'ra.fa ! ra.fw ra.wb 'ra.fb ! 0 'ra.fbad !
	0 ( ra.nweb <? dup ra.fit1 1+ ) drop
	ra.fbad 0? ( drop 1 ; ) drop 0 ;

#ra.tx #ra.ty #ra.tdone
:ra.try | x y --		; the color of y for x
	'ra.ty ! 'ra.tx !
	ra.tx 'ra.wP rg dup 0 <>? ( 1 ra.ty 'ra.wC rg << <>? ( 2drop ; ) ) 2drop
	ra.tx ra.ty 'ra.wC rg ra.fits 0? ( drop ; ) drop
	ra.ty 'ra.wC rg ra.tx 'ra.wC rs 1 'ra.tdone ! ;

#ra.cid #ra.cs #ra.cd
:ra.coal | pos --
	'ra.ord rg 'ra.cid !
	ra.cid 'ra.iCp rg 0? ( drop ; ) drop
	ra.cid 'ra.iO0 rg dup 'ra.oWd rg swap 1+ 'ra.oWu rg
	'ra.cs ! 'ra.cd !
	ra.cd 'ra.wC rg ra.cs 'ra.wC rg =? ( drop ; ) drop
	0 'ra.tdone !
	ra.cs ra.cd ra.try ra.tdone 1? ( drop ; ) drop
	ra.cd ra.cs ra.try ;

:ra.alloc | --
	ra.bn 1- ( 0 >=? dup ra.coal 1- ) drop ;


|--- the new text of the lines
:ra.rbase | rec -- base
	2 and 0? ( drop irpool ; ) drop ra.irpool2 ;
:rtext | rec -- str
	dup ra.rbase swap 8 >> + ;

:ra.web | o -- w
	dup 'ra.oRl rg 2 =? ( drop 'ra.oWd rg ; ) drop 'ra.oWu rg ;

#ra.rid #ra.rchg #ra.rox #ra.rsrc #ra.rcp #ra.cr #ra.ri #ra.sav #ra.ct #ra.cf
:ra.chg1 | k --
	ra.rid 'ra.iO0 rg + dup ra.web 'ra.wC rg swap 'ra.oR rg <>? ( drop 1 'ra.rchg ! ; ) drop ;
:ra.chg? | -- f		; some register of the line has other color
	0 'ra.rchg !
	0 ( ra.rid 'ra.iNo rg <? dup ra.chg1 1+ ) drop
	ra.rchg ;

:ra.cpy | from to --		; the characters to the new text ( B )
	'ra.ct ! 'ra.cf !
	( ra.cf ra.ct <? drop ra.cf c@ cb!+ 1 'ra.cf +! ) drop ;
:ra.puts | str --
	( c@+ 1? cb!+ ) 2drop ;
:ra.rname | color wg -- str
	4 << + 'ra.rnp rg ;

:ra.rep1 | k --
	ra.rid 'ra.iO0 rg + 'ra.rox !
	ra.rsrc ra.rcp + ra.rsrc ra.rox 'ra.oS rg + ra.cpy
	ra.rox ra.web 'ra.wC rg ra.rox 'ra.oW rg ra.rname ra.puts
	ra.rox 'ra.oE rg 'ra.rcp ! ;

:ra.rtext | -- off		; the new text in the pool 2
	ra.pool2 dup ra.irpool2 + >b
	ra.rid 'ra.iRec rg rtext 'ra.rsrc !
	0 'ra.rcp !
	0 ( ra.rid 'ra.iNo rg <? dup ra.rep1 1+ ) drop
	ra.rsrc ra.rcp + ra.rsrc count nip ra.rsrc + ra.cpy
	0 cb!+ b> ra.irpool2 - 'ra.pool2 ! ;

:ra.emit | rec --
	ra.nout 3 << ra.irout + ! 1 'ra.nout +! ;

:ra.deleted? | -- f		; a copy with the same register in both webs
	ra.rid 'ra.iCp rg 0? ( ; ) drop
	ra.rid 'ra.iO0 rg dup 'ra.oWd rg 'ra.wC rg swap 1+ 'ra.oWu rg 'ra.wC rg
	=? ( drop 1 ; ) drop 0 ;

:ra.rend1 | pos --
	'ra.ord rg 'ra.rid !
	ra.deleted? 1? ( drop 1 'ra.nmov +! ; ) drop
	ra.chg? 0? ( drop ra.rid 'ra.iRec rg ra.emit ; ) drop
	ra.rtext 8 << 2 or ra.emit ;

:ra.renderall | --
	0 ( ra.bn <? dup ra.rend1 1+ ) drop ;

:ra.asis | --			; the lines of the block go as they are
	0 ( ra.bn <? dup 'ra.iRec rg ra.emit 1+ ) drop
	1 'ra.nskip +! ;

|---------------------------------------------------------------
:ra.block | --
	ra.bm 'ra.pmask !
	0 ( ra.bn <? dup dup 'ra.ord rs 1+ ) drop
	ra.build 0? ( drop ra.asis ; ) drop
	ra.hoist ra.build 0? ( drop ra.asis ; ) drop
	ra.alloc ra.renderall
	1 'ra.nblk +! ;

:ra.flush | --
	ra.bn 0? ( drop 0 'ra.bskip ! 0 'ra.nocc ! ; ) drop
	ra.block 0 'ra.bn ! 0 'ra.bskip ! 0 'ra.nocc ! ;

:ra.dumpblock | --		; too big: the lines go as they are
	0 ( ra.bn <? dup 'ra.iRec rg ra.emit 1+ ) drop
	1 'ra.nskip +!
	0 'ra.bn ! 0 'ra.nocc ! ;

:ra.msk@ | i -- m
	ra.msrc 0? ( 2drop 0 ; ) drop 3 << ra.msrc + @ ;
:ra.rec1 | i --
	dup ra.msk@ 'ra.cm ! 3 << ra.src + @ 'ra.cr !
	ra.cr 1 and 1 =? ( drop ra.flush ra.cr ra.emit ; ) drop
	ra.cr rtext ":" =pos 1? ( 2drop ra.flush ra.cr ra.emit ; ) 2drop
	ra.bskip 1? ( drop ra.cr ra.emit ; ) drop
	ra.bn ra.MAXI 2 - >=? ( drop ra.dumpblock 1 'ra.bskip ! ra.cr ra.emit ; ) drop
	ra.nocc ra.MAXO 32 - >=? ( drop ra.dumpblock 1 'ra.bskip ! ra.cr ra.emit ; ) drop
	ra.cr ra.bn 'ra.iRec rs ra.cm 'ra.bm !
	ra.bn ra.cr rtext ra.parse
	ra.bn 'ra.iK rg 1 'ra.bn +!
	1 =? ( drop ra.flush ; ) 2 =? ( drop ra.flush ; ) 3 =? ( drop ra.flush ; ) drop ;

:ra.run | --
	0 'ra.nout ! 0 'ra.bn ! 0 'ra.bskip ! 0 'ra.nocc !
	0 ( ra.srcn <? dup ra.rec1 1+ ) drop
	ra.flush ;

:ra.copyall | --
	0 'ra.nout !
	0 ( nrec <? dup 3 << irrec + @ ra.emit 1+ ) drop ;

|---------------------------------------------------------------
| STAGE 4 : the stack slots go to registers in the zones without calls
|  region = the lines between calls ( it begins at the word or after a call )
|  valid if every jump goes to a label of the same region and the offsets of rbp are known
|  slot = a cell of the data stack ( rbp + offset ): the reads and writes are counted in the region
|  the slots with some accesses go to registers that the region does not use: load at the entry , store at the exits
|---------------------------------------------------------------
##ir.rg 1				| 0 = the slots stay in memory
##ir.thr 2				| accesses ( reads + writes ) to promote a slot
##ra.nreg 0 ##ra.nslot 0
:rg.MAXR 4096 ;
:rg.MAXL 512 ;
:rg.MAXS 256 ;
:rg.MAXP 2048 ;
:rg.MAXO 16384 ;
:rg.NA $7fffffff ;
#rg.k #rg.id #rg.dl #rg.off #rg.reg #rg.sop #rg.sd #rg.srl #rg.sfl #rg.um		| of each line
#rg.lid #rg.loff #rg.lkn #rg.lrg							| of each label
#rg.rs #rg.re #rg.rbad #rg.rpm #rg.rpt #rg.rpc						| of each region
#rg.sla #rg.slr #rg.slw #rg.sldq #rg.slrg						| slots of the region
#rg.pa #rg.pR #rg.pw									| the promotions of all the regions
#rg.out #rg.msk									| the new lines
#rg.n 0 #rg.nl 0 #rg.nr 0 #rg.np 0 #rg.no 0 #rg.fail 0 #rg.ci 0 #rg.ct 0 #rg.ns 0
#rg.hv 0 #rg.hn 0 #rg.hd 0 #rg.sp 0 #rg.sdv 0 #rg.sq 0 #rg.dv 0 #rg.mv 0 #rg.sg 0 #rg.oi 0 #rg.ot 0 #rg.dqf 0
#rg.st 0 #rg.ei 0 #rg.lx 0 #rg.fid 0 #rg.xr 0 #rg.li 0 #rg.sk 0 #rg.cur 0 #rg.chg 0 #rg.anon 0 #rg.ok 0 #rg.pe 0
#rg.cr1 0 #rg.af 0
#rg.okm "mov" "add" "sub" "and" "or" "xor" "cmp" "test" "imul" "imul1" "neg" "not" "push" "idiv" "div" "shl" "shr" "sar" ( 0 )
#rg.pref ( 13 12 11 10 9 8 7 6 3 2 1 )

:rg.hex | c -- v/-1
	$30 $39 in? ( $30 - ; ) $41 $46 in? ( $37 - ; ) $61 $66 in? ( $57 - ; ) drop -1 ;

:rg.hexid | adr -- id/-1		; l + hex digits ( then the end of the text or : )
	dup c@ $6c <>? ( 2drop -1 ; ) drop
	1+ 0 'rg.hv ! 0 'rg.hn !
	( dup c@ rg.hex 'rg.hd ! rg.hd 0 >=? drop
		rg.hv 4 << rg.hd or 'rg.hv ! 1 'rg.hn +! 1+ ) drop
	c@ $21 <? ( drop rg.hn 0? ( drop -1 ; ) drop rg.hv ; )
	$3a =? ( drop rg.hn 0? ( drop -1 ; ) drop rg.hv ; ) drop -1 ;

:rg.isd? | c -- f
	$30 $39 in? ( drop 1 ; ) drop 0 ;

:rg.dg | -- v/-1			; decimal digits at sp
	-1 'rg.dv !
	( rg.sp c@ rg.isd? 1? drop
		rg.dv 0 <? ( drop 0 ) 10 * rg.sp c@ + $30 - 'rg.dv !
		1 'rg.sp +! ) drop
	rg.dv ;

:rg.mulnum | -- v/-1			; n or n*m at sp
	rg.dg -? ( ; ) 'rg.mv !
	rg.sp c@ $2a <>? ( drop rg.mv ; ) drop
	1 'rg.sp +! rg.dg -? ( ; ) rg.mv * ;

:rg.qw | adr -- adr' q
	"qword" =pre 0? ( drop 0 ; ) drop 5 + trim 1 ;

:rg.fin | -- ok			; ] and the end of the text
	rg.sp c@ $5d <>? ( drop 0 ; ) drop
	1 'rg.sp +! rg.sp trim c@ 0? ( drop 1 ; ) drop 0 ;

:rg.sl | adr -- ok			; [rbp] [rbp+n] [rbp-n] with qword or nothing before: rg.sdv rg.sq
	trim rg.qw 'rg.sq !
	dup c@ $5b <>? ( 2drop 0 ; ) drop
	1+ "rbp" =pre 0? ( 2drop 0 ; ) drop
	3 + 'rg.sp !
	0 'rg.sdv !
	rg.sp c@ $2b =? ( drop 1 'rg.sp +! rg.mulnum -? ( drop 0 ; ) 'rg.sdv ! rg.fin ; )
	$2d =? ( drop 1 'rg.sp +! rg.mulnum -? ( drop 0 ; ) neg 'rg.sdv ! rg.fin ; )
	$5d =? ( drop rg.fin ; ) drop 0 ;

|--- the slot operand of a line
:rg.flag | bit --
	rg.ci 'rg.sfl rg or rg.ci 'rg.sfl rs ;

:rg.role | -- r			; 1 read 2 write 3 modify
	mnk 0 <? ( drop 1 ; ) 3 << 'mroles + @ rg.oi 1 << >> $3 and ;

:rg.dq3 | j --
	rg.oi =? ( drop ; )
	dup ra.opk 1 <>? ( 2drop ; ) drop
	3 << 'opw + @ 0? ( drop ; ) drop 1 'rg.dqf ! ;
:rg.dq? | -- f			; the slot can not go to a register
	'mnb 'rg.okm lookup 0 <? ( drop 1 ; ) drop
	rg.sq 1? ( drop 0 ; ) drop
	0 'rg.dqf !
	0 ( nopn <? dup rg.dq3 1+ ) drop
	rg.dqf ;

:rg.slot1 | i --
	'rg.oi !
	rg.oi opbuf 'rg.ot !
	rg.ot $5b findchar 0? ( drop ; ) 1+ "rbp" =pre 0? ( 2drop ; ) 2drop
	rg.ci 'rg.sop rg -1 <>? ( drop 1 rg.flag ; ) drop
	rg.ot rg.sl 0? ( drop 1 rg.flag ; ) drop
	rg.oi rg.ci 'rg.sop rs
	rg.sdv rg.ci 'rg.sd rs
	rg.role rg.ci 'rg.srl rs
	rg.dq? 1? ( 2 rg.flag ) drop ;

:rg.slots | --
	0 ( nopn <? dup rg.slot1 1+ ) drop ;

|--- the kind of each line
:rg.setk | k --
	rg.ci 'rg.k rs ;

:rg.lab | --				; a label
	rg.ct c@ $40 =? ( drop 2 rg.setk ; ) drop
	rg.ct rg.hexid -? ( drop 1 rg.setk ; )
	dup rg.ci 'rg.id rs
	0 rg.setk
	rg.nl rg.MAXL 1- >=? ( 1 'rg.fail ! ) drop
	rg.nl rg.MAXL 1- min 'rg.lx !
	rg.lx 'rg.lid rs
	-1 rg.lx 'rg.lrg rs  0 rg.lx 'rg.lkn rs
	1 'rg.nl +! ;

:rg.sign | -- s
	'mnb "add" =s 1? ( drop 1 ; ) drop 'mnb "sub" =s 1? ( drop -1 ; ) drop 0 ;
:rg.delta | --			; add rbp,n / sub rbp,n
	nopn 2 <>? ( drop ; ) drop
	0 opbuf trim "rbp" =s 0? ( drop ; ) drop
	rg.sign 0? ( drop ; ) 'rg.sg !
	1 opbuf trim 'rg.sp ! rg.mulnum -? ( drop ; )
	rg.sg * rg.ci 'rg.dl rs ;

:rg.jmpk | --
	0 opbuf trim rg.hexid -? ( drop 7 rg.setk ; )
	rg.ci 'rg.id rs 6 rg.setk ;
:rg.jcck | --
	rst trim c@ $40 =? ( drop 9 rg.setk ; ) drop
	rst trim rg.hexid -? ( drop 1 'rg.fail ! 9 rg.setk ; )
	rg.ci 'rg.id rs 8 rg.setk ;

:rg.ins | --
	rg.ct ir.fxq
	fxu fxd or rg.ci 'rg.um rs
	fxk 1 =? ( drop 4 rg.setk ; )
	2 =? ( drop 5 rg.setk ; )
	3 =? ( drop rg.jmpk ; )
	4 =? ( drop rg.jcck ; )
	drop 3 rg.setk rg.delta rg.slots ;

:rg.cls1 | i --
	dup 'rg.ci ! dup 3 << ra.src + @ rtext 'rg.ct !
	-1 over 'rg.id rs  0 over 'rg.dl rs  -1 over 'rg.sop rs  0 over 'rg.sfl rs
	rg.NA over 'rg.off rs  0 over 'rg.um rs  -1 swap 'rg.reg rs
	rg.ct ":" =pos 1? ( 2drop rg.lab ; ) 2drop
	rg.ins ;

|--- labels and regions
:rg.lfind | id -- li/-1
	'rg.fid !
	0 ( rg.nl <? dup 'rg.lid rg rg.fid =? ( drop ; ) drop 1+ ) drop -1 ;

:rg.close | i --			; a region ends at the line i
	dup 'rg.ei !
	rg.st rg.nr 'rg.rs rs
	rg.nr 'rg.re rs
	0 rg.nr 'rg.rbad rs
	0 rg.nr 'rg.rpc rs
	0 rg.nr 'rg.rpm rs
	1 'rg.nr +!
	rg.ei 1+ 'rg.st ! ;

:rg.split | --
	0 'rg.nr ! 0 'rg.st !
	0 ( rg.n <? dup rg.nr swap 'rg.reg rs
		dup 'rg.k rg 4 =? ( over rg.close ) drop 1+ ) drop
	rg.st rg.n <? ( rg.n 1- rg.close ) drop ;

:rg.lmap1 | i --
	dup 'rg.k rg 0 <>? ( 2drop ; ) drop
	dup 'rg.id rg rg.lfind
	swap 'rg.reg rg swap 'rg.lrg rs ;

:rg.bad | r --
	1 swap 'rg.rbad rs ;

:rg.jchk1 | i --
	dup 'rg.id rg rg.lfind
	-? ( drop 'rg.reg rg rg.bad ; )
	swap 'rg.reg rg 'rg.xr !
	'rg.lrg rg rg.xr <>? ( rg.bad rg.xr rg.bad ; ) drop ;

:rg.jchk | i --
	dup 'rg.k rg 6 =? ( drop rg.jchk1 ; ) 8 =? ( drop rg.jchk1 ; ) 2drop ;

:rg.regions | --
	rg.split
	0 ( rg.n <? dup rg.lmap1 1+ ) drop
	0 ( rg.n <? dup rg.jchk 1+ ) drop ;

|--- the offsets of rbp in a region
:rg.lclr | --
	0 ( rg.nl <? 0 over 'rg.lkn rs 1+ ) drop ;

:rg.chk | --
	rg.cur rg.NA =? ( drop ; ) drop
	rg.li 'rg.loff rg rg.cur <>? ( 0 'rg.ok ! ) drop ;

:rg.slab | --				; a label of the region
	rg.sk 'rg.id rg rg.lfind 'rg.li !
	rg.li 'rg.lkn rg 0? ( drop rg.cur rg.NA =? ( drop ; ) drop
		rg.cur rg.li 'rg.loff rs 1 rg.li 'rg.lkn rs 1 'rg.chg ! ; ) drop
	rg.chk rg.li 'rg.loff rg 'rg.cur ! ;

:rg.jmpl | --				; a jump to a label of the region
	rg.cur rg.NA =? ( drop ; ) drop
	rg.sk 'rg.id rg rg.lfind 'rg.li !
	rg.li 'rg.lkn rg 1? ( drop rg.chk ; ) drop
	rg.cur rg.li 'rg.loff rs 1 rg.li 'rg.lkn rs 1 'rg.chg ! ;

:rg.stepi | --
	rg.cur rg.sk 'rg.off rs
	rg.cur rg.NA <>? ( rg.cur rg.sk 'rg.dl rg + 'rg.cur ! ) drop
	rg.sk 'rg.k rg
	9 =? ( drop rg.cur 'rg.anon ! ; )
	8 =? ( drop rg.jmpl ; )
	6 =? ( drop rg.jmpl rg.NA 'rg.cur ! ; )
	7 =? ( drop rg.NA 'rg.cur ! ; )
	5 =? ( drop rg.NA 'rg.cur ! ; )
	drop ;

:rg.step | k --
	'rg.sk !
	rg.sk 'rg.k rg
	0 =? ( drop rg.slab ; )
	1 =? ( drop ; )
	2 =? ( drop rg.cur rg.NA =? ( drop rg.anon 'rg.cur ! ; ) drop ; )
	drop rg.stepi ;

:rg.pass | r --
	dup 'rg.rs rg swap 'rg.re rg 'rg.pe !
	0 'rg.cur ! 0 'rg.chg !
	( rg.pe <=? dup rg.step 1+ ) drop ;

:rg.kn1 | k --
	dup 'rg.k rg 3 <? ( 2drop ; ) drop
	'rg.off rg rg.NA =? ( 0 'rg.af ! ) drop ;
:rg.offs | r -- ok
	'rg.cr1 !
	rg.lclr 1 'rg.ok ! rg.NA 'rg.anon !
	rg.cr1 rg.pass rg.cr1 rg.pass rg.cr1 rg.pass rg.cr1 rg.pass rg.cr1 rg.pass rg.cr1 rg.pass
	rg.ok 0? ( ; ) drop
	rg.cr1 'rg.rs rg rg.cr1 'rg.re rg 'rg.pe !
	1 'rg.af !
	( rg.pe <=? dup rg.kn1 1+ ) drop
	rg.af ;

|--- the accesses to the slots of a region
#rg.used 0 #rg.skip 0 #rg.six 0 #rg.rl 0 #rg.fr 0 #rg.fi 0 #rg.bi 0 #rg.bv 0 #rg.bi2 0 #rg.cnt 0 #rg.rm 0 #rg.last 0
#rg.fa 0 #rg.pe2 0 #rg.er 0 #rg.ld 0 #rg.curm 0 #rg.o0 0 #rg.so 0 #rg.sR 0 #rg.p0 0 #rg.r0 0 #rg.ln 0 #rg.ip 0 #rg.intf 0
#rg.hay 0 #rg.nd2 0 #rg.pos 0 #rg.rR 0 #rg.ri 0 #rg.nd 0

:rg.sfind | a -- idx/-1
	'rg.fid !
	0 ( rg.ns <? dup 'rg.sla rg rg.fid =? ( drop ; ) drop 1+ ) drop -1 ;

:rg.sget | a -- idx			; the entry of the slot ( made if it is new )
	dup rg.sfind 0 >=? ( nip ; ) drop
	rg.ns rg.MAXS 1- >=? ( 1 'rg.skip ! ) drop
	rg.ns rg.MAXS 1- min 'rg.lx !
	rg.lx 'rg.sla rs
	0 rg.lx 'rg.slr rs  0 rg.lx 'rg.slw rs  0 rg.lx 'rg.sldq rs  -1 rg.lx 'rg.slrg rs
	rg.ns 1+ rg.MAXS min 'rg.ns !
	rg.lx ;

:rg.acc1 | k --
	dup 'rg.um rg rg.used or 'rg.used !
	dup 'rg.sfl rg 1 and 1? ( 1 'rg.skip ! ) drop
	dup 'rg.sop rg 0 <? ( 2drop ; ) drop
	dup 'rg.off rg over 'rg.sd rg + rg.sget 'rg.six !
	dup 'rg.sfl rg 2 and 2 =? ( 1 rg.six 'rg.sldq rs ) drop
	'rg.srl rg 'rg.rl !
	rg.rl 1 and 1? ( rg.six 'rg.slr rg 1+ rg.six 'rg.slr rs ) drop
	rg.rl 2 and 2 =? ( rg.six 'rg.slw rg 1+ rg.six 'rg.slw rs ) drop ;

:rg.acc? | k --
	dup 'rg.k rg 3 <? ( 2drop ; ) drop rg.acc1 ;

:rg.analyze | r --
	'rg.cr1 !
	0 'rg.ns ! 0 'rg.used ! 0 'rg.skip !
	rg.cr1 'rg.re rg 'rg.pe !
	rg.cr1 'rg.rs rg ( rg.pe <=? dup rg.acc? 1+ ) drop ;

|--- which slots go to registers
:rg.cnt1 | idx -- n
	dup 'rg.slr rg swap 'rg.slw rg + ;
:rg.cand? | idx -- f
	dup 'rg.sldq rg 1? ( 2drop 0 ; ) drop
	dup 'rg.slrg rg -1 <>? ( 2drop 0 ; ) drop
	dup 'rg.slr rg 1 <? ( 2drop 0 ; ) drop
	rg.cnt1 ir.thr <? ( drop 0 ; ) drop 1 ;
:rg.best1 | idx --
	dup rg.cand? 0? ( 2drop ; ) drop
	dup rg.cnt1 rg.bv <=? ( 2drop ; ) 'rg.bv ! 'rg.bi ! ;
:rg.pickbest | -- idx/-1
	-1 'rg.bi ! -1 'rg.bv !
	0 ( rg.ns <? dup rg.best1 1+ ) drop
	rg.bi ;
:rg.nextfree | -- R/-1			; a register that the region does not use
	( rg.fi 11 <? drop
		'rg.pref rg.fi + c@ 'rg.fr !
		1 'rg.fi +!
		rg.used rg.fr >> 1 and 0? ( drop rg.fr ; ) drop ) drop -1 ;
:rg.sel1 | -- f
	rg.pickbest 'rg.bi2 !
	rg.bi2 0 <? ( drop 0 ; ) drop
	rg.nextfree -? ( drop 0 ; )
	rg.bi2 'rg.slrg rs 1 ;
:rg.select | --
	0 'rg.fi !
	( rg.sel1 1? drop ) drop ;

|--- the promotions of the region , by address
:rg.nx1 | idx --
	dup 'rg.slrg rg 0 <? ( 2drop ; ) drop
	dup 'rg.sla rg rg.last <=? ( 2drop ; )
	rg.bv >=? ( 2drop ; )
	'rg.bv ! 'rg.bi ! ;
:rg.nxt | -- f
	rg.np rg.cnt + rg.MAXP 1- >=? ( 1 'rg.fail ! drop 0 ; ) drop
	-1 'rg.bi ! $7fffffff 'rg.bv !
	0 ( rg.ns <? dup rg.nx1 1+ ) drop
	rg.bi 0 <? ( drop 0 ; ) drop
	rg.bi 'rg.sla rg 'rg.last !
	rg.last rg.np rg.cnt + 'rg.pa rs
	rg.bi 'rg.slrg rg rg.np rg.cnt + 'rg.pR rs
	rg.bi 'rg.slw rg rg.np rg.cnt + 'rg.pw rs
	rg.bi 'rg.slrg rg 1 swap << rg.rm or 'rg.rm !
	1 'rg.cnt +! 1 ;
:rg.entries | r --
	'rg.cr1 !
	rg.np rg.cr1 'rg.rpt rs
	0 'rg.cnt ! 0 'rg.rm ! -2147483647 'rg.last !
	( rg.nxt 1? drop ) drop
	rg.cnt rg.cr1 'rg.rpc rs  rg.rm rg.cr1 'rg.rpm rs
	rg.cnt 'rg.np +!
	rg.cnt 0? ( drop ; ) drop
	1 'ra.nreg +! rg.cnt 'ra.nslot +! ;

:rg.region | r --
	dup 'rg.rbad rg 1? ( 2drop ; ) drop
	dup rg.offs 0? ( 2drop ; ) drop
	dup rg.analyze
	rg.skip 1? ( 2drop ; ) drop
	rg.select
	rg.entries ;

|--- the new lines
:rg.emit | rec --
	rg.no rg.MAXO 1- >=? ( 1 'rg.fail ! ) drop
	rg.no rg.MAXO 1- min 'rg.lx !
	rg.lx 3 << rg.out + !
	rg.curm rg.lx 3 << rg.msk + !
	1 'rg.no +! ;
:rg.copyrec | i --
	3 << ra.src + @ rg.emit ;
:rg.putstr | str --			; a new line ( from lbuf ) to the pool 2
	ra.pool2 'rg.o0 !
	dup ra.pool2 ra.irpool2 + strcpy
	count nip 1+ ra.pool2 + 'ra.pool2 !
	rg.o0 8 << 2 or rg.emit ;
:rg.disp, | n --
	0? ( drop ; ) +? ( $2b ,c ) ,d ;
:rg.mkld | a R --			; mov R,qword[rbp+a]
	ib "mov " ,s 0 ra.rname ,s "," ,s "qword[rbp" ,s rg.disp, "]" ,s ie rg.putstr ;
:rg.mkst | a R off --			; mov qword[rbp+a-off],R
	'rg.so ! 'rg.sR !
	ib "mov qword[rbp" ,s rg.so - rg.disp, "]," ,s rg.sR 0 ra.rname ,s ie rg.putstr ;

:rg.promo | r a -- R/-1			; the register of the slot a in the region r
	'rg.fa !
	dup 'rg.rpt rg swap 'rg.rpc rg over + 'rg.pe2 !
	( rg.pe2 <? dup 'rg.pa rg rg.fa =? ( drop 'rg.pR rg ; ) drop 1+ ) drop -1 ;

:rg.int2 | j --
	'rg.id rg rg.ip =? ( 1 'rg.intf ! ) drop ;
:rg.int1 | j --
	dup 'rg.k rg 6 =? ( drop rg.int2 ; ) 8 =? ( drop rg.int2 ; ) 2drop ;
:rg.internal? | p r -- f		; the label p is the target of a jump of the region
	'rg.cr1 !
	dup 'rg.k rg 0 <>? ( 2drop 0 ; ) drop
	'rg.id rg 'rg.ip ! 0 'rg.intf !
	rg.cr1 'rg.re rg 'rg.pe !
	rg.cr1 'rg.rs rg ( rg.pe <=? dup rg.int1 1+ ) drop
	rg.intf ;
:rg.lead1 | -- f
	rg.p0 rg.r0 'rg.re rg >? ( drop 0 ; ) drop
	rg.p0 'rg.k rg 3 >=? ( drop 0 ; ) drop
	rg.p0 rg.r0 rg.internal? 1? ( drop 0 ; ) drop
	1 'rg.p0 +! 1 'rg.ln +! 1 ;
:rg.lead | r -- n			; labels at the begin of the region where the loads can go after
	'rg.r0 ! rg.r0 'rg.rs rg 'rg.p0 ! 0 'rg.ln !
	( rg.lead1 1? drop ) drop
	rg.ln ;

:rg.ld1 | e --
	dup 'rg.pa rg 0 >? ( 2drop ; )
	swap 'rg.pR rg rg.mkld ;
:rg.st1 | e --
	dup 'rg.pw rg 0? ( 2drop ; ) drop
	dup 'rg.pa rg rg.ci 'rg.off rg >? ( 2drop ; ) drop
	dup 'rg.pa rg swap 'rg.pR rg rg.ci 'rg.off rg rg.mkst ;
:rg.loads | r --
	dup 'rg.rpt rg swap 'rg.rpc rg over + 'rg.pe2 !
	( rg.pe2 <? dup rg.ld1 1+ ) drop ;
:rg.stores | r --
	dup 'rg.rpt rg swap 'rg.rpc rg over + 'rg.pe2 !
	( rg.pe2 <? dup rg.st1 1+ ) drop ;

:rg.find | hay needle -- adr/0
	'rg.nd !
	( dup c@ 1? drop dup rg.nd =pre 1? ( drop nip ; ) 2drop 1+ ) 2drop 0 ;
:rg.rewrite | i R --			; the line i with the slot operand replaced by the register R
	'rg.rR ! dup 'rg.ri ! 3 << ra.src + @ rtext 'rg.hay !
	rg.hay ir.fxq
	rg.ri 'rg.sop rg opbuf trim 'rg.nd2 !
	rg.hay rg.nd2 rg.find 'rg.pos !
	rg.pos 0? ( drop 1 'rg.fail ! rg.ri rg.copyrec ; ) drop
	ra.pool2 'rg.o0 ! ra.pool2 ra.irpool2 + >b
	rg.hay rg.pos ra.cpy
	rg.rR 0 ra.rname ra.puts
	rg.pos rg.nd2 count nip + rg.hay count nip rg.hay + ra.cpy
	0 cb!+ b> ra.irpool2 - 'ra.pool2 !
	rg.o0 8 << 2 or rg.emit ;
:rg.slotrec | i --
	dup 'rg.sop rg 0 <? ( drop rg.copyrec ; ) drop
	dup 'rg.off rg over 'rg.sd rg +
	rg.er swap rg.promo 0 <? ( drop rg.copyrec ; )
	rg.rewrite ;

:rg.emit1 | i --
	'rg.ci !
	rg.ci 'rg.reg rg 'rg.er !
	rg.er 'rg.rpc rg 0? ( drop 0 'rg.curm ! rg.ci rg.copyrec ; ) drop
	rg.er 'rg.rpm rg 'rg.curm !
	rg.ci rg.er 'rg.rs rg =? ( rg.er rg.lead 'rg.ld ! ) drop
	rg.ci rg.er 'rg.rs rg rg.ld + <? ( drop rg.ci rg.copyrec ; ) drop
	rg.ci rg.er 'rg.rs rg rg.ld + =? ( rg.er rg.loads ) drop
	rg.ci 'rg.k rg
	4 =? ( rg.er rg.stores ) 5 =? ( rg.er rg.stores ) 7 =? ( rg.er rg.stores ) drop
	rg.ci rg.slotrec ;

::rg.run | -- ok			; 1 if the lines of the word are other ( ra.src ra.srcn ra.msrc )
	irrec 'ra.src ! nrec 'ra.srcn ! 0 'ra.msrc !
	ir.rg 0? ( drop 0 ; ) drop
	nrec rg.MAXR >? ( drop 0 ; ) drop
	nrec 0? ( drop 0 ; ) drop
	nrec 'rg.n ! 0 'rg.nl ! 0 'rg.fail !
	0 ( rg.n <? dup rg.cls1 1+ ) drop
	rg.fail 1? ( drop 0 ; ) drop
	rg.regions
	0 'rg.np !
	0 ( rg.nr <? dup rg.region 1+ ) drop
	rg.fail 1? ( drop 0 ; ) drop
	rg.np 0? ( drop 0 ; ) drop
	0 'rg.no !
	0 ( rg.n <? dup rg.emit1 1+ ) drop
	rg.fail 1? ( drop 0 ; ) drop
	rg.out 'ra.src ! rg.no 'ra.srcn ! rg.msk 'ra.msrc !
	1 ;

:ra.make | --
	ir.ra 0? ( drop ra.copyall ; ) drop rg.run drop ra.run ;

|---------------------------------------------------------------
| the lines go to r3opt1
|---------------------------------------------------------------
| STAGE 2b : shorter encodings ( on the lines that the allocator made )
|   movsx r,byte[m] , and r,255 -> movzx e,byte[m]       and r,255 -> movzx e,l      and r,65535 -> movzx e,x
|   mov r,imm ( 0 .. 2^32-1 ) -> mov e,imm                mov r,0 -> xor e,e
|  the ones that change the flags ( and , xor ) only if the flags are dead: the next one that reads them is after one that writes them
|---------------------------------------------------------------
##ir.pp 1				| 0 = no shorter encodings
##ir.pre 0			| 1 = the lines before r3opt1 are written to the console ( ~line , ~;W at the end of each word ): tests
#pp.flagw
"cmp" "test" "add" "sub" "and" "or" "xor" "neg" "shl" "shr" "sar" "shld" "shrd" "bsr" "imul" "idiv" "div" "call" "ret" "jmp" "acall" ( 0 )
#pp.i #pp.w #pp.rec #pp.txt #pp.off #pp.c #pp.j #pp.v #pp.wg #pp.mask
#pp.mem * 80
#pp.r0 * 24

:pp.cls | rec -- c		; 0 does not touch the flags , 1 reads them , 2 writes them or the code ends
	dup 1 and 1 =? ( 2drop 2 ; ) drop
	rtext ":" =pos 1? ( 2drop 2 ; ) drop
	trim gettok drop
	'tkb c@ $6a =? ( drop 'tkb "jmp" =s 1? ( drop 2 ; ) drop 1 ; ) drop
	'tkb "cmov" =pre 1? ( 2drop 1 ; ) 2drop
	'tkb "set" =pre 1? ( 2drop 1 ; ) 2drop
	'tkb "adc" =pre 1? ( 2drop 1 ; ) 2drop
	'tkb "sbb" =pre 1? ( 2drop 1 ; ) 2drop
	'tkb 'pp.flagw lookup -1 >? ( drop 2 ; ) drop 0 ;

:pp.dead? | i -- f		; the flags are dead after the line i
	1+ 'pp.j !
	( pp.j ra.nout <? drop
		pp.j 3 << ra.irout + @ pp.cls
		1 =? ( drop 0 ; ) 2 =? ( drop 1 ; ) drop
		1 'pp.j +! ) drop
	1 ;

:pp.reg64 | -- n/-1		; the register ( 64 bits ) of the operand 0
	0 opbuf trim gettok drop regidx 0 <? ( ; ) 16 >=? ( drop -1 ; ) ;

:pp.numop | i -- f		; the operand i is a number ( in pp.v )
	opbuf trim dup c@ 0? ( 2drop 0 ; ) drop
	str>nro swap trim c@ 0? ( drop 'pp.v ! 1 ; ) 2drop 0 ;

:pp.begin | --
	ra.pool2 'pp.off ! ra.pool2 ra.irpool2 + >b ;
:pp.fin | -- rec
	0 cb!+ b> ra.irpool2 - 'ra.pool2 ! pp.off 8 << 2 or ;
:pp.put | rec --
	pp.w 3 << ra.irout + ! 1 'pp.w +! ;
:pp.e32 | -- str
	pp.c 1 ra.rname ;

:pp.mkxor | --
	pp.begin "xor " ra.puts pp.e32 ra.puts "," ra.puts pp.e32 ra.puts pp.fin pp.put 1 'pp.i +! ;
:pp.mkmov | --
	pp.begin "mov " ra.puts pp.e32 ra.puts "," ra.puts 1 opbuf trim ra.puts pp.fin pp.put 1 'pp.i +! ;

:pp.zero? | -- f
	pp.v 0 <>? ( drop 0 ; ) drop
	pp.i pp.dead? ;

:pp.movimm | -- f		; mov r,imm
	pp.txt ir.fxq
	'mnb "mov" =s 0? ( ; ) drop
	nopn 2 <>? ( drop 0 ; ) drop
	0 ra.opk 1 <>? ( drop 0 ; ) drop
	1 ra.opk 3 <>? ( drop 0 ; ) drop
	pp.reg64 0 <? ( drop 0 ; ) 'pp.c !
	1 pp.numop 0? ( ; ) drop
	pp.v $ffffffff >? ( drop 0 ; ) drop
	pp.v 0 <? ( drop 0 ; ) drop
	pp.zero? 1? ( drop pp.mkxor 1 ; ) drop
	pp.mkmov 1 ;

:pp.wgof | v -- wg/0
	255 =? ( drop 3 ; ) 65535 =? ( drop 2 ; ) drop 0 ;

:pp.andmask | -- f		; and r,255 / and r,65535
	pp.txt ir.fxq
	'mnb "and" =s 0? ( ; ) drop
	nopn 2 <>? ( drop 0 ; ) drop
	0 ra.opk 1 <>? ( drop 0 ; ) drop
	1 ra.opk 3 <>? ( drop 0 ; ) drop
	pp.reg64 0 <? ( drop 0 ; ) 'pp.c !
	1 pp.numop 0? ( ; ) drop
	pp.v pp.wgof 0? ( ; ) 'pp.wg !
	pp.i pp.dead? 0? ( ; ) drop
	pp.begin "movzx " ra.puts pp.e32 ra.puts "," ra.puts pp.c pp.wg ra.rname ra.puts pp.fin pp.put 1 'pp.i +!
	1 ;

:pp.memw | -- mask/0
	'pp.mem "byte" =pre 1? ( 2drop 255 ; ) 2drop
	'pp.mem "word" =pre 1? ( 2drop 65535 ; ) 2drop 0 ;

:pp.movzxmem | -- f		; movsx r,byte[m] + and r,255
	pp.txt ir.fxq
	'mnb "movsx" =s 0? ( ; ) drop
	nopn 2 <>? ( drop 0 ; ) drop
	0 ra.opk 1 <>? ( drop 0 ; ) drop
	1 ra.opk 2 <>? ( drop 0 ; ) drop
	pp.reg64 0 <? ( drop 0 ; ) 'pp.c !
	1 opbuf trim 'pp.mem strcpy
	0 opbuf trim 'pp.r0 strcpy
	pp.memw dup 'pp.mask ! 0? ( ; ) drop
	pp.i 1+ ra.nout >=? ( drop 0 ; ) drop
	pp.i 1+ 3 << ra.irout + @ dup 1 and 1 =? ( 2drop 0 ; ) drop
	rtext ":" =pos 1? ( 2drop 0 ; ) drop
	ir.fxq
	'mnb "and" =s 0? ( ; ) drop
	nopn 2 <>? ( drop 0 ; ) drop
	0 opbuf trim 'pp.r0 =s 0? ( ; ) drop
	1 ra.opk 3 <>? ( drop 0 ; ) drop
	1 pp.numop 0? ( ; ) drop
	pp.v pp.mask <>? ( drop 0 ; ) drop
	pp.i 1+ pp.dead? 0? ( ; ) drop
	pp.begin "movzx " ra.puts pp.e32 ra.puts "," ra.puts 'pp.mem ra.puts pp.fin pp.put 2 'pp.i +!
	1 ;

:ra.pp1 | --
	pp.i 3 << ra.irout + @ dup 'pp.rec !
	1 and 1 =? ( drop pp.rec pp.put 1 'pp.i +! ; ) drop
	pp.rec rtext dup 'pp.txt !
	":" =pos 1? ( 2drop pp.rec pp.put 1 'pp.i +! ; ) 2drop
	pp.movzxmem 1? ( drop ; ) drop
	pp.andmask 1? ( drop ; ) drop
	pp.movimm 1? ( drop ; ) drop
	pp.rec pp.put 1 'pp.i +! ;

:ra.peep | -- ; the lines of the word, in place
	ir.pp 0? ( drop ; ) drop
	0 'pp.w ! 0 'pp.i !
	( pp.i ra.nout <? drop ra.pp1 ) drop
	pp.w 'ra.nout ! ;

:replay1 | rec --
	dup ra.rbase over 8 >> +
	ir.dbg 1? ( drop nip "%s" .println ; ) drop
	swap 1 and 1 =? ( drop opt.label ; ) drop opt.ins ;

::ir.word | -- ; the lines of the word go to r3opt1
	ir.pre 1? ( "~;W" .println ) drop
	0 'ra.pool2 ! ra.make ra.peep
	0 ( ra.nout <? dup 3 << ra.irout + @ replay1 1+ ) drop
	0 'nrec ! 0 'pool> ! ;

:ir.flushraw | --		; the buffer is full: the lines go as they are
	ir.ra 'ra.sav ! 0 'ir.ra ! ir.word ra.sav 'ir.ra ! ;

| ##ir.pre is declared in the section of the encodings ( it is before )
:irput | text kind --
	ir.pre 1? ( pick2 "~%s" .println ) drop
	nrec 16380 >? ( ir.flushraw ) drop
	pool> 260000 >? ( ir.flushraw ) drop
	pool> 8 << or nrec 3 << irrec + !
	1 'nrec +!
	dup irpool pool> + strcpy
	count nip 1+ pool> + 'pool> ! ;

::ir.ins | text --
	1 'ir.ninst +!
	":" =pos 1? ( drop dup vlabel 0 irput ; ) drop
	dup ir.fx dup vcheck 0 irput ;

::ir.label | text --
	dup vlabel 1 irput ;

:ra.mkrnp | --			; pointers to the names of the registers
	0 'ra.ri !
	'regnames ( dup c@ 1? drop dup ra.ri 3 << ra.rnp + ! >>0 1 'ra.ri +! ) 2drop ;

::ir.alloc | -- ; the memory of the lines ( before the mark of the output )
	here dup 'irrec ! 131072 + dup 'irpool ! 262144 + 'here !
	ra.MAXI ra.arr 'ra.iK !   ra.MAXI ra.arr 'ra.iFl !  ra.MAXI ra.arr 'ra.iO0 !  ra.MAXI ra.arr 'ra.iNo !
	ra.MAXI ra.arr 'ra.iU !   ra.MAXI ra.arr 'ra.iD !   ra.MAXI ra.arr 'ra.iCp !  ra.MAXI ra.arr 'ra.iDel !
	ra.MAXI ra.arr 'ra.iSl !  ra.MAXI ra.arr 'ra.iSt !  ra.MAXI ra.arr 'ra.iRec ! ra.MAXI ra.arr 'ra.ord !
	ra.MAXO ra.arr 'ra.oR !   ra.MAXO ra.arr 'ra.oW !   ra.MAXO ra.arr 'ra.oRl !  ra.MAXO ra.arr 'ra.oFx !
	ra.MAXO ra.arr 'ra.oS !   ra.MAXO ra.arr 'ra.oE !   ra.MAXO ra.arr 'ra.oWu !  ra.MAXO ra.arr 'ra.oWd !
	ra.MAXW ra.arr 'ra.wC !   ra.MAXW ra.arr 'ra.wD !   ra.MAXW ra.arr 'ra.wU !   ra.MAXW ra.arr 'ra.wP !
	ra.MAXW ra.arr 'ra.wL !  ra.MAXW ra.arr 'ra.wFM !  ra.MAXW ra.arr 'ra.wLM !  ra.MAXW ra.arr 'ra.wCF !  ra.MAXW ra.arr 'ra.wCP !
	16384 ra.arr 'ra.irout !  40960 ra.arr 'ra.irpool2 !  64 ra.arr 'ra.rnp !
	rg.MAXR ra.arr 'rg.k !   rg.MAXR ra.arr 'rg.id !  rg.MAXR ra.arr 'rg.dl !  rg.MAXR ra.arr 'rg.off ! rg.MAXR ra.arr 'rg.reg !
	rg.MAXR ra.arr 'rg.sop ! rg.MAXR ra.arr 'rg.sd !  rg.MAXR ra.arr 'rg.srl ! rg.MAXR ra.arr 'rg.sfl ! rg.MAXR ra.arr 'rg.um !
	rg.MAXL ra.arr 'rg.lid ! rg.MAXL ra.arr 'rg.loff ! rg.MAXL ra.arr 'rg.lkn ! rg.MAXL ra.arr 'rg.lrg !
	rg.MAXR ra.arr 'rg.rs !  rg.MAXR ra.arr 'rg.re !  rg.MAXR ra.arr 'rg.rbad ! rg.MAXR ra.arr 'rg.rpm ! rg.MAXR ra.arr 'rg.rpt ! rg.MAXR ra.arr 'rg.rpc !
	rg.MAXS ra.arr 'rg.sla ! rg.MAXS ra.arr 'rg.slr ! rg.MAXS ra.arr 'rg.slw ! rg.MAXS ra.arr 'rg.sldq ! rg.MAXS ra.arr 'rg.slrg !
	rg.MAXP ra.arr 'rg.pa !  rg.MAXP ra.arr 'rg.pR !  rg.MAXP ra.arr 'rg.pw !
	rg.MAXO ra.arr 'rg.out ! rg.MAXO ra.arr 'rg.msk !
	ra.mkrnp ;

::ir.reset | --
	0 'nrec ! 0 'pool> ! $C031 'vdef ! $C031 'vsav !
	0 'ir.ninst ! 0 'ir.nviol ! 0 'ir.nunk !
	0 'ra.nmov ! 0 'ra.nup ! 0 'ra.nblk ! 0 'ra.nskip ! 0 'ra.nreg ! 0 'ra.nslot ! ;

::ir.report | --
	ir.nunk ir.nviol ir.ninst "ir: instructions %d, violations %d, unknown %d" .println
	ra.nskip ra.nup ra.nmov ra.nblk "ra: blocks %d, moves deleted %d, stores up %d, skipped %d" .println
	ra.nslot ra.nreg "rg: regions %d, slots in registers %d" .println ;
