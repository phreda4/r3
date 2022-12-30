| Color Select Dialog
| PHREDA 2020
|---------------
^r3/win/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/gui.r3

#xpal 0 #ypal 200
#cwx 60 #cwy 200

|VErtex
| 4  4   4    4   4
| xf yf rgba xtf ytf
#vert [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
#index [ 0 1 3 1 2 3 ] 

##colord $0

#c1x #c1y #c1w #c1a

#pal8 * 300
#col128 * 512
#npal
#select 0

::color! | color --
	dup 'colord !
	select 0? ( 2drop ; ) drop
	rgb2hsv | h s v
	rot 
	128 16 *>> 'c1w !
	128 16 *>> 'c1y ! 
	128 16 *>> 'c1x !
	;

:setcolor | --
	cwx 2 + c1x +
	cwy 2 + c1y +
	SDLgetpixel
	dup 'colord !
	'pal8 npal 2 << + !
	;
	
:setcolorw
	cwx 140 + cwy c1w + SDLgetpixel
	'vert 7 2 << + !
	setcolor
	;
	
:xypen SDLx SDLy ;

:fillcbox
	'vert >a
	cwx 2 + i2fp da!+ cwy 2 + i2fp da!+ $ffffff da!+ 8 a+
	cwx 2 + 128 + i2fp da!+ cwy 2 + i2fp da!+ colord da!+ 8 a+
	cwx 2 + 128 + i2fp da!+ cwy 2 + 128 + i2fp da!+ 0 da!+ 8 a+
	cwx 2 + i2fp da!+ cwy 2 + 128 + i2fp da!+ 0 da!+ 8 a+
	;

:selectColorWheel
	$999999 SDLColor
	cwx cwy 200 160 SDLFRect

	'col128 >a
	0 ( 127 <?
		da@+ SDLColor
		cwx 140 + over cwy + over 10 + over SDLLine
		1 + ) drop
	
	SDLrenderer 0 'vert 4 'index 6 SDL_RenderGeometry	
	
	cwx 138 + cwy 12 127 guiBox
	[ SDLy cwy - 127 clamp0max 'c1w ! setcolorw ; ] dup
	onDnMoveA
	
	cwx 2 + cwy 2 + 128 128 guiBox
	[ xypen cwy - 'c1y ! cwx - 'c1x ! setcolor ; ] dup
	onDnMoveA
		
	$0 SDLColor
	cwx 138 + cwy c1w + 1 - 
	14 3 SDLRect
	
	cwx 2 + c1x + 4 -
	cwy 2 + c1y + 4 -
	8 8 SDLRect

	$ffffff SDLColor
	cwx 2 + c1x + 3 -
	cwy 2 + c1y + 3 -
	6 6 SDLRect

	
 	cwx 70 + cwy 138 + bat
	colord $ffffffff and "$%h" sprint bprint
	
	colord SDLColor
	cwx 10 + cwy 134 + 50 20 SDLFRect
	
	cwx cwy 200 160 guiBox
	guiEmpty
	;
		
#ink

::dlgColor
	select 1? ( selectColorWheel ) drop

	$454545 SDLColor
	xpal ypal 60 380 SDLFRect

	colord SDLColor
	xpal 10 + ypal 5 + 40 30 
	2over 2over SDLFRect
	guiBox
	[ select 1 xor 'select ! selectColorWheel colord color! ; ] onClick

	'pal8
	0 ( 20 <?
		0 ( 3 <?
			rot d@+ dup 'ink ! SDLColor
			rot rot
        	over 4 << 41 + ypal +
			over 4 << 7 + xpal + swap 14 14
			2over 2over SDLFRect
			guiBox
			over 3 * over +
			[ dup 'npal ! ink color! ; ] onClick
			npal =? ( 
				$ffffff SDLColor
				xr1 yr1 xr2 pick2 - yr2 pick2 - SDLRect
				)
			drop
			1 + ) drop
		1 + ) 2drop ;

::dlgColorIni
	'pal8 >a
	$000000 da!+
	$888888 da!+
	$ffffff da!+
	0 ( 19 <?
		dup 1.0 19 */ 1.0 0.5 hsv2rgb da!+
		dup 1.0 19 */ 1.0 1.0 hsv2rgb da!+
		dup 1.0 19 */ 0.5 1.0 hsv2rgb da!+
		1 + ) drop
	'col128 >a
	0 ( $7f <?
		dup 9 << 1.0 1.0 hsv2rgb da!+
		1 + ) drop
	fillcbox		
	$ff 'colord !
	;

::xydlgColor! | x y --
	over 60 + 'cwx !
	dup 'cwy !
	'ypal ! 'xpal ! ;