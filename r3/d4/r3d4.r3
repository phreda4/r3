| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/sdl2gfx.r3

|^r3/util/ui.r3
|^r3/util/uifiles.r3
|^r3/util/uiedit.r3
^r3/util/immi.r3
^r3/util/imedit.r3

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

|--------------- ANALYSIS
#anaword
#initoka 0
#cnttoka 0

|#winsettoka 1 [ 600 0 360 500 ] "ANALYSIS"

:infoword | adr -- str
	mark
	@+
	|dup "%h " ,print
	dup 1 and ":#" + c@ ,c		| code/data
	dup 1 >> 1 and " e" + c@ ,c	| local/export
	dup 2 >> 1 and " '" + c@ ,c	| /use adress
	dup 3 >> 1 and " >" + c@ ,c	| /R unbalanced
	dup 4 >> 1 and " ;" + c@ ,c	| /many exit
	dup 5 >> 1 and " R" + c@ ,c	| /recursive
	dup 6 >> 1 and " [" + c@ ,c	| /have anon
	dup 7 >> 1 and " ." + c@ ,c	| /not end
	dup 8 >> 1 and " m" + c@ ,c	| /mem access
	dup 9 >> 1 and " A" + c@ ,c	| />A
	dup 10 >> 1 and " a" + c@ ,c	| /A
	dup 11 >> 1 and " B" + c@ ,c	| />B
	dup 12 >> 1 and " b" + c@ ,c	| /B
	drop
	@
	dup 16 >> $ffff and " call:%d" ,print	| calls
	dup 32 >> " len:%d" ,print			| len
	drop
	,eol empty here 
	;

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
	cntdef >=? ( drop ; )
	dicword uiLabel ;
	
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
	
	
	
:coderun
	;
	
|---------------------------------
:memoria
	0.01 %w 0.8 %h 0.6 %w 0.19 %h uiBox
	|$111111 sdlcolor uiFillW
	;

|----- Includes
:iteminc
	cntinc >=? ( drop ; ) 
	4 << 'inc + @ "%w" sprint uiLabel
	;
	
:includes
	0.005 %w 0.07 %h 0.39 %w 0.03 %h uiBox
|	$333333 sdlcolor uiFillW
	8 1 uiGrid
	0 ( 8 <?
		dup iteminc
		1+ ) drop ;

|----- Dicc
:itemdef | n -- 
	cntdef >=? ( drop ; ) 
	4 << dic + nameword 
	uiLabel
	;
	
:diccionario
	0.405 %w 0.1 %h 0.29 %w 0.8 %h uiBox
	|$111111 sdlcolor uiFillW
	2 30 uiGrid

|	lidilines dup immListBox
|	'clicklistw onClick	
	0 ( 30 <?  
		dup lidiini + |cntdef <? 
		itemdef
|		colorlistw immback printlinew
		1+ ) drop	
|	listscroll uiDn
	;

|----- TOKENS
#initok 0

:showtok | nro
	cnttok >=? ( drop ; )
	3 << tok + @
	
|	"%h" immLabel imm>>
|	dup $ff and
|	1 =? ( drop 24 << 32 >> "%d" immLabel ; )				| lit
|	6 =? ( drop 8 >> $ffffff and strm + mark 34 ,c ,s 34 ,c ,eol empty here immLabel ; ) 	| str
|	drop
	40 >> src + "%w" sprint	uiLabel
	;
	
:tokens	
	0.705 %w 0.1 %h 0.29 %w 0.8 %h uiBox
	|$111111 sdlcolor uiFillW
	2 30 uiGrid
	0 ( 30 <?
		dup showtok
		1+ ) drop
	;

|----- codigo	
:codigo
	0.005 %w 0.1 %h 0.39 %w 0.8 %h uiBox
	|$111111 sdlcolor uiFillW
	
|	uiWin@ edwin
	edfocusro
	edcodedraw
	|edtoolbar
	;
	
:debug
	$55 SDLcls 

	font2 txfont	
	16 6 txat
	$ff0000 txrgb ":R3" txwrite
	$ff00 txrgb "debug" txwrite
	$ffffff txrgb
	
	uiStart 4 6 uiPading
	14 22 uiGrid
	1 0 uiat 
	stInfo
	'exit "Run" uiRBtn
	'exit "Step" uiRBtn

	codigo
	includes
	diccionario
	tokens
