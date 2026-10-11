| fxdemo.r3 - demo interactivo de fxsynth.r3 (estilo bfxr/jfxr)
| PHREDA 2026 
^r3/util/immi.r3
^r3/audio/fx.r3

#font1

#fxbuff * 44 | 22*2

#fxlistini
#fxlistcnt
#fxlistnow
#fxlist * 2048
#fxlist>

|============================================================
| PRESETS ALEATORIOS ESTILO BFXR
|============================================================
::fxPickup
	fxDefaults
	0 'p_wave !
	0.4 0.9 randminmax 'p_freq !
	0.0 0.1 randminmax 'p_sustain !
	0.3 0.6 randminmax 'p_punch !
	0.1 0.5 randminmax 'p_decay !
	0.0 0.3 randminmax 'p_freqramp !
	0.0 1.0 randminmax 'p_duty ! 
	rand $10000 and? (
		0.5 0.7 randminmax 'p_arpspeed !
		0.05 0.78 randminmax 'p_arpmod !
	) drop ;	
	

::fxLaser
	fxDefaults
	3 randmax 'p_wave !
	0.5 1.0 randminmax 'p_freq !
	p_freq 0.3 - 0.1 clampmin 'p_freqlimit !
	-0.35 -0.15 randminmax 'p_freqramp !
	0.0 1.0 randminmax 'p_duty !
	0.1 0.3 randminmax 'p_sustain !
	0.0 0.4 randminmax 'p_decay !
	0.0 0.3 randminmax 'p_hpffreq ! ;

::fxExplosion
	fxDefaults
	3 'p_wave !
	0.1 0.6 randminmax 'p_freq !
	-0.2 0.2 randminmax 'p_freqramp !
	0.1 0.4 randminmax 'p_sustain !
	0.2 0.8 randminmax 'p_punch !
	0.2 0.6 randminmax 'p_decay !
	0.2 0.9 randminmax 'p_lpffreq ! ;

::fxPowerup
	fxDefaults
	2 randmax 'p_wave !
	0.2 0.5 randminmax 'p_freq !
	0.1 0.3 randminmax 'p_freqramp !
	0.2 0.5 randminmax 'p_sustain !
	0.2 0.5 randminmax 'p_decay !
	0.0 0.3 randminmax 'p_arpmod !
	0.5 0.8 randminmax 'p_arpspeed ! ;

::fxHit
	fxDefaults
	4 randmax 'p_wave !
	0.2 0.8 randminmax 'p_freq !
	-0.7 -0.3 randminmax 'p_freqramp !
	0.0 0.1 randminmax 'p_sustain !
	0.1 0.3 randminmax 'p_decay ! 
	
	0.0 0.3 randminmax 'p_hpffreq !
	;

::fxJump
	fxDefaults
	0 'p_wave !
	0.3 0.6 randminmax 'p_freq !
	0.1 0.3 randminmax 'p_freqramp !
	0.1 0.4 randminmax 'p_sustain !
	0.1 0.3 randminmax 'p_decay !
	0.0 0.6 randminmax 'p_duty ! 
	0.0 0.3 randminmax 'p_hpffreq ! 
	0.4 1.0 randminmax 'p_lpffreq !	
	;

::fxBlip
	fxDefaults
	2 randmax 'p_wave !
	0.2 0.6 randminmax 'p_freq !
	0.03 0.1 randminmax 'p_sustain !
	0.05 0.2 randminmax 'p_decay ! 
	0.1 'p_hpffreq ! ;


|============================================================
| TIPO SFXDEMO: variaciones al azar de los sonidos de sfxpack.r3
|  (frecuencia: Hz = 3528*(p_freq^2+0.001); ramp<0 baja, >0 sube; tiempos: seg = param^2 * 2.27)
|============================================================
:randw | 'tabla n -- onda		| onda al azar de una tabla
	randmax 3 << + @ ;

#wk 0 4 8 2 5		| Sqr Tri SinFold Sin Pul25
#wt 3 17 18 3		| ruidos
#ws 0 5 1 14		| Sqr Pul25 Saw SSaw2
#wg 0 5 2 14 4		| Sqr Pul25 Sin SSaw2 Tri
#ww 2 4 10 12		| Sin Tri HSin Sin3
#wn 0 2 4 11 8		| Sqr Sin Tri Sin2 SinFold
#wl 1 4 14 15 7		| Saw Tri SSaw2 SSaw3 SawRev
#wc 1 16 0 14		| Saw SSawF Sqr SSaw2

