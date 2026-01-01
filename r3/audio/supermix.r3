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
#voice * $ffff
#voice> 'voice

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

:d.time		a> 24 + ;	| time+dt
:d.dtime	a> 28 + ;

:q.func		a> 32 + ;
:q.vec		a> 40 + ;

:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	48 'voice> +! ;
	
:delvoice | nv --
	-48 'voice> +! voice> 6 move ;

:delvoicea | --
	-48 'voice> +! 
	a> voice> 6 move 
	-48 a+	;

|---- OSC
| time -- val
::oscSaw	2* 1.0 - ;
::oscSqr	0.5 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscPul1	0.1 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscPul2	0.25 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscTri	$8000 and? ( $ffff xor ) 2 << 1.0 - ; 
::oscSin	sin ;

:envelADSR | voice -- mix
	1 d.time d+!
	1 =? ( drop | attack
		w.vol w@ 2* w.Adt w@ + 
		1.0 <? ( ; ) 1.0 nip 
		2 c.state c!
		; )
	2 =? ( drop | decay
		w.vol w@ 2* w.Ddt w@ -
		w.Sdt w@ 2* >? ( ; ) w.Sdt w@ 2* nip
		3 c.state c!
		; )
	3 =? ( drop 
		w.vol w@ 2* ; ) |sustain
	drop | release
	w.vol w@ 2* w.Rdt w@ -
	0 >? ( ; ) 0.0 nip 
	0 c.state c! ;

:playosc | vol voice -- vol voice
	c.state c@ 0? ( delvoicea ; ) 
	envelADSR dup 2/ w.vol w! | volumen por envelope	
	
	d.time d@ 
	d.dtime d@ >? ( 4 c.state c! )
	d.freq d@ *. $ffff and
	q.func @ ex |oscSin | ciclo
	
	*. ; | senial * envelope

:playnoise
	c.state c@ 0? ( delvoicea ; ) 
	envelADSR dup 2/ w.vol w! | volumen por envelope	
	d.time d@ 
	d.dtime d@ >? ( 4 c.state c! )
	drop
	q.func @ ex | noise sin ciclo |	fbrown 
	*. ; | senial * envelope

:playsam
	c.state c@ 0? ( delvoicea ; ) | state=0
	envelADSR dup 2/ w.vol w! | volumen por envelope	
	d.time d@ 
	d.dtime d@ >? ( 4 c.state c! )
	d.fresam d@ *
	d.lensam d@ 16 << >=? ( 2drop 0 c.state c! 0 ; )
	| interpolacion falta
	16 >>
	2 << q.func @ + w@ 2* |2.0 *. | w->0--1.0
	
	*. ;

|------------------- RUN
#aurate 44100 |48000 |
#audevice 
#auspec * 32

:dt>inc dt 32 *>> ;

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
			+ a> 48 + ) drop

		2/ | shift 
		master_volume *.
		fastanh. 2/ $ffff and
		
		dup 16 << or       | to stereo
		db!+
		) drop 
	;	


::smupdate | Queue audio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
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
	;
	
::fx
::control
	
|---- PLAY INSTRUMENT
:midi_to_freq | note -- freq
	fix. 69 - 12 / pow2. 440.0 *. ;

|inc_sample=(fr_deseada<<32)/fr_base
|inc_osc=(fr_desada<<32>/aurate

::smplayd | note time --
	newvoice 0? ( 3drop ; ) | No free voices|
	>a | Save voice index

	aurate *. 32 << d.time !
	
	midi_to_freq 16 <<
	dup 440.0 / d.fresam d! | para sample base 440
	aurate / d.freq d!	| para oscilador

	ins_vector q.vec !
	ins_wave q.func !
	ins_ADSR w.adt ! | ADSR
		ins_aux d.lensam d!
	
	1 c.state c!
	0 w.Vol w!
	;

#nnote 1

::smplay | nota -- id
	$7fffffff smplayd 
	nnote 1+ $ff and 0? ( 1+ ) 
	dup 'nnote !
	dup c.id !
	;
	
::smstop | id --
	'voice ( voice> <? 	| Find voice playing this note
		dup 1+
		pick2 =? ( drop 
			4 swap c!
			drop ;	)
		drop
		48 + ) 2drop ;


	