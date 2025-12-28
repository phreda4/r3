| MIxer
| PHREDA 2025
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^r3/util/immi.r3
^r3/lib/rand.r3
^r3/util/varanim.r3

#aurate 44100 |48000 |
#audevice 
#auspec * 32
#dt

:dt>inc dt * 32 >> ;

|--------------------
	
:init
	aurate $8010 2 1024 Mix_OpenAudio | minimal buffer for low latency

	aurate 'auspec 0 + d! |freq
	$8010 'auspec 4 + w! |format: 16-bit signed
	2 'auspec 6 + c! |channels: stereo
	2048 'auspec 8 + w! |samples: 2048 frame buffer
	0 'auspec 16 + ! |callback: null (push mode)

	0 0 'auspec 0 0 SDL_OpenAudioDevice 'audevice !
	audevice 0 SDL_PauseAudioDevice
	
	1.0 16 << aurate / 'dt ! 
	;

|---- SAMPLE
#sample1	
|typedef struct Mix_Chunk {
|    int allocated;
|    Uint8 *abuf; | +8
|    Uint32 alen; | +16
|    Uint8 volume;      
|} Mix_Chunk;

:infowav | adr --
	d@+ "allocate %d" .println
	4 + | align
	@+ "buffer %h" .println
	d@+ "len %h" .println
	c@+ $ff and "vol %d" .println
	drop
	;
	
#phases
	
:gensam | -- val
	phases
|	freq dt>inc
|	+ $ffff and 
	1+
	
	sample1 16 + d@ 2 >> >=? ( 0 nip )
	dup 'phases !
	2 << 
	sample1 8 + @ +
	w@ 2.0 *.
	;
	
|---- OSC
:oscSaw		2* 1.0 - ;
:oscSqr		0.5 >? ( 0.0 nip ; ) 1.0 nip ; 
:oscTri		$8000 and? ( $ffff xor ) 2 << 1.0 - ; 
:oscSin		sin ;

#freq 220.0
#phaseo

:genosc | -- val
	phaseo
	freq dt>inc
	+ $ffff and 
	dup 'phaseo !
	oscTri
	;

:gen_osc | phase -- val


#outbuffer * 8192 | Final output buffer (16-bit samples)
#master_volume 1.0

:gAudio | genera audio
	'outbuffer >b
	2048 ( 1? 1-
	
		0
		genosc 2/ +
		gensam +

		master_volume *.
		fastanh. 
		32767 *. 

		$ffff and
		dup 16 << or       | Duplicate to both channels
		db!+
		) drop ;	
		
|-------------------------
| VOICE
:c.id	;
:c.state 1 + ;
:c.wavef 2 + ;

:d.vel 4 + ;
:d.phase 8 + ; | inc|word

:d.env 16 + ;
:d.freq 40 + ;

#voice * $fff
#voice> 'voice

:resetvoices
	'voice 'voice> ! ;
	
:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	48 'voice> +! ;
	
:delvoice | nv --
	-48 'voice> +! voice> 6 move ;

|------------------------------------
	
#amp_attack 
#amp_decay 
#amp_sustain 
#amp_release 

#aattrt
#adecrt
#arelrt


:calcvar
	dt amp_attack / 'aattrt !
	dt amp_decay / 'adecrt !
	dt amp_release / 'arelrt !
	;
	
:aenvelope | voice -- mix
	a> c.state c@
	1 =? ( drop | attack
		aattrt +
		1.0 <? ( ; ) 1.0 nip
		2 a> c.state c!
		; )
	2 =? ( drop | decay
		adecrt -
		amp_sustain >? ( ; ) amp_sustain nip
		3 a> c.state c!
		; )
	3 =? ( drop ; ) |sustain
	drop | release
	arelrt -
	0 >? ( ; ) 0.0 nip 
	0 a> c.state c! ;
	
:playvoice | voice -- voice
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

|----------------------
:midi_to_freq | note -- freq
	fix. 12 / pow2. 440.0 *. ;

:note_on | noteid note velocity --
	newvoice 0? ( 4drop ; ) | No free voices|
	>a | Save voice index

	a> d.vel d!

	midi_to_freq 
	dup a> d.freq d!
	dt>inc 16 << a> d.phase d!
	
	a> c.id c!
	
	1 a> c.wavef c!
	1 a> c.state c!
	0 a> d.env d!
	;

:note_off | noteid --
	'voice ( voice> <? 	| Find voice playing this note
		dup c.id c@
		pick2 =? ( drop 
			4 
			over c.state c!
			2drop ;	)
		drop
		48 + ) 2drop ;
		
|-----------------------------------
:genAudio | genera audio
	'outbuffer >b
	2048 ( 1? 1-
	
		0
		'voice ( voice> <?
			playvoice
			48 + ) drop

		master_volume *.
		fastanh. 
		32767 *. 

		$ffff and
		dup 16 << or       | Duplicate to both channels
		db!+
		) drop ;	


:drawbuffer
	$ffffff sdlcolor
	'outbuffer >a 
	0 ( 1024 <? 1+
		da@+
		over 0 +
		over $7fff + 10 >> $3f and 200 + SDLPoint
		over 0 +
		swap 16 >> $7fff + 10 >> $3f and 400 + SDLPoint
		) drop ;	

|-------------------------

:qaudio | Queue audio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	genAudio
	audevice 'outbuffer 8192 SDL_QueueAudio 
	;

#playn * 100 
#nnote 1

:keydn | note --
	dup 'playn + c@ 1? ( 2drop ; ) drop 
	nnote 1+ $ff and 0? ( 1+ ) dup 'nnote !
	over 1.0 note_on
	nnote swap 'playn + c! ;

:keyup | note --
	dup 'playn + c@ 0? ( 2drop ; )
	note_off  
	0 swap 'playn + c! ;

:seq
	[ 0 keydn ; ] 0 +vexe
	[ 1 keydn ; ] 0.5 +vexe
	[ 0 keyup ; ] 1.0 +vexe
	[ 1 keyup ; ] 1.5 +vexe
	'seq 4.0 +vexe
	;
	
:main
	vupdate
	$0 SDLcls
	drawbuffer
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( seq )
	<z> =? ( 0 keydn )
	>z< =? ( 0 keyup )
	<x> =? ( 1 keydn )
	>x< =? ( 1 keyup )
	
	drop 
	qaudio
	;


: 
	"mix" 1024 600 SDLinit
	init
	$fff vaini
	
	0.005 'amp_attack !
	0.1 'amp_decay !
	0.7 'amp_sustain !
	0.1 'amp_release !
	calcvar	
	
	"media/snd/piano-C.mp3" mix_loadWAV  'sample1 !
	sample1 infowav
	'main SDLshow
	SDLquit 
;