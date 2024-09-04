| sprites atlas generator
| PHREDA 2024

^r3/lib/gui.r3
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3
^r3/util/sort.r3

|------ FLOOR
#ym #xm
#dx #dy

|--------- LOAD 
::loadss | w h "file" -- ssprite
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	|dup 0 SDL_SetTextureScaleMode | not fix
	here >a a!+ 		| texture
	2dup 16 << or a!+	| wi hi
	dy 16 <</ swap dx 16 <</ | dy dx
	0 ( 1.0 pick3 - <=?
		0 ( 1.0 pick3 - <=?
			dup f2fp da!+ 
			over f2fp da!+ 
			dup pick3 + f2fp da!+ 
			over pick4 + f2fp da!+		
			pick2 + ) drop
		pick2 + ) drop
	here 
	a> over - 4 >> 1- 32 << 
	over 8 + @ or over 8 + ! | altura
	a> 'here ! ;

	
|--------------
#rec [ 262 250 200 100 ]

:zoomsrc | x y  --
	0 200 100 32 0 0 0 0 SDL_CreateRGBSurface  |
	SDLrenderer 'rec
	pick2 8 + @ d@ pick3 32 + @ pick4 24 + d@ | format | pixels | pitch
	SDL_RenderReadPixels 
	SDLrenderer over SDL_CreateTextureFromSurface | surf tex
	swap SDL_FreeSurface
	-rot 600 300 pick4 SDLImages
	SDL_DestroyTexture
	;	
	
|--------------
#imglist
#imglist>
#imgcnt
#imgsort
#dx #dy

:+img | w h "file" -- 
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	a[ imglist> >a
	a!+ | texture
	16 << or a!+ |layersize
	dy 16 << dx or a!+ |imgsize
	0 a!+
	a> 'imglist> ! ]a
	;
	
:.tex ;				| texture
:.layer 1 ncell+ ;	| layer size
:.size 2 ncell+ ;	| img size
:.info 3 ncell+ ;	| new position
	
:]img | n -- adr
	5 << imglist + ;
:]simg | n -- adr
	3 << imgsort + @ $ffff and ]img ;
	
:2xy dup $ffff and swap 16 >> $ffff and ;
	
	
#x #y
#wmin #hmin #wmax #hmax
#newtex

| simple..not calc
:packbox
	0 'x ! 0 'y !
	0 'wmin ! 0 'hmin !
	0 ( imgcnt <?
		wmin hmin 16 << or over ]simg .info !
		dup ]simg .size @ 2xy  | dx dy
		over wmin + wmax max 'wmax !
		dup hmin + hmax max 'hmax !
		drop 
		1+ 'wmin +!
		1+ ) drop
|	0 SDL_TEXTUREACCESS_STATIC,    < Changes rarely, not lockable 
|	1 SDL_TEXTUREACCESS_STREAMING, < Changes frequently, lockable
|	2 SDL_TEXTUREACCESS_TARGET     < Texture can be used as a render target
| SDL_PIXELFORMAT_ARGB8888 16462004
	SDLrenderer $16462004 2 wmax hmax SDL_CreateTexture 'newtex !
	SDLrenderer newtex SDL_SetRenderTarget
	newtex 0 SDL_SetTextureBlendMode | SDL_BLENDMODE_NONE
	0 ( imgcnt <?
		dup ]img .info @ 2xy
		pick2 ]img .tex @ SDLImage | x y img --
		dup ]img .tex @ SDL_DestroyTexture
		1+ ) drop
	SDLrenderer 0 SDL_SetRenderTarget	
	newtex 1 SDL_SetTextureBlendMode | SDL_BLENDMODE_BLEND
	;
	
:loadlistss | list --
	a[ >a
	( ca@+ 1? ca@+
		a> "media/stackspr/%s.png" sprint +img 
		a> >>0 >a ) drop ]a ;
	
