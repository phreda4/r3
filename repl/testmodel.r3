| testmodel - headless test of the model of r3token (replmodel): nothing is run
^repl/replmodel.r3

:show | i --
	dup m.line over m.writes? pick2 m.eff effstr pick3 m.name
	"%w  eff:%s  writes:%d  line:%d" .println
	drop ;

:list
	m.ready
	m.count m.ok "ok:%d words:%d" .println
	0 ( m.count <? dup show 1+ ) drop ;

:
	core-init gen-init m.init
	"project empty:" .println list
	":sq dup * ;" defs+ ":cub dup sq * ;" defs+ "#v 0" defs+
	":setv 'v ! ;" defs+ "::pub 1 + ;" defs+ ":cond 0? ( 1 ) ;" defs+
	"project:" .println list
	"sq" m.has "has sq:%d" .println
	"nope" m.has "has nope:%d" .println
	"cub" m.find "find cub:%d" .println
	"repl-init" hasdef "hasdef repl-init:%d" .println
	":repl-init 1 ;" defs+ m.ready "repl-init" hasdef "hasdef repl-init (after):%d" .println
	"^r3/lib/rand.r3" inc+ ":rr randmax ;" defs+
	"with include:" .println list
	":sq dup dup * * ;" defs+ m.ready
	"sq prev:" .println m.count 1- m.prev "%d" .println
	": 5 | a; b" defs+ "  1 + ;" defs+ ":after 2 * ;" defs+
	"with boot:" .println list
	m.boots "boots:%d" .println
	0 ( 14 <? dup dup m.boot? swap "line %d boot:%d" .println 1+ ) drop
	"1" 'ga ! 0 'gk ! ga gk gen-src chk-run "exec program with the boot skipped: chk-run code:%d" .println
	":bad nope ;" defs+
	"with error:" .println list
	ckline 'ckmsg "msg:%s line:%d" .println ;
