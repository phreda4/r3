| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3

^r3/util/ui.r3
^r3/util/sdledit.r3
	
|--------------------------------	

#font1
#font2

#diskdirs
#dirnow 0 0
#dirchg -1

#files
#filenow 0 0
#filechg -1

#filename * 1024

|----- boxpath
#basepath "r3/"
#fullpath * 1024
#cfold

|---------
#memcode
#memcode>

#info
#info>

:loadcodigo | --
	'filename edload ;

|------------------------
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

:uixBoxPath
	" :" uiTLabel
	'fullpath 
	( dup c@ 1? drop
		dup scan/ | adr .
		0 over c! 'cfold !
		'clickf swap uitbtn
		$2f cfold c!+
		"/" uitlabel
		) 2drop ;	
		
	
|----- Files
:+file | f --
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	,s " " ,s  
|	dup FSIZEF 12 >> ,d " Kb" ,s
|	dup FDIR ,d
	|dup FWRITEDT dt>64 ,64>dtf
	drop 
	0 ,c ;
	
:file2list
	empty mark
	here 'files !
	'fullpath
|WIN|	"%s//*" sprint
	ffirst ( +file
		fnext 1? ) drop 
	0 , ;
	
#filenow 0 0
#filechg -1

#pad * 1024
		
:Fileselect
	0.01 %w 0.15 %h 0.35 %w 0.8 %h uiWin!
	$222222 sdlcolor uiRFill10
	5 15 uiGrid uiH
	
	0 14 uiGat
	stLink $ffffff txrgb
	'exit "Load" uiBtn
	'exit "Save" uiBtn
	'exit "Cancel" uiBtn
	'exit "Delete" uiBtn
	'exit "New" uiBtn
	
	|3 0 uiGat stFWhit "= FileSystem =" uiLabelC
	0.01 %w 0.15 %h 0.35 %w 0.1 %h uiWin!	
|	1 15 uiGrid<win
		1 2 uiGrid uiV 
		stDark 
		|0 1 uiGAt 'pad 1024 uiInputLine | 'buff max --
		0 0 uiGat uixBoxPath 
|		uiWin>

	0.01 %w 0.25 %h 0.15 %w 0.7 %h uiWin!
	1 16 uiGrid uiV
|	2 15 uiGrid<win
	'dirnow 24 diskdirs uiTree
	dirnow dirchg <>? ( dup 'dirchg ! 
		dup uiTreePath
		'basepath 'fullpath strcpyl 1- strcpy
		file2list
		0 0 'filenow !+ !
		) drop
|	uiWin>
		
	0.16 %w 0.25 %h 0.2 %w 0.7 %h uiWin!
	1 16 uiGrid uiV
|	2 15 uiGrid<win
		'filenow 24 files uiList
		filenow filechg <>? ( dup 'filechg ! 
			|****	
			dup uiNindx 'fullpath 'filename strcpyl 1- strcpy
			loadcodigo
		) drop
|	uiWin>	
	;

:codigo
	0.37 %w 0.1 %h 0.6 %w 0.86 %h uiWin!
	$111111 sdlcolor uiRFill10
|	5 15 uiGrid uiH
|	"cODIGO" uiLabel
|	fuente .h uiLabel
|	fuente 10 + c@ .h uiLabel
	edfocus
	edcodedraw
	edtoolbar

	;
:incodcod
	0.73 %w 0.1 %h 0.26 %w 0.85 %h uiWin!
	$222222 sdlcolor uiRFill10
	5 15 uiGrid uiH
	"+Info" uiLabel
	;
	
#tabs "1" "2" "3" 0
#tabnow	
|-----------------------------
:main
	$55 SDLcls 
	4 6 uiPad
	uiStart
	
	font1 txfont
	8 0 txat
	$ff0000 txrgb ":R3" txemits
	$ff00 txrgb "d4" txemits

	font2 txfont
	fileselect
	codigo
|	incodcod
	
|	'tabnow	'tabs uiTab

	uiEnd
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinit
	24 21 "media/img/icong16.png" ssload 'uicons !

	"media/ttf/Roboto-bold.ttf" 28 
	txload 'font1 !
	"media/ttf/RobotoMono-bold.ttf" 14 
	|"media/ttf/Roboto-bold.ttf" 18
	txload 'font2 !
	
	edram 
	0.37 %w 0.12 %h 0.6 %w 0.82 %h
	edwin

	"r3/opengl/voxels/3-vox.r3" 
	'filename strcpy
	'filename edload	
	
	mark
	here 'diskdirs !
	'basepath uiScanDir
	mark
	
	'main SDLshow
	SDLquit 
	;
