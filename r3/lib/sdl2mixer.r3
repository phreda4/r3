| SDL2_mixer.dll
| PHREDA 2024
^r3/lib/sdl2.r3

#sys-Mix_Init
#sys-Mix_Quit
#sys-Mix_LoadWAV_RW
#sys-Mix_LoadMUS
#sys-Mix_PlayChannelTimed
#sys-Mix_HaltChannel
#sys-Mix_FadeOutChannel
#sys-Mix_PlayMusic
#sys-Mix_HaltMusic
#sys-Mix_fadeOutMusic
#sys-Mix_VolumeMusic 

#sys-Mix_FreeChunk
#sys-Mix_FreeMusic
#sys-Mix_OpenAudio
#sys-Mix_CloseAudio
#sys-Mix_PlayingMusic
#sys-Mix_Playing
#sys-Mix_MasterVolume
	
::Mix_Init | flags -- result ; initialize the audio format loaders (MIX_INIT_OGG, MIX_INIT_MP3...), returns the flags that were loaded
	sys-Mix_Init sys1 ;
::Mix_Quit | -- ; unload the loaders started with Mix_Init
	sys-MIX_Quit sys0 drop ;
	
::Mix_LoadWAV | "file" -- chunk ; load a sound effect file (WAV, and OGG, MP3... depending on the loaders) as a chunk; 0 on error
	"rb" SDL_RWFromFile sys-Mix_LoadWAV_RW sys1 ;
::Mix_LoadMUS | "file" -- music ; load a music file; 0 on error
	sys-Mix_LoadMUS sys1 ;
::Mix_PlayChannelTimed | channel chunk loops ticks -- channel ; play the chunk: channel -1 = the first free one, loops 0 = once and -1 = forever, ticks -1 = no time limit; returns the channel used or -1
	sys-Mix_PlayChannelTimed sys4 ;
::Mix_HaltChannel | channel -- ; stop the channel (-1 = all channels)
	sys-Mix_HaltChannel sys1 drop ;
::Mix_FadeOutChannel | channel ms -- ; fade out the channel in ms milliseconds (-1 = all channels)
	sys-Mix_FadeOutChannel sys2 drop ;
::Mix_PlayMusic | music loops -- ; play the music (loops -1 = forever)
	sys-Mix_PlayMusic sys2 drop ;
::Mix_HaltMusic | -- ; stop the music
	sys-Mix_HaltMusic sys0 drop ;
::Mix_FadeOutMusic | ms -- ; fade out the music in ms milliseconds
	sys-Mix_fadeOutMusic sys1 drop ;
::Mix_VolumeMusic | volume -- ; set the music volume (0..128)
	sys-Mix_VolumeMusic sys1 drop ;
::Mix_PlayingMusic | -- bool ; 1 if the music is playing
	sys-Mix_PlayingMusic	sys0 ;
::Mix_Playing | channel -- n ; 1 if the channel is playing (channel -1: number of channels playing)
	sys-Mix_Playing sys1 ;

::Mix_FreeChunk | chunk -- ; free a chunk loaded with Mix_LoadWAV
	sys-Mix_FreeChunk sys1 drop ;
::Mix_FreeMusic | music -- ; free a music loaded with Mix_LoadMUS
	sys-Mix_FreeMusic sys1 drop ;
::Mix_OpenAudio | freq format channels chunksize -- ; open the audio device (for example 44100 $8010 2 4096)
	sys-Mix_OpenAudio sys4 drop ;
::Mix_CloseAudio | -- ; close the audio device
	sys-Mix_CloseAudio sys0 drop ;
::Mix_MasterVolume | volume -- ; set the master volume (0..128; needs SDL_mixer 2.6 or newer)
	sys-Mix_MasterVolume sys1 drop ;

::SNDInit | -- ; open the audio at 44100 Hz, 16 bit signed, stereo, 4096 samples per buffer (it is called when the library is loaded)
	44100 $8010 2 4096 Mix_OpenAudio ;

::SNDplay | chunk -- ; play the chunk once in the first free channel
	-1 swap 0 -1 Mix_PlayChannelTimed drop ;

::SNDplayn | channel chunk -- ; play the chunk once in the given channel
	0 -1 Mix_PlayChannelTimed drop ;

	
::SNDQuit | -- ; close the audio
	Mix_CloseAudio ;
	
|------- BOOT
:
|WIN|	"dll/SDL2_mixer.DLL" loadlib
|LIN|	"libSDL2_mixer-2.0.so.0" loadlib
|MAC|	"libSDL2_mixer.dylib" loadlib
	dup "Mix_Init" getproc 'sys-Mix_Init !
	dup "Mix_Quit" getproc 'sys-Mix_Quit !
	dup "Mix_LoadWAV_RW" getproc 'sys-Mix_LoadWAV_RW !
	dup "Mix_LoadMUS" getproc 'sys-Mix_LoadMUS !
	dup "Mix_PlayChannelTimed" getproc 'sys-Mix_PlayChannelTimed !
	dup "Mix_HaltChannel" getproc 'sys-Mix_HaltChannel !
	dup "Mix_FadeOutChannel" getproc 'sys-Mix_FadeOutChannel !
	dup "Mix_FreeChunk" getproc 'sys-Mix_FreeChunk !
	
	dup "Mix_PlayMusic" getproc 'sys-Mix_PlayMusic !
	dup "Mix_HaltMusic" getproc 'sys-Mix_HaltMusic !
	dup "Mix_FadeOutMusic" getproc 'sys-Mix_fadeOutMusic !
	dup "Mix_VolumeMusic" getproc 'sys-Mix_VolumeMusic !
	dup "Mix_FreeMusic" getproc 'sys-Mix_FreeMusic !
	
	dup "Mix_OpenAudio" getproc 'sys-Mix_OpenAudio !
	dup "Mix_CloseAudio" getproc 'sys-Mix_CloseAudio !
	
	dup "Mix_PlayingMusic" getproc 'sys-Mix_PlayingMusic !
	dup "Mix_Playing" getproc 'sys-Mix_Playing !
	dup "Mix_MasterVolume" getproc 'sys-Mix_MasterVolume !
		
	drop
	SNDInit
	;