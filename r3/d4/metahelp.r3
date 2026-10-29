| metahelp - the help text of the words: r3/d4/meta/mhelp.txt  (the same folder of mlibs.r3)
| PHREDA 2023
|
| mhelp.txt has one line for each word, in this order: the base words (the order of r3base in r3map.r3),
| then the exported words of the libraries (the folders and the order of metabuild.r3, so the order of mlibs.r3):
|
|   dup | a -- a a ; duplicate TOS               <- name | comment of the definition (no comment: only the name)
|
| the number of a word is the number of its line: nothing has to be searched (see helptxt.r3, that loads it
| with a direct index). the first word of a library is the number of base words + the words of the libraries before.
|
| the help line of a word is what follows the first | of the line of its definition (after a blank or a tab):
|   ::word | stack effect ; description
| a line that defines more than one word (##a 0 ##b 0 | text) has no help line.
| the base words are described in the table #r3basemov of r3map.r3, one row each:  | NAME effect ; description
|
| run it from the main folder, after metabuild.r3 (it has to use the same libraries):  r3 r3/d4/metahelp.r3
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

:,txt | adr n -- ; the text (a tab is a space)
	( 1? 1- swap c@+ $ff and 9 =? ( drop 32 ) ,c swap ) 2drop ;

:,help | adr n -- ; ' | text' if there is text
	1? ( " | " ,s ,txt ; ) 2drop ;

:,name | p -- ; the name
	( dup c@ $ff and 32 >? ,c 1+ ) 2drop ;

:low | c -- c ; lowercase (only A to Z: tolow changes [ and ] too)
	65 <? ( ; ) 90 >? ( ; ) 32 + ;

:,lname | p -- ; the name in lowercase
	( dup c@ $ff and 32 >? low ,c 1+ ) 2drop ;

|---------------------------
:ghelp | adr -- ; the line of an exported word: name | comment
	dup @ $2 nand? ( 2drop ; ) drop | only export
	@ dic>name dup ,name lcpy
	cpos 1? ( ctext dup trimlen ,help 0 ) drop
	,nl ;

:genhelp
	mark
	dic< ( dic> <? dup ghelp 16 + ) drop
	"r3/d4/meta/mhelp.txt" appendmem
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
	here =? ( 3drop .bred "no source code." .println empty ; )
	$0d3a0d swap !			| add ":" at end (as metabuild does)
	over only13 'here !
	mark
	r3loadmem
	error 1? ( .bred "ERROR %s" .println empty empty ; ) drop
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

|------------- the base words: the rows of #r3basemov in r3map.r3
#maptext 0

:nextl | adr -- adr' ; start of the next line
	>>cr c@+ $ff and
	0? ( drop 1- ; )
	13 =? ( drop dup c@ $ff and 10 =? ( drop 1+ ; ) drop ; )
	drop ;

:grow | adr -- ; a row: | NAME effect ; description  (the .lits .lit ... rows have no name)
	lcpy
	'hl "|" findstr 0? ( drop ; )
	1+ ( dup c@ $ff and blank? 1? drop 1+ ) drop
	dup c@ $ff and $2e =? ( 2drop ; ) drop		| .name = not a word
	dup ,lname
	( dup c@ $ff and 32 >? drop 1+ ) drop		| the name
	( dup c@ $ff and blank? 1? drop 1+ ) drop
	dup dup trimlen ,help drop
	,nl ;

:genbase | the first lines of the file
	mark
	here dup "r3/d4/r3map.r3" load 0 swap c! 'maptext !
	maptext "#r3basemov (" findstr 0? ( drop "r3/d4/meta/mhelp.txt" savemem empty ; )
	nextl
	( dup c@ $ff and $29 <>? 1? drop
		dup grow nextl )
	2drop
	"r3/d4/meta/mhelp.txt" savemem
	empty ;

|-------------
:main
	.cls
	"help generator" .println
	genbase
	'folders ( dup c@ 1? drop
		dup 'foldern strcpy
		dup ">> %s " .cr .println
		dup folder
		>>0 ) 2drop
	.cr
	"done" .println
	waitesc
	;

: main ;
