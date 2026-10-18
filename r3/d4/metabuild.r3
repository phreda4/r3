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
^r3/lib/console.r3
^r3/d4/r3token.r3

|---------------------------
#filenamev * 1024

:,wordstr | adr --
	( c@+ $ff and 32 >? 
		$22 =? ( dup ,c )
		,c	) 2drop ;
		
:gname | adr --
	dup @ $2 nand? ( 2drop ; ) drop | only export
	" """ ,s @ dic>name ,wordstr """" ,s ;

:gvector | adr --
	dup @ $2 nand? ( 2drop ; ) drop | only export
	@ dic>name " '%w" ,print ;

#flag 
:ginfo | adr --
	dup @ $2 nand? ( 2drop ; )  | only export
	0 'flag !
	1 and? ( $80 'flag +! ) | data?
	drop
	8 + @ 
	dup $7 and 4 << 'flag +!  | uso ($ff in info2)
	8 >> $f and 'flag +! | delta ($ff00 in info2, low 4 bits)
	flag " $%h" ,print
	;

:genlib
	mark
	"^" ,s 'filename ,s ,nl
	"#name """ ,s 'filename ,s """" ,s
	,nl
	"#words " ,s
	dic< ( dic> <? dup gname 16 + ) drop " 0" ,s 
	,nl
	"#calls " ,s
	dic< ( dic> <? dup gvector 16 + ) drop 
	,nl
	"#info (" ,s
	dic< ( dic> <? dup ginfo 16 + ) drop 
	" )" ,s 
	,nl
	"#" ,s 'filenamev ,s " 'name 'words 'calls 'info" ,s 
	,nl
	"r3/d4/meta/metalibs.r3" appendmem
	empty ;

:genlibnocall
	mark
|	"^" ,s 'filename ,s ,nl
	"#name """ ,s 'filename ,s """" ,s
	,nl
	"#words " ,s
	dic< ( dic> <? dup gname 16 + ) drop " 0" ,s 
	,nl
|	"#calls " ,s
|	dic< ( dic> <? dup gvector 16 + ) drop 
|	,nl
	"#info (" ,s
	dic< ( dic> <? dup ginfo 16 + ) drop 
	" )" ,s 
	,nl
	"#" ,s 'filenamev ,s " 'name 'words 'info" ,s 
	
	" 0" ,s				| (reserved: help line in manual, helplib.r3)
	,nl
	"r3/d4/meta/mlibs.r3" appendmem
	empty ;

:namevirtual | name -- name
	dup 'filenamev strcpy
	'filenamev
	( c@+ 1?
		$2f =? ( $5F pick2 1 - c! )
		drop ) 2drop ;
	
::makelib | str --
	mark
	dup namevirtual drop		| name
	dup " | %s " .fprint
	here swap 2dup load		| mem name end
	here =? ( 3drop .bred "no source code." .println empty ; )
	$0d3a0d swap !				| add ":" at end: r3token close the last word only when a new def start
	over only13 'here !
	mark
	r3loadmem				| tokenize + static analysis
	error 1? ( .bred "ERROR %s" .println empty empty ; ) drop
	genlib
	genlibnocall
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
	makelib  ;

:folder | "" --
	'procfile scanfolder ;
	
|-------------	
:procfilelist | name --
	'foldern "%s/%s" sprint 
	namevirtual drop
	" '" ,s 'filenamev ,s 
	;
	
:folderlist	| "" --
	'procfilelist scanfolder ;

|-------------	
:main
	.cls
	
	"library generator" .println
	mark "r3/d4/meta/metalibs.r3" savemem empty 
	mark "r3/d4/meta/mlibs.r3" savemem empty 
	'folders ( dup c@ 1? drop 
		dup 'foldern strcpy
		dup ">> %s " .cr .println
		dup folder
		>>0 ) 2drop
	.cr

	mark
	,nl
	"##liblist" ,s 
	'folders ( dup c@ 1? drop 
		dup 'foldern strcpy
		dup folderlist
		>>0 ) 2drop
	" 0" ,s ,nl
	"r3/d4/meta/metalibs.r3" appendmem		
	"r3/d4/meta/mlibs.r3" appendmem		
	empty 
	;

: main "any key to continue." .print waitkey ;