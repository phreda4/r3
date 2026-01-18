| ChipA - strudel sudaca
| PHREDA 2026

^r3/lib/sdl2gfx.r3
^r3/util/immi.r3
^r3/util/imedit.r3
^r3/util/varanim.r3

^./supermix.r3
^./eval.r3

^r3/lib/trace.r3

#font1
#font2

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
		swap 16 >> $7fff + 10 >> $3f and cy + 32 + SDLPoint
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


#i0 #i1 #i2 #i3

:splay
	dup @+ swap @ swap | get 2 params
	smplayd ;
	
:genevt | note dur start --
	|". " .print .flush
	'splay swap +vvvexe ;
	 
:generate
	eval
	1 'ccycle +!
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
	fuente 
	trim dup c@ 0? ( 2drop ; ) drop
|	dup .println .flush
	process | str --
	0 'ccycle !
	1 'run !
	vareset
	cicle ;

	
:stop
	vareset
	0 'run ! ;
	
:debug1
	0 'tokens ( tokens> <?
		mark
		swap dup "%h: " ,print 1+ swap
		@+ 	"| %h " ,print
		dup 8 - tok>ext @ " %h" ,print
		|drop 
		,eol
		empty here uiLabel
		) 2drop ;

:debug2
	tokens> 'tokens - "%h " sprint uiLabel
	list> 'list - "%h " sprint uiLabel
	stack> 'stack - "%h" sprint uiLabel
	voice> 'voice - "sm voice %h" sprint uiLabel
	timeline> timeline - 3 >> "timeline %d" sprint uiLabel
	|#timeline<	
	
	;

#listi oscSaw oscSqr oscPul1 oscPul2 oscTri oscSin oscFakeSuperSaw oscSuperSaw3P 
#listex "Saw" "Sqr" "Pull1" "Pull2" "Tri" "Sin" "FSuperSaw" "SuperSaw" 0

#vins 0 0 | instrument
:setInst
	vins 3 << 'listi + @ i0 smOSC! 
	i0 smi! ;
	
|-----------------------------
:gui
	|font1 txfont
	uiStart
	4 4 uiPading
	$ffffff sdlcolor
	
	0.05 %h uiN $004800 sdlcolor uiWinBox sdlFrect
	"r3ChipA - [f1] eval+play [f2] stop [esc] exit" uiLabel
	
	0.02 %h uiS
	
	0.01 %w uiO
	0.6 %w uiO $181818 sdlcolor uiWinBox sdlFrect
	font2 txfont
	uiWinBox edwin 
	edfocus
	edcodedraw
	
	0.2 %w uiO $484848 sdlcolor uiWinBox sdlFrect
	stLink 
	font1 txfont
	
	"BPM" uiLabel
	20 300 'bpm uiSlideri 
	uiEx? 1? ( 240.0 bpm / 'cyclesec ! ) drop
	cyclesec "%fsec" sprint uiLabelC
	
	'vins 'listex uiCombo
	uiEx? 1? ( setInst ) drop

	'gencycle "Play" uiRBtn 
	'stop "Stop" uiRBtn 
	stDang 'exit "Exit" uiRBtn 
	stInfo
	
	drawbuffer
	
	uiRest
	$181818 sdlcolor uiWinBox sdlFrect
	debug2

	"Voices" uiLabel
	
	uiEnd
	;

#ex1 |"< {a b c } {d e f} > a ~ " 
"<[g4*0.75 g4*0.25 a4 g4 c5 b4]
[g4*0.75 g4*0.25 a4 g4 d5 c5]
[g4*0.75 g4*0.25 g5 e5 c5 b4 a4]
[f5*0.75 f5*0.25 e5 c5 d5 c5] ~>"

#ex2
"{<
[e5 [b4 c5] d5 [c5 b4]]
[a4 [a4 c5] e5 [d5 c5]]
[b4 [~ c5] d5 e5]
[c5 a4 a4 ~]
[[~ d5] [~ f5] a5 [g5 f5]]
[e5 [~ c5] e5 [d5 c5]]
[b4 [b4 c5] d5 e5]
[c5 a4 a4 ~]
>
<
[[e2 e3]*4]
[[a2 a3]*4]
[[g#2 g#3]*2 [e2 e3]*2]
[a2 a3 a2 a3 a2 a3 b1 c2]
[[d2 d3]*4]
[[c2 c3]*4]
[[b1 b2]*2 [e2 e3]*2]
[[a1 a2]*4]
>}"
	
:main
	$0 SDLcls
	gui	
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( gencycle )
	<f2> =? ( stop )
	<f4> =? ( 'ex1 edloadmem )
	<f5> =? ( 'ex2 edloadmem )
	drop 
	vupdate
	smupdate
	;

||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
:
	"Chipa" 1024 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 18 txloadwicon 'font1 !
	"media/ttf/RobotoMono-Bold.ttf" 22 txload 'font2 !
	
	edram
	
	sminit
	$fff vaini

	0.002 0.05 0.8 0.1 packADSR 'oscSin iosc 'i0 !
|	0.002 0.01 0.8 0.1 packADSR 'oscSuperSaw3P iosc 'i1 !
|	0.01 0.01 0.8 0.2 packADSR 'bnoise inoise 'i2 !
|	0.001 0.01 0.8 0.2 packADSR "media/snd/piano-C.mp3" isample 'i3 !
	i0 smI! 
	
	"" edloadmem
	
	'main SDLshow
	SDLquit 
;
