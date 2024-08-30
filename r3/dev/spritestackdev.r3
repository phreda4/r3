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

|------- FLOOR
::xyz2iso | x y z -- x y
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

|------- SSPRITE
#ym #xm
#dx #dy

#vert [
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
]

#index [ 0 1 2 2 3 0 ]

:fillfull
	'vert >a 
	$ffffffff 0 $3f800000 |1.0 f2fp 
	8 a+ pick2 da!+ over da!+ over da!+
	8 a+ pick2 da!+ dup da!+ over da!+
	8 a+ pick2 da!+ dup da!+ dup da!+
	8 a+ pick2 da!+ over da!+ dup da!
	3drop ;

:rotxyiso! | x y x1 y1 -- x y
	over dx * over dy * - | x y x1 y1 x'
	rot dy * rot dx * +	| x y x' y'
	over isx *. over isx *. +   | x y x' y' x''
	17 >> pick4 + i2fp da!+
	swap isy neg *. swap isy *. +   | x y 
	17 >> over + i2fp da!+ 
	;	

:fillvertiso | x y ang --
	sincos 'dx ! 'dy !
	'vert >a
	xm neg ym neg rotxyiso! 12 a+
	xm ym neg rotxyiso! 12 a+
	xm ym rotxyiso! 12 a+
	xm neg ym rotxyiso!
	2drop ;

:fillvertisoy | dy --
	'vert 4 + >a | y
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+
	drop ;


:settile | n adr -- adr
	swap 3 << 16 + over +
	@ dup 1 << $1fffe and f2fp | x1
	swap dup 15 >> $1fffe and f2fp 
	swap dup 31 >> $1fffe and f2fp 
	swap 47 >> $1fffe and f2fp 
	'vert >a
	12 a+ pick3 da!+ pick2 da!+
	12 a+ over da!+ pick2 da!+
	12 a+ over da!+ dup da!+
	12 a+ pick3 da!+ dup da!+
	4drop ;
	
::sspriteiso | x y ang zoom n ssprite --
	rot over sspritewh pick2 16 *>> 'ym ! 16 *>> 'xm !
	settile >r fillvertiso
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry ;

::sspriteniso | dy n ssprite --
	settile >r fillvertisoy
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry ;
	
|---------- v1
:isospr | x y a z lev 'ss --
	pick2 neg pick2 pick2 
	>r >r >r
	sspriteiso | a lev 'ss
	r> r> r>
	swap ( 1-   | a 'ss lev 
		pick2 over pick3 sspriteniso | dy n ssprite --
		1? ) 3drop ;

|----------- v2
#d1 0 
#d2 0
#d3
#d4

:gx+ 48 << 48 >> + ;
:gy+ 32 << 48 >> + ;

:drawbase | x y -
	over d1 gx+ over d1 gy+ pick3 d2 gx+ pick3 d2 gy+ sdlline
	over d2 gx+ over d2 gy+ pick3 d3 gx+ pick3 d3 gy+ sdlline
	over d4 gx+ over d4 gy+ pick3 d3 gx+ pick3 d3 gy+ sdlline
	over d1 gx+ over d1 gy+ pick3 d4 gx+ pick3 d4 gy+ sdlline
	2drop ;
	
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

#cntv
#cnti
#ind
#tx1 #tx2
#ty1 #ty2

:gyx dup 32 << 48 >> swap 48 << 48 >> ; | y x
	
| posx posy color texx texy 

#ssp

:settex | lev -- lev
	dup 3 << 16 + ssp + @
	dup 1 << $1fffe and f2fp 'tx1 !
	dup 15 >> $1fffe and f2fp 'ty1 !
	dup 31 >> $1fffe and f2fp 'tx2 !
	47 >> $1fffe and f2fp 'ty2 !
	;

:renderlayer
	here >a
	d1 gyx pick3 + i2fp da!+ over + i2fp da!+ 
	$ffffffff da!+ tx1 da!+ ty1 da!+
	d2 gyx pick3 + i2fp da!+ over + i2fp da!+ 
	$ffffffff da!+ tx2 da!+ ty1 da!+
	d3 gyx pick3 + i2fp da!+ over + i2fp da!+ 
	$ffffffff da!+ tx2 da!+ ty2 da!+
	d4 gyx pick3 + i2fp da!+ over + i2fp da!+ 
	$ffffffff da!+ tx1 da!+ ty2 da!+
	4 'cntv ! | cntobj 2 << | *4
	a> 'ind !
	0 da!+ 1 da!+ 2 da!+ 2 da!+ 3 da!+ 0 da!+
	6 'cnti ! | cntobj 1 << dup 1 << + | *6
	SDLrenderer ssp @ here cntv ind cnti SDL_RenderGeometry 
	;
		
