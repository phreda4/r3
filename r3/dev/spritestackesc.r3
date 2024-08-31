| sprites stack escena
| PHREDA 2024

^r3/lib/gui.r3
^r3/lib/3dgl.r3
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3

|------------- ISO
#isang 0
#isalt 1.0

#isx1 0.87
#isx2 0.87
#isx3 0

#isy1 0.5
#isy2 -0.5
#isy3 -1.0

:xyz2iso | x y z -- x y
	pick2 isx1 *. pick2 isx2 *. + over isx3 *. +
	swap isy3 *. rot isy2 *. + rot isy1 *. + 
	;
	

##isxo ##isyo 

:2iso | x y z -- x y 
	xyz2iso 
	swap 12 >> isxo + 
	swap 12 >> isyo + ;
	
:resetcam
	sw 2/ 'isxo !
	sh 2/ 'isyo !
	;

:isocam
	isang sincos 'isx1 ! isalt *. 'isy1 !
	isang 0.25 + sincos 'isx2 ! isalt *. 'isy2 !
	;

	
#xr 0 #yr 0

:isocamrot
	[ SDLx 'xr ! SDLy 'yr ! ; ] 
	[	sdlx xr over - 0.001 * 'isang +! 'xr ! 
		sdly dup yr - 0.001 * 'isalt +! 'yr ! 
		isocam
		; ] 
	onDnMove 
	;	

|------ FLOOR
:floor
	$ffffff sdlcolor
	-1.0 ( 1.0 <?
		-1.0 ( 1.0 <?
			2dup 0 2iso sdlpoint
			0.1 + ) drop
		0.1 + ) drop ;

:floor2
	$ffffff sdlcolor
	-1.0 ( 1.0 <?
		-1.0 ( 1.0 <?
			2dup 1.0 2iso sdlpoint
			0.1 + ) drop
		0.1 + ) drop ;

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
	
	0 xyz2iso 17 >> swap 17 >> swap
|	over isx *. over isx *. + 17 >>		| x y x' y' x''
|	rot isy neg *. rot isy *. + 17 >>	| x y 
	
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
	swap 16 >> | 0? ( 1+ ) 
	swap			| x y zi lev ** not real scale
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
	
#xp -20.0 #yp 0.0 #zp 0.0 #ap 0
#vxp 0 #vyp 0 #vap 0

:adv | vel --
	0? ( dup 'vxp ! 'vyp ! ; ) 
	ap neg sincos pick2 *. 'vyp ! *. 'vxp !
	;


:game
	gui
	$3a3a3a SDLcls
	$ffffff pccolor
	0 0 pcat "Voxel Escene" pcprint pccr
	vxp vyp "%f %f" pcprint pccr
	
	floor	
	floor2
	
|	300 300 a 4.0 spvan isospr

	xp yp 0.0 2iso ap 4.0 spcar isospr
	-20.0 -6.0 0.0 2iso 0.75 4.0 spcar isospr
	20.0 -6.0 10.0 2iso 0.25 4.0 spcar isospr
	10.0 5.0 0.0 2iso a 4.0 sphouse isospr
	
	|0.002 'a +! 
	
|	0 0 zoomsrc

isocamrot
		
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	
	<le> =? ( -0.002 'vap ! )	>le< =? ( 0 'vap ! )
	<ri> =? ( 0.002 'vap ! )	>ri< =? ( 0 'vap ! )
	
	<up> =? ( -0.5 adv ) >up< =? ( 0 adv )
	<dn> =? ( 0.5 adv ) >dn< =? ( 0 adv )
	
	drop
	vxp 'xp +!
	vyp 'yp +!
	vap 'ap +!
	;

:main
	"WORD SS" 1024 600 SDLinit
	pcfont

	12 26 "media/stackspr/veh_mini1.png" loadss 'spcar !
	14 37 "media/stackspr/van.png" loadss 'spvan !
	64 64 "media/stackspr/obj_house1.png" loadss 'sphouse !
	
	resetcam
	
	'game SDLshow 
	SDLquit ;

: main ;