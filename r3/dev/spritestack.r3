| sprites stack test
| PHREDA 2024
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3

#sptree
#spcar
#sptank

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
	1.0 42 sptree sspriteiso
	41 ( 1?
		-1.0 over sptree sspriteniso | dy n ssprite --
		1- ) drop ;
		
:isospr | x y a z lev 'ss --
	pick2 neg pick2 pick2 
	>r >r >r
	sspriteiso | a lev 'ss
	r> r> r>
	swap 1- ( 1?  | a 'ss lev 
		pick2 over pick3 sspriteniso | dy n ssprite --
		1- ) 3drop ;
		
:2iso
	xyz2iso 
	swap 50 * int. 512 + 
	swap 50 * int. 300 + ;
	
:floor
	$ffffff sdlcolor
	-5.0 ( 5.0 <?
		-5.0 ( 5.0 <?
			2dup 0 2iso sdlpoint
			0.5 + ) drop
		0.5 + ) drop ;

#zcar -5.0
#vz

:grav
	vz 'zcar +!
	0.001 'vz +!
	zcar +? ( 0 'zcar ! vz neg 'vz ! )
	drop
	;
	
:game
	$3a3a3a SDLcls
	$ffffff pccolor
	0 0 pcat "Sprite stack" pcprint
	
	floor	
	
	| v1
	400 400 0 drawsp
	550 420 a drawsp | x y --
	| v2
	650 320 a drawsp1 | x y --	
	250 520 a 0.1 + drawsp1 | x y --		
	| v3
	300 200 a 3.0 43 sptree isospr
	0 0 zcar 2iso a 3.0 20 sptank isospr
	100 500 a 5.0 10 spcar isospr
	
	0.005 'a +!
	grav
	
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
	32 32 "media/stackspr/tank.png" ssload 'sptank !
	
	'game SDLshow 
	SDLquit ;

: main ;