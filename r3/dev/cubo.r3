| stack sprite test
| PHREDA 2024
|-------------------
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3
^r3/lib/gui.r3
^r3/lib/3d.r3

#sptree
#spcar

|-------------------------------
#xcam 0 #ycam 0 #zcam 20.0
#xr 0 #yr 0

:freelook
	sdlb 0? ( drop ; ) drop
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg 'xr ! 'yr ! ;

|-------------------- drawcube
#xop #yop
:xxop 'yop ! 'xop ! ;
:xxline 2dup xop yop SDLLine 'yop ! 'xop ! ;

:3dop project3d xxop ;
:3dline project3d xxline ;

:drawboxz | z --
	-1.0 -1.0 pick2 3dop
	1.0 -1.0 pick2 3dline
	1.0 1.0 pick2 3dline
	-1.0 1.0 pick2 3dline
	-1.0 -1.0 rot 3dline ;

:drawlinez | x1 x2 --
	2dup -1.0 3dop 1.0 3dline ;

:drawcube |
	-1.0 drawboxz
	1.0 drawboxz
	-1.0 -1.0 drawlinez
	1.0 -1.0 drawlinez
	1.0 1.0 drawlinez
	-1.0 1.0 drawlinez ;	
	
|--------------------- sprite stack
#x #y
#dx 1.0 #dy 1.0
#layers 43

:drawup
	0 ( 43 <?
		pick2 int. pick2 int. pick2 sptree ssprite
		rot dx + rot dy + rot 1+ ) drop ;

:drawdn
	42 ( 1?
		pick2 int. pick2 int. pick2 sptree ssprite
		rot dx + rot dy + rot 1- ) drop ;
		
:drawss
	-1.0 -1.0 -1.0 project3d 
	16 << 'y ! 16 << 'x !
	-1.0 -1.0 1.0 project3d 
	16 << y - 43 / 'dy ! 16 << x - 43 / 'dx !
	
	x y 
	1.0 -1.0 -1.0 project3d 
	1.0 1.0 -1.0 project3d 
	-1.0 1.0 -1.0 project3d 
	fillspritevert
	
	0 0 -1.0 project3d 
	16 << swap 16 << swap
	drawdn 
	2drop
	;
	
|---------------------------------
#rec [ 462 250 100 100 ]

:zoom | x y  --
	0 100 100 32 0 0 0 0 SDL_CreateRGBSurface  |
	SDLrenderer 'rec
	pick2 8 + @ d@ pick3 32 + @ pick4 24 + d@ | format | pixels | pitch
	SDL_RenderReadPixels 
	SDLrenderer over SDL_CreateTextureFromSurface | surf tex
	swap SDL_FreeSurface
	-rot 300 300 pick4 SDLImages
	SDL_DestroyTexture
	;	
|-----------------------------------------
:main
	$0 SDLcls
	$ffffff pccolor
	0 0 pcat "Sprite stack" pcprint
	
	freelook
	
	1.0 3dmode
	xr mrotx yr mroty 
	xcam ycam zcam mtrans
	
	$ff00 sdlcolor drawcube
	drawss
	0 0 zoom
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:
	"Sprite Rotation" 1024 600 SDLinit
	pcfont
	36 36 "media/stackspr/blue_tree.png" ssload 'sptree !
	16 16 "media/stackspr/car.png" ssload 'spcar !
		
	'main sdlshow 
	SDLquit ;