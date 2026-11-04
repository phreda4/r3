| r3opt1 - optimizing emission layer for r3comp
| PHREDA 2026
|---------------------------------------------------------------
| STAGE 1: stack pointer folding + peephole
|
| the code of each base word is written for a canonical stack ( [rbp] = NOS,
| rax = TOS ) and moves rbp every time. This layer keeps the movements of rbp
| as a pending displacement (rbd) and fixes the offsets of the next [rbp+k]:
|
|   DROP DUP    mov rax,[rbp] sub rbp,8 add rbp,8 mov [rbp],rax
|               ->  mov rax,[rbp] , mov [rbp],rax (removed, the same value)
|   2DROP DROP  one single  sub rbp,24  (when it is needed)
|
| rbp is made real (canonical) before: call word, ret, jmp, jcc, labels
| ( before jcc with lea, the flags must live )
| calls to the system ( call rax , acall , cinvoke64 ) do not touch rbp
|
| 1 line of text for each instruction, see ##optlevel
|---------------------------------------------------------------
^r3/lib/mem.r3
^r3/lib/str.r3
^r3/lib/parse.r3

##optlevel 2		| 0 = text as it is , 1 = rbp folding + peephole , 2 = virtual stack
##nins 0			| instructions received
##nout 0			| instructions written

#rbd 0				| pending displacement: real rbp + rbd = logical rbp
#hld 0				| 1 if there is an instruction on hold
#held * 256			| instruction on hold ( last one, to look for pairs )
#ibuf * 256			| rewritten instruction
#tmp * 256
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
:holdout | --
	hld 0? ( drop ; ) drop
	'held emit1 0 'hld ! ;

:flushadd | --
	holdout rbd 0? ( drop ; )
	+? ( o.tab "add rbp," ,s ,d o.nl 0 'rbd ! ; )
	neg o.tab "sub rbp," ,s ,d o.nl 0 'rbd ! ;

:flushlea | --
	holdout rbd 0? ( drop ; )
	+? ( o.tab "lea rbp,[rbp+" ,s ,d "]" ,s o.nl 0 'rbd ! ; )
	neg o.tab "lea rbp,[rbp-" ,s ,d "]" ,s o.nl 0 'rbd ! ;

|---------------------------------------------------------------
| peephole: pair held + new
|   mov rax,[X] , mov [X],rax   ->  the second is not needed
|   mov [X],rax , mov rax,[X]   ->  the second is not needed
:held? | "start" -- f
	'held swap =pre nip ;

:r1 | t -- t f
	'tmp >b "mov " bput 'held 8 + bput ",rax" bput 0 cb!+
	dup 'tmp cmpstr 0? ( drop 1 ; ) drop 0 ;

:r2 | t -- t f
	'held ",rax" =pos nip 0? ( ; ) drop
	'tmp >b "mov rax," bput 'held 4 + bput -4 b+ 0 cb!
	dup 'tmp cmpstr 0? ( drop 1 ; ) drop 0 ;

:redundant? | t -- t f
	hld 0? ( ; ) drop
	"mov rax,[" held? 1? ( drop r1 ; ) drop
	"mov [" held? 1? ( drop r2 ; ) drop
	0 ;

:hold | t --
	redundant? 1? ( 2drop ; ) drop
	holdout
	'held >b bput 0 cb!+
	1 'hld ! ;

|---------------------------------------------------------------
| 0 normal  1 canonical rbp  2 canonical rbp (jcc, keep the flags)
:bound | t -- t k
	"call w" =pre 1? ( drop 1 ; ) drop
	"call rcx" =pre 1? ( drop 1 ; ) drop
	"ret" =pre 1? ( drop 1 ; ) drop
	"jmp " =pre 1? ( drop 1 ; ) drop
	":" =pos 1? ( drop 1 ; ) drop
	dup c@ $6a =? ( drop 2 ; ) drop
	0 ;

:ins2 | t k --
	1 =? ( drop flushadd emit1 ; )
	2 =? ( drop flushlea emit1 ; )
	drop hold ;

|---------------------------------------------------------------
::opt.ins | "instr" --
	1 'nins +!
	optlevel 0? ( drop emit1 ; ) drop
	"add rbp," =pre 1? ( drop 8 + parsemul 'rbd +! ; ) drop
	"sub rbp," =pre 1? ( drop 8 + parsemul neg 'rbd +! ; ) drop
	rewrite bound ins2 ;

::opt.label | "label:" --
	optlevel 0? ( drop emitl ; ) drop
	flushadd emitl ;

::opt.reset | --
	0 'rbd ! 0 'hld ! 0 'nins ! 0 'nout ! ;

::opt.end | --
	flushadd ;
