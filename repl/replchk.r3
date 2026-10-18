| replchk - pre-check of the program generated for a line (mem/repl.r3)
| tokenizes the file inside the REPL process (r3token) before r3 is launched:
|  - compile error: message and exact file/line, without running anything
|  - word not found: the library is looked up (wfind), included and the check repeated
|  - stack: the line surely needs more values than the stack holds (straight-line start only)
|  - memory: words of the line and project words that write memory
| chk-run  -- code    0 ok | 1 compile error | 2 stack underflow | 3 boot word in the project    (ckmsg ckfile ckline)
| r3token must be included before replcore (replcore redefines tok)
^repl/replgen.r3

##ckmsg * 160
##ckfile * 128
##ckline 0

|--- memory writers (filled by chk-run)
##mwmb * 160 ##mwmb> 0		| words of the line that write memory
##mwflag 0
#mwmn 0 #mwie 0 #cktmp * 64 #cktmp2 * 64

#mwrw "!" "c!" "w!" "d!" "!+" "c!+" "w!+" "d!+" "+!" "c+!" "w+!" "d+!"
"a!" "a!+" "ca!" "ca!+" "da!" "da!+" "b!" "b!+" "cb!" "cb!+" "db!" "db!+"
"move" "move>" "fill" "cmove" "cmove>" "cfill" "dmove" "dmove>" "dfill" ( 0 )

::mw.in? | str ini end -- 0/1
	'mwie !
	( mwie <?
		over over =s 1? ( 3drop 1 ; ) drop
		>>0 ) 2drop 0 ;

|--- tables
#ckinfo * 8192		| by word number: 2 = project word that writes memory
#ckwtab * 256		| by token: 1 = base word that writes memory
#ckready 0
#cknmain 0

:ckinit | -- ; base writers by token number
	ckready 1? ( drop ; ) drop
	'mwrw ( dup c@ 1?  drop
		dup ?base 1? ( dup 6 + 'ckwtab + 1 swap c! ) drop
		>>0 ) 2drop
	1 'ckready ! ;

|--- lowercase copy / names
:lowcpy | str dst --
	( swap c@+ $ff and 1? tolow rot c!+ ) 2drop 0 swap c! ;

:ckadd | str -- ; culprit of the line (no repeats, at most 6)
	1 'mwflag !
	mwmn 6 >=? ( 2drop ; ) drop
	'cktmp swap copynom
	'cktmp 'mwmb mwmb> mw.in? 1? ( drop ; ) drop
	mwmb> 'mwmb - 120 >=? ( drop ; ) drop
	'cktmp mwmb> strcpyl 'mwmb> ! 1 'mwmn +! ;

|--- definitions: memory writers (one forward pass)
#ckcw 0

:cktok | tok -- ; ckcw = 1 if the token writes memory
	dup $ff and
	2 =? ( drop 8 >> $ffffffff and
		8192 >=? ( drop ; )
		'ckinfo + c@ 2 and? ( 1 'ckcw ! ) drop ; )
	dup 'ckwtab + c@ 1? ( 1 'ckcw ! ) drop
	2drop ;

:ckdef | n -- ; project words that write memory (their callees are always before)
	8192 >=? ( drop ; )
	cknmain <? ( drop ; )
	dup r3isdata 1? ( 2drop ; ) drop
	dup r3isboot 1? ( 2drop ; ) drop
	0 'ckcw !
	dup nro>dic toklend ( 1? 1- swap @+ cktok swap ) 2drop
	ckcw 0? ( 2drop ; ) drop
	2 swap 'ckinfo + c! ;

|--- the line: the stack with the analyzer of r3token (resetinfo / tokeninfo / wwinfo, as r3ide does)
#ckstop 0 #ckres 0 #ckus 0 #ckue 0 #cktk 0

:cknm | tok -- str ; name of a word or base word, for the messages
	dup $ff and
	2 =? ( drop 8 >> $ffffffff and r3name ; )
	7 >=? ( nip 7 - basename 'cktmp lowcpy 'cktmp ; )
	2drop "?" ;

:ckunder | tok --
	cknm sn wwinfo 8 >> $ff and
	"the line needs %d values, only %d on the stack (at %w)" sprint 'ckmsg strcpy
	2 'ckres ! 1 'ckstop ! ;

