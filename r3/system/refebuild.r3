| PHREDA 2023
| build reference r3
| Generate reference to library
|
^r3/lib/win/console.r3
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
|	"^" ,s 'r3filename ,s ,cr
	"#name """ ,s 'r3filename ,s """" ,s
	,cr
	"#words " ,s
	dicc< ( dicc> <? dup gname 32 + ) drop " 0" ,s 
	,cr
|	"#calls " ,s
|	dicc< ( dicc> <? dup gvector 32 + ) drop 
|	,cr
	"#info (" ,s
	dicc< ( dicc> <? dup ginfo 32 + ) drop 
	" )" ,s 
	,cr
	"#" ,s 'filenamev ,s " 'name 'words 'info" ,s 
	,cr
	"r3/system/meta/refelibs.r3" appendmem
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
	'r3filename dup "load %s " .println
	namevirtual	| mem fn
	load here =? ( drop "no source code." .println empty ; )
	0 swap c!+ 'here !
	0 'error ! 0 'cnttokens ! 0 'cntdef !
	'inc 'inc> !
	src 
	r3-stage-1 
	error 1? ( 4drop "ERROR %s" .println ; ) drop
|	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println
	r3-stage-2 |drop
	1? ( "ERROR %s" .println empty ; ) drop
|	code> code - 2 >> "tokens:%d" .println
|	r3-stage-3 | core.r3 fail!! (need inv)
	r3-stage-4-full
	genlib
	empty
	;

|----------------------------
#folders "r3/lib" "r3/util" "r3/win" 0
#foldern * 1024

:nextfile | file --
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
	mark "r3/system/meta/refelibs.r3" savemem empty 
	'folders ( dup c@ 1? drop 
		dup 'foldern strcpy
		dup ">> %s" .println
		dup folder
		>>0 ) 2drop
	"end" .println

	mark
	,cr
	"##liblist" ,s 
	'folders ( dup c@ 1? drop 
		dup 'foldern strcpy
		dup folderlist
		>>0 ) 2drop
	" 0" ,s ,cr
	"r3/system/meta/refelibs.r3" appendmem		
	empty ;

: main ;