::fxKick			| kick / pass / bounce: tono corto que cae (200->70 Hz, 0.09 s)
	fxDefaults
	'wk 5 randw 'p_wave !
	0.18 0.32 randminmax 'p_freq !
	-0.34 -0.2 randminmax 'p_freqramp !
	0.0 0.1 randminmax 'p_sustain !
	0.15 0.22 randminmax 'p_decay !
	0.3 0.6 randminmax 'p_punch !
	0.0 1.0 randminmax 'p_duty ! ;

::fxTackle		| tackle: rafaga de ruido (0.09 s)
	fxDefaults
	'wt 4 randw 'p_wave !
	0.0 0.08 randminmax 'p_sustain !
	0.15 0.22 randminmax 'p_decay !
	0.3 0.8 randminmax 'p_lpffreq !
	0.0 0.1 randminmax 'p_hpffreq ! ;

::fxSave			| save: chirp que sube (500->900 Hz, 0.08 s)
	fxDefaults
	'ws 4 randw 'p_wave !
	0.33 0.43 randminmax 'p_freq !
	0.2 0.32 randminmax 'p_freqramp !
	0.05 0.12 randminmax 'p_sustain !
	0.12 0.2 randminmax 'p_decay !
	0.2 0.4 randminmax 'p_punch !
	0.05 0.2 randminmax 'p_hpffreq ! ;

::fxGoal			| goal: salto de arpegio repetido (do-mi-sol, 0.13 s por nota)
	fxDefaults
	'wg 5 randw 'p_wave !
	0.37 0.45 randminmax 'p_freq !
	0.45 0.62 randminmax 'p_arpmod !
	0.42 0.55 randminmax 'p_arpspeed !
	0.2 0.3 randminmax 'p_repeat !
	0.3 0.42 randminmax 'p_sustain !
	0.25 0.4 randminmax 'p_decay !
	0.2 0.5 randminmax 'p_punch !
	0.0 1.0 randminmax 'p_duty ! ;

::fxWhistle		| whistle: tono agudo sostenido (2300 Hz, 0.15 s)
	fxDefaults
	'ww 4 randw 'p_wave !
	0.72 0.85 randminmax 'p_freq !
	0.0 0.12 randminmax 'p_vibdepth !
	0.1 0.16 randminmax 'p_vibspeed !
	0.22 0.3 randminmax 'p_sustain !
	0.1 0.2 randminmax 'p_decay ! ;

::fxKnock		| knock / bounce: golpe grave que cae (90->40 Hz)
	fxDefaults
	'wn 5 randw 'p_wave !
	0.13 0.2 randminmax 'p_freq !
	-0.3 -0.18 randminmax 'p_freqramp !
	0.05 0.15 randminmax 'p_sustain !
	0.15 0.27 randminmax 'p_decay !
	0.3 0.6 randminmax 'p_punch ! ;

::fxLose			| lose: caida larga (440->110 Hz, 0.6 s)
	fxDefaults
	'wl 5 randw 'p_wave !
	0.3 0.42 randminmax 'p_freq !
	-0.18 -0.12 randminmax 'p_freqramp !
	0.38 0.46 randminmax 'p_sustain !
	0.2 0.3 randminmax 'p_decay !
	0.0 0.2 randminmax 'p_vibdepth !
	0.1 0.2 randminmax 'p_vibspeed ! ;

::fxCrazy		| crazy: barrido que sube con vibrato (160->1200 Hz, 0.45 s)
	fxDefaults
	'wc 4 randw 'p_wave !
	0.15 0.26 randminmax 'p_freq !
	0.17 0.22 randminmax 'p_freqramp !
	0.38 0.46 randminmax 'p_sustain !
	0.2 0.3 randminmax 'p_decay !
	0.2 0.5 randminmax 'p_vibdepth !
	0.2 0.4 randminmax 'p_vibspeed !
	0.0 0.2 randminmax 'p_hpffreq ! ;

