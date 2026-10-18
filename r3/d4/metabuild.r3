| meta r3
| PHREDA 2023
| Generate virtual call to library
|
|##seed8 12345 | 
|::rand8 | -- r8
|##seed $a3b195354a39b70d
|::rand | -- rand
|::rerand | s1 s2 --
|::randmax | max -- rand
|::rnd | -- rand
|::rndmax | max -- rand
|::rnd128 | -- n
|
| info (0data/code 000use 0000deltad)
| build memory map, check access and bound
|----------------------------------------
| ^lib/rand.r3
|
| #name "lib/rand.r3"
| #words "seed8" "rand8" "seed" "rand" "rerand" "randmax" "rnd" "rndmax" "rnd128" 0
| #info ( $80 $01 $80 $01 $2e $10 $01 $10 $01 )
| #call seed8 rand8 seed rand rerand randmax rnd rndmax rnd128 0
| ##lib_rand.r3 'name 'words 'info 'call
|
| PHREDA 2026 ;; add 'manual por
^r3/lib/console.r3
^r3/system/r3base.r3
^r3/system/r3pass1.r3
^r3/system/r3pass2.r3
^r3/system/r3pass3.r3
^r3/system/r3pass4.r3

|---------------------------
#filenamev * 1024

#manual
#imanual
#cmanual

:searchmanual | 'name -- pos-manual
|	DUP ">>%s<<" .PRINTln
	0 ( cmanual <?
		dup 2 << imanual + d@ manual + | position
		4 + | skip ###_
		pick2 swap = 1? ( drop nip ; )
		drop
		1+ ) 2drop
	0 ;


:last_ | str -- str' 
	count + 
	( 1- dup c@ $5f <>? drop ) 
	drop 1+ ;
	
:,wordstr | adr --
	( c@+ $ff and 32 >? 
		$22 =? ( dup ,c )
		,c	) 2drop ;
		
:gname | adr --
	dup 16 + @ $2 nand? ( 2drop ; ) drop | only export
	" """ ,s @ ,wordstr """" ,s ;

:gvector | adr --
	dup 16 + @ $2 nand? ( 2drop ; ) drop | only export
	@ " '%w" ,print ;

#flag 
:ginfo | adr --
	dup 16 + @ $2 nand? ( 2drop ; )  | only export
	0 'flag !
	1 and? ( $80 'flag +! ) | data?
	drop
	24 + @ 
	dup $7 and 4 << 'flag +!  | uso ($f in ana)
	4 >> $f and 'flag +! | 55 << 59 >> ; delta ($1f0 in ana)
	flag " $%h" ,print
	;

:genlib
	mark
	"^" ,s 'r3filename ,s ,nl
	"#name """ ,s 'r3filename ,s """" ,s
	,nl
	"#words " ,s
	dicc< ( dicc> <? dup gname 32 + ) drop " 0" ,s 
	,nl
	"#calls " ,s
	dicc< ( dicc> <? dup gvector 32 + ) drop 
	,nl
	"#info (" ,s
	dicc< ( dicc> <? dup ginfo 32 + ) drop 
	" )" ,s 
	,nl
	"#" ,s 'filenamev ,s " 'name 'words 'calls 'info" ,s 
	,nl
	"r3/d4/meta/metalibs.r3" appendmem
	empty ;

:namevirtual | name -- name
	dup 'filenamev strcpy
	'filenamev
	( c@+ 1?
		$2f =? ( $5F pick2 1 - c! )
		drop ) 2drop ;

|--- mlibs for both systems
| the analyzer is compiled for the host (the lines |WIN| or |LIN| are code).
| the other target is analyzed changing the tags at the start of the lines of
| the source of the lib (the includes of the lib are read as they are).
| mlibs.r3 gets the line of each system only when the data differ:
|   |LIN|#info ( ... )
|   |WIN|#info ( ... )
|WIN|#tagh "|WIN|" #tago "|LIN|" #hostdir "/win/" #otherdir "/posix/"
|LIN|#tagh "|LIN|" #tago "|WIN|" #hostdir "/posix/" #otherdir "/win/"
#tagx "|XXX|"

:poke5 | adr str --
	swap >a
	5 ( 1? 1- swap c@+ ca!+ swap ) 2drop ;

:linefix | adr -- ; adr = start of line
	'tagh =pre 1? ( drop 'tagx poke5 ; ) drop	| host tag -> comment
	'tago =pre 1? ( drop 'tagh poke5 ; ) drop	| other tag -> host tag
	drop ;

