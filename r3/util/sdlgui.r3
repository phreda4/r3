| immg develop with SDL backend
| PHREDA 2023

^r3/lib/gui.r3

^r3/lib/sdl2gfx.r3
^r3/util/ttfont.r3
|^r3/lib/input.r3

#winx 10 #winy 10
#winw 10 #winh 10

##padx 2 | horizontal padding around the widgets in pixels
##pady 2 | vertical padding around the widgets in pixels
##curx 10 | x of the current widget (cursor) in pixels
##cury 10 | y of the current widget (cursor) in pixels
##boxw 100 | width of the widgets in pixels
##boxh 20 | height of the widgets in pixels

##immcolorwin $666666 | window background color $RRGGBB
##immcolortwin $444444 | window title bar color $RRGGBB
##immcolortex $ffffff | text color $RRGGBB
##immcolorbtn $0000ff | button color $RRGGBB

#icons
#immfont
#immfontsh 

#keyevent
|#winevent

#winnow 0
#winhot 0
#winhotn 0
#winlist * 64
#winlist> 'winlist

::immgui | -- ; start of a gui frame, once per frame before the widgets: calls gui and resets the layout (cursor at 0 0, box = screen width by font height + 8)
	gui 
	winhot 'winhotn !
	0 'winhot !
	
	0 'keyevent !
|	0 'winevent !

	0 'winx ! 0 'winy !
	0 'cury ! 0 'curx !
	sw 'boxw !
	immfontsh 8 + 'boxh !
	;
	
::immkey! | 'vec -- ; word to execute at the end of immRedraw of this frame (keyboard handler)
	'keyevent ! ;
|::immwin! 'winevent ! ;
	
::immat | x y -- ; set the cursor (position of the next widget)
	'cury ! 'curx ! ;
::immat+ | x y -- ; move the cursor by x y pixels
	'cury +! 'curx +! ;
::immbox | w h -- ; set the size of the next widgets
	'boxh ! 'boxw ! ;
::immfont! | font -- ; set the TTF font used by the widgets and measure its height
	dup 'immfont ! ttfont! "A" ttwh 'immfontsh ! drop ;
::immpad! | padx pady -- ; set the padding around the widgets
	'pady ! 'padx ! ;
::immwinxy | x y -- ; set the origin of the window and put the cursor inside it with the padding
	2dup 'winy ! 'winx ! pady + swap padx + swap immat ;

|----------------------	
::imm>> | -- ; move the cursor one widget to the right (box width plus the padding of both sides)
	padx 1 << boxw + 'curx +! ;	
::imm<< | -- ; move the cursor one widget to the left
	padx 1 << boxw + neg 'curx +! ;	
::immdn | -- ; move the cursor one widget down (box height plus the padding of both sides)
	pady 1 << boxh + 'cury +! ;
::immcr | -- ; new line: x back to the left of the window and y down one widget
	winx padx + 'curx ! 
	pady 1 << boxh + 'cury +! ;	

::immln | -- ; new line: x back to the left of the window and y down only the box height
	winx padx + 'curx ! boxh 'cury +! ;	
	
|--- place
::plgui | -- ; start a widget at the cursor: guiBox of the current box with the padding
	curx padx + cury pady + boxw boxh guiBox ;

::plxywh | -- x y w h ; rectangle of the widget at the cursor, with the padding
	curx padx + cury pady + boxw boxh ;

::immcur | x y w h -- ; set the guiBox of the rectangle x y w h (relative to the window), draw a gray outline around it and make it the cursor and the box
	pick3 winx + pick3 winy + pick3 pick3 guiBox
	$999999 color pick3 pick3 pick3 pick3 rect
	'boxh ! 'boxw ! 'cury ! 'curx ! 
	;
	
::immcur> | -- cur ; pack the cursor and the box in one value: curx | cury<<16 | boxw<<32 | boxh<<48
	curx cury 16 << or boxw 32 << or boxh 48 << or ;
	
::imm>cur | cur -- ; restore the cursor and the box packed by immcur>
	dup $ffff and 'curx !
	16 >> dup $ffff and 'cury !
	16 >> dup $ffff and 'boxw !
	16 >> $ffff and 'boxh ! ;
	
|--- label
::immlabel | "" -- ; draw the text (formatted, see ttprint) at the left of the current box, vertically centered
	immcolortex ttColor
	curx padx + 
	boxh immfontsh - 1 >> cury + pady + 
	ttat ttprint ;
	
