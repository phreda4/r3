| replchk - pre-check of the program generated for a line (mem/repl.r3)
| tokenizes the file inside the REPL process (r3token) before r3 is launched:
|  - compile error: message and exact file/line, without running anything
|  - word not found: the library is looked up (wfind), included and the check repeated
|  - stack: the line (the word rdline of mem/repl.r3) needs more values than the stack holds: its use, as r3token computed it
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

::mw.in? | str ini end -- 0/1
	'mwie !
	( mwie <?
		over over =s 1? ( 3drop 1 ; ) drop
		>>0 ) 2drop 0 ;

|--- tables
#ckinfo * 8192		| by word number: 2 = project word that writes memory
#cknmain 0

:ckwbase? | ntok -- 0/1 ; a base word that writes memory (bit $40 of its info in r3map)
	r3ainfo 3 + c@ $40 and ;

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
	7 <? ( 2drop ; )
	ckwbase? 1? ( 1 'ckcw ! ) 2drop ;

:ckdef | n -- ; project words that write memory (their callees are always before)
	8192 >=? ( drop ; )
	cknmain <? ( drop ; )
	dup r3isdata 1? ( 2drop ; ) drop
	dup r3isboot 1? ( 2drop ; ) drop
	0 'ckcw !
	dup nro>dic toklend ( 1? 1- swap @+ cktok swap ) 2drop
	ckcw 0? ( 2drop ; ) drop
	2 swap 'ckinfo + c! ;

|--- the line: the word rdline, its stack effect is the one r3token computed (info2: use / delta)
#ckstop 0 #ckres 0 #ckus 0 #ckue 0 #ckrdl 0 #ckavail 0

:ckrisky? | tok -- 0/1 ; a word whose effect is not fixed (several ; / R unbalanced / recursive / no ;)
	dup $ff and 2 <>? ( 2drop 0 ; ) drop
	8 >> $ffffffff and nro>dic @ $b8 and? ( drop 1 ; ) drop 0 ;


:ckculp | tok -- ; does the token write memory?
	dup $ff and
	2 =? ( drop 8 >> $ffffffff and
		8192 >=? ( drop ; )
		dup 'ckinfo + c@ 2 nand? ( 2drop ; ) drop
		nro>dic @ dic>name ckadd ; )
	7 <? ( 2drop ; )
	dup ckwbase? 0? ( 3drop ; ) drop
	nip 7 - basename 'cktmp2 lowcpy 'cktmp2 ckadd ;

:cknl | adr -- adr' ; start of the next line (the text only has 13)
	( c@+ 1? 13 =? ( drop ; ) drop ) drop 1- ;

:cklstart | line -- adr
	src swap ( 1 >? 1- swap cknl swap ) drop ;

:ckutok | tok -- ; culprits of the line, and if its effect is fixed
	dup 40 >>> src + ckus <? ( 2drop ; ) ckue >=? ( 2drop ; ) drop
	dup ckculp
	ckrisky? 1? ( 1 'ckstop ! ) drop ;

:ckfind | "name" -- idx ; the last word of the program with that name (-1 = none)
	cntdef ( cknmain >? 1- 2dup r3name =s 1? ( drop nip ; ) drop )
	2drop -1 ;

:ckinitd | -- delta ; the stack effect of repl-init, if the project has one
	"repl-init" ckfind -? ( drop 0 ; )
	nro>dic 8 + @ 8 >> $ff and 56 << 56 >> ;

:ckuser | --
	0 'ckres ! 0 'ckstop !
	gk 0 <>? ( drop ; ) drop
	"rdline" ckfind -? ( drop ; ) 'ckrdl !
	gyour cklstart dup 'ckus ! cknl 'ckue !
	ckrdl nro>dic toklend
	( 1? 1- swap @+ ckutok swap ) 2drop
	ckstop 1? ( drop ; ) drop
	sn ckinitd + 0 max 'ckavail !
	ckrdl nro>dic 8 + @ $ff and			| values the line takes from the stack
	ckavail >? (						| ... and the stack has less
		ckavail swap "the line needs %d values, only %d on the stack" sprint 'ckmsg strcpy
		2 'ckres ! ; ) drop ;

::ckwriters | -- ; marks the project words that write memory (call it with the tokens loaded)
	dic< dic - 4 >> 'cknmain !
	0 ( 1024 <? 0 over 3 << 'ckinfo + ! 1+ ) drop
	0 ( cntdef <? dup ckdef 1+ ) drop ;

::ckwrites? | n -- 0/1
	8192 >=? ( drop 0 ; ) 'ckinfo + c@ 2 and 1 >> ;

#cklc 0
::cklines | a b -- n
	0 'cklc ! swap ( over <? c@+ 13 =? ( 1 'cklc +! ) drop ) 2drop cklc 1+ ;

::ckboot1? | n -- 0/1 ; a boot word that is not the final boot of the REPL
	dup r3isboot 0? ( 2drop 0 ; ) drop
	boot>> <>? ( drop 1 ; ) drop 0 ;

:ckboottyped? | n -- 0/1 ; a boot word that starts on the line of the typed definition (the others are the boots of the project)
	dup ckboot1? 0? ( 2drop 0 ; ) drop
	r3name src swap cklines inyour? 1? ( drop 1 ; ) drop 0 ;

:ckbootin | -- 0/1
	gk 2 <>? ( drop 0 ; ) drop
	cknmain ( cntdef <? dup ckboottyped? 1? ( 2drop 1 ; ) drop 1+ ) drop 0 ;

:chk-user | -- code ; 0 ok, 2 stack, 3 a boot word typed in the project
	'mwmb 'mwmb> ! 0 'mwmn ! 0 'mwflag ! 0 'ckline !
	ckwriters
	ckbootin 1? ( drop "boot words (: ...) are edited with /edit" 'ckmsg strcpy 3 ; ) drop
	ckuser
	ckres ;

|--- compile error: message, file and line (before the memory is freed)
#ckeo 0 #ckbo 0 #ckunk 0 #ckni 0
#ckword * 64

:ckinc | entry -- ; the file whose text contains the error
	dup 8 + @ $ffffffff and
	ckeo >? ( 2drop ; )
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

##ckauto 1		| 1 = a word not found is looked up in the libraries and its include is added (the line); 0 = the project (the model)
##ckonok 'chk-user	| analysis with the tokens loaded: -- code
##ckonerr 0		| the tokenizer failed (ckmsg ckfile ckline are set): --

:ckfix | -- 0/1 ; word not found in the session: its library is included
	ckauto 0? ( ; ) drop
	ckunk 0? ( ; ) drop
	'ckword wfind 2 <>? ( drop 0 ; ) drop
	ninc 'ckni !
	cl "^%s" sprint inc+
	ninc ckni - 1? ( drop 1 ; ) drop 0 ;

:ckerrx | -- ; ckonerr, if there is one
	ckonerr 1? ( ex ; ) drop ;

:ckpass | -- code ; tokenizes mem/repl.r3 and calls ckonok (or ckonerr)
	"mem/repl.r3" r3tok
	error 1? ( drop ckerr ckerrx r3free 1 ; ) drop
	ckonok ex r3free ;

:ckloop | n -- code ; n = the includes added so far
	ckpass
	1 <>? ( nip ; )
	over 8 >=? ( drop nip ; ) drop
	ckfix 0? ( drop nip ; ) drop
	drop ga gk gen-src
	1+ ckloop ;

::chk-run | -- code ; ga/gk = the line already generated with gen-src
	0 ckloop ;

::chk-loop | -- code ; the same loop for other analyses (set ckonok, ckonerr, ckauto before)
	0 ckloop ;

|--- the program that is run: generated from the tokens of the assembled one (gen-src)
| the boot words of the project are left out, the hooks of the session (repl-init, repl-done) are called around the line
| /trace: a .tr before every ; of the project words
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

:ckhk | "word" -- ; the call to a hook of the session, if the program defines it (only for a typed line)
	gk 0 <>? ( 2drop ; ) drop
	dup ckfind -? ( 2drop ; ) drop
	,s ,sp ;

:ckgbc | tok idx -- ; call inside the final boot: the hooks of the session go around .rbegin and .rdump
	dup r3name ".rdump" =s 1? ( 2drop "repl-done" ckhk ckp ; ) drop
	r3name ".rbegin" =s 1? ( drop ckp "repl-init" ckhk ; ) drop
	ckp ;

:ckgcall | tok -- ; word call: the calls to boot words are not written (they only chain the boots; the includes chain the libraries)
	dup 8 >> $ffffffff and
	dup r3isboot 1? ( 3drop ; ) drop
	ckcur boot>> =? ( drop ckgbc ; ) drop
	drop ckp ;

:ckgsemi | tok -- ; ; of a project word (not in an anonymous one): with /trace the stack is recorded first
	ckanon 1? ( drop ckp ; ) drop
	ckcur boot>> =? ( drop ckp ; ) drop
	ckcur ckrdl =? ( drop ckp ; ) drop
	trace 0? ( drop ckp ; ) drop
	gk 0 <>? ( drop ckp ; ) drop
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

:ckgdef | n -- ; a word of the program (the boot words of the project are not written)
	dup ckboot1? 1? ( 2drop ; ) drop
	dup 'ckcur ! dup cktrn
	dup r3name src swap cklines ckpad
	dup nro>dic @ ,r3pre
	dup boot>> <>? ( dup ,wname ) drop ,sp
	nro>dic toklend
	( 1? 1- swap @+ ckgtok swap ) 2drop ;

:ckgen | -- ; the program that is run, from the tokens (the lines of mem/repl.r3 are kept)
	dic< dic - 4 >> 'cknmain !
	"rdline" ckfind 'ckrdl !
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

::chk-gen | -- 0/1 ; the program that is run is written from the tokens (1) ; 0 = it could not be written
	ckload 0? ( ; ) drop
	ckgen r3free
	ckload 1? ( drop r3free 1 ; ) drop		| the new program must compile
	0 ;
