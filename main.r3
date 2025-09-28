| main filesystem - Unified Windows/Linux version
| PHREDA 2019
|------------------------
^r3/lib/console.r3
^r3/lib/mconsole.r3
^r3/editor/code-print.r3

#reset 0
#path * 1024
#name * 1024

#nfiles
#files * 8192
#files> 'files
#files< 'files
#filen * $3fff
#filen> 'filen

#nivel
#pagina
#actual
#linesv 15

#source 0

|--------------------------------
:FINFO | adr -- adr info
	dup FDIR 1? ( drop 0 ; ) drop
	dup FNAME
	".r3" =pos 1? ( 2drop 2 ; ) 2drop
	3 ;

:getname | nro -- ""
	3 << 'files + @ 8 >> 'filen + ;

:getinfo | nro -- info
	3 << 'files + @ $ff and ;

:getlvl | nro -- info
	3 << 'files + @ 4 >> $f and ;

:chginfo | nro --
	3 << 'files + dup @ $1 xor swap ! ;

|--------------------------------
:files.clear
	0 'nfiles !
	'filen 'filen> !
	'files dup 'files> ! 'files< !
	;

:files!+
	files> ( files< >?
		8 - dup @+ swap !
		) drop
	files< !+ 'files< !
	8 'files> +!
	;

:files.free
	0 'files ( files> <?
		@+ pick2 >? ( swap rot )
		drop ) drop
	8 >> 'filen +
	( c@+ 1? drop ) drop
	'filen> !
	;

:fileadd
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	drop
	FINFO nivel 4 << or filen> 'filen - 8 << or
	files!+
	FNAME filen> strcpyl 'filen> !
	;

:reload
	'path 
|WIN|	"%s//*" sprint
	ffirst 0? ( drop ; ) 
	( fileadd fnext 1? ) drop
	files> 'files - 3 >> 'nfiles !
	;

:rebuild
	"r3" 'path strcpy
	files.clear
	0 'pagina !
	0 'nivel !
	reload
	;

|-----------------------------
:makepath | actual nivel --
	0? ( drop
		"r3/" 'path strcpy
		getname 'path strcat
		; )
	over 1 -
	( dup getlvl pick2 >=?
		drop 1 - ) drop
	over 1 - makepath drop
	"/" 'path strcat
	getname 'path strcat
	;

:expande
	actual dup
	getlvl makepath
   	actual chginfo
	actual getlvl 1 + 'nivel !
    actual 1 + 3 << 'files + 'files< !
	reload
	;

:remfiles
	actual chginfo
	actual getlvl 1 +
	actual 1 +
	( dup getlvl pick2 >=?
		drop 1 + ) drop
	nip
	actual 1 +
	( swap nfiles <?
		dup 3 << 'files + @
		pick2 3 << 'files + !
		1 + swap 1 + ) drop
	3 << 'files + 'files> !
	files> 'files - 3 >> 'nfiles !
	files.free
	;

:contrae
	'path ( c@+ 1? drop ) drop 1 -
	( 'path >?
		dup c@ $2f =? ( drop 0 swap c! remfiles ; )
		drop 1 - ) drop
	remfiles ;

|-------------
#nameaux * 1024

:next/ | adr -- adr'
	( c@+ 1?
		$2f =? ( drop 0 swap 1 - c!+ ; )
		drop ) nip ;

:getactual | adr actual -- actual
	( nfiles <?
		dup getname pick2 = 1? ( drop nip ; )
		drop 1 + ) nip ;


|--------------------------
:remlastpath
	'path ( c@+ 1? drop ) drop 1 -
	( dup c@ $2f <>? drop 1 - ) drop
	0 swap c! ;

