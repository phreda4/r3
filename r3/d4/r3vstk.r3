| r3vstk - virtual stack for r3comp
| PHREDA 2026
|---------------------------------------------------------------
| The stack of the program is kept at compile time as a list of cells
| and the code is made only when the value is needed.
|
| each cell is   kind , value
|   REG  r        the value is in the register r  ( rc[r] = cells that use r )
|   ENT  j        the value is in memory, entry cell j ( [rbp-8*(j-1)] )
|   CTE  n        constant
|   LBL  c<<32|i  address of a word/var (w), a string (s) or a local label (l)
|
| entry cells: E0 = rax , E1 = [rbp] , E2 = [rbp-8] ... of the state where
| the virtual stack was started.   ve = entry cells used , vn = cells in V
|
| canonical state:  .. [rbp+8] [rbp] rax   ( vs.norm )
| it is the state of the calls, the labels and the words without virtual code
|
| generic part : cells, shuffles, normalization
| x64 part     : registers, operands, the code of each word
|---------------------------------------------------------------
^r3/lib/mem.r3
^r3/lib/str.r3
^r3/d4/r3token.r3
^r3/d4/r3opt1.r3

|---------------------------------------------------------------
| CELLS
|---------------------------------------------------------------
#vk * 256			| kind
#vv * 256			| value
#vn 0				| cells in V
#ve 0				| entry cells used
#rc * 96			| cells that use each register

:eq? | a b -- f
	- 0? ( drop 1 ; ) drop 0 ;

:kv@ | i -- k v
	3 << dup 'vk + @ swap 'vv + @ ;

:kv! | k v i --
	3 << >a a> 'vv + ! a> 'vk + ! ;

:vpush | k v --
	vn kv! 1 'vn +! ;

|--- registers
:rci | r --
	3 << 'rc + 1 swap +! ;
:rcd | r --
	3 << 'rc + -1 swap +! ;
:rcc | r -- n
	3 << 'rc + @ ;

#pool ( 3 4 5 6 7 8 9 10 11 1 2 0 )

:alloc | -- r
	0 ( 12 <?
		dup 'pool + c@ rcc 0? ( drop 'pool + c@ dup rci ; ) drop
		1+ ) drop
	"; ERROR: no free register" opt.ins 3 ;

|--- cells that use registers
:cinc | k v --
	swap 0? ( drop rci ; ) 2drop ;
:cdec | k v --
	swap 0? ( drop rcd ; ) 2drop ;

