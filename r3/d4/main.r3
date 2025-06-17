| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/textb.r3
^r3/util/ttext.r3

|-----------------------------
|autolayout
#font
#fontcol $ffffff

#xl #yl #wl #hl 

#padx #pady	#marx #mary
#curx #cury #curw #curh

#recbox 0 0

:tt>
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

:ttemitl | "text" --
	font swap fontcol TTF_RenderUTF8_Blended
	Surf>wh swap | suf h w
	cury pady + curx padx + 'recbox d!+ d!+ d!+ d!
	tt> ;

:ttemitc | "text" --
	font swap fontcol TTF_RenderUTF8_Blended
	Surf>wh swap | suf h w
	curh 2/ pick2 2/ - cury +
	curw 2/ pick2 2/ - curx +
	'recbox d!+ d!+ d!+ d!
	tt> ;

:ttemitr | "text" --
	font swap fontcol TTF_RenderUTF8_Blended
	Surf>wh swap | suf h w
	cury pady + curw curx + pick2 - 'recbox d!+ d!+ d!+ d!
	tt> ;

::uiWin | x y w h --
	'hl ! 'wl ! 2dup 'yl ! 'xl ! 'cury ! 'curx ! ;

::uiCols | cols --
	wl swap /mod 'marx ! 'curw ! ;

::uiRows | rows --
	hl swap /mod 'mary ! 'curh ! ;

::uiBox | w h --
	'curh ! 'curw ! ;

:flow<	curw neg 'curx +! ;
:flow^	curh neg 'cury +! ;

:flowv	curh 'cury +! ;
:flowcr xl 'curx ! flowv ;
:flow>	curx curw + xl wl + >? ( drop flowcr ; ) 'curx ! ;

#flownext 'flowv

::ui> 'flow> 'flownext ! ;
::ui< 'flow< 'flownext ! ;
::uiv 'flowv 'flownext ! ;
::ui^ 'flow^ 'flownext ! ;


::uiFill | color --
	SDLcolor
	curx cury curw curh SDLFRect ;
	
::uiNext | -- ; next
	flownext ex ;
	
::uiLabel | "" --
	ttemitl uiNext ;
::uiLabec | "" --
	ttemitc uiNext ;
::uiLaber | "" --
	ttemitr uiNext ;
	
::uiBtn | v "" --
	curx cury curw curh guiBox
	[ $ffffff sdlcolor curx cury curw curh sdlRect ; ] guiI 
	ttemitc onClick uiNext ;	

	
|------------------------	
#basepath "r3"

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
#dirini
#dirnow

#fileini
#filenow

#memdirs
#memdirs>

#memfiles
#memfiles>
#link
	
:+dir
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	over FDIR 0? ( 3drop ; ) drop
	a> 'link !		|  f name
	over FSIZEF 32 <<
	|pick2 FDIR 24 << or 
	a!+
	over FWRITEDT dt>64 a!+
	a> strcpyl dup 
	a> - link +! | save link 
	>a
	drop ;
	
:adddir | path --
	ffirst ( 
		|dup FDIR 1? ( adddir ) drop
		+dir
		fnext 1? ) drop  ;
	
:rebuildir
	here dup 'memdirs ! >a 
	'basepath
|WIN|	"%s//*" sprint
	adddir
	0 a> !+ dup 'memdirs> ! 'here !
	;
	
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


||||||||||||||||
:filelist
	0 0 txy
	memfiles 
	( @+ 1?
		|dup 32 >> "%d " tprint | size
		|dup 24 >> $ff and "%d " tprint | type
		$ffffff and
		swap @+
		|64>dtf temits | DT
		drop
		dup temits
		tcr
		+ ) 2drop ;
||||||||||||||||
#str "›˅˃ˇ▶▼>V"
		
:dirpanel
	font 18 TTF_SetFontSize
	48 32 256 300 uiWin
	256 22 uiBox
	memdirs 
	( @+ 1?
		$ffffff and
		swap 8 + dup uilabel
		+ ) 2drop 
		'str uilabec
	
|	$00ff00 uiFill
|	'exit "unis" uiBtn
	
|	$007f00 uiFill
|	"coso" uiLabel
|	$003f00 uiFill
|	"dos" uiLabel
|	$001f00 uiFill
|	"tres" uiLabel
	;
	
:filpanel
	font 18 TTF_SetFontSize
	304 32 256 300 uiWin
	256 22 uiBox
	memfiles 
	( @+ 1?
		$ffffff and
		swap 8 + dup uilabel
		+ ) 2drop 

	;
|------------------------	
#ttitle

:sizefont
	;
	
:paneles
	;
|-----------------------------
:main
	0 SDLcls gui
	sw 2/ sh 2/ ttitle sprite
	
|	filelist
	
	dirpanel
	filpanel
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	.cls
	"R3d4 IDE" .println
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 24 TTF_OpenFont 'font !
	tini
	
	mark
	rebuildir
	rebuild
	
	"r3/forth IDE" $5ffff 300 200 font textbox 'ttitle !
	
	'main SDLshow
	SDLquit 
	;
