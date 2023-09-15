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
	
:FSIZE
	32 + d@ 10 >> ; | in kb
	
:]file 3 << files + @ ;	
:.name $ffff and filen + ;
:.size 17 >>> ;

:fileadd
	dup FNAME "." = 1? ( 2drop ; ) drop
	dup FDIR $1 and 16 << 
	over FSIZE 17 << or
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
	
|-----
:backfolder
	'path ( c@+ 1? drop ) drop 3 - | /0.
:backfhere | fromhere --	
	( 'path >?
		dup c@ $2f =? ( drop 0 swap ! reload ; )
		drop 1 - ) drop
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
	
:clicklist
	sdly cury - boxh / fileini + 
	filenow =? ( linenter ; )
	dup 'filenow !
	clicknfile ;
	
	


#winfiledlg 3 [ 500 0 400 416 ] "FileDlg"

:listscroll | n --
	filescroll 0? ( 2drop ; ) 
	immcur> >r 
	
	boxh rot *
	curx boxw + 2 + | pad?
	cury pick2 -
	rot boxh swap immcur

	0 swap 'fileini immScrollv 
	r> imm>cur
	;
	
:colorline | n --
	filenow =? ( $7f00 ; ) $3a3a3a ;

:printline | n --
	]file | filename
	$10000 and? ( " /" immBLabel )
	$10000 nand? ( dup .size "%d KB" sprint immLabelR )
	14 'curx +!
	.name immBLabel 
	immln ;
	
::immlist | cnt --
	dup immListBox
	'clicklist onClick	
	0 ( over over >?  drop
		dup fileini + nfiles <? 
		colorline immback printline
		1 + ) 2drop	
	listscroll immln
	;

#cfold

:scan/ | "" -- adr/
	( c@+ 1?
		$5c =? ( $2c nip )
		$2f =? ( drop 1 - ; )
		drop ) over c! | duplicate 0
		1 - ;
		
:clickf
	$2f cfold c!
	cfold backfhere ;
	
:boxpath
	1 immListBox
	'path 
	( dup c@ 1? drop
		dup scan/ | adr .
		0 over c! 'cfold !
		'clickf swap immtbtn
		$2f cfold c!+
		">" imm.
		) 2drop ;
	
::filedlg
	'winfiledlg immwin 0? ( drop ; ) drop
	390 18 immbox
	boxpath immcr
	390 18 immbox
	'filename 1024 immInputLine immcr 	
	370 18 immbox
	filelines immlist
	94 18 immbox
	$7f 'immcolorbtn !

	[ winexit ; ] "LOAD" immbtn imm>>
	'winexit "CANCEL" immbtn immcr		
	immln
	'winfiledlg immwinbottom
	;
	
::filedlgini | "" --
	'path strcpy
	15 'filelines !
	here dup 'files !	| 1k files
	8192 + dup 'filen ! | 64k names
	$ffff + 'here !
	reload	
	;
	
::immfileload | 'file -- 'file/0
|	mark
|	filedlgini
	
	'filedlg immwin! | winfix
	;
	
::immfilesave | 'file -- 'file/0
|	mark
|	filedlgini
	'filedlg immwin!
|	empty
|	'path dup 'filename strcat
	;