::immlabelc | "" -- ; draw the text centered in the current box
	immcolortex ttColor
	ttwh boxw rot - 1 >> curx + padx +
	boxh rot - 1 >> cury + pady + 
	ttat ttprint ;

::immlabelr | "" -- ; draw the text right aligned in the current box
	immcolortex ttColor
	ttwh boxw rot - curx + padx -
	boxh rot - 1 >> cury + pady +
	ttat ttprint ;

::imm. | "" -- ; draw the text (formatted with sprint) at the cursor and move the cursor right by its width plus padding (inline text)
	immcolortex ttColor
	curx padx + 
	boxh immfontsh - 1 >> cury + pady + 
	ttat sprint dup ttemits
	ttwh drop nip padx 1 << + 'curx +!
	;
	
::immStrC | "" -- ; draw the text centered in the current box (no format)
	immcolortex ttColor
	ttwh boxw rot - 1 >> curx + padx +
	boxh rot - 1 >> cury + pady + 
	ttat ttemits ;

::immListBox | lines -- ; guiBox of a list area of that many box heights
	boxh * curx cury rot boxw swap guiBox ;

|--- text in list, no pad
::immback | color -- ; fill the current box with the color (for the lines of a list)
	color curx padx + cury boxw boxh frect ;

::immblabel | "" -- ; text of a list line at the left of the current box (without the vertical padding)
	immcolortex ttColor
	curx padx + 
	boxh immfontsh - 1 >> cury + 
	ttat ttprint ;
	
|--- icon
::immicon | nro x y -- ; draw the icon nro of the icon set at x y
	icons -rot tsdraw ;
	
::immiconb | nro -- ; draw the icon nro centered in the current box with the text color
	immcolortex icons tscolor 
	boxw 24 - 1 >> curx + padx +
	boxh 21 - 1 >> cury + 
	immicon ;
	
::immwidth | w -- ; set the width of the next widgets
	'boxw ! ;	

|--- widget	
::immbtn | 'click "" -- ; button with centered text: moves 2 pixels while the mouse is over it and executes 'click when clicked
	plgui
	immcolorbtn [ $808080 xor 2 2 immat+ ; ] guiI color
	plxywh frect
	immlabelc
	[ -2 -2 immat+ ; ] guiI
	onClick ;	
	
::immibtn | 'click nro -- ; button with the icon nro
	plgui
	immcolorbtn [ $808080 xor 2 2 immat+ ; ] guiI color
	plxywh frect
	immiconb
	[ -2 -2 immat+ ; ] guiI
	onClick ;	

::immtbtn | 'click "" -- ; button as wide as its text; the background shows only while the mouse is over it
	ttwh drop 'boxw !
	plgui
	[ immcolorbtn color plxywh frect 2 2 immat+ ; ] guiI
	imm.
	[ -2 -2 immat+ ; ] guiI
	onClick ;

::immebtn | 'click "" -- ; button with the text only (no background), as wide as its text
	ttwh drop 'boxw !
	plgui
	[ 2 2 immat+ ; ] guiI
	immlabelc
	[ -2 -2 immat+ ; ] guiI
	onClick ;

::immzone | 'click -- ; invisible clickable area of the current box
	plgui onClick ;

|---- Horizontal slide
:slideh | 0.0 1.0 'value --
	sdlx curx padx + - boxw clamp0max 
	2over swap - | Fw
	boxw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	$7f color
	curx padx + cury pady + boxw boxh frect
	$3f3fff [ $7f7fff nip ; ] guiI color
	dup @ pick3 - 
	boxw 8 - pick4 pick4 swap - */ 
	curx padx + 1 + +
	cury pady + 2 + 
	6 
	boxh 4 - 
	frect ;
	
::immSliderf | min max 'value -- ; horizontal slider of a fixed point value between min and max (it shows the value with 2 decimals)
	plgui
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow
	@ .f2 immLabelC
	2drop ;

::immSlideri | min max 'value -- ; horizontal slider of an integer value between min and max
	plgui
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow	
	@ .d immLabelC
	2drop ;	

|----------------------	
:checkic | 'var ""
	over @ 1 nand? ( 60 nip ; ) drop 59 ;
	
::immCheck | 'val "text" -- ; check box: a click toggles bit 0 of the variable
	plgui
	$ffffff [ $7f7fff nip ; ] guiI icons TSColor
	checkic curx cury immicon
	20 'padx +!
	immLabel
	-20 'padx +!
	[ dup @ 1 xor over ! ; ] onClick
	drop ;
	
