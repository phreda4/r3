| test supermix
| PHREDA 2025
^r3/lib/sdl2gfx.r3
^r3/rimm/rimmsdl.r3
^r3/rimm/rimmwid.r3
^r3/util/varanim.r3

^./supermix.r3

^r3/lib/trace.r3

:drawbuffer
	$ffffff color
	'outbuffer >a 
	0 ( 1024 <? 1+
		da@+
		over 0 +
		over $7fff + 10 >> $3f and 200 + point
		over 0 +
		swap 16 >> $7fff + 10 >> $3f and 400 + point
		) drop ;	
		
|------------ keys
#playn * 100 

:keydn | note --
	dup 'playn + c@ 1? ( 2drop ; ) drop 
	dup smplay 'playn + c! ;

:keyup | note --
	dup 'playn + c@ 0? ( 2drop ; )
	0 over 'playn + c! 
	smstop ;
	
#i0 #i1 #i2 #i3

:debug
	'voice
	@ "%h" txprint
	;
	
:main
	vupdate
	$0 cls
	drawbuffer
	10 0 txat
	voice> 'voice - "sm voice %h" sprint txprint
	10 20 txat
	debug
	
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<a> =? ( 60 keydn ) <s> =? ( 62 keydn ) <d> =? ( 64 keydn ) <f> =? ( 65 keydn )
	<g> =? ( 67 keydn ) <h> =? ( 69 keydn ) <j> =? ( 71 keydn )
	>a< =? ( 60 keyup ) >s< =? ( 62 keyup ) >d< =? ( 64 keyup ) >f< =? ( 65 keyup )
	>g< =? ( 67 keyup ) >h< =? ( 69 keyup ) >j< =? ( 71 keyup )
	<f1> =? ( 30 0.25 smplayd )
	<f2> =? ( i0 smI! 31 0.25 smplayd )
	<f3> =? ( i1 smI! 31 0.25 smplayd )
	<f4> =? ( 34 0.5 smplayd 36 0.5 smplayd 39 0.5 smplayd )
	<z> =? ( i3 smi! 69 1.0 smplayd )
	<x> =? ( i3 smi! 73 1.0 smplayd )
	<c> =? ( i3 smi! 76 1.0 smplayd )
	<v> =? ( i2 smI! 60 1.0 smplayd )
	drop 
	smupdate
	;

#font1

:
	"supermix" 1024 600 SDLinit
	"media/ttf/Roboto-bold.ttf" 18 txload 'font1 ! |wicon 'font1 !
	font1 txfont	
	sminit
	$fff vaini


	0.002 0.05 0.7 0.1 packADSR 'oscSinF iosc 'i0 !
	0.002 0.01 0.8 0.1 packADSR 'oscSaw iosc 'i1 !
	0.01 0.01 0.8 0.2 packADSR 'oscBrown iosc 'i2 !
	0.001 0.01 0.8 0.2 packADSR "media/snd/piano-C.mp3" isample 'i3 !
	i0 smI!
	
	'main SDLshow
	SDLquit 
;
