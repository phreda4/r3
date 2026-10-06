| superMix
| PHREDA 2025
|-------------------

^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^./noise.r3

|^r3/lib/trace.r3

#master_volume 1.0
#dt

|------------------- VOICES
| unidad de sonido 
##voice * 65536	
##voice> 'voice

:resetvoices
	'voice 'voice> ! ;

:c.state	a> ;		| state
:c.id		a> 1 + ;	| id
:w.Vol		a> 2 + ;	| Volumen (/2)
:d.freq		a> 4 + ;	| inc freq

:w.Adt		a> 8 + ;	| ADSR
:w.Ddt		a> 10 + ;	| 
:w.Sdt		a> 12 + ;	| Volumen /2
:w.Rdt		a> 14 + ;	| 

:d.lensam	a> 16 + ;	| 
:d.fresam	a> 20 + ;

:d.time		a> 24 + ;	| time+dt (negativo = retardo antes de sonar)
:d.dtime	a> 28 + ;

:q.func		a> 32 + ;
:q.vec		a> 40 + ;
:d.vel		a> 48 + ;	| ganancia de la voz (16.16)
:d.crv		a> 52 + ;	| curva de envolvente: env^(n+1): 0 lineal, 1 cuadratica, 2 cubica, 3 cuartica (~exponencial)

:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	64 'voice> +! ;
	
:delvoice | nv --
	-64 'voice> +! voice> 8 move ;

:delvoicea | --
	-64 'voice> +! a> voice> 8 move -64 a+ ;

|---- OSC
| time -- val
::oscSaw	2* 1.0 - ;
::oscSqr	0.5 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscPul1	0.1 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscPul2	0.25 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscTri	$8000 and? ( $ffff xor ) 2 << 1.0 - ; 
::oscSin	sin ;
::oscHSin	sin abs ;
::oscSin2	sin dup *. ;
::oscSin3	sin dup dup *. *. ;
::oscSinF	2* 1.0 - dup *. 2* 1.0 - ;
::oscSawRev	1.0 swap - 2* 1.0 - ;
::oscTrap	0.25 <? ( 2 << ) 0.75 >? ( 2 << 4.0 - ) 2* 1.0 - ;
::oscParab	dup *. 2* 1.0 - ;

::oscFakeSuperSaw | phase -- v
	dup 2* 1.0 - swap dup *. 2* 1.0 - + 2/ ;
	
::oscSuperSaw2P | phase -- v
	2* 1.0 - dup 1.01 *. 2* 1.0 - + 2/ ;

::oscSuperSaw3P | phase -- v
	dup 2* 1.0 -
	swap dup 0.99 *. 2* 1.0 - +
	swap 1.01 *. 2* 1.0 - +
	0.333 *. ;


	
:rvol	w.Vol w@ $ffff and 2* ;	| w sin signo: 1.0/2 = $8000 no cabe en un w con signo
:rsus	w.Sdt w@ $ffff and 2* ;

:envelADSR | state -- mix	
	1 d.time d+!
	c.state c@
	1 =? ( drop | attack
		rvol w.Adt w@ $ffff and + 
		1.0 <? ( ; ) 1.0 nip 
		2 c.state c!
		; )
	2 =? ( drop | decay
		rvol w.Ddt w@ $ffff and -
		rsus >? ( ; ) rsus nip
		3 c.state c!
		; )
	3 =? ( drop 
		rvol ; ) |sustain
	drop | release (negativo = voz terminada, la borra playosc/playnoise/playsam)
	rvol w.Rdt w@ $ffff and -
	;

:delaying | -- 0/1		| retardo previo (sample-accurate): silencio mientras time < 0
	d.time d@ -? ( 1+ d.time d! 1 ; ) drop 0 ;

:shape | env -- env'
	d.crv c@ 0? ( drop ; )
	1 =? ( drop dup *. ; )
	2 =? ( drop dup dup *. *. ; )
	drop dup *. dup *. ;

:out | env osc -- v		| senial * envelope(curva) * ganancia de la voz
	swap shape swap *. d.vel d@ *. ;

:playosc	| -- v
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; ) 
	dup 2/ w.vol w! | volumen por envelope	
	
	d.time d@ d.dtime d@ >? ( 4 c.state c! )
	d.freq d@ *. $ffff and
	q.func @ ex |oscSin | ciclo
	
	out ;

