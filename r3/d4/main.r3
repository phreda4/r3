| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/ui.r3
^r3/util/uifiles.r3
^r3/util/uiedit.r3

^r3/d4/r3token.r3
^r3/d4/r3vmd.r3
^r3/d4/r3opt.r3
	
|--------------------------------	
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

|---------
#memcode
#memcode>

#info
#info>

:loadcodigo | --
	'filename edload ;


|--------------- SOURCE	
:cursor2ip
	<<ip 0? ( drop ; )
	@ 40 >>> src + 'fuente> ! ;

:codename | adr' info1 -- str
	$2 and? ( $3a ,c ) $3a ,c 
	40 >>> src + "%w | " ,print
	@ ,mov |,movd
	,eol empty here ;
	
:dataname | adr' info1 -- str
	$2 and? ( $23 ,c ) $23 ,c 
	40 >>> src + "%w" ,print
	drop
	,eol empty here ;
	
:nameword | dicadr -- str
	mark @+ 1 and? ( dataname ; ) codename ;

|------------------------

|-----------------------------
:compiler
	;
	
:profiler
	;

|--------------- DICCIONARY
#lidinow
#lidiini
#lidilines 20
#lidiscroll
#winsetwor 1 [ 940 200 340 390 ] "DICCIONARY"

:lidiset
	0 'lidinow !
	0 'lidiini !
	cntdef lidilines - 0 max 
	'lidiscroll !
	;
	
:dicword | nro --
	4 << dic + nameword ;

:printlinew
	cntdef >=? ( drop uiDn ; )
	dicword uiLabel uiDn ;
	
:clicklistw
|	sdly cury - boxh / lidiini + 
|	filenow =? ( linenter ; )
|	dup 'lidinow !
|	dup 'anaword !
|	wordanalysis
|	tokana> 'tokana - 3 >> 'cnttoka !
	;
	
:colorlistw | n -- n c
	lidinow =? ( $7f00 ; ) $3a3a3a ;

:listscroll | n --
	lidiscroll 0? ( 2drop ; ) 
|	immcur> >r 
	
|	boxh rot *
|	curx boxw + 2 + | pad?
|	cury pick2 -
|	rot boxh swap immcur

|	0 swap 
|	'lidiini immScrollv 
|	r> imm>cur
	;
	
:wordfocus
|	940 200 immwinxy
||	316 18 immbox
|	lidilines dup immListBox
|	'clicklistw onClick	
|	0 ( over over >?  drop
|		dup lidiini + |cntdef <? 
|		colorlistw immback printlinew
|		1 + ) 2drop	
|	listscroll uiDn
	
	;
	
	
:coderun
	;
	
:codedit
	;
	
:codenew
	;

|---------------------------------

:debug
	$55 SDLcls 
	4 6 uiPad

	uiStart
	
	font1 txfont
	8 0 txat
	$ff0000 txrgb ":R3" txemits
	$ff00 txrgb "debug" txemits

	font2 txfont
	0.01 %w 0.05 %h 0.35 %w 0.05 %h uiWin!
	5 1 uiGrid
	0 0 uiGat uiH
	stInfo
	'exit "Run" uiRBtn
	'exit "Step" uiRBtn
|	'codedebug "Debug" uiRBtn
|	'exit "Console" uiRBtn
|	'exit "Delete" uiBtn
|	ui>
|	stDang
|	'exit "New" uiRBtn
		
|	fileselect
|	codigo

	uiEnd
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
|	<F1> =? ( coderun )
|	<F2> =? ( codedit )
|	<F3> =? ( codenew )
	drop

	;

		
:errormode
|	3 'edmode ! | no edit src
|	lerror 'ederror !
	error .print 
	;
	
:codedebug
	empty mark
	fuente 'filename r3loadmem

	error 1? ( drop errormode ; ) drop
|	4 'edmode ! | no edit src
|	1 modo! 
	|lidiset
	|liinset
	|inc> 'inc - 4 >> 1 - incset
	$ffff 'here +!
	resetvm
	|cursor2ip
	mark
	'filename ,s ,cr ,cr
	debugmemmap
	"r3/d4/gen/map.txt" savemem
	empty
	'debug sdlshow
	;	
	
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
	0.01 %w 0.1 %h 0.35 %w 0.85 %h uiWin!
	$222222 sdlcolor uiRFill10
	2 20 uiGrid 
	
	stDark 
	uiPush
	0 1 uiGAt 2 1 uiGto 
	'pad 1024 uiInputLine | 'buff max --
	0 0 uiGat 2 1 uiGto 
	uixBoxPath 
	uiPop
	0 2 uiGAt uiV
	'dirnow 30 uiDirs uiTree
	dirnow dirchg <>? ( dup 'dirchg ! 
		dup uiTreePath
		'basepath 'fullpath strcpyl 1- strcpy
		'fullpath uiGetFiles
		0 0 'filenow !+ ! -1 'filechg !
		) drop
		
	1 2 uiGAt uiV
	'filenow 30 uiFiles uiList
	filenow filechg <>? ( dup 'filechg ! 
		dup uiNindx 'fullpath 'filename strcpyl 1- strcpy
		loadcodigo
		) drop
	;

#tabs "1" "2" "3" 0
#tabnow	

:codigo
|	0.37 %w 0.1 %h 0.6 %w 0.05 %h uiWin!
|	5 1 uiGrid uiH
|	incodcod
|	'tabnow	'tabs uiTab

	0.37 %w 0.05 %h 0.6 %w 0.9 %h uiWin!
	$111111 sdlcolor uiRFill10
|	5 15 uiGrid uiH
|	"cODIGO" uiLabel
|	fuente .h uiLabel
|	fuente 10 + c@ .h uiLabel
	edfocusro
	edcodedraw
	edtoolbar

	;
:incodcod
	0.73 %w 0.1 %h 0.26 %w 0.85 %h uiWin!
	$222222 sdlcolor uiRFill10
	5 15 uiGrid uiH
	"+Info" uiLabel
	;
	
|---------------------
:browser
	$55 SDLcls 
	4 6 uiPad

	uiStart
	
	font1 txfont
	8 0 txat
	$ff0000 txrgb ":R3" txemits
	$ff00 txrgb "d4" txemits

	font2 txfont
	0.01 %w 0.05 %h 0.35 %w 0.05 %h uiWin!
	5 1 uiGrid
	0 0 uiGat uiH
	stInfo
	'exit "Run" uiRBtn
	'codedebug "Debug" uiRBtn
|	'exit "Console" uiRBtn
|	'exit "Delete" uiBtn

	stDang
	'exit "New" uiRBtn
		
	fileselect
	codigo

	uiEnd
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<F1> =? ( coderun )
	<F2> =? ( codedit )
	<F3> =? ( codenew )
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
	.println
	
	uiDirs ( dup c@ 1? drop
		dup 'nameaux = 1? ( ">>" .print ) drop
		dup .println		
		>>0 ) 2drop
	;

:savem
	'filename 1024 "mem/d4.mem" save ;
	
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
	0.37 %w 0.08 %h 0.6 %w 0.85 %h
	edwin
	
	mark
	'basepath uiScanDir
	loadm
	
	mark
	'browser SDLshow
	
	|savem
	SDLquit 
	;
