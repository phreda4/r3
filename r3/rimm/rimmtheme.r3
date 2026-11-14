| RIMM theme: colors, shape and skins of the widgets
| Colors and st* words as immwid.r3. New: the skins (how each kind of widget
| is drawn) are vectors that a theme can replace, and the metrics (row height,
| padding, radius) belong to the theme, not to the font.
|
|  thDark thLight thBlender thGodot thMagica   ready made themes
|  uiTheme n   by number (0..4), thNext cycle
|  skin! 'vec kind   replace the drawing of one kind of widget
|
^r3/lib/color.r3
^r3/rimm/rimmicon.r3

|--- palette: 64 bits = light color $ffRRGGBB << 32 | normal color
##colBac $ff222222ff111111	| field background (normal)
##colFil $ff80D9FFff005D85	| fill: normal and light
##colTxt $ffffffffffffffff	| text
##colFoc $ffffff		| focus outline
##colBrd $404040		| border
##colPan $181818		| panel
##rrad 4			| corner radius (0 square, -1 capsule)
##rbrd 0			| border width (0 or 1)
##tpad 4			| padding of the text inside a field

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

##colFilT 0	| accent of the current theme
::stTheme | -- ; widget color style: the accent of the theme (undo stDang, stWarn...)
	colFilT 'colFil ! ;

::stRad | r -- ; corner radius of the widgets (0 square, -1 capsule)
	'rrad ! ;

|--- colors for the state of the widget
:stcol | state -- 0..255 ; how much of the light color
	1 =? ( drop 70 ; )
	2 =? ( drop 255 ; ) 3 =? ( drop 255 ; ) 6 =? ( drop 255 ; )
	drop 0 ;

::colFill | -- ; fill color of the widget for its state (over, pressed...)
	colFil dup $ffffff and swap 32 >> $ffffff and
	uistate $f and stcol colmix $ffffff and color ;
::colFillN | -- ; fill color, always the normal one
	colFil $ffffff and color ;
::colLight | -- ; the light color of the fill (marks, bars)
	colFil 32 >> $ffffff and color ;
::colBack | -- ; background of the fields
	colBac $ffffff and color ;
::colFocus | -- ; focus outline
	colFoc $ffffff and color ;
::colText | -- ; text color
	colTxt $ffffff and txrgb ;
::colBorde | -- ; border
	colBrd color ;

|--- the box that the skins draw (x y w h) and its shape
##bx ##by ##bw ##bh

::box! | x y w h -- ; box of the skins
	'bh ! 'bw ! 'by ! 'bx ! ;

:rr | -- r ; radius that fits the box
	rrad -? ( drop bw bh min 2/ ; ) bw bh min 2/ min ;

::fshape | -- ; fill the box with the radius of the theme
	rr 0? ( drop bx by bw bh frect ; )
	bx by bw bh fround ;

::oshape | -- ; outline of the box with the radius of the theme
	rr 0? ( drop bx by bw bh rect ; )
	bx by bw bh round ;

::skFocus | -- ; focus outline around the interaction area
	colFocus
	cx 1- cy 1- cw 2 + chx 2 + box! oshape ;

|--- skins: kind -> vector (called with the box set, the state in uistate)
::skinBtn 0 ; ::skinField 1 ; ::skinCheck 2 ; ::skinRadio 3 ; ::skinSlide 4 ; ::skinPanel 5 ; ::skinTab 6 ; ::skinScroll 7 ; ::skinSect 8 ;

#skin * 128

::skin! | 'vec kind -- ; replace the skin of a kind of widget
	3 << 'skin + ! ;

::skAt | .. x y w h kind -- ; draw the skin of that kind in the box x y w h
	>r box! r> 3 << 'skin + @ ex ;

::sk | .. kind -- ; draw the skin of that kind over the interaction area (cx cy cw chx)
	>r cx cy cw chx r> skAt ;

:borde | -- ; border if the theme has one
	rbrd 0? ( drop ; ) drop
	colBorde oshape ;

:skbtn
	colFill fshape borde ;

:skbtnflat | flat: fill and a line below, no radius
	colFill bx by bw bh frect
	colLight bx by bh + 2 - bw 2 frect ;

:skfield
	colBack fshape borde ;

#cks
:ckbox | -- ; square of the check/radio at the left of the box
	bh 4 - bw min 'cks !
	bx 2 + by bh cks - 2/ + cks cks box! ;

:skcheck | on --
	ckbox
	colBack fshape borde
	0? ( drop ; ) drop
	colLight ICCHK bx 1+ by 1+ cks 2 - uiIcon ;