:genatlas | list --
	here dup 'imglist ! 'imglist> !
	loadlistss
	imglist> imglist - 5 >> 'imgcnt !
	imglist> 'imgsort !	
	
	imgsort >a
	0 ( imgcnt <?
		dup ]img .size @ neg 32 << over or  | neg=inversesort
		a!+
		1+ ) drop
	imgcnt imgsort shellsort1
	
	packbox
	
	|** debug
	0 ( imgcnt <?
		dup ]simg .size @ 2xy "%d %d : " .print
		dup ]simg .info @ 2xy "%d %d" .println
		1+ ) drop
	|** debug
	
	
	;

|--------- LOAD 
::loadss | w h "file" -- ssprite
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	|dup 0 SDL_SetTextureScaleMode | not fix
	
	here >a a!+ 		| texture
	2dup 16 << or a!+	| wi hi
	dy 16 <</ swap dx 16 <</ | dy dx
	0 ( 1.0 pick3 - <=?
		0 ( 1.0 pick3 - <=?
			dup f2fp da!+ 
			over f2fp da!+ 
			dup pick3 + f2fp da!+ 
			over pick4 + f2fp da!+		
			pick2 + ) drop
		pick2 + ) drop
	here 
	a> over - 4 >> 1- 32 << 
	over 8 + @ or over 8 + ! | altura
	a> 'here ! ;

| cntspr
| spr1 spr2 .. sprn	
| altura|w|h
| altura{x1 y1 x2 y2}
|  
| altura|w|h
| altura{x1 y1 x2 y2}
|

	
:debugimglist
	$ffff pccolor
	imglist ( imglist> <? 
		@+ "%h " pcprint
		@+ "%h " pcprint
		@+ 2xy "%d %d " pcprint 
		@+ "%h " pcprint
		pccr
		) drop 
	$ff00ff pccolor
	0 (	imgcnt <?
		imgsort over 3 << + @ 
		|"%h " pcprint pccr
		$ffff and ]img .size @
		2xy "%d %d" pcprint pccr
		1+ ) drop
	;

:viewbox
	$ff00 sdlcolor
	0 ( imgcnt <?
		|dup 8 << sdlcolor
		dup ]img .info @ 
		dup $ffff and 1 >>
		swap 16 >> $ffff and 1 >>
		pick2 ]img .size @
		dup $ffff and 1 >>
		swap 16 >> $ffff and 1 >>
|		pick3 pick3 pick3 pick3 "%d %d %d %d" pcprint pccr
		sdlrect
		1+ ) drop ;

:game
	$3a3a3a SDLcls
	$ffffff pccolor
	0 0 pcat "Atlas generator - " pcprint 
	imgcnt "%d images" pcprint pccr
	hmax wmax "%d %d image max" pcprint
	
	|viewbox
	10 128 512 512 newtex sdlimages
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

|--------------------------------------------
#list1 
( 8 8 ) "obj_tree1"
( 8 8 ) "obj_tree1a"
( 8 8 ) "obj_tree1b"
( 8 8 ) "obj_tree1c"
( 10 10 ) "obj_tree2"
( 10 10 ) "obj_tree2a"
( 10 10 ) "obj_tree2b"
( 10 10 ) "obj_tree2c"
( 10 10 ) "obj_tree3"
( 6 6 ) "obj_tree4"
( 26 9 ) "deer" | 27
( 24 24 ) "T-Rex0" | 26
( 24 24 ) "T-Rex1" | 26
( 24 24 ) "T-Rex2" | 26
( 24 24 ) "T-Rex3" | 26
( 24 24 ) "T-Rex4" | 26
( 24 24 ) "T-Rex5" | 26
( 24 24 ) "T-Rex6" | 26
( 24 24 ) "T-Rex7" | 26
0

#list2
( 12 26 ) "veh_mini1" 
( 14 37 ) "van" 
( 36 36 ) "blue_tree"
( 16 16 ) "car"
( 10 10 ) "tank"
0

#list3
( 64 64 ) "obj_house1" 
( 64 64 ) "obj_house3" 
( 64 64 ) "obj_house4" 
( 64 64 ) "obj_house5" 
( 64 64 ) "obj_house8" 
( 64 64 ) "obj_house8c" 
0

	
:main
	"ATLAS GENERATOR" 1024 600 SDLinit
	pcfont

	'list1 genatlas
	
	'game SDLshow 
	SDLquit ;

: main ;