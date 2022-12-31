| Color Select Dialog
| PHREDA 2020
|---------------
^r3/win/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/gui.r3
^r3/util/bfont.r3

##colord 0
#select 0

#cwx #cwy | pos windows
#c1x #c1y #c1w #c1a

|Vertex * 4
| 4  4   4    4   4
| xf yf rgba xtf ytf
#vert [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
#index [ 0 1 3 1 2 3 ] 
#col128 * 512

::color! | color --
	dup 'colord !
	select 0? ( 2drop ; ) drop
	rgb2hsv | h s v
	rot 
	128 16 *>> 'c1w !
	128 16 *>> 128 swap - 'c1y ! 
	128 16 *>> 'c1x !
	;

:setcolor | --
	cwx 5 + c1x +
	cwy 5 + c1y +
	SDLgetpixel
	'colord ! ;
	
:setcolorw | --
	cwx 145 + 
	cwy 5 + c1w + SDLgetpixel
	dup $ff00 and over 16 << $ff0000 and or swap 16 >> $ff and or | swap BGR to RGB
	'vert 7 2 << + d! | vertex color
	setcolor 
	;
	
:fillcbox | -- ; fill vertex buffer
	'vert >a
	cwx 5 + i2fp da!+ cwy 5 + i2fp da!+ $ffffff da!+ 8 a+
	cwx 5 + 128 + i2fp da!+ cwy 5 + i2fp da!+ 12 a+ | don't store color
	cwx 5 + 128 + i2fp da!+ cwy 5 + 128 + i2fp da!+ 0 da!+ 8 a+
	cwx 5 + i2fp da!+ cwy 5 + 128 + i2fp da!+ 0 da!+ 8 a+
	;

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
	[ 	SDLy cwy - 5 - 127 clamp0max 'c1w ! 
		setcolorw ; ] dup
	onDnMoveA
	
	cwx 5 + cwy 5 + 128 128 guiBox
	[ 	SDLy cwy - 5 - 127 clamp0max 'c1y ! 
		SDLx cwx - 5 - 127 clamp0max 'c1x ! 
		setcolor ; ] dup
	onDnMoveA

	cwx 5 + cwy 137 + 128 8 guiBox
	[ 	SDLx cwx - 5 - 127 clamp0max 'c1a ! ; ] dup
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

::dlgColor | x y --
	'cwy ! 'cwx !
	select 1? ( 40 'cwx +! fillcbox selectColorPick -40 'cwx +! ) drop

	$454545 SDLColor
	cwx cwy 40 40 SDLFRect

	colord SDLColor
	cwx 5 + cwy 5 + 30 30 
	2over 2over SDLFRect
	guiBox
	[ select 1 xor 'select ! ; ] onClick
	;

::dlgColorIni
	'col128 >a
	0 ( 128 <?
		dup 9 << 1.0 1.0 hsv2rgb da!+
		1 + ) drop
	fillcbox		
	$ffffff 'colord !
	127 'c1a !
	$ff 'vert 7 2 << + d! | vertex color
	colord color! 
	;
