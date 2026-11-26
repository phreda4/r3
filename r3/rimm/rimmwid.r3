| RIMM widgets: same words as immwid.r3, built in layers
|
|   cell    (rimmcore)   where the widget goes: uiCols, uiSpan, rowh
|   sense   uiZone + uiClk uiSel uiFocus...  (rimmcore)
|   skin    sk kind  how it looks (rimmtheme), a theme can replace it
|   content ct* words   what is inside (text, icon, your own word)
|   action  the 'click vector or the variable
| A button of icon is the same sense and action as the text one: only the
| content changes (uiBtnX). A backend must be included before this file.
|
^r3/rimm/rimmcore.r3
^r3/rimm/rimmtheme.r3

:ui+a
	dup 'cx +! 'cy +! ;
:ui+c
	dup ui+a
	2* neg dup 'cw +! 'ch +! ;

|---- Draw words (cursor box)
#recbox [ 0 0 0 0 ] | for textures

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
::uiCRect | -- ; outline of the cursor box as a capsule
	cw ch min 2/ cx cy cw ch round ;
::uiCFill | -- ; fill the cursor box as a capsule
	cw ch min 2/ cx cy cw ch fround ;
::uiTex | texture -- ; draw the texture in the cursor box
	c2recbox 'recbox swap imageb ;

::uilFill | -- ; fill the interaction area with the draw color
	cx cy cw chx frect ;
::uilRFill | round -- ; like uilFill with rounded corners
	cx cy cw chx fround ;
::uilCFill | -- ; like uilFill as a capsule
	cw chx min 2/ cx cy cw chx fround ;
::uilTex | texture -- ; draw the texture in the interaction area
	cl2recbox 'recbox swap imageb ;
::uilRect | -- ; outline one pixel bigger than the interaction area
	cx 1- cy 1- cw 2 + chx 2 + rect ;
::uilRRect | round -- ; like uilRect with rounded corners
	cx 1- cy 1- cw 2 + chx 2 + round ;
::uilCRect | -- ; like uilRect as a capsule
	cw 2 + chx 2 + min 2/ cx 1- cy 1- cw 2 + chx 2 + round ;

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

|---- cursor
::uil.. | -- ; move the cursor down one row
	rh 'cy +! ;
::ui.. | -- ; the widget is done: next cell (columns) or down one row plus the padding
	rh uiAdvH ;

::ui-- | -- ; separator: a line across the frame, in its own row
	uiLnEnd uiCol# uiSpan
	colFillN
	fx flpadx + cy rh 2 >> + fw flpadx 2* - 1 frect
	rh 2/ uiAdvH ;

::uiClip | -- ; clip the drawing to the interaction area
	cx cy cw chx gclip ;
::uiUnclip | -- ; remove the clip
	gclip0 ;

|---- text: centered vertically in the row, whatever the font
:tty | -- y
	cy rh txh - 2/ + ;

::ttwrite | "text" -- ; text left aligned in the cursor box
	cx tty txat txwrite ;
::ttwritec | "text" -- ; text centered in the cursor box width
	txw cw swap - 2/ cx + tty txat txwrite ;
::ttwriter | "text" -- ; text right aligned in the cursor box
	txw cw cx + swap - tty txat txwrite ;
::ttinl | "text" -- ; like ttwrite with the padding of the theme (inside fields)
	cx tpad + tty txat txwrite ;
::ttinr | "text" -- ; like ttwriter with the padding of the theme
	txw cw cx + swap - tpad - tty txat txwrite ;

::uiTlabel | "text" -- ; label as wide as its text: write it centered and move the cursor right (rows of widgets)
	txw 4 + 'cw ! ttwritec cw 'cx +! ;

::uiLabel | "text" -- ; text left aligned, then next cell
	ttwrite ui.. ;
::uiLabelC | "text" -- ; text centered, then next cell
	ttwritec ui.. ;
::uiLabelR | "text" -- ; text right aligned, then next cell
	ttwriter ui.. ;

