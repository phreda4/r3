| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/textb.r3

^r3/util/ui.r3
^r3/util/sdledit.r3
	
|------------------------	
| type name size datetime
|satetime 
| YYYY MwDD HHMM SSmm (mm>>2)
:dt>64 | datetime -- dt64
	@+
	dup date.y 48 << 
	over date.m 44 << or
	over date.dw 40 << or
	swap date.d 32 << or
	swap @
	dup time.h 24 << 
	over time.m 16 << or
	over time.s 8 << or
	swap time.ms 2 >> $ff and or
	or ;

:,64>dtf | dt64 -- "d-m-y h:m"
	dup 32 >> $ff and ,2d "-" ,s
	dup 44 >> $f and ,2d "-" ,s
	dup 48 >> $ffff and ,d " " ,s
	dup 24 >> $ff and ,2d ":" ,s
	16 >> $ff and ,2d
	;

:64>dtc | dt64 -- "y-m-d h:m:s"
	;

|--------------------------------	
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
	0.01 %w 0.15 %h 0.35 %w 0.8 %h uiWin
	$222222 sdlcolor uiRFill10
	5 15 uiGrid uiH
	
	0 14 uiGat
	stLink
	'exit "Load" uiBtn
	'exit "Save" uiBtn
	'exit "Cancel" uiBtn
	'exit "Delete" uiBtn
	'exit "New" uiBtn
	
	4 0 uiGat stFWhit "FileSystem" uiLabelC
	0.01 %w 0.15 %h 0.35 %w 0.1 %h uiWin	
|	1 15 uiGrid<win
		1 2 uiGrid uiV 
		stDark 
		|0 1 uiGAt 'pad 1024 uiInputLine | 'buff max --
		0 0 uiGat uixBoxPath 
|		uiWin>

	0.01 %w 0.25 %h 0.15 %w 0.7 %h uiWin
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
		
	0.16 %w 0.25 %h 0.2 %w 0.7 %h uiWin
	1 16 uiGrid uiV
|	2 15 uiGrid<win
		'filenow 24 files uiList
		filenow filechg <>? ( dup 'filechg ! 
			|****	
			dup uiListStr 'fullpath 'filename strcpyl 1- strcpy
			loadcodigo
		) drop
|	uiWin>	
	;

:drawcode
	fuente 0? ( drop ; ) 
	|"%l" uiLabel
	.println
	|drop
	;
	
:codigo
	0.37 %w 0.1 %h 0.35 %w 0.85 %h uiWin
	$222222 sdlcolor uiRFill10
	5 15 uiGrid uiH
	"cODIGO" uiLabel
	fuente .h uiLabel
	fuente 10 + c@ .h uiLabel
	;
:incodcod
	0.73 %w 0.1 %h 0.26 %w 0.85 %h uiWin
	$222222 sdlcolor uiRFill10
	5 15 uiGrid uiH
	"+Info" uiLabel
	;
	
#tabs "1" "2" "3" 0
#tabnow	
|-----------------------------
:main
	0 SDLcls 
	4 6 uiPad
	uiStart

	fileselect	
	codigo
	incodcod
	
|	'tabnow	'tabs uiTab

|	edfocus
|	edcodedraw
	
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
	"media/ttf/Roboto-regular.ttf" 
	|"media/ttf/ProggyClean.ttf" 
	8 TTF_OpenFont 'uifont !
	24 21 "media/img/icong16.png" ssload 'uicons !
	16 uifontsize

	bfont1
	edram 
	60 4 80 40 edwin

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