|--- oscilador con pitch slide: fase acumulada (d.fresam) e incremento (d.freq) que
|    cambia cada muestra en forma exponencial; d.lensam = delta (0.32) por muestra
:playsweep	| -- v
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; ) 
	dup 2/ w.vol w!
	d.time d@ d.dtime d@ >? ( 4 c.state c! ) drop
	d.freq d@ dup d.lensam d@ * 32 >> + 0 max
	dup d.freq d!
	d.fresam d@ + dup d.fresam d!
	16 >> $ffff and
	q.func @ ex out ;

:playnoise
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; ) 
	dup 2/ w.vol w! | volumen por envelope	
	
	d.time d@ d.dtime d@ >? ( 4 c.state c! )
	drop
	q.func @ ex | noise sin ciclo |	fbrown 
	out ;

:interpolate | scr sample -- value
	w@+ swap 2 + w@	| src v0 v1 | 2 + stereo!
	rot $ffff and 	| v1 v0 p
	rot pick2 - *. + ;

:playsam
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; )
	dup 2/ w.vol w! | volumen por envelope	
	
	d.time d@ d.dtime d@ >? ( 4 c.state c! )
	d.fresam d@ *
	d.lensam d@ 16 << >=? ( 2drop 0 c.state c! 0 ; )
	
| sin interpolacion
|	16 >> 2 << q.func @ + w@ 

| interpolacion 
	dup 16 >> 2 << q.func @ + interpolate
	
	2* out ; |2.0 *. | w->0--1.0

|------------------- RUN
##aurate 44100 |48000 |
#audevice 
#auspec * 32

::sminit | -- ..
	aurate $8010 2 1024 Mix_OpenAudio | minimal buffer for low latency

	aurate	'auspec 0 + d! |freq
	$8010	'auspec 4 + w! |format: 16-bit signed
	2		'auspec 6 + c! |channels: stereo
	2048	'auspec 8 + w! |samples: 2048 frame buffer
	0		'auspec 16 + ! |callback: null (push mode)

	0 0 'auspec 0 0 SDL_OpenAudioDevice 'audevice !
	audevice 0 SDL_PauseAudioDevice
	
	1.0 16 << aurate / 'dt ! 
	
::smreset
	1.0 'master_volume !
	resetvoices
	;

##outbuffer * 8192 | Final output buffer (16-bit samples)

:genAudio | genera audio
	'outbuffer >b
	2048 ( 1? 1-

		0	| mix
		'voice ( voice> <? >a
			q.vec @ ex |playosc 
			| d.vel d@ *.	| VOLUME por voice
			+ a> 64 + ) drop

		2/ | shift 
		master_volume *.
		fastanh. 2/ clamps16 $ffff and	| fastanh. puede pasar de 1.0 con muchas voces
		
		dup 16 << or       | to stereo
		db!+
		) drop 
	;	


##smtick 0				| hook: 'palabra 'smtick ! ; se ejecuta antes de generar cada bloque de 2048 muestras
:runtick smtick 1? ( ex ; ) drop ;

::smmaster! | v --		| volumen general 0..1.0
	'master_volume ! ;

::smupdate | Queue audio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	runtick
	genAudio
	audevice 'outbuffer 8192 SDL_QueueAudio 
	;
	

|------------------- INSTRUMENTS

#instr * $fff
#instr> 'instr

#ins_vector playosc
#ins_wave oscSin |oscTri |'oscSin
#ins_ADSR 0 
#ins_aux
#ins_vel 1.0
#ins_crv 0

| A:0.001 -> 16.0
| D:0.001 -> 16.0
| S: 0..1.0
| R 0.001 -> 16.0
::packADSR | A D S R -- v
	dt swap 0? ( 1+ ) / $ffff and 0? ( 1+ )  16 <<	| rdt
	swap 2/ $ffff and or 16 <<					| Sdt
	dt rot 0? ( 1+ ) / $ffff and or 16 <<	| ddt
	dt rot 0? ( 1+ ) / $ffff and 0? ( 1+ ) or		| adt
	;

|--- MAKE INSTRUMENT

:ninstr
	instr> 'instr - 5 >> 1- ;  | 4 data
	