::uiText | "" align -- ; text wrapped in the cursor box with the alignment of txalign ($VH)
	txalign >r cw ch cx cy r> txText ;

|---- content words: what a button shows. They get the data and draw in the cursor box
::ctLabel | "text" -- ; centered text
	ttwritec ;

#isz
::ctIcon | n -- ; centered icon (ICxxx)
	rh 6 - 'isz !
	colTxt $ffffff and color
	cx cw isz - 2/ + cy rh isz - 2/ + isz uiIcon ;

|---- Buttons: sense + skin + content + action
:kbBtn
	sdlkey
	<ret> =? ( uiEx! )
	<tab> =? ( tabfocus )
	drop ;

#bcont

::uiBtnX | 'click data 'content -- ; button with any content: 'content gets data and draws it
	'bcont !
	uiZone
	'uiEx! uiClk
	[ 2 ui+a ; ] uiSel
	skinBtn sk
	[ kbBtn skFocus ; ] uiFocus
	colText bcont ex
	[ -2 ui+a ; ] uiSel
	ui..
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiBtn | 'click "" -- ; button with centered text; executes 'click when activated (click or Enter)
	'ctLabel uiBtnX ;

::uiIBtn | 'click icon -- ; button with an icon (ICxxx)
	'ctIcon uiBtnX ;

#rsave
::uiRBtn | 'click "" -- ; button with rounded corners (radius 6)
	rrad 'rsave ! 6 'rrad ! uiBtn rsave 'rrad ! ;
::uiCBtn | 'click "" -- ; button with capsule shape
	rrad 'rsave ! -1 'rrad ! uiBtn rsave 'rrad ! ;

::uiNBtn | 'click "" -- ; button as wide as its text, moving the cursor right (free flow: finish the row with uiLn); with columns (uiCols) it takes the cell like uiBtn
	uiCol# 1 >? ( drop uiBtn ; ) drop
	flpadx 'cx +!
	txw 8 + 'cw !
	uiZone
	'uiEx! uiClk
	skinBtn sk
	[ kbBtn skFocus ; ] uiFocus
	colText ttwritec
	flpadx cw + 'cx +!
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiTBtn | 'click "" align -- ; button with wrapped text of the given alignment; executes 'click when activated. In flow mode (uiCols) it takes the cell
	uiZoneW
	'uiEx! uiClk
	[ 2 ui+a ; ] uiSel
	skinBtn sk
	[ kbBtn skFocus ; ] uiFocus
	colText uiText
	[ -2 ui+a ; ] uiSel
	uiCol# 1 >? ( ch uiAdvH ) drop
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiTBtnH | 'click "" align h -- ; like uiTBtn with a height in pixels (several lines of text); in flow mode (uiCols) it takes the cell and the line is that high
	'ch ! uiTBtn ;

|---- Horizontal slide
#slstp 0 | 0: step = range/64, else a fixed step (integer sliders)

:slstep | min max -- step
	slstp 1? ( nip nip ; ) drop
	swap - 6 >> 1 max ;

:slmove | min max 'v key dir -- min max 'v key
	pick4 pick4 slstep *
	pick2 @ +
	pick4 clampmin
	pick3 clampmax
	pick2 ! uiEx! ;

:kbSlide
	sdlkey
	<tab> =? ( tabfocus )
	<le> =? ( <dn> nip )
	<dn> =? ( -1 slmove )
	<ri> =? ( <up> nip )
	<up> =? ( 1 slmove )
	drop ;

:slideh | min max 'v --
	sdlx cx - cw clamp0max
	2over swap -
	* cw 2/ + cw / pick3 +
	over ! uiEx! ;

:slideshow | 0.0 1.0 'value --
	dup @ pick3 -
	cw 6 -
	pick4 pick4 swap - 0? ( 1+ ) */
	skinSlide sk
	[ kbSlide skFocus ; ] uiFocus ;

