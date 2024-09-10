| sprites atlas generator
| sprite stack draw
| sprite stack scene
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
	imglist> >a a!+ 		| texture
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
#tx1 #tx2 #ty1 #ty2
#d01 #d23 
#z #dz
#ssp

#list
#list>
#scene 
#scene>
#vertex
#index

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
		dup da!+ dup 1 + da!+ dup 2 + dup 
		da!+ da!+ dup 3 + da!+ da!+
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
		
	a> 'index !
	makeindex
	SDLrenderer newtex 	| texture
	here cntl 2 << 		| 4* vertex list
	index cntl 6* 		| 6* index list
	SDL_RenderGeometry 
	;

|------------------ DRAW ALL

|................
| call start scene
::isoscene | maxobj --
	mark
	here 
	dup 'list ! dup 'list> ! 
	swap 3 << +
	dup 'scene ! 
	'scene> !
	;

::isopos | x y z -- xs ys
	list> list - 3 >> 
	over 32 << or 
	list> !+ 'list> !
	2iso ;
	
| 1.0 1.0 0.0 0.32 2.0 0 +isospr
|.............
| call to add spr
::+isospr | x y a z n --
	scene> >a 
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
	dup 52 << dz $3ffffff and 26 << or z or a!+
	ssp a!+
	d01
	dup 48 << 48 >> pick4 + $ffff and >b
	dup 32 << 48 >> pick3 + $ffff and 16 << b+
	dup 16 << 48 >> pick4 + $ffff and 32 << b+
	48 >> pick2 + $ffff and 48 << b+
	b> a!+
	d23
	dup 48 << 48 >> pick4 + $ffff and >b
	dup 32 << 48 >> pick3 + $ffff and 16 << b+
	dup 16 << 48 >> pick4 + $ffff and 32 << b+
	48 >> pick2 + $ffff and 48 << b+
	b> a!+
	a> 'scene> ! |... add to scenelist
	3drop
	;
	

| elev/Z/DZ	| fff | 3ffffff | 3ffffff ( 4096 / 1024.0 /1024.0) hasta 1024 texturas
| ADRSPRI
| BX1|BY1|BX2|BY2
| BX3|BY3|BX4|BY4
|
:rl	| adr lev/DZ/Z --
	dup $3ffffff and dup 
	pick2 12 << 38 >> +	| adr v v22v
	rot $3ffffff nand or $10000000000000 -
	rot !+ 				| update z and level
	@+ rot 16 >> 4 << + | texture
	d@+ 'tx1 ! d@+ 'ty1 ! d@+ 'tx2 ! d@ 'ty2 !  
	w@+ i2fp da!+ w@+ i2fp da!+ $ffffffff da!+ tx1 da!+ ty1 da!+
	w@+ i2fp da!+ w@+ i2fp da!+ $ffffffff da!+ tx2 da!+ ty1 da!+
	w@+ i2fp da!+ w@+ i2fp da!+ $ffffffff da!+ tx2 da!+ ty2 da!+
	w@+ i2fp da!+ w@+ i2fp da!+ $ffffffff da!+ tx1 da!+ ty2 da!+
	16 - 
	2 + -1 over w+! 
	4 + -1 over w+! 
	4 + -1 over w+! 
	4 + -1 over w+!
	drop
	1 'cntl +!	
	;

|
|------------------------
:reml | list+1 -- list+1
	list over 8 - 
	dup @ pick2 @ 
	rot ! swap !
	8 'list +!
	;
	
:drawobj | list+1 objesc  -- list+1
	dup @ dup 52 >>> | adr obj obj@ lev
	0? ( 3drop reml ; ) drop
	rl ;
	
:scenedraw
	( list list> <? 	| inilist
		( list> <?
			@+ 
			$ffff and 5 << scene + drawobj
			) drop
		) drop ;

|...... 
| call to end scene	
::isodraw
	|list list> over - 3 >> shellsort1
		
	scene> >a 
					|.... vertex
	a> 'vertex ! 
	0 'cntl ! 
	scenedraw
					|.... index
	a> 'index ! 
	makeindex
					|.... drawcall
	SDLrenderer 
	newtex 	| texture
	vertex cntl 2 << 		| 4* vertex list
	index cntl 6* 		| 6* index list
	SDL_RenderGeometry 
	
	empty
	;
