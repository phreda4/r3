| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/textb.r3
|^r3/util/ttext.r3

^r3/dev/ui.r3
	
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

:64>dtf | dt64 -- "d-m-y h:m"
	mark
	dup 32 >> $ff and ,2d "-" ,s
	dup 44 >> $f and ,2d "-" ,s
	dup 48 >> $ffff and ,d " " ,s
	dup 24 >> $ff and ,2d ":" ,s
	16 >> $ff and ,2d " " ,s
	empty here
	;

:64>dtc | dt64 -- "y-m-d h:m:s"
	;

|--------------------------------	
#basepath "r3"
#fullpath * 1024

#dirini
#dirnow

#fileini
#filenow

#memdirs
#memdirs>

#memfiles
#memfiles>
#link

|8k names
#memdirs * $ffff
#memdirs>
	
#filen 
#filen>

#lvl 0

:+dir
	dup FDIR 0? ( 2drop ; ) drop
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	here filen - 
	lvl 24 << or
	memdirs> !+ 'memdirs> !
	,s 0 ,c ;
	
:adddir | path --
	ffirst ( +dir fnext 1? ) drop  ;
		
:rebuildir
	here 'filen ! 
	'memdirs 'memdirs> !
	'basepath
|WIN|	"%s//*" sprint
	adddir
	0 memdirs> !+ 'memdirs> !
	
	'memdirs ( memdirs> <? 
		dup @
		|0? ( 1 'lvl +! )
		dup $ffffff and filen +
		swap !+
		) drop
	;
	
:pdir
	0? ( drop "-----" .println ; )
	$ffffff and filen + .println ;
	
:printdir
	'memdirs
	( memdirs> <? @+ pdir ) drop ;

|-----------------------
#stkd * 1024
#stkd> 'stkd
#lvl 0
#memfile

:+dir
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	over FDIR 0? ( 3drop ; ) drop
	a> 'link !		|  f name
	|over FSIZEF 32 <<
	0 | no size for dir
	|pick2 FDIR 24 << or 
	a!+
	over FWRITEDT dt>64 a!+
	a> strcpyl dup 
	
	a> .println
	a> stkd> !+ 'stkd> !
	
	a> - link +! | save link 
	>a
	drop ;

:adddirs
	1 'lvl +!
	'basepath
|WIN|	"%s//*" sprint
	ffirst ( 
		+dir
		fnext 1? ) drop 
	0 a!+ .cr ;	
	
:traversedirs
	here dup 'memfile ! >a
	'stkd 'stkd> !
	'basepath stkd> !+ 'stkd> !
	'basepath 'fullpath strcpy
	0 'lvl !
	( stkd> 'stkd >?
		dup .println
		adddirs
		-8 'stkd> +! ) drop
	;

|-------------------	
	
:+file | f --
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	a> 'link !		|  f name
	over FSIZEF 32 <<
	pick2 FDIR 24 << or a!+
	over FWRITEDT dt>64 a!+
	a> strcpyl dup 
	a> - link +! | save link 
	>a
	drop ;
	
:rebuild
	here dup 'memfiles !
	>a 
	'basepath
|WIN|	"%s//*" sprint
	ffirst ( +file
		fnext 1? ) drop 
	0 a> !+ dup 'memfiles> ! 'here !
	;


:pathpanel
	48 4 uiXy
	256 22 uiBox
	'exit "r3" uitbtn
	"/" uitlabel
	'exit "juegos" uitbtn
	"/" uitlabel
	'exit "2025" uitbtn
	;

:dirpanel
	48 32 uiXy
	256 22 uiBox
	memdirs 
	( @+ 1?
		$ffffff and
		swap 8 + dup uilabel
		+ ) 2drop ;
	
:filpanel
	304 32 uiXy 
	256 22 uiBox
	memfiles 
	( @+ 1?
		$ffffff and
		swap 8 + dup uilabel
		+ ) 2drop  ;

#pad "hola" * 1024
		
:namepanel
	32 500 uiXy
	512 24 uiBox
	'pad 1024 uiInputLine | 'buff max --
	;
	
|-----------------------------

:main
	0 SDLcls gui
	uiHome
	3 4 uiPad
|	sw 2/ sh 2/ ttitle sprite
	
|	filelist
	pathpanel
	
	uiV
	dirpanel
	filpanel
	namepanel
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
#diskdirs
|-----------------------------
|-----------------------------	
:	
	.cls
	"R3d4 IDE" .println

	|"R3d4" 0 SDLfullw | full windows | 
	|"R3d4" 1280 720 SDLinit
	|"media/ttf/Roboto-bold.ttf" 24 TTF_OpenFont 'uifont !
|	tini
	|18 uifontsize

	mark
	here 'diskdirs !
	"r3" uiScanDir
	
|	mark
|	rebuildir
|	printdir

	
	|rebuild

|traversedirs
	
|	"r3/forth IDE" $5ffff 300 200 font textbox 'ttitle !
	
	|'main SDLshow
	|SDLquit 
	
	waitesc
	;