::uiSliderf | min max 'value -- ; horizontal slider of a fixed point value (2 decimals)
	0 'slstp !
	uiZone
	'slideh uiSel
	slideshow
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | min max 'value -- ; horizontal slider of an integer value
	1 'slstp !
	uiZone
	'slideh uiSel
	slideshow
	@ .d uiLabelC
	2drop ;

::uiProgressf | min max 'value -- ; progress bar of a fixed point value (it can be dragged)
	uiSliderf ;
::uiProgressi | min max 'value -- ; progress bar of an integer value
	uiSlideri ;

::uiSliderfL | "name" min max 'value -- ; slider with the name at the left and the value at the right
	0 'slstp !
	uiZone
	'slideh uiSel
	slideshow
	colText pick3 ttinl
	@ .f2 ttinr ui..
	2drop drop ;

::uiSlideriL | "name" min max 'value -- ; like uiSlideri with the name at the left and the value at the right
	1 'slstp !
	uiZone
	'slideh uiSel
	slideshow
	colText pick3 ttinl
	@ .d ttinr ui..
	2drop drop ;

|---- Vertical slide (uses the whole height of the cursor box)
:slidev | 0.0 1.0 'value --
	sdly cy - ch clamp0max
	2over swap -
	* ch 2/ + ch / pick3 +
	over ! uiEx! ;

:slideshowv | min max 'v --
	skinField sk
	[ kbSlide skFocus ; ] uiFocus
	colFill
	dup @ pick3 -
	ch 8 - pick4 pick4 swap - 0? ( 1+ ) */ cy 1+ +
	cx 2 + swap cw 4 - 6 frect ;

:vadv | -- ; the vertical slider is as high as its box
	uiCol# 1 >? ( drop ch uiAdvH ; ) drop ui.. ;

::uiVSliderf | min max 'value -- ; vertical slider of a fixed point value (ch = height; in flow mode set ch before: it is the height of the line)
	uiZoneW
	'slidev uiSel
	slideshowv
	@ .f2 ttwritec vadv
	2drop ;

::uiVSlideri | min max 'value -- ; vertical slider of an integer value
	uiZoneW
	'slidev uiSel
	slideshowv
	@ .d ttwritec vadv
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

|----- TOGGLE
:togglev | 'var "text" -- 'var "text"
	over dup @ 1 xor swap ! uiEx! ;

:kbToggle
	sdlkey
	<tab> =? ( tabfocus )
	<ret> =? ( drop togglev 0 )
	drop ;

::uiToggle | 'var "text" -- ; on/off button: the variable is 0 or 1; click or Enter changes it; it is filled while on
	uiZone
	'togglev uiClk
	over @ skinTab sk
	[ kbToggle skFocus ; ] uiFocus
	colText uiLabelC drop ;

::uiNToggle | 'var "text" -- ; on/off button as wide as its text, moving the cursor right (free flow: finish the row with uiLn); filled while on. With columns (uiCols) it takes the cell like uiToggle
	uiCol# 1 >? ( drop uiToggle ; ) drop
	flpadx 'cx +!
	txw 8 + 'cw !
	uiZone
	'togglev uiClk
	over @ skinTab sk
	[ kbToggle skFocus ; ] uiFocus
	colText ttwritec
	flpadx cw + 'cx +!
	drop ;

|----- CHECK
:ttlbl | "text" -- ; label at the right of a check or radio box
	cx rh + 2 + tty txat txwrite ;

:focoCheck
	skFocus
	sdlkey
	<tab> =? ( tabfocus )
	<ret> =? ( 1 pick2 << pick3 @ xor pick3 ! uiEx! )
	drop ;

:icheck | 'var n -- 'var n
	uiZone
	'focoCheck uiFocus
	[ 1 over << pick2 @ xor pick2 ! uiEx! ; ] uiClk
	over @ 1 pick2 << and skinCheck sk
	colText dup uiNindx ttlbl
	ui.. ;

