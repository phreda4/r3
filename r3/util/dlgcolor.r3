| Color Select Dialog
| PHREDA 2020
|---------------
^r3/win/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/gui.r3

#xpal 0 #ypal 200
#cwx 60 #cwy 200

##color $0

#colorwimg |188x189
#c1 $ffffff
#c1x #c1y #c1w

#pal8 * 300
#npal
#select 0

::color! | color --
	dup 'color !
	select 0? ( 2drop ; ) drop
	rgb2hsv | h s v
	128 16 *>> 128 swap - 'c1w !
	61 16 *>> | 61 cae en color siempre, deberia ser 64!
	cwx 68 + cwy 68 + 2swap
	xy+polar
|	2dup SDLgetpixel  0? ( 3drop ; )
|	'c1 ! 'c1y ! 'c1x !
	2drop
	;

:setcolor | color --
|	cwx 140 + cwy c1w + SDLgetpixel
	dup 'color !
	'pal8 npal 2 << + !
	;

:xypen SDLx SDLy ;

:selectColorWheel
	$999999 SDLColor
	cwx cwy 200 160 SDLFillRect
	cwx 2 + cwy 2 + colorwimg SDLimage
|	cwx 140 + cwy xy>v >a
|	0 ( 128 <?
|		c1 0 pick2 1 << colmix
|		a> swap 10 fill sw 2 << a+
|		1 + ) drop
	cwx 2 + cwy 2 + 128 128 guiBox
	[ 
		xypen 
		|2dup xy>v @ 0? ( 3drop ; ) 
		0
		'c1 ! 'c1y ! 'c1x ! setcolor ; ] onMove
	cwx 138 + cwy 12 130 guiBox
	[ xypen nip cwy - 128 clamp0max 'c1w ! setcolor ; ] onMove

	$0 SDLColor
	c1x 3 - c1y 3 - 6 6 SDLRect
	cwx 137 + cwy c1w + 2 - 16 4 SDLRect

	$ffffff SDLColor
	c1x 2 - c1y 2 - 4 4 SDLRect
	cwx 138 + cwy c1w + 1 - 14 2 SDLRect
 	cwx 70 + cwy 138 + bat
	color $ffffffff and "$%h" sprint bprint
	color SDLColor
	cwx 10 + cwy 134 + 50 20 SDLFillRect
	;

#ink

::dlgColor
	select 1? ( selectColorWheel ) drop

	$454545 SDLColor
	xpal ypal 60 380 SDLFillRect

	color SDLColor
	xpal 10 + ypal 5 + 40 30 
	2over 2over SDLFillRect
	guiBox
	SDLb SDLx SDLy guiIn
	[ select 1 xor 'select ! selectColorWheel color color! ; ] onClick

	'pal8
	0 ( 20 <?
		0 ( 3 <?
			rot d@+ dup 'ink ! SDLColor
			rot rot
        	over 4 << 41 + ypal +
			over 4 << 7 + xpal + swap 14 14
			2over 2over SDLFillRect
			guiBox
			SDLb SDLx SDLy guiIn
			over 3 * over +
			[ dup 'npal ! ink color! ; ] onClick
			npal =? ( 
				$ffffff SDLColor
				xr1 yr1 xr2 pick2 - yr2 pick2 - SDLREct
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
	$0 'color !
	;

::xydlgColor! | x y --
	over 60 + 'cwx !
	dup 'cwy !
	'ypal ! 'xpal ! ;