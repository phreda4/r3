| sprites stack test
| PHREDA 2024
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3

#sptree
#spcar


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
	
	
#x #y 
#dx #dy -2

#a	

:drawsp | x y a --
	>r
	43 ( 1?
		pick2 pick2 r@ 2.0 pick4 sptree sspriteiso
		rot dx + rot dy + rot 1- ) 
	3drop r> drop ;

:drawsp1 | x y a --
	3.0 42 sptree sspriteiso
	41 ( 1?
		-3 over sptree sspriteniso | dy n ssprite --
		1- ) drop ;

:game
	$0 SDLcls
	$ffffff pccolor
	0 0 pcat "Sprite stack" pcprint
	
	400 400 0 drawsp
	550 420 a drawsp | x y --
	
	650 320 a drawsp1 | x y --	
	250 520 a 0.1 + drawsp1 | x y --		
	
	0.005 'a +!
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"Sprite Rotation" 1024 600 SDLinit
	pcfont
	36 36 "media/stackspr/blue_tree.png" ssload 'sptree !
	16 16 "media/stackspr/car.png" ssload 'spcar !
	
	'game SDLshow 
	SDLquit ;

: main ;