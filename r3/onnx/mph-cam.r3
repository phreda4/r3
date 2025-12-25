| Mediapipe hand
| PHREDA 2025
^r3/lib/sdl2gfx.r3	
^r3/util/varanim.r3
^r3/util/txfont.r3

^r3/lib/webcam.r3

^./mphands.r3

#font

|#cw 640 #ch 480
#cw 1280 #ch 720

#cam
#camdata
0 | unsigned char *data;
0 | int width; int height;
0 | int size; WebcamPixelFormat format;
0 | unsigned long timestamp_ms; 

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
	|mpixel capture 1280 720 * 2/ move | dsc
	mpixel camdata 1280 720 * 2* memcpy_avx
	texmem SDL_UnlockTexture
	texmem MPHands
	
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

	cam 'camdata webcam_capture 0? ( 
		setimg 
		cam webcam_release_frame
		) drop
		
	MPdrawhands
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
	"handpose MP" 0 1024 720 SDLinitScr | display 0,1	
	
	"media/ttf/Roboto-bold.ttf" 28 txload 'font !
	font txfont

|--- webcam
	1280 720 0
	WEBCAM_FMT_YUYV 
	webcam_open 
	0? ( drop "no webcam" .println ; ) 'cam !
	sdlRenderer $32595559 1 1280 720 SDL_CreateTexture 'texmem ! |SDL_PIXELFORMAT_YUV2
	texmem startMPHands
	
	'mainvideo SDLshow

	freeMPHands	
	texmem SDL_DestroyTexture
	SDLQuit
	;