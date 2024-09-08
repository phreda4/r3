| sprites atlas generator
| sprite stack draw
| sprite stcj scene
| PHREDA 2024

^r3/lib/gui.r3
^r3/win/sdl2gfx.r3
^r3/util/pcfont.r3
^r3/util/sort.r3

|------ FLOOR
#ym #xm
#dx #dy

|-------------- MEMM
#imglist
#imglist>
#imgcnt
#imgsort

:+img | w h "file" -- 
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	a[ 
	imglist> >a	a!+ 		| texture
	over over 16 << or 			|layersize
	dy 48 << or dx 32 << or a!+ |imagesize
	here a!+		| mem 
	0 a!+			| future info, image cnt
	a> 'imglist> ! 
	|w h
	here >a
	8 a+	| cant
	0 ( dy <? 
		0 ( dx <? | w h y x
			2dup 16 << or da!+ | x(16)/y(16)
			pick3 + ) drop 
		over + ) drop
	2drop 
	here a> over - 2 >> 2 - | image cnt
	swap !
	a> 'here ! 
	]a
	;

:countlistss | list -- list cnt
	0 over ( c@+ 1? drop c@+ drop 
		>>0 swap 1+ swap ) 2drop ;

|-----------------------------------
::loadlistss | list --
	a[ >a
	( ca@+ 1? ca@+
		a> "media/stackspr/%s.png" sprint +img
		a> >>0 >a ) drop ]a ;
		
:.tex ;				| texture
:.layer	1 ncell+ ;	| layer size/img size
:.mem	2 ncell+ ;	| mem descripcion
:.info	3 ncell+ ;	| new position
	
:]img	5 << imglist + ;
:]simg	3 << imgsort + @ $ffff and ]img ;
	
:2xy dup $ffff and swap 16 >> $ffff and ;
:2ixy dup 32 >> $ffff and swap 48 >> $ffff and ;
	
#x #y
#wmin #hmin #wmax #hmax
#newtex

| simple..not calc
:packbox
	0 'x ! 0 'y !
	1 'wmin ! 1 'hmin ! | borde
	0 ( imgcnt <?
		wmin hmin 16 << or over ]simg .info ! | save the border
		dup ]simg .layer @ 2ixy  | dx dy
		over wmin + wmax max 'wmax !
		dup hmin + hmax max 'hmax !
		drop 
		1+ 'wmin +! | borde
		|2 'hmin +!
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


#fileatlas		
| cntspr
| spr1 spr2 .. sprn	
| altura|w|h
| altura{x1 y1 x2 y2}
|  
| altura|w|h
| altura{x1 y1 x2 y2}
|
#wsp #hsp
#xsp #ysp 

:x2fp | x -- xn
	16 << wmax / f2fp ;
	
:y2fp | y -- yn
	16 << hmax / f2fp ;
	
:genspr | n adr -- n adr ; a:dest
	over ]img .info @ dup 16 >> 'ysp ! $ffff and 'xsp !
	over ]img .mem @ dup 8 + >b @ 
	pick2 ]img .layer @ $ffffffff and 
	dup $ffff and 'wsp !
	dup 16 >> 'hsp !
	over 32 << or a!+ | alt|w|h
	0 ( over <?
		db@+  | x y 
		dup
		dup 16 >> xsp + x2fp da!+
		$ffff and ysp + y2fp da!+
		dup 16 >> xsp + wsp + x2fp da!+
		$ffff and ysp + hsp + y2fp da!+
		1+ ) 2drop ;

:genfile
	here dup 'fileatlas !
	imgcnt swap !+
	dup imgcnt  ncell+ >a | inicio spr1
	0 ( imgcnt <? | adr nro
		a> rot !+ | save adress
		genspr 
		swap 1+ ) 2drop 
	a> 16 + 'here ! ;
		
	
|--------------------------------------	
::genatlas | list --
	countlistss dup 'imgcnt !
	|dup "((%d))" .println
	5 <<
	here 
	dup 'imglist ! 
	dup 'imglist> !
	+ 'here !
	
	loadlistss

	here 'imgsort !	
	imgsort >a
	0 ( imgcnt <?
		dup ]img .layer @ 
		$ffff000000000000 and neg over or  | neg=inversesort
		a!+
		1+ ) drop
	imgcnt imgsort shellsort1 | sort by height of image
	packbox
	genfile
	;

|------------- ISO
##isang 0.22
##isalt 0.28
##isxo ##isyo 

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

::2iso | x y z -- x y 
	xyz2iso 
	swap 12 >> isxo + 
	swap 12 >> isyo + ;

::isocam
	isang sincos 'isx1 ! isalt *. 'isy1 !
	isang 0.25 + sincos 'isx2 ! isalt *. 'isy2 !
	;
	
::resetcam
	sw 2/ 'isxo !
	sh 2/ 'isyo !
	isocam
	;
	
|-------------------------
#cntl 
#ind
#tx1 #tx2 #ty1 #ty2
#d01 #d23 
#z #dz
#ssp

:rotxyiso | x1 y1 -- xd yd
	over dx * over dy * -				| x y x1 y1 x'
	rot dy * rot dx * +					| x y x' y'
	
	0 xyz2iso 
	17 >> swap | scale !!
	17 >> swap
	;	

|----------- ** zoom

:fillvertiso | xm ym --
	over neg over neg rotxyiso 
	$ffff and 16 << swap $ffff and or 'd01 ! 
	2dup neg rotxyiso 
	$ffff and 16 << swap $ffff and or 
	32 << d01 or 'd01 !
	2dup rotxyiso 
	$ffff and 16 << swap $ffff and or 'd23 !
	swap neg swap rotxyiso 
	$ffff and 16 << swap $ffff and or 
	32 << d23 or 'd23 !
	;
	