|---- Vertical slide *** incorrect
:slidev | 0.0 1.0 'value --
	sdly cury - boxh 4 - clamp0max 
	2over swap - 1 + | Fw
	boxh */ pick3 +
	over ! ;
	
#wid	

:scrollshowv | 0.0 1.0 'value --
|	$ff00007f color
|	curx padx + cury pady + boxw boxh frect
	$7f7f7f [ $1f1f1f nip ; ] guiI color
	
	dup @ pick3 - 
	boxh 4 - pick4 pick4 swap - 1 + */ 
	curx padx + 
	cury pady + rot + 
	boxw 4 - wid 1 - frect ;
	
::immScrollv | 0 max 'value -- ; vertical scroll bar for the value between 0 and max (the code notes it is incorrect)
	plgui
	'slidev dup onDnMoveA | 'dn 'move --	
	boxh pick3 pick3 swap - 1 + / 'wid !
	scrollshowv	
	3drop ;	
	
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

::immRadio | 'val "op1|op2|op3" -- ; radio buttons, one line per option: the variable holds the number (0 is the first) of the chosen one
	mark
	makelist
	0 ( cntlist <? swap
		iglRadio immdn |glri
		>>0 swap 1 + ) 3drop 
	empty ;

|----------------------	
::immCombo | 'val "op1|op2|op3" -- ; shows the chosen option; a click goes to the next one (it is not a drop down list)
	mark
	makelist
	$7f color
	plgui
	plxywh frect
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

:cursor | 'var max
	msec $100 and? ( drop ; ) drop
	$a0a0a0 color
	modo 'lins =? ( drop padi> pad> ttcursor drop ; ) drop
	padi> pad> ttcursori drop ;
	
|----- ALFANUMERICO
:iniinput | 'var max IDF -- 'var max IDF
	dup 1- 'cmax !
	over dup 'padi> !
	( c@+ 1? drop ) drop 1-
	dup 'pad> ! 'padf> !
	'lins 'modo !
	;

:chmode
	modo 'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;

:proinputa | --
	$ffffff color
	curx cury boxw padx 1 << + boxh pady 1 << + rect

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
::immInputLine | 'buff max -- ; line editor of the text in 'buff (max bytes): insert or overwrite (Ins), left, right, home, end, backspace and delete; tab and enter go to the next widget
	plgui
	$222222 color
	curx cury boxw padx 1 << + boxh pady 1 << + frect
|	boxh 16 - 1 >> + ttat
|	$7f7f7f [ $ffffff nip ; ] guiI glcolor
	curx padx + 
	boxh immfontsh - 1 >> cury + pady + 
	ttat 
	'proinputa 'iniinput w/foco
	'clickfoco onClick
	$ffffff ttcolor
	drop
	ttemits ;


|----- ENTERO
:iniinputi
	dup 'cmax ! ;

:knro
	SDLchar 0? ( drop ; ) $30 <? ( drop ; ) $39 >? ( drop ; )
	$30 - cmax @ 10 * + cmax ! ;

|	ttx rot + tty rot 
|	sizechar
|	swap frect
	
:proinputi
	$ffffff color
	curx cury boxw padx 1 << + boxh pady 1 << + rect
	|1 cursor drop
	knro
	sdlkey
	<back> =? ( cmax @ 10 / cmax ! )
	<del> =? ( cmax @ 10 / cmax ! )
	|<-> =? ( cmax neg 'cmax ! )
	<tab> =? ( nextfoco )
	<ret> =? ( nextfoco )
	drop ;

|************************************
::immInputInt | 'var -- ; integer input: the digits typed are appended, backspace or delete divide by 10 (no negative numbers)
	plgui
	$222222 color
	curx cury boxw padx 1 << + boxh pady 1 << + frect
	curx padx + 
	boxh immfontsh - 1 >> cury + pady + 
	ttat 
	'proinputi 'iniinputi w/foco
	'clickfoco onClick
	$ffffff ttcolor
	@ "%d" ttprint 
	;

|----- windows
:winxy!
	dup 32 << 32 >> 'winx ! 32 >> 'winy ! ;
	
:winwh!
	dup 32 << 32 >> 'winw ! 32 >> 'winh ! ;
	
::immwin! | 'winword -- ; add a window to the list drawn by immRedraw ('winword draws the window and its widgets); it is not added twice
	'winlist ( winlist> <?
		@+ pick2 =? ( 3drop ; ) drop ) drop
	winlist> !+ 'winlist> ! ;
	
