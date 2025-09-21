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
	224 pixw 16 <</ 
	224 pixh 16 <</ 
	min	'imgz ! 
	pixw pixh 2dup max dup
	rot 16 <</ 'scly !
	swap 16 <</ 'sclx !
	
|--- centrado	
	pixw imgz *. 1+ 224 over - 2/ 'rectd d! 'rectd 8 + d!
	pixh imgz *. 1+	224 over - 2/ 'rectd 4 + d! 'rectd 12 + d!
	
	SDLrenderer $16362004 2 224 224 SDL_CreateTexture 'texmem0 !
	SDLrenderer $16362004 2 256 256 SDL_CreateTexture 'texmem1 !
	;
	
:getframe0  | texture --
	SDLrenderer texmem0 SDL_SetRenderTarget
	$727272 sdlcls
	SDLrenderer swap 0 'rectd SDL_RenderCopy
	SDLrenderer 0 $16362004 pix 224 2 << SDL_RenderReadPixels
	SDLrenderer 0 SDL_SetRenderTarget
	| convert rgb...>>RGB..
	pix input_data 224 224 * 
	|memcpy_rgb3f 
	memcpy_rgbf
	;

:letterx 0.5 - sclx *. 0.5 + ;
:lettery 0.5 - scly *. 0.5 + ;
		

|--------------------------------
| $yyy xxx YYYYY XXXXX
|      52  40    20
| $..... 
#dx #dy
#p0 #p1 #lenval

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
	lenval over -			| y1 yy x2 x1 xx
	-rot - 				| y1 yy xx x/
	2dup 'dx ! 'dy !
	*/ + lenval swap setxy 
	|... cut the shadow too
	cutshadow ;
	
|r.y=val; r.x=x1+(x2-x1)*(val-y1)/(y2-y1);	
:clipy | -- pr
	p0 getxy p1 getxy	| x1 y1 x2 y2
	swap pick3 -		| x1 y1 y2 xx
	lenval pick3 -			| x1 y1 y2 xx yy
	2swap swap - 
	2dup 'dx ! 'dy !
	*/ + lenval setxy 
	|... cut the shadow too
	cutshadow ;
	
#xclip 'clipx 	
:clipxy xclip ex ;

|... compare 	
:cmpx 44 << 44 >> lenval - ;
:inxi cmpx not 63 >> 1 and ; 
:inxa cmpx 63 >> 1 and ; 

:cmpy 24 << 44 >> lenval - ;
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
	'check ! 'lenval !
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

#box_x #box_y 
#k0_x #k0_y 
#k3_x #k3_y 
#rota
	
