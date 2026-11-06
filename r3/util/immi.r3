| gui v.3
| immediate mode inteface
| PHREDA 2025
|
^r3/lib/sdl2gfx.r3
^r3/lib/color.r3
^r3/util/txfont.r3

|--- Layout
#fx #fy #fw #fh 
#flpadx 0 #flpady 0
#flcols 1 #flrows 1 #flcur 0
#flcolm	1 #flrowm 1
##cx | x of the cursor box (the current widget) in pixels
##cy | y of the cursor box
##cw | width of the cursor box
##ch | height of the cursor box

:f2c
	flpadx fw over 2* - 'cw ! fx + 'cx !
	flpady fh over 2* - 'ch ! fy + 'cy ! ;

::%cw | frac -- px ; fixed point fraction (1.0 = all) of the width of the current frame in pixels
	fw 16 *>> ;
::%ch | frac -- px ; fixed point fraction (1.0 = all) of the height of the current frame in pixels
	fh 16 *>> ;

::uiPading | x y -- ; set the horizontal and vertical padding inside the frame (pixels) and recompute the cursor box
	'flpady ! 'flpadx ! f2c ;

#flstack * 64 | 8 niveles
#flstack> 'flstack

:fl>now | v --
	w@+ 'fx ! w@+ 'fy ! w@+ 'fw ! w@ 'fh ! ;
	
:xywh>fl | x y w h -- v
	$ffff and 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or ; | hhwwyyxx
	
::uiBox | x y w h -- ; set the current frame (layout area) and push it on the layout stack; the cursor box is the frame minus the padding
	2over 'fy ! 'fx ! 2dup 'fh ! 'fw ! 
	xywh>fl 'flstack !+ 'flstack> ! 
	f2c ;
	
	
::uiFull | -- ; the frame is the whole screen
	0 0 sw sh uiBox ;
	
:flx+! flstack> 8 - dup w@ rot + clamp0 swap w! ;
:fly+! flstack> 8 - 2 + dup w@ rot + clamp0 swap w! ;
:flw+! flstack> 8 - 4 + dup w@ rot + clamp0 swap w! ;
:flh+! flstack> 8 - 6 + dup w@ rot + clamp0 swap w! ;
	
::uiPush | -- ; push the current frame on the layout stack (8 levels)
	fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
::uiPop | -- ; pop the layout stack and make that frame the current one
	-8 'flstack> +! flstack> fl>now f2c ;

:uiGet		flstack> 8 - fl>now ;
::uiRest | -- ; make the frame at the top of the layout stack (what uiN uiS uiE uiO leave) the current one
	uiGet f2c ;

| N=^ S=v E=> O=<
| - is full minus the number
::uiN | lines -- ; take a strip of that height (pixels) from the top of the current frame and make it current; the rest stays on the stack (a negative value is the whole height minus it)
	-? ( fh + ) uiGet dup fly+! dup neg flh+!	'fh ! f2c ;
::uiS | lines -- ; like uiN taking the strip from the bottom of the frame
	-? ( fh + ) uiGet dup neg flh+! fh fy + over - 'fy ! 'fh ! f2c ;
::uiE | cols -- ; like uiN taking a strip of that width (pixels) from the right of the frame
	-? ( fw + ) uiGet dup neg flw+! fw fx + over - 'fx ! 'fw ! f2c ;
::uiO | cols -- ; like uiN taking a strip of that width (pixels) from the left of the frame
	-? ( fw + ) uiGet dup flx+! dup neg flw+! 'fw ! f2c ;
	
::uiAt | x y -- ; move the cursor box to the grid cell x y
	flrowm dup flpady 2* - 'ch !
	* fy + flpady + 'cy !
	flcolm dup flpadx 2* - 'cw !
	* fx + flpadx + 'cx ! ;
	
::uiTo | w h -- ; set the size of the cursor box to w x h grid cells
	flrowm * flpady 2* - 'ch !
	flcolm * flpadx 2* - 'cw ! ;

