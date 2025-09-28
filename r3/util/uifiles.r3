| UI
| PHREDA 2025

^r3/util/ui.r3

##uiDirs
##uiFiles

#basepath * 1024
#stckhdd>
#l1 0 #l2 0 

::uiTreePath | n -- str
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
	,s |" " ,s
|	dup FSIZEF 12 >> ,d " Kb" ,s
|	dup FDIR ,d
	|dup FWRITEDT dt>64 ,64>dtf
	drop 
	0 ,c ;
	
::uiGetFiles | filename -- | file2list
	mark uiFiles 'here !
|WIN|	"%s//*" sprint
	ffirst ( +file
		fnext 1? ) drop 
	0 , 
	empty ;
	
::uiScanDir | "" --
	here 'uiDirs !
	0 'basepath !
	here $ffff + 'stckhdd> ! 
	0 swap scand 0 , 
	here 'uiFiles !
	$ffff + 'here +!
	;
	
