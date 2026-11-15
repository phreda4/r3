| RIMM color picker: swatch + popup (saturation/value square, hue bar, hex)
| Port of imcolor.r3 without SDL calls: the square is drawn row by row with
| lineHg (a horizontal line with a color at each end) and the bar with lineH,
| both part of the backend contract, so it works in any backend (rimmsdl, rimmgl).
|
|   uiColor  | 'var --   swatch of the color in the variable ($RRGGBB)
|   uiColorH | 'var --   same with the hex text over the swatch
|   color!   | rgb --    set the color of the picker
|
^r3/lib/color.r3
^r3/rimm/rimmwid.r3

#colorvar
#c1x #c1y #c1w

:setcolor | --
	c1w 9 <<
	c1x 9 <<
	127 c1y - 9 <<
	hsv2rgb colorvar ! ;

::color! | rgb -- ; load the color in the picker
	dup colorvar !
	rgb2hsv | h s v
	128 16 *>> 127 swap - 'c1y !
	128 16 *>> 'c1x !
	128 16 *>> 'c1w ! ;

:hue | j -- rgb ; color of the hue j (0..127), the one setcolor gives
	9 << 1.0 1.0 hsv2rgb $ffffff and ;

:huebar | -- ; 128 rows of 12 pixels, a color per row
	0 ( 128 <? dup hue color
		cx 140 + over cy 5 + + cx 151 + lineH
		1+ ) drop ;

#hcv					| hue color of the square (once per frame)

:svrow | j -- j ; row j of the saturation/value square: white to hue, fading to black
	cx 5 + over cy 5 + + cx 132 +		| j x1 y x2
	pick3 255 * 127 /			| j x1 y x2 a
	$ffffff 0 pick2 colmix $ffffff and	| j x1 y x2 a c1
	hcv 0 pick3 colmix $ffffff and		| j x1 y x2 a c1 c2
	rot drop lineHg ;

:square | --
	c1w hue 'hcv !
	0 ( 128 <? svrow 1+ ) drop ;

:pickdraw | -- ; the popup: it is drawn by uiEnd over the rest
	uiZoneW
	skinField sk
	square
	huebar
	cx 140 + cy 5 + 12 128 uiZoneBox
	[ sdly cy - 127 clamp0max 'c1w ! setcolor ; ] uiSel
	uiBackBox
	cx 5 + cy 5 + 127 127 uiZoneBox
	[ sdly cy - 127 clamp0max 'c1y !
	  sdlx cx - 127 clamp0max 'c1x ! setcolor ; ] uiSel
	uiBackBox
	$0 color
	cx 4 + cy 4 + 130 130 rect
	cx 139 + cy 4 + 12 130 rect
	cx 5 + c1x + 2 - cy 5 + c1y + 2 - 5 5 rect
	$ffffff color
	cx 137 + cy c1w + 4 + 16 3 rect
	cx 5 + c1x + 1- cy 5 + c1y + 1- 3 3 rect
	colText
	cx 64 + cy 150 + txat
	colorvar @ $ffffff and "$%h" txprint
	colorvar @ $ffffff and color
	cx 10 + cy 154 + 50 20
	2over 2over frect
	uiZoneBox
	'uiExitWidget uiClk
	uiBackBox ;

:popx | -- x ; the popup keeps inside the screen
	cx 160 + sw >? ( drop sw 160 - ; ) drop cx ;
:popy | -- y ; below the swatch if it fits, else above
	cy rh + 180 + sh >? ( drop cy 180 - ; ) drop cy rh + ;

:iniColor | 'var -- 'var
	dup 'colorvar ! dup @ color!
	popx popy 160 180 'pickdraw uiSaveLast ;

:kbcolor
	skFocus
	'iniColor uiClk
	sdlkey
	<tab> =? ( tabfocus )
	drop ;

:swatch | 'var --
	@ $ffffff and color
	cx cy cw chx box! fshape
	rbrd 1? ( colBorde oshape ) drop ;

::uiColor | 'var -- ; color swatch: a click opens the picker
	uiZone
	'kbcolor uiFocus
	dup swatch
	drop ui.. ;

::uiColorH | 'var -- ; swatch with the hex value over it
	uiZone
	'kbcolor uiFocus
	dup swatch
	colText
	@ $ffffff and "$%h" sprint ttwritec
	ui.. ;
