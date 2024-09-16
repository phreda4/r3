| sprites atlas generator
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
	0 a!+			| future info 
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
	here a> over - 2 >> 2 -
	|dup "cnt:%d" .println
	swap !
	a> 'here ! 
	]a
	;

:countlistss | list -- list cnt
	0 over ( c@+ 1? drop c@+ drop 
		>>0 swap 1+ swap ) 2drop ;
	
:loadlistss | list --
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

#xfill #yfill 
#wfill #hfill

:fillbox
	;
	
:addbox | n -- n
	wmin hmin 16 << or 
	over ]simg .info ! | save the border

	dup ]simg .layer @ 2ixy  | dx dy
	over wmin + wmax max 'wmax !
	dup hmin + hmax max 'hmax !
	| dx dy
	wmin 'xfill ! 
	hmin over + 1+ 'yfill !
	'wfill !
	hmax yfill - 'hfill !
	;
	
| simple..not calc
:packbox
	0 'x ! 0 'y !
	1 'wmin ! 1 'hmin ! | borde
	
	|0 ]simg .layer @ 2ixy nip nextpow2 'hmax !
	
	0 ( imgcnt <?
	
		wmin hmin 16 << or 
		over ]simg .info ! | save the border
		
		dup ]simg .layer @ 2ixy  | dx dy
		over wmin + wmax max 'wmax !
		dup hmin + hmax max 'hmax !
		
		| dx dy
		drop   |2 'hmin +!
		1+ 'wmin +! | borde
		
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
	|xsp ysp wsp hsp "%dx%d %d %d" .println
	over 32 << or a!+ | alt|w|h
	0 ( over <?
		db@+  | x y 
		dup
		dup 16 >> xsp + x2fp da!+
		$ffff and ysp + y2fp da!+
		dup 16 >> xsp + wsp + x2fp da!+
		$ffff and ysp + hsp + y2fp da!+
		1+ ) 2drop
	;
			
:genfile
	here dup 'fileatlas !
	imgcnt swap !+
	dup imgcnt  ncell+ >a | inicio spr1
	0 ( imgcnt <? | adr nro
	
		|dup "%d." .println
		
		a> rot !+ | save adress
		genspr 
		swap 1+ ) 2drop 
	a> 16 + 'here ! ;
		
|-----------------
:debugsp | adr --
	@+ dup " %h " .print
	32 >> | altura
	0 ( over <? rot
		@+ "%h:" .print @+ "%h " .print
|d@+ fp2f "(%f " .print d@+ fp2f "%f " .print d@+ fp2f "%f " .print d@+ fp2f "%f) " .print

|d@+ "(%d " .print d@+ "%d " .print d@+ "%d " .print d@+ "%d) " .print

		-rot 1+ ) 2drop
	drop
	.cr
	;
	
:debug2
	fileatlas
	@+ "cnt:%d" .println
	0 ( imgcnt <? swap
		2dup "%h: %d " .print
		@+ debugsp
		swap 1+ ) drop ;
	
|--------------------------------------	

:debug1
	|** debug
	0 ( imgcnt <?
		dup ]simg .layer @ dup 
		2xy "%d %d : " .print
		2ixy "%d %d : " .print
		dup ]simg .mem @ "<%h>" .print
		dup ]simg .mem @ @ " %d - " .print
		dup ]simg .info @ 2xy "%d %d" .println
		1+ ) drop
	|** debug
	;
	
:genatlas | list --
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
		dup ]img .layer @ $ffff000000000000 and neg over or  | neg=inversesort
		a!+
		1+ ) drop
	imgcnt imgsort shellsort1 | sort by height of image
	packbox
|debug1
	genfile
|debug2
	;

|------------- ISO
#isang 0.22
#isalt 0.28

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

:isocam
	isang sincos 'isx1 ! isalt *. 'isy1 !
	isang 0.25 + sincos 'isx2 ! isalt *. 'isy2 !
	;
	
:resetcam
	sw 2/ 'isxo !
	sh 2/ 'isyo !
	isocam
	;
	
|-------------------------
#cntl 
#ind
#tx1 #tx2 #ty1 #ty2
#d1 #d2 #d3 #d4
#z #dz
#ssp

:rotxyiso | x1 y1 -- xd yd
	over dx * over dy * -				| x y x1 y1 x'
	rot dy * rot dx * +					| x y x' y'
	
	0 xyz2iso 
	17 >> swap | scale !!
	17 >> swap
	;	

|----------- correct zoom
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
	z 16 >> 4 << ssp + 
	d@+ 'tx1 ! d@+ 'ty1 ! d@+ 'tx2 ! d@ 'ty2 ! 
	dz 'z +!
	;
	
| posx posy color texx texy 
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
	
|  cntspr
| spr1 spr2 .. sprn	
| altura|w|h
| altura{x1 y1 x2 y2}
|  
| altura|w|h
| altura{x1 y1 x2 y2}	
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
	
|-------------------------	
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
		$ffff and ]img .layer @
		2xy "%d %d" pcprint pccr
		1+ ) drop ;

:viewbox
	$ff00 sdlcolor
	0 ( imgcnt <?
		|dup 8 << sdlcolor
		dup ]img .info @ 
		dup $ffff and 1 >>
		swap 16 >> $ffff and 1 >>
		pick2 ]img .layer @
		dup $ffff and 1 >>
		swap 16 >> $ffff and 1 >>
|		pick3 pick3 pick3 pick3 "%d %d %d %d" pcprint pccr
		sdlrect
		1+ ) drop ;

#ang

:game
	$0 SDLcls
	$ffffff pccolor
	0 0 pcat "Atlas generator - " pcprint 
	imgcnt "%d images" pcprint pccr
	hmax wmax "%d %d image max" pcprint
	|viewbox
	10 128 512 512 newtex sdlimages
	
	0.001 'ang +!
	
	700 200 ang 6.0 
	msec 7 >> $7 and 10 +
	isospr
	
	700 500 ang neg  6.0
	msec 7 >> $3 and 18 +
	isospr
	
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
( 24 24 ) "T-Rex0" | 26
( 24 24 ) "T-Rex1" | 26
( 24 24 ) "T-Rex2" | 26
( 24 24 ) "T-Rex3" | 26
( 24 24 ) "T-Rex4" | 26
( 24 24 ) "T-Rex5" | 26
( 24 24 ) "T-Rex6" | 26
( 24 24 ) "T-Rex7" | 26
( 26 9 ) "deer0" | 27
( 26 9 ) "deer1" | 27
( 26 9 ) "deer2" | 27
( 26 9 ) "deer3" | 27
0

#list2
( 12 26 ) "veh_mini1" 
( 14 37 ) "van" 
( 36 36 ) "blue_tree"
( 16 16 ) "car"
( 32 32 ) "tank"
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
	resetcam
	
	'game SDLshow 
	SDLquit ;

: main ;