:genbox | --
	|... build
	rota sincos 'dx ! 'dy !
	k0_x 224 / k0_y 224 /
	ab[
	'vertex >a 
	lenval neg dup rotv a!+
	lenval dup neg rotv $ff0000000000 or a!+ 
	lenval dup		rotv $ff0ff0000000000 or a!+
	lenval dup neg swap rotv $ff0000000000000 or a!+
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

:getframe1 | tex --
	genbox
	|----- | imagen rotada
	SDLrenderer texmem1 SDL_SetRenderTarget
	$727272 sdlcls
	SDLrenderer swap | texture
	'verfix 
	vertex> 'vertex - 3 >> | cntvertex
	'vindex 
	over 2 - 3 * | cntindex
	SDL_RenderGeometry
	
	SDLrenderer 0 $16362004 pix 256 2 << SDL_RenderReadPixels
	SDLrenderer 0 SDL_SetRenderTarget
	| conver to R G B
	pix input_data 256 256 * |memcpy_rgb3f | rgb RRR...GGG...BBB
	memcpy_rgbf
	;
	
:freeframe
	texmem1 SDL_DestroyTexture
	texmem0 SDL_DestroyTexture
	;

|---------------------------------------------- 
#env

#session_options

#sessionp
#sessionl

#memory_info

#output_tensor0
#output_tensor1

#output_tensor2
#output_tensor3
#output_tensor4
#output_tensor5
#output_tensor6

|name: input_1 tensor: float32[1,224,224,3]
|name: Identity tensor: float32[1,2254,12]
|name: Identity_1 tensor: float32[1,2254,1]
|------------------
#hand_shape 1 224 224 3
#n0 "input_1"
#hand_input_names 'n0
#n0 "Identity"
#n1 "Identity_1"
#hand_output_names 'n0 'n1

#id00
#id01

|name: input_1 tensor: float32[1,256,256,3]

|name: Identity tensor: float32[1,195] | x y z c f - 33 valores
|name: Identity_1 tensor: float32[1,1] | pose valid?
|name: Identity_2 tensor: float32[1,256,256,1]
|name: Identity_3 tensor: float32[1,64,64,39]
|name: Identity_4 tensor: float32[1,117] | normalizado?
|------------------
#mark_shape 1 256 256 3
#n0 "input_1"
#mark_input_names 'n0
#n0 "Identity"
#n1 "Identity_1"
#n2 "Identity_2"
#n3 "Identity_3"
#n4 "Identity_4"
#mark_output_names 'n0 'n1 'n2 'n3 'n4

#id10
#id11
#id12
#id13
#id14

:ortcheck
	dup OrtGetErrorMessage .println	OrtReleaseStatus drop waitesc ;
	
|---------------------------------			
#wchar * 256

:towchar | str -- str
	'wchar swap ( c@+ 1? rot w!+ swap ) nip swap w! 'wchar ;
	
::startMPpose | texture --
	sizeframe
	
	2 "pose" 'env OrtCreateEnv 1? ( ortcheck ; ) drop
    'session_options OrtCreateSessionOptions 1? ( ortcheck ; ) drop
    session_options 99 OrtSetSessionGraphOptimizationLevel 1? ( ortcheck ; ) drop
	
	env "onnx/pose_detection.onnx" towchar 
	session_options 'sessionp OrtCreateSession 1? ( ortcheck ; ) drop
	env	"onnx/pose_landmarks_detector_lite.onnx" towchar 
	session_options 'sessionl OrtCreateSession 1? ( ortcheck ; ) drop
	
	OrtArenaAllocator OrtMemTypeDefault 'memory_info OrtCreateCpuMemoryInfo 1? ( ortcheck ; ) drop	
	
	|--- MEMORY		
	here 
	align32
	dup 'pix ! 256 256 * 2 << + 
	dup 'input_data ! 256 256 * 3 * 2 << +
	'here !	
	;
	
::freeMPpose
	freeframe
	
    output_tensor0 OrtReleaseValue drop
	output_tensor1 OrtReleaseValue drop
	
	output_tensor2 OrtReleaseValue drop
	output_tensor3 OrtReleaseValue drop
	output_tensor4 OrtReleaseValue drop
	output_tensor5 OrtReleaseValue drop
	output_tensor6 OrtReleaseValue drop
	
	memory_info OrtReleaseMemoryInfo drop
	sessionl OrtReleaseSession drop
	sessionp OrtReleaseSession drop
	session_options OrtReleaseSessionOptions drop
    env OrtReleaseEnv drop ;

:onnxrun0
| entrada
    memory_info 
	input_data
	224 224 * 3 * 2 << 
	'hand_shape 4 ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT 
	'input_tensor
	OrtCreateTensorWithDataAsOrtValue 1? ( ortcheck ; ) drop
| inferencia0
	0 'output_tensor0 !
    sessionp 0 
	'hand_input_names 'input_tensor 1 
	'hand_output_names 2 'output_tensor0
	OrtRun 1? ( ortcheck ; ) drop
| Obtener datos de salida
	output_tensor0 'id00 OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	output_tensor1 'id01 OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	;

:onnxrun1
| entrada
    memory_info 
	input_data
	256 256 * 3 * 2 << 
	'mark_shape 4 ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT 
	'input_tensor
	OrtCreateTensorWithDataAsOrtValue 1? ( ortcheck ; ) drop
| inferencia1
|	0 'output_tensor2 ! 0 'output_tensor3 !
    sessionl 0 
	'mark_input_names 'input_tensor 1 
	'mark_output_names 5 'output_tensor2
	OrtRun 1? ( ortcheck ; ) drop
| Obtener datos de salida
	output_tensor2 'id10 OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	output_tensor3 'id11 OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	output_tensor4 'id12 OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	output_tensor5 'id13 OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	output_tensor6 'id14 OrtGetTensorMutableData 1? ( ortcheck ; ) drop
	;

|--------------------- MARKS
#banchor2254 [
$4040404 $40D040D $4160416 $4200420 $4290429 $4320432 $43B043B $4440444 
$44D044D $4560456 $4600460 $4690469 $4720472 $47B047B $4840484 $48D048D 
$4960496 $4A004A0 $4A904A9 $4B204B2 $4BB04BB $4C404C4 $4CD04CD $4D604D6 
$4E004E0 $4E904E9 $4F204F2 $4FB04FB $D040D04 $D0D0D0D $D160D16 $D200D20 
$D290D29 $D320D32 $D3B0D3B $D440D44 $D4D0D4D $D560D56 $D600D60 $D690D69 
$D720D72 $D7B0D7B $D840D84 $D8D0D8D $D960D96 $DA00DA0 $DA90DA9 $DB20DB2 
$DBB0DBB $DC40DC4 $DCD0DCD $DD60DD6 $DE00DE0 $DE90DE9 $DF20DF2 $DFB0DFB 
$16041604 $160D160D $16161616 $16201620 $16291629 $16321632 $163B163B $16441644 
$164D164D $16561656 $16601660 $16691669 $16721672 $167B167B $16841684 $168D168D 
$16961696 $16A016A0 $16A916A9 $16B216B2 $16BB16BB $16C416C4 $16CD16CD $16D616D6 
$16E016E0 $16E916E9 $16F216F2 $16FB16FB $20042004 $200D200D $20162016 $20202020 
$20292029 $20322032 $203B203B $20442044 $204D204D $20562056 $20602060 $20692069 
$20722072 $207B207B $20842084 $208D208D $20962096 $20A020A0 $20A920A9 $20B220B2 
$20BB20BB $20C420C4 $20CD20CD $20D620D6 $20E020E0 $20E920E9 $20F220F2 $20FB20FB 
$29042904 $290D290D $29162916 $29202920 $29292929 $29322932 $293B293B $29442944 
$294D294D $29562956 $29602960 $29692969 $29722972 $297B297B $29842984 $298D298D 
$29962996 $29A029A0 $29A929A9 $29B229B2 $29BB29BB $29C429C4 $29CD29CD $29D629D6 
$29E029E0 $29E929E9 $29F229F2 $29FB29FB $32043204 $320D320D $32163216 $32203220 
$32293229 $32323232 $323B323B $32443244 $324D324D $32563256 $32603260 $32693269 
$32723272 $327B327B $32843284 $328D328D $32963296 $32A032A0 $32A932A9 $32B232B2 
$32BB32BB $32C432C4 $32CD32CD $32D632D6 $32E032E0 $32E932E9 $32F232F2 $32FB32FB 
$3B043B04 $3B0D3B0D $3B163B16 $3B203B20 $3B293B29 $3B323B32 $3B3B3B3B $3B443B44 
$3B4D3B4D $3B563B56 $3B603B60 $3B693B69 $3B723B72 $3B7B3B7B $3B843B84 $3B8D3B8D 
$3B963B96 $3BA03BA0 $3BA93BA9 $3BB23BB2 $3BBB3BBB $3BC43BC4 $3BCD3BCD $3BD63BD6 
$3BE03BE0 $3BE93BE9 $3BF23BF2 $3BFB3BFB $44044404 $440D440D $44164416 $44204420 
$44294429 $44324432 $443B443B $44444444 $444D444D $44564456 $44604460 $44694469 
$44724472 $447B447B $44844484 $448D448D $44964496 $44A044A0 $44A944A9 $44B244B2 
$44BB44BB $44C444C4 $44CD44CD $44D644D6 $44E044E0 $44E944E9 $44F244F2 $44FB44FB 
$4D044D04 $4D0D4D0D $4D164D16 $4D204D20 $4D294D29 $4D324D32 $4D3B4D3B $4D444D44 
$4D4D4D4D $4D564D56 $4D604D60 $4D694D69 $4D724D72 $4D7B4D7B $4D844D84 $4D8D4D8D 
$4D964D96 $4DA04DA0 $4DA94DA9 $4DB24DB2 $4DBB4DBB $4DC44DC4 $4DCD4DCD $4DD64DD6 
$4DE04DE0 $4DE94DE9 $4DF24DF2 $4DFB4DFB $56045604 $560D560D $56165616 $56205620 
$56295629 $56325632 $563B563B $56445644 $564D564D $56565656 $56605660 $56695669 
$56725672 $567B567B $56845684 $568D568D $56965696 $56A056A0 $56A956A9 $56B256B2 
$56BB56BB $56C456C4 $56CD56CD $56D656D6 $56E056E0 $56E956E9 $56F256F2 $56FB56FB 
$60046004 $600D600D $60166016 $60206020 $60296029 $60326032 $603B603B $60446044 
$604D604D $60566056 $60606060 $60696069 $60726072 $607B607B $60846084 $608D608D 
$60966096 $60A060A0 $60A960A9 $60B260B2 $60BB60BB $60C460C4 $60CD60CD $60D660D6 
$60E060E0 $60E960E9 $60F260F2 $60FB60FB $69046904 $690D690D $69166916 $69206920 
$69296929 $69326932 $693B693B $69446944 $694D694D $69566956 $69606960 $69696969 
$69726972 $697B697B $69846984 $698D698D $69966996 $69A069A0 $69A969A9 $69B269B2 
$69BB69BB $69C469C4 $69CD69CD $69D669D6 $69E069E0 $69E969E9 $69F269F2 $69FB69FB 
$72047204 $720D720D $72167216 $72207220 $72297229 $72327232 $723B723B $72447244 
$724D724D $72567256 $72607260 $72697269 $72727272 $727B727B $72847284 $728D728D 
$72967296 $72A072A0 $72A972A9 $72B272B2 $72BB72BB $72C472C4 $72CD72CD $72D672D6 
$72E072E0 $72E972E9 $72F272F2 $72FB72FB $7B047B04 $7B0D7B0D $7B167B16 $7B207B20 
$7B297B29 $7B327B32 $7B3B7B3B $7B447B44 $7B4D7B4D $7B567B56 $7B607B60 $7B697B69 
$7B727B72 $7B7B7B7B $7B847B84 $7B8D7B8D $7B967B96 $7BA07BA0 $7BA97BA9 $7BB27BB2 
$7BBB7BBB $7BC47BC4 $7BCD7BCD $7BD67BD6 $7BE07BE0 $7BE97BE9 $7BF27BF2 $7BFB7BFB 
$84048404 $840D840D $84168416 $84208420 $84298429 $84328432 $843B843B $84448444 
$844D844D $84568456 $84608460 $84698469 $84728472 $847B847B $84848484 $848D848D 
$84968496 $84A084A0 $84A984A9 $84B284B2 $84BB84BB $84C484C4 $84CD84CD $84D684D6 
$84E084E0 $84E984E9 $84F284F2 $84FB84FB $8D048D04 $8D0D8D0D $8D168D16 $8D208D20 
$8D298D29 $8D328D32 $8D3B8D3B $8D448D44 $8D4D8D4D $8D568D56 $8D608D60 $8D698D69 
$8D728D72 $8D7B8D7B $8D848D84 $8D8D8D8D $8D968D96 $8DA08DA0 $8DA98DA9 $8DB28DB2 
$8DBB8DBB $8DC48DC4 $8DCD8DCD $8DD68DD6 $8DE08DE0 $8DE98DE9 $8DF28DF2 $8DFB8DFB 
$96049604 $960D960D $96169616 $96209620 $96299629 $96329632 $963B963B $96449644 
$964D964D $96569656 $96609660 $96699669 $96729672 $967B967B $96849684 $968D968D 
$96969696 $96A096A0 $96A996A9 $96B296B2 $96BB96BB $96C496C4 $96CD96CD $96D696D6 
$96E096E0 $96E996E9 $96F296F2 $96FB96FB $A004A004 $A00DA00D $A016A016 $A020A020 
$A029A029 $A032A032 $A03BA03B $A044A044 $A04DA04D $A056A056 $A060A060 $A069A069 
$A072A072 $A07BA07B $A084A084 $A08DA08D $A096A096 $A0A0A0A0 $A0A9A0A9 $A0B2A0B2 
$A0BBA0BB $A0C4A0C4 $A0CDA0CD $A0D6A0D6 $A0E0A0E0 $A0E9A0E9 $A0F2A0F2 $A0FBA0FB 
$A904A904 $A90DA90D $A916A916 $A920A920 $A929A929 $A932A932 $A93BA93B $A944A944 
$A94DA94D $A956A956 $A960A960 $A969A969 $A972A972 $A97BA97B $A984A984 $A98DA98D 
$A996A996 $A9A0A9A0 $A9A9A9A9 $A9B2A9B2 $A9BBA9BB $A9C4A9C4 $A9CDA9CD $A9D6A9D6 
$A9E0A9E0 $A9E9A9E9 $A9F2A9F2 $A9FBA9FB $B204B204 $B20DB20D $B216B216 $B220B220 
$B229B229 $B232B232 $B23BB23B $B244B244 $B24DB24D $B256B256 $B260B260 $B269B269 
$B272B272 $B27BB27B $B284B284 $B28DB28D $B296B296 $B2A0B2A0 $B2A9B2A9 $B2B2B2B2 
$B2BBB2BB $B2C4B2C4 $B2CDB2CD $B2D6B2D6 $B2E0B2E0 $B2E9B2E9 $B2F2B2F2 $B2FBB2FB 
$BB04BB04 $BB0DBB0D $BB16BB16 $BB20BB20 $BB29BB29 $BB32BB32 $BB3BBB3B $BB44BB44 
$BB4DBB4D $BB56BB56 $BB60BB60 $BB69BB69 $BB72BB72 $BB7BBB7B $BB84BB84 $BB8DBB8D 
$BB96BB96 $BBA0BBA0 $BBA9BBA9 $BBB2BBB2 $BBBBBBBB $BBC4BBC4 $BBCDBBCD $BBD6BBD6 
$BBE0BBE0 $BBE9BBE9 $BBF2BBF2 $BBFBBBFB $C404C404 $C40DC40D $C416C416 $C420C420 
$C429C429 $C432C432 $C43BC43B $C444C444 $C44DC44D $C456C456 $C460C460 $C469C469 
$C472C472 $C47BC47B $C484C484 $C48DC48D $C496C496 $C4A0C4A0 $C4A9C4A9 $C4B2C4B2 
$C4BBC4BB $C4C4C4C4 $C4CDC4CD $C4D6C4D6 $C4E0C4E0 $C4E9C4E9 $C4F2C4F2 $C4FBC4FB 
$CD04CD04 $CD0DCD0D $CD16CD16 $CD20CD20 $CD29CD29 $CD32CD32 $CD3BCD3B $CD44CD44 
$CD4DCD4D $CD56CD56 $CD60CD60 $CD69CD69 $CD72CD72 $CD7BCD7B $CD84CD84 $CD8DCD8D 
$CD96CD96 $CDA0CDA0 $CDA9CDA9 $CDB2CDB2 $CDBBCDBB $CDC4CDC4 $CDCDCDCD $CDD6CDD6 
$CDE0CDE0 $CDE9CDE9 $CDF2CDF2 $CDFBCDFB $D604D604 $D60DD60D $D616D616 $D620D620 
$D629D629 $D632D632 $D63BD63B $D644D644 $D64DD64D $D656D656 $D660D660 $D669D669 
$D672D672 $D67BD67B $D684D684 $D68DD68D $D696D696 $D6A0D6A0 $D6A9D6A9 $D6B2D6B2 
$D6BBD6BB $D6C4D6C4 $D6CDD6CD $D6D6D6D6 $D6E0D6E0 $D6E9D6E9 $D6F2D6F2 $D6FBD6FB 
$E004E004 $E00DE00D $E016E016 $E020E020 $E029E029 $E032E032 $E03BE03B $E044E044 
$E04DE04D $E056E056 $E060E060 $E069E069 $E072E072 $E07BE07B $E084E084 $E08DE08D 
$E096E096 $E0A0E0A0 $E0A9E0A9 $E0B2E0B2 $E0BBE0BB $E0C4E0C4 $E0CDE0CD $E0D6E0D6 
$E0E0E0E0 $E0E9E0E9 $E0F2E0F2 $E0FBE0FB $E904E904 $E90DE90D $E916E916 $E920E920 
$E929E929 $E932E932 $E93BE93B $E944E944 $E94DE94D $E956E956 $E960E960 $E969E969 
$E972E972 $E97BE97B $E984E984 $E98DE98D $E996E996 $E9A0E9A0 $E9A9E9A9 $E9B2E9B2 
$E9BBE9BB $E9C4E9C4 $E9CDE9CD $E9D6E9D6 $E9E0E9E0 $E9E9E9E9 $E9F2E9F2 $E9FBE9FB 
$F204F204 $F20DF20D $F216F216 $F220F220 $F229F229 $F232F232 $F23BF23B $F244F244 
$F24DF24D $F256F256 $F260F260 $F269F269 $F272F272 $F27BF27B $F284F284 $F28DF28D 
$F296F296 $F2A0F2A0 $F2A9F2A9 $F2B2F2B2 $F2BBF2BB $F2C4F2C4 $F2CDF2CD $F2D6F2D6 
$F2E0F2E0 $F2E9F2E9 $F2F2F2F2 $F2FBF2FB $FB04FB04 $FB0DFB0D $FB16FB16 $FB20FB20 
$FB29FB29 $FB32FB32 $FB3BFB3B $FB44FB44 $FB4DFB4D $FB56FB56 $FB60FB60 $FB69FB69 
$FB72FB72 $FB7BFB7B $FB84FB84 $FB8DFB8D $FB96FB96 $FBA0FBA0 $FBA9FBA9 $FBB2FBB2 
$FBBBFBBB $FBC4FBC4 $FBCDFBCD $FBD6FBD6 $FBE0FBE0 $FBE9FBE9 $FBF2FBF2 $FBFBFBFB 
$9090909 $91B091B $92D092D $9400940 $9520952 $9640964 $9760976 $9890989 
$99B099B $9AD09AD $9C009C0 $9D209D2 $9E409E4 $9F609F6 $1B091B09 $1B1B1B1B 
$1B2D1B2D $1B401B40 $1B521B52 $1B641B64 $1B761B76 $1B891B89 $1B9B1B9B $1BAD1BAD 
$1BC01BC0 $1BD21BD2 $1BE41BE4 $1BF61BF6 $2D092D09 $2D1B2D1B $2D2D2D2D $2D402D40 
$2D522D52 $2D642D64 $2D762D76 $2D892D89 $2D9B2D9B $2DAD2DAD $2DC02DC0 $2DD22DD2 
$2DE42DE4 $2DF62DF6 $40094009 $401B401B $402D402D $40404040 $40524052 $40644064 
$40764076 $40894089 $409B409B $40AD40AD $40C040C0 $40D240D2 $40E440E4 $40F640F6 
$52095209 $521B521B $522D522D $52405240 $52525252 $52645264 $52765276 $52895289 
$529B529B $52AD52AD $52C052C0 $52D252D2 $52E452E4 $52F652F6 $64096409 $641B641B 
$642D642D $64406440 $64526452 $64646464 $64766476 $64896489 $649B649B $64AD64AD 
$64C064C0 $64D264D2 $64E464E4 $64F664F6 $76097609 $761B761B $762D762D $76407640 
$76527652 $76647664 $76767676 $76897689 $769B769B $76AD76AD $76C076C0 $76D276D2 
$76E476E4 $76F676F6 $89098909 $891B891B $892D892D $89408940 $89528952 $89648964 
$89768976 $89898989 $899B899B $89AD89AD $89C089C0 $89D289D2 $89E489E4 $89F689F6 
$9B099B09 $9B1B9B1B $9B2D9B2D $9B409B40 $9B529B52 $9B649B64 $9B769B76 $9B899B89 
$9B9B9B9B $9BAD9BAD $9BC09BC0 $9BD29BD2 $9BE49BE4 $9BF69BF6 $AD09AD09 $AD1BAD1B 
$AD2DAD2D $AD40AD40 $AD52AD52 $AD64AD64 $AD76AD76 $AD89AD89 $AD9BAD9B $ADADADAD 
$ADC0ADC0 $ADD2ADD2 $ADE4ADE4 $ADF6ADF6 $C009C009 $C01BC01B $C02DC02D $C040C040 
$C052C052 $C064C064 $C076C076 $C089C089 $C09BC09B $C0ADC0AD $C0C0C0C0 $C0D2C0D2 
$C0E4C0E4 $C0F6C0F6 $D209D209 $D21BD21B $D22DD22D $D240D240 $D252D252 $D264D264 
$D276D276 $D289D289 $D29BD29B $D2ADD2AD $D2C0D2C0 $D2D2D2D2 $D2E4D2E4 $D2F6D2F6 
$E409E409 $E41BE41B $E42DE42D $E440E440 $E452E452 $E464E464 $E476E476 $E489E489 
$E49BE49B $E4ADE4AD $E4C0E4C0 $E4D2E4D2 $E4E4E4E4 $E4F6E4F6 $F609F609 $F61BF61B 
$F62DF62D $F640F640 $F652F652 $F664F664 $F676F676 $F689F689 $F69BF69B $F6ADF6AD 
$F6C0F6C0 $F6D2F6D2 $F6E4F6E4 $F6F6F6F6 $12121212 $12121212 $12121212 $12361236 
$12361236 $12361236 $125B125B $125B125B $125B125B $12801280 $12801280 $12801280 
$12A412A4 $12A412A4 $12A412A4 $12C912C9 $12C912C9 $12C912C9 $12ED12ED $12ED12ED 
$12ED12ED $36123612 $36123612 $36123612 $36363636 $36363636 $36363636 $365B365B 
$365B365B $365B365B $36803680 $36803680 $36803680 $36A436A4 $36A436A4 $36A436A4 
$36C936C9 $36C936C9 $36C936C9 $36ED36ED $36ED36ED $36ED36ED $5B125B12 $5B125B12 
$5B125B12 $5B365B36 $5B365B36 $5B365B36 $5B5B5B5B $5B5B5B5B $5B5B5B5B $5B805B80 
$5B805B80 $5B805B80 $5BA45BA4 $5BA45BA4 $5BA45BA4 $5BC95BC9 $5BC95BC9 $5BC95BC9 
$5BED5BED $5BED5BED $5BED5BED $80128012 $80128012 $80128012 $80368036 $80368036 
$80368036 $805B805B $805B805B $805B805B $80808080 $80808080 $80808080 $80A480A4 
$80A480A4 $80A480A4 $80C980C9 $80C980C9 $80C980C9 $80ED80ED $80ED80ED $80ED80ED 
$A412A412 $A412A412 $A412A412 $A436A436 $A436A436 $A436A436 $A45BA45B $A45BA45B 
$A45BA45B $A480A480 $A480A480 $A480A480 $A4A4A4A4 $A4A4A4A4 $A4A4A4A4 $A4C9A4C9 
$A4C9A4C9 $A4C9A4C9 $A4EDA4ED $A4EDA4ED $A4EDA4ED $C912C912 $C912C912 $C912C912 
$C936C936 $C936C936 $C936C936 $C95BC95B $C95BC95B $C95BC95B $C980C980 $C980C980 
$C980C980 $C9A4C9A4 $C9A4C9A4 $C9A4C9A4 $C9C9C9C9 $C9C9C9C9 $C9C9C9C9 $C9EDC9ED 
$C9EDC9ED $C9EDC9ED $ED12ED12 $ED12ED12 $ED12ED12 $ED36ED36 $ED36ED36 $ED36ED36 
$ED5BED5B $ED5BED5B $ED5BED5B $ED80ED80 $ED80ED80 $ED80ED80 $EDA4EDA4 $EDA4EDA4 
$EDA4EDA4 $EDC9EDC9 $EDC9EDC9 $EDC9EDC9 $EDEDEDED $EDEDEDED $EDEDEDED ]

