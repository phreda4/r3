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
#rbusy 0		| registers that alloc must not use ( bit r )

:regfree? | r -- f
	dup rcc 1? ( 2drop 0 ; ) drop
	1 swap << rbusy and 0? ( drop 1 ; ) drop 0 ;

:alloc | -- r
	0 ( 12 <?
		dup 'pool + c@ regfree? 1? ( drop 'pool + c@ dup rci ; ) drop
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

:,lbl | v --			| value = offset<<34 | class<<32 | index
	dup 32 >>> $3 and 'lpre nth ,s
	dup $ffffffff and ,h
	34 >> ,off ;

:lbl+ | v n -- v'		| label + constant, the offset goes in the cell
	34 << + ;

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

:lblc? | -- f ; a is a label and b a small constant: w+k, no code
	ak 3 <>? ( drop 0 ; ) drop
	bk 2 <>? ( drop 0 ; ) drop
	bv abs $fffffff >? ( drop 0 ; ) drop 1 ;

:v.add
	setab cte2? 1? ( drop av bv + vcte 1 ; ) drop
	comm lblc? 1? ( drop 3 av bv lbl+ vpush 1 ; ) drop
	"add" bin 1 ;
:v.sub
	setab cte2? 1? ( drop av bv - vcte 1 ; ) drop
	lblc? 1? ( drop 3 av bv neg lbl+ vpush 1 ; ) drop
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
| DESCRIPTORS  ( where the data are, how to resolve them )
|---------------------------------------------------------------
| "rows" = row ^ row ^ ...          the first row that fits is used
| row    = inputs | clobbers | outputs | template
|
| inputs ( from the deepest to the top, #0 is the top, #1 the next ... )
|   R  register, exclusive, changed by the code ( can be the output R )
|   r  register        H  register or memory     G  register, memory or imm32
|   V  register or imm32                          M  register, label or imm32
|   N  count: rcx or constant ( $i is  cl  or the number )
|   K  constant ( K{lo,hi} only if lo<=value<=hi )
|   A C D S I  the value must be in rax rcx rdx rsi rdi
| clobbers   a c d s i : registers that the code destroys
| outputs    A C D : result in that register    R : the register of the R input
|            n : a new register ( %0 %1 .. )     - : none
| template   instructions separated by ;  and
|   #i  operand ( #iB #iW #iD  low byte/word/dword )   $i constant or cl ( $i-64 $i&63 )
|   %k  register of the output k
|
| ~ at the start of the row : commutative ( the constant to the right )
|---------------------------------------------------------------
#ik * 64	| input cells ( 0 = top )
#iv * 64
#ni 0
#tcl * 16	| class of each input ( deepest first )
#tlo * 128
#thi * 128
#rp #pc #rclob #rout #rtpl #rcomm
#cur #tx #ty #ti #tc #tkk #tvv #ci #pii #pi #nw #tp #no #po
#evx #evy #evi #evm #evc #tx2 #ecnt #tt
#orr * 64
#ol * 64

:ik@ 3 << 'ik + @ ;
:iv@ 3 << 'iv + @ ;
:iset | k v i --
	3 << >a a> 'iv + ! a> 'ik + ! ;

:cls | i -- c
	ni 1- swap - 'tcl + c@ ;
:clo | i -- v
	ni 1- swap - 3 << 'tlo + @ ;
:chi | i -- v
	ni 1- swap - 3 << 'thi + @ ;

|--- parse a row
:pbrace | -- ; pc is at {
	1 'pc +! pc str>nro swap 'pc !
	dup ni 3 << 'tlo + ! ni 3 << 'thi + !
	pc c@ $2c <>? ( drop 1 'pc +! ; ) drop
	1 'pc +!
	pc c@ $7d =? ( drop 99999999 ni 3 << 'thi + ! 1 'pc +! ; ) drop
	pc str>nro swap 'pc ! ni 3 << 'thi + !
	1 'pc +! ;

:pcl1 | -- ; one class
	pc c@ ni 'tcl + c!
	-99999999 ni 3 << 'tlo + !
	99999999 ni 3 << 'thi + !
	1 'pc +!
	pc c@ $7b =? ( pbrace ) drop
	1 'ni +! ;

:skipbar | --
	( pc c@ 1? $7c =? ( drop 1 'pc +! ; ) drop 1 'pc +! ) drop ;

:parse.row | --
	rp 'pc ! 0 'rcomm ! 0 'ni !
	pc c@ $7e =? ( 1 'rcomm ! 1 'pc +! ) drop
	( pc c@ 1? $7c <>? drop pcl1 ) drop
	1 'pc +! pc 'rclob ! skipbar
	pc 'rout ! skipbar
	pc 'rtpl ! ;

:nextrow | --
	rtpl ( c@+ 1? $5e =? ( drop 'rp ! ; ) drop ) drop 1- 'rp ! ;

|--- the row fits ?
:guard? | i -- f
	dup ik@ 2 <>? ( 2drop 0 ; ) drop
	dup iv@ 'tvv !
	dup clo tvv >? ( 2drop 0 ; ) drop
	chi tvv <? ( drop 0 ; ) drop 1 ;

:rowok? | -- f
	0 ( ni <?
		dup cls $4b =? ( over guard? 0? ( 3drop 0 ; ) drop ) drop
		1+ ) drop 1 ;

|--- classes -> registers
:ltr | c -- r
	$df and
	$41 =? ( drop 0 ; ) $43 =? ( drop 1 ; ) $44 =? ( drop 2 ; )
	$53 =? ( drop 4 ; ) $49 =? ( drop 5 ; ) drop -1 ;

:maskadd | r --
	-? ( drop ; ) 1 swap << rbusy or 'rbusy ! ;

:fieldmask | p --
	( c@+ 1? $7c =? ( 2drop ; ) ltr maskadd ) 2drop ;

:mkmask | --
	0 'rbusy !
	0 ( ni <?
		dup cls ltr maskadd
		dup cls $4e =? ( over ik@ 2 <>? ( 1 maskadd ) drop ) drop
		1+ ) drop
	rclob fieldmask rout fieldmask ;

:inx? | i X -- f
	'tx ! dup ik@ 0 <>? ( 2drop 0 ; ) drop iv@ tx eq? ;

|--- move holders of a register to another one
:isr? | k v -- f
	swap 0 <>? ( 2drop 0 ; ) drop evx eq? ;

:patchV | --
	0 ( vn <?
		dup kv@ isr? 1? ( 0 evy pick3 kv! 1 'evc +! ) drop
		1+ ) drop ;

:okpatch? | i -- f
	evm 2 =? ( 2drop 1 ; ) 1 =? ( drop evi eq? 0? ( drop 1 ; ) drop 0 ; ) 2drop 0 ;

:patchI | --
	0 ( ni <? dup 'pii !
		pii okpatch? 1? ( pii ik@ pii iv@ isr? 1? ( 0 evy pii iset 1 'evc +! ) drop ) drop
		1+ ) drop ;

:phantom | -- ; the entry cell 0 ( rax ) becomes a cell
	ve 0? ( nextent insb ) drop ;

:inin | X -- n ; input cells that are in the register X
	'tx2 ! 0 'ecnt !
	0 ( ni <? dup 'pii !
		pii ik@ 0 =? ( pii iv@ tx2 eq? ecnt + 'ecnt ! ) drop
		1+ ) drop ecnt ;

:evict | X mode exi --
	'evi ! 'evm ! 'evx !
	evx rcc 0? ( drop ; ) drop
	evm 0? ( evx rcc evx inin - 1 <? ( 2drop ; ) drop ) drop
	evx 0? ( phantom ) drop
	alloc 'evy !
	ib "mov " ,s evy ,reg "," ,s evx ,reg ie opt.ins
	0 'evc !
	patchV patchI
	evc evy 3 << 'rc + !
	evx rcc evc - evx 3 << 'rc + ! ;

:toreg | i X --
	'tx ! 'ti !
	ti tx inx? 1? ( drop tx 1 ti evict ; ) drop
	tx 2 -1 evict
	ib "mov " ,s tx ,reg "," ,s ti ik@ ti iv@ ,opn ie opt.ins
	ti ik@ ti iv@ cdec
	0 tx ti iset tx rci ;

:ownin | i --
	'ti !
	ti ik@ ti iv@ own 'tx !
	0 tx ti iset ;

:awayfrom | i --
	'ti !
	ti ik@ 0 <>? ( drop ; ) drop
	1 ti iv@ << rbusy and 0? ( drop ; ) drop
	ti iv@ 'tx ! alloc 'ty !
	ib "mov " ,s ty ,reg "," ,s tx ,reg ie opt.ins
	tx rcd 0 ty ti iset ;

:okcls? | i c -- f
	'tc ! dup ik@ 'tkk ! iv@ 'tvv !
	tkk 2 eq? tvv imm32? and 'ci !
	tc $72 =? ( drop tkk 0 eq? ; )
	$48 =? ( drop tkk 0 eq? tkk 1 eq? or ; )
	$47 =? ( drop tkk 0 eq? tkk 1 eq? or ci or ; )
	$56 =? ( drop tkk 0 eq? ci or ; )
	$4d =? ( drop tkk 0 eq? tkk 3 eq? or ci or ; )
	drop 1 ;

:mkcls | i c --
	$52 =? ( drop ownin ; )
	over swap okcls? 0? ( drop ownin ; ) 2drop ;

:isother? | c -- f
	$52 =? ( drop 1 ; ) $72 =? ( drop 1 ; ) $48 =? ( drop 1 ; ) $47 =? ( drop 1 ; )
	$56 =? ( drop 1 ; ) $4d =? ( drop 1 ; ) drop 0 ;

:stepspec | --
	cur cls ltr 'ty !
	ty 0 >=? ( cur ty toreg ) drop
	cur cls $4e =? ( cur ik@ 2 <>? ( cur 1 toreg ) drop ) drop ;

:stepother | --
	cur cls 'tc !
	tc isother? 1? ( drop cur tc mkcls cur awayfrom ; ) drop ;

:evictfield | p --
	( c@+ 1? $7c =? ( 2drop ; ) ltr +? ( dup 0 -1 evict ) drop ) 2drop ;

:rreg | -- r
	0 ( ni <? dup cls $52 =? ( drop iv@ ; ) drop 1+ ) drop 0 ;

:out1 | c --
	$2d =? ( drop ; )
	dup no 3 << 'ol + !
	$6e =? ( drop alloc no 3 << 'orr + ! 1 'no +! ; )
	$52 =? ( drop rreg no 3 << 'orr + ! 1 'no +! ; )
	ltr no 3 << 'orr + ! 1 'no +! ;

:mkouts | --
	0 'no ! rout 'po !
	( po c@ 1? $7c =? ( drop ; ) out1 1 'po +! ) drop ;

|--- template
:,narrow | i w --
	'nw ! 'ti !
	ti ik@ 0 =? ( drop ti iv@ nw ,regw ; )
	drop ti iv@ nw immw ,d ;

:ph# | --
	tp c@ $30 - 'pi ! 1 'tp +!
	tp c@ $42 =? ( drop 1 'tp +! pi 1 ,narrow ; )
	$57 =? ( drop 1 'tp +! pi 2 ,narrow ; )
	$44 =? ( drop 1 'tp +! pi 4 ,narrow ; )
	drop pi ik@ pi iv@ ,opn ;

:skipn | --
	tp str>nro drop 'tp ! ;
:skipsfx | --
	tp c@ $26 =? ( drop 1 'tp +! skipn ; )
	$2b =? ( drop skipn ; ) $2d =? ( drop skipn ; ) drop ;

:ph$ | --
	tp c@ $30 - 'pi ! 1 'tp +!
	pi ik@ 0 =? ( drop "cl" ,s skipsfx ; ) drop
	pi iv@
	tp c@ $2d =? ( drop tp str>nro swap 'tp ! + ,d ; )
	$2b =? ( drop tp str>nro swap 'tp ! + ,d ; )
	$26 =? ( drop 1 'tp +! tp str>nro swap 'tp ! and ,d ; )
	drop ,d ;

:ph% | --
	tp c@ $30 - 'pi ! 1 'tp +!
	pi 3 << 'orr + @ ,reg ;

:tpl1 | -- f
	tp c@ 0? ( ; ) $5e =? ( drop 0 ; )
	1 'tp +!
	$3b =? ( drop ie opt.ins ib 1 ; )
	$23 =? ( drop ph# 1 ; )
	$24 =? ( drop ph$ 1 ; )
	$25 =? ( drop ph% 1 ; )
	,c 1 ;

:tpl | --
	rtpl c@ 0? ( drop ; ) $5e =? ( drop ; ) drop
	rtpl 'tp ! ib
	( tpl1 1? drop ) drop
	ie opt.ins ;

|--- release the inputs, push the outputs
:rel1 | i --
	dup cls $52 =? ( 2drop ; ) drop
	dup ik@ swap iv@ cdec ;

:pushout | k --
	dup 3 << 'ol + @ swap 3 << 'orr + @
	swap $6e =? ( drop 0 swap vpush ; )
	$52 =? ( drop 0 swap vpush ; )
	drop dup rci 0 swap vpush ;

:finish | --
	0 ( ni <? dup rel1 1+ ) drop
	0 ( no <? dup pushout 1+ ) drop ;

:apply | --
	mkmask
	0 ( ni <? dup 'cur ! stepspec 1+ ) drop
	0 ( ni <? dup 'cur ! stepother 1+ ) drop
	rclob evictfield rout evictfield
	mkouts tpl finish
	0 'rbusy ! ;

:popin | --
	0 ( ni <? vpop pick2 iset 1+ ) drop ;

:pushback | --
	ni ( 1? 1- dup ik@ over iv@ vpush ) drop ;

:swapin | -- ; the constant to the top
	1 ik@ 2 <>? ( drop ; ) drop
	0 ik@ 2 =? ( drop ; ) drop
	0 'pii ! pii ik@ 'tkk ! pii iv@ 'tvv !
	1 'pi !
	pi ik@ pi iv@ pii iset
	tkk tvv pi iset ;

::vop | "rows" -- f
	'rp ! parse.row
	popin
	rcomm 1? ( swapin ) drop
	( rp c@ 1?
		drop parse.row rowok? 1? ( drop apply 1 ; ) drop
		nextrow ) drop
	pushback 0 ;

|---------------------------------------------------------------
| CALL OF A WORD AT RUNTIME, IN?
|---------------------------------------------------------------
:ins1 | "text" --
	ib ,s ie opt.ins ;

:v.ex | -- f
	vpop 'bv ! 'bk !
	bk 3 =? ( drop vs.norm ib "call " ,s bv ,lbl ie opt.ins 1 ; ) drop
	b2reg
	bv 0? ( alloc 'st ! st bv mov.rr bv rcd st 'bv ! ) drop
	vs.norm
	ib "mov rcx," ,s bv ,reg ie opt.ins
	"test rcx,rcx" ins1 "jz @f" ins1 "call rcx" ins1 "@@:" ins1 1 ;

:v.in | -- f
	vpop 'cv ! 'ck ! vpop 'bv ! 'bk !
	0 vtop 'av ! 'ak !
	prepb
	alloc 'tt !
	ib "mov " ,s tt ,reg "," ,s ak av ,opn ie opt.ins
	ib "sub " ,s tt ,reg "," ,s bk bv ,opn ie opt.ins
	ck cv own 'ra !
	ib "sub " ,s ra ,reg "," ,s bk bv ,opn ie opt.ins
	ib "cmp " ,s tt ,reg "," ,s ra ,reg ie opt.ins
	tt rcd ra rcd bk bv cdec
	"ja" 'lmn ! vjump ;

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
#vh * 2048	| handler ( word ) for each base word
#vd * 2048	| descriptor ( rows ) for each base word

:sethv | 'word "NAME" --
	0 ( dup basename c@ 1? drop
		dup basename pick2 =s 1? ( drop nip 3 << 'vh + ! ; ) drop
		1+ ) 4drop ;

:sethd | "rows" "NAME" --
	0 ( dup basename c@ 1? drop
		dup basename pick2 =s 1? ( drop nip 3 << 'vd + ! ; ) drop
		1+ ) 4drop ;

::vs.handled? | i -- f ; the base word i has handler or descriptor
	dup 3 << 'vh + @ swap 3 << 'vd + @ or 1? ( drop 1 ; ) drop 0 ;

::vs.init | --
	'vh 0 256 fill 'vd 0 256 fill
	'v.dup "DUP" sethv 'v.drop "DROP" sethv 'v.over "OVER" sethv
	'v.pick2 "PICK2" sethv 'v.pick3 "PICK3" sethv 'v.pick4 "PICK4" sethv
	'v.swap "SWAP" sethv 'v.nip "NIP" sethv 'v.rot "ROT" sethv 'v.-rot "-ROT" sethv
	'v.2dup "2DUP" sethv 'v.2drop "2DROP" sethv 'v.3drop "3DROP" sethv 'v.4drop "4DROP" sethv
	'v.2over "2OVER" sethv 'v.2swap "2SWAP" sethv
	'v.add "+" sethv 'v.sub "-" sethv 'v.mul "*" sethv
	'v.and "AND" sethv 'v.or "OR" sethv 'v.xor "XOR" sethv 'v.nand "NAND" sethv
	'v.not "NOT" sethv 'v.neg "NEG" sethv 'v.abs "ABS" sethv
	'v.fq "@" sethv 'v.fb "C@" sethv 'v.fw "W@" sethv 'v.fd "D@" sethv
	'v.st8 "!" sethv 'v.st1 "C!" sethv 'v.st2 "W!" sethv 'v.st4 "D!" sethv
	'v.ad8 "+!" sethv 'v.ad1 "C+!" sethv 'v.ad2 "W+!" sethv 'v.ad4 "D+!" sethv
	'v.fp8 "@+" sethv 'v.fp1 "C@+" sethv 'v.fp2 "W@+" sethv 'v.fp4 "D@+" sethv
	'v.lt "<?" sethv 'v.gt ">?" sethv 'v.eq "=?" sethv 'v.ge ">=?" sethv 'v.le "<=?" sethv 'v.ne "<>?" sethv
	'v.andq "AND?" sethv 'v.nandq "NAND?" sethv
	'v.z "0?" sethv 'v.nz "1?" sethv 'v.pos "+?" sethv 'v.negq "-?" sethv
	'v.sp8 "!+" sethv 'v.sp1 "C!+" sethv 'v.sp2 "W!+" sethv 'v.sp4 "D!+" sethv
	'v.ex "EX" sethv 'v.in "IN?" sethv
	"AH|d|A|cqo;idiv #0" "/" sethd
	"AH|d|D|cqo;idiv #0" "MOD" sethd
	"AH|d|AD|cqo;idiv #0" "/MOD" sethd
	"AHH|d|A|imul #1;idiv #0" "*/" sethd
	"AHK{0}|d|A|imul #1^AHK{1,63}|d|A|imul #1;shrd rax,rdx,$0^AHK{64,}|d|A|imul #1;sar rdx,$0-64;mov rax,rdx^AHN|d|A|imul #1;shrd rax,rdx,$0;sar rdx,$0;and ecx,64;cmovne rax,rdx" "*>>" sethd
	"AHN|d|A|cqo;shld rdx,rax,$0;shl rax,$0;idiv #1" "<</" sethd
	"R||R|cvtsi2sd xmm0,#0;sqrtsd xmm0,xmm0;cvttsd2si #0,xmm0" "SQRT" sethd
	"R||R|bsr #0,#0;xor #0,63" "CLZ" sethd
	"RK{0}||R|^RK||R|shl #1,$0&63^RN||R|shl #1,$0" "<<" sethd
	"RK{0}||R|^RK||R|sar #1,$0&63^RN||R|sar #1,$0" ">>" sethd
	"RK{0}||R|^RK||R|shr #1,$0&63^RN||R|shr #1,$0" ">>>" sethd
	"G|-|-|push #0" ">R" sethd
	"|-|n|pop %0" "R>" sethd
	"|-|n|mov %0,[rsp]" "R@" sethd
	"|-|n|mov %0,[FREE_MEM]" "MEM" sethd
	"|-|-|push r14;push r15" "AB[" sethd
	"|-|-|pop r15;pop r14" "]BA" sethd
	"ISC|-|-|rep movsq" "MOVE" sethd
	"ISC|-|-|lea rsi,[rsi+rcx*8-8];lea rdi,[rdi+rcx*8-8];std;rep movsq;cld" "MOVE>" sethd
	"ISC|-|-|rep movsb" "CMOVE" sethd
	"ISC|-|-|lea rsi,[rsi+rcx-1];lea rdi,[rdi+rcx-1];std;rep movsb;cld" "CMOVE>" sethd
	"ISC|-|-|rep movsd" "DMOVE" sethd
	"ISC|-|-|lea rsi,[rsi+rcx*4-4];lea rdi,[rdi+rcx*4-4];std;rep movsd;cld" "DMOVE>" sethd
	"IAC|-|-|rep stosq" "FILL" sethd
	"IAC|-|-|rep stosb" "CFILL" sethd
	"IAC|-|-|rep stosd" "DFILL" sethd
	"G|-|-|mov r14,#0" ">A" sethd
	"|-|n|mov %0,r14" "A>" sethd
	"G|-|-|add r14,#0" "A+" sethd
	"|-|n|mov %0,qword[r14]" "A@" sethd
	"V|-|-|mov qword[r14],#0" "A!" sethd
	"|-|n|mov %0,qword[r14];add r14,8" "A@+" sethd
	"V|-|-|mov qword[r14],#0;add r14,8" "A!+" sethd
	"|-|n|movsx %0,byte[r14]" "CA@" sethd
	"V|-|-|mov byte[r14],#0B" "CA!" sethd
	"|-|n|movsx %0,byte[r14];add r14,1" "CA@+" sethd
	"V|-|-|mov byte[r14],#0B;add r14,1" "CA!+" sethd
	"|-|n|movsxd %0,dword[r14]" "DA@" sethd
	"V|-|-|mov dword[r14],#0D" "DA!" sethd
	"|-|n|movsxd %0,dword[r14];add r14,4" "DA@+" sethd
	"V|-|-|mov dword[r14],#0D;add r14,4" "DA!+" sethd
	"G|-|-|mov r15,#0" ">B" sethd
	"|-|n|mov %0,r15" "B>" sethd
	"G|-|-|add r15,#0" "B+" sethd
	"|-|n|mov %0,qword[r15]" "B@" sethd
	"V|-|-|mov qword[r15],#0" "B!" sethd
	"|-|n|mov %0,qword[r15];add r15,8" "B@+" sethd
	"V|-|-|mov qword[r15],#0;add r15,8" "B!+" sethd
	"|-|n|movsx %0,byte[r15]" "CB@" sethd
	"V|-|-|mov byte[r15],#0B" "CB!" sethd
	"|-|n|movsx %0,byte[r15];add r15,1" "CB@+" sethd
	"V|-|-|mov byte[r15],#0B;add r15,1" "CB!+" sethd
	"|-|n|movsxd %0,dword[r15]" "DB@" sethd
	"V|-|-|mov dword[r15],#0D" "DB!" sethd
	"|-|n|movsxd %0,dword[r15];add r15,4" "DB@+" sethd
	"V|-|-|mov dword[r15],#0D;add r15,4" "DB!+" sethd ;

|---------------------------------------------------------------
| ENTRY: the token is made with the virtual stack ( 1 ) or not ( 0 )
|---------------------------------------------------------------
::vs.tok | tok -- f
	vn 8 >? ( vs.norm ) drop
	dup $ff and
	8 =? ( 2drop 1 ; )
	9 =? ( drop vtkv 0? ( drop 1 ; ) drop 0 ; )
	6 >? ( 7 - dup 3 << 'vh + @ 0? ( drop 3 << 'vd + @ 0? ( nip ; ) nip vop ; ) nip nip ex ; )
	3 << 'vt + @ 0? ( nip ; ) ex 1 ;
