| r3synth
| PHREDA 2025

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

|-----------------------------------------
| Audio Configuration
#audio_device |SDL_AudioDeviceID 
#audio_spec * 32
#sample_rate 44100
	
:iniaudio
	sample_rate 'audio_spec 0 + d! |freq
	$8010 'audio_spec 4 + w! |format: 16-bit signed
	2 'audio_spec 6 + c! |channels: stereo
	2048 'audio_spec 8 + w! |samples: 2048 frame buffer
	0 'audio_spec 16 + ! |callback: null (push mode)

	0 0 'audio_spec 0 0 SDL_OpenAudioDevice 'audio_device !
	audio_device 0 SDL_PauseAudioDevice
	;	

:reset
	;
	
|--------------------------------
:_softclip
	0.8 <? ( 
		dup dup 16 *>> over 16 *>> 
		0.185 16 *>> - ; )
	1.6 <? ( 0.8 -
		dup dup 16 *>> 0.05625 16 *>> neg
		swap 0.32599 16 *>> 0.70528 + + ; )
	2.4 <? ( 1.6 -
		dup dup 16 *>> 0.02281 16 *>> neg
		swap 0.08625 16 *>> 0.92167 + + ; )
	2.4 -
	0.02722 16 *>> 0.98367 +
	1.0 <? ( ; ) 1.0 nip ;
	
:soft_clip
	-? ( neg _softclip neg ; ) _softclip ;
	
	
|--------------------------------
:main
	$0 SDLcls
	10 10 txat "R3Synth" txprint
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop ;
	
: |--------------------------------
	"R3 Polyphonic Synthesizer" 1024 600 SDLinit
	"media/ttf/Roboto-bold.ttf" 20 txloadwicon txfont
	iniaudio
	reset
	'main SDLshow
	SDLquit ;