#fxall 'fxPickup 'fxLaser 'fxExplosion 'fxPowerup 'fxHit 'fxJump 'fxBlip
'fxKick 'fxTackle 'fxSave 'fxGoal 'fxWhistle 'fxKnock 'fxLose 'fxCrazy

::fxMix			| uno cualquiera de todos los tipos
	15 randmax 3 << 'fxall + @ ex ;

::fxRandom
	fxDefaults
	fxnwaves randmax 'p_wave !
	0.0 0.3 randminmax 'p_attack !
	0.0 0.5 randminmax 'p_sustain !
	0.0 0.5 randminmax 'p_punch !
	0.1 0.6 randminmax 'p_decay !
	0.1 1.0 randminmax 'p_freq !
	-0.5 0.5 randminmax 'p_freqramp !
	0.0 0.5 randminmax 'p_vibdepth !
	0.0 0.5 randminmax 'p_vibspeed !
	-0.5 0.5 randminmax 'p_arpmod !
	0.0 1.0 randminmax 'p_duty !
	0.2 1.0 randminmax 'p_lpffreq !
	0.0 0.5 randminmax 'p_hpffreq ! 
	
	0.0 0.5 randminmax 'p_repeat !
	;
	
|---- fx list
:setlist | n --
	dup 'fxlistnow !
	'fxbuff over 44 * 'fxlist + 44 cmove
	'fxbuff fxUnpack
	fxStop fxPlay
	;
	
:putlist
	'fxbuff fxpack
	fxlist> 'fxbuff 44 cmove
	44 'fxlist> +!
	1 'fxlistcnt +!
	;
	
:remlist
	;
	
:listfx
	stLink
	0 ( fxlistcnt <?
		fxlistnow =? ( stInfo ) 
		'setlist over "%h" sprint uiRbtn
		fxlistnow =? ( stLink ) 
		1+ ) drop ;
	