::uiCheck | 'var 'list -- ; one check box per string of the list (0-terminated strings, an empty one ends the list); each bit of the variable is a box
	mark makeindx
	0 ( cntlist <? icheck 1+ ) 2drop
	empty ;

|----- RADIO
:focoRadio
	skFocus
	sdlkey
	<tab> =? ( tabfocus )
	<ret> =? ( over pick3 ! uiEx! )
	drop ;

:isel | 'var n -- 'var n flag
	over @ over xor 0? ( drop 1 ; ) drop 0 ;

:iradio | 'var n --
	uiZone
	'focoRadio uiFocus
	[ 2dup swap ! uiEx! ; ] uiClk
	isel skinRadio sk
	colText dup uiNindx ttlbl
	ui.. ;

::uiRadio | 'var 'list -- ; one radio button per string of the list; the variable holds the number of the chosen one
	mark makeindx
	0 ( cntlist <? iradio 1+ ) 2drop
	empty ;

|----- TABS: radio buttons that look like tabs, one cell each
:itab | 'var n --
	uiZone
	'focoRadio uiFocus
	[ 2dup swap ! uiEx! ; ] uiClk
	isel skinTab sk
	colText dup uiNindx ttwritec
	ui.. ;

::uiTabs | 'var 'list -- ; tabs in a row, equal width, one per string; the variable holds the chosen one
	mark makeindx
	cntlist uiCols
	0 ( cntlist <? itab 1+ ) 2drop
	empty
	1 uiCols ;

|----- SECTION and PROPERTY rows
::uiSection | 'var "title" -- open ; folding header over the whole row: the variable is 0 or 1 (click toggles it); returns it
	uiLnEnd uiCol# uiSpan
	uiZone
	'togglev uiClk
	over @ skinSect sk
	colText cx rh + tty txat txwrite
	rh uiAdvH
	@ ;

#pw2 0.4 0.6
::uiProps | frac -- ; rows of two columns: name (frac of the width) and value (the rest)
	dup 'pw2 ! 1.0 swap - 'pw2 8 + !
	'pw2 2 uiColsW ;

::uiPanelBg | -- ; background of the frame with the skin of the panels
	fx fy fw fh skinPanel skAt ;

|--------
#lx #ly

:wwlist	| 'var max d -- 'var max d ; Wheel
	dup pick3 8 +
	dup @ rot +
	cntlist pick4 -
	clamp0max
	swap ! ;

:backline
	lx ly cw rh frect ;

:lsclick | 'var max -- 'var max
	cntlist over - 1+
	sdly cy - chx 1- clamp0max
	chx */ pick2 8 + ! ;

:cscroll | 'var max -- 'var max ; scroll bar over the interaction area
	cntlist >=? ( ; )
	chx over * cntlist / 8 max
	pick2 8 + @ chx pick2 - * cntlist pick3 - 1 max /
	swap skinScroll sk ;

:kbList
	SDLw 1? ( wwlist ) drop
	sdlkey
	<ret> =? ( uiEx! )
	<tab> =? ( tabfocus )
	<up> =? ( pick2 dup @ 1- clamp0 swap ! uiEx! )
	<dn> =? ( pick2 dup @ 1+ cntlist 1- clampmax swap ! uiEx! )
	drop
	cscroll ;

:cklist | 'var max --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop lsclick ; ) drop )
	sdly cy - rh / pick2 8 + @ + cntlist 1- clampmax pick2 !
	uiEx! ;

:ilist | 'var max n -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colFill backline )
	uiNindx
	colText
	lx tpad + ly rh txh - 2/ + txat txwrite
	rh 'ly +! ;

::uiList | 'var cntl 'list -- ; list box of cntl lines over the strings of the list; 'var points to two cells: the selected number and the first line shown (it scrolls with the wheel, keys or the bar)
	over uiZoneL
	mark makeindx
	skinField sk
	cx 'lx ! cy 'ly !
	uiClip 0 ( over <? ilist 1+ ) drop uiUnclip
	[ kblist skFocus ; ] uiFocus
	'cklist uiClk
	2drop
	empty
	chx uiAdvH ;

