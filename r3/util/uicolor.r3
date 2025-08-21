| Color Select Dialog
| PHREDA 2025
|---------------
^r3/lib/color.r3
^r3/util/ui.r3
^r3/util/txfont.r3

#colorvar
#c1x #c1y #c1w #c1a

|Vertex * 4
| 4  4   4    4   4
| xf yf rgba xtf ytf
#vert [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
#index [ 0 1 3 1 2 3 ] 
#col128 * 512

::color! | color --
	dup colorvar !
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
	colorvar ! 
	c1w 2 << 'col128 + d@ bgr2rgb
	'vert 7 2 << + d! | vertex color
	;

	
:selectColorPick
	'col128 >a
	0 ( 128 <?
		da@+ SDLColor
		curx 140 + over cury + 5 + over 10 + over SDLLine
		1 + ) drop
	
	SDLrenderer 0 'vert 4 'index 6 SDL_RenderGeometry	
	
	curx 140 + cury 5 + 12 128 guiBox
	[ SDLy cury - 5 - 128 clamp0max 'c1w ! setcolor ; ]
	onMove
	
	curx 5 + cury 5 + 128 128 guiBox
	[	SDLy cury - 5 - 128 clamp0max 'c1y ! 
		SDLx curx - 5 - 128 clamp0max 'c1x ! 
		setcolor ; ] 
	onMove

	curx 5 + cury 137 + 128 8 guiBox
	[ SDLx curx - 5 - 127 clamp0max 'c1a ! ; ]
	onMove
		
	$0 SDLColor
	curx 4 + cury 4 + 130 130 SDLRect
	curx 139 + cury 4 + 12 130 SDLRect
	curx 5 + c1x + 2 - cury 5 + c1y + 2 - 5 5 SDLRect	
	$ffffff SDLColor
	curx 137 + cury c1w + 4 + 16 3 SDLRect
	curx 5 + c1x + 1- cury 5 + c1y + 1- 3 3 SDLRect
	curx 5 + cury 140 + 128 2 SDLRect
	curx 5 + c1a + cury 137 + 2 8 SDLRect

| 	curx 5 + cury 158 + bat
|	colorvar @ $ffffffff and "$%h" sprint bprint
	colorvar @ SDLColor
	curx 10 + cury 154 + 50 20 2over 2over guibox SDLFRect
	'uiExitWidget onclick
	;

:fillcbox | -- ; fill vertex buffer
	'vert >a
	curx 5 + i2fp da!+ cury 5 + i2fp da!+ $ffffff da!+ 8 a+
	curx 5 + 128 + i2fp da!+ cury 5 + i2fp da!+ 12 a+ | don't store color
	curx 5 + 128 + i2fp da!+ cury 5 + 128 + i2fp da!+ 0 da!+ 8 a+
	curx 5 + i2fp da!+ cury 5 + 128 + i2fp da!+ 0 da!+ 8 a+
	;

:uiSelcol	
	0 0 uiPad
	uiZone@ 2drop |swap 0.07 %w - swap
	160 180 uiWinFit! fillcbox
	$222222 sdlcolor uiRFill10 $ffffff sdlcolor uiRRect10
	1 1 UIGridA 
	0 0 uigAt 
	selectColorPick
|	'uiExitWidget "ok" uiRBtn
	;
	
|-----	
:fcolor
	'uiSelcol uisaveLast
|	cifoc sdlColor uiRRect
	sdlkey
	<tab> =? ( nextfoco )
	drop ;
	
:fcolorini
	dup 'colorvar ! dup @ color! ;

::uiColor | 'var --
	uiZone 
	'fcolor 'fcolorini w/foco
	'clickfoco onClick		
	@ sdlcolor uiRFill ui.. ;

::uiColorH | 'var --
	uiZone 
	'fcolor 'fcolorini w/foco
	'clickfoco onClick		
	dup @ sdlcolor uiRFill 
	@ .h ttemitc
	ui.. ;
	
| boot	
: 'col128 >a 0 ( 128 <? dup 9 << 1.0 1.0 hsv2rgb da!+ 1+ ) drop ;
	