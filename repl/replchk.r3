| replchk - pre-check of the program generated for a line (mem/repl.r3)
| tokenizes the file inside the REPL process (r3token) before r3 is launched:
|  - compile error: message and exact file/line, without running anything
|  - word not found: the library is looked up (wfind), included and the check repeated
|  - stack: the line surely needs more values than the stack holds (straight-line start only)
|  - memory: words of the line and project words that write memory
| chk-run  -- code    0 ok | 1 compile error | 2 stack underflow    (ckmsg ckfile ckline)
| r3token must be included before replcore (replcore redefines tok)
^repl/replgen.r3

##ckmsg * 160
##ckfile * 128
##ckline 0

|--- memory writers (filled by chk-run)
##mwnm * 2048 ##mwnm> 0		| project words that write memory
##mwmb * 160 ##mwmb> 0		| words of the line that write memory
##mwflag 0
#mwmn 0 #mwie 0 #cktmp * 64 #cktmp2 * 64 #ckhere 0

#mwrw "!" "c!" "w!" "d!" "!+" "c!+" "w!+" "d!+" "+!" "c+!" "w+!" "d+!"
"a!" "a!+" "ca!" "ca!+" "da!" "da!+" "b!" "b!+" "cb!" "cb!+" "db!" "db!+"
"move" "move>" "fill" "cmove" "cmove>" "cfill" "dmove" "dmove>" "dfill" ( 0 )

::mw.in? | str ini end -- 0/1
	'mwie !
	( mwie <?
		over over =s 1? ( 3drop 1 ; ) drop
		>>0 ) 2drop 0 ;

|--- tables
#ckinfo * 8192		| by word number: 1 = effect is certain, 2 = project word that writes memory
#ckwtab * 256		| by token: 1 = base word that writes memory
#ckready 0
#cknmain 0

:ckinit | -- ; base writers by token number
	ckready 1? ( drop ; ) drop
	'mwrw ( dup c@ 1?  drop
		dup ?base 1? ( dup 6 + 'ckwtab + 1 swap c! ) drop
		>>0 ) 2drop
	1 'ckready ! ;

:sbyte | v -- n
	$ff and 56 << 56 >> ;

:ckboot? | n -- 0/1 ; definition ": " without name
	nro>dic @ dic>name c@+ $3a <>? ( 2drop 0 ; ) drop
	c@ $ff and 33 <? ( drop 1 ; ) drop 0 ;

|--- lowercase copy / names
:lowcpy | str dst --
	( swap c@+ $ff and 1? tolow rot c!+ ) 2drop 0 swap c! ;

:cknamew | str -- ; project word that writes memory
	'cktmp swap copynom
	mwnm> 'mwnm - 1900 >=? ( drop ; ) drop
	'cktmp mwnm> strcpyl 'mwnm> ! ;

:ckadd | str -- ; culprit of the line (no repeats, at most 6)
	1 'mwflag !
	mwmn 6 >=? ( 2drop ; ) drop
	'cktmp swap copynom
	'cktmp 'mwmb mwmb> mw.in? 1? ( drop ; ) drop
	mwmb> 'mwmb - 120 >=? ( drop ; ) drop
	'cktmp mwmb> strcpyl 'mwmb> ! 1 'mwmn +! ;

|--- definitions: certain effect and memory writers (one forward pass)
#ckcc 0 #ckcw 0

