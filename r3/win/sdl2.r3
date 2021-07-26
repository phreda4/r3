| SDL2.dll
|
^r3/win/kernel32.r3
^r3/win/core.r3

#sys-SDL_Init 
#sys-SDL_Quit 
#sys-SDL_GetNumVideoDisplays 
#sys-SDL_CreateWindow 
#sys-SDL_GetWindowSurface 
#sys-SDL_ShowCursor 
#sys-SDL_UpdateWindowSurface 
#sys-SDL_DestroyWindow 
#sys-SDL_CreateRenderer 
#sys-SDL_CreateTexture 
#sys-SDL_DestroyTexture 
#sys-SDL_DestroyRenderer 
#sys-SDL_UpdateTexture 
#sys-SDL_RenderClear
#sys-SDL_RenderCopy 
#sys-SDL_RenderPresent 
#sys-SDL_SetRenderDrawColor
#sys-SDL_CreateTextureFromSurface
#sys-SDL_FreeSurface
#sys-SDL_LockTexture
#sys-SDL_UnlockTexture
#sys-SDL_RenderSetLogicalSize
#sys-SDL_SetRenderDrawBlendMode

#sys-SDL_Delay
#sys-SDL_PollEvent	
#sys-SDL_GetTicks
#sys-SDL_StartTextInput	
#sys-SDL_StopTextInput

#sys-SDL_RWFromFile

#sys-SDL_GL_SetAttribute
#sys-SDL_GL_CreateContext
#sys-SDL_GL_DeleteContext
#sys-SDL_GL_SetSwapInterval
#sys-SDL_GL_SwapWindow

::SDL_Init sys-SDL_Init sys1 drop ;
::SDL_Quit sys-SDL_Quit sys0 drop ;
::SDL_GetNumVideoDisplays sys-SDL_GetNumVideoDisplays sys0 ;
::SDL_CreateWindow sys-SDL_CreateWindow sys6 ;
::SDL_GetWindowSurface sys-SDL_GetWindowSurface sys1 ;
::SDL_ShowCursor sys-SDL_ShowCursor sys1 drop ;
::SDL_UpdateWindowSurface sys-SDL_UpdateWindowSurface sys1 drop ;
::SDL_DestroyWindow sys-SDL_DestroyWindow sys1 drop ;
::SDL_CreateRenderer sys-SDL_CreateRenderer sys3 ;
::SDL_CreateTexture sys-SDL_CreateTexture sys5 ;
::SDL_DestroyTexture sys-SDL_DestroyTexture sys1 drop ;
::SDL_DestroyRenderer sys-SDL_DestroyRenderer sys1 ;
::SDL_UpdateTexture sys-SDL_UpdateTexture sys4 ;
::SDL_RenderClear sys-SDL_RenderClear sys1 drop ;
::SDL_RenderCopy sys-SDL_RenderCopy sys4 drop ;
::SDL_RenderPresent sys-SDL_RenderPresent sys1 drop ;
::SDL_CreateTextureFromSurface sys-SDL_CreateTextureFromSurface sys2 ;
::SDL_SetRenderDrawColor sys-SDL_SetRenderDrawColor sys5 drop ; 
::SDL_FreeSurface sys-SDL_FreeSurface sys1 drop ;
::SDL_LockTexture sys-SDL_LockTexture sys4 drop ;
::SDL_UnlockTexture sys-SDL_UnlockTexture sys1 drop ;
::SDL_RenderSetLogicalSize sys-SDL_RenderSetLogicalSize sys3 drop ;
::SDL_SetRenderDrawBlendMode sys-SDL_SetRenderDrawBlendMode sys2 drop ;

::SDL_Delay sys-SDL_Delay sys1 drop ;
::SDL_PollEvent sys-SDL_PollEvent sys1 ; | &evt -- ok
::SDL_GetTicks sys-SDL_GetTicks sys0 ; | -- msec
::SDL_StartTextInput sys-SDL_StartTextInput sys0 drop ;
::SDL_StopTextInput sys-SDL_StopTextInput sys0 drop ;

::SDL_RWFromFile sys-SDL_RWFromFile sys2 ;

::SDL_GL_SetAttribute sys-SDL_GL_SetAttribute sys2 drop ;
::SDL_GL_CreateContext sys-SDL_GL_CreateContext sys1 ;
::SDL_GL_DeleteContext sys-SDL_GL_DeleteContext sys1 drop ;
::SDL_GL_SetSwapInterval sys-SDL_GL_SetSwapInterval sys1 drop ;
::SDL_GL_SwapWindow sys-SDL_GL_SwapWindow sys1 drop ;

