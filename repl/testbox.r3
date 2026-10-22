| testbox - the text box (replbox)
^repl/replbox.r3

:st | -- ; the state
	'bx bxc bx.line bx.col bx.nl bx.mode "  [%s] cursor=%d line=%d col=%d lines=%d mode=%d" .println
	;
:t | "text" --
	dup .println bx.set ;
:pr | --
	bx.complete? bx.err swap bx.mode "  mode=%d complete=%d err=%s" .println ;
:cls | -- ; classes of ba as digits
	bx.color
	0 ( bx.len <? dup 'ba + c@ $ff and "%d" .print 1+ ) drop "" .println ;
:
	core-init m.init
	"--- edit" .println
	bx.clear
	"abc" ( c@+ $ff and 1? bx.ins ) 2drop
	bx.left bx.left 88 bx.ins "X" drop
	'bx "after abc,left,left,X: [%s]" .println
	bx.end 10 bx.ins "de" ( c@+ $ff and 1? bx.ins ) 2drop
	'bx "after end,LF,de: [%s]" .println
	bx.up "up=%d" .println bx.col bxc "cursor=%d col=%d" .println
	bx.down "down=%d" .println bx.col bxc "cursor=%d col=%d" .println
	bx.down "down (last)=%d" .println
	bx.home bx.back 'bx "home+backspace (joins lines): [%s]" .println
	bx.del 'bx "del: [%s]" .println
	"--- set (CR LF)" .println
	"line1
line2

" bx.set bx.nl bxc 'bx "set: [%s] cursor=%d lines=%d" .println
	"--- modes" .println
	":a 1 ;" bx.set pr
	"#v 0" bx.set pr
	"| comment" bx.set pr
	"^r3/lib/rand.r3" bx.set pr
	"2 3 +" bx.set pr
	"" bx.set pr
	"--- complete?" .println
	":a 1 +" bx.set pr
	":a 1 + ;" bx.set pr
	":a dup 0? ( 1 +" bx.set pr
	":a ""hi" bx.set pr
	":a 1 ;
:b 2" bx.set pr
	":a ( 1 ) ) ;" bx.set pr
	":a [ dup * ; ] ;" bx.set pr
	"--- colors" .println
	":cua dup * ;" defs+ m.ready
	":x dup cua 12 $ff 'x ""s"" | c
	( ) ; zzz" bx.set 0 'bxc ! cls
	"--- accept" .println
	"2 3 +  dup cu" bx.set "cua" bx.accept 'bx "[%s]" .println
	"--- out" .println
	"a
b" bx.set bx.out ( c@+ $ff and 1? "%d " .print ) 2drop "" .println
	"--- limits" .println
	bx.clear 9000 ( 1? 1- 120 bx.ins ) drop
	bx.len bx.col "one line: len=%d (max 1990)  col=%d" .println
	bx.clear 4 ( 1? 1- 1900 ( 1? 1- 120 bx.ins ) drop 10 bx.ins ) drop
	bx.len bx.nl "several lines: len=%d lines=%d" .println
	bx.clear 100 ( 1? 1- 1900 ( 1? 1- 120 bx.ins ) drop 10 bx.ins ) drop
	bx.len "text of 100 lines: len=%d (max 7900)" .println
	"--- word / scroll" .println
	"one two thr" bx.set bxc bx.word "word start=%d cursor=%d" .println
	;
