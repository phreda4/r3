| uiFileDlg
| PHREDA 2025
|---------------
^r3/util/ui.r3
^r3/util/txfont.r3

#filevar

#filename * 1024
#path "r3" * 1024
#nfiles
#files
#files>
#filenow
#fileini
#filelines
#filescroll
#filen
#filen>

:]file 3 << files + @ ;	
:.name $ffff and filen + ;
:.size 17 >>> ;

:fileadd
	dup FNAME "." = 1? ( 2drop ; ) drop
	dup FDIR $1 and 16 << 
|	over FSIZEf 17 << or
	filen> filen - or 	| start string
	files> !+ 'files> !
	FNAME filen> strcpyl 'filen> ! ;
	
:reload
	files 'files> !
	filen 'filen> !
	'path 
|WIN|	"%s/*" sprint
	ffirst ( fileadd fnext 1? ) drop
	files> files - 3 >> 'nfiles !
	nfiles filelines - 0 max 'filescroll !
	0 'fileini !
	0 'filenow ! 
	;
	
	
|-----
:backfolder
	'path ( c@+ 1? drop ) drop 3 - | /0.
:backfhere | fromhere --	
	( 'path >?
		dup c@ $2f =? ( drop 0 swap ! reload ; )
		drop 1- ) drop
	reload ;

:setfolder
    .name
	dup ".." = 1? ( 2drop backfolder ; ) drop
	'path strcat
	reload ;

:linenter | nfile --
	]file
	$10000 and? ( setfolder ; )
	.name 'filename strcpy 
	refreshfoco ;
	
:clicknfile | n -- 
	]file 
	$10000 and? ( drop 0 'filename ! ; )
	.name 'filename strcpy ;
	

:refile 
	0 'fileini !
	'filename
	0 ( nfiles <? 
		dup ]file .name pick2 cmpstr 
		0? ( drop nip 
			filelines >? ( dup filelines - 1+ 'fileini ! )
			'filenow ! ; ) drop 
		1+ ) 2drop ;
		

:listscroll | n --
	filescroll 0? ( 2drop ; ) 2drop
|	immcur> 
|	>r 
	
|	boxh rot *
|	curx boxw + 2 + | pad?
|	cury pick2 -
|	rot boxh swap immcur

|	0 swap 'fileini immScrollv 
|	r> imm>cur
	;


:clicklist
	sdlBoxListY fileini + 
	filenow =? ( linenter ; )
	dup 'filenow !
	clicknfile ;

:printline | n --
	nfiles >=? ( drop ; )
|	overl =? ( overfil uiFill )
	filenow =? ( oversel uiFill )
	]file | filename
	$10000 and? ( "/" ttemitr )
	$10000 nand? ( dup .size "%d kb" sprint ttemitr )
|	14 'curx +!
	.name ttemitl
	guiNextlist
	;
	
:listfiles | --
	dup guiBoxlist
	'clicklist onClick	
	0 ( over <?
		dup fileini + printline
		1+ ) drop
	|listscroll 
	drop
	;

|------------------------
#cfold

:scan/ | "" -- adr/
	( c@+ 1?
		$5c =? ( $2c nip )
		$2f =? ( drop 1- ; )
		drop ) over c! | duplicate 0
		1- ;
		
:clickf
	$2f cfold c!
	|cfold backfhere 
	;

:uiBoxPath
	uiPush
	'path 
	( dup c@ 1? drop
		dup scan/ | adr .
		0 over c! 'cfold !
		'clickf swap uitbtn
		$2f cfold c!+
		"/" uitlabel
		) 2drop
	uiPop
	ui.. ;			
	
#vecexec
#labelok 0 | 7chars+0

:uiFilen
	4 2 uiPad
	uiZone@ 2drop 0.4 %h - |swap 0.07 %w - swap
	0.3 %w 0.8 %h uiWinFit! 
	$222222 sdlcolor uiRFill10 $ffffff sdlcolor uiRRect10
	1 20 UIGridA uiV
	$444444 sdlcolor uiRFill
	0 0 uigAt 	
	'filename 1024 uiInputLine 
	uiBoxPath
	20 listfiles
	4 20 UIGridA uiH
	0 19 uigAt
	[ 'filename filevar strcpy uiExitWidget ; ] "OK" uiRBtn
	'uiExitWidget "CANCEL" uiRBtn
	;
	

:loadnames | filename --
	dup 'path strpath
	'path count nip + 
	dup c@ $2f =? ( swap 1+ swap ) drop
	'filename strcpy
	reload refile ;
	
::immfileload | 'vecload 'file --
	loadnames
|	'vecexec !
|	"LOAD" 'labelok strcpy
|	'filedlg immwin! | winfix
	;
	
::immfilesave | 'vecload 'file --
	loadnames
|	'vecexec !
|	"SAVE" 'labelok strcpy
	|'filedlg immwin!
	;
	
::fullfilename
	'filename 'path "%s%s" sprint ;
	
|-----	
:ffilen
	'uiFilen uisaveLast
	cifoc sdlColor uiRRect
	sdlkey
	<tab> =? ( nextfoco )
	drop ;
	
:ffilei
	dup 'filevar ! 
	dup 'filename strcpy ;

::uiFileName | 'var --
	uiZone overfil uiRFill
	'ffilen 'ffilei w/foco
	'clickfoco onClick		
	ttemitc ui.. ;

:
	here dup 'files !	| 8k files
	$7ff + dup 'filen ! | 16k names
	$fff + 'here !
	"." loadnames
	;

	