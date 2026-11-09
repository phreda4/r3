| immi widgets and draw words
| PHREDA 2025
|
| Needs a backend (immsdl.r3 or immgl.r3) and immcore.r3 included before.
|
^r3/lib/color.r3
^r3/util/immcore.r3

|uncomment for generate help
|^r3/util/immsdl.r3

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
#statec ( 0 0 32 32 0 0 32 ) | uistate -> shift of colFil (32 = light color)
:colFill	colFil uistate $f and 'statec + c@ >> $ffffffff and color ;
:colFillN	colFil $ffffffff and color ;
:colFocus	colFoc color ;
:colText	colTxt txrgb ;

|---- text cursor
::uil.. | -- ; move the cursor down one text line
	txh 'cy +! ;
::ui.. | -- ; move the cursor down one text line plus the padding
	txh flpady + 'cy +! ;
	
::ui-- | -- ; draw a horizontal separator line and move the cursor down
	colFillN
	cx cy 1+ cw 2 rect
	flpady 7 + 'cy +! ;

::uiClip | -- ; clip the drawing to the interaction area
	cx cy cw chx gclip ;
::uiUnclip | -- ; remove the clip
	gclip0 ;

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
	<ret> =? ( uiEx! )
	<tab> =? ( tabfocus ) 
	drop ;

	
::uiTBtn | 'click "" align -- ; button with wrapped text of the given alignment and rounded fill; executes 'click when activated
	uiZoneW 
	'uiEx! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill 8 uilRFill 
	[ kbBtn colFocus 8 uiRrect ; ] uiFocus
	colText uiText
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiNBtn | 'click "" -- ; button as wide as its text; it moves the cursor right; executes 'click when activated
	txw 4 + 'cw !
	uiZone
	'uiEx! uiClk
	colFill uilFill 
	[ kbBtn colFocus uiLRect ; ] uiFocus
	ttwritec
	cw 'cx +! 
	uiEx? 0? ( 2drop ; ) drop ex ;	
	
::uiBtn | 'click "" -- ; button with centered text; executes 'click when activated (click or Enter)
	uiZone
	'uiEx! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill uilFill 
	[ kbBtn colFocus uiLRect ; ] uiFocus
	colText uiLabelC 
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiRBtn | 'click "" -- ; button with rounded corners (radius 6)
	uiZone
	'uiEx! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill 6 uiLRFill 
	[ kbBtn colFocus 6 uiLRRect ; ] uiFocus
	colText uiLabelc 
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiCBtn | 'click "" -- ; button with capsule shape
	uiZone
	'uiEx! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill uiLCFill 
	[ kbBtn colFocus uiLCRect ; ] uiFocus
	colText uiLabelc
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

|---- Horizontal slide
#slstp 0 | 0: step = range/100, else a fixed step (integer sliders)

:slstep | min max -- step
	slstp 1? ( nip nip ; ) drop
	swap - 100 / 1 max ;

:slmove | min max 'v key dir -- min max 'v key
	pick4 pick4 slstep *		| min max 'v key delta
	pick2 @ +					| min max 'v key nv
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

:slideh | 0.0 1.0 'value --
	sdlx cx - cw clamp0max 
	2over swap - | Fw
	cw */ pick3 +
	over ! uiEx! ;
	
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
	0 'slstp !
	uiZone
	'slideh uiSel |
	slideshow
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | min max 'value -- ; horizontal slider of an integer value
	1 'slstp !
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
	0 'slstp !
	uiZone
	'slideh uiSel | 'dn 'move --	
	progreshow
	@ .f2 uiLabelC
	2drop ;

::uiProgressi | min max 'value -- ; horizontal progress bar of an integer value
	1 'slstp !
	uiZone
	'slideh uiSel | 'dn 'move --	
	progreshow
	@ .d uiLabelC
	2drop ;	
	
	
::uiSliderfL | "name" min max 'value -- ; like uiSliderf with the name at the left and the value at the right
	0 'slstp !
	uiZone
	'slideh uiSel
	slideshow
	colText pick3 ttwrite
	@ .f2 ttwriter ui..
	2drop drop ;

::uiSlideriL | "name" min max 'value -- ; like uiSlideri with the name at the left and the value at the right
	1 'slstp !
	uiZone
	'slideh uiSel
	slideshow
	colText pick3 ttwrite
	@ .d ttwriter ui..
	2drop drop ;

