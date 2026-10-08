| start program
| PHREDA 2025
|---------------
^r3/util/tui.r3
^r3/util/tuiedit.r3
^r3/util/filedirs.r3

|^r3/lib/trace.r3

|--------------------------------	
#basepath "r3/"
#fullpath * 1024

#nameaux * 1024

#vfolder 0 0

|---------------------
:loadm
	'nameaux "mem/menu.mem" load
	'nameaux =? ( drop ; )
	'nameaux dup c@ 0? ( 2drop ; ) drop
	dup 'fullpath strcpy
	flOpenFullPath 'vfolder !
	'fullpath 
	".r3" =pos 1? ( drop TuLoadCode ; ) 
	2drop
	tuNewCode ;	

:savem
	'fullpath 1024 "mem/menu.mem" save ;

:reloadir
	empty mark
	'basepath flScanFullDir ;

|---------------------------
:banner
	.cls "[01R[023[03f[04o[05r[06t[07h" .awrite .cr .cr .cr .cr .flush ;
	
:runcheck
	banner
	here dup "error.log" load
	over =? ( 2drop ; ) 
	0 swap c!
	.cr .bred .white " * ERROR * " .write .cr
	.reset .write .cr
	.bblue .white " Any key to continue... " .write .cr
	.flush 
	waitkey 
	"error.log" delete
	;

:filerun
	fuente c@ 0? ( drop ; ) drop
	banner
	savem
	'fullpath r3run
	.reterm .alsb .flush
	runcheck
	tuR! ;
	
:fileedit	
	fuente c@ 0? ( drop ; ) drop
	.masb .flush
	savem
	"r3/d4/r3ide.r3" r3run
	.reterm .alsb .flush tuR! ;

:remfilename | str --
	count
	swap over + | count 'fnla
	( 1- dup c@ 
		$2f =? ( drop 0 swap c! drop ; )
		drop swap 1- 1?
		swap ) 2drop ;

:addext | str --
	".r3" =pos 1? ( drop ; ) drop
	".r3" swap strcat
	;

|===================================
#newsdl "| r3 sdl program
^r3/lib/sdl2gfx.r3
	
:main
	0 cls
	$ff00 color
	10 10 100 100 frect
	SDLredraw
	
	SDLkey 
	>esc< =? ( exit )
	drop ;

:
	""r3sdl"" 800 600 SDLinit
	'main SDLshow
	SDLquit 
;"
|===================================
	
:filenew
	8 .bc 15 .fc 
	0 rows 1- .at 
	" Name: " .write .eline .input
	'pad trim c@ 0? ( drop ; ) drop
	'fullpath remfilename
	'pad addext
	'pad 'fullpath "%s/%s" sprint 'fullpath strcpy

	'fullpath filexist 1? ( drop 
		15 .fc 1 .bc " ** FILE EXIST **" .write waitkey ; ) drop

	mark
	'newsdl ,s
	'fullpath savemem
	empty
	
	32 fuente c! | for enter edit
	fileedit
	reloadir
	loadm
	tuR! ;
	
:filesearch
	8 .bc 15 .fc 
	0 rows 1- .at 
	" ? " .write .eline .input 
	'pad trim
	dup c@ 0? ( 2drop ; ) drop
	flCloseAll
	flOpenSearch 0? ( drop ; ) 
	uiDirs swap flVisibleIndex
	-1 =? ( drop ; ) 'vfolder ! 
	tuR! ;

:filedelete
	fuente c@ 0? ( drop ; ) drop	
	15 .fc 1 .bc
	0 rows 1- .at 
	" !! " .write 'filename .write	
	" !! DELETE ? (Y/N) " .write .eline
	getch tolow
	$79 <>? ( drop ; ) drop
	'filename delete | "filename" --
	'filename remfilename
	'filename 'fullpath strcpy
	savem
	reloadir
	loadm
	tuR! ;
	
|------------
:paneleditor
	fuente c@ 0? ( drop ; ) drop
	|tuwin $1 'fullpath .wtitle
	fx fy .at 
	8 .bc 15 .fc .sp 'fullpath .write .eline
	1 'fy +! -1 'fh +!
	|1 1 flpad 
|	tuEditCode
	tuReadCode
	;
	
|------------
:changefiles
	vfolder flTreePath
	'basepath 'fullpath strcpyl 1- strcpy
	'fullpath c@ 0? ( drop tuNewCode ; ) drop |
	'fullpath 
	".r3" =pos 1? ( drop TuLoadCode ; ) 
	2drop
	tuNewCode ;
	
:setcolor | str -- str
	"/" =pos 1? ( drop 7 .fc ; ) drop
	".r3" =pos 1? ( drop 11 .fc ; ) drop	
	14 .fc ;
	
:filecolor	
	setcolor lwrite ;
	
:dirpanel
	.reset
	'filecolor xwrite!
	tuwin $1 "" .wtitle
	1 1 flpad 
	'vfolder uiDirs tuTree
	xwrite.reset
	tuX? 1? ( changefiles ) drop
	;

#tk
|------------	
:scrmain
	.bblack .cls
	
	|___________
	4 flxN
	fx fy .at "[01R[023[03f[04o[05r[06t[07h" .awrite 
	|.tdebug |2dup " %d %d " .print
	|tk "%h" .print 'fullpath .write
	8 .bc 15 .fc 
	3 flxS
	fx fy .at .eline .cr .sp
	.rev " H" .write .nrev "elp  " .write 
	.rev " R" .write .nrev "un  " .write 
	.rev " E" .write .nrev "dit  " .write 
	.rev " N" .write .nrev "ew  " .write 
	.rev " /" .write .nrev "Search  " .write 
	.eline .cr
	.eline
	|___________
	38 flxO
	dirpanel
	|___________
	flxRest	
	paneleditor

	uikey
|	[f2] =? ( help )		| H

	[f5] =? ( filerun )
	[ENTER] =? ( filerun )
	
	[f6] =? ( fileedit )
	$20 =? ( fileedit )
	$2f =? ( filesearch )
	toUpp
|	$43 =? ( fileclon )	| Clon	
	$44 =? ( filedelete ) | Delete
	$45	=? ( fileedit )	| Edit
	$4e =? ( filenew )	| New
	$52 =? ( filerun )	| Run
	$51 =? ( exit )
	drop
	;

|-----------------------------------
:main
	mark
	'basepath flScanFullDir
	
	TuNewCode 	|"main.r3" TuLoadCode
	loadm
	'scrmain onTui 
	savem
	;

: .alsb main .masb .free ;
