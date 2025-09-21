| Mediapipe hand
| PHREDA 2025
^r3/lib/sdl2gfx.r3	
^r3/util/txfont.r3

^r3/lib/escapi.r3

^./mppose.r3

#font

|#cw 640 #ch 480
#cw 1280 #ch 720
#device
|#capture 0 [ 640 480 ]
#capture 0 [ 1280 720 ]
#mpixel #mpitch
#texmem
|----------------------
#fps #fpsc #seca
	
:getfps
	1 'fpsc +! msec seca <? ( drop ; )
	1000 + 'seca ! fpsc 'fps ! 0 'fpsc ! ;
|----------------------

:setimg
	texmem 0 'mpixel 'mpitch SDL_LockTexture
	|mpixel capture cw ch * 2/ move | dsc
	mpixel capture 1280 720 * 2 << memcpy_avx	
	texmem SDL_UnlockTexture
	device doCapture
	texmem MPpose
	;

#viewflags
:mainvideo
	getfps 
	0 sdlcls

	viewflags
	$1 and? ( 128 128 texmem0 sprite )
	$2 and? ( 128 384 texmem1 sprite )
	$4 and? ( 512 320 0.5 texmem spritez )
	drop

	device isCaptureDone 1? ( setimg ) drop 

	MPdrawpose
	900 16 txat fps "%d fps" txprint
	16 680 txat "F1-tex0 F2-tex0 F3-Cam" txprint
	SDLRedraw 
	SDLkey 
	>esc< =? ( exit ) 
	<f1> =? ( viewflags $1 xor 'viewflags ! )
	<f2> =? ( viewflags $2 xor 'viewflags ! )
	<f3> =? ( viewflags $4 xor 'viewflags ! )
	drop ;			

|------------------------------
|---------------------------------------------	
:  
	"pose MP" 1024 720 SDLinitScr	
	
	"media/ttf/Roboto-bold.ttf" 28 txload 'font !
	font txfont

|--- webcam
	setupESCAPI 1 <? ( "no webcam" .println ) drop |'maxdevice !
	0 'device !
	cw ch SDLframebuffer 'texmem !
	
	texmem startMPpose
	
	here 'capture !
	cw ch * 4 * 'here +!
	device 'capture initCapture drop |"%d" .println
	
	device doCapture
	'mainvideo SDLshow

	freeMPpose
	texmem SDL_DestroyTexture
	SDLQuit
	;