| SDL2_mixer.dll
|
^r3/win/sdl2.r3

#sys-Mix_Init
#sys-Mix_Quit
#sys-Mix_LoadWAV_RW
#sys-Mix_LoadMUS
#sys-Mix_PlayChannelTimed
#sys-Mix_HaltChannel
#sys-Mix_PlayMusic
#sys-Mix_HaltMusic
#sys-Mix_FreeChunk
#sys-Mix_FreeMusic
#sys-Mix_OpenAudio
#sys-Mix_CloseAudio
#sys-Mix_PlayingMusic
	
::Mix_Init sys-Mix_Init sys1 ;
::Mix_Quit sys-MIX_Quit sys0 drop ;
	
::Mix_LoadWAV "rb" SDL_RWFromFile sys-Mix_LoadWAV_RW sys1 ;
::Mix_LoadMUS sys-Mix_LoadMUS sys1 ;
::Mix_PlayChannelTimed sys-Mix_PlayChannelTimed sys4 drop ;
::Mix_HaltChannel sys-Mix_HaltChannel
::Mix_PlayMusic sys-Mix_PlayMusic sys2 ;
::Mix_HaltMusic sys-Mix_HaltMusic sys1 drop ;
::Mix_FreeChunk sys-Mix_FreeChunk sys1 drop ;
::Mix_FreeMusic sys-Mix_FreeMusic sys1 drop ;
::Mix_OpenAudio sys-Mix_OpenAudio sys4 drop ;
::Mix_CloseAudio sys-Mix_CloseAudio sys0 drop ;
::Mix_PlayingMusic sys-Mix_PlayingMusic	sys0 ;
	
::sdl2mixer
	"SDL2_mixer.DLL" loadlib
	dup "Mix_Init" getproc 'sys-Mix_Init !
	dup "Mix_Quit" getproc 'sys-Mix_Quit !
	dup "Mix_LoadWAV_RW" getproc 'sys-Mix_LoadWAV_RW !
	dup "Mix_LoadMUS" getproc 'sys-Mix_LoadMUS !
	dup "Mix_PlayChannelTimed" getproc 'sys-Mix_PlayChannelTimed !
	dup "Mix_HaltChannel" getproc 'sys-Mix_HaltChannel !
	dup "Mix_PlayMusic" getproc 'sys-Mix_PlayMusic !
	dup "Mix_HaltMusic" getproc 'sys-Mix_HaltMusic !
	dup "Mix_FreeChunk" getproc 'sys-Mix_FreeChunk !
	dup "Mix_FreeMusic" getproc 'sys-Mix_FreeMusic !
	dup "Mix_OpenAudio" getproc 'sys-Mix_OpenAudio !
	dup "Mix_CloseAudio" getproc 'sys-Mix_CloseAudio !
	dup "Mix_PlayingMusic" getproc 'sys-Mix_PlayingMusic !
	drop
	;

