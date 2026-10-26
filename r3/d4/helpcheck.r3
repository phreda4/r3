| helpcheck - the help lists (mhelp.r3) are parallel to the libraries (mlibs.r3): the same count of words
| run it after metahelp.r3:  r3 r3/d4/test/helpcheck.r3
^r3/lib/console.r3
^r3/d4/r3map.r3
^r3/d4/meta/mlibs.r3
^r3/d4/meta/mhelp.r3

#ct 0 #cne 0 #ce 0
#nbad 0 #tw 0 #ts 0 #tt 0 #li 0 #nw 0

:cntw | 'words -- n ; words of a list of mlibs
	0 swap ( dup c@ $ff and 1? drop >>0 swap 1+ swap ) 2drop ;

:step | p -- p'
	1 'ct +!
	dup c@ $ff and 0? ( drop 1+ ; ) drop
	1 'cne +! >>0 ;

:cnth | 'start 'end -- ; strings of a help list (ct) and the ones that have text (cne)
	8 - 'ce ! 0 'ct ! 0 'cne !
	( ce <? step ) drop ;

:lib | i --
	'li !
	li 3 << 'liblist + @ 8 + @ cntw 'nw !
	li 3 << 'helplist + @
	li 1+ 3 << 'helplist + @ 0? ( drop 'helplist )
	cnth
	nw tw + 'tw !
	ct 'ts +! cne 'tt +!
	ct nw <>? ( 1 'nbad +! nw li "MISMATCH lib %d: %d words, %d help lines" .println 0 ) drop ;

:main
	"help lists vs libraries" .println
	0 ( dup 3 << 'liblist + @ 1? drop
		dup lib 1+ ) 2drop
	tt ts tw "words %d, help strings %d, with text %d" .println
	0 ( dup basename c@ $ff and 1? drop 1+ ) drop
	"base words %d" .println
	0 ( dup 3 << 'liblist + @ 1? drop 1+ ) drop
	"libraries %d" .println
	nbad 0? ( drop "OK: the lists are parallel" .println ; ) drop
	"ERRORS" .println ;

: main ;
