| SDL2.dll
|
^r3/win/kernel32.r3
^r3/win/core.r3

#sys-SDL_Init 
#sys-SDL_Quit 
#sys-SDL_GetNumVideoDisplays 
#sys-SDL_CreateWindow 
#sys-SDL_SetWindowFullscreen
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
#sys-SDL_RenderCopyEx
#sys-SDL_RenderPresent 
#sys-SDL_SetRenderDrawColor
#sys-SDL_CreateTextureFromSurface
#sys-SDL_QueryTexture
#sys-SDL_FreeSurface
#sys-SDL_LockTexture
#sys-SDL_UnlockTexture
#sys-SDL_RenderSetLogicalSize
#sys-SDL_SetRenderDrawBlendMode
#sys-SDL_RenderDrawPoint
#sys-SDL_RenderDrawLine
#sys-SDL_RenderDrawRect
#sys-SDL_RenderFillRect

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
#sys-SDL_SetTextureColorMod

::SDL_Init sys-SDL_Init sys1 drop ;
::SDL_Quit sys-SDL_Quit sys0 drop ;
::SDL_GetNumVideoDisplays sys-SDL_GetNumVideoDisplays sys0 ;
::SDL_CreateWindow sys-SDL_CreateWindow sys6 ;
::SDL_SetWindowFullscreen sys-SDL_SetWindowFullscreen sys2 drop ;

::SDL_GetWindowSurface sys-SDL_GetWindowSurface sys1 ;
::SDL_ShowCursor sys-SDL_ShowCursor sys1 drop ;
::SDL_UpdateWindowSurface sys-SDL_UpdateWindowSurface sys1 drop ;
::SDL_DestroyWindow sys-SDL_DestroyWindow sys1 drop ;
::SDL_CreateRenderer sys-SDL_CreateRenderer sys3 ;
::SDL_CreateTexture sys-SDL_CreateTexture sys5 ;
::SDL_QueryTexture sys-SDL_QueryTexture sys5 drop ;
::SDL_SetTextureColorMod sys-SDL_SetTextureColorMod sys4 drop ;
::SDL_DestroyTexture sys-SDL_DestroyTexture sys1 drop ;
::SDL_DestroyRenderer sys-SDL_DestroyRenderer sys1 ;
::SDL_UpdateTexture sys-SDL_UpdateTexture sys4 ;
::SDL_RenderClear sys-SDL_RenderClear sys1 drop ;
::SDL_RenderCopy sys-SDL_RenderCopy sys4 drop ;
::SDL_RenderCopyEx sys-SDL_RenderCopyEx sys7 drop ;
::SDL_RenderPresent sys-SDL_RenderPresent sys1 drop ;
::SDL_CreateTextureFromSurface sys-SDL_CreateTextureFromSurface sys2 ;
::SDL_SetRenderDrawColor sys-SDL_SetRenderDrawColor sys5 drop ; 
::SDL_FreeSurface sys-SDL_FreeSurface sys1 drop ;
::SDL_LockTexture sys-SDL_LockTexture sys4 drop ;
::SDL_UnlockTexture sys-SDL_UnlockTexture sys1 drop ;
::SDL_RenderSetLogicalSize sys-SDL_RenderSetLogicalSize sys3 drop ;
::SDL_SetRenderDrawBlendMode sys-SDL_SetRenderDrawBlendMode sys2 drop ;

::SDL_RenderDrawPoint sys-SDL_RenderDrawPoint sys3 drop ;
::SDL_RenderDrawLine sys-SDL_RenderDrawLine sys5 drop ;
::SDL_RenderDrawRect sys-SDL_RenderDrawRect sys2 drop ;
::SDL_RenderFillRect sys-SDL_RenderFillRect sys2 drop ;

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

|----------------------------------------------------------
	
##SDL_windows
##SDL_screen
##SDLrenderer

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

	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	|0 SDL_ShowCursor | disable cursor
	;
	
::SDLfull | --
	SDL_windows 1 SDL_SetWindowFullscreen ;
	
::SDLframebuffer | w h --
	>r >r SDLrenderer $16362004 1 r> r> SDL_CreateTexture ;
	
