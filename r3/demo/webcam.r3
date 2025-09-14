| https://github.com/jarikomppa/escapi
| lib for webcam

^r3/lib/sdl2gfx.r3	
^r3/util/varanim.r3
^r3/util/txfont.r3
^r3/lib/escapi.r3
^r3/lib/rand.r3

|-------------------
#device
#capture 0 [ 640 480 ]
#texmem
#mpixel #mpitch

:setimg
	texmem 0 'mpixel 'mpitch SDL_LockTexture
	mpixel capture 640 240 * move | dsc
	texmem SDL_UnlockTexture
	device doCapture
	;

:main
	0 sdlcls
	512 320 texmem sprite
	device isCaptureDone 1? ( setimg ) drop 
	sdlredraw
	sdlkey >esc< =? ( exit ) drop
	;


| 
: 
	"ESCAPI demo" 0 1024 640 SDLinitScr | display 0,1	
	
	setupESCAPI 1 <? ( "Unable to init ESCAPI" .println ) drop |'maxdevice !
	0 'device !
	
	|512 512 SDLframebuffer 'texmem !
	640 480 SDLframebuffer 'texmem !
	|512 512 here 'capture !+ d!+ d!
	here 'capture !
	512 512 * 4 * 'here +!
	device 'capture initCapture drop |"%d" .println
	device doCapture
	
	'main sdlshow
	SDLQuit
	;