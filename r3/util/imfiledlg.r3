| uiFileDlg
| PHREDA 2025
|---------------
^r3/util/immi.r3

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
	;
	
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
	sdly cy - txh /  
	fileini + 
	filenow =? ( linenter ; )
	dup 'filenow !
	clicknfile ;

:printline | n --
	nfiles >=? ( drop ; )
|	overl =? ( overfil uiFill )
	|filenow =? ( oversel uiFill )
	]file | filename
	$10000 and? ( "/" ttwriter )
	$10000 nand? ( dup .size "%d kb" sprint ttwriter )
|	14 'curx +!
	.name ttwrite
	|guiNextlist
	;
	
:listfiles | --
|	dup guiBoxlist
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
		'clickf swap uiNbtn
		$2f cfold c!+
		"/" uitlabel
		) 2drop
	uiPop
	ui.. ;			
	
#vecexec
#labelok 0 | 7chars+0

:uiFilen
	uiPush

	cx cy cw ch uiBox
	uiZone $222222 sdlcolor uiFill
	4 4 uiPading

	txh 16 + uiN
	
	'filename 1024 uiInputLine 	
	uiBoxPath
	
	txh 16 + uiS	
	3 1 uiGrid
	2 0 uiAt
	[ 'filename filevar strcpy uiExitWidget ; ] "OK" uiRBtn
	2 0 uiAt
	'uiExitWidget "CANCEL" uiRBtn

	uiRest	
	1 20 UIGrid
	20 listfiles
	
	uiPop
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
	
:ffilei
	dup 'filevar ! 
	dup 'filename strcpy 
	cx |0.125 %w - 
	cy |0.25 %h -
	0.25 %w |0.5 %h 
	txh 30 *	
	'uiFilen uisaveLast ;

:ffilen
	$ffffff sdlcolor
	4 cx 1- cy 1- cw 2 + txh 2 + SDLRound
	'ffilei uiClk 
	sdlkey
	<tab> =? ( tabfocus )
	drop ;

::uiFileName | 'var --
	uiZone $222222 sdlcolor uilFill |overfil uiRFill
	'ffilen uiFocus |'datefocoini w/foco
	ttwritec ui.. ;


:
	here dup 'files !	| 8k files
	$7ff + dup 'filen ! | 16k names
	$fff + 'here !
	"." loadnames
	;

	