::uiGrid | c r -- ; divide the frame in c columns by r rows (adjusted to fit) and put the cursor at the cell 0 0
	2dup 'flrows ! 'flcols ! 0 'flcur !
	fh swap /mod dup 2/ 'fy +! neg 'fh +! 'flrowm !
	fw swap /mod dup 2/ 'fx +! neg 'fw +! 'flcolm !
	0 0 uiAt ;
	
::uiNext | -- ; move the cursor to the next grid cell going along the rows (it goes back to the first one at the end)
	flcur 1+ 
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod swap uiAt ;
	
::uiNextV | -- ; move the cursor to the next grid cell going down the columns
	flcur 1+
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod uiAt ;
	
|---- IMMGUI
#id	#idh #ida 	| now hot active
#idf #idfh #idfa | focus
#wid #wida	| panel now active
##mdrag | number of the place (uiPlace) under the mouse while dragging, -1 if none
#mdragh	
#idfl		| idf last

#uistate
##keymd | key modifiers: bit 0 is set while a shift key is down
##btnMouse | mouse button mask (sdlb) of the last press on a widget

:flagEx!	uistate $100 or 'uistate ! ;
::uiEx? | -- flag ; not 0 if the last widget was activated (clicked or Enter pressed)
	uistate $100 and ;

::uiOvr | 'v -- ; execute 'v while the mouse is over the widget
	uiState $f and 1 <>? ( 2drop ; ) drop ex ;
::uiDwn | 'v -- ; execute 'v on the frame the button is pressed on the widget
	uiState $f and 2 <>? ( 2drop ; ) drop ex ;
::uiSel | 'v -- ; execute 'v while the widget is active (button held with the mouse over it)
	uiState $f and 3 <>? ( 2drop ; ) drop ex ;
::uiClk | 'v -- ; execute 'v when the widget is clicked (released over it)
	uiState $f and 6 <>? ( 2drop ; ) drop ex ;
::uiUp | 'v -- ; execute 'v when the mouse button is released or the mouse goes out after being pressed
	uiState $f and 5 <? ( 2drop ; ) drop ex ;

::uiFocusIn | 'v -- ; execute 'v on the frame the widget gets the keyboard focus
	uiState $10 nand? ( 2drop ; ) drop ex ;
::uiFocus | 'v -- ; execute 'v while the widget keeps the keyboard focus (after the first frame)
	uiState $20 nand? ( 2drop ; ) drop ex ;

