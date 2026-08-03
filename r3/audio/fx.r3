| fx.r3 - reproduce sonidos generados por fxsynth.r3 
| PHREDA 2026

^r3/audio/fxsynth.r3
^r3/lib/sdl2.r3

##aurate 44100
#audevice
#auspec * 32

#vplaying 0
#vphase
#vlen
#vptr

::fxAudioInit
	aurate 'auspec 0 + d! |freq
	$8010 'auspec 4 + w! |format: 16-bit signed
	2 'auspec 6 + c! |channels: stereo
	2048 'auspec 8 + w! |samples: 2048 frame buffer
	0 'auspec 16 + ! |callback: null (push mode)

	0 0 'auspec 0 0 SDL_OpenAudioDevice 'audevice !
	audevice 0 SDL_PauseAudioDevice ;

|---- dispara el sonido actual (segun p_* params) - una sola voz de preview
::fxPlay
	fxRender 'vlen !
	'fxbuf 'vptr !
	0 'vphase !
	1 'vplaying ! ;

::fxStop
	0 'vplaying ! ;

:fxGenSample | -- v
	vplaying 0? ( drop 0 ; ) drop
	vphase vlen >=? ( drop 0 'vplaying ! 0 ; ) 
	1 << vptr + w@
	1 'vphase +! ;

#outbuffer * 8192 | 2048 frames stereo 16bit

:genAudio
	'outbuffer >b
	2048 ( 1? 1-
		fxGenSample
		$ffff and
		dup 16 << or | mono -> stereo
		db!+
		) drop ;

::fxUpdate | -- ; llamar cada frame del loop principal
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop
	genAudio
	audevice 'outbuffer 8192 SDL_QueueAudio ;

::fxPlaying? | -- flag
	vplaying ;