:ckrisky? | tok -- 0/1 ; control token, or a word whose effect is not fixed (several ; / R unbalanced / recursive / no ;)
	dup $ff and
	2 =? ( drop 8 >> $ffffffff and nro>dic @ $b8 and? ( drop 1 ; ) drop 0 ; )
	7 12 in? ( 2drop 1 ; )
	2drop 0 ;


:ckculp | tok -- ; does the token write memory?
	dup $ff and
	2 =? ( drop 8 >> $ffffffff and
		8192 >=? ( drop ; )
		dup 'ckinfo + c@ 2 and 0? ( 2drop ; ) drop
		nro>dic @ dic>name ckadd ; )
	dup 'ckwtab + c@ 0? ( 3drop ; ) drop
	nip 7 - basename 'cktmp2 lowcpy 'cktmp2 ckadd ;

:cknl | adr -- adr' ; start of the next line (the text only has 13)
	( c@+ 1? 13 =? ( drop ; ) drop ) drop 1- ;

:cklstart | line -- adr
	src swap ( 1 >? 1- swap cknl swap ) drop ;

:ckutok | tok --
	dup 40 >>> src + ckus <? ( 2drop ; ) ckue >=? ( 2drop ; ) drop
	dup ckculp
	ckstop 1? ( 2drop ; ) drop
	dup ckrisky? 1? ( 2drop 1 'ckstop ! ; ) drop
	dup 'cktk ! tokeninfo				| the analyzer needs the next token address under the token (as in r3ide)
	wwinfo 8 >> $ff and sn >? ( drop cktk ckunder ; ) drop ;

:ckuser | --
	0 'ckres ! 0 'ckstop !
	gk 0 <>? ( drop ; ) drop
	boot>> -? ( drop ; ) drop
	gyour cklstart dup 'ckus ! cknl 'ckue !
	resetinfo
	boot>> nro>dic toklend
	( 1? 1- swap @+ ckutok swap ) 2drop ;

::ckwriters | -- ; marks the project words that write memory (call it with the tokens loaded)
	ckinit
	dic< dic - 4 >> 'cknmain !
	0 ( 1024 <? 0 over 3 << 'ckinfo + ! 1+ ) drop
	0 ( cntdef <? dup ckdef 1+ ) drop ;

::ckwrites? | n -- 0/1
	8192 >=? ( drop 0 ; ) 'ckinfo + c@ 2 and 1 >> ;

::ckboot1? | n -- 0/1 ; a boot word that is not the final boot of the REPL
	dup r3isboot 0? ( 2drop 0 ; ) drop
	boot>> <>? ( drop 1 ; ) drop 0 ;

:ckbootin | -- 0/1
	cknmain ( cntdef <? dup ckboot1? 1? ( 2drop 1 ; ) drop 1+ ) drop 0 ;

:chk-user | -- code ; 0 ok, 2 stack, 3 a boot word typed in the project
	'mwmb 'mwmb> ! 0 'mwmn ! 0 'mwflag ! 0 'ckline !
	ckwriters
	ckbootin 1? ( drop "boot words (: ...) are edited with /edit" 'ckmsg strcpy 3 ; ) drop
	ckuser
	ckres ;

|--- compile error: message, file and line (before the memory is freed)
#ckeo 0 #ckbo 0 #cklc 0 #ckunk 0 #ckni 0 #ckn 0
#ckword * 64

::cklines | a b -- n
	0 'cklc ! swap ( over <? c@+ 13 =? ( 1 'cklc +! ) drop ) 2drop cklc 1+ ;

:ckinc | entry -- ; the file whose text contains the error
	dup 8 + @ $ffffffff and
	dup ckeo >? ( 2drop ; )
	ckbo <=? ( 2drop ; )
	'ckbo !
	@ 'ckfile swap copynom ;

:ckstart | -- adr ; start of the unknown word (lerror points after its first char)
	lerror 1- dup c@ $ff and 33 <? ( swap drop lerror swap ) drop
	dup c@ $ff and $27 =? ( swap 1+ swap ) drop ;

::ckerr | --
	error 'ckmsg strcpy
	0 'ckline ! 0 'ckunk ! 0 'ckword c!
	error "word not found" = error "addr not exist" = or 'ckunk !
	lerror 0? ( drop ; ) drop
	lerror src - 'ckeo !
	0 'ckbo ! "mem/repl.r3" 'ckfile strcpy
	'inc ( inc> <? dup ckinc 16 + ) drop
	src ckbo + lerror cklines 'ckline !
	ckunk 1? ( drop
		ckstart 'ckword swap copynom
		'ckword 'ckmsg "%s: %s" sprint 'ckmsg strcpy ; ) drop ;

:ckfix | -- 0/1 ; word not found in the session: its library is included
	ckunk 0? ( ; ) drop
	ckn 8 >=? ( drop 0 ; ) drop
	1 'ckn +!
	'ckword wfind 2 <>? ( drop 0 ; ) drop
	ninc 'ckni !
	cl "^%s" sprint inc+
	ninc ckni - 1? ( drop 1 ; ) drop 0 ;

:ckpass | -- code
	ckinit
	"mem/repl.r3" r3tok
	error 1? ( drop ckerr r3free 1 ; ) drop
	chk-user r3free ;

:ckloop | -- code
	ckpass
	1 <>? ( ; )
	ckfix 0? ( drop ; ) 2drop
	ga gk gen-src
	ckloop ;

::chk-run | -- code ; ga/gk = the line already generated with gen-src
	0 'ckn !
	ckloop ;

|--- /trace: the program regenerated from the tokens, with a .tr before every ; of the project words
| the generated text keeps the line of every token of mem/repl.r3 (errors and gyour keep their meaning)
##trace 0
##trnm * 24576		| names of the project words (24 bytes each), by word number - first project word
##trbuf * 32016		| mem/repl.trc as it was read
#ckol 0 #ckcur 0 #ckanon 0

::trname | n -- str
	1024 >=? ( drop "?" ; ) 24 * 'trnm + ;

:cktrn | n -- ; saves the name of the word n
	dup cknmain -
	1024 >=? ( 2drop ; )
	24 * 'trnm +
	swap nro>dic @ dic>name 'cktmp swap copynom
	0 'cktmp 23 + c!
	'cktmp swap strcpy ;

:ckpad | line -- ; blank lines until the output is on that line
	( ckol over <? drop 13 ,c 1 'ckol +! ) 2drop ;

:ckptr | tok -- tok line
	dup 40 >>> src + src swap cklines ;

:ckp | tok -- ; token and space
	,tokgen ,sp ;

:ckgcall | tok -- ; word call: the boot calls of the libraries are not written (their includes chain them)
	dup 8 >> $ffffffff and
	cknmain <? ( dup r3isboot 1? ( 3drop ; ) drop )
	drop ckp ;

:ckgsemi | tok -- ; ; of a project word (not in an anonymous one): the stack is recorded first
	ckanon 1? ( drop ckp ; ) drop
	ckcur boot>> =? ( drop ckp ; ) drop
	ckcur cknmain - "%d .tr " ,print
	ckp ;

:ckgtok | tok --
	ckptr ckpad
	dup $ff and
	2 =? ( drop ckgcall ; )
	7 =? ( drop ckgsemi ; )
	10 =? ( 1 'ckanon +! )
	11 =? ( -1 'ckanon +! )
	drop ckp ;

:ckgdef | n --
	dup 'ckcur ! dup cktrn
	dup r3name src swap cklines ckpad
	dup nro>dic @ ,r3pre
	dup boot>> <>? ( dup ,wname ) drop ,sp
	nro>dic toklend
	( 1? 1- swap @+ ckgtok swap ) 2drop ;

:ckgen | -- ; mem/repl.r3 from the tokens
	dic< dic - 4 >> 'cknmain !
	0 'ckanon !
	cknmain r3name src swap cklines dup 'ckol !
	cklstart
	mark
	src ( over <? c@+ $ff and ,c ) 2drop
	cknmain ( cntdef <? dup ckgdef 1+ ) drop
	13 ,c
	"mem/repl.r3" savemem empty ;

:ckload | -- 0/1 ; tokenizes mem/repl.r3 (1 = ok) ; r3free frees it
	"mem/repl.r3" r3tok
	error 1? ( drop r3free 0 ; ) drop 1 ;

::chk-trace | -- 0/1 ; mem/repl.r3 instrumented (1) ; 0 = it was left as gen-src wrote it
	ckinit
	ckload 0? ( ; ) drop
	ckgen r3free
	ckload 1? ( drop r3free 1 ; ) drop		| the new program must compile
	ga gk gen-src 0 ;