::sdl2
	"SDL2.DLL" loadlib
	dup "SDL_Init" getproc 'sys-SDL_Init !
	dup "SDL_Quit" getproc 'sys-SDL_Quit !
	dup "SDL_GetNumVideoDisplays" getproc 'sys-SDL_GetNumVideoDisplays !
	dup "SDL_CreateWindow" getproc 'sys-SDL_CreateWindow !
	dup "SDL_GetWindowSurface" getproc 'sys-SDL_GetWindowSurface !
	dup "SDL_ShowCursor" getproc 'sys-SDL_ShowCursor !
	dup "SDL_UpdateWindowSurface" getproc 'sys-SDL_UpdateWindowSurface !
	dup "SDL_DestroyWindow" getproc 'sys-SDL_DestroyWindow !
	dup "SDL_CreateRenderer" getproc 'sys-SDL_CreateRenderer !
	dup "SDL_CreateTexture" getproc 'sys-SDL_CreateTexture !
	dup "SDL_DestroyTexture" getproc 'sys-SDL_DestroyTexture !
	dup "SDL_DestroyRenderer" getproc 'sys-SDL_DestroyRenderer !
	dup "SDL_UpdateTexture" getproc 'sys-SDL_UpdateTexture !
	dup "SDL_RenderClear" getproc 'sys-SDL_RenderClear !
	dup "SDL_RenderCopy" getproc 'sys-SDL_RenderCopy !
	dup "SDL_RenderPresent" getproc 'sys-SDL_RenderPresent !
	dup "SDL_CreateTextureFromSurface" getproc 'sys-SDL_CreateTextureFromSurface !
	dup "SDL_SetRenderDrawColor" getproc 'sys-SDL_SetRenderDrawColor !
	dup "SDL_FreeSurface" getproc 'sys-SDL_FreeSurface !
	dup "SDL_LockTexture" getproc 'sys-SDL_LockTexture !
	dup "SDL_UnlockTexture" getproc 'sys-SDL_UnlockTexture !
	dup "SDL_RenderSetLogicalSize" getproc 'sys-SDL_RenderSetLogicalSize !
	dup "SDL_SetRenderDrawBlendMode" getproc 'sys-SDL_SetRenderDrawBlendMode !
	
	dup "SDL_Delay" getproc 'sys-SDL_Delay !
	dup "SDL_PollEvent" getproc 'sys-SDL_PollEvent !
	dup "SDL_GetTicks" getproc 'sys-SDL_GetTicks !
	
	dup "SDL_RWFromFile" getproc 'sys-SDL_RWFromFile !
	
	dup "SDL_GL_SetAttribute" getproc 'sys-SDL_GL_SetAttribute !
	dup "SDL_GL_CreateContext" getproc 'sys-SDL_GL_CreateContext !
	dup "SDL_GL_DeleteContext" getproc 'sys-SDL_GL_DeleteContext !
	dup "SDL_GL_SetSwapInterval" getproc 'sys-SDL_GL_SetSwapInterval !
	dup "SDL_GL_SwapWindow" getproc 'sys-SDL_GL_SwapWindow	!
	drop
	;

|----------------------------------------------------------
	
##SDL_windows
##SDL_screen

##sw
##sh
##pitch
##sizebuffer
##vframe

::SDLinit | "titulo" w h --
	2dup * 'sizebuffer !
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 $1FFF0000 sw sh 0 SDL_CreateWindow dup 'SDL_windows !
	SDL_GetWindowSurface dup 'SDL_screen !
	24 + d@+ 'pitch !
	4 + @ 'vframe ! 

	0 SDL_ShowCursor | disable cursor
	;

::SDLinitGL | "titulo" w h --
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 $1FFF0000 sw sh 6 SDL_CreateWindow dup 'SDL_windows ! 
	SDL_GetWindowSurface dup 'SDL_screen !
	;
	
::SDLquit
	SDL_windows SDL_DestroyWindow 
	SDL_Quit ;
	
::SDLredraw
	|SDL_windows SDL_UpdateWindowSurface 
	;

##SDLevent * 56 

##SDLkey
##SDLkeychar
##SDLx ##SDLy ##SDLb
	
|#SDL_KEYDOWN	$300     | Key pressed
|#SDL_KEYUP		$301     | Key released
|#SDL_TEXTINPUT	$303 | Keyboard text input
|#SDL_MOUSEMOTION	$400     | Mouse moved
|#SDL_MOUSEBUTTONDOWN $401    | Mouse button pressed
|#SDL_MOUSEBUTTONUP	$402     | Mouse button released
|#SDL_MOUSEWHEEL		$403     | Mouse wheel motion
	
::SDLupdate
	0 'SDLkey !
	0 'SDLkeychar !
	10 SDL_delay
	( 'SDLevent SDL_PollEvent 1? drop
		'SDLevent d@ 
		$300 =? ( 'SDLevent 20 + d@ dup $ffff and swap 16 >> or 'SDLkey ! )
		$301 =? ( 'SDLevent 20 + d@ dup $ffff and swap 16 >> or $1000 or 'SDLkey ! )
		$303 =? ( 'SDLevent 12 + c@ 'SDLkeychar ! )
		$400 =? ( 'SDLevent 20 + d@+ 'SDLx ! d@ 'SDLy ! )
		$401 =? ( 'SDLevent 16 + c@ SDLb or 'SDLb ! )
		$402 =? ( 'SDLevent 16 + c@ not SDLb and 'SDLb ! )
		drop
		) drop ;	
		
