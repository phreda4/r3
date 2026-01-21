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
^r3/system/r3base.r3
^r3/system/r3pass1.r3
^r3/system/r3pass2.r3
^r3/system/r3pass3.r3
^r3/system/r3pass4.r3
|---------------------------

#filenamev * 1024

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

:genlibnocall
	mark
|	"^" ,s 'r3filename ,s ,nl
	"#name """ ,s 'r3filename ,s """" ,s
	,nl
	"#words " ,s
	dicc< ( dicc> <? dup gname 32 + ) drop " 0" ,s 
	,nl
|	"#calls " ,s
|	dicc< ( dicc> <? dup gvector 32 + ) drop 
|	,nl
	"#info (" ,s
	dicc< ( dicc> <? dup ginfo 32 + ) drop 
	" )" ,s 
	,nl
	"#" ,s 'filenamev ,s " 'name 'words 'info" ,s 
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
	r3name
	mark
	here dup 'src ! | mem
	'r3filename dup " | %s " .fprint |ln
	namevirtual	| mem fn
	load here =? ( drop .bred "no source code." .println empty ; )
	0 swap c!+ 'here !
	0 'error ! 0 'cnttokens ! 0 'cntdef !
	'inc 'inc> !
	src 
	r3-stage-1 
	error 1? ( 4drop .bred "ERROR %s" .println ; ) drop
|	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println
	r3-stage-2 |drop
	1? ( .bred "ERROR %s" .println empty ; ) drop
|	code> code - 2 >> "tokens:%d" .println
|	r3-stage-3 | core.r3 fail!! (need inv)
	r3-stage-4-full
	genlib
	genlibnocall
	empty
	;

|----------------------------
#folders "r3/lib" "r3/util" 
|WIN|"r3/lib/win"
|LIN|"r3/lib/posix"
 0
#foldern * 1024

:nextfile | file --
	dup FDIR 1? ( 2drop ; ) drop
	FNAME
	dup ".." = 1? ( 2drop ; ) drop
	dup "." = 1? ( 2drop ; ) drop
	'foldern "%s/%s" sprint 
	makelib  ;
	
:folder | "" --
	"%s//*" sprint ffirst 
	( nextfile fnext 1? ) drop ;
	
|-------------	
:nextfilelist | file --
	dup FDIR 1? ( 2drop ; ) drop
	FNAME
	dup ".." = 1? ( 2drop ; ) drop
	dup "." = 1? ( 2drop ; ) drop
	'foldern "%s/%s" sprint 
	namevirtual drop
	" '" ,s 'filenamev ,s 
	;
	
:folderlist	| "" --
	"%s//*" sprint ffirst 
	( nextfilelist fnext 1? ) drop ;

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