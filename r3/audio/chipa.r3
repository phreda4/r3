| chipa - strudel sudaca
| PHREDA 2026

^r3/lib/sdl2gfx.r3
^r3/util/immi.r3
^r3/util/varanim.r3

^./supermix.r3
^./eval.r3

^r3/lib/trace.r3

#font1

|------------
#kit909
"909CX BD1" "909CX BD2" "909CX BD3"
"909CX SN1" "909CX SN2" "909CX SN3" 
"909CX CHH" "909CX CP1"
"909CX CS1" "909CX CS2"
"909CX FTH" "909CX FTL"
"909CX HTH" "909CX HTL"
"909CX MTH" "909CX MTL"
"909CX OHH" "909CX PHH"
"909CX RD2" "909CX RM1" 0
|		dup "media/snd/909/%s.mp3" sprint 

#kit808
"808_2" "808_3" "808_4" "808_5" "808_6" "808_7"
"808_C" "808_K" "808_O" "808_R" "808_S" 0
|		dup "media/snd/808/%s.mp3" sprint 

|-----------
:drawbuffer
	$ffffff sdlcolor
	'outbuffer >a 
	0 ( cw <? 1+
		da@+ 
		over cx +
		over $7fff + 10 >> $3f and cy + SDLPoint
		over cx +
		swap 16 >> $7fff + 10 >> $3f and cy + ch 2/ + SDLPoint
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
	
|------------ eval
#bpm 120
#cyclesec 2.0 | 240/bpm bmp=120

#run 0

#pad "a b [c d] e? f " * 256

#i0 #i1 #i2 #i3

:splay
	dup @+ swap @ swap smplayd ;
	
:genevt | note dur start --
	'splay swap +vvvexe ;
	 
:generate
	1 'ccycle +!
	eval
	'stack ( stack> <?
		@+
		dup 32 >>
		over $ffff and cyclesec *.
		rot 16 >> $ffff and cyclesec *.
		genevt
		|"%f %f %d" .println .flush
		) drop ;
	
:cicle
	run 0? ( drop ; ) drop
	generate
	'cicle cyclesec  +vexe
	;

:gencycle
	'pad .println
	"----" .println .flush
|	"a b [c d] " 
	'pad 
	
	process | str --
	0 'ccycle !
	1 'run !
	cicle
	;

:play
	1 'run !
	cicle ;
	
:stop
	0 'run ! ;
	
|-----------------------------
:gui
	font1 txfont
	uiStart
	4 4 uiPading
	$ffffff sdlcolor
	
	0.1 %w uiO
	stLink "* Chipa *" uiLabelC
	
	"BPM" uiLabel
	20 300 'bpm uiSlideri 
	|uiEx? 1? ( 240.0 bpm / 'cyclesec ! ) drop
	
	cyclesec "%f" sprint uiLabelC
	
	'play "Play" uiRBtn 
	'stop "Stop" uiRBtn 
	stDang 'exit "Exit" uiRBtn 
	
	0.1 %h uiN
	uiPush
	0.5 %w uiO
	"R3code music" $11 uiText
	uiRest
	|drawbuffer
	uiPop
	
	0.1 %h uiS

	0.6 %w uiO
	'pad 64 uiInputLine
	uiEx? 1? ( gencycle ) drop
	
	uiRest
	"Voices" uiLabel
	
	uiEnd
	;
	
:main
	vupdate
	$0 SDLcls
	gui	
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
|	<a> =? ( 0 keydn )
|	>a< =? ( 0 keyup )
	<f1> =? ( generate )
|	<f2> =? ( i0 smI! 1 0.25 smplayd )
|	<f3> =? ( i1 smI! 1 0.25 smplayd )
|	<f4> =? ( 4 0.5 smplayd 6 0.5 smplayd 9 0.5 smplayd )
|	<z> =? ( i3 smi! 0 1.0 smplayd )
|	<x> =? ( i3 smi! 1 1.0 smplayd )
|	<c> =? ( i3 smi! 2 1.0 smplayd )
|	<v> =? ( i2 smI! 2 1.0 smplayd )
	drop 
	smupdate
	;

:
	"Chipa" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 18 txloadwicon 'font1 !

	sminit
	$fff vaini


	0.002 0.05 0.7 0.1 packADSR 'oscSinF iosc 'i0 !
	0.002 0.01 0.8 0.1 packADSR 'oscSuperSaw2P iosc 'i1 !
	0.01 0.01 0.8 0.2 packADSR 'bnoise inoise 'i2 !
	0.001 0.01 0.8 0.2 packADSR "media/snd/piano-C.mp3" isample 'i3 !
	i0 smI!
	
	'main SDLshow
	SDLquit 
;