:isospr2 | x y a z lev 'ss --
	dup 'ssp ! sspritewh	| x y a z lev w h
	pick3 16 *>> 'ym !		| x y a z lev w 
	pick2 16 *>> 'xm !		| x y a z lev
	rot fillvertiso 		| x y z lev
	swap 0.9 + 16 >> swap			| x y zi lev
	( 1? 1- settex 
		2swap				| zi lev x y
		pick3 ( 1? 1- >r renderlayer 1- r> ) drop
		2swap ) 4drop ;

|-------------- v3 
::loadss | w h "file" -- ssprite
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	here >a a!+ 		| texture
	2dup 16 << or a!+	| wi hi
	1.0 rot dx */ 'dx ! | $ffff = 0.99..
	1.0 swap dy */ 'dy ! 
	0 ( 1.0 dy - <=?
		0 ( 1.0 dx - <=?
			dup f2fp da!+ 
			over f2fp da!+ 
			dup dx + f2fp da!+ 
			over dy + f2fp da!+
			dx + ) drop
		dy + ) drop
	 here 
	 a> over - 4 >> 1- 32 << over 8 + @ or over 8 + ! | altura
	 a> 'here ! ;


:settex | lev -- lev
	dup 4 << 16 + ssp + 
	d@+ 'tx1 ! d@+ 'ty1 ! d@+ 'tx2 ! d@ 'ty2 ! ;

::sswh | adr -- h w
	8 + @ dup $ffff and swap 16 >> $ffff and ;
	
:isospr3 | x y a z lev 'ss --
	dup 'ssp ! sswh	| x y a z lev w h
	pick3 16 *>> 'ym !		| x y a z lev w 
	pick2 16 *>> 'xm !		| x y a z lev
	rot fillvertiso 		| x y z lev
	swap 16 >> 0? ( 1+ ) swap			| x y zi lev
	( 1? 1- settex 
		2swap				| zi lev x y
		pick3 ( 1? 1- >r renderlayer 1- r> ) drop
		2swap ) 4drop ;

|--------------- v4

#cntl 
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
		dup 0 + da!+ dup 1 + da!+ dup 2 + da!+
		dup 2 + da!+ dup 3 + da!+ 0 + da!+
		1+ ) drop ;

:isospr4 | x y a z 'ss --
	dup 'ssp ! 
	8 + @ 
	dup 32 >> swap 
	dup $ffff and swap
	16 >> $ffff and 
	| lev w h
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

|--------------- example
#spcar #spcara
#spk #spka
#spk1 #spka1

#spcasa #spcasa1

#zoom 4.0
#a	
	
:game
	$3a3a3a SDLcls
	$ffffff pccolor
	0 0 pcat "Sprite stack" pcprint pccr
	isy isx "iso %f %f : <ad ws>" pcprint pccr
	zoom "%f" pcprint
	
	floor	

	| v2
|	200 300 a 10.0 spcara spcar isospr2 | x y a z lev 'ss --
|	500 300 a 4.0 spka spk isospr2

	| v3
	|200 300 a 10.0 spcara1 spcar1 isospr3 | x y a z lev 'ss --
	200 200 a zoom spka1 spk1 isospr3
	700 200 a 5.0 spcasa1 spcasa isospr3


	| v4
	200 550 a neg zoom spk1 isospr4
	700 550 a neg 5.0 spcasa isospr4
	
	0.002 'a +! 
	
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
	here 
	16 16 "media/stackspr/car.png" ssload 'spcar !
	here swap - 3 >> 2 - 'spcara !
	
	here
	14 37 "media/stackspr/van.png" ssload 'spk !
	here swap - 3 >> 2 - 'spka !

	here
	14 37 "media/stackspr/van.png" loadss 'spk1 !
	here swap - 4 >> 1- 'spka1 !

	here
	64 64 "media/stackspr/obj_house3.png" loadss 'spcasa !
	here swap - 4 >> 1- 'spcasa1 !
	
	'game SDLshow 
	SDLquit ;

: main ;