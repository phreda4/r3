| immi backend: OpenGL (glgfx)
| PHREDA 2026
|
| Same words as immsdl.r3 over the glgfx font/rect drawing.
| The font is fixed (VGA8x16 x fscale) and the text color (txrgb) is kept apart
| from the draw color (color), like in the SDL backend.
| Not done: rounded corners (fround/round are plain rects), images, wrapped text.
|
^r3/lib/sdl2gl.r3
^r3/util/glgfx.r3

::immIniOld | -- ; immIni of sdl2gl (old engine), for programs that mix both
	immIni ;

|--- color
#txcol $ffffff

::color | rgb -- ; draw color $RRGGBB (alpha 255)
	$ff000000 or 'fcolor ! ;

::txrgb | rgb -- ; text color $RRGGBB
	$ffffff and 'txcol ! ;

|--- fixed font
::txfont | font -- ;
	drop ;
::txfont@ | -- font ;
	0 ;
::txh | -- h ; line height
	fsizeh ;
::txw | "" -- "" w ; width in pixels
	fsize drop ;

|--- text cursor
#tcx #tcy

::txat | x y --
	'tcy ! 'tcx ! ;

::txwrite | "" -- ; draw the string at the cursor, the cursor moves
	txw >r
	tcx tcy fat
	fcolor >r
	txcol $ff000000 or 'fcolor !
	ftext
	r> 'fcolor !
	r> 'tcx +! ;

#icbuf 0 0

::txicon | char -- ; draw a one char icon, the cursor moves
	'icbuf c!
	'icbuf txwrite ;

::icChkOn 254 ;
::icChkOff 9 ;
::icRadOn 7 ;
::icRadOff 9 ;
::icTreeC 16 ;
::icTreeO 31 ;
::icCombo 31 ;

::txcur | str cur -- ; block cursor over the char at cur
	swap - fsizew * 'tcx +!
	tcx tcy fsizew fsizeh frect ;

::txcuri | str cur -- ; insert cursor (bar at the bottom)
	swap - fsizew * 'tcx +!
	tcx tcy fsizeh + fsizeh 2 >> - fsizew fsizeh 2 >> frect ;

|--- aligned text in a box (no wrap)
#txal 0
#tw #th #tx0 #ty0

::txalign | $VH -- ; low 2 bits horizontal (0 left 1 center 2 right), bits 4-5 vertical (0 top 1 center 2 bottom)
	'txal ! ;

:txalx | w -- dx
	txal $3 and
	1 =? ( drop tw swap - 2/ ; )
	2 =? ( drop tw swap - ; )
	2drop 0 ;

:txaly | -- dy
	txal 4 >> $3 and
	1 =? ( drop th txh - 2/ ; )
	2 =? ( drop th txh - ; )
	drop 0 ;

::txText | w h x y "" -- ; the string in the box x y w h with the txalign alignment
	>r 'ty0 ! 'tx0 ! 'th ! 'tw ! r>
	txw txalx tx0 +
	ty0 txaly +
	txat txwrite ;

|--- shapes
::fround | r x y w h -- ; plain rect
	>r >r >r >r drop r> r> r> r> frect ;

::round | r x y w h -- ; plain rect outline
	>r >r >r >r drop r> r> r> r> rect ;

::lineH | x1 y x2 --
	pick2 - 1+ 1 frect ;

::lineV | x y1 y2 --
	over - 1+ 1 swap frect ;

::imageb | 'box img -- ; not done in this backend
	2drop ;

|--- clip
#gcx #gcy #gcw #gch

::gclip | x y w h -- ; clip the drawing to the rectangle
	'gch ! 'gcw ! 'gcy ! 'gcx !
	3089 glEnable | GL_SCISSOR_TEST
	gcx sh gcy - gch - gcw gch glScissor ;

::gclip0 | --
	3089 glDisable ;
