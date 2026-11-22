| r3ssa - IR of a block of tokens for r3comp3
| PHREDA 2026
|---------------------------------------------------------------
| the tokens of a block are made as a tape of operations over virtual registers
| ( SSA : each value is defined one time ) , then the tape is written with the
| registers of the x64. The block begins and ends with the canonical stack:
|   rax = TOS , [rbp] = NOS , ...
|   entry cells : E0 = rax , E1 = [rbp] , E2 = [rbp-8] ...  ( R0 = rbp at the begin )
| the stack of the block is virtual ( vs ) : dup swap over ... do not make code.
| a block ends when a token is not supported, a call, a label, a jump or a condition.
|
| operand : >= 0 virtual register , < 0 constant -( n + 1 ) in the table of constants
|   constant kind 0 = number , 1 = label ( class<<32 | index )
|---------------------------------------------------------------
^r3/lib/mem.r3
^r3/lib/str.r3
^r3/d4/r3token.r3
^r3/d4/r3opt1.r3

|--- tape
#tOP * 8192
#tA * 8192
#tB * 8192
#tD * 8192
#tX * 8192
#no 0			| operations
#nv 0			| virtual registers
#po 0
#bcn 0			| cells ( 1.. ) that live in registers at the boundaries of the block
#rsvm 0			| reserved registers ( bit = register )
#vej * 8192			| entry cell of the virtual register ( -1 = not an entry cell )

|--- virtual stack
#vs * 4096
#vn 0
#ek 0			| entry cells used
#maxvn 0

|--- constants
#ck * 4096
#cv * 4096
#nc 0

##jt 0			| the target of the jump ( token index ) , it is set by the caller

|--- opcodes
| 1 ENT0 d | 2 LI d a | 3 ENTM d x=j | 4 BIN d a b x | 5 SHF d a b x | 6 UN d a x
| 7 LD d a x=size | 8 ST a b x=size | 9 ADDM a b x=size | 10 LDV d a
| 11 STC a x=offset | 12 MOVAX a | 13 CMPJ a b x=token | 14 ADDRBP x

:addop | op a b d x --
	no 3 << 'po !
	po 'tX + ! po 'tD + ! po 'tB + ! po 'tA + ! po 'tOP + !
	1 'no +! ;

:newv | -- v
	nv dup 1+ 'nv ! -1 over 3 << 'vej + ! ;

:cadd | kind val -- o
	nc 3 << 'cv + ! nc 3 << 'ck + !
	nc neg 1- 1 'nc +! ;

:isc | o -- 0/1
	63 >>> ;
:cidx | o -- i
	neg 1- ;
:ckind | o -- k
	cidx 3 << 'ck + @ ;
:cval | o -- v
	cidx 3 << 'cv + @ ;
:cnum? | o -- f ; constant number
	dup isc 0? ( nip ; ) drop
	ckind 0? ( drop 1 ; ) drop 0 ;
:cimm? | o -- f ; constant number as imm32
	dup cnum? 0? ( nip ; ) drop
	cval dup 32 << 32 >> - 0? ( drop 1 ; ) drop 0 ;

|--- begin
::ssa.begin | --
	0 'no ! 1 'nv ! 0 'vn ! 0 'ek ! 0 'maxvn ! 0 'nc ! -1 'vej !
	1 0 0 0 0 addop		| v0 = rax of the entry
	1 ( bcn <=? 1 0 0 pick3 pick4 3 + addop 1+ ) drop
	bcn 1+ 'nv ! ;

