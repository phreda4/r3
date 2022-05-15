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
:FNAME | adr -- adrname
|WIN| 44 +
|LIN| 19 +
|WEB| 19 +
|RPI| 11 +
	;

:FDIR | adr -- dir
|WIN| @ 4 >>
|LIN| 18 + c@ 2 >>
|WEB| 18 + c@ 2 >>
|RPI| 10 + c@ 2 >>
	;

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
	'path
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
	$ffffff Color
	bprint
	;

:fillback
	$ffffff Color
	xdlg 8 + pick2
    wdlg 16 - 16 | alto letra
	FRect
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

:lineup
	filenow 1 - clamp0 fileini <? ( dup 'fileini ! )
	'filenow ! ;

:linedn
	filenow 1 + nfiles 1 - clampMax
	fileini filelines + >=? ( dup filelines - 1 + 'fileini ! )
	'filenow ! ;

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
	<ret> =? ( linenter )
	>esc< =? ( "" 'filename strcpy exit )
	drop ;

:dlgback
	0 clrscr
	gui
	$696969 Color 
	xdlg ydlg wdlg hdlg FRect
	
	$006900 Color 
	xdlg 2 + ydlg 2 + wdlg 4 - 20 6 + FRect

	$00 Color 
	xdlg 6 + ydlg 20 1 << + wdlg 12 - 20 6 + FRect
	xdlg 6 + ydlg 20 2 << + wdlg 12 - 20 6 + FRect
	
	xdlg 8 + ydlg 20 3 << + wdlg 16 - 20 filelines * FRect

	$ffffff Color
	xdlg 8 + ydlg 20 1 << + 3 + bat
	'path bprint | 64 input

	ydlg 20 3 << + 4 +
	0 ( filelines <? swap
		xdlg 8 + over bat
		linefile
		20 + swap 1 + ) 2drop
	;

|----------------------
:fileload
	dlgback
	"load File " dlgtitle
	xdlg 8 + ydlg 20 2 << + 3 + bat
	'filename bprint
	teclado
	redraw 	
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
	"save file" dlgtitle
	xdlg 8 + ydlg 20 2 << + 3 + bat
	'filename 64 input
	teclado
	redraw 
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
