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
| OSCILADORES : fp(0.0..1.0 fixed) -- v(-1.0..1.0 fixed)
|============================================================
:fxNoiseSample | -- v
	-1.0 1.0 randminmax ;

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
	p_freqdramp dup dup *. *. 0.0001 *. neg 'fdslide !
	0.5 p_duty 2/ - 'sduty !
	p_dutyramp neg 0.0005 *. 'sdutyramp !
	0 'iphase ! ;

:fxDeriveArp
	p_arpmod 
	+? ( 1.0 swap dup *. 0.9 *. - 'arpmod ! ; )
	1.0 swap dup *. 10.0 *. + 'arpmod ! ;

:fxDeriveArpLimit
	p_arpspeed 1.0 =? ( drop 0 'arplimit ! ; ) 
	1.0 swap - dup *. 20000 *. 32 + 'arplimit !
	0 'arptime ! ;

:fxDeriveRepeat
	p_repeat 0? ( drop 0 'replimit ! ; ) 
	1.0 swap - dup *. 20000 *. 32 + 'replimit !
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
	;

|============================================================
| PASO DE MUESTRA (envolvente, slide, filtros)
|============================================================
:fxRepeatCheck
	replimit 0? ( drop ; ) drop
	1 'reptime +!
	reptime replimit <? ( drop ; ) drop 
	0 'reptime !
	iphase period
	fxDeriveFreq
	fperiod int. 8 max
	swap /.
	*. 'iphase ! ; 

:fxArpCheck
	arplimit 0? ( drop ; ) drop
	1 'arptime +!
	arptime arplimit <? ( drop ; ) drop
	fperiod arpmod *. 'fperiod !
	iphase arpmod *. 'iphase !
	0 'arplimit ! ; 


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
	envtime 
	envlen2 >=? ( drop 0 'playing ! 0.0 'envvol ! ; )	
	1.0 swap envlen2 /. - 'envvol ! ;

:fxEnvSustain
	envtime 
	envlen1 >=? ( drop 0 'envtime ! 2 'envstage ! fxEnvDecay ; )
	1.0 swap envlen1 /. - p_punch 2.0 *. *. 1.0 + 'envvol ! ;

:fxEnvAttack
	envtime 
	envlen0 >=? ( drop 0 'envtime ! 1 'envstage ! fxEnvSustain ; ) 
	envlen0 /. 'envvol ! ;

:fxEnvelope
	1 'envtime +!
	envstage
	0 =? ( drop fxEnvAttack ; )
	1 =? ( drop fxEnvSustain ; )
	drop fxEnvDecay ;

:fxFilterBypass | s -- s'
	dup 'fltp ! 0.0 'fltdp ! ;
	
:fxLpRamp
	fltwd 0? ( drop ; )
	fltw *. 1.0 clamp0max 'fltw ! ;
	
:fxFilterLP | s -- s'
	fxLpRamp
	fltp - fltw *. fltdp +
	dup fltdmp *. - dup 'fltdp !
	fltp + dup 'fltp ! ;

:fxLowpass | s -- s'
	p_lpffreq 1.0 =? ( drop fxFilterBypass ; )
	drop fxFilterLP ;

:fxHpRamp
	flthpd 0? ( drop ; ) drop
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
	sduty 0.5 clamp0max 'sduty !
	1 'iphase +!
	iphase 
	period >=? ( 0 'iphase ! )
	period /. fxOsc
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

::fxRender | -- len
	|playing 0? ( drop fxmaxsamples ; ) drop
	fxReset
	'fxbuf 
	0 ( fxmaxsamples <?
		fxSample 2/ clamps16
		rot w!+ swap
		1+ ) nip ;

::fxPack | 'dest --
	'p_wave >b
	b@+ swap w!+ 
	21 ( 1? 1- b@+ 2 >> rot w!+ swap ) 
	2drop ;
	
::fxUnpack | 'src --
	'p_wave >b
	w@+ b!+
	21 ( 1? 1- swap w@+ 2 << b!+ swap ) 
	2drop ;
