| metahelp - help line of each exported word of the libraries, and of the base words
| PHREDA 2023
|
| mlibs.r3 (metabuild.r3) has the name, the stack and the type of each word;
| mhelp.r3 has its help line: the comment of its definition, in the same order, as parallel lists
|
|   ::dup | a -- a a ; duplicate top of stack     <- source code (the comment is the help line)
|   #h_r3_lib_rand.r3 "-- rand ; random number" "a -- b ; ..." 0     <- one string per exported word ("" = no comment)
|   ##helplist 'h_r3_lib_3d.r3 ... 0    <- same order as ##liblist of mlibs.r3
|   ##basehelp "a -- a a ; duplicate TOS" ... 0   <- the base words, same order as r3base (r3map.r3)
|
| the help line of a word is what follows the first | of the line of its definition (after a blank or a tab):
|   ::word | stack effect ; description
| a line that defines more than one word (##a 0 ##b 0 | text) has no help line.
| the base words are described in the table #r3basemov of r3map.r3, one row each:  | NAME effect ; description
|
| run it from the main folder:  r3 r3/d4/metahelp.r3     (the same folders of metabuild.r3)
|
^r3/lib/console.r3
^r3/d4/r3token.r3

#filenamev * 1024
#hl * 2048

|---------------------------
:blank? | c -- 0/1 ; a space or a tab
	32 =? ( drop 1 ; ) 9 =? ( drop 1 ; ) drop 0 ;

:lenl | adr -- n ; length of the line
	0 swap ( c@+ $ff and 1? 13 <>? 10 <>? drop swap 1+ swap ) 2drop ;

:lcpy | adr -- ; the line to hl (2046 chars at most)
	dup lenl 2046 min
	'hl pick2 pick2 cmove
	'hl + 0 swap c! drop ;

:minnz | a b -- m ; the smaller one that is not 0 (0 if none)
	0? ( drop ; ) swap 0? ( drop ; ) swap min ;

:cpos | -- adr/0 ; the comment in hl: the first ' |' or tab '|' after the name ; 0 = none, or another definition comes first
	'hl ( dup c@ $ff and 32 >? drop 1+ ) drop
	dup " |" findstr over "	|" findstr minnz
	over " #" findstr pick2 "	#" findstr minnz
	0? ( drop nip ; )
	over 0? ( 4drop 0 ; ) drop
	over <? ( 3drop 0 ; )
	drop nip ;

:ctext | cpos -- adr ; the text after the |
	2 + ( dup c@ $ff and blank? 1? drop 1+ ) drop ;

:lastblank? | adr n -- adr n 0/1 ; the last char is a blank
	dup 0? ( ; ) drop
	over over 1- + c@ $ff and blank? ;

:trimlen | adr -- n ; length without the blanks at the end
	dup count nip ( lastblank? 1? drop 1- ) drop nip ;

:,qtext | adr n -- ; the text as the content of a string (a tab is a space, a quote is written twice)
	( 1? 1- swap c@+ $ff and 9 =? ( drop 32 ) $22 =? ( dup ,c ) ,c swap ) 2drop ;

|---------------------------
:ghelp | adr -- ; a string with the help line of the exported word
	dup @ $2 nand? ( 2drop ; ) drop | only export
	" """ ,s
	@ dic>name lcpy
	cpos 1? ( ctext dup trimlen ,qtext 0 ) drop
	"""" ,s ;

:genhelp
	mark
	"#h_" ,s 'filenamev ,s
	dic< ( dic> <? dup ghelp 16 + ) drop " 0" ,s
	,nl
	"r3/d4/meta/mhelp.r3" appendmem
	empty ;

:emptyhelp | the list of a library that could not be read: it keeps the order
	mark
	"#h_" ,s 'filenamev ,s " 0" ,s ,nl
	"r3/d4/meta/mhelp.r3" appendmem
	empty ;

:namevirtual | name -- name
	dup 'filenamev strcpy
	'filenamev
	( c@+ 1?
		$2f =? ( $5F pick2 1 - c! )
		drop ) 2drop ;

:makehelp | str --
	mark
	dup namevirtual drop		| name
	dup " | %s " .fprint
	here swap 2dup load		| mem name end
	here =? ( 3drop .bred "no source code." .println emptyhelp empty ; )
	$0d3a0d swap !			| add ":" at end (as metabuild does)
	over only13 'here !
	mark
	r3loadmem
	error 1? ( .bred "ERROR %s" .println drop emptyhelp empty empty ; ) drop
	genhelp
	empty empty
	;

|----------------------------
#folders "r3/lib" "r3/util" 0
#foldern * 1024

| sorted list of the files of a folder (the order of readdir is not fixed in linux)
#fnames * $4000
#fnames> 'fnames
#fidx * $800
#fcnt 0
#xvec 0

:fcopy | name -- start
	fnames> dup >a swap
	( c@+ 1? ca!+ ) 2drop
	0 ca!+ a> 'fnames> ! ;

:fgt? | name i -- name i 1/0 ; fidx[i-1] > name
	0? ( 0 ; )
	dup 1- 3 << 'fidx + @ pick2 cmpstr +? ( drop 1 ; ) drop 0 ;

:finsert | name --
	fcnt
	( fgt? 1? drop
		dup 1- 3 << 'fidx + @ over 3 << 'fidx + !
		1- )
	drop 3 << 'fidx + !
	1 'fcnt +! ;

:fentry | file --
	dup FDIR 1? ( 2drop ; ) drop
	FNAME
	dup ".." = 1? ( 2drop ; ) drop
	dup "." = 1? ( 2drop ; ) drop
	fcopy finsert ;

:scanfolder | "dir" 'vec --	; vec | name --   sorted
	'xvec !
	'fnames 'fnames> ! 0 'fcnt !
|WIN|	"%s//*" sprint
	ffirst 0? ( drop ; )		| not found or empty
	( fentry fnext 1? ) drop
	0 ( fcnt <?
		dup 3 << 'fidx + @ xvec ex
		1+ ) drop ;

:procfile | name --
	'foldern "%s/%s" sprint
	makehelp ;

:folder | "" --
	'procfile scanfolder ;

|-------------
:procfilelist | name --
	'foldern "%s/%s" sprint
	namevirtual drop
	" 'h_" ,s 'filenamev ,s
	;

:folderlist	| "" --
	'procfilelist scanfolder ;

|------------- the base words: the rows of #r3basemov in r3map.r3
#maptext 0

:nextl | adr -- adr' ; start of the next line
	>>cr c@+ $ff and
	0? ( drop 1- ; )
	13 =? ( drop dup c@ $ff and 10 =? ( drop 1+ ; ) drop ; )
	drop ;

:grow | adr -- ; the help line of a row: | NAME effect ; description (the .lits .lit ... rows have no name)
	lcpy
	'hl "|" findstr 0? ( drop ; )
	1+ ( dup c@ $ff and blank? 1? drop 1+ ) drop
	dup c@ $ff and $2e =? ( 2drop ; ) drop		| .name = not a word
	( dup c@ $ff and 32 >? drop 1+ ) drop		| the name
	( dup c@ $ff and blank? 1? drop 1+ ) drop
	" """ ,s dup dup trimlen ,qtext drop """" ,s ;

:genbase
	mark
	"##basehelp" ,s
	here dup "r3/d4/r3map.r3" load 0 swap c! 'maptext !
	maptext "#r3basemov (" findstr 0? ( drop " 0" ,s ,nl "r3/d4/meta/mhelp.r3" appendmem empty ; )
	nextl
	( dup c@ $ff and $29 <>? 1? drop
		dup grow nextl )
	2drop
	" 0" ,s ,nl
	"r3/d4/meta/mhelp.r3" appendmem
	empty ;

|-------------
:main
	.cls
	"help generator" .println
	mark
	"| mhelp - help line of the words: generated by metahelp.r3 from the source code" ,s ,nl
	"| ##helplist: same order as ##liblist (mlibs.r3) ; ##basehelp: same order as the base words (r3map.r3)" ,s ,nl
	"r3/d4/meta/mhelp.r3" savemem 
	empty

	'folders ( dup c@ 1? drop
		dup 'foldern strcpy
		dup ">> %s " .cr .println
		dup folder
		>>0 ) 2drop
	.cr

	mark
	,nl
	"##helplist" ,s
	'folders ( dup c@ 1? drop
		dup 'foldern strcpy
		dup folderlist
		>>0 ) 2drop
	" 0" ,s ,nl
	"r3/d4/meta/mhelp.r3" appendmem
	empty

	genbase
	"done" .println
	;

: main ;
