| immi core: layout, ids, mouse/keyboard state, zones
| PHREDA 2025
|
| No drawing here. A backend (immsdl.r3 or immgl.r3) must be included
| before this file: the words it uses are txh txfont txfont@
| (the font height is always the live one, there is no copy of it here).
| Widgets are in immwid.r3

||||||||||||||||||||||||||||||| uncoment for metabuild
|^r3/util/immsdl.r3
|||||||||||||||||||||||||||||||

^r3/lib/math.r3
^r3/lib/sdl2.r3

|uncomment for generate help
|^r3/util/immsdl.r3

|--- Layout
##fx ##fy ##fw ##fh | frame (layout area)
##flpadx 0 ##flpady 0
##flcols 1 ##flrows 1 #flcur 0
##flcolm	1 ##flrowm 1
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

::uiPad | x y -- ; set the horizontal and vertical padding inside the frame (pixels) and recompute the cursor box
	'flpady ! 'flpadx ! f2c ;

#flstack * 128 | 16 levels
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
	
	
::uiWinBox | -- x y w h ; the current frame
	fx fy fw fh ;

::uiLn | -- ; end of a row of uiNBtn/uiTlabel: back to the left of the frame and down one line
	fx flpadx + 'cx !
	fw flpadx 2* - 'cw !
	txh flpady + 'cy +! ;

::uiFull | -- ; the frame is the whole screen
	0 0 sw sh uiBox ;
	
:flx+! flstack> 8 - dup w@ rot + clamp0 swap w! ;
:fly+! flstack> 8 - 2 + dup w@ rot + clamp0 swap w! ;
:flw+! flstack> 8 - 4 + dup w@ rot + clamp0 swap w! ;
:flh+! flstack> 8 - 6 + dup w@ rot + clamp0 swap w! ;
	
::uiPush | -- ; push the current frame on the layout stack (16 levels, the last ones are ignored)
	flstack> 'flstack 128 + >=? ( drop ; ) drop
	fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
::uiPop | -- ; pop the layout stack and make that frame the current one
	flstack> 'flstack <=? ( drop ; ) drop
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
#idf ##idfh #idfa | focus
##mdrag | number of the place (uiPlace) under the mouse while dragging, -1 if none
#mdragh	
#idfl		| idf last

##uistate
##keymd | key modifiers: bit 0 is set while a shift key is down
##btnMouse | mouse button mask (sdlb) of the last press on a widget

::uiEx! | -- ; mark the last widget as activated (uiEx? is true)
	uistate $100 or 'uistate ! ;
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
	sdlkey
	<shift> =? ( keymd 1 or 'keymd ! ) 
	>shift< =? ( keymd 1 nand 'keymd ! ) 
	drop ;

#uilastwidget 0
#uilastpos 0 
#uilaststy 0 0 0 0
#uiLastfont 0

:isavepos | x y w h -- 
	'uilastpos w!+ w!+ w!+ w! ;
	
:iloadpos | --
	'uilastpos w@+ 'ch ! w@+ 'cw ! w@+ 'cy ! w@ 'cx ! ;
	

|------- LAST WIDGET
##idfs

::uiExitWidget | -- ; close the pending last widget (the open combo list)
	idfs dup 'idfh ! 'idfa !
	0 'uilastwidget ! ;

::uiSaveLast | x y w h 'vector -- ; save a widget (its box and font) to be executed by uiEnd after the others (used for pop-ups)
	'uiLastWidget !	| save vector
	isavepos
	| save style
|	'cx dims>64 'uilastpos !
|	'uilaststy 'cifil 3 move	|dsc style

	txfont@ 'uiLastfont !		| save font
	
	idfa 'idfs !
	idfl dup 'idfh ! 'idfa !
	;
	
:uiBacklast |--
	iloadpos
	| pos style font
|	'cifil 'uilaststy 3 move 
	uiLastfont txfont
	;
	
::uiEnd | -- ; end of a gui frame: executes the pending last widget (the open combo list), drawn over the others
	id 1+ 'idfl !
	uilastWidget 0? ( drop ; ) 
	idfa idfl <? ( 2drop uiExitWidget ; ) drop
	txfont@ >r uiBacklast ex r> txfont ;
	
| 0 = normal
| 1 = over (not all sytems)
| 2 = in
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click
##chx

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