:setactual
	actual dup getlvl makepath
	actual getinfo 1 >? ( remlastpath ) drop
	actual
	dup getinfo $3 and 
	2 <? ( 2drop "" 'name strcpy 0 'source ! ; ) 
	3 =? ( drop getname 'name strcpy 0 'source ! ; ) 
	drop
	getname 'name strcpy
	here $ffff + dup 'source ! 
	'name 'path "%s/%s" sprint load 
	0 swap ! 
	;	

|---------------------
:traverse | adr -- adrname
	dup next/ 0? ( drop ; )
	( dup next/ 1?
		swap
		actual getactual 'actual !
		expande
		) drop ;

:loadm
	'nameaux "mem/menu.mem" load
	'nameaux =? ( drop ; )
	'nameaux dup c@ 0? ( 2drop ; ) drop
	0 'actual !
	0 'path !
	traverse
	actual getactual nip
	pagina linesv + 1- >=? ( dup linesv - 1+ 'pagina ! )
	'actual !
	drop
	setactual
	;

:savem
    'path 'name strcpy
	"/" 'name strcat
	actual getname 'name strcat
	'name 1024 "mem/menu.mem" save ;

|--------------------------
:remlastpath
	'path ( c@+ 1? drop ) drop 1 -
	( dup c@ $2f <>? drop 1 - ) drop
	0 swap c! ;

|--------------------------------
|WIN| :conadj | adjust console
|WIN| 	.getconsoleinfo
|WIN| 	.alsb .showc .insc
|WIN| 	evtmouse	
|WIN| 	;

:checkerror
	mark
	here dup "mem/error.mem" load
	over =? ( 2drop empty ; ) 
	0 swap c!
	.cr .bred .white 
	" * ERROR * " .println
	.reset
	.println
	.bblue .white
	"<ESC> to continue..." .println
	waitesc
	empty
	;

:runfile
	actual -? ( drop ; )
	getinfo $7 and 2 <? ( drop ; ) drop
|WIN|	.reset .cls
|LIN|	.reset .masb	
	"mem/error.mem" delete
	'path
|WIN| 	"cmd /c r3 ""%s/%s"" 2>mem/error.mem"
|LIN| 	"./r3lin ""%s/%s"" 2>mem/error.mem"
	sprint sys
	checkerror
|WIN|	conadj 
|LIN|	.alsb
	;

:r3info
|WIN| 	"r3 r3/editor/r3info.r3"
|LIN| 	"./r3lin r3/editor/r3info.r3"
	sys ;

:r3edit
|WIN| 	"r3 r3/editor/code-edit.r3"
|LIN| 	"./r3lin r3/editor/code-edit.r3"
	sys 
|WIN|	conadj 
	;

|--------------------------------
:editfile
	actual getname 'path "%s/%s" sprint 'name strcpy
	'name 1024 "mem/main.mem" save
|LIN|	r3info
|LIN|	|cerror 1? ( drop ; ) drop	
	r3edit
	;

:editmap
	actual getname 'path "%s/%s" sprint 'name strcpy
	'name 1024 "mem/mapedit.mem" save
|WIN| 	"r3 r3/editor/map-edit.r3"
|LIN| 	"./r3lin r3/editor/map-edit.r3"
	sys
|WIN|	conadj
	;

:editbmap
 	actual getname 'path "%s/%s" sprint 'name strcpy
 	'name 1024 "mem/bmapedit.mem" save
|WIN| 	"r3 r3/editor/bmap-edit.r3"
|LIN| 	"./r3lin r3/editor/bmap-edit.r3"
 	sys
|WIN| 	conadj
 	;
	
:f2edit
	actual -? ( drop ; )
	|getinfo $3 and 2 <>? ( drop ; ) drop
	getname 
	".r3" =pos 1? ( 2drop editfile ; ) drop
	".map" =pos 1? ( 2drop editmap ; ) drop
	".bmap" =pos 1? ( 2drop editbmap ; ) drop
	| ".png"
	| ".jpg"
	| ".txt"
	drop
	;

:r3d4
 	actual -? ( drop ; )
 	getname 
 	".r3" =pos 0? ( 2drop ; ) drop
 	'path "%s/%s" sprint 'name strcpy
 	'name 1024 "mem/main.mem" save
 	"r3 r3/d4/d4-coded.r3"
	sys 
|WIN| 	conadj 
	;

|--------------------------------
|===================================
#newprg1 "| r3 sdl program
^r3/lib/sdl2gfx.r3
	
:demo
	0 SDLcls
	$ff0000 SDLColor
	10 10 20 20 SDLFRect
	SDLredraw
	
	SDLkey 
	>esc< =? ( exit )
	drop ;

:main
	""r3sdl"" 800 600 SDLinit
	'demo SDLshow
	SDLquit ;	
	
: main ;"
|===================================
:createmap
	'path "%s/%s" sprint 'name strcpy
	mark
	0 ,q
	10 , 10 ,
	100 ( 1? 1 - 0 ,c ) drop
	0 ,c
	'name savemem
	empty	

	'name 1024 "mem/mapedit.mem" save
	'name 1024 "mem/menu.mem" save
|WIN| 	"r3 r3/editor/map-edit.r3"
|LIN| 	"./r3lin r3/editor/map-edit.r3"
	sys
	rebuild
	loadm
|WIN|	conadj
	;

	
:createfile
	'name 
	".map" =pos 1? ( drop createmap ; ) drop
	".r3" =pos 0? ( ".r3" pick2 strcat ) drop

|	remaddtxt
	|'name 
	'path "%s/%s" sprint 'name strcpy

	mark
	'newprg1 ,s
	'name savemem
	empty

	'name 1024 "mem/main.mem" save
	'name 1024 "mem/menu.mem" save

	r3edit

	rebuild
	loadm
	;

:newfile
	0 linesv 1+ .at 
	.bblue .white .eline 
	" Name: " .print
	.input 
	'pad 'name strcpy
	'name c@ 0? ( drop ; ) drop
	createfile
	;

|--------------------------------
:fenter
	actual
	getinfo $f and
	0? ( drop expande ; )
	1 =? ( drop contrae ; )
	drop

	actual
	getname
	".r3" =pos 1? ( drop runfile ; ) drop
	drop
	;

:fdn
	actual nfiles 1 - >=? ( drop ; )
	1 + pagina linesv + 1- >=? ( dup linesv - 1+ 'pagina ! )
	'actual !
	setactual ;

:fup
	actual 0? ( drop ; )
	1 - pagina <? ( dup 'pagina ! )
	'actual !
	setactual ;

:fpgdn
	actual nfiles 1 - >=? ( drop ; )
	20 + nfiles >? ( drop nfiles 1 - ) 'actual !
	actual pagina linesv + 1-
	>=? ( dup linesv - 1+ 'pagina ! ) drop
	setactual ;

:fpgup
	actual 0? ( drop ; )
	20 - 0 <? ( drop 0 )
	pagina <? ( dup 'pagina ! )
	'actual !
	setactual ;

:fhome
	actual 0? ( drop ; ) drop
	0 'actual ! 0 'pagina !
	setactual ;

:fend
	actual nfiles 1 - >=? ( drop ; ) drop
	nfiles 1 - 'actual !
	actual 1 + pagina linesv + 1-
	>=? ( dup linesv - 1+ 'pagina ! ) drop
	setactual ;

|--------------------------------
#filecolor 1 2 3 4 

:colorfile | n -- n
	actual =? ( ,bwhite ,black ; )
    dup getinfo $3 and
	3 << 'filecolor + @ ,fc 
	;

:printfn | n --
	,sp
	dup getlvl 1 << ,nsp
	dup getinfo $3 and "+-  " + c@ ,c ,sp 
	getname ,s ,sp
	;

:drawl | n --
	,sp colorfile printfn ,nl ;
	
:drawtree
	1 2 ,at
	0 ( linesv <?
		dup pagina +
		nfiles >=? ( 2drop ; )
		,reset
    	drawl 
		1 + ) drop ;

:drawsrc	
 	source 0? ( drop ; ) drop
 	235 ,bc 
 	40 2 linesv cols 41 - source code-print
 	;

:screen
	mark
	,hidec
	,reset ,cls ,bblue 
	1 1 ,at	" r3 " ,s
	"^[7mF1^[27m Run ^[7mF2^[27m Edit ^[7mF3^[27m New " ,printe ,eline
	drawtree
	drawsrc
	,bblue ,white	
	0 linesv 2 + ,at 
	'name 'path " %s/%s  " ,print ,eline
	,showc 
	memsize type	| type buffer
	empty			| free buffer	
	;

|-------------------------------------
|WIN| #exit 0

|WIN| :evkey	
|WIN| 	evtkey
|WIN| 	]ESC[ =? ( 1 'exit ! ) | esc
|WIN| 	[ENTER] =? ( fenter )
|WIN| 	[UP] =? ( fup ) | up
|WIN| 	[DN] =? ( fdn ) | dn
|WIN| 	[PGUP] =? ( fpgup )
|WIN| 	[PGDN] =? ( fpgdn )
|WIN| 	[HOME] =? ( fhome )
|WIN| 	[END] =? ( fend )
|WIN| 	[F1] =? ( fenter )
|WIN| 	[F2] =? ( f2edit )
|WIN| 	[F3] =? ( newfile )
|WIN| 	|[F4] =? ( newfolder ) | f4 - new folder
|WIN| 	[F5] =? ( r3d4 ) | F5 - NEW VERSION
|WIN| 	drop 
|WIN| 	;

|WIN| :evwmouse 
|WIN| 	evtmw pagina +
|WIN| 	clamp0 nfiles 1- min 
|WIN| 	'pagina !
|WIN| 	;
	
|WIN| :evmouse
|WIN| 	evtm
|WIN| 	1 =? ( drop ; ) | move 
|WIN| 	4 =? ( drop evwmouse ; )
|WIN| 	drop
|WIN| 	evtmb 0? ( drop ; ) drop	
|WIN| 	evtmxy swap
|WIN| 	40 >? ( 2drop f2edit ; ) drop
|WIN| 	1- pagina +
|WIN| 	actual =? ( drop fenter ; )
|WIN| 	'actual !
|WIN| 	setactual 
|WIN| 	;
	
|WIN| :evsize	
|WIN| 	.getconsoleinfo
|WIN| 	rows 1- 'linesv !
|WIN| 	;

:teclado | key --
    [ENTER] =? ( fenter screen ) 
	
	[UP] =? ( fup screen ) | up
	[DN] =? ( fdn screen ) | dn
	[PGUP] =? ( fpgup screen )
	[PGDN] =? ( fpgdn screen )
	[HOME] =? ( fhome screen )
	[END] =? ( fend screen )
	
	[f1] =? ( fenter screen )
	[f2] =? ( f2edit screen ) |editfile screen )
	[f3] =? ( newfile screen )
	|[f4] =? ( newfolder screen ) | f4 - new folder
	drop 
	;
	
|---------------------------------
:main
	rebuild
|LIN|	.getconsoleinfo rows 1- 'linesv !
|LIN|	.alsb 
	loadm
|WIN|	( exit 0? drop
|WIN|		screen
|WIN|		getevt
|WIN|		$1 =? ( evkey )
|WIN|		$2 =? ( evmouse )
|WIN|		$4 =? ( evsize )
|WIN|		drop ) drop

|LIN|	screen
|LIN|	( getch [esc] <>? teclado ) drop | esc
|LIN|	.reset |.cls
|LIN|	.masb	
	savem 
	;

: |<<<<<<<<<<<<<<< BOOT
|WIN| conadj evsize
	main 
|WIN| .masb 
	;
