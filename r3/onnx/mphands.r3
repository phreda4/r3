| Mediapipe hand
| PHREDA 2025
^r3/lib/sdl2gfx.r3	
^r3/lib/onnx.r3
^r3/lib/memavx.r3

#pix
#pixw #pixh #imgz 1.0

#rectd [ 0 0 0 0 ]
##texmem0
##texmem1

#input_tensor
#input_data

#sclx #scly

:sizeframe | texture --
	0 0 'pixw 'pixh SDL_QueryTexture
	192 pixw 16 <</ 
	192 pixh 16 <</ 
	min	'imgz ! 
	pixw pixh 2dup max dup
	rot 16 <</ 'scly !
	swap 16 <</ 'sclx !
	
|--- centrado	
	pixw imgz *. 1+ 192 over - 2/ 'rectd d! 'rectd 8 + d!
	pixh imgz *. 1+	192 over - 2/ 'rectd 4 + d! 'rectd 12 + d!
	
	SDLrenderer $16362004 2 192 192 SDL_CreateTexture 'texmem0 !
	SDLrenderer $16362004 2 224 224 SDL_CreateTexture 'texmem1 !
	;
	
:letterx 0.5 - sclx *. 0.5 + ;
:lettery 0.5 - scly *. 0.5 + ;
		
:getframe0  | texture --
	SDLrenderer texmem0 SDL_SetRenderTarget
	SDLrenderer swap 0 'rectd SDL_RenderCopy
	SDLrenderer 0 $16362004 pix 192 2 << SDL_RenderReadPixels
	SDLrenderer 0 SDL_SetRenderTarget
	| convert rgb...>>RGB..
	pix input_data 192 192 * memcpy_rgb3f ;

|--------------------------------
| $yyy xxx YYYYY XXXXX
|      52  40    20
| $..... 
#dx #dy
#p0 #p1 #val

#vertex * 160	| 8 vertex (8 * 8)
#vertex> 'vertex
#verfix * 160	| 8 vertex (5 * 4 * 8)
#verfix> 'verfix
#vindex [ 0 1 2 0 2 3 0 3 4 0 4 5 0 5 6 0 6 7 ]

:getxy dup 44 << 44 >> swap 24 << 44 >> ; | v -- x y
:setxy $fffff and 20 << swap $fffff and or ; | x y -- v

:getsx 40 >> $fff and ; | v -- sx
:getsy 52 >> $fff and ; | v -- sy

:cutshadow | value -- value+
	p0 getsx p1 getsx | x1 x2
	over - dy dx */ + $fff and 40 << 
	p0 getsy p1 getsy 
	over - dy dx */ + $fff and 52 << or 
	or ;
	
|r.x=val; r.y=y1+(y2-y1)*(val-x1)/(x2-x1);
:clipx | -- pr
	p1 getxy p0 getxy	| x2 y2 x1 y1
	rot over -			| x2 x1 y1 yy
	2swap				| y1 yy x2 x1
	val over -			| y1 yy x2 x1 xx
	-rot - 				| y1 yy xx x/
	2dup 'dx ! 'dy !
	*/ + val swap setxy 
	|... cut the shadow too
	cutshadow ;
	
|r.y=val; r.x=x1+(x2-x1)*(val-y1)/(y2-y1);	
:clipy | -- pr
	p0 getxy p1 getxy	| x1 y1 x2 y2
	swap pick3 -		| x1 y1 y2 xx
	val pick3 -			| x1 y1 y2 xx yy
	2swap swap - 
	2dup 'dx ! 'dy !
	*/ + val setxy 
	|... cut the shadow too
	cutshadow ;
	
#xclip 'clipx 	
:clipxy xclip ex ;

|... compare 	
:cmpx 44 << 44 >> val - ;
:inxi cmpx not 63 >> 1 and ; 
:inxa cmpx 63 >> 1 and ; 