:swaptags | adr --
	dup linefix
	( c@+ $ff and 1?
		13 =? ( over linefix )
		10 =? ( over linefix )
		drop ) 2drop ;

:hostlib? | -- 0/1 ; not a lib of the other system
	'r3filename 'otherdir findstr 0? ( drop 1 ; ) drop 0 ;

:ownlib? | -- 0/1 ; lib of the host system (win/ or posix/)
	'r3filename 'hostdir findstr 0? ( drop 0 ; ) drop 1 ;

#wb0 * $10000 #ib0 * $10000	| host: words and info text
#wb1 * $10000 #ib1 * $10000	| other

:gwords | --
	dicc< ( dicc> <? dup gname 32 + ) drop " 0" ,s ;

:ginfos | --
	dicc< ( dicc> <? dup ginfo 32 + ) drop ;

:cpyz | src dst --
	>a ( c@+ 1? ca!+ ) 2drop 0 ca!+ ;

:capture | 'buf 'gen -- ; text written by gen -> buf
	here swap ex 0 ,c
	dup >r swap cpyz r> 'here ! ;

#awb 0 #aib 0 #aoth 0

|--- stage 1 for the other system: same as r3pass1.r3 (includes) but the text of
|    every file is changed with swaptags when it is loaded
:xescom
|WIN|	"WIN|" =pre 1? ( drop 4 + ; ) drop
|LIN|	"LIN|" =pre 1? ( drop 4 + ; ) drop
	"MEM" =pre 1? ( drop
		4 +
		trim str>nro 'switchmem !
		>>cr ; ) drop
	>>cr ;

