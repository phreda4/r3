| helpcheck - the lines of mhelp.txt are the words of r3base and of mlibs.r3, in order
| run it after metabuild.r3 and metahelp.r3:  r3 r3/d4/test/helpcheck.r3
^r3/d4/helptxt.r3

#bad 0 #cn 0 #ci 0 #ncom 0 #ndesc 0 #ndup 0
#tbuf * 128

:low | c -- c
	65 <? ( ; ) 90 >? ( ; ) 32 + ;

:tokeq | 'line 'name -- 0/1 ; the first word of the line is the name
	( dup c@ $ff and 1?
		low pick2 c@ $ff and low <>? ( 3drop 0 ; )
		drop 1+ swap 1+ swap )
	2drop c@ $ff and 33 <? ( drop 1 ; ) drop 0 ;

:stats | 'line --
	dup " | " findstr 1? ( 1 'ncom +! ) drop
	" ; " findstr 1? ( 1 'ndesc +! ) drop ;

:chkb | n --
	dup 'cn ! bhelp dup stats cn basename tokeq
	0? ( 1 'bad +! cn "BASE: the line of the word %d is not its line" .println ) drop ;

:chkl | i --
	dup 'ci !
	3 << 'liblist + @ 8 + @ 0
	( over c@ $ff and 1? drop
		ci over lhelp dup stats pick2 tokeq
		0? ( 1 'bad +! over ci "LIB %d: the line of the word %d is not its line" .println ) drop
		swap >>0 swap 1+ ) 3drop ;

|---- search by name and parts of a line
:chkf | n -- ; hw.find finds the line, and hw.next reaches it
	'cn !
	cn hline -1 hw.next
	-? ( drop 1 'bad +! cn "FIND: the line %d is not found" .println ; )
	cn <>? ( 1 'ndup +! )
	( cn <>?
		cn hline swap hw.next
		-? ( drop 1 'bad +! cn "FIND: the line %d is not in its chain" .println ; ) )
	drop ;

:chkw | n -- ; the library of the line (a lib word: its place gives the same line)
	dup hbase <? ( 2drop ; ) drop
	dup hw.libidx over hw.libj lhelp over hline <>? ( 1 'bad +! over "WHERE: the line %d is not lhelp(libidx, libj)" .println ) 2drop ;

:parts
	"parts of a line" .println
	"dup | a -- a a ; duplicate TOS" 'tbuf 120 hw.eff 'tbuf "eff:  [%s]" .println
	"dup | a -- a a ; duplicate TOS" hw.desc "desc: [%s]" .println
	"xf | horizontal scale" 'tbuf 120 hw.eff 'tbuf "eff (no effect): [%s]" .println
	"xf | horizontal scale" hw.desc "desc (no effect): [%s]" .println
	"foo" 'tbuf 120 hw.eff 'tbuf "eff (no comment): [%s]" .println
	"foo" hw.desc "desc (no comment): [%s]" .println
	$101 hw.effab "effab 1 -> 2: [%s]" .println
	$2ff hw.effab "effab 2 -> 1: [%s]" .println
	$0 hw.effab "effab 0 -> 0: [%s]" .println
	-1 hw.effab "effab data: [%s]" .println ;

:finds
	"dup" hw.find dup "find dup: line %d" .println
	dup hline swap hw.where "  %s  (%s)" .println
	"DROP" hw.find hline "find DROP (case): %s" .println
	"drawtile" hw.find ( +? dup hline over hw.where pick2 "line %d  %s  (%s)" .println
		"drawtile" swap hw.next ) drop
	"zzznotaword" hw.find "find zzznotaword: %d" .println ;

:main
	"help lines vs words" .println
	helptxt-load 0? ( "ERROR: the lines of mhelp.txt are not the words (run metabuild.r3 and metahelp.r3)" .println hw.count htotal "lines %d, words %d" .println ; ) drop
	hw.count "lines: %d" .println
	0 ( dup bhelp c@ $ff and 1? drop dup chkb 1+ ) drop
	0 ( dup 3 << 'liblist + @ 1? drop dup chkl 1+ ) drop
	0 ( hw.count <? dup chkf dup chkw 1+ ) drop
	ndup "names that repeat in more than one library: %d" .println
	parts finds
	ndesc ncom hw.count "lines %d, with comment %d, with ; description %d" .println
	19 bhelp "line 19 (base): %s" .println
	0 0 lhelp "first line of the first library: %s" .println
	bad 0? ( drop "OK: every line is the help of its word" .println ; ) drop
	"ERRORS" .println ;

: main ;
