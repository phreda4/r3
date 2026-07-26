| fxdemo.r3 - demo interactivo de fxsynth.r3 (estilo bfxr/jfxr)
| PHREDA-style - GUI immi.r3 v3
^r3/util/immi.r3
^r3/audio/fx.r3

#font1
#seedbuf * 256

:presetsPanel
	stLink [ fxPickup fxPlay ; ]    "Pickup / Coin" uiBtn
	stLink [ fxLaser fxPlay ; ]     "Laser / Shoot" uiBtn
	stLink [ fxExplosion fxPlay ; ] "Explosion"     uiBtn
	stLink [ fxPowerup fxPlay ; ]   "Powerup"       uiBtn
	stLink [ fxHit fxPlay ; ]       "Hit / Hurt"    uiBtn
	stLink [ fxJump fxPlay ; ]      "Jump"          uiBtn
	stLink [ fxBlip fxPlay ; ]      "Blip / Select" uiBtn
	stDang [ fxRandom fxPlay ; ]    "Random"        uiBtn
	ui--
	stSucc [ fxPlay ; ]             "Reproducir"    uiBtn
	;

|---- botones de onda: solo cambian p_wave y vuelven a tocar, sin tocar el resto
:wavebtns
	stLink [ 0 'p_wave ! fxPlay ; ] "Cuadrada"  uiBtn
	stLink [ 1 'p_wave ! fxPlay ; ] "Sierra"    uiBtn
	stLink [ 2 'p_wave ! fxPlay ; ] "Seno"      uiBtn
	stLink [ 3 'p_wave ! fxPlay ; ] "Ruido"     uiBtn
	stLink [ 4 'p_wave ! fxPlay ; ] "Triangulo" uiBtn
	;

:paramsLeft
	p_freq .f2 "Freq %s" sprint uiLabelC
	p_attack .f2 "Ataque %s" sprint uiLabelC	
	p_sustain .f2 "Sosten %s" sprint uiLabelC
	p_punch .f2 "Punch %s" sprint uiLabelC
	p_decay .f2 "Decay %s" sprint uiLabelC
	p_freqramp .f2 "Ramp %s" sprint uiLabelC
	p_duty .f2 "Duty %s" sprint uiLabelC
	
	p_vibdepth .f2 "Vib.Prof %s" sprint uiLabelC
	p_vibspeed .f2 "Vib.Vel %s" sprint uiLabelC
	p_lpffreq .f2 "LowPass %s" sprint uiLabelC
	p_hpffreq .f2 "HighPass %s" sprint uiLabelC
	p_repeat .f2 "Repetir %s" sprint uiLabelC
	p_vol .f2 "Volumen %s" sprint uiLabelC
	
	;

:paramsRight
	0.0 1.0 'p_freq uiSliderf
	0.0 1.0 'p_attack uiSliderf
	0.0 1.0 'p_sustain uiSliderf
	0.0 1.0 'p_punch uiSliderf
	0.0 1.0 'p_decay uiSliderf
	-1.0 1.0 'p_freqramp uiSliderf
	0.0 1.0 'p_duty uiSliderf
	0.0 1.0 'p_vibdepth uiSliderf
	0.0 1.0 'p_vibspeed uiSliderf
	0.0 1.0 'p_lpffreq uiSliderf
	0.0 1.0 'p_hpffreq uiSliderf
	0.0 1.0 'p_repeat uiSliderf
	0.0 1.0 'p_vol uiSliderf
	;

:seedPanel
	uiPush
	0.12 %w uiO
	stSucc [ 'seedbuf fxSave ; ]         "Guardar"  uiBtn
	stWarn [ 'seedbuf fxLoad fxPlay ; ]  "Cargar"   uiBtn
	uiRest
	'seedbuf $11 uiText |Label
	uiPop
	;

:game
	$0 SDLcls

	uiStart
	2 1 uiPading
	font1 txfont

	0.1 %h uiN
	"FX Generator" uiLabelC
	ui--	
	
	0.1 %h uiS 	
	ui--
	seedPanel
	
	0.2 %w uiO
	presetsPanel
	ui--
	wavebtns

	0.3 %w uiO
	paramsLeft
	
	0.3 %w uiO
	paramsRight

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
	'seedbuf fxSave
	'game SDLshow
	SDLquit ;