:cmpy 24 << 44 >> val - ;
:inyi cmpy not 63 >> 1 and ;
:inya cmpy 63 >> 1 and ;

#check 'inxi
:ckin check ex ;
		
:clipab | v1 --
	%11 =? ( drop p1 b!+ ; ) 
	%01 =? ( drop clipxy b!+ p1 b!+ ; )
	%10 =? ( drop clipxy b!+ ; ) 
	drop ;
		
:clipp | val check --
	'check ! 'val !
	'verfix >b 
	vertex> 8 - @ 'p0 !
	'vertex ( vertex> <?
		@+ dup 'p1 ! 
		p0 ckin 2* p1 ckin or | v01
		clipab
		'p0 !
		) drop 
	b> 'verfix> !
	'vertex 'verfix verfix> over - | copy fix to ver
	'vertex over + 'vertex> !
	3 >> move |dsc
	;

:rotv | x y x1 y1 -- x y v
	over dx * over dy * - 17 >> pick4 + 
	letterx	$fffff and >r | x
	swap dy * swap dx * + 17 >> over +  
	lettery $fffff and 20 << | y
	r> or ;	

:genbox | box --
	|... build
	dup 48 >>> sincos 'dx ! 'dy !
	dup 32 >> $ffff and 2.9 *. 'val ! 
	dup $ffff and swap 
	16 >> $ffff and | x y 
	ab[
	'vertex >a 
	val neg dup rotv a!+
	val dup neg rotv $e00000000000 or a!+ |e0 = 224
	val dup		rotv $e00e00000000000 or a!+
	val dup neg swap rotv $e00000000000000 or a!+
	a> 'vertex> !
	2drop
	|... cliping
	'clipx 'xclip ! 0 'inxi clipp $ffff 'inxa clipp
	'clipy 'xclip ! 0 'inyi clipp $ffff 'inya clipp
	|... make de vertex for rendergeometry
	'verfix >a
	'vertex ( vertex> <? @+ 
		dup getsx i2fp da!+ 
		dup getsy i2fp da!+ 
		-1 da!+ 
		dup $fffff and f2fp da!+ 
		20 >> $fffff and f2fp da!+ 
		) drop 
	]ba ;

:getframe1 | tex box --
	genbox
	|showvert
	|----- | imagen rotada
	SDLrenderer texmem1 SDL_SetRenderTarget
	$727272 sdlcls
	SDLrenderer swap |drop texmem0 | texture
	'verfix 
	vertex> 'vertex - 3 >> | cntvertex
	'vindex 
	over 2 - 3 * | cntindex
	SDL_RenderGeometry
	
	SDLrenderer 0 $16362004 pix 224 2 << SDL_RenderReadPixels
	SDLrenderer 0 SDL_SetRenderTarget
	| conver to R G B
	pix input_data 224 224 * memcpy_rgb3f | rgb RRR...GGG...BBB
	;
	
|---------------------------------------------------
#env

#session_options

#sessionp
#sessionl

#memory_info

#output_tensor0

#output_tensor1
#output_tensor2
#output_tensor3

|------------------
|name: input
|tensor: float32[1,3,192,192]
|name: pdscore_boxx_boxy_boxsize_kp0x_kp0y_kp2x_kp2y
|tensor: float32[N,8]

|#handfile_onnx "onnx/palm_detection_full_inf_post_192x192.onnx"
#hand_shape 1 3 192 192
#name0 "input"
#hand_input_names 'name0
#name0 "pdscore_boxx_boxy_boxsize_kp0x_kp0y_kp2x_kp2y"
#hand_output_names 'name0

#boxout
#boxcnt 0 0 0

|#markfile_onnx "onnx/hand_landmark_sparse_Nx3x224x224.onnx"
#mark_shape 1 3 224 224
#name0 "input"			| image		float32[1,3,256,256]  | <<<<<
#mark_input_names 'name0
#name0 "xyz_x21" 					| float32[N,63]
#name1 "hand_score"					| float32[N,1]
#name2 "lefthand_0_or_righthand_1"	| float32[N,1]
#mark_output_names 'name0 'name1 'name2