| SDL_WINDOW_FULLSCREEN = 0x00000001,
| SDL_WINDOW_OPENGL = 0x00000002,
| SDL_WINDOW_SHOWN = 0x00000004,
| SDL_WINDOW_HIDDEN = 0x00000008,
| SDL_WINDOW_BORDERLESS = 0x00000010,
| SDL_WINDOW_RESIZABLE = 0x00000020,
| SDL_WINDOW_MINIMIZED = 0x00000040,
| SDL_WINDOW_MAXIMIZED = 0x00000080,
| SDL_WINDOW_INPUT_GRABBED = 0x00000100,
| SDL_WINDOW_INPUT_FOCUS = 0x00000200,
| SDL_WINDOW_MOUSE_FOCUS = 0x00000400,
| SDL_WINDOW_FULLSCREEN_DESKTOP = ( SDL_WINDOW_FULLSCREEN | 0x00001000 ),
| SDL_WINDOW_FOREIGN = 0x00000800,
| SDL_WINDOW_ALLOW_HIGHDPI = 0x00002000,
| SDL_WINDOW_MOUSE_CAPTURE = 0x00004000,
| SDL_WINDOW_ALWAYS_ON_TOP = 0x00008000,
| SDL_WINDOW_SKIP_TASKBAR = 0x00010000,
| SDL_WINDOW_UTILITY = 0x00020000,
| SDL_WINDOW_TOOLTIP = 0x00040000,
| SDL_WINDOW_POPUP_MENU = 0x00080000,
 | | SDL_WINDOW_VULKAN = 0x10000000
  
::SDLinitGL | "titulo" w h --
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 $1FFF0000 sw sh 6 SDL_CreateWindow dup 'SDL_windows ! 
	SDL_GetWindowSurface dup 'SDL_screen !
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	;
	
::SDLquit
	SDL_windows SDL_DestroyWindow 
	SDL_Quit ;
	
::SDLredraw
	SDL_windows SDL_UpdateWindowSurface 
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
		
		
##.exit 0

::SDLshow | 'word --
	0 '.exit !
	( .exit 0? drop
		SDLupdate
		dup ex ) 2drop
	0 '.exit ! ;

::exit
	1 '.exit ! ;
		

::SDLcolor | col --
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;

::SDLPoint | x y --
	SDLRenderer rot rot SDL_RenderDrawPoint ;
	
::SDLLine | x y x y --	
	>r >r >r >r SDLRenderer r> r> r> r> SDL_RenderDrawLine ;

#rec [ 0 0 0 0 ]

::SDLFillRect | x y w h --	
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderFillRect ;
	
|------- BOOT
:
	"SDL2.DLL" loadlib
	dup "SDL_Init" getproc 'sys-SDL_Init !
	dup "SDL_Quit" getproc 'sys-SDL_Quit !
	dup "SDL_GetNumVideoDisplays" getproc 'sys-SDL_GetNumVideoDisplays !
	dup "SDL_CreateWindow" getproc 'sys-SDL_CreateWindow !
	dup "SDL_SetWindowFullscreen" getproc 'sys-SDL_SetWindowFullscreen !
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
	dup "SDL_RenderCopyEx" getproc 'sys-SDL_RenderCopyEx !
	dup "SDL_RenderPresent" getproc 'sys-SDL_RenderPresent !
	dup "SDL_CreateTextureFromSurface" getproc 'sys-SDL_CreateTextureFromSurface !
	dup "SDL_QueryTexture" getproc 'sys-SDL_QueryTexture !
	dup "SDL_SetTextureColorMod" getproc 'sys-SDL_SetTextureColorMod !
	dup "SDL_SetRenderDrawColor" getproc 'sys-SDL_SetRenderDrawColor !
	dup "SDL_FreeSurface" getproc 'sys-SDL_FreeSurface !
	dup "SDL_LockTexture" getproc 'sys-SDL_LockTexture !
	dup "SDL_UnlockTexture" getproc 'sys-SDL_UnlockTexture !
	dup "SDL_RenderSetLogicalSize" getproc 'sys-SDL_RenderSetLogicalSize !
	dup "SDL_SetRenderDrawBlendMode" getproc 'sys-SDL_SetRenderDrawBlendMode !
	dup "SDL_RenderDrawPoint" getproc 'sys-SDL_RenderDrawPoint !
	dup "SDL_RenderDrawLine" getproc 'sys-SDL_RenderDrawLine !
	dup "SDL_RenderDrawRect" getproc 'sys-SDL_RenderDrawRect !
	dup "SDL_RenderFillRect" getproc 'sys-SDL_RenderFillRect !

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