| v-z-y-x (16 BITS)

#marks * 512 | puntos

#anchorx #anchory

:getbox | n -- 
	dup 2* 'banchor2254 + w@ 
	dup $ff and 8 << 224 * 'anchorx !
	$ff00 and 224 * 'anchory !	
	
	12 4 * * id00 +
	|d@+ fp2f anchorx + 'box_x ! d@+ fp2f anchory + 'box_y !
	|d@+ fp2f 'box_w ! d@+ fp2f 'box_h !
	16 +
	d@+ fp2f anchorx + 'k0_x ! d@+ fp2f anchory + 'k0_y ! | <<
|	d@+ fp2f anchorx + 'k1_x ! d@+ fp2f anchory + 'k1_y !
|	d@+ fp2f anchorx + 'k2_x ! d@+ fp2f anchory + 'k2_y !
	16 +
	d@+ fp2f anchorx + 'k3_x ! d@+ fp2f anchory + 'k3_y ! | <<
	drop
	k3_x k0_x - k0_y k3_y - 
	over dup *. over dup *. + sqrt. 112 / 'lenval ! 
	atan2 'rota !
	;

:getperson
	id01 >a
	0 da@+ 
	1 ( 2254 <? da@+ 	| nmax max now value
		pick2 >? ( 2swap 2drop 2dup )
		drop 1+ ) 2drop
	getbox ;


