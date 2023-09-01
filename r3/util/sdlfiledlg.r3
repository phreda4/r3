|---------------------- filedlg
^r3/util/sdlgui.r3

#filename * 1024
#path * 1024
#nfiles
#files
#files>
#filenow
#fileini
#filelines
#filescroll
#filen
#filen>
	
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
	
:]file 3 << files + @ ;	
:.name $ffff and filen + ;

:fileadd
	dup FNAME "." = 1? ( 2drop ; ) drop
	dup FDIR 16 << 
	filen> filen - or 	| start string
	files> !+ 'files> !
	FNAME filen> strcpyl 'filen> ! ;
	
:reload
	files 'files> !
	filen 'filen> !
	'path "%s/*" sprint
	ffirst ( fileadd fnext 1? ) drop
	files> files - 3 >> 'nfiles !
	nfiles filelines - 0 max 'filescroll !
	0 'fileini !
	0 'filenow ! 
	;
	
:colorline | n --
	filenow =? ( $7f00 ; ) $3a3a3a ;

:printline | n --
	]file | filename
	$10000 and? ( " >" immBLabel )
	14 'curx +!
	.name immBLabel 
	;


	
:listscroll | n --
	filescroll 0? ( 2drop ; ) 
	immcur> >r 
	boxh rot *
	curx boxw + boxh 1 >> -
	cury pick2 - 2 -
	rot boxh swap immcur
	0 swap 'fileini immScrollv 
	r> imm>cur
	;
	

:backfolder
	'path ( c@+ 1? drop ) drop 1 -
	( 'path >?
		dup c@ $2f =? ( drop 0 swap c! reload ; )
		drop 1 - ) drop
	reload ;

:setfolder
    .name
	dup ".." = 1? ( 2drop backfolder ; ) drop
	"/" 'path strcat
	'path strcat
	reload
	;

:linenter | nfile --
	]file
	$10000 and? ( setfolder ; )
	.name 'filename strcpy ;

	
:clicklist
	sdly cury - boxh / fileini + 
	filenow =? ( linenter ; )
	dup ]file .name 'filename strcpy 
	'filenow ! ; 
	;
	
	
::filedlgini | "" --
	'path strcpy
	15 'filelines !
	mark
	here dup 'files !	| 1k files
	8192 + dup 'filen ! | 64k names
	$ffff + 'here !
	reload	
	;
	
::filedlgend
	empty ;

#winfiledlg 1 [ 500 0 280 416 ] "FileDlg"

::immlist | cnt --
	dup immListBox
	'clicklist onClick	
	0 ( over over >=?  drop
		dup fileini + nfiles <? 
		colorline immback
		printline
		immln 1 + 
		) 2drop	
	listscroll immln
	'winfiledlg immwinbot
	;

::filedlg
	'winfiledlg immwin 0? ( drop ; ) drop
	$7f 'immcolorbtn !
	94 18 immbox
	'exit "LOAD" immbtn imm>>
	'immwin- "CANCEL" immbtn 
	immcr		
	232 18 immbox
	'path immLabel immcr
	'filename 1024 immText immcr 	
	15 immlist
	;
	
::immfileload
	'filedlg immwin!
|	1 'winfiledlg !
	;
	
::immfilesave
	'filedlg immwin!
|	1 'winfiledlg !
	;
