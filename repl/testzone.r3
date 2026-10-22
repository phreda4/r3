| testzone - zones of defs (replzone)
^repl/replzone.r3

#canary 0
:canary? | -- ; the memory after defs must be as it was
	0 ( 4096 <? dup canary + c@ $ff and 85 <>? ( "CANARY DAMAGED at %d" .println ; ) drop 1+ ) drop
	"canary ok" .println ;

:zinfo | i --
	dup "  #%d " .print
	dup z.kind "kind=%d " .print
	dup z.off "off=%d " .print
	dup z.len "len=%d " .print
	dup z.nl "lines=%d " .print
	dup z.line "line=%d " .print
	z.name "[%s]" .println ;

:show | --
	z.build
	0 ( zn <? dup zinfo 1+ ) drop
	defl "defl=%d  text:" .println
	defs .write .flush "<end>" .println ;

:
	core-init
	here dup 'canary ! 4096 + 'here !
	canary 4096 ( 1? 1- over over + 85 swap c! ) 2drop
	"| first comment" defs+ "| second line" defs+ "" defs+
	":a" defs+ "	dup *" defs+ "" defs+ "	1 + ;" defs+ "" defs+
	"#v 0 1 2" defs+
	":b 3 ;" defs+
	":c 5 ;" defs+ "" defs+ "" defs+ "" defs+
	"2 3 +" defs+ "| tail" defs+
	"--- zones" .println show
	"b" z.find "find b=%d" .println
	"a" z.find "find a=%d" .println
	"nope" z.find "find nope=%d" .println
	"v" z.find "find v=%d" .println
	"--- replace b (2 lines)" .println
	"b" z.find ":b
	dup * ;" z.replace "replace=%d" .println
	z.build show
	"--- delete a" .println
	"a" z.find z.delete "delete=%d" .println
	z.build show
	"--- norm" .println
	z.norm "norm=%d" .println
	show canary? ;
