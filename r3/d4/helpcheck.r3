| helpcheck - the lines of mhelp.txt are the words of r3base and of mlibs.r3, in order
| run it after metabuild.r3 and metahelp.r3:  r3 r3/d4/test/helpcheck.r3
^r3/d4/helptxt.r3

#bad 0 #cn 0 #ci 0 #ncom 0 #ndesc 0

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

:main
	"help lines vs words" .println
	helptxt-load 0? ( "ERROR: the lines of mhelp.txt are not the words (run metabuild.r3 and metahelp.r3)" .println hn htotal "lines %d, words %d" .println ; ) drop
	hn "lines: %d" .println
	0 ( dup bhelp c@ $ff and 1? drop dup chkb 1+ ) drop
	0 ( dup 3 << 'liblist + @ 1? drop dup chkl 1+ ) drop
	ndesc ncom hn "lines %d, with comment %d, with ; description %d" .println
	19 bhelp "line 19 (base): %s" .println
	0 0 lhelp "first line of the first library: %s" .println
	bad 0? ( drop "OK: every line is the help of its word" .println ; ) drop
	"ERRORS" .println ;

: main ;
