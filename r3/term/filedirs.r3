| GetFolders and Files from every folder
| PHREDA 2025

| reseve memory with
|::flScanDir | "path" -- | only load one time!
| load filenames with
|::FlGetFiles | "path\file" -- | reload for every folder when need
|
|##uiDirs | list for tree widget
|##uiFiles	| list for list widget
|

^r3/lib/mem.r3
^r3/util/datetime.r3
^r3/util/tui.r3

|--------------------------------	
##uiDirs
##uiFiles

#basepath * 1024

#stckhdd>
#l1 0 #l2 0 

::flcpy | 'file 'str --
	( swap c@+ 1?
		$7c =? ( 2drop 0 swap c! ; )
|	 	$5e =? ( 2drop 0 swap c! ; ) | ^
		rot c!+ ) nip swap c! ;
		
::flTreePath | n -- str
	ab[
	here 1024 + dup >b >a
	mark
	( dup uiNindx c@+ $1f and 
		swap a!+ 1? 'l1 ! 
		( 1- dup uiNindx c@ $1f and 
			l1 >=? drop ) drop
		) 2drop
	|a> 8 - ( b> >=? dup @ ,s  "/" ,s 8 - ) drop
	a> 8 - ( b> >=? dup @ ,s  8 - ) drop
	0 ,c
	empty here 
	]ba ;
	
	
|------ folders for tree
:backdir | -- ;  2 '/' !!
	0 'l1 !
	'basepath ( c@+ 1? 
		$2f =? ( l1 'l2 ! over 'l1 ! )
		drop ) 2drop
	0 l2 1? ( c! ; ) 2drop ;	

:pushdd | --
	stckhdd> findata 
|WIN|	520 
|LIN|	8
	cmove |dsc
|WIN|	520 
|LIN|	8
	'stckhdd> +! ;
	
:pophdd
|WIN|	-520 
|LIN|	-8
	'stckhdd> +!
	findata stckhdd>
|WIN|	520 
|LIN|	8
	cmove ;

:dir.?
	dup fname 
	dup "." = 1? ( 2drop 0 ; ) drop
	dup ".." = 1? ( 2drop 0 ; ) drop
	drop
	dup fdir ;
	
:scand | level "" --
	'basepath strcat "/" 'basepath strcat
	'basepath 
|WIN| "%s/*" sprint
	ffirst 0? ( drop ; ) |drop fnext drop 
	( dir.? 1? (
		pushdd
|		pick2 64 + .emit over fname .write .cr
		pick2 64 + ,c over fname ,s 0 ,c
		pick2 1+ pick2 fname scand
		pophdd
		) 2drop
	fnext 1? ) 2drop 	
	backdir ;

|----- Files
:+file | f --
	dup FDIR 1? ( 2drop ; ) drop | nodirs
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	,s 
|	"|" ,s dup FSIZEF $300 + 10 >> ,d " Kb" ,s
|	"|" ,s dup FWRITEDT dt>64 ,64>dtf 
	drop 
	0 ,c ;
	
::FlGetFiles | filename --
	mark uiFiles 'here !
|WIN|	"%s//*" sprint
	ffirst ( +file fnext 1? ) drop 0 , 
	empty ;
	
|----------------	

::flScanDir | "" --
	here 'uiDirs !
	0 'basepath !
	here $ffff + 'stckhdd> ! 
	0 swap scand 0 , 
	here 'uiFiles !
	$ffff + 'here +!
	;
|-------------
:writefname | level fd -- level fd 1/0
	dup fname 
	dup "." = 1? ( 2drop 0 ; ) drop
	dup ".." = 1? ( 2drop 0 ; ) drop
	pick2 64 + ,c ,s 
	dup fdir 1? ( "/" ,s )
	0 ,c ;
	
:scandf | level "" --
	'basepath strcat "/" 'basepath strcat
	'basepath 
|WIN| "%s/*" sprint
	ffirst 0? ( drop ; ) |drop fnext drop 
	( writefname
		1? ( pushdd
			pick2 1+ pick2 fname scandf
			pophdd 	)
		2drop
		fnext 1? ) 2drop 	
	backdir ;


::flScanFullDir | "" --
	here 'uiDirs !
	0 'basepath !
	here $ffff + 'stckhdd> ! 
	0 swap scandf 0 , 
	;
	
|--------------	
#lvl	|  $1f:level $20:have_more $80:is_open	

:traverselevel	| adr -- adr
	dup c@ 
	$80 and? ( drop >>0 ; ) | open
	$1f and 'lvl ! 
	( >>0 dup c@ 1? 
		$1f and lvl >? drop )
	drop ;
	
:searchtree | list --
	0 'lvl ! 0 >b
	uiDirs ( a> <? 
		traverselevel
		1 b+ ) drop
	b> ;

:findh | str -- ; a:uidir
	a> ( dup c@ 1? drop
		dup here = 1? ( drop >a drop ; ) drop
		>>0 ) 
	3drop 0 ;
	
:find/
	mark b> 64 + ,c dup ,s "/" ,s ,eol empty
	findh ;
	
:findl
	mark b> 64 + ,c dup ,s ,eol	empty
	findh ;

:next/ | adr -- adr'
	( c@+ 1?
		$2f =? ( drop 0 swap 1- c!+ ; )
		drop ) nip ;
	
::flOpenFullPath | str -- place ; open the folders
	ab[
	uiDirs >a 0 >b
	next/ 0? ( ; ) 
	( dup next/ 1? swap
		dup find/ 0? ( nip nip ; ) drop
		a> c@ $80 or a> c! | open dir
		1 b+ ) drop 
	findl drop | last name
	searchtree
	]ba ;

