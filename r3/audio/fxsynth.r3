| fxsynth.r3 - generador de efectos de sonido parametrizable (estilo bfxr/jfxr)
| PHREDA-style, sin samples, todo sintetizado
^r3/lib/math.r3
^r3/lib/rand.r3

|============================================================
| PARAMETROS (0.0..1.0 fixed salvo aclaracion). Editables por UI o presets.
|============================================================
##p_wave 0        | 0 sqr | 1 saw | 2 sin | 3 noise | 4 tri

##p_attack  0.0
##p_sustain 0.3
##p_punch   0.0
##p_decay   0.4

##p_freq      0.5
##p_freqlimit 0.0
##p_freqramp  0.0
##p_freqdramp 0.0

##p_vibdepth 0.0
##p_vibspeed 0.0

##p_arpmod   0.0   | -1.0..1.0
##p_arpspeed 0.0

##p_duty     0.5
##p_dutyramp 0.0

##p_lpffreq 1.0    | 1.0 = filtro abierto (sin efecto)
##p_lpframp 0.0
##p_lpfreso 0.0

##p_hpffreq 0.0
##p_hpframp 0.0

##p_repeat   0.0
##p_vol 0.5

|============================================================
| ESTADO DE RENDER (interno)
|============================================================
#fperiod #fmaxperiod #fslide #fdslide
#sduty #sdutyramp
#arpmod #arplimit #arptime
#replimit #reptime
#envstage #envtime #envvol
#envlen0 #envlen1 #envlen2
#vibphase #vibspeedinc #vibamp
#fltp #fltdp #fltw #fltwd #fltdmp #fltphp #flthp #flthpd #pp
#iphase #period
#playing

#noisebuf * 256   | 32 qwords

|============================================================
| DEFAULTS
|============================================================
::fxDefaults
	0 'p_wave !
	0.0 'p_attack ! 0.3 'p_sustain ! 0.0 'p_punch ! 0.4 'p_decay !
	0.5 'p_freq ! 0.0 'p_freqlimit ! 0.0 'p_freqramp ! 0.0 'p_freqdramp !
	0.0 'p_vibdepth ! 0.0 'p_vibspeed !
	0.0 'p_arpmod ! 0.0 'p_arpspeed !
	0.5 'p_duty ! 0.0 'p_dutyramp !
	0.0 'p_repeat !
	1.0 'p_lpffreq ! 0.0 'p_lpframp ! 0.0 'p_lpfreso !
	0.0 'p_hpffreq ! 0.0 'p_hpframp !
	0.5 'p_vol ! ;

|============================================================
| NOISE BUFFER
|============================================================
:fxNoiseGen
	'noisebuf >a
	32 ( 1? -1.0 1.0 randminmax a!+ 1- ) drop ;

:fxNoiseSample | -- v
	iphase 32 * period / 3 << 'noisebuf + @ ;

:fxNoiseWrapCheck
	p_wave 3 =? ( drop fxNoiseGen ; )
	drop ;

|============================================================
| OSCILADORES : fp(0.0..1.0 fixed) -- v(-1.0..1.0 fixed)
|============================================================
:fxOscSqr | fp -- v
	sduty <? ( drop 0.5 ; ) drop -0.5 ;

:fxOscTri | fp -- v
	$8000 and? ( $ffff xor ) 2 << 1.0 - ;

:fxOsc | fp -- v
	p_wave
	0 =? ( drop fxOscSqr ; )
	1 =? ( drop 2* 1.0 - ; )
	2 =? ( drop sin ; )
	3 =? ( drop drop fxNoiseSample ; )
	drop fxOscTri ;

|============================================================
| DERIVACION DE PARAMETROS (reset)
|============================================================
:fxDeriveFreq
	100.0 p_freq dup *. 0.001 + /. 'fperiod !
	100.0 p_freqlimit dup *. 0.001 + /. 'fmaxperiod !
	1.0 p_freqramp dup dup *. *. 0.01 *. - 'fslide !
	p_freqdramp dup dup *. *. 0.000001 *. neg 'fdslide !
	0.5 p_duty 2/ - 'sduty !
	p_dutyramp neg 0.00005 *. 'sdutyramp !
	0 'iphase ! ;

