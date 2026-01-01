| test supermix
| PHREDA 2025
^r3/lib/sdl2gfx.r3
^r3/util/immi.r3
^r3/util/varanim.r3

^./supermix.r3

#i0 #i1 #i2

:drawbuffer
	$ffffff sdlcolor
	'outbuffer >a 
	0 ( 1024 <? 1+
		da@+
		over 0 +
		over $7fff + 10 >> $3f and 200 + SDLPoint
		over 0 +
		swap 16 >> $7fff + 10 >> $3f and 400 + SDLPoint
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
	
#tk * 127

:main
	vupdate
	$0 SDLcls
	drawbuffer
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<a> =? ( 0 keydn )
	>a< =? ( 0 keyup )
	<f1> =? ( 0 0.25 smplayd )
	<f2> =? ( i0 smI! 1 0.25 smplayd )
	<f3> =? ( i1 smI! 2 0.25 smplayd )
	<f4> =? ( 4 0.5 smplayd 6 0.5 smplayd 9 0.5 smplayd i2 smI! 0 0.6 smplayd )
	drop 
	smupdate
	;

:
	"supermix" 1024 600 SDLinit
	sminit
	$fff vaini


	0.001 0.1 'oscSin iosc 'i0 !
	0.002 0.1 'oscSaw iosc 'i1 !
	0.001 0.2 'bnoise inoise 'i2 !
|	"media/snd/piano-C.mp3" isample 'i1 !
|	'wnoise inoise 'i2 !
	i0 smI!
	
	'main SDLshow
	SDLquit 
;
