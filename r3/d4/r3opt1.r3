| r3opt1 - emission layer for r3comp
| PHREDA 2026
|---------------------------------------------------------------
| stack pointer folding
|
| the code of each base word is written for a canonical stack ( [rbp] = NOS,
| rax = TOS ) and moves rbp every time. This layer keeps the movements of rbp
| as a pending displacement (rbd) and fixes the offsets of the next [rbp+k]:
|
|   sub rbp,8 , add rbp,16 , mov rax,[rbp]   ->  mov rax,[rbp+8] , and later  add rbp,8
|   2DROP DROP  one single  sub rbp,24  (when it is needed)
|
| rbp is made real (canonical) before: call word, ret, jmp, jcc, labels
| ( before jcc with lea, the flags must live )
| calls to the system ( call rax , acall , cinvoke64 ) do not touch rbp
|
| 1 line of text for each instruction
|
| peephole window ( the lines are written when the next one is known ):
|   call wN , ret                 ->  jmp wN                  tail call
|   call rcx , @@: , ret          ->  jmp rcx , @@: , ret     tail EX ( 0 goes to the ret )
|   jcc A , jmp B , A:            ->  jncc B , A:
|   after jmp / ret until the next label: dead code, not written
|---------------------------------------------------------------
^r3/lib/mem.r3
^r3/lib/str.r3
^r3/lib/parse.r3

##nins 0			| instructions received
##nout 0			| instructions written

#rbd 0				| pending displacement: real rbp + rbd = logical rbp
#ibuf * 256			| rewritten instruction
#lbuf * 256			| text of the instruction in construction
#hsv				| here saved

|---------------------------------------------------------------
| build an instruction with the usual words ( ,s ,d ,h ,c ) :
|   ib  "mov rax," ,s 5 ,d  ie opt.ins
::ib | -- ; the next text goes to lbuf
	here 'hsv ! 'lbuf 'here ! ;
::ie | -- "text" ; end of the text, back to the output
	0 ,c hsv 'here ! 'lbuf ;

|---------------------------------------------------------------
| output
:o.tab 9 ,c ;
:o.nl 10 ,c ;

:emit1 | "instr" --
	1 'nout +! o.tab ,s o.nl ;

:emitl | "label" --
	,s o.nl ;

|---------------------------------------------------------------
| text helpers ( B = destination )
:bput | str --
	( c@+ 1? cb!+ ) 2drop ;

:bnum | n --
	.d bput ;

| offset  [rbp+8] [rbp-1*8] [rbp+8*2] [rbp]
:pk | adr -- adr' k
	str>nro over c@ $2a =? ( drop swap 1+ str>nro rot * ; ) drop ;

:rdk | -- k
	a> c@ $5d =? ( drop 0 ; ) drop
	a> pk swap >a ;

:rbn | k --
	0? ( drop ; )
	+? ( $2b cb!+ ) bnum ;

:rbk | -- ; A is after "rbp"
	rdk rbd + "[rbp" bput rbn $5d cb!+ 1 a+ ;

:lbr | -- ; A is after "["
	a> "rbp" =pre 1? ( 2drop 3 a+ rbk ; ) 2drop $5b cb!+ ;

:rwc | ch --
	$5b =? ( drop lbr ; )
	cb!+ ;

:rewrite | s -- 'ibuf ; fix all the [rbp+k] with the displacement
	>a 'ibuf >b
	( ca@+ 1? rwc ) drop
	0 cb!+ 'ibuf ;

|---------------------------------------------------------------
| 8 , 8*3
:parsemul | adr -- n
	str>nro swap dup c@ $2a =? ( drop 1+ str>nro nip * ; ) 2drop ;