:skradio | on --
	bh 4 - bw min 'cks !
	colBack cks 2/ bx 2 + cks 2/ + by bh 2/ + fcircle
	rbrd 1? ( colBorde cks 2/ bx 2 + cks 2/ + by bh 2/ + circle ) drop
	0? ( drop ; ) drop
	colLight cks 2/ 3 - 1 max bx 2 + cks 2/ + by bh 2/ + fcircle ;

:skslide | px --
	colBack fshape borde
	bx 2 + by 2 + pick2 1 max bh 4 - box!
	colFill fshape drop ;

:skpanel
	colPan color fshape borde ;

:sktab | on --
	1? ( drop colFillN fshape borde ; ) drop
	colBack fshape borde ;

#sty #sth
:skscroll | thumby thumbh --
	'sth ! 'sty !
	colBack bx bw + 8 - by 8 bh frect
	colFillN 4 bx bw + 7 - by sty + 6 sth fround ;

:icopen | open -- icon
	1? ( drop ICDOWN ; ) drop ICRIGHT ;

:sksect | open --
	colFil $ffffff and colBac $ffffff and 128 colmix color
	bx by bw bh frect
	colLight
	icopen bx 2 + by bh 2/ + bh 4 - 2/ - bh 4 - uiIcon ;

:sknone | -- ;
	;

:skinini
	'skbtn skinBtn skin!  'skfield skinField skin!  'skcheck skinCheck skin!
	'skradio skinRadio skin!  'skslide skinSlide skin!  'skpanel skinPanel skin!
	'sktab skinTab skin!  'skscroll skinScroll skin!  'sksect skinSect skin! ;

|--- themes
| metrics: row height, padding (x y), text padding
:metrics | rowh padx pady tpad --
	'tpad ! 'flpady ! 'flpadx ! uiRowH
	colFil 'colFilT ! ;

::thDark | -- ; dark, like the original
	skinini
	$ff2a2a2aff1a1a1a 'colBac ! $ff80D9FFff005D85 'colFil !
	$ffffffffffffffff 'colTxt ! $ffffff 'colFoc !
	$404040 'colBrd ! $181818 'colPan !
	4 'rrad ! 0 'rbrd !
	22 4 4 4 metrics ;

::thLight | -- ; light, with border
	skinini
	$ffeeeeeeffdddddd 'colBac ! $ff9CC3FFff3C78D8 'colFil !
	$ff202020ff202020 'colTxt ! $2060d0 'colFoc !
	$a0a0a0 'colBrd ! $f2f2f2 'colPan !
	3 'rrad ! 1 'rbrd !
	22 4 4 4 metrics ;

::thBlender | -- ; gray, small, accent blue
	skinini
	$ff5a5a5aff545454 'colBac ! $ff6a93d6ff4772b3 'colFil !
	$ffe6e6e6ffe6e6e6 'colTxt ! $ffffff 'colFoc !
	$1d1d1d 'colBrd ! $303030 'colPan !
	4 'rrad ! 1 'rbrd !
	20 3 2 4 metrics ;

::thGodot | -- ; blue gray, rounded, tall rows
	skinini
	$ff2e3440ff1d2229 'colBac ! $ff6fb3e6ff478cbf 'colFil !
	$ffdfe3eaffdfe3ea 'colTxt ! $ff9fd0ff 'colFoc !
	$3b4252 'colBrd ! $21262e 'colPan !
	6 'rrad ! 1 'rbrd !
	26 6 4 6 metrics ;

::thMagica | -- ; flat, compact, orange
	skinini
	'skbtnflat skinBtn skin!
	$ff555555ff3c3c3c 'colBac ! $ffffb347ffb8741a 'colFil !
	$ffeeeeeeffeeeeee 'colTxt ! $ffffb347 'colFoc !
	$222222 'colBrd ! $2b2b2b 'colPan !
	0 'rrad ! 0 'rbrd !
	18 3 2 3 metrics ;

#themes 'thDark 'thLight 'thBlender 'thGodot 'thMagica
#themen 0

::uiTheme | n -- ; theme by number (it does not move the cursor: it can be changed in the middle of a frame) (0 dark, 1 light, 2 blender, 3 godot, 4 magica)
	5 mod dup 'themen ! 3 << 'themes + @ ex ;

::thNext | -- ; next theme
	themen 1+ uiTheme ;

::thNow | -- n ; number of the current theme
	themen ;


: thDark ;