#hxyz
#hsco
#hlor

:ortcheck
	dup OrtGetErrorMessage .println
	OrtReleaseStatus drop ;
	
|---------------------------------			
#wchar * 256

:towchar | str -- str
	'wchar swap ( c@+ 1? rot w!+ swap ) nip swap w! 'wchar ;
		
:onnxend
    output_tensor0 OrtReleaseValue drop
	output_tensor1 OrtReleaseValue drop
	output_tensor2 OrtReleaseValue drop
	
	memory_info OrtReleaseMemoryInfo drop
	sessionl OrtReleaseSession drop
	sessionp OrtReleaseSession drop
	session_options OrtReleaseSessionOptions drop
    env OrtReleaseEnv drop ;

#coo_info

:onnxrun0
| entrada
    memory_info 
	input_data
	192 192 * 3 * 2 << 
	'hand_shape 4 ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT 
	'input_tensor
	OrtCreateTensorWithDataAsOrtValue 1? ( ortcheck ; ) drop
| inferencia0
	0 'output_tensor0 !
    sessionp 0 
	'hand_input_names 'input_tensor 1 
	'hand_output_names 1 'output_tensor0
	OrtRun 1? ( ortcheck ; ) drop
| Obtener datos de salida
	output_tensor0 'coo_info OrtGetTensorTypeAndShape 1? ( ortcheck ; ) drop
	coo_info 'boxcnt 1 OrtGetDimensions 1? ( ortcheck ; ) drop 
	output_tensor0 'boxout OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	;

:onnxrun1
| entrada
    memory_info 
	input_data
	224 224 * 3 * 2 << 
	'mark_shape 4 ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT 
	'input_tensor
	OrtCreateTensorWithDataAsOrtValue 1? ( ortcheck ; ) drop
| inferencia1
|	0 'output_tensor1 ! 0 'output_tensor3 !
    sessionl 0 
	'mark_input_names 'input_tensor 1 
	'mark_output_names 3 'output_tensor1
	OrtRun 1? ( ortcheck ; ) drop
| Obtener datos de salida
	output_tensor1 'hxyz OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	output_tensor3 'hlor OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	;

|--------------------- get boxes
| rota-scale-y-x (16 bits)

#boxes * 128 | 16 hands
#boxes> 'boxes
#hands * 128
#hands> 'hands 
#points * 2048 |

#50fp

:iou | v1 v2 -- val
	- $ffffffffffff and 
	dup 15 >> $000100010001 and $7fff * 	| abs de 16^3
	swap over xor swap -
	dup 32 >> or dup 16 >> or $ffff and ; | big max of 16 16 16 

:check2 | adr value adr2 val2 -- 
	pick2 over
	iou 63 >? ( drop ; ) drop | similares
	0 pick2 8 - ! ; 
	
:check1 | adr value adr2 --
	boxes> >=? ( drop ; )  |...
	@+ 1? ( check2 ) drop 
	check1 ;

:nsm
	'boxes ( boxes> 8 - <?
		@+ 1? ( over check1 ) drop
		) drop ;

#box_x #box_y #box_size
#k0_x #k0_y #k2_x #k2_y
#rota
	
:addbox
	da@+ 50fp <? ( drop 7 2 << a+ ; ) drop
	da@+ fp2f 'box_x !
	da@+ fp2f 'box_y !
	da@+ fp2f 'box_size !
	da@+ fp2f 'k0_x ! da@+ fp2f 'k0_y !
	da@+ fp2f 'k2_x ! da@+ fp2f 'k2_y !
	
	k2_x k0_x - k0_y k2_y - atan2 'rota !
	box_x rota sin box_size *. 2/ + | centerx
|	dup "%f " .print
$ffff and 
	box_y rota cos box_size *. 2/ - | centery
|	dup "%f " .print
$ffff and 16 << or 
	box_size	| size