:cktok | tok --
	dup $ff and
	2 =? ( drop 8 >> $ffffffff and
		8192 >=? ( drop 0 'ckcc ! ; )
		'ckinfo + c@
		dup 1 and 0? ( 0 'ckcc ! ) drop
		2 and? ( 1 'ckcw ! ) drop ; )
	8 12 in? ( 0 'ckcc ! )			| ( ) [ ] EX ; the final ; is fine, several ; are flagged by r3token
	13 25 in? ( 0 'ckcc ! )
	dup 'ckwtab + c@ 1? ( 1 'ckcw ! ) drop
	2drop ;

:ckdef | n --
	1 'ckcc ! 0 'ckcw !
	dup nro>dic @ 1 and? ( 2drop ; ) drop		| data
	dup nro>dic @ $b8 and? ( 0 'ckcc ! ) drop		| several ; / R unbalanced / recursive / no ;
	dup nro>dic toklend ( 1? 1- swap @+ cktok swap ) 2drop
	dup cknmain <? ( 0 'ckcw ! ) drop
	dup ckboot? 1? ( 0 'ckcw ! ) drop
	ckcw 1? ( over nro>dic @ dic>name cknamew ) drop
	ckcc ckcw 1 << or swap
	8192 <? ( 'ckinfo + c! ; ) 2drop ;

|--- the line: culprits and stack (straight-line start)
#ckdep 0 #ckstop 0 #ckres 0
#ckuse 0 #ckdel 0 #cknm 0
#ckus 0 #ckue 0

:ckunder
	sn ckdep + ckuse cknm
	"%w needs %d value(s), only %d on the stack" sprint 'ckmsg strcpy
	2 'ckres ! 1 'ckstop ! ;

:ckapply | -- ; applies the effect ckuse/ckdel
	sn ckdep + ckuse <? ( drop ckunder ; ) drop
	ckdel 'ckdep +! ;

:cksimw | n -- ; call to a word
	8192 >=? ( drop 1 'ckstop ! ; )
	dup 'ckinfo + c@ 1 and 0? ( 2drop 1 'ckstop ! ; ) drop
	nro>dic dup @ dic>name 'cknm !
	8 + @ dup $ff and 'ckuse !
	8 >> sbyte 'ckdel !
	ckapply ;

:cksimb | n -- ; base word (n >= 7)
	12 <=? ( drop 1 'ckstop ! ; )			| ; ( ) [ ] EX
	dup 7 - basename 'cktmp lowcpy 'cktmp 'cknm !
	dup r3ainfo c@ $ff and 'ckuse !
	dup r3ainfo 1+ c@ sbyte 'ckdel !
	25 <=? ( drop ckapply 1 'ckstop ! ; )		| conditionals: check, then stop
	drop ckapply ;

:cksim | tok --
	dup $ff and
	2 =? ( drop 8 >> $ffffffff and cksimw ; )
	7 <? ( 2drop 1 'ckdep +! ; )
	nip cksimb ;

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
	dup 40 >>> src +
	ckus <? ( 2drop ; )
	ckue >=? ( 2drop ; ) drop
	dup ckculp
	ckstop 1? ( 2drop ; ) drop
	cksim ;

:ckuser | --
	0 'ckres ! 0 'ckstop ! 0 'ckdep !
	gk 0 <>? ( drop ; ) drop
	boot>> -? ( drop ; ) drop
	gyour cklstart dup 'ckus ! cknl 'ckue !
	boot>> nro>dic toklend
	( 1? 1- swap @+ ckutok swap ) 2drop ;

:chk-user | -- code
	'mwnm 'mwnm> ! 'mwmb 'mwmb> ! 0 'mwmn ! 0 'mwflag !
	dic< dic - 4 >> 'cknmain !
	0 ( 1024 <? 0 over 3 << 'ckinfo + ! 1+ ) drop
	0 ( cntdef <? dup ckdef 1+ ) drop
	ckuser
	ckres ;

|--- compile error: message, file and line (before the memory is freed)
#ckeo 0 #ckbo 0 #cklc 0 #ckunk 0 #ckni 0 #ckn 0
#ckword * 64

:cklines | a b -- n
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

:ckerr | --
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

:ckfree | -- ; frees what r3load reserved
	( memsize drop ckhere <>? drop empty ) drop empty ;


:ckpass | -- code
	ckinit
	here 'ckhere ! mark
	"mem/repl.r3" r3load
	error 1? ( drop ckerr ckfree 1 ; ) drop
	chk-user ckfree ;

:ckloop | -- code
	ckpass
	1 <>? ( ; )
	ckfix 0? ( drop ; ) 2drop
	ga gk gen-src
	ckloop ;

::chk-run | -- code ; ga/gk = the line already generated with gen-src
	0 'ckn !
	ckloop ;
