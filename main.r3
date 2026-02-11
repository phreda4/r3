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
	'fullpath
|WIN| 	"cmd /c r3 ""%s"""
|LIN| 	"./r3lin ""%s"""
	sprint sys | run
	.reterm .alsb .flush
	runcheck
	tuR! ;
	
:fileedit	
	fuente c@ 0? ( drop ; ) drop
	.masb .flush
	savem
||WIN| 	"r3 r3/editor/code-edit.r3"
||LIN| 	"./r3lin r3/editor/code-edit.r3"

|WIN| 	"r3 r3/d4/r3ide.r3"
|LIN| 	"./r3lin r3/d4/r3ide.r3"
	sys 
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
	0 SDLcls
	$ff00 SDLColor
	10 10 100 100 SDLFRect
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
	0 rows .at 7 .fc 4 .bc cols .nsp
	0 rows .at 
	" Name: " .write .input
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
	0 rows .at 7 .fc 4 .bc cols .nsp
	0 rows .at 
	" ? " .write .input
	'pad trim c@ 0? ( drop ; ) drop
	
	;

:filedelete
	fuente c@ 0? ( drop ; ) drop	
	0 rows .at 15 .fc 1 .bc cols .nsp
	0 rows .at 
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
	tuwin $1 'fullpath .wtitle
	1 1 flpad 
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
	4 .bc 7 .fc	
	1 flxS
	fx fy .at fw .nsp
	" ^[7m H ^[27melp ^[7m R ^[27mun ^[7m E ^[27mEdit ^[7m N ^[27mew ^[7m / ^[27mSearch "
	.printe

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
