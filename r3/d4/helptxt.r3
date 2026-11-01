| helptxt - the help lines of the words (meta/mhelp.txt) with a direct index
| PHREDA 2023
|
| mhelp.txt (made by metahelp.r3) has one line for each word:  name | stack effect ; description
| the order: the base words (as in r3base), then the words of the libraries (the order of mlibs.r3)
| helptxt-load puts the text in memory, changes each end of line (CR, LF or CR LF) for a 0 and makes
| an index with the address of each line: the help of a word is at once, without searching.
|
| the library of the help, for the tools (repl, r3ide): include only this file.
|
|   hw.load     | -- 1/0               loads the help once (call it at the start, before any mark/empty). 1 = ready
|   hw.count    | -- n                 lines of the file (= words)
|
| the line of a word (a pointer to the text, "" if there is none)
|   bhelp       | n -- 'str            the base word n (as in r3base)
|   lhelp       | lib j -- 'str        the word j of a library (lib = its place in liblist)
|   hline       | n -- 'str            the line n of the file (the number of the word in all)
|
| search by name (the first word of the string, the case does not matter; n = the number of the line)
|   hw.find     | "name" -- n/-1       the first line of that word (the base words, then the libraries in order)
|   hw.next     | "name" n -- n'/-1   the next line of the same name after the line n (a word in more than one library)
|   hw.where    | n -- 'str           "base" or the path of the library of the line n
|   hw.libidx   | n -- lib/-1         the place in liblist of the library of the line n (-1 = base word)
|   hw.libj     | n -- j              the place of the word in its library (the number in r3base for a base word)
|   hw.libname  | lib -- 'str         the path of the library ("base" for -1)
|
| the parts of a line:   name | stack effect ; description
|   hw.eff      | 'line dst n --       the stack effect (empty if the line has no one), at most n chars (dst: n+1 bytes)
|   hw.desc     | 'line -- 'str        the description ("" if the line has no one; a comment without effect is all description)
|   hw.comment  | 'line -- 'str/0      all that follows the first " | " (0 = a line without comment)
|   hw.cpy      | src dst n --         copy at most n chars of src to dst, and a 0 (dst: n+1 bytes)
|   hw.effab    | eff -- 'str          the stack effect computed by the analyzer, as  a b -- c d  (eff = use<<8 | delta, -1 = data)
|                                     the string is in a buffer of the library: copy it before the next call
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
#hn 0			| lines
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

::hline | n -- 'str
	hn >=? ( drop "" ; )
	3 << hidx + @ ;

|---- search by name: a table with the lines (hash of the first word, the case does not matter)
#hhash 0			| 16384 qwords: line+1 (0 = free)
#cpd 0 #cps 0
#efa * 64

::hw.cpy | src dst n -- ; at most n chars and a 0 (dst: n+1 bytes)
	>r 'cpd ! dup 'cps !
	count nip r> min
	cpd cps pick2 cmove
	cpd + 0 swap c! ;

:hhs | 'line -- h ; hash of the first word
	5381 swap
	( c@+ $ff and 32 >? $20 or rot 33 * + swap )
	2drop $3fff and ;

:hins | n -- ; the line n in the table
	dup hline hhs
	( dup 3 << hhash + @ 1? drop 1+ $3fff and ) drop
	3 << hhash + swap 1+ swap ! ;

:hmake | -- ; the table of the names
	here dup 'hhash ! $20000 + 'here !
	0 ( $4000 <? 0 over 3 << hhash + ! 1+ ) drop
	0 ( hn <? dup hins 1+ ) drop ;

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
	hn htotal =? ( drop hmake 1 ; ) drop
	0 'hn ! 0 ;

::bhelp | n -- 'str ; the base word n (as in r3base)
	hbase >=? ( drop "" ; )
	hline ;

::lhelp | lib j -- 'str ; the word j of a library
	swap 3 << hlibs + @ + hline ;

|---- api for the tools
#hq 0 #hl0 0 #hlb 0 #hed 0
#hdone -1

::hw.load | -- 1/0 ; loads the help once
	hdone -? ( drop helptxt-load dup 'hdone ! ) ;

::hw.count | -- n
	hn ;

:hmatch | line -- 0/1 ; after hl0 and with the name hq
	hl0 <=? ( drop 0 ; ) hline hq =s ;

::hw.next | "name" n -- n'/-1
	'hl0 ! 'hq !
	hhash 0? ( drop -1 ; ) drop
	hq hhs
	( dup 3 << hhash + @ 1?
		1- dup hmatch 1? ( drop nip ; ) 2drop
		1+ $3fff and )
	2drop -1 ;

::hw.find | "name" -- n/-1
	-1 hw.next ;

::hw.libidx | n -- lib/-1
	-1 'hlb !
	0 ( dup 3 << 'liblist + @ 1? drop
		dup 3 << hlibs + @ pick2 <=? ( over 'hlb ! ) drop
		1+ )
	3drop hlb ;

::hw.libname | lib -- 'str
	-? ( drop "base" ; ) 3 << 'liblist + @ @ ;

::hw.where | n -- 'str
	hw.libidx hw.libname ;

::hw.libj | n -- j
	hbase <? ( ; )
	dup hw.libidx 3 << hlibs + @ - ;

::hw.comment | 'line -- 'str/0
	0? ( ; ) " | " findstr 0? ( ; ) 3 + ;

::hw.desc | 'line -- 'str
	hw.comment 0? ( drop "" ; )
	dup " ; " findstr 1? ( nip 3 + ; ) drop
	dup "--" findstr 1? ( 2drop "" ; ) drop ;

::hw.eff | 'line dst n --
	over 'hed ! 0 hed c!
	rot hw.comment 0? ( 3drop ; )
	dup "--" findstr 0? ( 4drop ; ) drop
	-rot hw.cpy
	hed " ; " findstr 1? ( 0 over c! ) drop ;

::hw.effab | eff -- 'str
	-? ( drop "data" ; )
	dup 8 >> swap $ff and 56 << 56 >> over +
	'efa >a
	over 12 min 0 ( over <? dup 97 + ca!+ 32 ca!+ 1+ ) 2drop
	45 ca!+ 45 ca!+
	swap 12 min dup rot + 24 min swap
	( over <? 32 ca!+ dup 97 + ca!+ 1+ ) 2drop
	0 ca! 'efa ;