:fxDeriveArp
	p_arpmod +? ( drop 1.0 p_arpmod dup *. 0.9 *. - 'arpmod ! ; )
	drop 1.0 p_arpmod dup *. 10.0 *. + 'arpmod ! ;

:fxDeriveArpLimit
	p_arpspeed 1.0 =? ( drop 0 'arplimit ! ; )
	drop
	1.0 p_arpspeed - dup *. 20000 *. 32 + 'arplimit !
	0 'arptime ! ;

:fxDeriveRepeat
	p_repeat 0? ( drop 0 'replimit ! ; )
	drop
	1.0 p_repeat - dup *. 20000 *. 32 + 'replimit !
	0 'reptime ! ;

:fxDeriveEnv
	p_attack  dup *. 100000 *. 1 max 'envlen0 !
	p_sustain dup *. 100000 *. 1 max 'envlen1 !
	p_decay   dup *. 100000 *. 1 max 'envlen2 !
	0 'envstage ! 0 'envtime ! 0.0 'envvol ! ;

:fxDeriveVib
	p_vibspeed dup *. 0.01 *. 'vibspeedinc !
	p_vibdepth 0.5 *. 'vibamp !
	0 'vibphase ! ;

:fxDeriveFilter
	0.0 'fltp ! 0.0 'fltdp ! 0.0 'fltphp ! 0.0 'pp !
	p_lpffreq dup dup *. *. 0.1 *. 'fltw !
	1.0 p_lpframp 0.0001 *. + 'fltwd !
	1.0 p_lpfreso dup *. 20.0 *. +
	5.0 swap /.
	0.01 fltw + *.
	0.8 clampmax 'fltdmp !
	p_hpffreq dup *. 0.1 *. 'flthp !
	1.0 p_hpframp 0.0003 *. + 'flthpd ! ;

::fxReset
	fxDeriveFreq
	fxDeriveArp
	fxDeriveArpLimit
	fxDeriveRepeat
	fxDeriveEnv
	fxDeriveVib
	fxDeriveFilter
	1 'playing !
	fxNoiseGen ;

|============================================================
| PASO DE MUESTRA (envolvente, slide, filtros)
|============================================================
:fxRepeatCheck
	replimit 0? ( drop ; )
	drop
	1 'reptime +!
	reptime replimit >=? ( drop 0 'reptime !
		iphase period
		fxDeriveFreq
		fperiod int. 8 max
		swap /.
		*. 'iphase ! ; )
	drop ;

:fxArpCheck
	arplimit 0? ( drop ; )
	drop
	1 'arptime +!
	arptime arplimit >=? ( drop
		fperiod arpmod *. 'fperiod !
		iphase arpmod *. 'iphase !
		0 'arplimit ! ; )
	drop ;

:fxForceFadeOut
	envstage 2 <? (
		2 'envstage !
		0 'envtime !
		200 'envlen2 !
	) drop ;

:fxSlide
	fperiod fslide *. 'fperiod !
	fdslide 'fslide +!
	fperiod fmaxperiod >? ( drop fmaxperiod 'fperiod !
		p_freqlimit 1? ( fxForceFadeOut ) drop ; )
	drop ;

:fxRFPeriod | -- rfperiod
	vibspeedinc 'vibphase +!
	fperiod vibphase sin vibamp *. 1.0 + *. ;

:fxEnvDecay
	envtime envlen2 >=? ( drop 0 'playing ! 0.0 'envvol ! ; )
	drop
	1.0 envtime envlen2 /. - 'envvol ! ;

:fxEnvSustain
	envtime envlen1 >=? ( drop 0 'envtime ! 2 'envstage ! fxEnvDecay ; )
	drop
	1.0 envtime envlen1 /. - p_punch 2.0 *. *. 1.0 + 'envvol ! ;

:fxEnvAttack
	envtime envlen0 >=? ( drop 0 'envtime ! 1 'envstage ! fxEnvSustain ; )
	drop
	envtime envlen0 /. 'envvol ! ;

:fxEnvelope
	1 'envtime +!
	envstage
	0 =? ( drop fxEnvAttack ; )
	1 =? ( drop fxEnvSustain ; )
	drop fxEnvDecay ;

:fxFilterBypass | s -- s'
	dup 'fltp ! 0.0 'fltdp ! ;

:fxFilterLP | s -- s'
	dup fltp - fltw *. 'fltdp +!
	fltdp fltdmp *. neg 'fltdp +!
	fltp fltdp + 'fltp !
	drop fltp ;

:fxLowpass | s -- s'
	p_lpffreq 1.0 =? ( drop fxFilterBypass ; )
	drop fxFilterLP ;

:fxHpRamp
	flthpd 0? ( drop ; )
	drop
	flthp flthpd *. 0.00001 clampmin 0.1 clampmax 'flthp ! ;

:fxHighpass | s -- s'
	fxHpRamp
	fltp pp - 'fltphp +!
	fltphp flthp *. neg 'fltphp +!
	flthp 0.0 >? ( 2drop fltphp ; )
	2drop fltp ;

::fxSample | -- v
	fxRepeatCheck
	fxArpCheck
	fxSlide
	fxRFPeriod int. 8 max 'period !
	sdutyramp 'sduty +!
	sduty 0.0 clampmin 0.5 clampmax 'sduty !
	1 'iphase +!
	iphase period >=? ( 0 'iphase ! fxNoiseWrapCheck ) drop
	iphase period /. fxOsc
	fltp 'pp !
	fxLowpass
	fxHighpass
	fxEnvelope
	envvol *. 2.0 *.
	p_vol *. ;

|============================================================
| RENDER OFFLINE A BUFFER (16 bit signed, mono, 44100hz)
|============================================================
##fxrate 44100
##fxmaxsamples 176400 | 4 seg tope de seguridad
##fxbuf * 352800        | fxmaxsamples * 2 bytes
##fxlen 0
#fxwptr

:fxNextI | i -- i'
	playing 0? ( 2drop fxmaxsamples ; )
	drop 1 + ;

::fxRender | -- len
	fxReset
	'fxbuf 'fxwptr !
	0 'fxlen !
	0
	( fxmaxsamples <?
		fxSample 2/ -32768 clampmin 32767 clampmax
		fxwptr w!
		2 'fxwptr +!
		1 'fxlen +!
		fxNextI
	) drop
	fxlen ;

|============================================================
| PRESETS ALEATORIOS ESTILO BFXR
|============================================================
::fxPickup
	fxDefaults
	0 'p_wave !
	0.3 0.5 randminmax 'p_freq !
	0.0 0.1 randminmax 'p_sustain !
	0.3 0.6 randminmax 'p_punch !
	0.1 0.5 randminmax 'p_decay !
	0.0 0.3 randminmax 'p_freqramp !
	0.0 1.0 randminmax 'p_duty ! ;

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
	-0.5 -0.2 randminmax 'p_freqramp !
	0.0 0.1 randminmax 'p_sustain !
	0.1 0.3 randminmax 'p_decay ! ;

::fxJump
	fxDefaults
	0 'p_wave !
	0.3 0.6 randminmax 'p_freq !
	0.1 0.3 randminmax 'p_freqramp !
	0.1 0.3 randminmax 'p_sustain !
	0.1 0.2 randminmax 'p_decay !
	0.0 1.0 randminmax 'p_duty ! ;

::fxBlip
	fxDefaults
	2 randmax 'p_wave !
	0.2 0.6 randminmax 'p_freq !
	0.03 0.1 randminmax 'p_sustain !
	0.05 0.2 randminmax 'p_decay ! ;

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

::fxPack | 'dest --
	>a 'p_wave >b
	b@+ ca!+
	21 ( 1? 1- b@+ da!+ ) drop ;
	
::fxUnpack
	>a 'p_wave >b
	ca@+ b!+
	21 ( 1? 1- da@+ b!+ ) drop ;	