:seedPanel
	uiPush
	0.12 %w uiO
	stSucc 
	'putlist         "Save"  uiCBtn
	stinfo
	[ 'fxbuff fxUnpack fxPlay ; ]  "Load"   uiCBtn
	stDang
	'remlist "Delete" uiCBtn
	uiRest
	'fxbuff @+ swap @+ swap @ "$%h $%h $%h.." sprint 
	$11 uiText |Label
	uiPop
	;

#wavelist "Sqr" "Saw" "Sin" "Nse" "Tri" "Pul25" "Pul10" "SawRev" "SinFold" "Trap" "HSin" "Sin2" "Sin3" "Parab" "SSaw2" "SSaw3" "SSawF" "Pink" "Brown"

:wavename | n -- "str"
	'wavelist swap ( 1? 1- swap >>0 swap ) drop ;

:wavebtns
	2 2 uiPading
	8 3 uiGrid
	0 ( fxnwaves <?
		p_wave =? ( stWarn )
		[ dup 'p_wave ! fxPlay ; ] over wavename uiCBtn
		p_wave =? ( stLink )
		uiNext
		1+ ) drop ;
		
:exPlay
	uiEx? 1? ( fxStop fxPlay ) drop	;
	
|---- tipos al azar parecidos a los sonidos de sfxdemo
:game
	$0 cls

	uiStart
	8 2 uiPading
	font1 txfont

	0.05 %h uiN
	"FX Generator" uiLabelC
	ui--
	
	0.2 %w uiO
	uiPush
	txh 2 + 5 * uiN		| Play .. "* Wave *": 11 filas; abajo la grilla de ondas
	stSucc [ fxPlay ; ]             "Play"    uiCBtn
	stDang [ fxRandom fxPlay ; ]    "Random"        uiCbtn
	stLink 
	"* Type *" uiLabelC
	[ fxPickup fxPlay ; ]    "Pickup / Coin" uiRbtn
	[ fxLaser fxPlay ; ]     "Laser / Shoot" uiRbtn
	[ fxExplosion fxPlay ; ] "Explosion"     uiRbtn
	[ fxPowerup fxPlay ; ]   "Powerup"       uiRbtn
	[ fxHit fxPlay ; ]       "Hit / Hurt"    uiRbtn
	[ fxJump fxPlay ; ]      "Jump"          uiRbtn
	[ fxBlip fxPlay ; ]      "Blip / Select" uiRbtn
	[ fxKick fxPlay ; ]    "Kick / Pass"    uiRbtn 
	[ fxTackle fxPlay ; ]  "Tackle"         uiRbtn 
	[ fxSave fxPlay ; ]    "Save"           uiRbtn 
	[ fxGoal fxPlay ; ]    "Goal"           uiRbtn 
	[ fxWhistle fxPlay ; ] "Whistle"        uiRbtn 
	[ fxKnock fxPlay ; ]   "Knock"          uiRbtn 
	[ fxLose fxPlay ; ]    "Lose / Fall"    uiRbtn 
	[ fxCrazy fxPlay ; ]   "Crazy"          uiRbtn 
	[ fxMix fxPlay ; ]     "Mix (all)"    uiRbtn  
	uiPop

	|---- zona central: parametros (dos columnas etiquetas | sliders) arriba, tipos sfx abajo
	0.7 %w uiO
	uiPush
	txh 2 + 16 * uiN
	uiPush
	0.12 %w uiO
	"* Envelope *" uiLabelC
	"Attack " uiLabelR
	"Sustain " uiLabelR
	"Punch " uiLabelR
	"Decay " uiLabelR
	"* Frequency *" uiLabelC
	"Freq " uiLabelR
	"Min.Freq " uiLabelR
	"Slide " uiLabelR
	"D.Slide " uiLabelR
	"* Vibrato *" uiLabelC
	"Vib.Depth " uiLabelR
	"Vib.Speed " uiLabelR
	"* Arpeggio *" uiLabelC
	"Arp.Amount " uiLabelR
	"Arp.Speed " uiLabelR

	0.23 %w uiO
	ui..
	0.0 1.0 'p_attack uiSliderf		exPlay
	0.0 1.0 'p_sustain uiSliderf	exPlay
	0.0 1.0 'p_punch uiSliderf		exPlay
	0.0 1.0 'p_decay uiSliderf		exPlay
	ui..
	0.0 1.0 'p_freq uiSliderf		exPlay
	0.0 1.0 'p_freqlimit uiSliderf	exPlay
	-1.0 1.0 'p_freqramp uiSliderf	exPlay
	-1.0 1.0 'p_freqdramp uiSliderf	exPlay
	ui..
	0.0 1.0 'p_vibdepth uiSliderf	exPlay
	0.0 1.0 'p_vibspeed uiSliderf	exPlay
	ui..
	-1.0 1.0 'p_arpmod uiSliderf	exPlay
	0.0 1.0 'p_arpspeed uiSliderf	exPlay

	0.12 %w uiO
	"* Duty *" uiLabelC
	"Duty " uiLabelR
	"Duty.Sweep " uiLabelR
	"* Filters *" uiLabelC
	"LowPass " uiLabelR
	"LP.Sweep " uiLabelR
	"LP.Reso " uiLabelR
	"HighPass " uiLabelR
	"HP.Sweep " uiLabelR
	"* Output *" uiLabelC
	"Repeat " uiLabelR
	"Volume " uiLabelR

	0.23 %w uiO
	ui..
	0.0 1.0 'p_duty uiSliderf		exPlay
	-1.0 1.0 'p_dutyramp uiSliderf	exPlay
	ui..
	0.0 1.0 'p_lpffreq uiSliderf 	exPlay
	-1.0 1.0 'p_lpframp uiSliderf	exPlay
	0.0 1.0 'p_lpfreso uiSliderf	exPlay
	0.0 1.0 'p_hpffreq uiSliderf 	exPlay
	-1.0 1.0 'p_hpframp uiSliderf	exPlay
	ui..
	0.0 1.0 'p_repeat uiSliderf 	exPlay
	0.0 1.0 'p_vol uiSliderf		exPlay
	uiPop
	
	txh 2 + 3 * uiN
	|ui-- "* Wave *" uiLabelC
	|uiRest
	wavebtns
	uiPop

	uiRest
	listfx
	
	fxUpdate

	uiEnd
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;

:
	"FX Generator" 1024 760 SDLinitR
	fxAudioInit
	"media/ttf/Roboto-Medium.ttf" 20 txload 'font1 !

	fxDefaults
	'fxbuff fxPack
	
	'fxlist 'fxlist> !
	0 'fxlistcnt !
	putlist
	'game SDLshow
	SDLquit ;
