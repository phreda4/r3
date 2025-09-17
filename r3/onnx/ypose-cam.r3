| Mediapipe hand
| PHREDA 2025
^r3/lib/sdl2gfx.r3	
^r3/util/varanim.r3
^r3/util/txfont.r3

^r3/lib/escapi.r3

^./yolopose.r3

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
|	mpixel capture 640 480 * 2 << memcpy_avx	
	mpixel capture 1280 720 * 2 << memcpy_avx
	texmem SDL_UnlockTexture
	device doCapture
	texmem YoloPose
	;

#viewflags 0
:mainvideo
	getfps 
	0 sdlcls

	viewflags
	$1 and? ( 512 360 0.5 texmem spritez )
	drop

	device isCaptureDone 1? ( setimg ) drop 

	YoloPoseDraw
	900 16 txat fps "%d fps" txprint
	16 680 txat "F1-Cam" txprint
	SDLRedraw 
	SDLkey 
	>esc< =? ( exit ) 
	<f1> =? ( viewflags $1 xor 'viewflags ! )
	drop ;			

|------------------------------
|---------------------------------------------	
:  
	"YoloPose" 1024 720 SDLinit 
	"media/ttf/Roboto-bold.ttf" 28 txload 'font !
	font txfont

|--- webcam
	setupESCAPI 1 <? ( "no webcam" .println ) drop |'maxdevice !
	0 'device !
	cw ch SDLframebuffer 'texmem !
	
	texmem startYoloPose
	
	here 'capture !
	cw ch * 4 * 'here +!
	device 'capture initCapture drop |"%d" .println
	
	device doCapture
	'mainvideo SDLshow

	freeYoloPose	
	texmem SDL_DestroyTexture
	SDLQuit
	;