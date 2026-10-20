| testtrace - headless test of /trace: generation from the tokens, run and read of mem/repl.trc
^repl/replchk.r3

:rec | i --
	80 * 'trbuf 16 + + >a
	a@+ trname a@+ swap "%w depth:%d" .println ;

:
	core-init
	0 'sn !
	":sq dup * ;" defs+
	":cub dup sq * ;" defs+
	":abs- -? ( neg ) ;" defs+
	":fact dup 1 >? ( dup 1- fact * ) ;" defs+
	"3 cub 4 sq abs-" dup 'ga ! 0 'gk !
	ga gk gen-src
	chk-run "chk:%d" .println
	chk-trace "trace-gen:%d" .println
	"mem/repl.trc" delete
	do-run
	'trbuf "mem/repl.trc" load drop
	'trbuf @ "records:%d" .println
	0 ( 'trbuf @ <? dup rec 1+ ) drop ;