|--- entry cells
:nextent | -- k v
	ve 0? ( drop 1 've ! 0 0 ; )
	1 've +! 1 swap ;

:shup | --
	vn ( 1? dup 1- kv@ pick2 kv! 1- ) drop ;

:insb | k v --
	shup 0 kv! 1 'vn +! ;

:need | n --
	( vn >=? nextent insb ) drop ;

:vpop | -- k v
	0 need vn 1- dup kv@ rot 'vn ! ;

:vtop | d -- k v
	dup need vn 1- swap - kv@ ;

|---------------------------------------------------------------
| X64 : names and operands
|---------------------------------------------------------------
#rq "rax" "rcx" "rdx" "rbx" "rsi" "rdi" "r8" "r9" "r10" "r11" "r12" "r13"
#rd "eax" "ecx" "edx" "ebx" "esi" "edi" "r8d" "r9d" "r10d" "r11d" "r12d" "r13d"
#rw "ax" "cx" "dx" "bx" "si" "di" "r8w" "r9w" "r10w" "r11w" "r12w" "r13w"
#rb "al" "cl" "dl" "bl" "sil" "dil" "r8b" "r9b" "r10b" "r11b" "r12b" "r13b"
#lpre "w" "s" "l"

:nth | n 'list -- str
	swap ( 1? 1- swap >>0 swap ) drop ;

:,reg | r --
	'rq nth ,s ;

:,regw | r w --
	8 =? ( drop ,reg ; )
	4 =? ( drop 'rd nth ,s ; )
	2 =? ( drop 'rw nth ,s ; )
	drop 'rb nth ,s ;

:,off | n --
	0? ( drop ; )
	+? ( $2b ,c ) ,d ;

:,ent | j --
	"qword[rbp" ,s 1 swap - 3 << ,off "]" ,s ;

:,cte | v --
	dup 32 << 32 >> <>? ( "$" ,s ,h ; ) ,d ;

:,lbl | v --
	dup 32 >>> 'lpre nth ,s $ffffffff and ,h ;

:,opn | k v --
	swap 0? ( drop ,reg ; )
	1 =? ( drop ,ent ; )
	2 =? ( drop ,cte ; )
	drop ,lbl ;

:imm32? | v -- f
	dup 32 << 32 >> eq? ;

:mov.rr | dst src --
	ib "mov " ,s swap ,reg "," ,s ,reg ie opt.ins ;

|---------------------------------------------------------------
| NORMALIZATION  ( canonical state )
|---------------------------------------------------------------
##jt 0		| label of the jump of the condition ( set by the caller )
#nn #ne
#si #sk #sv #st #tk #tv

:nreset | --
	0 'vn ! 0 've !
	'rc 0 12 fill
	1 'rc ! ;

:slot | idx -- ; text of the final place in memory
	"qword[rbp" ,s ne - 2 + 3 << ,off "]" ,s ;

| the cell is in the final place of the canonical stack
:inplace? | idx -- f
	dup nn 1- =? ( 2drop 0 ; ) drop
	dup kv@ swap 1 <>? ( 3drop 0 ; ) drop
	swap ne swap - 1 - eq? ;

:ent2reg | idx --
	dup kv@ swap 1 <>? ( 3drop ; ) drop
	alloc
	ib "mov " ,s dup ,reg "," ,s over ,ent ie opt.ins
	swap drop 0 swap rot kv! ;

:loadents | --
	0 ( nn <?
		dup inplace? 0? ( over ent2reg ) drop
		1+ ) drop ;

:store.tmp | --
	alloc 'st !
	ib "mov " ,s st ,reg "," ,s sk sv ,opn ie opt.ins
	ib "mov " ,s si slot "," ,s st ,reg ie opt.ins
	st rcd ;

:store1 | idx --
	dup 'si ! kv@ 'sv ! 'sk !
	sk 0 =? ( drop ib "mov " ,s si slot "," ,s sv ,reg ie opt.ins ; )
	2 =? ( drop sv imm32? 1? ( drop ib "mov " ,s si slot "," ,s sv ,cte ie opt.ins ; ) drop store.tmp ; )
	drop store.tmp ;

:spill0 | --
	ne 0? ( ib "mov qword[rbp+8],rax" ,s ie opt.ins ) drop ;

:storecells | --
	spill0
	0 ( nn 1- <?
		dup inplace? 0? ( over store1 ) drop
		1+ ) drop ;

:tophome | --
	nn 1- kv@ 'tv ! 'tk !
	tk 0? ( tv 0? ( 2drop ; ) drop ) drop
	ib "mov rax," ,s tk tv ,opn ie opt.ins ;

:adjrbp | --
	nn ne - 3 << 0? ( drop ; )
	+? ( ib "add rbp," ,s ,d ie opt.ins ; )
	neg ib "sub rbp," ,s ,d ie opt.ins ;

:normn | --
	vn 'nn ! ve 'ne !
	loadents storecells tophome adjrbp nreset ;

:norm0 | -- ; no cells, entry cells used
	ib "mov rax," ,s ve ,ent ie opt.ins
	ib "sub rbp," ,s ve 3 << ,d ie opt.ins
	nreset ;

::vs.norm | --
	optlevel 2 <? ( drop ; ) drop
	vn 0? ( drop ve 0? ( drop ; ) drop norm0 ; ) drop
	normn ;

::vs.reset | --
	nreset ;

|---------------------------------------------------------------
| SHUFFLES  ( no code )
|---------------------------------------------------------------
#ak #av #bk #bv #ck #cv #dk #dv #ra #dd #dr #sw #lmn #lsz

:v.dup 0 need 0 vtop 2dup cinc vpush 1 ;
:v.over 1 need 1 vtop 2dup cinc vpush 1 ;
:v.pick2 2 need 2 vtop 2dup cinc vpush 1 ;
:v.pick3 3 need 3 vtop 2dup cinc vpush 1 ;
:v.pick4 4 need 4 vtop 2dup cinc vpush 1 ;
:v.drop vpop cdec 1 ;
:v.nip
	vpop 'bv ! 'bk ! vpop cdec bk bv vpush 1 ;
:v.swap
	vpop 'bv ! 'bk ! vpop 'av ! 'ak !
	bk bv vpush ak av vpush 1 ;
:v.rot | a b c -- b c a
	vpop 'cv ! 'ck ! vpop 'bv ! 'bk ! vpop 'av ! 'ak !
	bk bv vpush ck cv vpush ak av vpush 1 ;
:v.-rot | a b c -- c a b
	vpop 'cv ! 'ck ! vpop 'bv ! 'bk ! vpop 'av ! 'ak !
	ck cv vpush ak av vpush bk bv vpush 1 ;
:v.2dup
	1 need 1 vtop 2dup cinc vpush 1 vtop 2dup cinc vpush 1 ;
:v.2drop
	vpop cdec vpop cdec 1 ;
:v.3drop
	vpop cdec vpop cdec vpop cdec 1 ;
:v.4drop
	vpop cdec vpop cdec vpop cdec vpop cdec 1 ;
:v.2over
	3 need 3 vtop 2dup cinc vpush 3 vtop 2dup cinc vpush 1 ;
:v.2swap | a b c d -- c d a b
	vpop 'dv ! 'dk ! vpop 'cv ! 'ck ! vpop 'bv ! 'bk ! vpop 'av ! 'ak !
	ck cv vpush dk dv vpush ak av vpush bk bv vpush 1 ;

|---------------------------------------------------------------
| OWN : value in a register that nobody else uses
|---------------------------------------------------------------
:own.reg | r -- r
	dup rcc 1 =? ( drop ; ) drop
	alloc dup pick2 mov.rr swap rcd ;

:own.mem | k v -- r
	alloc 'st !
	ib "mov " ,s st ,reg "," ,s ,opn ie opt.ins
	st ;

:own | k v -- r
	swap 0? ( drop own.reg ; ) swap own.mem ;

|---------------------------------------------------------------
| ARITHMETIC
|---------------------------------------------------------------
:setab | -- ; b = TOS , a = NOS
	vpop 'bv ! 'bk ! vpop 'av ! 'ak ! ;

:vcte | n --
	2 swap vpush ;

:cte2? | -- f
	ak 2 =? ( drop bk 2 =? ( drop 1 ; ) drop 0 ; ) drop 0 ;

:comm | -- ; the constant to the right
	ak 2 <>? ( drop ; ) drop
	bk 2 =? ( drop ; ) drop
	ak bk 'ak ! 'bk !
	av bv 'av ! 'bv ! ;

:b2reg | -- ; b in a register
	bk bv own 0 'bk ! 'bv ! ;

:prepb | -- ; b can be an operand ( register , memory , imm32 )
	bk 2 =? ( drop bv imm32? 1? ( drop ; ) drop b2reg ; )
	3 =? ( drop b2reg ; ) drop ;

:bin | "mn" --
	ak av own 'ra !
	prepb
	ib ,s " " ,s ra ,reg "," ,s bk bv ,opn ie opt.ins
	bk bv cdec
	0 ra vpush ;

:v.add
	setab cte2? 1? ( drop av bv + vcte 1 ; ) drop
	comm "add" bin 1 ;
:v.sub
	setab cte2? 1? ( drop av bv - vcte 1 ; ) drop
	"sub" bin 1 ;
:v.mul
	setab cte2? 1? ( drop av bv * vcte 1 ; ) drop
	comm "imul" bin 1 ;
:v.and
	setab cte2? 1? ( drop av bv and vcte 1 ; ) drop
	comm "and" bin 1 ;
:v.or
	setab cte2? 1? ( drop av bv or vcte 1 ; ) drop
	comm "or" bin 1 ;
:v.xor
	setab cte2? 1? ( drop av bv xor vcte 1 ; ) drop
	comm "xor" bin 1 ;
:v.nand
	setab cte2? 1? ( drop av bv not and vcte 1 ; ) drop
	b2reg ib "not " ,s bv ,reg ie opt.ins
	"and" bin 1 ;

:v.not
	vpop 'bv ! 'bk !
	bk 2 =? ( drop bv not vcte 1 ; ) drop
	b2reg ib "not " ,s bv ,reg ie opt.ins
	0 bv vpush 1 ;
:v.neg
	vpop 'bv ! 'bk !
	bk 2 =? ( drop bv neg vcte 1 ; ) drop
	b2reg ib "neg " ,s bv ,reg ie opt.ins
	0 bv vpush 1 ;
:v.abs
	vpop 'bv ! 'bk !
	bk 2 =? ( drop bv abs vcte 1 ; ) drop
	b2reg alloc 'st !
	ib "mov " ,s st ,reg "," ,s bv ,reg ie opt.ins
	ib "sar " ,s st ,reg ",63" ,s ie opt.ins
	ib "add " ,s bv ,reg "," ,s st ,reg ie opt.ins
	ib "xor " ,s bv ,reg "," ,s st ,reg ie opt.ins
	st rcd
	0 bv vpush 1 ;

| shift by a constant
:v.sh | "mn" -- f
	0 vtop swap 2 <>? ( 3drop 0 ; ) 2drop
	setab
	ak av own 'ra !
	ib ,s " " ,s ra ,reg "," ,s bv $3f and ,d ie opt.ins
	0 ra vpush 1 ;
:v.shl "shl" v.sh ;
:v.sar "sar" v.sh ;
:v.shr "shr" v.sh ;

|---------------------------------------------------------------
| CONDITIONS  ( compare the cells and jump, a stays in the stack )
|---------------------------------------------------------------
:a2reg | -- ; the top cell goes to a register ( it stays in the stack )
	ak 0 =? ( drop ; ) drop
	ak av own 'ra !
	0 ra vn 1- kv!
	0 'ak ! ra 'av ! ;

:cmpset | -- ; a and b ready for  cmp/test a,b
	prepb
	ak 1 =? ( drop bk 1 =? ( drop a2reg ; ) drop ; )
	0 =? ( drop ; )
	drop a2reg ;

:vjump | -- f ; canonical state, then jump when the condition fails
	vs.norm
	ib lmn ,s " l" ,s jt ,h ie opt.ins 1 ;

:vcond2 | "cmp" "jcc" -- f
	'lmn ! 'lsz !
	vpop 'bv ! 'bk !
	0 vtop 'av ! 'ak !
	cmpset
	ib lsz ,s " " ,s ak av ,opn "," ,s bk bv ,opn ie opt.ins
	bk bv cdec
	vjump ;

:vcond1 | "jcc" -- f
	'lmn !
	0 vtop 'av ! 'ak !
	ak 1 =? ( drop ib "cmp " ,s ak av ,opn ",0" ,s ie opt.ins vjump ; )
	0 <>? ( a2reg ) drop
	ib "test " ,s av ,reg "," ,s av ,reg ie opt.ins
	vjump ;

:v.lt "cmp" "jge" vcond2 ;
:v.gt "cmp" "jle" vcond2 ;
:v.eq "cmp" "jne" vcond2 ;
:v.ge "cmp" "jl" vcond2 ;
:v.le "cmp" "jg" vcond2 ;
:v.ne "cmp" "je" vcond2 ;
:v.andq "test" "jz" vcond2 ;
:v.nandq "test" "jnz" vcond2 ;
:v.z "jnz" vcond1 ;
:v.nz "jz" vcond1 ;
:v.pos "js" vcond1 ;
:v.negq "jns" vcond1 ;

|---------------------------------------------------------------
| MEMORY
|---------------------------------------------------------------
:addrok | -- f ; a can be an address operand
	ak 0 =? ( drop 1 ; ) 3 =? ( drop 1 ; ) 2 =? ( drop av imm32? ; ) drop 0 ;

:prepaddr | --
	addrok 0? ( drop ak av own 0 'ak ! 'av ! ; ) drop ;

:,addr | k v --
	"[" ,s ,opn "]" ,s ;

:vload | "mn" "sz" -- f
	'lsz ! 'lmn !
	vpop 'av ! 'ak !
	prepaddr
	0 'dr !
	ak 0? ( av rcc 1 =? ( 1 'dr ! ) drop ) drop
	dr 0? ( alloc 'dd ! ) drop
	dr 1? ( av 'dd ! ) drop
	ib lmn ,s " " ,s dd ,reg "," ,s lsz ,s ak av ,addr ie opt.ins
	dr 0? ( ak av cdec ) drop
	0 dd vpush 1 ;

:v.fq "mov" "qword" vload ;
:v.fb "movsx" "byte" vload ;
:v.fw "movsx" "word" vload ;
:v.fd "movsxd" "dword" vload ;

:szn | w -- str
	8 =? ( drop "qword" ; ) 4 =? ( drop "dword" ; ) 2 =? ( drop "word" ; ) drop "byte" ;

:immw | v w -- v'
	8 =? ( drop ; ) 4 =? ( drop $ffffffff and ; ) 2 =? ( drop $ffff and ; ) drop $ff and ;

:prepsrc | -- ; b can be the source of a store
	bk 2 =? ( drop sw 8 <>? ( drop ; ) drop bv imm32? 1? ( drop ; ) drop b2reg ; )
	0 =? ( drop ; )
	drop b2reg ;

:,srcw | --
	bk 2 =? ( drop bv sw immw ,d ; ) drop bv sw ,regw ;

:vstore | "mn" w -- f
	'sw ! 'lmn !
	vpop 'av ! 'ak ! vpop 'bv ! 'bk !
	prepaddr prepsrc
	ib lmn ,s " " ,s sw szn ,s ak av ,addr "," ,s ,srcw ie opt.ins
	ak av cdec bk bv cdec 1 ;

:v.st8 "mov" 8 vstore ;
:v.st4 "mov" 4 vstore ;
:v.st2 "mov" 2 vstore ;
:v.st1 "mov" 1 vstore ;
:v.ad8 "add" 8 vstore ;
:v.ad4 "add" 4 vstore ;
:v.ad2 "add" 2 vstore ;
:v.ad1 "add" 1 vstore ;

| fetch and increment   a -- a+n [a]
:vloadp | "mn" "sz" n -- f
	'sw ! 'lsz ! 'lmn !
	vpop 'av ! 'ak !
	ak av own 'ra !
	alloc 'dd !
	ib lmn ,s " " ,s dd ,reg "," ,s lsz ,s "[" ,s ra ,reg "]" ,s ie opt.ins
	ib "add " ,s ra ,reg "," ,s sw ,d ie opt.ins
	0 ra vpush 0 dd vpush 1 ;

:v.fp8 "mov" "qword" 8 vloadp ;
:v.fp1 "movsx" "byte" 1 vloadp ;
:v.fp2 "movsx" "word" 2 vloadp ;
:v.fp4 "movsxd" "dword" 4 vloadp ;

| store and increment   v a -- a+n
:vstorep | w -- f
	'sw !
	vpop 'av ! 'ak ! vpop 'bv ! 'bk !
	ak av own 'ra ! 0 'ak ! ra 'av !
	prepsrc
	ib "mov " ,s sw szn ,s "[" ,s ra ,reg "]" ,s "," ,s ,srcw ie opt.ins
	bk bv cdec
	ib "add " ,s ra ,reg "," ,s sw ,d ie opt.ins
	0 ra vpush 1 ;

:v.sp8 8 vstorep ;
:v.sp1 1 vstorep ;
:v.sp2 2 vstorep ;
:v.sp4 4 vstorep ;

|---------------------------------------------------------------
| LITERALS AND ADDRESSES
|---------------------------------------------------------------
:vtkv 8 >> $ffffffff and ;
:vtks 24 << 32 >> ;

:vt0 40 >>> src + str>anro nip vcte ;
:vt1 vtks vcte ;
:vt3 vtkv 3 swap vpush ;
:vt4 vtkv 'bv ! alloc 'st !
	ib "mov " ,s st ,reg ",qword[w" ,s bv ,h "]" ,s ie opt.ins
	0 st vpush ;
:vt6 vtkv $100000000 or 3 swap vpush ;

#vt 'vt0 'vt1 0 'vt3 'vt4 'vt3 'vt6

|---------------------------------------------------------------
| TABLE OF THE BASE WORDS
|---------------------------------------------------------------
#vh * 2048

:sethv | 'word "NAME" --
	0 ( dup basename c@ 1? drop
		dup basename pick2 =s 1? ( drop nip 3 << 'vh + ! ; ) drop
		1+ ) 4drop ;

::vs.init | --
	'vh 0 256 fill
	'v.dup "DUP" sethv 'v.drop "DROP" sethv 'v.over "OVER" sethv
	'v.pick2 "PICK2" sethv 'v.pick3 "PICK3" sethv 'v.pick4 "PICK4" sethv
	'v.swap "SWAP" sethv 'v.nip "NIP" sethv 'v.rot "ROT" sethv 'v.-rot "-ROT" sethv
	'v.2dup "2DUP" sethv 'v.2drop "2DROP" sethv 'v.3drop "3DROP" sethv 'v.4drop "4DROP" sethv
	'v.2over "2OVER" sethv 'v.2swap "2SWAP" sethv
	'v.add "+" sethv 'v.sub "-" sethv 'v.mul "*" sethv
	'v.and "AND" sethv 'v.or "OR" sethv 'v.xor "XOR" sethv 'v.nand "NAND" sethv
	'v.not "NOT" sethv 'v.neg "NEG" sethv 'v.abs "ABS" sethv
	'v.shl "<<" sethv 'v.sar ">>" sethv 'v.shr ">>>" sethv
	'v.fq "@" sethv 'v.fb "C@" sethv 'v.fw "W@" sethv 'v.fd "D@" sethv
	'v.st8 "!" sethv 'v.st1 "C!" sethv 'v.st2 "W!" sethv 'v.st4 "D!" sethv
	'v.ad8 "+!" sethv 'v.ad1 "C+!" sethv 'v.ad2 "W+!" sethv 'v.ad4 "D+!" sethv
	'v.fp8 "@+" sethv 'v.fp1 "C@+" sethv 'v.fp2 "W@+" sethv 'v.fp4 "D@+" sethv
	'v.lt "<?" sethv 'v.gt ">?" sethv 'v.eq "=?" sethv 'v.ge ">=?" sethv 'v.le "<=?" sethv 'v.ne "<>?" sethv
	'v.andq "AND?" sethv 'v.nandq "NAND?" sethv
	'v.z "0?" sethv 'v.nz "1?" sethv 'v.pos "+?" sethv 'v.negq "-?" sethv
	'v.sp8 "!+" sethv 'v.sp1 "C!+" sethv 'v.sp2 "W!+" sethv 'v.sp4 "D!+" sethv ;

|---------------------------------------------------------------
| ENTRY: the token is made with the virtual stack ( 1 ) or not ( 0 )
|---------------------------------------------------------------
::vs.tok | tok -- f
	optlevel 2 <? ( 2drop 0 ; ) drop
	vn 8 >? ( vs.norm ) drop
	dup $ff and
	8 =? ( 2drop 1 ; )
	9 =? ( drop vtkv 0? ( drop 1 ; ) drop 0 ; )
	6 >? ( 7 - 3 << 'vh + @ 0? ( nip ; ) nip ex ; )
	3 << 'vt + @ 0? ( nip ; ) ex 1 ;
