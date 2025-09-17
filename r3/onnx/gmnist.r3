| ONNX example
| PHREDA 2025

^r3/lib/sdl2gfx.r3
^r3/lib/vdraw.r3
^r3/util/ui.r3
^r3/lib/onnx.r3

#output_data_f * 4096

#env 
#session_options
#session
#memory_info

#input_shape 1 1 28 28 
#input_data * 3136 | 28*28*4 (float)

#input_tensor
#output_tensor
#output_data

#max #rec

:ortcheck
	dup OrtGetErrorMessage .println OrtReleaseStatus ;

| Input and output names
#in	"Input3"
#input_names 'in 

#on "Plus214_Output_0"
#output_names 'on 
	
:onnxrun
| Run inference
    session 0 
	'input_names 'input_tensor 1 
	'output_names 1 'output_tensor
	OrtRun 
	1? ( ortcheck ; ) drop

	output_tensor 'output_data OrtGetTensorMutableData
	1? ( ortcheck ; ) drop

| Encontrar el número con la mayor probabilidad
	0 'max ! -1 'rec !	
	output_data >a		
	'output_data_f >b		
	0 ( 10 <?
		da@+ fp2f 
		max >? ( dup 'max ! over 'rec ! )
		db!+
		1+ ) drop
	;
	
|----------------
#font1	
#grid * 1024

:gridcolor | x y c --
	0? ( drop ; ) drop
	over 3 << 16 + 
	over 3 << 16 + swap
	8 8 SDLFRect ;
	
:drawgrid
	$ffffff sdlcolor
	'grid >a
	0 ( 28 <?
		0 ( 28 <?
			ca@+ gridcolor
		1+ ) drop
	1+ ) drop ;
	
:clearGrid
	'grid 0 128 fill ; |dvc
	
:geng	
	1? ( 1.0 f2fp nip ) ;
	
:runGrid	
	'grid >a
	'input_data >b
	0 ( 28 <?
		0 ( 28 <? 
			ca@+ geng db!+
			1+ ) drop
		1+ ) drop
	onnxrun ;

|---------------	
	
:setg
	28 * + 'grid + 1 swap c! ;

:dnd 
	sdlx 16 - 3 >> 27 >? ( drop ; )
	sdly 16 - 3 >> 27 >? ( 2drop ; )
	vop ;

:moved
	sdlx 16 - 3 >> 27 >? ( drop ; )
	sdly 16 - 3 >> 27 >? ( 2drop ; )
	vline ;	

:upd
	rungrid ;
	
:mainmnist	
	0 sdlcls
	drawgrid

	16 dup 28 8 * dup 
	2over 2over guiBox sdlRect
	'dnd 'moved 'upd onMap

	uiStart
	4 2 uiPad
	280 16 0.3 %w 0.6 %h uiWin!
	$222222 sdlcolor uiFillW 
	1 14 uiGridA uiV
	'output_data_f >a
	0 ( 10 <?
		da@+ over "%d : %f " sprint uiLabel
		1+ ) drop
	rec ">> %d <<" sprint uiLabelc
	stSucc
	'clearGrid "Clear" uiRBtn
|	'runGrid "Run" uiRBtn
	stDang	
	'exit "Exit" uiRBtn
	uiEnd
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
		
		
#wchar * 1024

:towchar | str -- str
	'wchar swap
	( c@+ 1? 
		rot w!+ swap 
		) nip swap w!
	'wchar ;
	
:main
	|OrtGetVersionString .println
	
	4 "test" 'env OrtCreateEnv 1? ( ortcheck ; ) drop
    'session_options OrtCreateSessionOptions 1? ( ortcheck ; ) drop
    env "onnx/mnist-12.onnx" towchar 
	session_options 'session OrtCreateSession 1? ( ortcheck ; ) drop
	"Cpu" OrtArenaAllocator 0 OrtMemTypeDefault 
	'memory_info OrtCreateMemoryInfo  1? ( ortcheck ; ) drop
	memory_info 'input_data 3136 'input_shape 4 ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT 'input_tensor	
	OrtCreateTensorWithDataAsOrtValue 1? ( ortcheck ; ) drop
	
	'mainmnist SDLshow 

| Liberar recursos
	memory_info OrtReleaseMemoryInfo drop
	input_tensor OrtReleaseValue drop
	output_tensor OrtReleaseValue drop
	
	session OrtReleaseSession drop
	session_options OrtReleaseSessionOptions drop
	env OrtReleaseEnv drop
	;

:
	"Hello Word IA" 800 600 SDLinit
	"media/ttf/Roboto-bold.ttf" 19 txload 'font1 !
	font1 txfont
	'setg vset!	
	main
	SDLquit	
	;