:getpose | texture --
	getframe1
	onnxrun1

	rota sincos 'dx ! 'dy !
	k0_x 224 / 'box_x !
	k0_y 224 / 'box_y !
	
	id10 >a
	'marks >b
	33 ( 1? 1-
		da@+ fp2f 8 >> $ffff and 			| X
		da@+ fp2f 8 >> $ffff and 16 << or	| Y
		da@+ fp2f 8 >> $ffff and 32 << or	| Z
		da@+ fp2f 8 >> $ffff and 48 << or	| Visibity
		b!+
		4 a+	| presence 
		) drop ;

#scorep

:getperson | texture --
	id01 >a
	0 da@+ 
	1 ( 2254 <? da@+ 	| nmax max now value
		pick2 >? ( 2swap 2drop 2dup )
		drop 1+ ) drop
	-? ( 'scorep ! 2drop ; ) 'scorep ! 
	getbox 
	getpose ;
	
|--------------------------------	
#POSE_CON  ( 
	 0  1  1  2  2  3  3  7  0  4 
	 4  5  5  6  6  8  9 10 11 12 
	11 13 13 15 15 17 15 19 15 21 
	17 19 12 14 14 16 16 18 16 20 
	16 22 18 20 11 23 12 24 23 24 
	23 25 24 26 25 27 26 28 27 29 
	28 30 29 31 30 32 27 31 28 32 )
	
:Dgetxy | n - x y 
	3 << 'marks + @ 
	dup $ffff and 8 >> 
	swap 16 >> $ffff and 8 >> 300 +
	;
	
:drawpose0
	'pose_con >a 
	35 ( 1? 1- 
		ca@+ Dgetxy
		ca@+ Dgetxy
		sdlline ) drop ;

|----		
:rotb | x y -- x1 y1
	over dx * over dy * - 16 >> -rot | x1 x y x1
	swap dy * swap dx * + 16 >> ;

:Dgetxy1 | n - x y 
	3 << 'marks + @ 
	dup $ffff and 0.5 -
	swap 16 >> $ffff and 0.5 -
	rotb
	swap box_x 0.5 - + 
	224 *. 112 + 200 +
	swap box_y 0.5 - + 
	224 *. 112 +
	;

:drawpose1
	'pose_con >a 
	35 ( 1? 1- 
		ca@+ Dgetxy1 
		ca@+ Dgetxy1 
		sdlline ) drop 
		;

::MPdrawpose
	drawpose0
	drawpose1
	;
	
|----------------------
::MPpose | texture --
	dup getframe0
	onnxrun0
	getperson
	;	

	