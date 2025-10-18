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
^./tui.r3

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
	a> 8 - ( b> >=? dup @ ,s  "/" ,s 8 - ) drop
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
:next/ | adr -- adr'
	( c@+ 1?
		$2f =? ( drop 0 swap 1- c!+ ; )
		drop ) nip ;

:searchd |  nro 'list -- 'list+ nro
	( dup c@ 1? drop | nro 'list
		dup a> ">>%s %s" .fprintln waitkey
		
		dup a> = 1? ( | nro 'list =?
			drop swap ; ) drop
		swap 1+ swap >>0 ) 
	2drop -1 dup ;

::flSearchDir | 'str -- n
	next/ | r3/
	0 uiDirs	| 'str nro 'list
	rot 		| nro 'list 'str
	( dup next/ 1? | nro 'list 'str 'str+
		>r >a  	| nro 'list 
		searchd | 'list nro
		-? ( nip ; ) 
		swap r>
		) 3drop ;
	
::flScanDir | "" --
	here 'uiDirs !
	0 'basepath !
	here $ffff + 'stckhdd> ! 
	0 swap scand 0 , 
	here 'uiFiles !
	$ffff + 'here +!
	;