|----- TREE
:cktree | 'var cnt --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop lsclick ; ) drop )
	sdly cy - rh / pick2 8 + @ + cntlist 1- clampmax
	pick2 @ <>? ( pick2 ! ; )
	3 << indlist + @
	dup c@ $80 xor swap c! ;

#tdx
:tic | c -- icon
	$80 and 1? ( drop ICDOWN ; ) drop ICRIGHT ;
:ticon | c --
	$20 nand? ( drop ; )
	tic colTxt $ffffff and color tdx ly 2 + rh 4 - uiIcon ;

:itree | 'var max n -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colFill backline )
	uiNindx
	c@+ 0? ( 2drop rh 'ly +! ; )
	dup $1f and 4 << lx + tpad + 'tdx !
	ticon
	colText
	tdx rh + ly rh txh - 2/ + txat txwrite
	rh 'ly +! ;

::uiTree | 'var cntl 'list -- ; like uiList for a tree: every string starts with a byte (level in $1f, $20 has children, $80 open) and a click toggles a folder
	over uiZoneL
	mark maketree
	skinField sk
	cx 'lx ! cy 'ly !
	uiClip 0 ( over <? itree 1+ ) drop uiUnclip
	[ kblist skFocus ; ] uiFocus
	'cktree uiClk
	2drop
	empty
	chx uiAdvH ;

|----- COMBO
#uidata1 0
#uidata2 0

:comboclk | 'var cnt -- 'var cnt
	cntlist <? ( sdlx cx - cw 12 - >? ( drop lsclick ; ) drop )
	sdly cy - rh / pick2 8 + @ + cntlist 1- clampmax pick2 !
	uiExitWidget
	;

:combolist | --
	uidata1 uidata2
	mark makeindx
	cntlist 6 min
	dup uiZoneL
	skinField sk
	cx 'lx ! cy 'ly !
	uiClip 0 ( over <? ilist 1+ ) drop uiUnclip
	cscroll
	skFocus
	kblist
	'comboclk uiClk
	2drop
	empty ;

:iniCombo | 'var 'list -- 'var 'list ; the list opens below the combo (above if it does not fit)
	2dup 'uidata2 ! 'uidata1 !
	calcindx
	cntlist 6 min rh *
	cy rh + over + sh >? ( drop cx cy pick2 - cw ch 'combolist uiSaveLast drop ; ) drop
	drop cx cy rh + cw ch 'combolist uiSaveLast ;

:kblistc
	skFocus
	'iniCombo uiClk
	calcindx
	kblist
	idfs idfh =? ( -1 'idfs ! uiEx! ) drop
	;

::uiCombo | 'var 'list -- ; combo box (the variable has TWO cells: chosen, first line shown): it shows the chosen string of the list (the variable holds its number); a click opens the list of up to 6 lines, drawn by uiEnd over the rest
	uiZone
	skinField sk
	'kblistc uiFocus
	mark makeindx
	colText
	@ uiNindx ttinl
	colTxt $ffffff and color
	ICDOWN cx cw + rh - 2 + cy 2 + rh 4 - uiIcon
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
	cx tpad + cy rh txh - 2/ + txat 
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
	skFocus
	$ffffff color
	cursor
	SDLchar 1? ( modo ex ; ) drop
	SDLkey 0? ( drop ; )
	<ins> =? ( chmode )
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )
	<ret> =? ( uiEx! )
	<tab> =? ( tabfocus )
	drop
	;

::uiInputLine | 'buff max -- ; text line editor on the buffer (max bytes): insert or overwrite (Ins), left, right, home, end, backspace, delete, Tab and Enter
	uiZone
	skinField sk
	'iniinput uiFocusIn
	'proinputa uiFocus
	drop
	colText ttinl ui.. ;

