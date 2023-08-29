| immg develop with SDL backend
| PHREDA 2023

^r3/lib/gui.r3

^r3/win/sdl2gfx.r3
^r3/util/ttfont.r3
^r3/lib/input.r3

#winx 10 #winy 10
#winw 10 #winh 10

#padx 2 #pady 2
##curx 10 ##cury 10
##boxw 100 ##boxh 20

##immcolorwin $666666	| window 
##immcolortwin $444444	| title window (back)
##immcolortex $ffffff	| text
##immcolorbtn $0000ff	| button

#icons
#immfont
#immfontsh 

::immgui 
	gui 
	immfontsh 8 + 'boxh !
	;
	
::immat 'cury ! 'curx ! ;
::immbox 'boxh ! 'boxw ! ;
::immfont! dup 'immfont ! ttfont "A" ttsize 'immfontsh ! drop ;

|----------------------	
::imm>>
	padx 1 << boxw + 'curx +! ;	
::imm<<
	padx 1 << boxw + neg 'curx +! ;	
::immdn
	pady 1 << boxh + 'cury +! ;
::immcr
	winx padx + 'curx ! 
	pady 1 << boxh + 'cury +! ;	

::immln
	winx padx + 'curx ! boxh 'cury +! ;	
	
|--- place
:plgui
	curx padx + cury pady + boxw boxh guiBox ;

:plxywh
	curx padx + cury pady + boxw boxh ;

::immcur | x y w h --
	pick3 winx + pick3 winy + pick3 pick3 guiBox
	'boxh ! 'boxw ! 'cury ! 'curx ! ;
	
::immcur> | -- cur
	curx cury 16 << or boxw 32 << or boxh 48 << or ;
	
::imm>cur | cur --
	dup $ffff and 'curx !
	16 >> dup $ffff and 'cury !
	16 >> dup $ffff and 'boxw !
	16 >> $ffff and 'boxh ! ;
	
|--- label
::immlabel | "" --
	immcolortex ttColor
	curx padx + 
	boxh immfontsh - 1 >> cury + pady + 
	ttat ttprint ;
	
::immlabelc | "" --
	immcolortex ttColor
	ttsize boxw rot - 1 >> curx + padx +
	boxh rot - 1 >> cury + pady + 
	ttat ttprint ;

::immlabelr | "" --
	immcolortex ttColor
	ttsize boxw rot - curx + padx -
	boxh rot - 1 >> cury + pady +
	ttat ttprint ;

::immListBox | lines --
	boxh * curx cury rot boxw swap guiBox ;

|--- text in list, no pad
::immback | color --
	SDLColor curx padx + cury boxw boxh SDLFRect ;

::immblabel | "" --
	immcolortex ttColor
	curx padx + 
	boxh immfontsh - 1 >> cury + 
	ttat ttprint ;
	
|--- icon
::immicon | nro x y --
	icons rot rot tsdraw ;
	
::immiconb | nro --
	immcolortex icons tscolor 
	boxw 24 - 1 >> curx + padx +
	boxh 21 - 1 >> cury + 
	immicon ;
	
::immwidth |w -- 
	'boxw ! ;	

|--- widget	
::immbtn | 'click "" --
	plgui
	immcolorbtn [ $808080 xor ; ] guiI SDLColor
	plxywh SDLFRect
	immlabelc
	onClick ;	

::immibtn | 'click nro --
	plgui
	immcolorbtn [ $808080 xor ; ] guiI SDLColor
	plxywh SDLFRect
	immiconb
	onClick ;	

|---- Horizontal slide
:slideh | 0.0 1.0 'value --
	sdlx curx padx + - boxw clamp0max 
	2over swap - | Fw
	boxw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	$7f SDLColor
	curx padx + cury pady + boxw boxh SDLFRect
	$3f3fff [ $7f7fff nip ; ] guiI SDLColor
	dup @ pick3 - 
	boxw 8 - pick4 pick4 swap - */ 
	curx padx + 1 + +
	cury pady + 2 + 
	6 
	boxh 4 - 
	SDLFRect ;
	
::immSliderf | 0.0 1.0 'value --
	plgui
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow
	@ .f2 immLabelC
	2drop ;

::immSlideri | 0 255 'value --
	plgui
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow	
	@ .d immLabelC
	2drop ;	

|---- Vertical slide *** incorrect
:slidev | 0.0 1.0 'value --
	sdly cury - boxh clamp0max 
	2over swap - | Fw
	boxh */ pick3 +
	over ! ;
	
#wid	

:scrollshowv | 0.0 1.0 'value --
|	$ff00007f SDLColor
|	curx padx + cury pady + boxw boxh SDLFRect
	$3f3f3f [ $7f7f7f nip ; ] guiI SDLColor
	
	dup @ pick3 - 
	boxh 2 - pick4 pick4 swap - 1 + */ 
	curx padx + 2 + 
	cury pady + 1 + rot +
	boxw 4 - 
	wid
	SDLFRect ;
	
::immScrollv | 0 max 'value --
	plgui
	'slidev dup onDnMoveA | 'dn 'move --	
	boxh pick3 pick3 swap -  1 + / 'wid !
	scrollshowv	
	3drop ;	
	
