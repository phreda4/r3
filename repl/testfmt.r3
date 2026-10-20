| testfmt - headless test of the automatic format (replfmt)
^repl/replfmt.r3

:show | --
	defs ( dup c@ $ff and 1? drop
		dup 'lo2 strcpyln 'lo2 "|%s" .println
		nextl ) 2drop ;

:add | "text" --
	defs-mark defs+n m.ready defs-fmt ;

:
	core-init gen-init m.init
	"^r3/lib/rand.r3" inc+
	":cua dup * ;" add
	":foo 2 3 + dup cua * ;" add
	":t dup 0? ( drop 1 ) swap [ dup * ; ] drop ;" add
	"#v 0" add
	":setv 'v ! ;" add
	"| comment" add
	":old | x -- y z
  dup dup + + ;

:nxt old drop ;" add
	": 5 | boot" add
	"  1 + ;" add
	"show:" .println show ;
