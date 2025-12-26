| MIxer
| PHREDA 2025
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^r3/util/immi.r3
^r3/lib/rand.r3

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
:qaudio | Queue audio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	gaudio
	audevice 'outbuffer 8192 SDL_QueueAudio 
	;
	
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

:main
	$0 SDLcls
	drawbuffer
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop 
	qaudio
	;


: 
	"mix" 1024 600 SDLinit
	init
	
	"media/snd/piano-C.mp3" mix_loadWAV  'sample1 !
	sample1 infowav
	'main SDLshow
	SDLquit 
;