:windrop | win adr+  -- 
	( winlist> <?
		dup @ over 8 - !
		8 + ) 2drop 	
	-8 'winlist> +! ;
		
::immwin$ | 'winword -- ; remove the window from the list
	'winlist ( winlist> <?
		@+ pick2 =? ( drop windrop ; ) drop ) drop
	winlist> !+ 'winlist> ! ;
	
::winexit | -- ; close the window that has the mouse over it (it is the action of the close button)
	winhotn 0? ( drop ; ) drop 
	-8 'winlist> +!
	0 'winhot ! | need this!!!
|	winevent exe
	;

:wintitle | "" --
	immcolorwin color
	winx winy winw winh 
	pick3 pick3 pick3 pick3 frect
	guiBox
	[ winnow 'winhot ! ; ] guiI
	0 color
	winx winy winw winh rect
	
	winx 'curx ! winy 'cury !
	winw padx 1 << - 'boxw ! immfontsh pady + 'boxh !
	immcolortwin color
	plxywh frect 
	immlabelc
	|---- close button
	$444444 'immcolorbtn !
	22 'boxw ! curx winw + 26 - 'curx !
	'winexit 91 immibtn 
	|----
	winx winy immfontsh pady + + winw winh immfontsh pady + - guiBox 
	;	
	
#px #py 	
:movwin
	sdlx dup px - swap 'px ! over 8 + d+!
	sdly dup py - swap 'py ! over 12 + d+! ;

:wintit
|	winnow winhot <>? ( drop ; ) drop
	dup 8 + 
	@+ dup $ffffffff and 'curx ! 32 >> 'cury ! 
	@ $ffffffff and padx 1 << - 'boxw !
	immfontsh pady 1 << + 'boxh !
	plgui
	[ sdlx 'px ! sdly 'py ! ; ] 'movwin onDnMoveA
	;
	
::immwin | 'win -- 0/flags ; draw the window of the record 'win (flags, x y w h in four dwords, title): flag 1 = open, flag 2 = comes to the front; handles dragging by the title and the close button; returns 0 if it is closed, else puts the cursor and the box inside the window
	dup @ 
	$1 nand? ( 2drop 0 ; )
	$2 and? ( winnow 'winhot ! ) drop | all in top
	wintit
	dup 8 + @+ winxy! @+ winwh! wintitle
	@ 
	winx padx + 'curx ! 
	winy pady 2 << + immfontsh + 'cury ! 
	winw 1 >> padx 1 << - padx - 'boxw !
	;	

::immnowin | x y w h -- ; set the region for the widgets without a window frame
	'boxh ! 'boxw !
	dup 'winy ! 'cury ! 
	dup 'winx ! 'curx ! ;

::immwinbottom | 'win -- ; set the height of the window record to the cursor y reached (the window fits its content)
	cury winy - swap 20 + d! ;

:win2front
	winhot 0? ( drop ; )
	dup @ winlist> 8 - dup @
|	winlist> 8 - =? ( drop ; )
	-rot ! swap ! ;
	
::immRedraw | -- ; execute the word of every window of the list, bring the clicked window to the front and execute the key handler set with immkey!
	'winlist ( winlist> <? dup 'winnow !
		@+ ex
		) drop 
	win2front 		
	keyevent 1? ( dup ex ) drop
|	winevent 1? ( dup ex ) drop
	;

|----- static windows

:wintitles | "" --
	immcolorwin color
	winx winy winw winh 
	pick3 pick3 pick3 pick3 frect
	pick3 pick3 pick3 pick3 guiBox
	0 color rect
	winx 'curx ! winy 'cury !
	winw padx 1 << - 'boxw ! immfontsh pady + 'boxh !
	immcolortwin color
	plxywh frect 
	immlabelc
	winx winy immfontsh pady + + winw winh immfontsh pady + - guiBox 
	;	
	
::immwins | 'win -- ; like immwin for a fixed window: no dragging, no close button
	|dup @ |$2 and? ( winnow 'winhot ! ) drop | all in top
	|wintit
	dup 8 + @+ winxy! @+ winwh! wintitles
	@ 
	winx padx + 'curx ! 
	winy pady 2 << + immfontsh + 'cury ! 
	winw 1 >> padx 1 << - padx - 'boxw !
	;

|------ Init
::immSDL | font -- ; start the gui with the TTF font and load the icons media/img/icong16.png (tiles of 24x21)
|	"media/ttf/ProggyClean.ttf" 16 TTF_OpenFont 
	immfont!
	24 21 "media/img/icong16.png" tsload 'icons !
	;