|	memoria

	uiEnd
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop ;

		
:errormode
|	3 'edmode ! | no edit src
|	lerror 'ederror !
	error .print 
	| goto edit mode
	;
	
:codedebug
	empty mark
	fuente 'filename r3loadmem

	error 1? ( drop errormode ; ) drop
|	4 'edmode ! | no edit src
|	1 modo! 
	lidiset
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
	
|---------------------------------	
:edit
	$55 SDLcls 
	
	font2 txfont	
	16 6 txat
	$ff0000 txrgb ":R3" txwrite
	$ff00 txrgb "Edit" txwrite
	$ffffff txrgb
	
	uiStart 4 6 uiPading
	14 22 uiGrid
	1 0 uiat
	stInfo
	'exit "F1 Help" uiRBtn
|	'codedit "F2 Edit" uiRBtn
	'codedebug "F3 Debug" uiRBtn

	0.01 %w 0.1 %h 0.7 %w 0.8 %h uiBox
	|$111111 sdlcolor uiRFill10
	|uiWin@ edwin
	edfocus
	edcodedraw

	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f3> =? ( codedebug ) 
	drop ;
	
:codedit
	'edit sdlshow
	;
	
:codenew
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
	0.01 %w 0.05 %h 0.35 %w 0.94 %h uiBox
	|$222222 sdlcolor uiFillW
	2 22 uiGrid 
	
	stDark 
	uiPush
	0 1 uiAt 2 1 uito 
	'pad 1024 uiInputLine | 'buff max --
	0 0 uiat 2 1 uito 
	uixBoxPath 
	uiPop
	0 2 uiAt 
	|'dirnow 33 uiDirs uiTree
	dirnow dirchg <>? ( dup 'dirchg ! 
|		dup uiTreePath
		'basepath 'fullpath strcpyl 1- strcpy
|		'fullpath uiGetFiles
		0 0 'filenow !+ ! -1 'filechg !
		) drop
		
	1 2 uiAt 
|	'filenow 33 uiFiles uiList
	filenow filechg <>? ( dup 'filechg ! 
		dup uiNindx 'fullpath 'filename strcpyl 1- strcpy
		loadcodigo
		) drop
	;


:codigo
	0.37 %w 0.05 %h 0.6 %w 0.9 %h uiBox
|	$111111 sdlcolor uiFillW
|	uiWin@ edwin	
	edfocusro
	edcodedraw
	edtoolbar
	;
	
:incodcod
	0.73 %w 0.1 %h 0.26 %w 0.85 %h uiBox
|	$222222 sdlcolor uiFillW
	5 15 uiGrid
	"+Info" uiLabel
	;
	
|---------------------
:browser
	$55 SDLcls 
	
	font2 txfont	
	16 6 txat
	$ff0000 txrgb ":R3" txwrite
	$ff00 txrgb "d4" txwrite
	$ffffff txrgb
	
	uiStart 4 6 uiPading
	14 22 uiGrid
	1 0 uiat 
	stInfo
	'coderun "F1 Run" uiRBtn
	'codedit "F2 Edit" uiRBtn
	'codedebug "F3 Debug" uiRBtn
|	'exit "Console" uiRBtn
|	'exit "Delete" uiBtn

	stLink
	'exit "New" uiRBtn
		
	fileselect
	codigo

	uiEnd
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<F1> =? ( coderun )
	<F2> =? ( codedit )
	<F3> =? ( codedebug )
	<F4> =? ( codenew )
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
|	'nameaux uiDirs searchtd
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

	"media/ttf/Roboto-bold.ttf" 28 txloadwicon 'font1 !
	"media/ttf/RobotoMono-Bold.ttf" 14 txloadwicon 'font2 !
	
	edram 
|	0.37 %w 0.08 %h 0.6 %w 0.85 %h edwin
	
	mark
|	'basepath uiScanDir
	loadm
	
	mark
	'browser SDLshow
	
	|savem
	SDLquit 
	;
