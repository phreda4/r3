| Color Select Dialog
| PHREDA 2020
|---------------
^r3/win/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/gui.r3
^r3/util/bfont.r3

##colord 0

#select 0

#cwx 0 #cwy 200 | pos windows
#c1x #c1y #c1w #c1a

|Vertex * 4
| 4  4   4    4   4
| xf yf rgba xtf ytf
#vert [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
#index [ 0 1 3 1 2 3 ] 
#col128 * 512

#pal8 * 300
#npal

::color! | color --
	dup 'colord !
	|select 0? ( 2drop ; ) drop
	rgb2hsv | h s v
	rot 
	128 16 *>> 'c1w !
	128 16 *>> 128 swap - 'c1y ! 
	128 16 *>> 'c1x !
	
	c1w 2 << 'col128 + d@ bgr2rgb
	'vert 7 2 << + d! | vertex color
	;

:setcolor | --
	c1w 9 <<
	c1x 9 <<
	128 c1y - 9 <<
	hsv2rgb 
	'colord ! ;

:setcolorw | c1w --
	'c1w ! setcolor ;
	

:selectColorPick
	$454545 SDLColor
	cwx cwy 160 180 SDLFRect

	'col128 >a
	0 ( 128 <?
		da@+ SDLColor
		cwx 140 + over cwy + 5 + over 10 + over SDLLine
		1 + ) drop
	
	SDLrenderer 0 'vert 4 'index 6 SDL_RenderGeometry	
	
	cwx 140 + cwy 5 + 12 128 guiBox
	[ SDLy cwy - 5 - 128 clamp0max setcolorw ; ] dup
	onDnMoveA
	
	cwx 5 + cwy 5 + 128 128 guiBox
	[	SDLy cwy - 5 - 128 clamp0max 'c1y ! 
		SDLx cwx - 5 - 128 clamp0max 'c1x ! 
		setcolor ; ] dup
	onDnMoveA

	cwx 5 + cwy 137 + 128 8 guiBox
	[ SDLx cwx - 5 - 127 clamp0max 'c1a ! ; ] dup
	onDnMoveA	
		
	$0 SDLColor
	cwx 4 + cwy 4 + 130 130 SDLRect
	cwx 139 + cwy 4 + 12 130 SDLRect
	
	cwx 5 + c1x + 2 -
	cwy 5 + c1y + 2 -
	5 5 SDLRect	
	
	$ffffff SDLColor
	cwx 137 + 
	cwy c1w + 4 + 
	16 3 SDLRect
	
	cwx 5 + c1x + 1 -
	cwy 5 + c1y + 1 -
	3 3 SDLRect

	cwx 5 + cwy 140 + 
	128 2 SDLRect

	cwx 5 + c1a +
	cwy 137 +
	2 8 SDLRect
	
 	cwx 5 + cwy 158 + bat
	colord $ffffffff and "$%h" sprint bprint
	
|	colord SDLColor
|	cwx 10 + cwy 154 + 50 20 SDLFRect
	
	cwx cwy 160 180 guiBox
	guiEmpty
	;

#ink

:fillcbox | -- ; fill vertex buffer
	'vert >a
	cwx 5 + i2fp da!+ cwy 5 + i2fp da!+ $ffffff da!+ 8 a+
	cwx 5 + 128 + i2fp da!+ cwy 5 + i2fp da!+ 12 a+ | don't store color
	cwx 5 + 128 + i2fp da!+ cwy 5 + 128 + i2fp da!+ 0 da!+ 8 a+
	cwx 5 + i2fp da!+ cwy 5 + 128 + i2fp da!+ 0 da!+ 8 a+
	;

::dlgColor | x y --
	select 1? ( 60 'cwx +! fillcbox selectColorPick -60 'cwx +! ) drop

	$454545 SDLColor
	cwx cwy 60 380 SDLFRect

	colord SDLColor
	cwx 10 + cwy 5 + 40 30 
	2over 2over SDLFRect
	guiBox
	[ select 1 xor 'select ! ; ] onClick
	
	'pal8
	0 ( 20 <?
		0 ( 3 <?
			rot d@+ dup 'ink ! SDLColor
			-rot
        	over 4 << 41 + cwy +
			over 4 << 7 + cwx + swap 14 14
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
	'col128 >a
	0 ( 128 <?
		dup 9 << 1.0 1.0 hsv2rgb da!+
		1 + ) drop
	'pal8 >a
	$000000 da!+
	$888888 da!+
	$ffffff da!+
	0 ( 19 <?
		dup 1.0 19 */ 1.0 0.5 hsv2rgb da!+
		dup 1.0 19 */ 1.0 1.0 hsv2rgb da!+
		dup 1.0 19 */ 0.5 1.0 hsv2rgb da!+
		1 + ) drop
	$ffffff 'colord !
	127 'c1a !
	colord color! 
	;

::xydlgColor! | x y --
	'cwy ! 'cwx !
	fillcbox
	;