|----------------------	
:checkic | 'var ""
	over @ 1 nand? ( 60 nip ; ) drop 59 ;
	
::immCheck | 'val "op1" -- ; v op1  v op2  x op3
	plgui
	$ffffff [ $7f7fff nip ; ] guiI icons TSColor
	checkic curx cury immicon
	20 'padx +!
	immLabel
	-20 'padx +!
	[ dup @ 1 xor over ! ; ] onClick
	drop ;
	
|----------------------
#cntlist
	
:makelist | "" -- list
	1 'cntlist !
	here >a
	a> swap
	( c@+ 1?
		$7c =? ( 1 'cntlist +! 0 nip )
		ca!+ ) ca!+ 
	a> 'here !
	drop ;
	
:nlist | here n -- str
	( 1? 1 - swap >>0 swap ) drop ;	
	
|----------------------
:radioic | 'var nro "" -- 'var nro "" 
	pick2 @ pick2 <>? ( 238 nip ; ) drop 236 ;
	
:iglRadio | val nro str -- val nro str
	plgui
	$ffffff [ $7f7fff nip ; ] guiI icons TSColor
	radioic curx cury immicon
	20 'padx +!
	dup immLabel
	-20 'padx +!
	[ over pick3 ! ; ] onClick
	;

::immRadio | 'val "op1|op2|op3" -- ; ( ) op1  (x) op2 ( ) op3
	mark
	makelist
	0 ( cntlist <? swap
		iglRadio immdn |glri
		>>0 swap 1 + ) 3drop 
	empty ;

|----------------------	
::immCombo | 'val "op1|op2|op3" -- ; [op1  v]
	mark
	makelist
	$7f SDLColor
	plgui
	plxywh SDLFRect
	$ffffff [ $7f7fff nip ; ] guiI icons TSColor
	268	curx boxw + 24 - cury immicon
	over @ nlist immLabel
	[ dup @ 1 + cntlist >=? ( 0 nip ) over ! ; ] onClick
	drop
	empty
	;
	
|--------- input text	
|--- Edita linea
#cmax
#padi>	| inicio
#pad>	| cursor
#padf>	| fin

:lins  | c -- ;
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1 - padf> over - 1 + cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> >? (
		dup padi> - cmax >=? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
:0lin 0 padf> c! ;
:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> padi> <=? ( drop ; ) dup 1 - swap padf> over - 1 + cmove -1 'padf> +! -1 'pad> +! ;
:kder pad> padf> <? ( 1 + ) 'pad> ! ;
:kizq pad> padi> >? ( 1 - ) 'pad> ! ;
:kup
	pad> ( padi> >?
		1 - dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1 - 'pad> ! ;

#modo 'lins

::cursoro | pos --
	|ttfont "A" ttsize | w y
|	xs ys >r >r
|	gltextsizecnt drop | w h
|	xs 16 >> + ys 16 >> 8 16 frect
|	r> r> 'ys ! 'xs !
	drop
	;
	
::cursori | pos --
|	xs ys >r >r
|	gltextsizecnt drop | w h
|	xs 16 >> + ys 16 >> 12 + 8 4 frect
|	r> r> 'ys ! 'xs !
	drop
	;

:cursor
	msec $100 and? ( drop ; ) drop
	$ff00 SDLColor
	modo 'lins =? ( drop pad> padi> - cursori ; ) drop
	pad> padi> - cursoro ;
	
|----- ALFANUMERICO
:iniinput | 'var max IDF -- 'var max IDF
	pick2 1 - 'cmax !
	pick3 dup 'padi> !
	( c@+ 1? drop ) drop 1 -
	dup 'pad> ! 'padf> !
	'lins 'modo !
	;

:chmode
	modo 'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;

:proinputa | --
	cursor 
	SDLchar 1? ( modo ex ; ) drop
	SDLkey 0? ( drop ; )
	<ins> =? ( chmode )
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )
	<tab> =? ( nextfoco )
	<ret> =? ( nextfoco )
|	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )
|	<dn> =? ( nextfoco ) <up> =? ( prevfoco )
	drop
	;


|************************************
::immText | 'buff max --
	plgui
	$7f SDLColor
	curx cury boxw padx 1 << + boxh pady 1 << + sdlRect
|	boxh 16 - 1 >> + ttat
|	$7f7f7f [ $ffffff nip ; ] guiI glcolor
	'proinputa 'iniinput w/foco
	'clickfoco onClick
	$ffffff ttcolor
	drop
	curx padx + 
	boxh immfontsh - 1 >> cury + pady + 
	ttat ttprint ;

	
|----- windows
:winxy!
	dup 32 << 32 >> 'winx ! 32 >> 'winy ! ;
	
:winwh!
	dup 32 << 32 >> 'winw ! 32 >> 'winh ! ;

:wintitle | "" --
	immcolorwin SDLColor
	winx winy winw winh SDLFRect
	0 SDLColor
	winx winy winw winh SDLRect
	winx 'curx ! winy 'cury !
	winw padx 1 << - 'boxw ! immfontsh pady + 'boxh !
	immcolortwin SDLColor
	plxywh SDLFRect 
	immlabelc
	| close button
	|'exit 134 immibtn 
	winx winy immfontsh pady + + winw winh immfontsh pady + - guiBox 
	;	
	
#px #py 	
:movwin
	sdlx dup px - swap 'px ! over 8 + d+!
	sdly dup py - swap 'py ! over 12 + d+! ;

:wintit
	dup 8 + 
	@+ dup $ffffffff and 'curx ! 32 >> 'cury ! 
	@ $ffffffff and padx 1 << - 'boxw !
	immfontsh pady 1 << + 'boxh !
	plgui
	[ sdlx 'px ! sdly 'py ! ; ] 'movwin onDnMoveA
	;
	
::immwin | 'win -- 0/1
	dup @ 0? ( nip ; ) drop
	wintit
	dup 8 + @+ winxy! @+ winwh! wintitle
	@ 
	winx padx + 'curx ! 
	winy pady 2 << + immfontsh + 'cury ! 
	winw 1 >> padx 1 << - padx - 'boxw !
	;	

::immnowin | xini yini w h --
	'boxh ! 'boxw !
	dup 'winy ! 'cury ! 
	dup 'winx ! 'curx ! ;

#winlist * 32
#winlist> 'winlist

::immwin! | win --
	winlist> !+ 'winlist> ! ;

:procwin | 'w --
	drop
	;
	
::immwindows
	'winlist ( winlist> <?
		@+ procwin
		) drop ;
	
	
