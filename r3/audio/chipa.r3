| ChipA - strudel sudaca
| PHREDA 2026

^r3/lib/sdl2gfx.r3
^r3/util/immi.r3
^r3/util/imedit.r3

^./chipalib.r3

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
	$ffffff color
	'outbuffer >a 
	0 ( cw <? 1+
		da@+ 
		over cx +
		over $7fff + 10 >> $3f and cy + point
		over cx +
		swap 16 >> $7fff + 10 >> $3f and cy + 32 + point
		) drop ;	
		
|------------ musica: chipalib (motor de gamesfx: eval.r3 + smtick/smplayhz, precision de muestra)
|  Play evalua el texto: si ya suena, el patron nuevo entra en el proximo ciclo y sigue el compas
#bpm 120

:play
	fuente trim dup c@ 0? ( 2drop ; ) drop
	bpm cpplay ;

:stop
	cpstop ;

:restart
	cpstop play ;

:debug2
	cpcycle "cycle %d" sprint uiLabel
	cpplaying "playing %d" sprint uiLabel
	stack> 'stack - 3 >> "events %d" sprint uiLabel
	voice> 'voice - 6 >> "voices %d" sprint uiLabel ;

|-----------------------------
:ap | --			| aplica los parametros si el ultimo widget cambio
	uiEx? 1? ( cpapply ) drop ;

:gui
	|font1 txfont
	uiStart
	4 4 uiPading
	$ffffff color
	
	0.05 %h uiN $004800 color uiWinBox frect
	"r3ChipA - [f1] play/eval [f2] stop [f3] restart [esc] exit" uiLabel
	
	0.02 %h uiS
	
	0.01 %w uiO
	0.6 %w uiO $181818 color uiWinBox frect
	font2 txfont
	uiWinBox edwin 
	edfocus
	edcodedraw
	
	0.2 %w uiO $484848 color uiWinBox frect
	stLink 
	font1 txfont
	
	"BPM" uiLabel
	20 300 'bpm uiSlideri 
	uiEx? 1? ( bpm cpbpm ) drop
	240.0 bpm / "%fsec" sprint uiLabelC
	
	'play "Play" uiRBtn 
	'stop "Stop" uiRBtn 
	'restart "Restart" uiRBtn 
	stDang 'exit "Exit" uiRBtn 
	stInfo
	
	drawbuffer
	
	uiRest
	$181818 color uiWinBox frect
	
	"* Instrument *" uiLabelC
	"Wave" uiLabel
	'cp_wave 'cp_wnames uiCombo ap
	"Attack" uiLabel
	0.0 1.0 'cp_a uiSliderf ap
	"Decay" uiLabel
	0.0 2.0 'cp_d uiSliderf ap
	"Sustain" uiLabel
	0.0 1.0 'cp_s uiSliderf ap
	"Release" uiLabel
	0.0 3.0 'cp_r uiSliderf ap
	"Volume" uiLabel
	0.0 2.0 'cp_vol uiSliderf ap
	"Curve" uiLabel
	0 3 'cp_crv uiSlideri ap
	"Detune" uiLabel
	0.0 0.05 'cp_detune uiSliderf ap
	
	debug2
	
	uiEnd
	;

#ex1 |"< {a b c } {d e f} > a ~ " 
"<[g4@0.75 g4@0.25 a4 g4 c5 b4]
[g4@0.75 g4@0.25 a4 g4 d5 c5]
[g4@0.75 g4@0.25 g5 e5 c5 b4 a4]
[f5@0.75 f5@0.25 e5 c5 d5 c5] ~>"

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
	$0 cls
	gui	
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( play )
	<f2> =? ( stop )
	<f3> =? ( restart )
	<f4> =? ( 'ex1 edloadmem )
	<f5> =? ( 'ex2 edloadmem )
	drop 
	cpupdate
	;

||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
:
	"Chipa" 1024 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 18 txloadwicon 'font1 !
	"media/ttf/RobotoMono-Bold.ttf" 22 txload 'font2 !
	
	edram
	
	cpinit0
	
	"" edloadmem
	
	'main SDLshow
	SDLquit 
;