|---- Vertical slide
:slidev | 0.0 1.0 'value --
	sdly cy - ch clamp0max 
	2over swap - | Fw
	ch */ pick3 +
	over ! uiEx! ;
	
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

|----- TOGGLE
:togglev | 'var "text" -- 'var "text"
	over dup @ 1 xor swap ! uiEx! ;

:kbToggle
	sdlkey
	<tab> =? ( tabfocus )
	<ret> =? ( drop togglev 0 )
	drop ;

:tgcol | v --
	1? ( drop colFill ; ) drop colBack ;

::uiToggle | 'var "text" -- ; on/off button: the variable is 0 or 1; click or Enter changes it; it is filled while on
	uiZone
	'togglev uiClk
	over @ tgcol uilFill
	[ kbToggle colFocus uiLRect ; ] uiFocus
	colText uiLabelC drop ;

|----- CHECK
:focoCheck
	colFocus uiLRect 
	sdlkey
	<tab> =? ( tabfocus  )
	<ret> =? ( 1 pick2 << pick3 @ xor pick3 ! uiEx! ) | 'var n key -- 'var n key
	drop ;

:ic	over @ 1 pick2 << |and? ( drop "[x]" ; ) drop "[ ]" ;
	and? ( drop icChkOn ; ) drop icChkOff ;
	
:icheck | 'var n -- 'var n
	uiZone 
	'focoCheck uiFocus 
	[ 1 over << pick2 @ xor pick2 ! uiEx! ; ] uiClk
	cx cy txat 
	ic txicon 32 txicon colText a@+ txwrite
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
	<ret> =? ( over pick3 ! uiEx! ) | 'var n key -- 'var n key
	drop ;

:ir over @ |=? ( "(o)" ; ) "( )" ;
	=? ( icRadOn ; ) icRadOff ;

:iradio | 'var n --
	uiZone
	'focoRadio uiFocus
	[ 2dup swap ! uiEx! ; ] uiClk
	cx cy txat 
	ir txicon 32 txicon colText a@+ txwrite
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
	
:lsclick | 'var max -- 'var max
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
	<ret> =? ( uiEx! )
	<tab> =? ( tabfocus ) 
	<up> =? ( pick2 dup @ 1- clamp0 swap ! uiEx! )
	<dn> =? ( pick2 dup @ 1+ cntlist 1- clampmax swap ! uiEx! )	
	drop 
	cscroll ;

:cklist | 'var max --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop lsclick ; ) drop )
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
	uiClip 0 ( over <? ilist 1+ ) drop uiUnclip
	[ kblist colFocus uiLRect ; ] uiFocus	
	'cklist uiClk
	2drop
	empty 
	chx flpady + 'cy +! ;
	
|----- TREE
| #vtree 0 0

:cktree | 'var cnt --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop lsclick ; ) drop )
	sdly cy - txh / pick2 8 + @ + cntlist 1- clampmax
	pick2 @ <>? ( pick2 ! ; )
	3 << indlist + @ 
	dup c@ $80 xor swap c! ;

:iicon | n -- 
	$20 nand? ( drop 32 txicon ; )
	7 >> 1? ( drop icTreeO txicon ; ) drop icTreeC txicon ;
	
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
	uiClip 0 ( over <? itree 1+ ) drop uiUnclip
	[ kblist colFocus uiLRect ; ] uiFocus
	'cktree uiClk
	2drop
	empty 
	chx flpady + 'cy +! ;
	
|----- COMBO
#uidata1 0 
#uidata2 0 

:comboclk | 'var cnt -- 'var cnt
	cntlist <? ( sdlx cx - cw 12 - >? ( drop lsclick ; ) drop )
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
	uiClip 0 ( over <? ilist 1+ ) drop uiUnclip
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
	idfs idfh =? ( -1 'idfs ! uiEx! ) drop | ex when exit last widget
	;
	
::uiCombo | 'var 'list -- ; combo box: it shows the chosen string of the list (the variable holds its number); a click opens the list of up to 6 lines, drawn by uiEnd
	uiZone 
	colBack uiLFill
	'kblistc uiFocus
	mark makeindx	
	cx cy txat
	@ uiNindx txwrite
	cx cw + txh - cy txat icCombo txicon
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
	
	<ret> =? ( uiEx! )
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
		