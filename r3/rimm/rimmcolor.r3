| RIMM color picker: swatch + popup (saturation/value square, hue bar, hex)
| Port of imcolor.r3 without SDL calls: the square is drawn row by row with
| lineHg (a horizontal line with a color at each end) and the bar with lineH,
| both part of the backend contract, so it works in any backend (rimmsdl, rimmgl).
|
|   uiColor       | 'var --   swatch of the color in the variable ($RRGGBB)
|   uiColorH      | 'var --   same with the hex text over the swatch
|   uiColorAlpha  | 'var --   swatch of the color with alpha in the variable ($AARRGGBB):
|                              the right half is shown over a checker, the popup has an alpha bar
|   uiColorAlphaH | 'var --   same with the hex text over the swatch
|   uiColorMat    | 'var --   swatch of a material color in the variable ($RRGGBBuma, as ss3d/ssmulti use it):
|                              the popup adds three controls for the low byte: metal 0..7 (3 bits, bits 2-4),
|                              rough 0..7 (3 bits, bits 5-7) and glow 0..3 (2 bits, bits 0-1)
|   uiColorMatH   | 'var --   same with the hex text (rgb) over the swatch
|   color!        | rgb --    set the color of the picker
|
^r3/lib/color.r3
^r3/rimm/rimmwid.r3

#colorvar
#c1x #c1y #c1w
#c1a 0			| alpha bar 0..127 (top = opaque)
#ca 255			| alpha 0..255 (the exact value of the variable)
#cmode 0			| mode of the open popup: 0 $RRGGBB, 1 $AARRGGBB, 2 $RRGGBBuma
#cmodew 0			| mode of the widget being drawn

:setcolor | -- ; hue 0..127 of 128, s and v 0..127 reach 1.0: $000000 and $ffffff are exact
	c1w 9 <<
	c1x 16 << 127 /
	127 c1y - 16 << 127 /
	hsv2rgb $ffffff and
	cmode 2 =? ( drop 8 << colorvar @ $ff and or colorvar ! ; ) drop
	ca 24 << cmode * or colorvar ! ;

:setalpha | -- ; only the alpha byte changes (the rgb of the variable stays as it is)
	colorvar @ $ffffff and ca 24 << or colorvar ! ;

::color! | rgb -- ; load the color in the picker (alpha too when the mode has it)
	dup colorvar !
	dup 24 >> $ff and dup 'ca ! 127 * 127 + 255 / 127 swap - 'c1a !
	cmode 2 =? ( swap 8 >> swap ) drop			| $RRGGBBuma: the rgb is in the upper 24 bits
	rgb2hsv | h s v (v is 0..$ff00)
	127 * 32640 + 65280 / 127 swap - 'c1y !
	127 * 32768 + 16 >> 'c1x !
	128 16 *>> 127 min 'c1w ! ;

:hexd | n -- char ; 0..15 as 0-9 A-F
	$f and 10 <? ( 48 + ; ) 55 + ;

