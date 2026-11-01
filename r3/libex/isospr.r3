| SDL2 sprite stack
| PHREDA 2024

^r3/lib/sdl2gfx.r3	

|------------- ISO
##isang 0.22
##isalt 0.28
##isxo 
##isyo 

#isx1 0.87
#isx2 0.87
#isx3 0

#isy1 0.5
#isy2 -0.5
#isy3 -1.0

#ssp
#dx #dy	
#d1 #d2 #d3 #d4
#tx1 #tx2 #ty1 #ty2
#cntl 
#ind
#z #dz

::xyz2iso | x y z -- x y
	pick2 isx1 *. pick2 isx2 *. + over isx3 *. +
	swap isy3 *. rot isy2 *. + rot isy1 *. + 
	;

::2iso | x y z -- x y 
	xyz2iso 
	swap 12 >> isxo + 
	swap 12 >> isyo + ;

::isocam | --
	isang sincos 'isx1 ! isalt *. 'isy1 !
	isang 0.25 + sincos 'isx2 ! isalt *. 'isy2 !
	;
	
::resetcam
	sw 2/ 'isxo !
	sh 2/ 'isyo !
	isocam
	;

| posx posy color texx texy 
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

|------- SSPRITE
:rotxyiso | x1 y1 -- xd yd
	over dx * over dy * -				| x y x1 y1 x'
	rot dy * rot dx * +					| x y x' y'
	
	0 xyz2iso 
	17 >> swap | scale !!
	17 >> swap
	;	

:fillvertiso | xm ym --
	over neg over neg rotxyiso 
	$ffff and 16 << swap $ffff and or 'd1 ! 
	2dup neg rotxyiso 
	$ffff and 16 << swap $ffff and or 'd2 !
	2dup rotxyiso 
	$ffff and 16 << swap $ffff and or 'd3 !
	swap neg swap rotxyiso 
	$ffff and 16 << swap $ffff and or 'd4 !
	;
	
:gyx dup 32 << 48 >> swap 48 << 48 >> ; | y x
	
|#indexm [ 0 1 2 2 3 0 ]
:makeindex
	0 ( cntl <?
		dup 2 << 
		dup da!+ dup 1 + da!+ dup 2 + da!+
		dup 2 + da!+ dup 3 + da!+ da!+
		1+ ) drop ;

:settex | --
	z 16 >> 4 << 16 + ssp + 
	d@+ 'tx1 ! d@+ 'ty1 ! d@+ 'tx2 ! d@ 'ty2 ! 
	dz 'z +!
	;
	
:makelayer | x y lev -- x y lev
	d1 gyx pick4 + i2fp da!+ pick2 + i2fp da!+ 
	$ffffffff da!+ tx1 da!+ ty1 da!+
	d2 gyx pick4 + i2fp da!+ pick2 + i2fp da!+ 
	$ffffffff da!+ tx2 da!+ ty1 da!+
	d3 gyx pick4 + i2fp da!+ pick2 + i2fp da!+ 
	$ffffffff da!+ tx2 da!+ ty2 da!+
	d4 gyx pick4 + i2fp da!+ pick2 + i2fp da!+ 
	$ffffffff da!+ tx1 da!+ ty2 da!+
	1 'cntl +!
	;
	
::isospr | x y a z 'ss --
	rot sincos 'dx ! 'dy !
	dup 'ssp ! 				| x y z 'ss
	8 + @ dup 32 >> swap
	dup $ffff and swap
	16 >> $ffff and		| x y z lev w h
	swap pick3 16 *>> 		| x y z lev h xm
	swap pick3 16 *>> 		| x y z lev xm ym
	fillvertiso 		| x y z lev
	1.0 pick2 /. neg 'dz !
	dup 1 - 16 << 'z !
	*. 					| x y reallev.
	here >a 0 'cntl ! 
	
	( 1? 1-
		settex
		makelayer
		swap 1- swap 
		) 3drop
		
	a> 'ind !
	makeindex
	SDLrenderer ssp @ 			| texture
	here cntl 2 << 				| 4* vertex list
	ind cntl 1 << dup 1 << + 	| 6* index list
	SDL_RenderGeometry 
	;