|--- virtual stack
:vpushn | o -- ; to the cell vn
	vn 3 << 'vs + ! 1 'vn +!
	vn maxvn >? ( dup 'maxvn ! ) drop ;

#tv
:ent | -- o ; the next entry cell
	ek 0? ( drop 1 'ek ! 0 ; ) drop
	ek bcn <=? ( drop ek 1 'ek +! ; ) drop
	newv 'tv ! ek tv 3 << 'vej + ! 3 0 0 tv ek addop
	1 'ek +! tv ;

:vins | o -- ; at the bottom
	vn ( 1? 1- dup 3 << 'vs + @ over 1+ 3 << 'vs + ! ) drop
	'vs ! 1 'vn +!
	vn maxvn >? ( dup 'maxvn ! ) drop ;

:need | n -- ; at least n cells
	( vn >? ent vins ) drop ;

:vpop | -- o
	vn 0? ( drop ent ; ) drop
	-1 'vn +! vn 3 << 'vs + @ ;

:vpush | o --
	vpushn ;

:vtop | d -- o
	dup 1+ need vn 1- swap - 3 << 'vs + @ ;

|--- x64
#rq "rax" "rcx" "rdx" "rbx" "rsi" "rdi" "r8" "r9" "r10" "r11" "r12" "r13"
#rd "eax" "ecx" "edx" "ebx" "esi" "edi" "r8d" "r9d" "r10d" "r11d" "r12d" "r13d"
#rw "ax" "cx" "dx" "bx" "si" "di" "r8w" "r9w" "r10w" "r11w" "r12w" "r13w"
#rb "al" "cl" "dl" "bl" "sil" "dil" "r8b" "r9b" "r10b" "r11b" "r12b" "r13b"

:nth | n 'list -- str
	swap ( 1? 1- swap >>0 swap ) drop ;

:,reg | r --
	'rq nth ,s ;
:,regw | r w --
	8 =? ( drop ,reg ; )
	4 =? ( drop 'rd nth ,s ; )
	2 =? ( drop 'rw nth ,s ; )
	drop 'rb nth ,s ;

:,nm | n --
	dup 32 << 32 >> <>? ( "$" ,s ,h ; ) ,d ;

#slpre "w" "s_" "l_"		| prefix of the labels: word , string , local

:,lbl | v -- ; offset<<40 | class<<32 | index
	dup 32 >>> $3 and 'slpre nth ,s
	dup $ffffffff and ,h
	40 >> 0? ( drop ; ) +? ( $2b ,c ) ,d ;

:,cst | o -- ; the constant
	dup ckind 0? ( drop cval ,nm ; ) drop
	cval ,lbl ;

:,szn | w --
	8 =? ( drop "qword" ,s ; ) 4 =? ( drop "dword" ,s ; ) 2 =? ( drop "word" ,s ; )
	drop "byte" ,s ;

:ins | -- ; ie opt.ins
	ie opt.ins ;

|---------------------------------------------------------------
| WRITE THE TAPE ( 2a : every virtual register has a slot in memory )
|---------------------------------------------------------------
:gO 3 << 'tOP + @ ;
:gA 3 << 'tA + @ ;
:gB 3 << 'tB + @ ;
:gD 3 << 'tD + @ ;
:gX 3 << 'tX + @ ;

:,off | n --
	0? ( drop ; )
	+? ( $2b ,c ) ,d ;

:,slot | v --
	"qword[rbp+" ,s maxvn 2 + + 3 << ,d "]" ,s ;

:,opn | o -- ; source operand
	dup isc 1? ( drop ,cst ; ) drop ,slot ;

:ldo | o r -- ; mov r,o
	ib "mov " ,s ,reg "," ,s ,opn ins ;

:stv | r d -- ; mov slot,r
	ib "mov " ,s ,slot "," ,s ,reg ins ;

:i1 | "text" --
	ib ,s ins ;

#ti
:e.ent0 | i --
	gD 0 swap stv ;
:e.li | i --
	dup gA 1 ldo gD 1 swap stv ;
:e.entm | i --
	ib "mov rcx,qword[rbp" ,s dup gX 1- 3 << neg ,off "]" ,s ins
	gD 1 swap stv ;

#bmn "add" "sub" "and" "or" "xor" "imul"
:e.bin | i --
	'ti !
	ti gA 1 ldo
	ti gB cimm? 1? ( drop
		ib ti gX 'bmn nth ,s " rcx," ,s ti gX 5 =? ( "rcx," ,s ) drop ti gB ,cst ins
		1 ti gD stv ; ) drop
	ti gB 2 ldo
	ib ti gX 'bmn nth ,s " rcx,rdx" ,s ins
	1 ti gD stv ;

#smn "shl" "sar" "shr"
:e.shf | i --
	'ti !
	ti gB cnum? 1? ( drop
		ti gA 1 ldo
		ib ti gX 'smn nth ,s " rcx," ,s ti gB cval 63 and ,d ins
		1 ti gD stv ; ) drop
	ti gB 1 ldo ti gA 2 ldo
	ib ti gX 'smn nth ,s " rdx,cl" ,s ins
	2 ti gD stv ;

:e.un | i --
	'ti !
	ti gA 1 ldo
	ti gX 0 =? ( drop "not rcx" i1 1 ti gD stv ; )
	1 =? ( drop "neg rcx" i1 1 ti gD stv ; )
	drop
	"mov rdx,rcx" i1 "sar rdx,63" i1 "add rcx,rdx" i1 "xor rcx,rdx" i1
	1 ti gD stv ;

:,ldm | size -- ; mnemonic of the load
	8 =? ( drop "mov" ,s ; ) 4 =? ( drop "movsxd" ,s ; ) drop "movsx" ,s ;

:e.ld | i --
	'ti !
	ti gA 2 ldo
	ib ti gX ,ldm " rcx," ,s ti gX ,szn "[rdx]" ,s ins
	1 ti gD stv ;

:e.st | i -- ; mnemonic is in tm
	'ti !
	ti gB 1 ldo ti gA 2 ldo
	ib ti gO 8 =? ( "mov " ,s ) 9 =? ( "add " ,s ) drop
	ti gX ,szn "[rdx]," ,s 1 ti gX ,regw ins ;

:e.ldv | i --
	'ti !
	ib "mov rcx,qword[" ,s ti gA ,cst "]" ,s ins
	1 ti gD stv ;

:e.stc | i -- ; store a cell
	'ti !
	ti gA cimm? 1? ( drop
		ib "mov qword[rbp" ,s ti gX ,off "]," ,s ti gA ,cst ins ; ) drop
	ti gA 1 ldo
	ib "mov qword[rbp" ,s ti gX ,off "],rcx" ,s ins ;

:e.movax | i --
	gA 0 ldo ;

#jcc "jnz" "jz" "js" "jns" "jge" "jle" "jne" "jl" "jg" "je" "jz" "jnz"
:ejcc | --
	ib ti gX 13 - 'jcc nth ,s " l_" ,s jt ,h ins ;
:cmpmn | x -- str
	23 <? ( drop "cmp" ; ) drop "test" ;
:e.cmpj | i --
	'ti !
	ti gA 1 ldo
	ti gX 17 <? ( drop "test rcx,rcx" i1 ; ) drop
	ti gB cimm? 1? ( drop
		ib ti gX cmpmn ,s " rcx," ,s ti gB cval ,d ins
		; ) drop
	ti gB 2 ldo
	ib ti gX cmpmn ,s " rcx,rdx" ,s ins ;

:e.jcc | i --
	'ti ! ejcc ;

:e.addrbp | i --
	gX 0? ( drop ; )
	+? ( ib "add rbp," ,s ,d ins ; )
	neg ib "sub rbp," ,s ,d ins ;

:divreg | op -- r
	16 =? ( drop 0 ; ) drop 2 ;
:e.div | i -- ; 16 / , 17 mod
	'ti !
	ti gA 0 ldo ti gB 1 ldo
	"cqo" i1 "idiv rcx" i1
	ti gO divreg ti gD stv ;
:e.idm | i --
	'ti !
	ti gA 0 ldo ti gB 1 ldo
	"cqo" i1 "idiv rcx" i1
	0 ti gD stv 2 ti gX stv ;
:e.muldiv | i --
	'ti !
	ti gA 0 ldo ti gB 1 ldo
	"imul rcx" i1
	ti gX 1 ldo "idiv rcx" i1
	0 ti gD stv ;
:e.shldiv | i --
	'ti !
	ti gX 1 ldo ti gA 0 ldo
	"cqo" i1 "shld rdx,rax,cl" i1 "shl rax,cl" i1
	ti gB 1 ldo "idiv rcx" i1
	0 ti gD stv ;
:,mulshr | c --
	0 =? ( drop ; )
	64 <? ( ib "shrd rax,rdx," ,s ,d ins ; )
	64 - ib "sar rdx," ,s ,d ins "mov rax,rdx" i1 ;
:e.mulshr | i --
	'ti !
	ti gA 0 ldo ti gB 1 ldo
	"imul rcx" i1 ti gX ,mulshr
	0 ti gD stv ;

:emitop | i --
	dup gO
	16 =? ( drop e.div ; ) 17 =? ( drop e.div ; ) 18 =? ( drop e.idm ; )
	19 =? ( drop e.muldiv ; ) 20 =? ( drop e.shldiv ; ) 21 =? ( drop e.mulshr ; )
	1 =? ( drop e.ent0 ; )
	2 =? ( drop e.li ; )
	3 =? ( drop e.entm ; )
	4 =? ( drop e.bin ; )
	5 =? ( drop e.shf ; )
	6 =? ( drop e.un ; )
	7 =? ( drop e.ld ; )
	8 =? ( drop e.st ; )
	9 =? ( drop e.st ; )
	10 =? ( drop e.ldv ; )
	11 =? ( drop e.stc ; )
	12 =? ( drop e.movax ; )
	13 =? ( drop e.cmpj ; )
	14 =? ( drop e.addrbp ; )
	15 =? ( drop e.jcc ; )
	2drop ;

|---------------------------------------------------------------
| END OF THE BLOCK : the canonical stack
|---------------------------------------------------------------
#adj
:selfst? | i -- f ; the cell is the entry cell that is in this place
	dup 3 << 'vs + @
	0 <? ( 2drop 0 ; )
	3 << 'vej + @
	1 <? ( 2drop 0 ; )
	over 1+ ek - + 0 =? ( 2drop 1 ; ) 2drop 0 ;
:stc1 | i -- ; store the cell
	11 over 3 << 'vs + @ 0 0 pick4 2 + ek - 3 << addop drop ;

:bcreg | j -- r
	3 + ;
#ct
:cellreg | i -- ; the cell goes to the register of its place ( promoted )
	dup 3 << 'vs + @
	ct =? ( 2drop ; )
	12 swap 0 0 ct bcreg addop drop ;
:cell1 | i -- ; a cell that is not the top
	vn 1- over - 'ct !
	ct bcn <=? ( drop cellreg ; ) drop
	dup selfst? 0? ( over stc1 ) drop drop ;

:epilogue | -- ; the stack is made canonical
	0 'adj !
	vn 0? ( ek 0? ( 2drop 12 0 0 0 0 addop ; ) drop 1 need ) drop
	ek 0? ( 0 vins 1 'ek ! ) drop
	0 ( vn 1- <? dup cell1 1+ ) drop
	12 vn 1- 3 << 'vs + @ 0 0 0 addop
	vn ek - 3 << 'adj ! ;

:written | -- ; the tape is written
	0 ( no <? dup emitop 1+ ) drop ;


|---------------------------------------------------------------
| WRITE THE TAPE ( 2b : SSRA , a pass in reverse )
|---------------------------------------------------------------
| the tape is walked from the end to the begin. a virtual register is alive
| from the last use ( the first that is seen ) to the definition. When the registers
| are not enough the less recently used is spilled to a slot above the stack.
| the instructions are made in reverse order and then written.
|   vloc[v] = register | -1 not alive | -2 in memory ( slot )
|---------------------------------------------------------------
#vloc * 8192
#vslot * 8192
#rv * 128
#rt * 128
#lockm 0
#nslot 0
#step 0
#pref -1
#obuf * 131072
#oend 0
#optr * 32768
#nout 0
#pqk * 512
#pqa * 512
#pqb * 512
#npq 0

:vl@ 3 << 'vloc + @ ;
:vl! | loc v -- 
	3 << 'vloc + ! ;
:rv@ 3 << 'rv + @ ;
:rv! | v r -- 
	3 << 'rv + ! ;
:locked? | r -- f
	1 swap << lockm and ;
:lock | r -- 
	1 swap << lockm or 'lockm ! ;
:touch | r -- 
	step swap 3 << 'rt + ! ;

:rins | -- ; the text goes to the buffer of the block
	ie oend nout 3 << 'optr + ! oend strcpyl 'oend !
	1 'nout +! ;

:,sl | s -- ; slot
	"qword[rbp+" ,s maxvn 2 + + 3 << ,d "]" ,s ;
:ldsl | r s -- ; mov r,[slot]
	ib "mov " ,s swap ,reg "," ,s ,sl rins ;
:stsl | r s -- ; mov [slot],r
	ib "mov " ,s ,sl "," ,s ,reg rins ;
:mvr | xd rs -- ; mov xd,rs
	ib "mov " ,s swap ,reg "," ,s ,reg rins ;
:ldc | r o -- ; mov r,const
	ib "mov " ,s swap ,reg "," ,s ,cst rins ;

:slotof | v -- s
	dup 3 << 'vslot + @
	-1 <>? ( nip ; ) drop
	nslot swap 3 << 'vslot + over swap !
	1 'nslot +! ;

#er #ev
:evict | r -- ; the value goes to memory , it is loaded after the instruction
	dup 'er ! rv@ 'ev !
	er ev slotof ldsl
	-2 ev vl! -1 er rv! ;

:freeok0? | r -- f
	dup rv@ -1 <>? ( 2drop 0 ; ) drop
	locked? 0? ( drop 1 ; ) drop 0 ;
:freeok? | r -- f ; free and not reserved
	rsvm over >> 1 and 1? ( 2drop 0 ; ) drop
	freeok0? ;

:findfree | -- r
	pref 0 >=? ( dup freeok0? 1? ( drop ; ) drop ) drop
	0 ( 12 <? dup freeok? 1? ( drop ; ) drop 1+ ) drop -1 ;

:cand? | r -- f ; not locked and with value
	rsvm over >> 1 and 1? ( 2drop 0 ; ) drop
	dup rv@ -1 =? ( 2drop 0 ; ) drop
	locked? 0? ( drop 1 ; ) drop 0 ;

#bestr #bestt #ri
:lru | -- r
	-1 'bestr ! $7fffffffffff 'bestt ! 0 'ri !
	12 ( 1? 1-
		ri cand? 1? ( ri 3 << 'rt + @ bestt <? ( ri 'bestr ! dup 'bestt ! ) drop ) drop
		1 'ri +! ) drop
	bestr ;

:getfree | -- r
	findfree -1 <>? ( ; ) drop
	lru dup evict ;

:bind | v r -- ; v lives in r
	dup touch dup lock 2dup rv! swap vl! ;

:pq+ | k a b --
	npq 3 << 'pqb + ! npq 3 << 'pqa + ! npq 3 << 'pqk + !
	1 'npq +! ;
:pq.ld | r s -- 
	0 -rot pq+ ;
:pq.mv | xd rs -- 
	1 -rot pq+ ;
:pq.ci | xd o -- 
	2 -rot pq+ ;

#pi
:pq1 | i --
	'pi !
	pi 3 << 'pqk + @
	0 =? ( drop pi 3 << 'pqa + @ pi 3 << 'pqb + @ ldsl ; )
	1 =? ( drop pi 3 << 'pqa + @ pi 3 << 'pqb + @ mvr ; )
	drop pi 3 << 'pqa + @ pi 3 << 'pqb + @ ldc ;
:pqflush | -- ; the instructions before the operation
	npq ( 1? 1- dup pq1 ) drop 0 'npq ! ;

#uo #ur
:pbc | v -- r ; the register of an entry value ( -1 = none )
	bcn >? ( drop -1 ; ) 0? ( ; ) 3 + ;
:usereg | o -- r ; register with the value of the virtual register
	'uo !
	uo vl@ 0 >=? ( dup lock dup touch ; )
	-1 =? ( drop uo pbc 'pref ! getfree -1 'pref ! 'ur ! uo ur bind ur ; )
	drop getfree 'ur ! ur lock
	ur uo slotof pq.ld ur ;

:imm? | o -- f ; constant that can be an immediate
	dup isc 0? ( nip ; ) drop
	dup ckind 1 =? ( 2drop 1 ; ) drop cimm? ;

#sc
:srcreg | o -- r ; register with the operand ( constant too )
	dup isc 1? ( drop 'sc ! getfree dup lock dup sc pq.ci ; ) drop
	usereg ;

#dd #dr
:dstreg | v -- r ; register of the definition ( -1 = not alive )
	dup 'dd ! vl@
	-1 =? ( ; )
	-2 =? ( drop getfree 'dr ! dr lock dr dd slotof stsl -1 dd vl! dr ; )
	dup lock -1 dd vl! -1 over rv! ;

#ra2 #ao2
:srcA2 | a xd -- ; the first operand in xd at the begin of the instruction
	'ra2 ! 'ao2 !
	ao2 isc 1? ( drop ra2 ao2 pq.ci ; ) drop
	ao2 vl@
	-1 =? ( drop ao2 ra2 bind ; )
	-2 =? ( drop ra2 ao2 slotof pq.ld ; )
	ra2 swap pq.mv ;

#xd #xb #xc #am
:rA | -- a ; operand a of the operation
	ti gA ;
:rB | -- b
	ti gB ;

|--- fixed registers
#fixm 0
#mc 0
:fixedreg? | r -- f
	fixm swap >> 1 and ;

:claim | r -- ; the register is used by the operation
	dup rv@ -1 <>? ( over evict ) drop lock ;

#cd #cf #lc
:outreg | d F -- ; the result d is made in the fixed register F
	'cf ! 'cd !
	cd vl@ 'lc !
	lc -1 =? ( drop cf claim ; ) drop
	lc cf =? ( drop -1 cd vl! -1 cf rv! cf lock ; ) drop
	lc 0 >=? ( lc fixedreg? 1? ( lc evict -2 'lc ! ) drop ) drop
	cf claim
	lc 0 >=? ( drop lc cf mvr -1 lc rv! -1 cd vl! ; ) drop
	cf cd slotof stsl -1 cd vl! ;

#io #iF
:infix | o F -- ; the operand in the fixed register F at the begin
	'iF ! 'io !
	iF claim
	io isc 1? ( drop iF io pq.ci ; ) drop
	io vl@
	-1 =? ( drop io iF bind ; )
	-2 =? ( drop iF io slotof pq.ld ; )
	iF swap pq.mv ;

:dead? | v -- f
	vl@ -1 =? ( drop 1 ; ) drop 0 ;

:divF | op -- r
	16 =? ( drop 0 ; ) drop 2 ;

:r.div | i -- ; 16 / , 17 mod
	'ti !
	ti gD dead? 1? ( drop ; ) drop
	5 'fixm !
	ti gD ti gO divF outreg
	0 claim 2 claim
	rA 0 infix
	rB srcreg 'xb !
	ib "idiv " ,s xb ,reg rins
	ib "cqo" ,s rins
	pqflush ;

:r.idm | i -- ; /mod
	'ti !
	ti gD dead? 1? ( drop ti gX dead? 1? ( drop ; ) ) drop
	5 'fixm !
	ti gD 0 outreg ti gX 2 outreg
	0 claim 2 claim
	rA 0 infix
	rB srcreg 'xb !
	ib "idiv " ,s xb ,reg rins
	ib "cqo" ,s rins
	pqflush ;

:r.muldiv | i -- ; a*b/c
	'ti !
	ti gD dead? 1? ( drop ; ) drop
	5 'fixm !
	ti gD 0 outreg
	0 claim 2 claim
	rA 0 infix
	rB srcreg 'xb !
	ti gX srcreg 'xc !
	ib "idiv " ,s xc ,reg rins
	ib "imul " ,s xb ,reg rins
	pqflush ;

:r.shldiv | i -- ; (a<<c)/b
	'ti !
	ti gD dead? 1? ( drop ; ) drop
	7 'fixm !
	ti gD 0 outreg
	0 claim 1 claim 2 claim
	rA 0 infix
	ti gX 1 infix
	rB srcreg 'xb !
	ib "idiv " ,s xb ,reg rins
	ib "shl rax,cl" ,s rins
	ib "shld rdx,rax,cl" ,s rins
	ib "cqo" ,s rins
	pqflush ;

:r.mulshr | i -- ; (a*b)>>c
	'ti !
	ti gD dead? 1? ( drop ; ) drop
	5 'fixm !
	ti gX 'mc !
	ti gD 0 outreg
	0 claim 2 claim
	rA 0 infix
	rB srcreg 'xb !
	mc 0 >? ( mc 64 <? ( ib "shrd rax,rdx," ,s mc ,d rins ) drop ) drop
	mc 63 >? ( ib "mov rax,rdx" ,s rins ib "sar rdx," ,s mc 64 - ,d rins ) drop
	ib "imul " ,s xb ,reg rins
	pqflush ;


#xr
:r.ent0 | i -- ; the entry value is in the register x
	'ti ! ti gD 'dd ! ti gX 'xr !
	dd vl@
	-1 =? ( drop ; )
	-2 =? ( drop xr dd slotof stsl -1 dd vl! ; )
	'xd !
	xd xr <>? ( xd xr mvr ) drop
	-1 xd rv! -1 dd vl! ;

:r.li | i --
	'ti ! ti gD dstreg 'xd !
	xd 0 <? ( drop ; ) drop
	ib "mov " ,s xd ,reg "," ,s rA ,cst rins ;

:r.entm | i --
	'ti ! ti gD dstreg 'xd !
	xd 0 <? ( drop ; ) drop
	ib "mov " ,s xd ,reg ",qword[rbp" ,s ti gX 1- 3 << neg ,off "]" ,s rins ;

:r.ldv | i --
	'ti ! ti gD dstreg 'xd !
	xd 0 <? ( drop ; ) drop
	ib "mov " ,s xd ,reg ",qword[" ,s rA ,cst "]" ,s rins ;

:r.bin | i --
	'ti ! ti gD dstreg 'xd !
	xd 0 <? ( drop ; ) drop
	rB imm? 1? ( drop
		ib ti gX 'bmn nth ,s " " ,s xd ,reg "," ,s ti gX 5 =? ( xd ,reg "," ,s ) drop rB ,cst rins
		rA xd srcA2 pqflush ; ) drop
	rB srcreg 'xb !
	ib ti gX 'bmn nth ,s " " ,s xd ,reg "," ,s xb ,reg rins
	rA xd srcA2 pqflush ;

:r.shf | i -- ; the count is a constant or a register ( cl )
	'ti !
	ti gD dead? 1? ( drop ; ) drop
	rB cnum? 1? ( drop
		ti gD dstreg 'xd !
		ib ti gX 'smn nth ,s " " ,s xd ,reg "," ,s rB cval 63 and ,d rins
		rA xd srcA2 pqflush ; ) drop
	1 claim
	ti gD dstreg 'xd !
	rB 1 infix
	ib ti gX 'smn nth ,s " " ,s xd ,reg ",cl" ,s rins
	rA xd srcA2 pqflush ;

#rt2
:r.un | i --
	'ti ! ti gD dstreg 'xd !
	xd 0 <? ( drop ; ) drop
	ti gX 0 =? ( drop ib "not " ,s xd ,reg rins rA xd srcA2 pqflush ; )
	1 =? ( drop ib "neg " ,s xd ,reg rins rA xd srcA2 pqflush ; )
	drop
	getfree 'rt2 ! rt2 lock
	ib "xor " ,s xd ,reg "," ,s rt2 ,reg rins
	ib "add " ,s xd ,reg "," ,s rt2 ,reg rins
	ib "sar " ,s rt2 ,reg ",63" ,s rins
	ib "mov " ,s rt2 ,reg "," ,s xd ,reg rins
	rA xd srcA2 pqflush ;

:addrmode | o -- 0/1/2 ; 0 register , 1 label , 2 number
	dup isc 0? ( nip ; ) drop
	ckind 1 =? ( drop 1 ; ) drop 2 ;

:,addr | -- ; [ ... ] of the address
	am 1 =? ( drop rA ,cst ; ) drop xb ,reg ;

:r.ld | i --
	'ti ! ti gD dstreg 'xd !
	xd 0 <? ( drop ; ) drop
	rA addrmode 'am !
	am 1 =? ( drop
		ib ti gX ,ldm " " ,s xd ,reg "," ,s ti gX ,szn "[" ,s rA ,cst "]" ,s rins ; ) drop
	am 2 =? ( drop
		ib ti gX ,ldm " " ,s xd ,reg "," ,s ti gX ,szn "[" ,s xd ,reg "]" ,s rins
		xd rA pq.ci pqflush ; ) drop
	rA vl@ -1 =? ( drop
		ib ti gX ,ldm " " ,s xd ,reg "," ,s ti gX ,szn "[" ,s xd ,reg "]" ,s rins
		rA xd bind ; ) drop
	rA usereg 'xb !
	ib ti gX ,ldm " " ,s xd ,reg "," ,s ti gX ,szn "[" ,s xb ,reg "]" ,s rins
	pqflush ;

:,immw | o size --
	over ckind 1 =? ( 2drop ,cst ; ) drop
	swap cval swap
	1 =? ( drop $ff and ,d ; ) 2 =? ( drop $ffff and ,d ; ) 4 =? ( drop $ffffffff and ,d ; ) drop ,d ;

:r.st | i -- ; ST ( 8 ) or ADDM ( 9 )
	'ti !
	rA addrmode 'am !
	am 0 =? ( rA usereg 'xb ! ) 2 =? ( rA srcreg 'xb ! 0 'am ! ) drop
	rB imm? 1? ( drop
		ib ti gO 8 =? ( "mov " ,s ) drop ti gO 9 =? ( "add " ,s ) drop
		ti gX ,szn "[" ,s ,addr "]," ,s rB ti gX ,immw rins pqflush ; ) drop
	rB srcreg 'xc !
	ib ti gO 8 =? ( "mov " ,s ) drop ti gO 9 =? ( "add " ,s ) drop
	ti gX ,szn "[" ,s ,addr "]," ,s xc ti gX ,regw rins pqflush ;

:r.stc | i --
	'ti !
	rA imm? 1? ( drop
		ib "mov qword[rbp" ,s ti gX ,off "]," ,s rA ,cst rins ; ) drop
	rA srcreg 'xc !
	ib "mov qword[rbp" ,s ti gX ,off "]," ,s xc ,reg rins pqflush ;


:axocc? | -- f ; the register has other value
	xr rv@ dup -1 =? ( 2drop 0 ; ) ao2 =? ( 2drop 0 ; ) 2drop 1 ;

:r.movax | i -- ; the value goes to the register x ( rax = the TOS )
	'ti ! ti gA 'ao2 ! ti gX 'xr !
	axocc? 1? ( xr evict ) drop
	ao2 isc 1? ( drop ib "mov " ,s xr ,reg "," ,s ao2 ,cst rins ; ) drop
	ao2 vl@
	-1 =? ( drop ao2 xr bind ; )
	xr =? ( drop ; )
	-2 =? ( drop xr ao2 slotof ldsl ; )
	xr swap mvr ;

:r.cmpj | i --
	'ti !
	0 'pref ! rA srcreg 'xc ! -1 'pref !
	ti gX 17 <? ( drop ib "test " ,s xc ,reg "," ,s xc ,reg rins pqflush ; ) drop
	rB imm? 1? ( drop
		ib ti gX cmpmn ,s " " ,s xc ,reg "," ,s rB ,cst rins pqflush ; ) drop
	rB srcreg 'xb !
	ib ti gX cmpmn ,s " " ,s xc ,reg "," ,s xb ,reg rins pqflush ;

:r.jcc | i --
	'ti ! ib ti gX 13 - 'jcc nth ,s " l_" ,s jt ,h rins ;

:r.addrbp | i --
	gX 0? ( drop ; )
	+? ( ib "add rbp," ,s ,d rins ; )
	neg ib "sub rbp," ,s ,d rins ;

:,ar | x --
	$ff and 14 =? ( drop "r14" ,s ; ) drop "r15" ,s ;

:r.awrite | i --
	'ti !
	rA isc 1? ( drop ib "mov " ,s ti gX ,ar "," ,s rA ,cst rins ; ) drop
	rA usereg 'xb !
	ib "mov " ,s ti gX ,ar "," ,s xb ,reg rins pqflush ;

:r.aadd | i --
	'ti !
	rA imm? 1? ( drop ib "add " ,s ti gX ,ar "," ,s rA ,cst rins ; ) drop
	rA srcreg 'xb !
	ib "add " ,s ti gX ,ar "," ,s xb ,reg rins pqflush ;

:r.aread | i --
	'ti ! ti gD dstreg 'xd !
	xd 0 <? ( drop ; ) drop
	ib "mov " ,s xd ,reg "," ,s ti gX ,ar rins ;

#asz #ainc
:r.ald | i --
	'ti !
	ti gX 8 >> $ff and 'asz ! ti gX 16 >> $ff and 'ainc !
	ainc 1? ( ib "add " ,s ti gX ,ar "," ,s asz ,d rins ) drop
	ti gD dstreg 'xd !
	xd 0 <? ( drop ; ) drop
	ib asz ,ldm " " ,s xd ,reg "," ,s asz ,szn "[" ,s ti gX ,ar "]" ,s rins ;

:r.ast | i --
	'ti !
	ti gX 8 >> $ff and 'asz ! ti gX 16 >> $ff and 'ainc !
	ainc 1? ( ib "add " ,s ti gX ,ar "," ,s asz ,d rins ) drop
	rA imm? 1? ( drop
		ib "mov " ,s asz ,szn "[" ,s ti gX ,ar "]," ,s rA asz ,immw rins ; ) drop
	rA srcreg 'xc !
	ib "mov " ,s asz ,szn "[" ,s ti gX ,ar "]," ,s xc asz ,regw rins pqflush ;

:ropx | i -- ; one operation
	dup gO
	1 =? ( drop r.ent0 ; ) 2 =? ( drop r.li ; ) 3 =? ( drop r.entm ; )
	4 =? ( drop r.bin ; ) 5 =? ( drop r.shf ; ) 6 =? ( drop r.un ; )
	7 =? ( drop r.ld ; ) 8 =? ( drop r.st ; ) 9 =? ( drop r.st ; )
	10 =? ( drop r.ldv ; ) 11 =? ( drop r.stc ; ) 12 =? ( drop r.movax ; )
	13 =? ( drop r.cmpj ; ) 14 =? ( drop r.addrbp ; ) 15 =? ( drop r.jcc ; )
	16 =? ( drop r.div ; ) 17 =? ( drop r.div ; ) 18 =? ( drop r.idm ; )
	19 =? ( drop r.muldiv ; ) 20 =? ( drop r.shldiv ; ) 21 =? ( drop r.mulshr ; )
	24 =? ( drop r.awrite ; ) 25 =? ( drop r.aread ; ) 26 =? ( drop r.aadd ; )
	27 =? ( drop r.ald ; ) 28 =? ( drop r.ast ; )
	2drop ;

:rop | i --
	0 'lockm ! 0 'npq ! 1 'step +!
	ropx ;

:ssra.reset
	0 'nout ! 'obuf 'oend ! 0 'nslot ! 0 'step ! -1 'pref !
	nv ( 1? 1- -1 over vl! -1 over 3 << 'vslot + ! ) drop
	12 ( 1? 1- -1 over rv! 0 over 3 << 'rt + ! ) drop ;

#ssra 1
:written2 | --
	ssra.reset
	no ( 1? 1- dup rop ) drop
	nout ( 1? 1- dup 3 << 'optr + @ opt.ins ) drop ;

:wr | --
	ssra 1? ( drop written2 ; ) drop written ;

:blockempty? | -- f
	no 1 <>? ( drop 0 ; ) drop
	vn 1? ( drop 0 ; ) drop
	ek 1? ( drop 0 ; ) drop
	1 ;

::ssa.flush | --
	blockempty? 1? ( drop ssa.begin ; ) drop
	epilogue 14 0 0 0 adj addop wr ssa.begin ;

#ja #jb #tt
:flushj | tok -- ; end of the block with the jump
	'tt !
	epilogue
	13 ja jb 0 tt addop 14 0 0 0 adj addop 15 0 0 0 tt addop
	wr ssa.begin ;

|---------------------------------------------------------------
| THE TOKENS ( builds the tape ) : handler | -- f   1 = made
|---------------------------------------------------------------
#ctk			| the token that is being made
#wa #wb #wc #wd
#ao #bo #dv #tx

:tkv 8 >> $ffffffff and ;
:tks 24 << 32 >> ;

:ncst | n --
	0 swap cadd vpush ;
:lcst | v --
	1 swap cadd vpush ;

:s.no 0 ;
:s.l0 ctk 40 >>> src + str>anro nip ncst 1 ;
:s.l1 ctk tks ncst 1 ;
:s.l3 ctk tkv lcst 1 ;
:s.l6 ctk tkv $100000000 or lcst 1 ;
:s.l4 | value of a var
	newv 'dv ! 10 ctk tkv 1 swap cadd 0 dv 0 addop dv vpush 1 ;

|--- stack
:s.dup 0 vtop vpush 1 ;
:s.drop vpop drop 1 ;
:s.over 1 vtop vpush 1 ;
:s.pick2 2 vtop vpush 1 ;
:s.pick3 3 vtop vpush 1 ;
:s.pick4 4 vtop vpush 1 ;
:s.swap vpop vpop swap vpush vpush 1 ;
:s.nip vpop vpop drop vpush 1 ;
:s.rot vpop 'wc ! vpop 'wb ! vpop 'wa ! wb vpush wc vpush wa vpush 1 ;
:s.-rot vpop 'wc ! vpop 'wb ! vpop 'wa ! wc vpush wa vpush wb vpush 1 ;
:s.2dup 1 vtop vpush 1 vtop vpush 1 ;
:s.2drop vpop drop vpop drop 1 ;
:s.3drop vpop drop vpop drop vpop drop 1 ;
:s.4drop vpop drop vpop drop vpop drop vpop drop 1 ;
:s.2over 3 vtop vpush 3 vtop vpush 1 ;
:s.2swap vpop 'wd ! vpop 'wc ! vpop 'wb ! vpop 'wa ! wc vpush wd vpush wa vpush wb vpush 1 ;

|--- arithmetic
:binfold | -- f ; both numbers
	ao cnum? 0? ( ; ) drop
	bo cnum? ;

:islbl? | o -- f
	dup isc 0? ( nip ; ) drop ckind 1 =? ( drop 1 ; ) drop 0 ;
:fit24? | n -- f
	dup 40 << 40 >> - 0? ( drop 1 ; ) drop 0 ;
:calc | a b x -- r
	0 =? ( drop + ; ) 1 =? ( drop - ; ) 2 =? ( drop and ; ) 3 =? ( drop or ; ) 4 =? ( drop xor ; )
	drop * ;
:sh | a c x -- r
	0 =? ( drop << ; ) 1 =? ( drop >> ; ) drop >>> ;
:un1 | a x -- r
	0 =? ( drop not ; ) 1 =? ( drop neg ; ) drop abs ;
:foldbin | -- f ; the constants are made now
	ao cnum? bo cnum? and 1? ( drop ao cval bo cval tx calc ncst 1 ; ) drop
	tx 1 >? ( drop 0 ; ) drop
	ao islbl? bo cnum? and 1? ( drop
		bo cval tx 1 =? ( drop neg tx ) drop
		dup fit24? 1? ( drop 40 << ao cval + lcst 1 ; ) 2drop 0 ; ) drop
	tx 0 =? ( drop ao cnum? bo islbl? and 1? ( drop
		ao cval dup fit24? 1? ( drop 40 << bo cval + lcst 1 ; ) 2drop 0 ; ) drop 0 ; ) 
	drop 0 ;

:bin | x -- f
	'tx !
	vpop 'bo ! vpop 'ao !
	foldbin 1? ( ; ) drop
	newv 'dv ! 4 ao bo dv tx addop dv vpush 1 ;
:s.add 0 bin ;
:s.sub 1 bin ;
:s.and 2 bin ;
:s.or 3 bin ;
:s.xor 4 bin ;
:s.mul 5 bin ;

:shf | x -- f
	'tx !
	vpop 'bo ! vpop 'ao !
	ao cnum? bo cnum? and 1? ( drop
		ao cval bo cval 63 and tx sh ncst 1 ; ) drop
	newv 'dv ! 5 ao bo dv tx addop dv vpush 1 ;
:s.shl 0 shf ;
:s.sar 1 shf ;
:s.shr 2 shf ;

:un | x -- f
	'tx !
	vpop 'ao !
	ao cnum? 1? ( drop ao cval tx un1 ncst 1 ; ) drop
	newv 'dv ! 6 ao 0 dv tx addop dv vpush 1 ;
:s.not 0 un ;
:s.neg 1 un ;
:s.abs 2 un ;

|--- division and multiplication ( fixed registers : rax rdx rcx )
:s.div | -- f
	vpop 'bo ! vpop 'ao ! newv 'dv ! 16 ao bo dv 0 addop dv vpush 1 ;
:s.mod | -- f
	vpop 'bo ! vpop 'ao ! newv 'dv ! 17 ao bo dv 0 addop dv vpush 1 ;
#dq
:s.divmod | -- f
	vpop 'bo ! vpop 'ao ! newv 'dq ! newv 'dv !
	18 ao bo dq dv addop dq vpush dv vpush 1 ;
:s.muldiv | -- f ; a b c -- a*b/c
	vpop 'tx ! vpop 'bo ! vpop 'ao ! newv 'dv !
	19 ao bo dv tx addop dv vpush 1 ;
:s.shldiv | -- f ; a b c -- (a<<c)/b
	vpop 'tx ! vpop 'bo ! vpop 'ao ! newv 'dv !
	20 ao bo dv tx addop dv vpush 1 ;
:s.mulshr | -- f ; a b c -- (a*b)>>c  , c is a constant
	0 vtop cnum? 0? ( drop 0 ; ) drop
	vpop cval 'tx ! vpop 'bo ! vpop 'ao ! newv 'dv !
	21 ao bo dv tx addop dv vpush 1 ;

|--- memory
:load | size -- f
	'tx !
	vpop 'ao !
	newv 'dv ! 7 ao 0 dv tx addop dv vpush 1 ;
:s.fq 8 load ;
:s.fb 1 load ;
:s.fw 2 load ;
:s.fd 4 load ;

:store | op size -- f
	'tx ! 'dv !
	vpop 'ao ! vpop 'bo !
	dv ao bo 0 tx addop 1 ;
:s.st8 8 8 store ;
:s.st1 8 1 store ;
:s.st2 8 2 store ;
:s.st4 8 4 store ;
:s.ad8 9 8 store ;
:s.ad1 9 1 store ;
:s.ad2 9 2 store ;
:s.ad4 9 4 store ;

|--- @+ !+ : a load or a store and an add of the address
:ldi | size -- f
	'tx ! vpop 'ao !
	newv 'dv ! 7 ao 0 dv tx addop
	newv 'dq ! 4 ao 0 tx cadd dq 0 addop
	dq vpush dv vpush 1 ;
:s.fq+ 8 ldi ;
:s.fb+ 1 ldi ;
:s.fw+ 2 ldi ;
:s.fd+ 4 ldi ;

:sti | size -- f
	'tx ! vpop 'ao ! vpop 'bo !
	8 ao bo 0 tx addop
	newv 'dq ! 4 ao 0 tx cadd dq 0 addop
	dq vpush 1 ;
:s.st8+ 8 sti ;
:s.st1+ 1 sti ;
:s.st2+ 2 sti ;
:s.st4+ 4 sti ;

|--- the registers A ( r14 ) and B ( r15 ) : 24 AWRITE 25 AREAD 26 AADD 27 ALD 28 AST
:abk | -- k ; 0 >A 1 A> 2 A+ 3 A@ 4 A! 5 A@+ 6 A!+ 7 CA@ 8 CA! 9 CA@+ 10 CA!+ 11 DA@ 12 DA! 13 DA@+ 14 DA!+
	ctk $ff and 86 - 15 >=? ( 15 - ) ;
:abr | -- r
	ctk $ff and 101 <? ( drop 14 ; ) drop 15 ;
:abx | size inc -- x
	16 << swap 8 << or abr or ;

:s.ab | -- f
	ssra 0? ( ; ) drop
	abk
	0 =? ( drop vpop 'ao ! 24 ao 0 0 abr addop 1 ; )
	1 =? ( drop newv 'dv ! 25 0 0 dv abr addop dv vpush 1 ; )
	2 =? ( drop vpop 'ao ! 26 ao 0 0 abr addop 1 ; )
	3 =? ( drop 8 0 abx 'tx ! newv 'dv ! 27 0 0 dv tx addop dv vpush 1 ; )
	5 =? ( drop 8 1 abx 'tx ! newv 'dv ! 27 0 0 dv tx addop dv vpush 1 ; )
	7 =? ( drop 1 0 abx 'tx ! newv 'dv ! 27 0 0 dv tx addop dv vpush 1 ; )
	9 =? ( drop 1 1 abx 'tx ! newv 'dv ! 27 0 0 dv tx addop dv vpush 1 ; )
	11 =? ( drop 4 0 abx 'tx ! newv 'dv ! 27 0 0 dv tx addop dv vpush 1 ; )
	13 =? ( drop 4 1 abx 'tx ! newv 'dv ! 27 0 0 dv tx addop dv vpush 1 ; )
	4 =? ( drop 8 0 abx 'tx ! vpop 'ao ! 28 ao 0 0 tx addop 1 ; )
	6 =? ( drop 8 1 abx 'tx ! vpop 'ao ! 28 ao 0 0 tx addop 1 ; )
	8 =? ( drop 1 0 abx 'tx ! vpop 'ao ! 28 ao 0 0 tx addop 1 ; )
	10 =? ( drop 1 1 abx 'tx ! vpop 'ao ! 28 ao 0 0 tx addop 1 ; )
	12 =? ( drop 4 0 abx 'tx ! vpop 'ao ! 28 ao 0 0 tx addop 1 ; )
	14 =? ( drop 4 1 abx 'tx ! vpop 'ao ! 28 ao 0 0 tx addop 1 ; )
	drop 0 ;

|--- conditions : the block ends with the jump
:cond1 | -- f
	0 vtop 'ja ! 0 'jb !
	ctk $ff and flushj 1 ;
:cond2 | -- f
	vpop 'jb ! 0 vtop 'ja !
	ctk $ff and flushj 1 ;

#sw
's.l0 's.l1 's.no 's.l3 's.l4 's.l3 's.l6 's.no 's.no 's.no
's.no 's.no 's.no 'cond1 'cond1 'cond1 'cond1 'cond2 'cond2 'cond2
'cond2 'cond2 'cond2 'cond2 'cond2 's.no 's.dup 's.drop 's.over 's.pick2
's.pick3 's.pick4 's.swap 's.nip 's.rot 's.-rot 's.2dup 's.2drop 's.3drop 's.4drop
's.2over 's.2swap 's.no 's.no 's.no 's.and 's.or 's.xor 's.no 's.add
's.sub 's.mul 's.div 's.shl 's.sar 's.shr 's.mod 's.divmod 's.muldiv 's.mulshr
's.shldiv 's.not 's.neg 's.abs 's.no 's.no 's.fq 's.fb 's.fw 's.fd
's.fq+ 's.fb+ 's.fw+ 's.fd+ 's.st8 's.st1 's.st2 's.st4 's.st8+ 's.st1+
's.st2+ 's.st4+ 's.ad8 's.ad1 's.ad2 's.ad4 's.ab 's.ab 's.ab 's.ab
's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.ab
's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.ab
's.ab 's.ab 's.ab 's.ab 's.ab 's.ab 's.no 's.no 's.no 's.no
's.no 's.no 's.no 's.no 's.no 's.no 's.no 's.no 's.no 's.no
's.no 's.no 's.no 's.no 's.no 's.no 's.no 's.no 's.no 's.no
's.no

::ssa.tok | tok -- f ; 1 = the token is in the block
	no 800 >? ( ssa.flush ) drop
	nc 400 >? ( ssa.flush ) drop
	vn 200 >? ( ssa.flush ) drop
	dup 'ctk !
	$ff and 3 << 'sw + @ ex ;

|--- boundaries with cells in registers
::ssa.promote | k --
	'bcn !
	bcn 0? ( drop 0 'rsvm ! ssa.begin ; ) drop
	1 bcn << 1- 4 << 'rsvm !
	ssa.begin ;

::ssa.ok? | type -- f ; the token can be inside a loop with cells in registers
	ssra 0? ( nip ; ) drop
	8 =? ( drop 1 ; ) 9 =? ( drop 1 ; )
	3 << 'sw + @ 's.no =? ( drop 0 ; ) drop 1 ;

::ssa.,reg | r --
	,reg ;
::ssa.,off | n --
	,off ;
