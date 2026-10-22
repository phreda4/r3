| testfmt2 - fparen 0 (no line break after open marks) and defs-fmt-all
^repl/replfmt.r3

:show | --
	defs .write .flush "<end>" .println ;
:
	core-init m.init
	0 'fparen !
	"| helpers" defs+
	":cua dup * ;" defs+ ":foo 2 3 + dup cua * ;" defs+
	":t dup 0? ( drop 1 ) swap [ dup * ; ] drop ;" defs+
	"#v 0" defs+
	":u 2 3 + dup ( 1 + dup 4 + ) * ;" defs+
	":w dup ( 1 + 2 + 3 + dup swap drop ( 7 8 + 5 * ) ) drop ;" defs+
	"5 6 +" defs+
	defs-fmt-all
	show ;