::uiStart | -- ; start of a gui frame, once per frame before the widgets: frame = whole screen, ids and drag reset, shift key tracked
	uiFull
	idfh -? ( id nip ) id >? ( 0 nip ) dup 'idf ! 'idfh !
	idh 'ida ! -1 'id !
	mdragh 'mdrag ! -1 'mdragh ! 
	0 'wid ! 
	sdlkey
	<shift> =? ( keymd 1 or 'keymd ! ) 
	>shift< =? ( keymd 1 nand 'keymd ! ) 
	drop ;

#uilastwidget 0
#uilastpos 0 
#uilaststy 0 0 0 0
#uiLastfont 0
#uidata1 0 
#uidata2 0 

:fitinwin | x y w h -- x y w h 
	2swap 	| w h x y 
	dup pick3 + sh - 0 max - 0 max swap | 1.0 %h
	dup pick4 + sw - 0 max - 0 max swap | 1.0 %w
	2swap ;

:isavepos | x y w h -- 
	'uilastpos w!+ w!+ w!+ w! ;
	
:iloadpos | --
	'uilastpos w@+ 'ch ! w@+ 'cw ! w@+ 'cy ! w@ 'cx ! ;
	

|------- LAST WIDGET
#idfs

::uiExitWidget | -- ; close the pending last widget (the open combo list)
	idfs dup 'idfh ! 'idfa !
	0 'uilastwidget ! ;

::uiSaveLast | x y w h 'vector -- ; save a widget (its box and font) to be executed by uiEnd after the others (used for pop-ups)
	'uiLastWidget !	| save vector
	isavepos
	| save style
|	'cx dims>64 'uilastpos !
|	'uilaststy 'cifil 3 move	|dsc style
	txFont@ 'uiLastfont !		| save font	
	idfa 'idfs !
	idfl dup 'idfh ! 'idfa !
	;
	
:uiBacklast |--
	iloadpos
	| pos style font
|	'cifil 'uilaststy 3 move 
	uiLastfont txfont ;
	
::uiEnd | -- ; end of a gui frame: executes the pending last widget (the open combo list), drawn over the others
	id 1+ 'idfl !
	uilastWidget 0? ( drop ; ) 
	idfa idfl <? ( 2drop uiExitWidget ; ) drop
	uiBacklast
	ex ;
	
| 0 = normal
| 1 = over (not all sytems)
| 2 = in
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click
#chx

:uIn? | x y -- 0/-1
	sdlx cx - $ffff and cw >? ( drop 0 ; ) drop
	sdly cy - $ffff and chx >? ( drop 0 ; ) drop 
	-1 ;

:stMouse | -- state
|	0 'uistate !	
	1 'id +! 
	ida -1 =? ( drop 			| no active
		uIn? 0? ( ; ) drop		| out->0
		sdlb 0? ( drop 1 ; ) |drop	| over->1
		'BtnMouse !
|		id dup 'idh ! 'idfh ! -1 'idfx ! 1 ; )	| in->2(prev)
		id dup 'idh ! 'idfh ! 2 ; )	| in->2(prev)
	id <>? ( drop 0 ; ) 	|	 active no this->0
|	idfx <>? ( 'idfx ! 2 ; ) | in->2
	drop
	uIn? 0? ( drop
		sdlb 1? ( drop 4 ; ) drop	| active out->4
		-1 'idh ! 5 ; ) drop		| out up->5
	sdlb 1? ( drop 3 ; ) drop 		| active->3
	-1 'idh ! 6 ; 					| click->6		

| 0 - No
| 1 - Start focus
| 2 - In focus
:stFocus | -- flag
	id 
	idf <>? ( drop 0 ; )
	wid 1- 'wida ! 
	idfa <>? ( 'idfa ! $10 ; ) | in 
	drop $20 ; | stay

|-- interactive box
::uiZone | -- ; define the interaction area of the widget (cursor box, one text line high) and compute its mouse and focus state; read it with uiOvr uiClk uiFocus...
	txh 'chx !
	stMouse stFocus or 'uistate ! ;

::uiZoneL | nlines -- ; like uiZone with an area of nlines text lines
	txh * 'chx !
	stMouse stFocus or 'uistate ! ;

::uiZoneW | -- ; like uiZone with the whole cursor box height
	ch 'chx !
	stMouse stFocus or 'uistate ! ;
	
#auxbox
::uiZoneBox | x y w h -- ; set the cursor box to x y w h (the old one is kept for uiBackBox) and use it as the interaction area
	cx cy cw ch 'auxbox w!+ w!+ w!+ w!
	dup 'ch ! 'chx ! 'cw ! 'cy ! 'cx !
	stMouse stFocus or 'uistate ! ;
	
::uiBackBox | -- ; restore the cursor box saved by uiZoneBox
	'auxbox w@+ 'ch ! w@+ 'cw ! w@+ 'cy ! w@ 'cx ! ;
	
	
|-- place to go in drag (index n)	
::uiPlace | n -- ; (drag and drop) the cursor box is the place number n: if the mouse is over it mdrag gets n
	ch 'chx !
	uIn? 0? ( 2drop ; ) drop 'mdragh ! ;


::uiRefocus | -- ; clear the keyboard focus (the first widget takes it)
	-1 'idfa ! ;
::uiFocus>> | -- ; move the keyboard focus to the next widget
	1 'idfh +! ;
::uiFocus<< | -- ; move the keyboard focus to the previous widget
	-1 'idfh +! ;

::tabfocus | -- ; action of the Tab key: next widget, or the previous one if shift is down
	keymd 1 and? ( drop uiFocus<< ; ) drop uiFocus>> ;

:ui+a
	dup 'cx +! 'cy +! ;
:ui+c
	dup ui+a
	2* neg dup 'cw +! 'ch +! ;
	
|---- Draw words 
#recbox [ 0 0 0 0 ] | for sdl2

:c2recbox
	ch cw cy cx 'recbox d!+ d!+ d!+ d! ;

:cl2recbox
	chx cw cy cx 'recbox d!+ d!+ d!+ d! ;
	
::uiFill | -- ; fill the cursor box with the draw color
	cx cy cw ch frect ;
::uiRect | -- ; outline of the cursor box
	cx cy cw ch rect ;
::uiRFill | round -- ; fill the cursor box with rounded corners of that radius
	cx cy cw ch fround ;
::uiRRect | round -- ; outline of the cursor box with rounded corners
	cx cy cw ch round ;
::uiCRect | -- ; outline of the cursor box as a capsule (radius = half of the smaller side)
	cw ch min 2/ cx cy cw ch round ;
::uiCFill | -- ; fill the cursor box as a capsule
	cw ch min 2/ cx cy cw ch fround ;
::uiTex | texture -- ; draw the texture in the cursor box
	c2recbox 'recbox swap imageb ;

::uiWinBox | -- x y w h ; the current frame
	fx fy fw fh ;

|--- grid lines
::uiLineGridV | -- ; draw the vertical lines of the grid
	fx flcolm +
	flcols 1- ( 1? 1-
		over fy fh over + lineV
		swap flcolm + swap ) 2drop ;
		
::uiLineGridH | -- ; draw the horizontal lines of the grid
	fy flrowm +
	flrows 1- ( 1? 1-
		fx pick2 fw pick2 + lineH
		swap flrowm + swap ) 2drop ;
	
::uiLineGrid | -- ; draw the lines of the grid
	uiLineGridH uiLineGridV ;

|---- Style

|  disable|focus|over|normal
#colBac	$ff222222ff111111 | background
#colFil $ff80D9FFff005D85 | fill
#colTxt $ffffffffffffffff | texto

#colFoc $ffffff 

::stDang | -- ; widget color style: danger (red)
	$ffff8099ff85001B 'colfil ! ;
::stWarn | -- ; widget color style: warning (orange)
	$ffffBF29fff55D00 'colfil ! ;
::stSucc | -- ; widget color style: success (green)
	$ff5BCD9Aff1F6546 'colfil ! ;
::stInfo | -- ; widget color style: info (cyan, the default)
	$ff80D9FFff005D85 'colfil ! ;
::stLink | -- ; widget color style: link (blue)
	$ff4258FFff000F85 'colfil ! ;
::stDark | -- ; widget color style: dark gray
	$ff393F4Cff14161A 'colfil ! ;
::stLigt | -- ; widget color style: light gray
	$ffaaaaaaff888888 'colfil ! ;

::stColor | rgb -- ; widget color style from a color $RRGGBB (the second color is a lighter mix)
	dup $ffffff $7f colmix  
	32 << or $ff000000ff000000 or
	'colfil ! ;
	
|--- fill widget
::uilFill | -- ; fill the interaction area (one text line high) with the draw color
|	colBac color 
	cx cy cw chx frect ;
::uilRFill | round -- ; like uilFill with rounded corners
|	colBac color 
	cx cy cw chx fround ; | round --
::uilCFill | -- ; like uilFill as a capsule
|	colBac color 
	cw chx min 2/ cx cy cw chx fround ;
::uilTex | texture -- ; draw the texture in the interaction area
	cl2recbox 'recbox swap imageb ; | texture --

|--- focus
::uilRect | -- ; outline one pixel bigger than the interaction area (focus rectangle)
	cx 1- cy 1- cw 2 + chx 2 + rect ;
::uilRRect | round -- ; like uilRect with rounded corners
	cx 1- cy 1- cw 2 + chx 2 + round ;
::uilCRect | -- ; like uilRect as a capsule
	cw 2 + chx 2 + min 2/ cx 1- cy 1- cw 2 + chx 2 + round ;

:colBack	colBac color ;
:colFill	colFil color ;
:colFocus	colFoc color ;
:colText	colTxt txrgb ;

|---- text cursor
::uil.. | -- ; move the cursor down one text line
	txh 'cy +! ;
::ui.. | -- ; move the cursor down one text line plus the padding
	txh flpady + 'cy +! ;
	
::ui-- | -- ; draw a horizontal separator line and move the cursor down
	colFill
	cx cy 1+ cw 2 rect
	flpady 7 + 'cy +! ;

|---- helptext
::ttwrite | "text" -- ; write the text left aligned at the cursor box
	cx 
	|ch txh - 2/ cy +
	cy txat txwrite ;

::ttwritec | "text" -- ; write the text centered in the cursor box width
	txw | "" w   
	cw swap - 2/ cx +
	|ch txh  - 2/ cy +
	cy txat txwrite ;

::ttwriter | "text" -- ; write the text right aligned in the cursor box
	txw | "" w 
	cw cx + swap -
	|ch txh - 2/ cy +
	cy txat txwrite ;
	
:txicon | char --
	txh over txch - 2/  | char ny
	0 over tx+at
	swap txemit
	0 swap neg tx+at ;
	
::uiTlabel | "text" -- ; label as wide as its text: write it centered and move the cursor right (for rows of widgets)
	txw 4 + 'cw ! ttwritec cw 'cx +! ;
	
|---- widget
::uiLabel | "text" -- ; write the text left aligned and move down one line
	ttwrite	ui.. ;
	
::uiLabelC | "text" -- ; write the text centered and move down one line
	ttwritec ui.. ;
	
::uiLabelR | "text" -- ; write the text right aligned and move down one line
	ttwriter ui.. ;

::uiText | "" align -- ; write the text wrapped in the cursor box with the alignment of txalign ($VH)
	txalign >r cw ch cx cy r> txText ;	

:kbBtn
	sdlkey 
	<ret> =? ( flagEx! )
	<tab> =? ( tabfocus ) 
	drop ;

	
::uiTBtn | 'click "" align -- ; button with wrapped text of the given alignment and rounded fill; executes 'click when activated
	uiZoneW 
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill 8 uilRFill 
	[ kbBtn colFocus 8 uiRrect ; ] uiFocus
	colText uiText
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiNBtn | 'click "" -- ; button as wide as its text; it moves the cursor right; executes 'click when activated
	txw 4 + 'cw !
	uiZone
	'flagex! uiClk
	colFill uilFill 
	[ kbBtn colFocus uiLRect ; ] uiFocus
	ttwritec
	cw 'cx +! 
	uiEx? 0? ( 2drop ; ) drop ex ;	
	
::uiBtn | 'click "" -- ; button with centered text; executes 'click when activated (click or Enter)
	uiZone
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill uilFill 
	[ kbBtn colFocus uiLRect ; ] uiFocus
	colText uiLabelC 
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiRBtn | 'click "" -- ; button with rounded corners (radius 6)
	uiZone
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill 6 uiLRFill 
	[ kbBtn colFocus 6 uiLRRect ; ] uiFocus
	colText uiLabelc 
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiCBtn | 'click "" -- ; button with capsule shape
	uiZone
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill uiLCFill 
	[ kbBtn colFocus uiLCRect ; ] uiFocus
	colText uiLabelc
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

|---- Horizontal slide
:kbSlide
	sdlkey 
	<tab> =? ( tabfocus ) 
	<le> =? ( <dn> nip ) 
	<dn> =? ( over dup @ 1- clamp0 swap ! flagEx! )
	<ri> =? ( <up> nip ) 
	<up> =? ( over dup @ 1+ pick4 clampmax swap ! flagEx! )	
	drop ;

:slideh | 0.0 1.0 'value --
	sdlx cx - cw clamp0max 
	2over swap - | Fw
	cw */ pick3 +
	over ! flagEx! ;
	
:slideshow | 0.0 1.0 'value --
	colBack uiLFill
	[ kbSlide colFocus uiLRect ; ] uiFocus
	colFill
	dup @ pick3 - 
	cw 8 - pick4 pick4 swap - */ cx 1+ +
	cy 2 + 
	6 txh 4 - 
	frect ;
	
::uiSliderf | min max 'value -- ; horizontal slider of a fixed point value (it shows 2 decimals); left and right keys change it
	uiZone
	'slideh uiSel |
	slideshow
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | min max 'value -- ; horizontal slider of an integer value
	uiZone
	'slideh uiSel | 'dn 'move --	
	slideshow
	@ .d uiLabelC
	2drop ;	
	
:progreshow | 0.0 1.0 'value --
	colBack uiLFill
	[ kbSlide colFocus uiLRect ; ] uiFocus	
	colFill
	dup @ pick3 - cw pick4 pick4 swap - */
	txh
	cx cy 2swap
	frect ;

::uiProgressf | min max 'value -- ; horizontal progress bar of a fixed point value (it can be dragged)
	uiZone
	'slideh uiSel | 'dn 'move --	
	progreshow
	@ .f2 uiLabelC
	2drop ;

::uiProgressi | min max 'value -- ; horizontal progress bar of an integer value
	uiZone
	'slideh uiSel | 'dn 'move --	
	progreshow
	@ .d uiLabelC
	2drop ;	
	
	
|---- Vertical slide
:slidev | 0.0 1.0 'value --
	sdly cy - ch clamp0max 
	2over swap - | Fw
	ch */ pick3 +
	over ! flagEx! ;
	
:slideshowv | 0.0 1.0 'value --
	ColBack uiFill
	[ kbBtn colFocus uiLRect ; ] uiFocus	
	ColFill
	dup @ pick3 - 
	ch 8 - pick4 pick4 swap - */ cy 1+ +
	cx 2 + swap
	cw 4 - 6 
	frect ;

::uiVSliderf | min max 'value -- ; vertical slider of a fixed point value
	uiZone
	'slidev uiSel
	slideshowv
	@ .f2 uiLabelC
	2drop ;

::uiVSlideri | min max 'value -- ; vertical slider of an integer value
	uiZone
	'slidev uiSel
	slideshowv	
	@ .d uiLabelC
	2drop ;		
	
|----- list mem (intern)
#cntlist #indlist

:makeindx | 'adr -- 
	here dup 'indlist ! >a
	( dup a!+ >>0
		dup c@ 1? drop ) 2drop
	a> dup here - 3 >> 'cntlist !
	'here ! ;
	
:calcindx | 'adr -- 'adr
	0 over ( dup c@ 1? drop
		>>0 swap 1+ swap ) 2drop
	'cntlist ! ;
	
::uiNindx | n -- str ; string number n of the list being drawn by the list widgets ("" if n is out of range)
	cntlist >=? ( drop "" ; )
	3 << indlist + @ ;

#lvl	|  $1f:level $20:have_more $80:is_open	
:getval	| adr lvl -- adr nlvl	
	lvl <=? ( ; ) 
	a> 8 - @ dup 				
	c@ $20 or over c!
	c@ $80 and? ( drop ; ) | draw
	2drop
	( >>0 dup c@ 1? 
		$1f and lvl >? drop ) ;
	
:maketree |
	0 'lvl !
	here dup 'indlist ! >a
	( dup a!+ >>0
		dup c@ 1? 
		$1f and getval 'lvl ! 
		) 2drop
	a> dup here - 3 >> 'cntlist !
	'here ! ;

|----- CHECK
:focoCheck
	colFocus uiLRect 
	sdlkey
	<tab> =? ( tabfocus  )
	<ret> =? ( 1 pick2 << pick3 @ xor pick3 ! flagEx! ) | 'var n key -- 'var n key
	drop ;

:ic	over @ 1 pick2 << |and? ( drop "[x]" ; ) drop "[ ]" ;
	and? ( drop 139 ; ) drop 138 ;
	
:icheck | 'var n -- 'var n
	uiZone 
	'focoCheck uiFocus 
	[ 1 over << pick2 @ xor pick2 ! flagEx! ; ] uiClk
	cx cy txat 
	ic txicon 32 txemit a@+ txwrite
	ui.. ;
		
::uiCheck | 'var 'list -- ; one check box per string of the list (0-terminated strings, an empty one ends the list); each bit of the variable is a box
	mark makeindx
	indlist >a
	0 ( cntlist <? icheck 1+ ) 2drop
	empty ;	

|----- RADIO
:focoRadio
	colFocus uiLRect 
	sdlkey
	<tab> =? ( tabfocus  )
	<ret> =? ( over pick3 ! flagEx! ) | 'var n key -- 'var n key
	drop ;

:ir over @ |=? ( "(o)" ; ) "( )" ;
	=? ( 137 ; ) 136 ;

:iradio | 'var n --
	uiZone
	'focoRadio uiFocus
	[ 2dup swap ! flagEx! ; ] uiClk
	cx cy txat 
	ir txicon 32 txemit a@+ txwrite
	ui.. ;

::uiRadio | 'var 'list -- ; one radio button per string of the list; the variable holds the number of the chosen one
	mark makeindx
	indlist >a
	0 ( cntlist <? iradio 1+ ) 2drop
	empty ;	
	
|--------
#lx #ly

:wwlist	| 'var max d -- 'var max d ; Wheel 
	dup pick3 8 + 
	dup @ rot + 
	cntlist pick4 -
	clamp0max
	swap ! ;
	
:backline 
	lx ly cw txh frect ;
	
:slidev | 'var max -- 'var max
	cntlist over - 1+	| maxi
	sdly cy - chx 1- clamp0max | 'v max rec (0..curh)
	chx */ pick2 8 + ! ;

:cscroll | 'var max -- 'var max
	cntlist >=? ( ; ) 
	$ffffff color 
	cntlist over - 1+	| maxi
	cx cw + 10 -		| 'var max maxi x 
	pick3 8 + @ 		| 'var max maxi x ini
	chx pick3 / 	| 'var max maxi x ini hp
	swap over *	cy +	| 'var max maxi x hp ini*hp
	8 rot
	>r >r 4 -rot r> r> fround	
	drop ;
	
:kbList
	SDLw 1? ( wwlist ) drop 
	sdlkey 
	<ret> =? ( flagEx! )
	<tab> =? ( tabfocus ) 
	<up> =? ( pick2 dup @ 1- clamp0 swap ! flagEx! )
	<dn> =? ( pick2 dup @ 1+ cntlist 1- clampmax swap ! flagEx! )	
	drop 
	cscroll ;

:cklist | 'var max --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop slidev ; ) drop )
	sdly cy - txh / pick2 8 + @ + cntlist 1- clampmax pick2 !
	;
	
:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colFill backline )
	|overl =? ( colBack uiFill )
	uiNindx 
	lx ly txat txwrite txh 'ly +!
	;

::uiList | 'var cntl 'list -- ; list box of cntl lines over the strings of the list; 'var points to two cells: the selected number and the first line shown (it scrolls with the wheel, keys or the bar)
	over uiZoneL
	mark makeindx
	cx 'lx ! cy 'ly !
	0 ( over <? ilist 1+ ) drop
	[ kblist colFocus uiLRect ; ] uiFocus	
	'cklist uiClk
	2drop
	empty 
	chx flpady + 'cy +! ;
	
|----- TREE
| #vtree 0 0

:cktree | 'var cnt --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop slidev ; ) drop )
	sdly cy - txh / pick2 8 + @ + cntlist 1- clampmax
	pick2 @ <>? ( pick2 ! ; )
	3 << indlist + @ 
	dup c@ $80 xor swap c! ;

:iicon | n -- 
	$20 nand? ( drop 32 txicon ; )
	7 >> 1 and 129 + txicon ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colFill backline )
|	overl =? ( overfil uiFill )
	uiNindx 
	c@+ 0? ( 2drop ch 'ly +! ; )
	dup $1f and 4 << lx + ly txat iicon txwrite 
	txh 'ly +! ;

::uiTree | 'var cntl 'list -- ; like uiList for a tree: every string starts with a byte (level in $1f, $20 has children, $80 open) and a click toggles a folder
	over uiZoneL
	mark maketree
	cx 'lx ! cy 'ly !
	0 ( over <? itree 1+ ) drop
	[ kblist colFocus uiLRect ; ] uiFocus
	'cktree uiClk
	2drop
	empty 
	chx flpady + 'cy +! ;
	
|----- COMBO
:comboclk | 'var cnt -- 'var cnt
	cntlist <? ( sdlx cx - cw 12 - >? ( drop slidev ; ) drop )
	sdly cy - txh / pick2 8 + @ + cntlist 1- clampmax pick2 !
	uiExitWidget 
	;

:combolist | --
	uidata1 uidata2 
	mark makeindx
	cntlist 6 min
	dup uiZoneL
	colBack uiLFill
	colFocus uiLRect
	cx 'lx ! cy 'ly !
	0 ( over <? ilist 1+ ) drop
	cscroll
	kblist
	'comboclk uiClk
	2drop
	empty ;	
	
	
:iniCombo | 'var 'list -- 'var 'list 
	2dup 'uidata2 ! 'uidata1 !
	cx cy cw ch 'combolist uiSaveLast ;
	
:kblistc	
	colFocus uiLRect
	'iniCombo uiClk 
	calcindx | for cntlist
	kblist 
	idfs idfh =? ( -1 'idfs ! flagex! ) drop | ex when exit last widget
	;
	
::uiCombo | 'var 'list -- ; combo box: it shows the chosen string of the list (the variable holds its number); a click opens the list of up to 6 lines, drawn by uiEnd
	uiZone 
	colBack uiLFill
	'kblistc uiFocus
	mark makeindx	
	cx cy txat
	@ uiNindx txwrite
	cx cw + txh - cy txat 130 txicon
	empty ui.. ;

|--- Edita linea
#cmax
#padi>	| inicio
#pad>	| cursor
#padf>	| fin

:lins  | c -- ;
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1- padf> over - 1+ cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> <=? ( drop ; )
	dup padi> - cmax >=? ( swap 1- swap -1 'pad> +! ) drop
	'padf> ! ;
:0lin 0 padf> c! ;
:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> padi> <=? ( drop ; ) dup 1- swap padf> over - 1+ cmove -1 'padf> +! -1 'pad> +! ;
:kder pad> padf> <? ( 1+ ) 'pad> ! ;
:kizq pad> padi> >? ( 1- ) 'pad> ! ;
:kup
	pad> ( padi> >?
		1- dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1- 'pad> ! ;

#modo 'lins

:cursor | 'var max
	msec $100 and? ( drop ; ) drop
	$a0a0a0 color
	cx cy txat 
	padi> pad> 
	modo 'lins =? ( drop txcur ; ) drop
	txcuri ;
	
|----- ALFANUMERICO
:iniinput | 'var max -- 'var max
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
	colFocus cx 1- cy 1- cw 2 + txh 2 + rect 
	$ffffff color |	uiRect
	cursor 
	SDLchar 1? ( modo ex ; ) drop
	SDLkey 0? ( drop ; )
	<ins> =? ( chmode )
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )
	
	<ret> =? ( flagEx! )
	<tab> =? ( tabfocus ) 
|	<dn> =? ( nextfoco ) <up> =? ( prevfoco )
	drop
	
	;

::uiInputLine | 'buff max -- ; text line editor on the buffer (max bytes): insert or overwrite (Ins), left, right, home, end, backspace, delete, Tab and Enter
	uiZone
	Colback uiLFill
	'iniinput uiFocusIn
	'proinputa uiFocus 
	drop
	ttwrite ui.. ;	
		