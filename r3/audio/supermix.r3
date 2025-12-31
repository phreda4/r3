| superMix
| PHREDA 2025
|-------------------
| INSTRUMENTS
| ::isample
| ::iosc
| ::imix

| VOICES
| ::smplay
| ::smstop
| 
| RUN
| ::sminit
| ::smupdate
| ::smreset

^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^./noise.r3

#master_volume 1.0
#dt

|------------------- VOICES
| unidad de sonido 

| INSTRUMENTO
| TIEMPO(NOW)
| ATACK-RELEASE
| TONO (SAMPLE[shift]-OSC[gen])
| VOLUMEN
| FX
| PANEO


#voice * $ffff
#voice> 'voice

:resetvoices
	'voice 'voice> ! ;

| VOICE
| siwv pp dd	0
| aa rr eeee	8 / llll eeee
| pppp ffff		16
| *sample		24

| 32
| 40
| 48

:c.state	a> ;
:c.id		a> 1 + ;
:c.wavef 	a> 2 + ;
:c.vel		a> 3 + ;
:d.time		a> 4 + ;

:d.samlen				| SAMPLE
:w.Adt		a> 8 + ;	| OSC
:w.Rdt		a> 10 + ;	| OSC
:d.len					| SAMPLE
:d.EVol		a> 12 + ;	| OSC

:d.phase	a> 16 + ;  |phase+dt...
:d.freq		a> 20 + ;

:q.sample				| SAMPLE
:d.dtime	a> 24 + ;	| duracion nota



:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	48 'voice> +! ;
	
:delvoice | nv --
	-48 'voice> +! voice> 6 move ;



|---- OSC
::oscSaw	2* 1.0 - ;
::oscSqr	0.5 >? ( 0.0 nip ; ) 1.0 nip ; 
::oscTri	$8000 and? ( $ffff xor ) 2 << 1.0 - ; 
::oscSin	sin ;


:envelAR | state -- mix
	1 =? ( drop | attack
		d.Evol d@ w.Adt w@ + 
		1.0 <? ( ; ) 1.0 nip 
		2 c.state c!
		; )
	2 =? ( drop 
		d.time d@ d.dtime d@ >? ( 3 c.state c! ) drop
		d.Evol d@ ; ) |sustain
	drop | release
	d.Evol d@ w.Rdt w@ -
	0 >? ( ; ) 0.0 nip 
	0 c.state c! ;
	

:playosc | vol voice -- vol voice
	dup >a
	1 d.time d+!
	c.state c@ 
	0? ( drop dup delvoice 48 - ; ) 

	envelAR dup d.Evol d! | volumen por envelope	
	d.phase dup d@ dup 16 >> $ffff and + dup rot w! $ffff and 
	
	oscSin | ciclo
	*. | senial * envelope
|	d.vel d@ *.	| VOLUME
	rot + swap ; | suma a mix



:playsam
	dup >a
	c.state c@ 
	0? ( drop dup delvoice 48 - ; ) | state=0
	envelAR | voice mixe
	
	
	d.phase dup d@			| PHASE
	1+ dup 
	rot d!
	d.len d@ >=? ( drop 0 c.state c! ; )
	2 << 
	q.sample @ + w@ 2* |2.0 *. | w->0--1.0
	rot + swap ;
	

| suma voice voice+	
::wnoise 
	drop swap fwhite + swap ;
::pnoise 
	drop swap fpink + swap ;
::bnoise 
	drop swap fbrown + swap ;
	
|------------------- INSTRUMENTS
| OSC/SAMPLE
| AR (Attack-Release)
| NOTAS?
|
| KIT
| Lista de 
#instr * $fff
#instr> 'instr

:ninstr
	instr> 'instr - 6 >> ;  | 8 data
:ireset
	'instr 'instr> ! ;

:iosc | osc -- n
	instr> >a
	'playosc a!+
	a!+
	0 a!+
	0 a!+
	0 a!+
	0 a!+
	a> 'instr> ! 
	ninstr ;
	
::isample | "" -- n
	mix_loadWAV  
	instr> >a
	'playsam a!+
	dup a!+
	dup 8 + @ a!+
	dup 16 + d@ 2 >> a!+
	0 a!+
	0 a!+
	a> 'instr> !
	ninstr ;

	
::inoise | noise -- n
	instr> >a
	a!+
	0 a!+
	0 a!+
	0 a!+
	0 a!+
	0 a!+
	a> 'instr> ! 
	ninstr 
	;


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
	
		0
		'voice ( voice> <?
|			dup @+ ex
			playosc
			48 + ) drop
|fbrown +
| suma voice voice+

		master_volume *.
		fastanh. 2/ $ffff and
		
		dup 16 << or       | to stereo
		db!+
		) drop ;	
		


::smupdate | Queue audio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	genAudio
	audevice 'outbuffer 8192 SDL_QueueAudio 
	;
	
|------------------- VOICES
| INSTRUMENTO
| TIEMPO(NOW)
| c ATACK-RELEASE
| c VOL c PAN
| c FX
| TONO (SAMPLE[shift]-OSC[gen])
| DURACION

#nowinst 
#amp_attack 0.001
#amp_release 0.1

::fx
::control
::instr
	;
	
::smplay | nota -- id
	;
::smstop | id --
	;

:midi_to_freq | note -- freq
	fix. 12 / pow2. 440.0 *. ;

::smplayd | note time --
	newvoice 0? ( 3drop ; ) | No free voices|
	>a | Save voice index

	aurate *. d.dtime d! | tiempo en muestra para terminar
	0 d.time d!
	
	midi_to_freq 
	dup d.freq d!		| frecuencia
	dt>inc 16 << 		| incremento por sample
	d.phase d!		| phase actual
	
	dt amp_attack / w.adt w!
	dt amp_release / w.rdt w!
	
	1 c.wavef c!
	1 c.state c!
	0 d.EVol d!
	;


	