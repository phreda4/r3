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

::fxRandom
	fxDefaults
	5 randmax 'p_wave !
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
	2 11 uiGrid
	0 ( fxnwaves <?
		p_wave =? ( stInfo )
		[ dup 'p_wave ! fxPlay ; ] over wavename uiCBtn
		p_wave =? ( stLink )
		uiNext
		1+ ) drop ;
		
:exPlay
	uiEx? 1? ( fxStop fxPlay ) drop	;
	
:game
	$0 cls

	uiStart
	8 2 uiPading
	font1 txfont

	0.1 %h uiN
	"FX Generator" uiLabelC
	ui--	
	
	0.14 %h uiS 	
	seedPanel
	
	0.2 %w uiO
	uiPush
	txh 2 + 11 * uiN		| Play .. "* Wave *": 11 filas; abajo la grilla de ondas
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
	"* Wave *" uiLabelC
	uiRest
	wavebtns
	uiPop

	|---- parametros, dos columnas (etiquetas | sliders); una fila de titulo por grupo
	0.115 %w uiO
	"* Envolvente *" uiLabelC
	"Ataque " uiLabelR
	"Sosten " uiLabelR
	"Punch " uiLabelR
	"Decay " uiLabelR
	"* Frecuencia *" uiLabelC
	"Freq " uiLabelR
	"Freq.Min " uiLabelR
	"Ramp " uiLabelR
	"Ramp.Acel " uiLabelR
	"* Vibrato *" uiLabelC
	"Vib.Prof " uiLabelR
	"Vib.Vel " uiLabelR
	"* Arpegio *" uiLabelC
	"Arp.Mod " uiLabelR
	"Arp.Vel " uiLabelR

	0.165 %w uiO
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

	0.115 %w uiO
	"* Duty *" uiLabelC
	"Duty " uiLabelR
	"Duty.Ramp " uiLabelR
	"* Filtros *" uiLabelC
	"LowPass " uiLabelR
	"LP.Ramp " uiLabelR
	"LP.Reso " uiLabelR
	"HighPass " uiLabelR
	"HP.Ramp " uiLabelR
	"* Salida *" uiLabelC
	"Repetir " uiLabelR
	"Volumen " uiLabelR

	0.165 %w uiO
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
