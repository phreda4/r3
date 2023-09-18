| File load/save
| PHREDA 2020
|---------------
^r3/win/sdl2gfx.r3
^r3/lib/gui.r3
^r3/lib/input.r3

#path * 1024
#filename * 1024
#ext * 32

#xdlg 0 #ydlg 0
#wdlg 0 #hdlg 0

|--------------------------------
#files
#files>
#filenow
#fileini
#filelines
#filen
#filen>
#nfiles

|----------------------
:fileadd
	dup FNAME
	"." = 1? ( 2drop ; ) drop
	filen> files> !+ 'files> !
	dup FDIR files> !+ 'files> !
	FNAME 
	filen> strcpyl 'filen> !
	;

:findlast | -- adr
	'path ( c@+ 1? drop ) drop ;

:searchlast
	findlast
	files ( files> <?
		@+ pick2 = 1? ( drop 8 - files - 4 >> 'filenow ! drop ; )
		drop 8 + ) 2drop
	0 'filenow !
	;

:reload
	files 'files> !
	filen 'filen> !
	'path "%s/*" sprint
	ffirst ( fileadd fnext 1? ) drop
	files> files - 4 >> 'nfiles !
	0 'fileini !
	searchlast
	refreshfoco
	;

:dlgFileIni
	10 'ydlg ! 640 'hdlg !
	10 'xdlg ! 480 'wdlg !
	15 'filelines !
	mark
	here dup 'files !
	8192 + dup 'filen !
	'here !
	reload
	;

:dlgFileEnd
	empty
	;
	
:dlgtitle
	xdlg 4 + ydlg 4 + bat
	$ffffff SDLColor
	bprint
	;

:fillback
	$ffffff SDLColor
	xdlg 8 + pick2
    wdlg 16 - 16 | alto letra
	SDLFRect
	;

:colorline | n --
	filenow =? ( fillback $0 bcolor ; )
	$ffffff bcolor ;

:printline | n --
	4 << files + @+
	swap @
	1 and? ( "/" bprint ) drop
	bprint ;

:linefile | n x -- n x
	over fileini +
	nfiles >=? ( drop ; )
	colorline
	printline
	;

:setfilenow! | nfile --
	nfiles 1 - clamp0Max  
	dup 'filenow !
	4 << files + @ 'filename strcpy 
	;
	
:lineup
	filenow 1 - clamp0 fileini <? ( dup 'fileini ! )
	setfilenow! ;

:linedn
	filenow 1 + nfiles 1 - clampMax
	fileini filelines + >=? ( dup filelines - 1 + 'fileini ! )
	setfilenow! ;

:setfile
	filenow 4 << files + @ 'filename strcpy 
	exit ;

:backfolder
	'path ( c@+ 1? drop ) drop 1 -
	( 'path >?
		dup c@ $2f =? ( drop 0 swap c! reload ; )
		drop 1 - ) drop
	reload ;

:setfolder
    filenow 4 << files + @
	dup ".." = 1? ( 2drop backfolder ; ) drop
	"/" 'path strcat
	'path strcat
	reload
	;

:linenter
	filenow 4 << files + 8 + @
	1 and? ( drop setfolder ; ) drop
	setfile ;

:teclado
	SDLkey
	<up> =? ( lineup )
	<dn> =? ( linedn )
	|<ret> =? ( linenter )
	<ret> =? ( exit )
	>esc< =? ( "" 'filename strcpy exit )
	drop ;

:dlgback
	0 SDLcls
	gui
	$696969 SDLColor 
	xdlg ydlg wdlg hdlg SDLFRect
	
	$006900 SDLColor 
	xdlg 2 + ydlg 2 + wdlg 4 - 20 6 + SDLFRect

	$00 SDLColor 
	xdlg 6 + ydlg 20 1 << + wdlg 12 - 20 6 + SDLFRect
	xdlg 6 + ydlg 20 2 << + wdlg 12 - 20 6 + SDLFRect
	
	xdlg 8 + ydlg 20 3 << + wdlg 16 - 20 filelines * SDLFRect

	$ffffff bcolor
	xdlg 8 + ydlg 20 1 << + 3 + bat
	'path bprint |64 input
	
	xdlg 8 + 
	ydlg 20 3 << + 4 +
	wdlg 12 -
	filelines 16 * guiBox
	
	[ sdly ydlg 20 3 << + 4 + - 16 / fileini + 
		setfilenow! ; ] onClick
	
	ydlg 20 3 << + 4 +
	0 ( filelines <? swap
		xdlg 8 + over bat
		linefile
		20 + swap 1 + ) 2drop
	;

|----------------------
:fileload
	dlgback
	$ffffff bcolor
	"load File " dlgtitle
	xdlg 8 + ydlg 20 2 << + 3 + bat
	'filename bprint
	teclado
	SDLredraw 	
	;

:fullfilename | -- fn
	'filename dup c@ $2f =? ( swap 1 + swap ) drop
	'path "%s/%s" sprint
	;

::dlgFileLoad | -- fn/0
	dlgFileIni
	'fileload SDLshow
	dlgFileEnd
	'filename c@ 0? ( ; ) drop
	fullfilename
	;

|----------------------
:teclado
	SDLkey
	<up> =? ( lineup )
	<dn> =? ( linedn )
	<tab> =? ( linenter )
	<ret> =? ( exit )
	>esc< =? ( "" 'filename strcpy exit )
	drop ;

:filesave
	dlgback
	$ffffff bcolor
	"save file" dlgtitle
	xdlg 8 + ydlg 20 2 << + 3 + bat
	'filename 64 input
	teclado
	SDLredraw 
	;

::dlgFileSave | -- fn/0
	dlgFileIni
	'filesave SDLShow
	dlgFileEnd
	'filename c@ 0? ( ; ) drop
	fullfilename
	;

::dlgSetPath | "path" --
	'path strcpy ;
