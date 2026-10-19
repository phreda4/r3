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
:helpdlg
	"Help" 50 12 tuDlg
	fcr
	"ctrl+R Run    ctrl+E Edit " .cw
	"ctrl+I Imm    ctrl+D Debug" .cw
	"ctrl+N New    ctrl+O Clon " .cw
	fcr
	"ctrl+K Help   ctrl+S Search" .cw
	"ctrl+Q Quit   ctrl+X Delete" .cw
	fcr
	fcr
	
	fMu "PHREDA - R3Forth" .cw
	tuDlgEnd
	uikey
	[esc] =? ( exit )
	drop ;
	
:banner
	"[01R[023[03f[04o[05r[06t[07h" .awrite .cr .cr .cr .cr ;
	
:runcheck
	.cls banner .flush
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
	.cls banner .flush
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

:filedebug
	savem
	|checkcode error 1? ( drop moderror ; ) drop
	"r3/d4/r3debug.r3" r3run
	.reterm .alsb .flush tuR! ;

:r3repl
	.masb .flush
	savem
	"repl/repl.r3" r3run
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
#newsdl "| r3 sdl code
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
#newconsole "| r3 console code
^r3/lib/console.r3
	
:main
	.cls
	.cr
	""Hello Word !"" .println
	anykey 
	;

: main ;"
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
	|8 .bc 15 .fc 
	4 .bc 7 .fc
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
	bg0 fPr fhome .sp 'fullpath .write .eline
	1 2 flpad
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

|------------	
:scrmain
	.reset .bblack .cls
	
	4 flxN |___________
	fhome banner 
	
	1 flxS |___________
	bg3 fhome
	fPr " ^R" .write fTx "un" .write 
	fPr " ^E" .write fTx "dit" .write 
	fPr " ^N" .write fTx "ew" .write 
	fPr " ^I" .write fTx "mm" .write 
	fPr " ^K" .write fTx "help" .write 
	.eline
	
	38 flxO |___________
	dirpanel
	
	flxRest	 |___________
	paneleditor

	uikey
	[esc] =? ( exit ) 
	[f5] =? ( filerun )
	[f6] =? ( fileedit )
	[ENTER] =? ( filerun )
	$20 =? ( fileedit )
	$2f =? ( filesearch )

| ctrl
	$3 =? ( exit ) 		| ctrl+c exit
	$4 =? ( filedebug )	| ctrl+d Debug
	$5 =? ( fileedit )	| ctrl+e Edit
	$9 =? ( r3repl )	| ctrl+i Imm
	$b =? ( 'helpdlg onTui ) | ctrl+k Help	
	$e =? ( filenew )	| ctrl+n New
	$11 =? ( exit )		| ctrl+q quit
	$12 =? ( filerun )	| ctrl+r run
	$13 =? ( filesearch )	| ctrl+s search
	$18 =? ( filedelete ) | ctrl+x delete

	toUpp
	$44 =? ( filedebug ) | Debug
	$45	=? ( fileedit )	| Edit
	$49	=? ( r3repl )	| Interactive
	$4b =? ( 'helpdlg onTui ) | k Help	
	$4e =? ( filenew )	| New
	$52 =? ( filerun )	| Run
	$53 =? ( filesearch )	| S search
	$58 =? ( filedelete ) | X Delete	
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