|	dup "%f " .println
$ffff and 32 << or 
	rota		| rotation
48 << or 
	boxes> !+ 'boxes> ! ;
	
:getboxes
	'boxes 'boxes> !
	boxout >a
	0 ( boxcnt <? addbox 1+ ) drop 
	nsm 
	
	|boxes> 'boxes - 3 >> 0? ( drop ; ) "%d boxes" .println
	;

:gethand | box tex-- box
	over getframe1 | tex box --
	onnxrun1
	hands> 'hands - 21 * 'points + >b
	hxyz >a
	21 ( 1? 1-
		da@+ fp2f 8 >> $ffff and
		da@+ fp2f 8 >> $ffff and 16 << or
		da@+ fp2f $ffff and 32 << or
		b!+
		) drop 
	dup hands> !+ 'hands> !
	;
	
|-------- drawhands
#hand ( 
    0 1 1 2 2 3 3 4 | Thumb
    1 5 5 6 6 7 7 8 | Index
    5 9 9 10 10 11 11 12 | Middle
    9 13 13 14 14 15 15 16 | Ring
    13 17 17 18 18 19 19 20 | Pinky
    0 17 | Wrist to pinky base
	)

:boxdata | box --
	dup 48 >>> neg sincos 'dx ! 'dy !
	dup 32 >> $ffff and 2.9 *. 'box_size ! 
	dup $ffff and 'box_x !
	16 >> $ffff and 'box_y !
	;

:rotb | x y -- x1 y1
	over dx * over dy * - 16 >> -rot | x1 x y x1
	swap dy * swap dx * + 16 >> ;

:getxy | n -- x y
	3 << b> + @
	dup $ffff and 0.5 - 
	swap 16 >> $ffff and 0.5 - 
	swap rotb
	200 *. box_x 200 *. + 300 + swap
	200 *. box_y 200 *. + 200 +
	;
	
:drawline | n n --
	getxy rot getxy sdlline ;

:drawll
	'hand
	21 ( 1? 1- swap
		c@+ swap c@+ rot
		drawline
		swap ) 2drop ;
	
:dhand | adr+ box --adr+
	boxdata
	dup 'hands - 8 - 21 * 'points + >b
	drawll ;

#colores $ff0000 $00ff00 $0000ff $ff00ff $ffff00 $ffff
	
::MPdrawhands
	'colores
	'hands ( hands> <? 
		swap @+ sdlcolor swap
		@+ dhand ) 2drop ;

::startMPHands | texture --
	sizeframe | texture
	
	2 "hand" 'env OrtCreateEnv 1? ( ortcheck ; ) drop
    'session_options OrtCreateSessionOptions 1? ( ortcheck ; ) drop
    session_options 99 OrtSetSessionGraphOptimizationLevel 1? ( ortcheck ; ) drop
	
	env "onnx/palm_detection_full_inf_post_192x192.onnx" towchar 
	session_options 'sessionp OrtCreateSession 1? ( ortcheck ; ) drop
	env "onnx/hand_landmark_sparse_Nx3x224x224.onnx" towchar 
	session_options 'sessionl OrtCreateSession 1? ( ortcheck ; ) drop
	
	OrtArenaAllocator OrtMemTypeDefault 'memory_info OrtCreateCpuMemoryInfo 1? ( ortcheck ; ) drop	
	
	0.5 f2fp '50fp !
|--- onnx		
	here 
	align32
	dup 'pix ! 224 224 * 2 << + 
	dup 'input_data ! 224 224 * 3 * 2 << +
	'here !	
	;

::freeMPHands	
	onnxend 
	texmem1 SDL_DestroyTexture
	texmem0 SDL_DestroyTexture
	;

::MPHands | texture --
	dup getframe0
	onnxrun0
	getboxes
	'hands 'hands> ! | clear hands
	'boxes ( boxes> <?
		@+ 1? ( pick2 gethand ) drop
		) 
	2drop ;
