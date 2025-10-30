| Color Select Dialog
| PHREDA 2025
|---------------
^r3/lib/color.r3
^r3/util/immi.r3

#colorvar
#c1x #c1y #c1w #c1a

|Vertex * 4
| 4  4   4    4   4
| xf yf rgba xtf ytf
#vert [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
#index [ 0 1 3 1 2 3 ] 
#col128 * 512

:coltex
	c1w 2 << 'col128 + d@ bgr2rgb
	'vert 7 2 << + d! ; | vertex color

::color! | color --
	dup colorvar !
	rgb2hsv | h s v
	128 16 *>> 127 swap - 'c1y ! 
	128 16 *>> 'c1x !
	128 16 *>> 'c1w !
	coltex ;
	
:setcolor | --
	c1w 9 <<
	c1x 9 <<
	127 c1y - 9 <<
	hsv2rgb colorvar ! 
	coltex ;
	
:selectColorPick
	uiZone
	$222222 sdlcolor uiFill
	'col128 >a
	0 ( 128 <?
		da@+ SDLColor
		cx 140 + over cy + 5 + over 10 + over SDLLine
		1 + ) drop
	
	SDLrenderer 0 'vert 4 'index 6 SDL_RenderGeometry	
	
	cx 140 + cy 5 + 12 127 uiZoneBox
	[ SDLy cy - 127 clamp0max 'c1w ! setcolor ; ] uiSel
	uiBackBox
	
	cx 5 + cy 5 + 127 127 uiZoneBox
	[ SDLy cy - 127 clamp0max 'c1y ! 
		SDLx cx - 127 clamp0max 'c1x ! setcolor ; ] uiSel
	uiBackBox
	
	cx 5 + cy 137 + 127 8 uiZoneBox
	[ SDLx cx - 127 clamp0max 'c1a ! ; ] uiSel
	uiBackBox
	
	$0 SDLColor
	cx 4 + cy 4 + 130 130 SDLRect
	cx 139 + cy 4 + 12 130 SDLRect
	cx 5 + c1x + 2 - cy 5 + c1y + 2 - 5 5 SDLRect	
	$ffffff SDLColor
	cx 137 + cy c1w + 4 + 16 3 SDLRect
	cx 5 + c1x + 1- cy 5 + c1y + 1- 3 3 SDLRect
	cx 5 + cy 140 + 128 2 SDLRect
	cx 5 + c1a + cy 137 + 2 8 SDLRect

 	cx 64 + cy 150 + txat
	colorvar @ $ffffffff and "$%h" txprint
	colorvar @ SDLColor
	cx 10 + cy 154 + 50 20 
	2over 2over SDLFRect
	uiZoneBox
	'uiExitWidget uiClk
	uiBackBox ;

:fillcbox | -- ; fill vertex buffer
	'vert >a
	cx 5 + i2fp da!+ cy 5 + i2fp da!+ $ffffff da!+ 8 a+
	cx 5 + 128 + i2fp da!+ cy 5 + i2fp da!+ 12 a+ | don't store color
	cx 5 + 128 + i2fp da!+ cy 5 + 128 + i2fp da!+ 0 da!+ 8 a+
	cx 5 + i2fp da!+ cy 5 + 128 + i2fp da!+ 0 da!+ 8 a+
	;
	
:inicolor
	dup 'colorvar ! dup @ color! 
	cx cy 160 180
	'selectColorPick uiSaveLast 
	fillcbox
	;

:kbcolor
	$ffffff sdlcolor
	4 cx 1- cy 1- cw 2 + txh 2 + SDLRound
	'iniColor uiClk 
	sdlkey 
	<tab> =? ( tabfocus ) 
	drop ;
	
::uiColor | 'var --
	uiZone 
	'kbcolor uiFocus
	@ sdlcolor 
	4 cx cy cw txh SDLFRound 
	ui.. ;

::uiColorH | 'var --
	uiZone 
	'kbcolor uiFocus
	dup @ sdlcolor uiRFill 
	@ .h ttwritec
	ui.. ;
	
| boot	
: 'col128 >a 0 ( 128 <? dup 9 << 1.0 1.0 hsv2rgb da!+ 1+ ) drop ;
	