|#indexm [ 0 1 2 2 3 0 ]
:makeindex
	0 ( cntl <?
		dup 2 << 
		dup da!+ dup 1 + da!+ dup 2 + da!+
		dup 2 + da!+ dup 3 + da!+ da!+
		1+ ) drop ;
	
:settex | --
	z 16 >> 4 << ssp + 
	d@+ 'tx1 ! d@+ 'ty1 ! d@+ 'tx2 ! d@ 'ty2 ! 
	dz 'z +!
	;


| posx posy color texx texy 
:makelayer | x y lev -- x y lev
	d01 
	dup 48 << 48 >> pick4 + i2fp da!+
	dup 32 << 48 >> pick3 + i2fp da!+
	$ffffffff da!+ tx1 da!+ ty1 da!+
	dup 16 << 48 >> pick4 + i2fp da!+
	48 >> pick2 + i2fp da!+
	$ffffffff da!+ tx2 da!+ ty1 da!+
	d23
	dup 48 << 48 >> pick4 + i2fp da!+
	dup 32 << 48 >> pick3 + i2fp da!+
	$ffffffff da!+ tx2 da!+ ty2 da!+
	dup 16 << 48 >> pick4 + i2fp da!+
	48 >> pick2 + i2fp da!+
	$ffffffff da!+ tx1 da!+ ty2 da!+
	1 'cntl +!
	;
	
|  cntspr
| spr1 spr2 .. sprn	
| altura|w|h
| altura{x1 y1 x2 y2}
|  
| altura|w|h
| altura{x1 y1 x2 y2}	
|-- draw one sprite alone
::isospr | x y a z n --
	rot sincos 'dx ! 'dy !		| x y z n
	1+ 3 << fileatlas + @	|
	dup 8 + 'ssp ! 				| x y z 'ss
	@ 
	dup 32 >> swap
	dup $ffff and swap
	16 >> $ffff and		| x y z lev w h
	swap pick3 16 *>> 		| x y z lev h xm
	swap pick3 16 *>> 		| x y z lev xm ym
	fillvertiso 		| x y z lev
	1.0 pick2 /. neg 'dz !
	dup 16 << 'z !
	*. 					| x y reallev.
	here >a 0 'cntl ! 

	( 1? 1-
		settex
		makelayer
		swap 1- swap 
		) 3drop
		
	a> 'ind !
	makeindex
	SDLrenderer newtex 	| texture
	here cntl 2 << 		| 4* vertex list
	ind cntl 6* 		| 6* index list
	SDL_RenderGeometry 
	;

|------------------ DRAW ALL
#scene 
#scene>
#minz
#maxz
#vertex
#index

::isoscene
	here 'scene !
	0 'minz ! 
	0 'maxz !
	;

::+isospr
	| x y a z n --
	rot sincos 'dx ! 'dy !		| x y z n
	1+ 3 << fileatlas + @	|
	dup 8 + 'ssp ! 				| x y z 'ss
	@ 
	dup 32 >> swap
	dup $ffff and swap
	16 >> $ffff and		| x y z lev w h
	swap pick3 16 *>> 		| x y z lev h xm
	swap pick3 16 *>> 		| x y z lev xm ym
	fillvertiso 		| x y z lev
	1.0 pick2 /. neg 'dz !
	dup 16 << 'z !
	*. 					| x y reallev.
	
	|... ad to scenelist
	;
	
| Z/DZ
| ADRSPRI
| Z0|X|Y|ELEV
| BX1|BY1|BX2|BY2
| BX3|BY3|BX4|BY4
|
:rendlayer
	dup @ 	| DZ|Z
	dup $ffffffff and dup pick2 32 >> + | a v z nz 
	rot $ffffffff nand or				| a z nv
	rot !+ 	| z adr
	@+		| z adr sprite
	rot 16 >> 4 << + | adr 
	d@+ 'tx1 ! d@+ 'ty1 ! d@+ 'tx2 ! d@ 'ty2 !  
	@+ | z0 x y elev
	swap @+ 'd01 ! @+ 'd23 !
	;

|
|------------------------
:fillsprite | adr -- adr+
	@+
	| x y z lev z dz
	z 16 >> 4 << ssp + 
	d@+ 'tx1 ! 
	d@+ 'ty1 ! 
	d@+ 'tx2 ! 
	d@ 'ty2 ! 
	dz 'z +!
	
	d01
	dup 48 << 48 >> pick4 + i2fp da!+
	dup 32 << 48 >> pick3 + i2fp da!+
	$ffffffff da!+ tx1 da!+ ty1 da!+
	dup 16 << 48 >> pick4 + i2fp da!+
	48 >> pick2 + i2fp da!+
	$ffffffff da!+ tx2 da!+ ty1 da!+
	d23
	dup 48 << 48 >> pick4 + i2fp da!+
	dup 32 << 48 >> pick3 + i2fp da!+
	$ffffffff da!+ tx2 da!+ ty2 da!+
	dup 16 << 48 >> pick4 + i2fp da!+
	48 >> pick2 + i2fp da!+
	$ffffffff da!+ tx1 da!+ ty2 da!+
	1 'cntl +!
	;

:drawlayer
	scene ( scene> <?
		fillsprite
		) drop ;
	
::isodraw
	here >a 
					|.... vertex
	a> 'vertex ! 
	0 'cntl ! 
	minz ( maxz <?
		drawlayer
		1+ ) drop
					|.... index
	a> 'index ! 
	makeindex
					|.... drawcall
	SDLrenderer 
	newtex 	| texture
	vertex cntl 2 << 		| 4* vertex list
	index cntl 6* 		| 6* index list
	SDL_RenderGeometry 
	;
