| helptxt - the help lines of the words (meta/mhelp.txt) with a direct index
| PHREDA 2023
|
| mhelp.txt (made by metahelp.r3) has one line for each word:  name | stack effect ; description
| the order: the base words (as in r3base), then the words of the libraries (the order of mlibs.r3)
| helptxt-load puts the text in memory, changes each end of line (CR, LF or CR LF) for a 0 and makes
| an index with the address of each line: the help of a word is at once, without searching.
|
|   bhelp  | n -- 'str          the help line of the base word n (as in r3base)
|   lhelp  | lib j -- 'str      the help line of the word j of a library (lib = its place in liblist)
|   hline  | n -- 'str          the line n of the file
|
| the first line of a library is: the base words + the words of the libraries before it
| (the words of each library are counted with its list in mlibs.r3), so only the file and mlibs.r3
| are needed. if the number of lines is not the number of words, there is no help (helptxt-load = 0):
| metabuild.r3 and metahelp.r3 have to be run together.
|
^r3/lib/console.r3
^r3/d4/r3map.r3
^r3/d4/meta/mlibs.r3

#htxt 0			| the text, each end of line is a 0
#hidx 0			| address of each line (qwords)
#hlibs 0		| first line of each library (qwords)
#cum 0
##hn 0			| lines
##hbase 0		| base words
##htotal 0		| base words + words of the libraries

:cntw | 'words -- n ; words of a list of mlibs
	0 swap ( dup c@ $ff and 1? drop >>0 swap 1+ swap ) 2drop ;

:hc | n p c -- n p ; a char of the text: the ends of line count (a CR LF is one)
	13 =? ( drop swap 1+ swap dup c@ $ff and 10 =? ( drop 1+ ; ) drop ; )
	10 =? ( drop swap 1+ swap ; )
	drop ;

:hcount | -- n ; lines of the text
	1 htxt ( c@+ $ff and 1? hc ) 2drop ;

:endl | p -- p' ; p is a CR or a LF: it is a 0 (a CR LF is one end) ; the start of the next line
	dup c@ $ff and
	13 =? ( drop 0 over c! 1+ dup c@ $ff and 10 =? ( drop 0 over c! 1+ ; ) drop ; )
	drop 0 over c! 1+ ;

:hstep | p -- p'
	dup c@ $ff and
	13 =? ( drop endl dup a!+ 1 'hn +! ; )
	10 =? ( drop endl dup a!+ 1 'hn +! ; )
	drop 1+ ;

:hbuild | -- ; the index of the lines
	hidx >a htxt a!+ 1 'hn !
	htxt ( dup c@ $ff and 1? drop hstep ) drop
	hn 1- 3 << hidx + @ c@ $ff and 0? ( drop -1 'hn +! ; ) drop ;	| the "line" after the last end is not a line

:hbases | -- n ; base words
	0 ( dup basename c@ $ff and 1? drop 1+ ) drop ;

::helptxt-load | -- 1/0 ; 1 = the lines are the words
	0 'hn !
	here dup 'htxt !
	"r3/d4/meta/mhelp.txt" load 0 swap c!+ 'here !
	here 'hidx !
	hcount 2 + 3 << here + 'here !
	here 'hlibs !
	0 ( dup 3 << 'liblist + @ 1? drop 1+ ) drop
	1+ 3 << here + 'here !
	hbuild
	hbases dup 'hbase ! 'cum !
	0 ( dup 3 << 'liblist + @ 1? drop
		cum over 3 << hlibs + !
		dup 3 << 'liblist + @ 8 + @ cntw cum + 'cum !
		1+ ) 2drop
	cum 'htotal !
	hn htotal =? ( drop 1 ; ) drop
	0 'hn ! 0 ;

::hline | n -- 'str
	hn >=? ( drop "" ; )
	3 << hidx + @ ;

::bhelp | n -- 'str ; the base word n (as in r3base)
	hbase >=? ( drop "" ; )
	hline ;

::lhelp | lib j -- 'str ; the word j of a library
	swap 3 << hlibs + @ + hline ;