:ireset
	'instr 'instr> ! ;

::iosc | ADSR osc -- n
	instr> >a
	'playosc a!+
	a!+ | func
	a!+ | ADSR
	0 a!+
	a> 'instr> ! 
	ninstr ;


::inoise | ADSR noise -- n
	instr> >a
	'playnoise a!+
	a!+	| func
	a!+ | ADSR
	0 a!+
	a> 'instr> ! 
	ninstr ;

::isweep | ADSR osc -- n		| oscilador con pitch slide (ver smslide!)
	instr> >a
	'playsweep a!+
	a!+ | func
	a!+ | ADSR
	0 a!+
	a> 'instr> ! 
	ninstr ;

::isample | ADSR "" -- n
	instr> >a
	'playsam a!+
	mix_loadWAV 
	dup 8 + @ a!+ 		| sample
	swap a!+ 			| ADSR
	16 + d@ 2 >> a!+	| len sample
	a> 'instr> !
	ninstr ;

|---- SET INSTRUMENT
::smi! | n --
	5 << 'instr +
	@+ 'ins_vector !
	@+ 'ins_wave !
	@+ 'ins_ADSR !
	@ 'ins_aux !
	1.0 'ins_vel ! 0 'ins_crv !	| se ajustan despues de smi! (smslide! smvel! smcurve!)
	;

::smslide! | oct/s --		| slide (octavas por segundo, +sube -baja) para el proximo smplayd; despues de smi!
	dt 45426 *. *. 'ins_aux ! ;

::smvel! | v --			| ganancia (16.16) de las proximas voces; despues de smi!
	'ins_vel ! ;

::smcurve! | n --		| curva de envolvente 0 lineal .. 3 cuartica (~exp); despues de smi!
	'ins_crv ! ;

::smOSC! | osc n --
	5 << 'instr + 8 + ! ;
	
::smASDR! | v n --
	5 << 'instr + 16 + ! ;
	
::fx
::control
	
|---- PLAY INSTRUMENT
|inc_sample=(fr_deseada<<32)/fr_base
|inc_osc=(fr_desada<<32>/aurate

:midi_to_freq | note -- freq
	69 - fix. 12 / pow2. 440.0 *. ;

|inc_sample=(fr_deseada<<32)/fr_base
|inc_osc=(fr_desada<<32>/aurate

::smplayhz | hz time --		| frecuencia en Hz (16.16), duracion en segundos (16.16)
	newvoice 0? ( 3drop ; ) | No free voices|
	>a | Save voice index

	aurate *. 32 << d.time !
	
	16 <<
	dup 440.0 / d.fresam d! | para sample base 440
	aurate / d.freq d!	| para oscilador

	ins_vector q.vec !
	ins_wave q.func !
	ins_ADSR w.adt ! | ADSR
	ins_aux d.lensam d!
	ins_vel d.vel d!
	ins_crv d.crv c!
	ins_vector 'playsweep =? ( 0 d.fresam d! ) drop	| fase inicial 0
	
	1 c.state c!
	0 w.Vol w!
	;

::smplayd | note time --
	swap midi_to_freq swap smplayhz ;

#sdelay
::smplayhzat | hz time delay --	| como smplayhz pero empieza 'delay' muestras despues
	'sdelay !
	voice> >r
	smplayhz
	voice> r> =? ( drop ; ) drop
	sdelay neg voice> 64 - 24 + d! ;

::smplayat | note time delay --	| como smplayd pero empieza 'delay' muestras despues
	>r swap midi_to_freq swap r> smplayhzat ;

#nnote 1

::smplay | nota -- id		| id=0 si no hay voces libres
	voice> >r
	$7fffffff smplayd
	voice> r> =? ( drop 0 ; ) drop
	nnote 1+ $ff and 0? ( 1+ ) 
	dup 'nnote !
	dup c.id c! ;				| c! (antes ! escribia 8 bytes y pisaba freq/vol/ADSR)
	
::smstop | id --
	$ff and
	'voice ( voice> <? 	| Find voice playing this note
		dup 1+ c@ $ff and	| id de la voz (antes se comparaba la DIRECCION)
		pick2 =? ( drop 
			4 over c!		| release
			2drop ; )
		drop
		64 + ) 2drop ;
