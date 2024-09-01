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
#spcar 
#spvan 
#sphouse

#imglist
#imglist>
#imgcnt

#imgsort

#dx #dy

:+img | w h "file" -- adr
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	imglist> >a
	a!+ | texture
	16 << or a!+ |layersize
	dy 16 << dx or a!+ |imgsize
	0 a!+
	a> 'imglist> !
	a> 8 - 
	;
	
:.tex ;
:.layer 1 ncell+ ;
:.size 2 ncell+ ;
:.info 3 ncell+ ;
	
:]img | n -- adr
	5 << imglist + ;
:]simg | n -- adr
	3 << imgsort + @ $ffff and ]img ;
	
:2xy dup $ffff and swap 16 >> $ffff and ;
	
#treebox
#treebox>

:+freebox |
	treebox> !+ 'treebox> ! ;
	
#x #y
#wmin #hmin #wmax #hmax
:packbox
	0 'x ! 0 'y !
	0 'wmin ! 0 'hmin !
	0 ( imgcnt <?
		wmin hmin 16 << or over ]simg .info !
		dup ]simg .size @ 2xy  | dx dy
		over wmin + wmax max 'wmax !
		dup hmin + hmax max 'hmax !
		drop 
		'wmin +!
		1+ ) drop
	;
	
:loadimgs
	12 26 "media/stackspr/veh_mini1.png" +img 'spcar !
	14 37 "media/stackspr/van.png" +img 'spvan !
	64 64 "media/stackspr/obj_house1.png" +img 'sphouse !
	
	imglist> imglist - 5 >> 'imgcnt !
	
	imglist> 'imgsort !	
	imgsort >a
	0 ( imgcnt <?
		dup ]img .size @ neg 32 << over or  | neg=inversesort
		a!+
		1+ ) drop
	>a dup 'treebox ! 'treebox> !
	imgcnt imgsort shellsort1
	
	packbox
	;
	
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

:game
	$3a3a3a SDLcls
	$ffffff pccolor
	0 0 pcat "Atlas generator - " pcprint 
	imgcnt "%d images" pcprint pccr
	hmax wmax "%d %d image max" pcprint
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
		1+ ) drop		
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:reset
	here dup 'imglist ! 'imglist> !

	;
	
:main
	"ATLAS GENERATOR" 1024 600 SDLinit
	pcfont

	reset
	loadimgs
	
	'game SDLshow 
	SDLquit ;

: main ;