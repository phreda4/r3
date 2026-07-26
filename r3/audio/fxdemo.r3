| fxdemo.r3 - demo interactivo de fxsynth.r3 (estilo bfxr/jfxr)
| PHREDA-style - GUI immi.r3 v3
^r3/util/immi.r3
^r3/audio/fx.r3

#font1

#fxbuff * 46 | 1+22*2

#fxlist * 1024
#fxlist>

:presetsPanel
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

	;

|---- botones de onda: solo cambian p_wave y vuelven a tocar, sin tocar el resto
:wavebtns
	stLink [ 0 'p_wave ! fxPlay ; ] "Square" uiCBtn
	stLink [ 1 'p_wave ! fxPlay ; ] "Saw"    uiCBtn
	stLink [ 2 'p_wave ! fxPlay ; ] "Sin"    uiCBtn
	stLink [ 3 'p_wave ! fxPlay ; ] "Noise"  uiCBtn
	stLink [ 4 'p_wave ! fxPlay ; ] "Trig"   uiCBtn
	;

:paramsLeft
	"Freq " uiLabelR
	"Ataque " uiLabelR	
	"Sosten " uiLabelR
	"Punch " uiLabelR
	"Decay " uiLabelR
	"Ramp " uiLabelR
	"Duty " uiLabelR
	"Vib.Prof " uiLabelR
	"Vib.Vel " uiLabelR
	"LowPass " uiLabelR
	"HighPass " uiLabelR
	"Repetir " uiLabelR
	"Volumen " uiLabelR
	;

:paramsRight
	0.0 1.0 'p_freq uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_attack uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_sustain uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_punch uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_decay uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	-1.0 1.0 'p_freqramp uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_duty uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_vibdepth uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_vibspeed uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_lpffreq uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_hpffreq uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_repeat uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	0.0 1.0 'p_vol uiSliderf
	uiEx? 1? ( fxStop fxPlay ) drop
	;

:setlist
	;
	
:putlist
	'fxbuff fxpack
	fxlist> 'fxbuff 56 cmove
	56 'fxlist> +!
	;
:listfx
	stLink
	'fxlist
	( fxlist> <?
		'setlist over "%h" sprint uiRbtn
		56 + ) drop
	;
	
:seedPanel
	uiPush
	0.12 %w uiO
	
	stSucc 'putlist         "Save"  uiCBtn
	stWarn [ 'fxbuff fxunpack fxPlay ; ]  "Load"   uiCBtn
	uiRest
	'fxbuff @+ swap @+ swap @ "$%h $%h $%h.." sprint 
	$11 uiText |Label
	uiPop
	;

:game
	$0 SDLcls

	uiStart
	8 2 uiPading
	font1 txfont

	0.1 %h uiN
	"FX Generator" uiLabelC
	ui--	
	
	0.1 %h uiS 	
	seedPanel
	
	0.2 %w uiO
	presetsPanel
	"* Wave *" uiLabelC
	wavebtns

	0.2 %w uiO
	paramsLeft
	
	0.3 %w uiO
	paramsRight

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
	'game SDLshow
	SDLquit ;
