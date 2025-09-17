| https://github.com/jarikomppa/escapi
| lib for webcam

^r3/lib/sdl2gfx.r3	
^r3/util/txfont.r3
^r3/util/ui.r3
^r3/lib/escapi.r3
^r3/lib/rand.r3
^r3/lib/memavx.r3

#font
|-------------------
#device
#capture 0 [ 1280 720 ]
#texmem
#tsize 0.6
#mpixel #mpitch

:setimg
	texmem 0 'mpixel 'mpitch SDL_LockTexture
	|mpixel capture 1280 720 * 2/ move | dsc
	mpixel capture 1280 720 * 2 << memcpy_avx
	texmem SDL_UnlockTexture
	device doCapture
	;

#proplist
"BRIGHTNESS"
"CONTRAST"
"HUE"
"SATURATION"
"SHARPNESS"
"GAMMA"
"COLORENABLE"
"WHITEBALANCE"
"BACKLIGHTCOMP"
"GAIN"
"PAN"
"TILT"
"ROLL"
"ZOOM"
"EXPOSURE"
"IRIS" 0
"FOCUS" 0

#propv * 136
#propc * 136
#propi * 136
#val #mi #ma #de #au

:printp
	0 ( 16 <? 
		0 over 'val 'mi 'ma 'de 'au getCaptureProperty 
		au de 32 << 32 >>  ma 32 << 32 >> mi 32 << 32 >> val 32 << 32 >> "v:%d min:%d max:%d def:%d auto:%d" .println
		1+ ) drop
	;
	
:getprop
	'propv >a	
	'propi >b
	0 ( 16 <? 
		device over 'val 'mi 'ma 'de 'au getCaptureProperty 
		val 32 << 32 >> a!+
		mi $ffff and 
		ma $ffff and 16 << or
		de $ffff and 32 << or
		au $ffff and 48 << or
		b!+
		1+ ) drop 
	'propc 'propv 17 move ; |dsc
	
:chgprop | n v -- n v
	device pick2 pick2 0 setCaptureProperty ;
	
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
	dup uiLabelR
	b@
	dup 48 << 48 >> | min
	swap 32 << 48 >> | max
	a> uiSlideri
|	dup 16 << 48 >> | default
|	swap 48 >> | auto
|	"%d %d" sprint uiLabelc	
	;
	
:guipanel
	uiStart
	3 2 uiPad
	0.01 %w 0.05 %h 0.3 %w 0.6 %h uiWin!
	3 18 uiGridA uiH
	"WEBCAM" uiLabelc
	stLink 'setdef "Default" uiRBtn
	stDang 'exit "Exit" uiRBtn
	2 18 uiGridA uiH
	0 1 uiGat
	stdark
	'propv >a 'propi >b
	'proplist ( dup c@ 1? drop
		guilinea
		8 a+ 8 b+
		>>0 ) 2drop
	
	uiEnd
	changeprop
	;
	
:main
	0 sdlcls
	1280 2/ 720 2/ tsize texmem spritez
	guipanel		
	sdlredraw
	sdlkey >esc< =? ( exit ) drop
	device isCaptureDone 1? ( setimg ) drop 
	;


| 
: 
	"ESCAPI demo" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 16 txload 'font !
	font txfont
	
	setupESCAPI 1 <? ( "Unable to init ESCAPI" .println ) drop |'maxdevice !
	0 'device !
	
	1280 720 SDLframebuffer 'texmem !
	here 'capture !
	1280 720 * 4 * 'here +!
	device 'capture initCapture drop |"%d" .println
	getprop
|	printp	

	device doCapture
	'main sdlshow
	SDLQuit
	;