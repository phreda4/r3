| SDL2_mixer.dll
|
^r3/win/sdl2.r3

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
	
::Mix_Init sys-Mix_Init sys1 ;
::Mix_Quit sys-MIX_Quit sys0 drop ;
	
::Mix_LoadWAV "rb" SDL_RWFromFile sys-Mix_LoadWAV_RW sys1 ;
::Mix_LoadMUS sys-Mix_LoadMUS sys1 ;
::Mix_PlayChannelTimed sys-Mix_PlayChannelTimed sys4 ;
::Mix_HaltChannel sys-Mix_HaltChannel sys1 drop ;
::Mix_FadeOutChannel sys-Mix_FadeOutChannel sys2 drop ;
::Mix_PlayMusic sys-Mix_PlayMusic sys2 drop ;
::Mix_HaltMusic sys-Mix_HaltMusic sys0 drop ;
::Mix_FadeOutMusic sys-Mix_fadeOutMusic sys1 drop ;
::Mix_VolumeMusic sys-Mix_VolumeMusic sys1 ;
::Mix_PlayingMusic sys-Mix_PlayingMusic	sys0 ;
::Mix_Playing sys-Mix_Playing sys1 ;

::Mix_FreeChunk sys-Mix_FreeChunk sys1 drop ;
::Mix_FreeMusic sys-Mix_FreeMusic sys1 drop ;
::Mix_OpenAudio sys-Mix_OpenAudio sys4 drop ;
::Mix_CloseAudio sys-Mix_CloseAudio sys0 drop ;

::SNDInit
	44100 $8010 2 4096 Mix_OpenAudio ;

::SNDplay | adr --
	-1 swap 0 -1 Mix_PlayChannelTimed drop ;

::SNDplayn | channel adr --
	0 -1 Mix_PlayChannelTimed drop ;

	
::SNDQuit	
	Mix_CloseAudio ;
	
|------- BOOT
:
	"SDL2_mixer.DLL" loadlib
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
	drop
	SNDInit
	;