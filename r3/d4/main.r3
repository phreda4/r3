| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/textb.r3
|^r3/util/ttext.r3

^r3/util/ui.r3
	
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

|----- boxpath
#basepath "r3/"
#fullpath * 1024
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

:boxpath
	'fullpath 
	( dup c@ 1? drop
		dup scan/ | adr .
		0 over c! 'cfold !
		'clickf swap uitbtn
		$2f cfold c!+
		"/" uitlabel
		) 2drop ;	
		
:pathpanel
	48 4 uiXy
	256 30 uiBox
	boxpath
	;
	
|----- Files
:+file | f --
	dup FNAME
|	dup ".." = 1? ( 3drop ; ) drop
|	dup "." = 1? ( 3drop ; ) drop
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

#fp * 1024
|-------
:dirpanel
	48 32 uiXy
	256 30 uiBox
	'dirnow 20 diskdirs uiTree
	dirnow dirchg =? ( drop ; ) dup 'dirchg !
	uiTreePath
	'basepath 'fullpath strcpyl 1- strcpy
	file2list
	0 0 'filenow !+ !
	;
	
:filpanel
	304 32 uiXy 
	400 30 uiBox
	'filenow 20 files uiList
	filenow filechg =? ( drop ; ) 'filechg !
	;

#pad * 1024
		
:namepanel
	32 500 uiXy
	512 24 uiBox
	'pad 1024 uiInputLine | 'buff max --
	;

	
#tabs "1" "2" "3" 0
#tabnow	
|-----------------------------
:main
	0 SDLcls 
	uiStart
	3 4 uiPad
	
	pathpanel
	uiV
	dirpanel filpanel
	
	uiH
	32 480 uiXy
	80 24 uibox
	'tabnow	'tabs uiTab
	namepanel
	
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
	"media/ttf/Roboto-bold.ttf" 8 TTF_OpenFont 'uifont !
	24 21 "media/img/icong16.png" ssload 'uicons !
	18 uifontsize

	mark
	here 'diskdirs !
	'basepath uiScanDir
	mark
|	rebuild
	
	'main SDLshow
	SDLquit 
	;
