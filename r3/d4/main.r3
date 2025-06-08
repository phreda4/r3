| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/textb.r3
^r3/util/ttext.r3

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

:,2d 10 <? ( "0" ,s ) ,d ;

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
	
#memfiles
#memfiles>
#link

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
	0 a!+		
	a> dup 'here ! 
	'memfiles> !
	;

:filelist
	0 0 txy
	memfiles 
	( @+ 1?
		dup 32 >> 
		"%d " tprint
		dup 24 >> $ff and 
		"%d " tprint
		$ffffff and
		swap @+
		64>dtf temits
		|"%h " tprint
		dup temits
		+
		tcr
		) 2drop ;
|------------------------	
#font
#ttitle

:sizefont
	;
	
|-----------------------------
:main
	0 SDLcls 
	sw 2/ sh 2/ ttitle sprite
	
	filelist
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
	rebuild

	"r3/forth IDE" $5ffff 300 200 font textbox 'ttitle !
	
	'main SDLshow
	SDLquit 
	;
