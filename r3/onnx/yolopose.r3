| yolo11n-pose
| PHREDA 2025

^r3/lib/rand.r3
^r3/lib/math.r3
^r3/util/txfont.r3

^r3/lib/sdl2gfx.r3
^r3/lib/onnx.r3
^r3/lib/memavx.r3

#font

#pixw #pixh #imgz 
#rectd [ 0 0 0 0 ]
#texmem0
#pix

#50fp

:calcframe | texture -- 
	0 0 'pixw 'pixh SDL_QueryTexture
	640 pixw 16 <</ 
	640 pixh 16 <</ 
	min 'imgz ! 
|--- centrado	
	pixw imgz *. 1+ 640 over - 2/ 'rectd d! 'rectd 8 + d!
	pixh imgz *. 1+	640 over - 2/ 'rectd 4 + d! 'rectd 12 + d!
	
	SDLrenderer $16362004 2 640 640 SDL_CreateTexture 'texmem0 !
	;
	
:getframe  | texture --
	SDLrenderer texmem0 SDL_SetRenderTarget
	|$727272 sdlcls
	SDLrenderer swap 0 'rectd SDL_RenderCopy
	SDLrenderer 0 $16362004 pix 640 2 << SDL_RenderReadPixels
	SDLrenderer 0 SDL_SetRenderTarget
	;

#env 
#session_options
#session
#memory_info

|name: images
|tensor: float32[1,3,640,640]
#in	"images" 0
#input_names 'in 
#input_shape 1 3 640 640 
#input_tensor
#input_data

|name: output0
|tensor: float32[1,56,8400]
#on "output0" 0
#output_names 'on 
#output_tensor
#output_data

:ortcheck
	dup OrtGetErrorMessage .println
	OrtReleaseStatus drop ;
	
:onnxrun
	| convert
	pix input_data 640 640 * memcpy_rgb3f
| entrada
    memory_info 
	input_data
	640 640 * 3 * 2 << 
	'input_shape 4 ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT 
	'input_tensor
	OrtCreateTensorWithDataAsOrtValue 1? ( ortcheck ; ) drop	
| inferencia
	|0 'output_tensor !
    session 0 
	'input_names 'input_tensor 1 
	'output_names 1 'output_tensor
	OrtRun 1? ( ortcheck ; ) drop

| Obtener dimensiones de la salida
	output_tensor 'output_data 
	OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	;

|--------------------- get boxes
|--- [1,84,8400]
#boxes>
#boxes * $3fff 
#point>
#point * $ffff 
			
|-------------------------------------	
:iou | v1 v2 -- val
	- dup 11 >> $001001001001 and $7ff * 	| abs de 12-12-12-12 bits !! bittrick vvv
	swap over xor swap -
	dup 24 >> or dup 12 >> or $fff and ; | big max of 12-12-12-12

:check2 | adr value adr2 val2 -- 
	pick2 over
	iou 63 >? ( drop ; ) drop
	0 pick2 8 - ! | limpia
	;
	
:check1 | adr value adr2 --
	boxes> >=? ( drop ; )  |...
	@+ 1? ( check2 ) drop 
	check1 ;

:nsm
	'boxes ( boxes> 8 - <?
		@+ 1? ( over check1 ) drop
		) drop ;
		
|-------------------------------------			
| box:  .... hhhw wwyy yxxx
	
| otput_data
| x1 x2 .. x8400 |0
| y1 y2 .. y8400 | 1	
| w1			| 2
| h1			| 3
| conf1			| 4
| xp1...
| w55..
:addbox | n conf -- n conf ; a=conf(n+1)
	a> 8400 4 * 4 * 4 + - >b | xi
	db@ fp2i $fff and		| x
	8400 4 * b+
	db@ fp2i $fff and 12 << or	| y
	8400 4 * b+
	db@ fp2i $fff and 24 << or	| w
	8400 4 * b+ 
	db@ fp2i $fff and 36 << or 	| h
	pick2 48 << or  | n
	boxes> !+ 'boxes> ! ;

:addpoint | box -- box
	dup 48 >>> 8400 5 * + 2 << 
	output_data + >a
	17 ( 1? 1-
		da@ fp2i $fff and			|x
		8400 4 * a+
		da@ fp2i $fff and 12 << or	|y
		8400 4 * a+
		da@ fp2i 24 << or |w
		8400 4 * a+
		point> !+ 'point> !
		) drop ;
	
:getboxes
	'boxes 'boxes> !
	output_data 
	8400 4 * 4 * + >a | confiance line
	0 ( 8400 <? 
		da@+ 50fp >? ( addbox ) drop 
		1+ ) drop 
|	boxes> 'boxes - 3 >> "%d boxes" .println
	nsm		
	'point 'point> !
	'boxes >b	| quita los 0
	'boxes ( boxes> <?	
		@+ 1? ( dup b!+ addpoint ) drop
		) drop 
	b> 'boxes> !
|	boxes> 'boxes - 3 >> "%d boxes" .println	
|	point> 'point - 3 >> "%d points" .println
	;
	
|----------------------
:drawbox | n -- n
	dup 24 >> $fff and 	| x
	over 36 >> $fff and | y
	pick2 $fff and pick2 2/ -	| x1
	pick3 12 >> $fff and pick2 2/ -	| y1
	2swap sdlrect ;	

:showboxes
	$0 sdlcolor
	'boxes ( boxes> <? @+ drawbox drop ) drop ;
	
#skeleton ( 0 1 0 2 1 3 2 4 5 6 5 7 7 9 6 8 8 10 5 11 6 12 11 12 11 13 13 15 12 14 14 16 )
	
:getxy | v -- x y 
	dup $fff and 
	swap 12 >> $fff and ;
	
:drawline | adr c n n -- adr 
	3 << pick4 + @ 
	swap 3 << pick4 + @ 
	getxy rot getxy sdlline ;
	
:drawlines | point -- point
	'skeleton
	16 ( 1? 1- swap
		c@+ swap c@+ rot drawline
		swap ) 2drop ;
		
::YoloPoseDraw
	$ffff sdlcolor
	'point ( point> <?
		drawlines		
		17 3 << +
		) drop ;
		
	
|---------------------------------			
#wchar * 256

:towchar | str -- str
	'wchar swap ( c@+ 1? rot w!+ swap ) nip swap w! 'wchar ;
	
::startYoloPose | texture -- texture
	calcframe

	0.5 f2fp '50fp !
|--- MEMORY		
	here 
	align32
	dup 'pix ! 640 640 * 2 << + 
	dup 'input_data ! 640 640 * 3 * 2 << +
	'here !
	
	2 "yolo11n-pose" 'env OrtCreateEnv 1? ( ortcheck ; ) drop
    'session_options OrtCreateSessionOptions 1? ( ortcheck ; ) drop
    session_options 99 OrtSetSessionGraphOptimizationLevel 1? ( ortcheck ; ) drop
	env 
	"onnx/yolo11n-pose.onnx" towchar 
	session_options 'session OrtCreateSession 1? ( ortcheck ; ) drop
	
	OrtArenaAllocator OrtMemTypeDefault 'memory_info OrtCreateCpuMemoryInfo 
	1? ( ortcheck ; ) drop
	;

::YoloPose | texture --
	getframe
	onnxrun
	getboxes
	;

::freeYoloPose	
    input_tensor OrtReleaseValue drop
    output_tensor OrtReleaseValue drop
	memory_info OrtReleaseMemoryInfo drop
	session OrtReleaseSession drop
	session_options OrtReleaseSessionOptions drop
    env OrtReleaseEnv drop
	
	texmem0 SDL_DestroyTexture
	;
