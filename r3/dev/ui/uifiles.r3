| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/ui.r3
^r3/util/uifiles.r3
	
|--------------------------------	
#folder1 0 0 0

#font1
#font2

#dirnow 0 0
#dirchg -1

#filenow 0 0
#filechg -1

#filename * 1024

|----- boxpath
#basepath "r3/"

#fullpath * 1024
#cfold

|------------------------	
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
		

#filenow 0 0
#filechg -1

#pad * 1024
		
:Fileselect
	0.01 %w 0.05 %h 0.35 %w 0.94 %h uiWin!
	$222222 sdlcolor uiFillW
	2 22 uiGrid 
	
	stDark 
	uiPush
	0 1 uiGAt 2 1 uiGto 
	'pad 1024 uiInputLine | 'buff max --
	0 0 uiGat 2 1 uiGto 
	uixBoxPath 
	uiPop
	0 2 uiGAt uiV
	'dirnow 33 uiDirs uiTree
	dirnow dirchg <>? ( dup 'dirchg ! 
		dup uiTreePath
		'basepath 'fullpath strcpyl 1- strcpy
		'fullpath uiGetFiles
		0 0 'filenow !+ ! -1 'filechg !
		) drop
		
	1 2 uiGAt uiV
	'filenow 33 uiFiles uiList
	filenow filechg <>? ( dup 'filechg ! 
		dup uiNindx 'fullpath 'filename strcpyl 1- strcpy
|		loadcodigo
		) drop
	;


	
|---------------------
:browser
	$55 SDLcls 
	
	font2 txfont	
	16 6 txat
	$ff0000 txrgb ":R3" txemits
	$ff00 txrgb "d4" txemits
	$ffffff txrgb
	
	uiStart 4 6 uiPad
	14 22 uiGrid
	1 0 uiGat uiH
	stInfo
|	'exit "Console" uiRBtn
	'exit "Delete" uiBtn

	stLink
	'exit "New" uiRBtn
		
	fileselect
|	codigo

	uiEnd
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
|-----------------------------
#nameaux * 1024

:>>/ | adr -- adr
	( c@+ 1? $2f <>? drop ) drop 1- ;

:genlevel | list 0 -- 
	'filename 'basepath count nip + 
	over ( 1? 1- swap >>/ swap ) drop
	'nameaux >a swap 64 + ca!+
	( c@+ 1? $2f <>? ca!+ ) 2drop
	0 ca!+	|'nameaux .println
	;
	
:searchtd | "" list -- list
	0 >a
	( dup c@ 1? drop
		dup pick2 = 1? ( drop nip ; ) drop
		1 a+
		>>0 ) 3drop 0 ;
	
:loadm
	'filename "mem/d4.mem" load
	
	'filename filexist 0? ( drop ; ) drop | si no existe
	|'dirnow
|	"@" 'nameaux strcpy
|	'fullpath 'basepath count nip + 
|	'nameaux strcat
|	"--aux:" .print	'nameaux .println
|	"--full:" .print 'fullpath .println
|	"--dir:" .println
	
|	'nameaux diskdirs
|	0? ( drop ; )
|	.println	
		
	|diskdirs 
	0 genlevel
	'nameaux uiDirs searchtd
	$80 over c+!
	12 'dirnow !
	|.println
	drop
	
|	uiDirs ( dup c@ 1? drop
|		dup 'nameaux = 1? ( ">>" .print ) drop
|		dup .println		
|		>>0 ) 2drop
	;

:savem
	'filename 1024 "mem/d4.mem" save ;
	
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 28 
	txloadwicon 'font1 !
	"media/ttf/RobotoMono-Bold.ttf" 14 
	txloadwicon 'font2 !

	mark
	'basepath uiScanDir
	loadm
	
	mark
	'browser SDLshow
	
	|savem
	SDLquit 
	;
