| Color Select Dialog
| PHREDA 2020
|---------------
^r3/win/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/gui.r3

#xpal 0 #ypal 200
#cwx 60 #cwy 200

##colord $0

#colorwimg |188x189
#c1 $ffffff
#c1x #c1y #c1w

#pal8 * 300
#npal
#select 0

::color! | color --
	dup 'colord !
	select 0? ( 2drop ; ) drop
	rgb2hsv | h s v
	128 16 *>> 128 swap - 'c1w !
	61 16 *>> | 61 cae en color siempre, deberia ser 64!
	cwx 68 + cwy 68 + 2swap
	xy+polar
	2dup getpixel  0? ( 3drop ; )
	'c1 ! 'c1y ! 'c1x !
	;

:setcolor | color --
	cwx 140 + cwy c1w + getpixel
	dup 'colord !
	'pal8 npal 2 << + !
	;

:xypen SDLx SDLy ;

:selectColorWheel
	$999999 Color
	cwx cwy 200 160 FRect
	cwx 2 + cwy 2 + colorwimg Image
	0 ( 128 <?
		c1 0 pick2 1 << colmix Color
		cwx 140 + over cwy + over 10 + over Line
		1 + ) drop
	cwx 2 + cwy 2 + 128 128 guiBox
	SDLb SDLx SDLy guiIn
	[ 	xypen 2dup 
		getPixel 0? ( 3drop ; ) 
		'c1 ! 'c1y ! 'c1x ! setcolor ; ] onMove
	cwx 138 + cwy 12 130 guiBox
	SDLb SDLx SDLy guiIn
	[ xypen nip cwy - 128 clamp0max 'c1w ! setcolor ; ] onMove

	$0 Color
	c1x 3 - c1y 3 - 6 6 Rect
	cwx 137 + cwy c1w + 2 - 16 4 Rect

	$ffffff Color
	c1x 2 - c1y 2 - 4 4 Rect
	cwx 138 + cwy c1w + 1 - 14 2 Rect
 	cwx 70 + cwy 138 + bat
	colord $ffffffff and "$%h" sprint bprint
	colord Color
	cwx 10 + cwy 134 + 50 20 FRect
	
	cwx cwy 200 160 guiBox
	SDLb SDLx SDLy guiIn
	guiEmpty
	;

#ink

::dlgColor
	select 1? ( selectColorWheel ) drop

	$454545 Color
	xpal ypal 60 380 FRect

	colord Color
	xpal 10 + ypal 5 + 40 30 
	2over 2over FRect
	guiBox
	SDLb SDLx SDLy guiIn
	[ select 1 xor 'select ! selectColorWheel colord color! ; ] onClick

	'pal8
	0 ( 20 <?
		0 ( 3 <?
			rot d@+ dup 'ink ! Color
			rot rot
        	over 4 << 41 + ypal +
			over 4 << 7 + xpal + swap 14 14
			2over 2over FRect
			guiBox
			SDLb SDLx SDLy guiIn
			over 3 * over +
			[ dup 'npal ! ink color! ; ] onClick
			npal =? ( 
				$ffffff Color
				xr1 yr1 xr2 pick2 - yr2 pick2 - Rect
				)
			drop
			1 + ) drop
		1 + ) 2drop ;

::dlgColorIni
	"media/img/colorwheel.png" loadimg 'colorwimg !
	'pal8 >a
	$000000 da!+
	$888888 da!+
	$ffffff da!+
	0 ( 19 <?
		dup 1.0 19 */ 1.0 0.5 hsv2rgb da!+
		dup 1.0 19 */ 1.0 1.0 hsv2rgb da!+
		dup 1.0 19 */ 0.5 1.0 hsv2rgb da!+
		1 + ) drop
	$0 'colord !
	;

::xydlgColor! | x y --
	over 60 + 'cwx !
	dup 'cwy !
	'ypal ! 'xpal ! ;