|---------------------- filedlg
#filename * 1024
#path * 1024
#nfiles
#files
#files>
#filenow
#fileini
#filelines
#filescroll
#filen
#filen>
	
:FNAME | adr -- adrname
|WIN| 44 +
|LIN| 19 +
|WEB| 19 +
|RPI| 11 +
	;

:FDIR | adr -- dir
|WIN| @ 4 >>
|LIN| 18 + c@ 2 >>
|WEB| 18 + c@ 2 >>
|RPI| 10 + c@ 2 >>
	;
	
:]file 3 << files + @ ;	
:.name $ffff and filen + ;

:fileadd
	dup FNAME "." = 1? ( 2drop ; ) drop
	dup FDIR 16 << 
	filen> filen - or 	| start string
	files> !+ 'files> !
	FNAME filen> strcpyl 'filen> ! ;
	
:reload
	files 'files> !
	filen 'filen> !
	'path "%s/*" sprint
	ffirst ( fileadd fnext 1? ) drop
	files> files - 3 >> 'nfiles !
	nfiles filelines - 0 max 'filescroll !
	0 'fileini !
	0 'filenow ! 
	;
	
:colorline | n --
	filenow =? ( $7f00 ; ) 0 ;

:printline | n --
	]file | filename
	$10000 and? ( " >" immBLabel )
	14 'curx +!
	.name immBLabel 
	;

:linefile | n -- n 
	dup fileini + nfiles >=? ( drop ; )
	colorline immback
	printline
	;	
	
:listscroll | n --
	filescroll 0? ( 2drop ; ) 
	immcur> >r 
	boxh rot *
	curx boxw + boxh - 
	cury pick2 - 2 -
	rot boxh swap immcur
	0 swap 'fileini immScrollv 
	r> imm>cur
	;
	

:backfolder
	'path ( c@+ 1? drop ) drop 1 -
	( 'path >?
		dup c@ $2f =? ( drop 0 swap c! reload ; )
		drop 1 - ) drop
	reload ;

:setfolder
    .name
	dup ".." = 1? ( 2drop backfolder ; ) drop
	"/" 'path strcat
	'path strcat
	reload
	;

:linenter | nfile --
	]file
	$10000 and? ( setfolder ; )
	.name 'filename strcpy ;

	
:clicklist
	sdly cury - boxh / fileini + 
	filenow =? ( linenter ; )
	dup ]file .name 'filename strcpy 
	'filenow ! ; 
	;
	
::immlist | cnt --
	dup immListBox
	'clicklist onClick	
	0 ( over <? linefile immln 1 + ) drop	
	listscroll
	immcr
	;
	
	
::filedlgini | "" --
	'path strcpy
	15 'filelines !
	mark
	here dup 'files !
	$ffff + dup 'filen ! | 64k names
	'here !
	reload	
	;
	
::filedlgend
	empty ;

#winfiledlg 1 [ 10 10 280 416 ] "FileDlg"

::filedlg
	'winfiledlg immwin 0? ( drop ; ) drop
	232 18 immbox
	'path immLabel immcr
	15 immlist
	'filename 1024 immText immcr 
	immcr
	$7f 'immcolorbtn !
	94 18 immbox
	'exit "LOAD" immbtn imm>>
	'exit "CANCEL" immbtn 
	immcr		
	;

|------
|------ Init
::immSDL | font --
|	"media/ttf/ProggyClean.ttf" 16 TTF_OpenFont 
	immfont!
	24 21 "media/img/icong16.png" tsload 'icons !
	;
