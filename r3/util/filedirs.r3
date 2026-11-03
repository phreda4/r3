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
##uiDirs | list of folders (or full tree) of flScanDir/flScanFullDir: 0-terminated entries, each one a byte $40+level ($20 more, $80 open) and the name; it ends with an empty entry
##uiFiles | list of the files of a folder made by FlGetFiles: 0-terminated names that end with an empty entry

#basepath * 1024

#stckhdd>
#l1 0 #l2 0 

::flcpy | 'file 'str -- ; copy a list entry up to | or the final 0 into 'str, with a final 0
	( swap c@+ 1?
		$7c =? ( 2drop 0 swap c! ; )
|	 	$5e =? ( 2drop 0 swap c! ; ) | ^
		rot c!+ ) nip swap c! ;
		
::flTreePath | n -- str ; path of node n of the tree shown by the tui tree widget (it uses the widget state of tui: only meaningful inside it)
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
|MAC|	8
	cmove |dsc
|WIN|	520 
|LIN|	8
|MAC|	8
	'stckhdd> +! ;
	
:pophdd
|WIN|	-520 
|LIN|	-8
|MAC|	-8
	'stckhdd> +!
	findata stckhdd>
|WIN|	520 
|LIN|	8
|MAC|	8
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
	
::FlGetFiles | "path" -- ; fill uiFiles with the names of the files (no folders) of the folder; the memory was reserved by flScanDir
	mark uiFiles 'here !
|WIN|	"%s//*" sprint
	ffirst ( +file fnext 1? ) drop 0 , 
	empty ;
	
|----------------	

::flScanDir | "path" -- ; scan the folders under path recursively into uiDirs and reserve 64 KB for uiFiles; call it only once
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


::flScanFullDir | "path" -- ; like flScanDir but uiDirs also has the files (the folders end with /)
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
	
::flOpenFullPath | "root/a/b" -- place ; open the folders of a path in the uiDirs list of flScanFullDir (the first component, the root, is skipped; the string is modified); returns the row of the last entry in the visible tree
	ab[
	uiDirs >a 0 >b
	next/ 0? ( ]ba ; ) 
	( dup next/ 1? swap
		dup find/ 0? ( nip nip ]ba ; ) drop
		a> c@ $80 or a> c! | open dir
		1 b+ ) drop 
	findl drop | last name
	searchtree
	]ba ;

#ancestors * 256	| scratch: 32 niveles posibles

::flOpenSearch | "text" -- adr/0 ; first entry of uiDirs that contains the text (ignoring case): its folders are opened and its address is returned; 0 if not found
	uiDirs
	( dup c@ 1? 
		$1f and 3 << 'ancestors + over swap !
		dup 1+ pick2 findstri 
		1? ( drop 
			dup c@ $1f and
			( 1? 1-
				dup 3 << 'ancestors + @
				dup c@ $80 or swap c!
				) drop nip ; 
			) drop
		>>0	) 3drop 0 ;

::flCloseAll | -- ; close all the folders of uiDirs
	uiDirs
	( dup c@ 1? 
		$7f and over c!
		>>0 ) 2drop ;