:xincludepal | str car -- str'
	$7c =? ( drop xescom ; )
	1 'cnttokens +!
	$3A =? ( 1 'cntdef +! )
	$23 =? ( 1 'cntdef +! )
	$28 =? ( over c@ 33 <? ( 1 'cntblk +! ) drop )
	$5b =? ( over c@ 33 <? ( 1 'cntblk +! ) drop )
	$22 =? ( drop >>str ; )
	drop >>sp ;

:xininc? | str -- str adr/0
	'inc ( inc> <?
		@+ pick2 =s 1? ( drop ; ) drop
		8 + ) drop 0 ;

:xrealfilename | str -- str
	"." =pre 0? ( drop "%l" sprint ; ) drop
	2 + 'r3path "%s/%l" sprint ;

:xrtrim | str -- str
	dup ( c@+ 1? drop ) drop 2 -
	( dup c@ $ff and 33 <? drop 1 - ) drop
	0 swap 1 + c! ;

:xload.inc | str -- str new
	here over xrealfilename xrtrim
	dup filexist 0? ( nip
			pick2 'lerror ! 
			"Include not found" 'error !
			; ) drop
	load 0 swap c!
	here aoth 1? ( over swaptags ) drop
	dup only13 'here ! 
	;

:xadd.inc | src here -- src
	over inc> !+ !+ 'inc> ! ;

:xincludes | src --
	dup ( trimcar 1?
		( $5e =? drop
			xininc? 0? ( drop
				xload.inc 0? ( drop ; )
				xincludes
				error 1? ( drop ; ) drop
				dup ) drop
			>>cr trimcar )
		xincludepal ) 2drop
	xadd.inc ;

:xstage1 | src --
	10 'switchmem !
	xincludes
	inc> 'inc - 4 >> 'cntinc ! ;

:stage1 | src --
	aoth 1? ( drop xstage1 ; ) drop r3-stage-1 ;


:sweep | sentinel .. junk -- ; drop junk and the sentinel
	( $5afe5afe <>? drop ) drop ;

:errprint | --
	.bred error " ERROR %s" .print
	lerror 1? ( dup c@ 1? ( drop " at %w" .print ; ) drop ) drop .cr ;

:analyze | -- err
	aoth ">%d " .print .flush		| 0 host / 1 other: the last one shown is the one that crashes
	mark
	here dup 'src ! | mem
	'r3filename namevirtual	| mem fn
	load here =? ( drop .bred "no source code." .println empty 1 ; )
	0 swap c!+ 'here !
	aoth 1? ( src swaptags ) drop
	0 'error ! 0 'cnttokens ! 0 'cntdef !
	'inc 'inc> !
	$5afe5afe src stage1 sweep		| an error leaves junk in the stack
	error 1? ( drop errprint empty 1 ; ) drop
	$5afe5afe r3-stage-2 drop sweep
	error 1? ( drop errprint empty 1 ; ) drop
	r3-stage-4-full
	aoth 0? ( hostlib? 1? ( genlib ) drop ) drop	| metalibs: only the host
	awb 'gwords capture
	aib 'ginfos capture
	empty 0 ;

#dh #d0 #d1 #dt
:,tl | --
	dt 1? ( dup ,s ) drop ,nl ;

:,dual | hd b0 b1 tl --
	'dt ! 'd1 ! 'd0 ! 'dh !
	d0 d1 cmpstr 0? ( drop dh ,s d0 ,s ,tl ; ) drop
	'tagh ,s dh ,s d0 ,s ,tl
	'tago ,s dh ,s d1 ,s ,tl ;

:genlibdual
	mark
	"#name """ ,s 'r3filename ,s """" ,s
	,nl
	"#words " 'wb0 'wb1 0 ,dual
	"#info (" 'ib0 'ib1 " )" ,dual
	"#" ,s 'filenamev ,s " 'name 'words 'info" ,s 
	'filenamev last_
	searchmanual | advance 'r3_lib_'
	" $%h" ,print
	,nl
	"r3/d4/meta/mlibs.r3" appendmem
	empty ;

::makelib | str --
	r3name
	'r3filename " | %s " .fprint |ln
	hostlib? 0? ( drop		| lib of the other system: analyzed only for it
		'wb1 'awb ! 'ib1 'aib ! 1 'aoth !
		analyze 1? ( drop ; ) drop
		'wb1 'wb0 cpyz 'ib1 'ib0 cpyz
		genlibdual ; ) drop
	ownlib? 1? ( drop		| lib of the host system: analyzed only for it
		'wb0 'awb ! 'ib0 'aib ! 0 'aoth !
		analyze 1? ( drop ; ) drop
		'wb0 'wb1 cpyz 'ib0 'ib1 cpyz
		genlibdual ; ) drop
	'wb0 'awb ! 'ib0 'aib ! 0 'aoth !
	analyze 1? ( drop ; ) drop			| host
	'wb1 'awb ! 'ib1 'aib ! 1 'aoth !
	analyze 1? ( 'wb0 'wb1 cpyz 'ib0 'ib1 cpyz ) drop	| other: if fails, same as host
	genlibdual ;

|----------------------------
#folders "r3/lib" "r3/util" "r3/lib/win" "r3/lib/posix" 0
#foldern * 1024

| sorted list of the files of a folder (the order of readdir is not fixed in linux)
#fnames * $4000
#fnames> 'fnames
#fidx * $800
#fcnt 0
#xvec 0
#si 0

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
	0 'si !
	( si fcnt <? drop
		si 3 << 'fidx + @ xvec ex
		1 'si +! ) drop ;

:procfile | name --
	'foldern "%s/%s" sprint 
	makelib  ;

:folder | "" --
	'procfile scanfolder ;
	
|-------------	
#lfile 0
#hostonly 0	| 1 = list without the libs of the other system (metalibs)

:procfilelist | name --
	'foldern "%s/%s" sprint 
	hostonly 1? ( over 'otherdir findstr 1? ( 3drop ; ) drop ) drop
	namevirtual drop
	" '" ,s 'filenamev ,s 
	;
	
:folderlist	| "" --
	'procfilelist scanfolder ;

|-------------	
| collect #### lib.r3 
:parsemanual | adr -- 
	( dup c@ $ff and? drop
		dup manual - da!+
		( c@+ 13 <>? drop ) drop
		) 2drop ;
	
	
:genliblist | "file" hostonly --
	'hostonly !
	'lfile !
	mark
	,nl
	"##liblist" ,s 
	'folders ( dup c@ 1? drop 
		dup 'foldern strcpy
		dup folderlist
		>>0 ) 2drop
	" 0" ,s ,nl
	lfile appendmem
	empty ;

:main
	.cls
	
	"loading manual.." .println
	mark
	here dup 'manual !
	"doc/r3forth-manual.md" load 0 swap c!
	here only13 0 swap c!+
	dup >a 'imanual !
	manual parsemanual
	a> dup imanual - 2 >> 'cmanual !
	'here !
	
	cmanual "%d entry libs" .println .cr
	
	
	"library generator" .println
	mark "r3/d4/meta/metalibs.r3" savemem empty 
	mark "r3/d4/meta/mlibs.r3" savemem empty 
	'folders ( dup c@ 1? drop 
		dup 'foldern strcpy
		dup ">> %s " .cr .println
		dup folder
		>>0 ) 2drop
	.cr

	"r3/d4/meta/metalibs.r3" 1 genliblist	| only the host
	"r3/d4/meta/mlibs.r3" 0 genliblist	| both systems
	;

: main "any key to continue." .print waitkey ;