| sprites stack inv
| PHREDA 2024
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3


|------------- ISO
##isx 0.9 | 0.87
##isy 0.2 | 0.5
##isz -1.0
##isxo 512
##isyo 300

|------ FLOOR
:xyz2iso | x y z -- x y
	-rot
	over isx *. over isx *. + | z x y x'
	rot isy neg *. rot isy *. + | x' y'
	rot + ;

:2iso
	xyz2iso 
	swap 12 >> isxo + 
	swap 12 >> isyo + ;

:floor
	$ffffff sdlcolor
	-5.0 ( 5.0 <?
		-5.0 ( 5.0 <?
			2dup 0 2iso sdlpoint
			0.5 + ) drop
		0.5 + ) drop ;

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
	1.0 dx 2 << / 'dx ! | center pixel 4/ ?? 2/ not good
	1.0 dy 2 << / 'dy ! 
	0 ( 1.0 pick3 - <=?
		0 ( 1.0 pick3 - <=?
			dup dx + f2fp da!+ 
			over dy + f2fp da!+ 
			dup pick3 + dx - f2fp da!+ 
			over pick4 + dy - f2fp da!+
			pick2 + ) drop
		pick2 + ) drop
	here 
	a> over - 4 >> 1- 32 << 
	over 8 + @ or over 8 + ! | altura
	a> 'here ! ;

	 
|------- SSPRITE
#d1 #d2 #d3 #d4

:rotxyiso | x1 y1 -- xd yd
	over dx * over dy * -				| x y x1 y1 x'
	rot dy * rot dx * +					| x y x' y'
	over isx *. over isx *. + 17 >>		| x y x' y' x''
	rot isy neg *. rot isy *. + 17 >>	| x y 
	;	

:fillvertiso | ang --
	sincos 'dx ! 'dy !
	xm neg ym neg rotxyiso 
	$ffff and 16 << swap $ffff and or 'd1 ! 
	xm ym neg rotxyiso 
	$ffff and 16 << swap $ffff and or 'd2 !
	xm ym rotxyiso 
	$ffff and 16 << swap $ffff and or 'd3 !
	xm neg ym rotxyiso 
	$ffff and 16 << swap $ffff and or 'd4 !
	;

#ssp

#tx1 #tx2
#ty1 #ty2
#cntl 
#ind

:gyx dup 32 << 48 >> swap 48 << 48 >> ; | y x

:settex | lev -- lev
	dup 3 << 16 + ssp + @
	dup 1 << $1fffe and f2fp 'tx1 !
	dup 15 >> $1fffe and f2fp 'ty1 !
	dup 31 >> $1fffe and f2fp 'tx2 !
	47 >> $1fffe and f2fp 'ty2 !
	;

:settex | lev -- lev
	dup 4 << 16 + ssp + 
	d@+ 'tx1 ! d@+ 'ty1 ! d@+ 'tx2 ! d@ 'ty2 ! ;

	
| posx posy color texx texy 
:makelayer
	d1 gyx pick3 + i2fp da!+ over + i2fp da!+ 
	$ffffffff da!+ tx1 da!+ ty1 da!+
	d2 gyx pick3 + i2fp da!+ over + i2fp da!+ 
	$ffffffff da!+ tx2 da!+ ty1 da!+
	d3 gyx pick3 + i2fp da!+ over + i2fp da!+ 
	$ffffffff da!+ tx2 da!+ ty2 da!+
	d4 gyx pick3 + i2fp da!+ over + i2fp da!+ 
	$ffffffff da!+ tx1 da!+ ty2 da!+
	1 'cntl +!
	;
	
|#indexm [ 0 1 2 2 3 0 ]
:makeindex
	0 ( cntl <?
		dup 2 << 
		dup da!+ dup 1 + da!+ dup 2 + da!+
		dup 2 + da!+ dup 3 + da!+ da!+
		1+ ) drop ;

|.................................
::isospr | x y a z 'ss --
	dup 'ssp ! 
	8 + @ 
	dup 32 >> swap
	dup $ffff and swap
	16 >> $ffff and			| x y a z lev w h
	pick3 16 *>> 'ym !		| x y a z lev w 
	pick2 16 *>> 'xm !		| x y a z lev
	rot fillvertiso 		| x y z lev
	swap 16 >> 0? ( 1+ ) swap			| x y zi lev
	here >a 0 'cntl ! 
	( 1? 1- settex 
		2swap				| zi lev x y
		pick3 ( 1? 1- >r makelayer 1- r> ) drop
		2swap ) 4drop 
	a> 'ind !
	makeindex
	SDLrenderer ssp @ here 
	cntl 2 << | 4*
	ind 
	cntl 1 << dup 1 << + | 6*
	SDL_RenderGeometry 
	;
	
|--------------
|---------------------------------
#rec [ 262 450 200 100 ]

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
	

#spcar 
#spvan 
#sphouse

#zoom 4.0
#a	
	
:game
	$3a3a3a SDLcls
	$ffffff pccolor
	0 0 pcat "Sprite stack" pcprint pccr
	isy isx "iso %f %f : <ad ws>" pcprint pccr
	zoom "%f" pcprint
	
	floor	
	
	300 300 a 4.0 spvan isospr
	700 500 a 5.0 sphouse isospr
	300 500 a 6.0 spcar isospr
	
	0.002 'a +! 
	
|	0 0 zoomsrc
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<w> =? ( 0.1 'isy +! )
	<s> =? ( -0.1 'isy +! )
	<a> =? ( 0.1 'isx +! )
	<d> =? ( -0.1 'isx +! )
	
	<up> =? ( 0.1 'zoom +! )
	<dn> =? ( -0.1 'zoom +! )
	drop
	;

:main
	"WORD SS" 1024 600 SDLinit
	pcfont

	16 16 "media/stackspr/car.png" loadss 'spcar !
	14 37 "media/stackspr/van.png" loadss 'spvan !
	64 64 "media/stackspr/obj_house3.png" loadss 'sphouse !
	
	'game SDLshow 
	SDLquit ;

: main ;