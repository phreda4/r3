| https://github.com/jarikomppa/escapi
| lib for webcam

^r3/lib/sdl2gfx.r3	
^r3/util/txfont.r3
^r3/util/immi.r3
^r3/lib/webcam.r3
^r3/lib/memavx.r3

#font
|-------------------

#cam
#camw #camh 

#camdata
0 | unsigned char *data;
0 | int width; int height;
0 | int size; WebcamPixelFormat format;
0 | unsigned long timestamp_ms; 

#texmem
#tsize 0.6

#mpixel #mpitch
	
:setimg	
	texmem 0 'mpixel 'mpitch SDL_LockTexture
	|mpixel capture 1280 720 * 2/ move | dsc
	mpixel camdata 1280 720 * 3 * memcpy_avx
	texmem SDL_UnlockTexture
	;	

:setimg2
	texmem 0 'mpixel 'mpitch SDL_LockTexture
	|mpixel capture 1280 720 * 2/ move | dsc
	mpixel camdata 1280 720 * 2* memcpy_avx
	texmem SDL_UnlockTexture
	;	

#proplist
"BRIGHTNESS"
"CONTRAST"
"SATURATION"
"EXPOSURE"
"FOCUS" 
"ZOOM"
0

#propv * 136
#propc * 136
#propi * 136
#val #mi #ma #de #au

:printp
	0 ( 16 <? 
|		0 over 'val 'mi 'ma 'de 'au getCaptureProperty 
		au de 32 << 32 >>  ma 32 << 32 >> mi 32 << 32 >> val 32 << 32 >> "v:%d min:%d max:%d def:%d auto:%d" .println
		1+ ) drop
	;
	
:getprop
	'propv >a	
	'propi >b
	0 ( 16 <? 
|		device over 'val 'mi 'ma 'de 'au getCaptureProperty 
		val 32 << 32 >> a!+
		mi $ffff and 
		ma $ffff and 16 << or
		de $ffff and 32 << or
		au $ffff and 48 << or
		b!+
		1+ ) drop 
	'propc 'propv 17 move ; |dsc
	
:chgprop | n v -- n v
	|device pick2 pick2 0 setCaptureProperty 
	;
	
:changeprop	| -- 0/1
	'propc >b 'propv >a
	0 0 ( 16 <?
		a@+ b@+ <>? ( chgprop rot 1+ -rot ) drop
		1+ ) drop 
	1? ( 'propc 'propv 17 move ) drop
	;

:defgui
	$ffff =? ( 2drop ; ) drop
	16 << 48 >> chgprop drop 
	;
	
:setdef
	'propv >a 'propi >b
	0 ( 16 <?
		b@+ a@+ defgui
		1+ ) drop 
	getprop	;
	
:guilinea
	a@ $ffff =? ( drop ; ) drop
	dup uiLabel
	b@
	dup 48 << 48 >> | min
	swap 32 << 48 >> | max
	a> uiSlideri
|	dup 16 << 48 >> | default
|	swap 48 >> | auto
|	"%d %d" sprint uiLabelc	
	;
	
:guipanel
	uiStart 8 8 uiPading
	0.01 %w uiO
	0.18 %w uiO
	"WEBCAM" uiLabelc
	'camdata 8 + 
	d@+ "%d" sprint uiLabel
	d@+ "%d" sprint uiLabel
	d@+ "%d" sprint uiLabel
	d@+ "%d" sprint uiLabel
	d@+ "%d" sprint uiLabel
	d@ "%d" sprint uiLabel
	
	stdark
|	'propv >a 'propi >b
|	'proplist ( dup c@ 1? drop
|		guilinea
|		8 a+ 8 b+
|		>>0 ) 2drop
	stLink 'setdef "Default" uiRBtn
	stDang 'exit "Exit" uiRBtn
	uiEnd
|	changeprop
	;
	
:main
	0 sdlcls
	1280 2/ 720 2/ tsize texmem spritez
	guipanel		
	sdlredraw
	sdlkey >esc< =? ( exit ) drop
	cam 'camdata webcam_capture 0? ( 
		|setimg |RGB
		setimg2 |YUV2
		) drop
	;


| 
: 
	"ESCAPI demo" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 16 txload 'font !
	font txfont
	
	1280 720 0
	|WEBCAM_FMT_RGB24 
	WEBCAM_FMT_YUYV 
	webcam_open 
	0? ( drop ; ) 'cam !

	here 'camdata !
	1280 720 * 2* 'here +! |YUV
	|1280 720 * 3 * 'here +! |RGB24
|	getprop
	 
	sdlRenderer $32595559 1 1280 720 SDL_CreateTexture 'texmem ! |SDL_PIXELFORMAT_YUV2
	|sdlRenderer $17101803 1 1280 720 SDL_CreateTexture 'texmem ! |rgb24 0x17101803u

	'main sdlshow
	SDLQuit
	;