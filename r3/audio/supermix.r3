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
| exe| par1 par2 par3 par4

#voice * $ffff
#voice> 'voice

:resetvoices
	'voice 'voice> ! ;

| VOICE
:c.id	;
:c.state 1 + ;
:c.wavef 2 + ;

:d.vel 4 + ;
:d.phase 8 + ; | inc|word

:d.env 12 + ;
:d.freq 40 + ;

:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	48 'voice> +! ;
	
:delvoice | nv --
	-48 'voice> +! voice> 6 move ;

| SAMPLE
:d.len 4 + ;
:q.sample 16 + ;


|---- OSC
:oscSaw		2* 1.0 - ;
:oscSqr		0.5 >? ( 0.0 nip ; ) 1.0 nip ; 
:oscTri		$8000 and? ( $ffff xor ) 2 << 1.0 - ; 
:oscSin		sin ;

:playsam
	dup c.state c@ 0? ( drop dup delsample 48 - ; ) drop | state=0
	dup >a

	a> d.phase dup d@			| PHASE
	1+ dup 
	rot d!
	a> d.len d@ >=? ( drop 0 a> c.state c! ; )
	2 << 
	a> q.sample @ + w@ 2* |2.0 *. | w->0--1.0
	rot + swap ;
	
:playosc
	dup c.state c@ 0? ( drop dup delvoice 48 - ; ) drop | state=0
	dup >a
	
|	a> d.freq d@ dt>inc a> d.phase w+! a> d.phase w@ $ffff and 
	a> d.phase dup d@			| PHASE
	dup 16 >> $ffff and + $ffff and dup rot w! | write in W, read in D
	
	oscSin
	
	a> d.env d@		| ADSR general
	aenvelope 
	dup a> d.env d!
	*. 
|	a> d.vel d@ *.	| VOLUME
	rot + swap ;
	
:playmix
	;
	
:playwnoise 
	drop swap fwhite + swap ;
:playpnoise 
	drop swap fpink + swap ;
:playbnoise 
	drop swap fbrown + swap ;
	
|------------------- INSTRUMENTS
#instr * $fff
#instr> 

:ireset
	'instr 'instr> ! ;
	
::isample | "" --
	mix_loadWAV  
	instr> >a
	'playsam a!+
	dup a!+
	dup 8 + @ a!+
	dup 16 + d@ 2 >> a!+
	0 a!+
	0 a!+
	a> 'instr> ! ;

::iosc | osc --
	instr> >a
	'playosc a!+
	a!+
	0 a!+
	0 a!+
	0 a!+
	0 a!+
	a> 'instr> ! ;
	
::inoise | noise --
	instr> >a
	a!+
	0 a!+
	0 a!+
	0 a!+
	0 a!+
	0 a!+
	a> 'instr> ! ;


|------------------- RUN
#aurate 44100 |48000 |
#audevice 
#auspec * 32

:dt>inc dt * 32 >> ;

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
	
:genAudio | genera audio
	'outbuffer >b
	2048 ( 1? 1-
	
		0
		'voice ( voice> <?
			dup @+ ex
			48 + ) drop

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
| vol|note|instr
::smplay | volumen nota instrumento -- id
	;
	
::smstop | id --
	;