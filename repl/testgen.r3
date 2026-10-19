| testgen - headless test of the program generated from the tokens (replchk chk-gen)
| the boot words of the project are left out, repl-init and repl-done go around the line, the lines are kept
^repl/replchk.r3

:run | "line" kind --
	'gk ! 'ga !
	ga gk gen-src
	chk-run "chk-run:%d" .println
	chk-gen "chk-gen:%d" .println ;

:
	core-init gen-init
	0 'sn !
	":sq dup * ;" defs+
	": 5 | a; b" defs+ "  1 + ;" defs+
	":repl-init 100 ;" defs+ ":repl-done 1 + ;" defs+
	":after 2 * ;" defs+
	"3 sq" 0 run
	;