#hexbuf * 12
#hn 0
:hexn | v n -- "$..." ; always n digits
	'hn ! $24 'hexbuf c! 0 'hexbuf hn 1+ + c!
	hn ( 1? 1- over hexd over 'hexbuf 1+ + c! swap 4 >> swap ) 2drop 'hexbuf ;

:chex | v mode -- "text" ; $RRGGBB, $AARRGGBB, or the $RRGGBB of an $RRGGBBuma
	0? ( drop $ffffff and 6 hexn ; ) 2 =? ( drop 8 >> $ffffff and 6 hexn ; ) drop 8 hexn ;

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

|--- alpha: checker and bar (everything with colmix, no blending of the backend)
:chk | p -- c ; the two colors of the checker
	1 and 1? ( drop $d8d8d8 ; ) drop $909090 ;

#cbc #cba #cbj #cbb
:alphabar | -- ; 128 rows, two columns of 6 pixels over a checker, opaque at the top
	colorvar @ $ffffff and 'cbc !
	0 ( 128 <?
		dup 'cbj !
		127 cbj - 255 * 127 / 'cba !
		cbj 6 / 'cbb !
		cbb chk cbc cba colmix $ffffff and color
		cx 160 + cbj cy 5 + + cx 165 + lineH
		cbb 1+ chk cbc cba colmix $ffffff and color
		cx 166 + cbj cy 5 + + cx 171 + lineH
		1+ ) drop ;

#csx2 #csy2 #csw2 #csh2 #cbx #cby
:swalpha | 'var -- ; right half of the swatch: the color with its alpha over a checker
	@ dup $ffffff and 'cbc ! 24 >> $ff and 'cba !
	cx cw 2/ + 'csx2 ! cy 2 + 'csy2 !
	cw 2/ 4 - 'csw2 ! chx 4 - 'csh2 !
	0 ( csh2 <?
		dup 'cby !
		0 ( csw2 <?
			dup 'cbx !
			cby 6 / cbx 6 / + chk cbc cba colmix $ffffff and color
			csx2 cbx + csy2 cby + csw2 cbx - 6 min csh2 cby - 6 min frect
			6 + ) drop
		6 + ) drop ;

#cpb 0 #cpn 0
#cpw 160				| width of the popup
#cph 180				| height of the popup
#csx 0 #csy 0 #csw 0 #csh 0		| swatch that opened the popup
#cskip 0				| a press on the swatch closed the popup: its release must not open it again
#ibx #iby #ibw #ibh

:uiDrag | 'v -- ; execute 'v while the widget is active, also with the mouse out of its zone
	uiState $f and 3 <? ( 2drop ; ) 4 >? ( 2drop ; ) drop ex ;

:inbox? | x y w h -- flag ; the mouse is inside
	'ibh ! 'ibw ! 'iby ! 'ibx !
	sdlx ibx <? ( drop 0 ; ) ibx ibw + >=? ( drop 0 ; ) drop
	sdly iby <? ( drop 0 ; ) iby ibh + >=? ( drop 0 ; ) drop 1 ;

:outside? | -- flag ; out of the popup and of the swatch
	cx cy cpw cph inbox? 1? ( drop 0 ; ) drop
	csx csy csw csh inbox? 1? ( drop 0 ; ) drop 1 ;

|--- material (mode 2): metal, rough and glow live in the low byte of the color, $uma
#mn					| control being drawn or dragged: 0 metal, 1 rough, 2 glow
:mshift | n -- shift ; bit position of the field in the low byte
	0? ( drop 2 ; ) 1 =? ( drop 5 ; ) drop 0 ;
:mmax | n -- max ; maximum value, also the bit mask (7 = 3 bits, 3 = 2 bits)
	2 <? ( drop 7 ; ) drop 3 ;
:mname | n -- "name"
	0? ( drop "metal" ; ) 1 =? ( drop "rough" ; ) drop "glow" ;
:mval | n -- v ; value of the control in the variable
	dup mshift colorvar @ swap >> swap mmax and ;
:mset | v n -- ; set the control, the other bits of the variable stay as they are
	'mn ! mn mmax mn mshift << not colorvar @ and
	swap mn mmax and mn mshift << or colorvar ! ;

:mrowy | -- y ; screen y of the row of the control mn
	cy 178 + mn 20 * + ;
:mdrag | -- ; the mouse sets the value of the control mn (inside its zone: cx is the bar origin, 96 pixels wide)
	sdlx cx - mn mmax 1+ * 96 / mn mmax clamp0max mn mset ;

:matrow | n -- ; label, bar filled up to the value, number; drag to change it
	'mn !
	$202020 color cx 54 + mrowy 96 14 frect
	$3070c0 color cx 54 + mrowy mn mval 96 * mn mmax / 14 frect
	$808080 color cx 54 + mrowy 96 14 rect
	colText
	cx 5 + mrowy 1+ txat mn mname txprint
	cx 98 + mrowy 1+ txat mn mval "%d" txprint
	cx 54 + mrowy 96 14 uiZoneBox
	[ mdrag ; ] uiDrag
	uiBackBox ;

:matrows | -- ; the three controls
	0 ( 3 <? dup matrow 1+ ) drop ;

:cclose | -- ; ESC or a press outside closes the popup
	sdlkey >esc< =? ( uiExitWidget ) drop
	sdlb cpb nand 'cpn !
	sdlb 'cpb !
	cpn 0? ( drop ; ) drop
	outside? 0? ( drop ; ) drop
	uiExitWidget ;

:pickdraw | -- ; the popup: it is drawn by uiEnd over the rest
	cclose
	uiZoneW
	skinField sk
	square
	huebar
	cmode 1 =? ( alphabar ) drop
	cx 140 + cy 5 + 12 128 uiZoneBox
	[ sdly cy - 127 clamp0max 'c1w ! setcolor ; ] uiDrag
	uiBackBox
	cmode 1 =? ( cx 160 + cy 5 + 12 128 uiZoneBox
		[ sdly cy - 127 clamp0max 'c1a ! 127 c1a - 255 * 127 / 'ca ! setalpha ; ] uiDrag
		uiBackBox ) drop
	cx 5 + cy 5 + 128 128 uiZoneBox
	[ sdly cy - 127 clamp0max 'c1y !
	  sdlx cx - 127 clamp0max 'c1x ! setcolor ; ] uiDrag
	uiBackBox
	$0 color
	cx 4 + cy 4 + 130 130 rect
	cx 139 + cy 4 + 12 130 rect
	cmode 1 =? ( cx 159 + cy 4 + 12 130 rect ) drop
	cx 5 + c1x + 2 - cy 5 + c1y + 2 - 5 5 rect
	$ffffff color
	cx 137 + cy c1w + 4 + 16 3 rect
	cmode 1 =? ( cx 157 + cy c1a + 4 + 16 3 rect ) drop
	cx 5 + c1x + 1- cy 5 + c1y + 1- 3 3 rect
	cmode 2 =? ( matrows ) drop
	colText
	cx 64 + cy 150 + txat
	colorvar @ cmode chex txprint
	colorvar @ cmode 2 =? ( swap 8 >> swap ) drop $ffffff and color
	cx 10 + cy 154 + 50 20
	2over 2over frect
	uiZoneBox
	'uiExitWidget uiClk
	uiBackBox ;

:popx | -- x ; the popup keeps inside the screen
	cx cpw + sw >? ( drop sw cpw - ; ) drop cx ;
:popy | -- y ; below the swatch if it fits, else above
	cy rh + cph + sh >? ( drop cy cph - ; ) drop cy rh + ;

:pickw | mode -- w ; the alpha bar widens the popup
	1 =? ( drop 176 ; ) drop 160 ;
:pickh | mode -- h ; the material controls make it taller
	2 =? ( drop 240 ; ) drop 180 ;

:iniColor | 'var -- 'var
	cskip 1? ( drop 0 'cskip ! ; ) drop
	cx 'csx ! cy 'csy ! cw 'csw ! chx 'csh ! sdlb 'cpb !
	cmodew 'cmode ! cmode pickw 'cpw ! cmode pickh 'cph !
	dup 'colorvar ! dup @ color!
	popx popy cpw cph 'pickdraw uiSaveLast ;

:kbcolor
	skFocus
	'iniColor uiClk
	sdlkey
	<tab> =? ( tabfocus )
	drop ;

:cwatch | -- ; press on the swatch with its popup open: the popup closes, the click must not open it again
	uiState $f and 2 <>? ( drop ; ) drop
	0 'cskip ! uiPopup? 'pickdraw =? ( 1 'cskip ! ) drop ;

:swatch | 'var --
	dup @ cmodew 2 =? ( swap 8 >> swap ) drop $ffffff and color
	cx cy cw chx box! fshape
	rbrd 1? ( colBorde oshape ) drop
	cmodew 1 =? ( drop swalpha ; ) drop drop ;

:cwidget | 'var --
	uiZone cwatch
	'kbcolor uiFocus
	dup swatch drop ui.. ;

:cwidgetH | 'var --
	uiZone cwatch
	'kbcolor uiFocus
	dup swatch
	colText
	@ cmodew chex ttwritec
	ui.. ;

::uiColor | 'var -- ; color swatch: a click opens the picker
	0 'cmodew ! cwidget ;

::uiColorH | 'var -- ; swatch with the hex value over it
	0 'cmodew ! cwidgetH ;

::uiColorAlpha | 'var -- ; swatch of an $AARRGGBB color: a click opens the picker with an alpha bar
	1 'cmodew ! cwidget ;

::uiColorAlphaH | 'var -- ; same with the hex value over the swatch
	1 'cmodew ! cwidgetH ;

::uiColorMat | 'var -- ; swatch of a $RRGGBBuma color: the popup has the picker and metal 0..7, rough 0..7, glow 0..3
	2 'cmodew ! cwidget ;

::uiColorMatH | 'var -- ; same with the hex value (rgb) over the swatch
	2 'cmodew ! cwidgetH ;
