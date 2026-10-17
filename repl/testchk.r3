| testchk - headless test of replchk (no UI): the lines are checked, nothing is run
^repl/replchk.r3

:rep | code --
	dup "code:%d" .println
	1 =? ( drop 'ckmsg "  %s" .println ckline 'ckfile "  at %s line %d" .println ; )
	2 =? ( drop 'ckmsg "  %s" .println ; )
	drop
	mwflag 0? ( drop ; ) drop
	'mwmb ( mwmb> <? dup "  writes: %s" .println >>0 ) drop ;

:t | str kind --
	'gk ! dup .println 'ga !
	ga gk gen-src
	chk-run rep ;

:t0 0 t ;
:t2 2 t ;

:
	core-init gen-init
	0 'sn !
	"1 2 +" t0
	"+" t0
	"foo" t0
	"10 randmax drop" t0
	ninc "ninc:%d" .println
	"#x 0" defs+ ":setx 'x ! ;" defs+
	"5 'x !" t0
	"1 setx" t0
	":bad foo ;" t2
	3 'sstk ! 4 'sstk 8 + ! 2 'sn !
	"+" t0
	"+ + +" t0
	"dup 0? ( drop ) drop" t0
	"1 2 3 4 5 + + + + + + +" t0
	":zzz nope ;" defs+
	"1" t0
	| effect of the project words (only certain effects are used)
	0 'sn !
	":two 2 + ;" defs+ ":three two two two ;" defs+
	":cond 0? ( 1 ) ;" defs+ ":rec dup 1 >? ( 1- rec ) ;" defs+
	"two" t0 "three" t0 "cond" t0 "rec" t0 "randmax" t0 "1 two drop two" t0 ;