|---------------------------------------------------------------
| pending displacement
:flushadd | --
	rbd 0? ( drop ; )
	+? ( o.tab "add rbp," ,s ,d o.nl 0 'rbd ! ; )
	neg o.tab "sub rbp," ,s ,d o.nl 0 'rbd ! ;

:flushlea | --
	rbd 0? ( drop ; )
	+? ( o.tab "lea rbp,[rbp+" ,s ,d "]" ,s o.nl 0 'rbd ! ; )
	neg o.tab "lea rbp,[rbp-" ,s ,d "]" ,s o.nl 0 'rbd ! ;

|---------------------------------------------------------------
| PEEPHOLE : pending lines
|   pk  0 none  1 call wN  2 jcc  3 jcc,jmp  4 call rcx  5 call rcx,@@:
|   rbp must be canonical ( rbd = 0 ) to join the lines
|---------------------------------------------------------------
#pend * 256		| first pending line
#pend2 * 256	| second pending line
#pk 0
#dead 0			| 1 = unreachable code ( after jmp / ret ) until the next label
#tmpl * 256

:pflush | -- ; the pending lines go to the output as they are
	pk 0? ( drop ; )
	'pend emit1
	3 =? ( 'pend2 emit1 ) 5 =? ( 'pend2 emit1 ) drop
	0 'pk ! ;

:emitjmp | -- ; the pending call becomes jmp
	o.tab "jmp " ,s 'pend 5 + ,s o.nl
	1 'nout +! 0 'pk ! ;

| jcc -> inverse jcc
#jlist "jz" "jnz" "jnz" "jz" "jge" "jl" "jl" "jge" "jg" "jle" "jle" "jg"
"je" "jne" "jne" "je" "js" "jns" "jns" "js" "ja" "jbe" ( 0 )

:jinv | "jcc ..." -- "jncc"/0
	'jlist ( dup c@ 1?
		drop over over =s 1? ( drop nip >>0 ; ) drop
		>>0 >>0 )
	3drop 0 ;

:tgt1 'pend 32 findchar 1+ ;		| target of the pending jcc
:tgt2 'pend2 4 + ;					| target of the pending jmp

:labmatch | "label:" "target" -- f
	swap 'tmpl strcpy
	'tmpl count + 1- 0 swap c!
	'tmpl swap =s ;

:cclose | "label:" -- ; the label comes after  jcc A , jmp B
	'pend jinv 0? ( drop pflush flushadd emitl ; )
	over tgt1 labmatch 0? ( 2drop pflush flushadd emitl ; ) drop
	o.tab ,s " " ,s tgt2 ,s o.nl
	1 'nout +! 0 'pk !
	emitl ;

|--- each kind of instruction
:i.ret | t --
	pk 1 =? ( rbd 0? ( 3drop emitjmp 1 'dead ! ; ) drop ) drop
	pk 5 =? ( rbd 0? ( 2drop emitjmp 'pend2 emit1 emit1 1 'dead ! ; ) drop ) drop
	pflush flushadd emit1 1 'dead ! ;

:i.call | t --
	pflush flushadd 'pend strcpy 1 'pk ! ;

:i.callx | t --
	pflush flushadd 'pend strcpy 4 'pk ! ;

:i.jcc | t -- ; flags must live, lea
	pflush flushlea 'pend strcpy 2 'pk ! ;

:i.jmpl | t -- ; jmp to a local label
	pk 2 =? ( rbd 0? ( 2drop 'pend2 strcpy 3 'pk ! 1 'dead ! ; ) drop ) drop
	pflush flushadd emit1 1 'dead ! ;

:i.jmp | t --
	pflush flushadd emit1 1 'dead ! ;

:i.lab | t -- ; label of the code ( @@: )
	pk 4 =? ( drop 'pend2 strcpy 5 'pk ! ; ) drop
	pflush flushadd emit1 ;

:dispatch | t --
	"ret" =pre 1? ( drop i.ret ; ) drop
	"call w" =pre 1? ( drop i.call ; ) drop
	"call rcx" =pre 1? ( drop i.callx ; ) drop
	"jmp l" =pre 1? ( drop i.jmpl ; ) drop
	"jmp " =pre 1? ( drop i.jmp ; ) drop
	":" =pos 1? ( drop i.lab ; ) drop
	dup c@ $6a =? ( drop i.jcc ; ) drop
	pflush emit1 ;

|---------------------------------------------------------------
::opt.ins | "instr" --
	1 'nins +!
	dead 1? ( 2drop ; ) drop
	"add rbp," =pre 1? ( drop 8 + parsemul 'rbd +! ; ) drop
	"sub rbp," =pre 1? ( drop 8 + parsemul neg 'rbd +! ; ) drop
	rewrite dispatch ;

::opt.label | "label:" --
	0 'dead !
	pk 3 =? ( drop cclose ; ) drop
	pflush flushadd emitl ;

::opt.reset | --
	0 'rbd ! 0 'nins ! 0 'nout ! 0 'pk ! 0 'dead ! ;

::opt.end | --
	pflush flushadd ;

::opt.flush | -- ; writes the pending lines ( before a comment )
	pflush flushadd ;
