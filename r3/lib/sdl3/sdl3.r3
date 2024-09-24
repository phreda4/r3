| SDL3.dll
| IMHO adding float parameters is not a good idea 
| pause this dev
^r3/lib/win/kernel32.r3
^r3/lib/win/core.r3
^r3/lib/console.r3
^r3/lib/sdlkeys.r3

#sys-SDL_Init 
#sys-SDL_Quit 
#sys-SDL_ShowWindow

#sys-SDL_CreateWindow 
#sys-SDL_SetWindowFullscreen
#sys-SDL_GetWindowSurface 
#sys-SDL_RaiseWindow
#sys-SDL_ShowCursor 
#sys-SDL_UpdateWindowSurface 
#sys-SDL_DestroyWindow 
#sys-SDL_CreateRenderer 
#sys-SDL_CreateTexture 
#sys-SDL_DestroyTexture 
#sys-SDL_DestroyRenderer 
#sys-SDL_UpdateTexture 
#sys-SDL_RenderClear
|#sys-SDL_RenderCopy 
|#sys-SDL_RenderCopyEx
#sys-SDL_RenderPresent 
#sys-SDL_SetRenderDrawColor
#sys-SDL_GetRenderDrawColor
#sys-SDL_CreateTextureFromSurface
#sys-SDL_QueryTexture
#sys-SDL_CreateRGBSurface 
#sys-SDL_LockSurface
#sys-SDL_UnlockSurface
#sys-SDL_BlitSurface
#sys-SDL_SetSurfaceBlendMode
#sys-SDL_FreeSurface
#sys-SDL_LockTexture
#sys-SDL_UnlockTexture
#sys-SDL_RenderSetLogicalSize
#sys-SDL_SetRenderDrawBlendMode
#sys-SDL_SetTextureBlendMode
#sys-SDL_ConvertSurfaceFormat

#sys-SDL_RenderDrawPoint
#sys-SDL_RenderDrawLine
#sys-SDL_RenderDrawRect
#sys-SDL_RenderFillRect
#sys-SDL_RenderGeometry
#sys-SDL_RenderReadPixels
#sys-SDL_RenderSetClipRect

#sys-SDL_Delay
#sys-SDL_PollEvent	
#sys-SDL_GetTicks

#sys-SDL_RWFromFile

#sys-SDL_GL_SetAttribute
#sys-SDL_GL_CreateContext
#sys-SDL_GL_DeleteContext
#sys-SDL_GL_SetSwapInterval
#sys-SDL_GL_SwapWindow
#sys-SDL_GL_MakeCurrent
#sys-SDL_GL_LoadLibrary
#sys-SDL_GL_GetProcAddress

#sys-SDL_SetTextureColorMod
#sys-SDL_SetTextureAlphaMod
#sys-SDL_SetHint

#names
"SDL_Init"
"SDL_Quit"
"SDL_ShowWindow"

"SDL_CreateWindow"
"SDL_SetWindowFullscreen"
"SDL_GetWindowSurface"
"SDL_RaiseWindow"
"SDL_ShowCursor"
"SDL_UpdateWindowSurface"
"SDL_DestroyWindow"
"SDL_CreateRenderer"
"SDL_CreateTexture"
"SDL_DestroyTexture"
"SDL_DestroyRenderer"
"SDL_UpdateTexture"
"SDL_RenderClear"
|"SDL_RenderCopy"
|"SDL_RenderCopyEx"
"SDL_RenderPresent"
"SDL_SetRenderDrawColor"
"SDL_GetRenderDrawColor"
"SDL_CreateTextureFromSurface"
"SDL_QueryTexture"
"SDL_CreateRGBSurface"
"SDL_LockSurface"
"SDL_UnlockSurface"
"SDL_BlitSurface"
"SDL_SetSurfaceBlendMode"
"SDL_FreeSurface"
"SDL_LockTexture"
"SDL_UnlockTexture"
"SDL_RenderSetLogicalSize"
"SDL_SetRenderDrawBlendMode"
"SDL_SetTextureBlendMode"
"SDL_ConvertSurfaceFormat"

"SDL_RenderDrawPoint"
"SDL_RenderDrawLine"
"SDL_RenderDrawRect"
"SDL_RenderFillRect"
"SDL_RenderGeometry"
"SDL_RenderReadPixels"
"SDL_RenderSetClipRect"

"SDL_Delay"
"SDL_PollEvent	"
"SDL_GetTicks"

"SDL_RWFromFile"

"SDL_GL_SetAttribute"
"SDL_GL_CreateContext"
"SDL_GL_DeleteContext"
"SDL_GL_SetSwapInterval"
"SDL_GL_SwapWindow"
"SDL_GL_MakeCurrent"
"SDL_GL_LoadLibrary"
"SDL_GL_GetProcAddress"

"SDL_SetTextureColorMod"
"SDL_SetTextureAlphaMod"
"SDL_SetHint"


::SDL_Init sys-SDL_Init sys1 ;
::SDL_Quit sys-SDL_Quit sys0 drop ;
::SDL_ShowWindow sys-SDL_ShowWindow sys1 drop ;

::SDL_CreateWindow sys-SDL_CreateWindow sys4 ;
::SDL_SetWindowFullscreen sys-SDL_SetWindowFullscreen sys2 drop ;
::SDL_RaiseWindow sys-SDL_RaiseWindow sys1 drop ;
::SDL_GetWindowSurface sys-SDL_GetWindowSurface sys1 ;
::SDL_ShowCursor sys-SDL_ShowCursor sys1 drop ;
::SDL_UpdateWindowSurface sys-SDL_UpdateWindowSurface sys1 drop ;
::SDL_DestroyWindow sys-SDL_DestroyWindow sys1 drop ;
::SDL_CreateRenderer sys-SDL_CreateRenderer sys3 ;
::SDL_CreateTexture sys-SDL_CreateTexture sys5 ;
::SDL_QueryTexture sys-SDL_QueryTexture sys5 drop ;
::SDL_SetTextureColorMod sys-SDL_SetTextureColorMod sys4 drop ;
::SDL_SetTextureAlphaMod sys-SDL_SetTextureAlphaMod sys2 drop ;
::SDL_DestroyTexture sys-SDL_DestroyTexture sys1 drop ;
::SDL_DestroyRenderer sys-SDL_DestroyRenderer sys1 drop ;
::SDL_UpdateTexture sys-SDL_UpdateTexture sys4 ;
::SDL_RenderClear sys-SDL_RenderClear sys1 drop ;
|::SDL_RenderCopy sys-SDL_RenderCopy sys4 drop ;
|::SDL_RenderCopyEx sys-SDL_RenderCopyEx sys7 drop ; |sys6f1 drop ;
::SDL_RenderPresent sys-SDL_RenderPresent sys1 drop ;
::SDL_CreateTextureFromSurface sys-SDL_CreateTextureFromSurface sys2 ;
::SDL_SetRenderDrawColor sys-SDL_SetRenderDrawColor sys5 drop ; 
::SDL_GetRenderDrawColor sys-SDL_GetRenderDrawColor sys5 drop ; 
::SDL_CreateRGBSurface sys-SDL_CreateRGBSurface sys8 ;
::SDL_LockSurface sys-SDL_LockSurface sys1 drop ;
::SDL_UnlockSurface sys-SDL_UnlockSurface sys1 drop ;
::SDL_BlitSurface sys-SDL_BlitSurface sys4 drop ;
::SDL_SetSurfaceBlendMode sys-SDL_SetSurfaceBlendMode sys2 drop ;
::SDL_FreeSurface sys-SDL_FreeSurface sys1 drop ;
::SDL_LockTexture sys-SDL_LockTexture sys4 drop ;
::SDL_UnlockTexture sys-SDL_UnlockTexture sys1 drop ;
::SDL_RenderSetLogicalSize sys-SDL_RenderSetLogicalSize sys3 drop ;
::SDL_SetRenderDrawBlendMode sys-SDL_SetRenderDrawBlendMode sys2 drop ;
::SDL_SetTextureBlendMode sys-SDL_SetTextureBlendMode sys2 drop ;
::SDL_ConvertSurfaceFormat sys-SDL_ConvertSurfaceFormat sys3 ;

::SDL_RenderDrawPoint sys-SDL_RenderDrawPoint sys3 drop ;
::SDL_RenderDrawLine sys-SDL_RenderDrawLine sys5 drop ;
::SDL_RenderDrawRect sys-SDL_RenderDrawRect sys2 drop ;
::SDL_RenderFillRect sys-SDL_RenderFillRect sys2 drop ;
::SDL_RenderGeometry sys-SDL_RenderGeometry sys6 drop ;
::SDL_RenderReadPixels sys-SDL_RenderReadPixels sys5 drop ;
::SDL_RenderSetClipRect sys-SDL_RenderSetClipRect sys2 drop ;

::SDL_Delay sys-SDL_Delay sys1 drop ;
::SDL_PollEvent sys-SDL_PollEvent sys1 ; | &evt -- ok
::SDL_GetTicks sys-SDL_GetTicks sys0 ; | -- msec

|::SDL_StartTextInput sys-SDL_StartTextInput sys0 drop ;
|::SDL_StopTextInput sys-SDL_StopTextInput sys0 drop ;

::SDL_RWFromFile sys-SDL_RWFromFile sys2 ;

::SDL_GL_SetAttribute sys-SDL_GL_SetAttribute sys2 drop ;
::SDL_GL_CreateContext sys-SDL_GL_CreateContext sys1 ;
::SDL_GL_DeleteContext sys-SDL_GL_DeleteContext sys1 drop ;
::SDL_GL_SetSwapInterval sys-SDL_GL_SetSwapInterval sys1 drop ;
::SDL_GL_SwapWindow sys-SDL_GL_SwapWindow sys1 drop ;
::SDL_GL_LoadLibrary sys-SDL_GL_LoadLibrary sys1 drop ;
::SDL_GL_GetProcAddress sys-SDL_GL_GetProcAddress sys1 ;

::SDL_GL_MakeCurrent sys-SDL_GL_MakeCurrent sys2 drop ; 
::SDL_SetHint sys-SDL_SetHint sys2 drop ; 

|----------------------------------------------------------
	
##sdlwin
##sdlscr
##sw
##sh

##SDL_INIT_TIMER     $00000001
##SDL_INIT_AUDIO     $00000010
##SDL_INIT_VIDEO     $00000020
##SDL_INIT_JOYSTICK  $00000200
##SDL_INIT_HAPTIC    $00001000
##SDL_INIT_GAMEPAD   $00002000
##SDL_INIT_EVENTS    $00004000
##SDL_INIT_SENSOR    $00008000
##SDL_INIT_CAMERA    $00010000

##SDL_WINDOW_FULLSCREEN         $00000001 |window is in fullscreen mode
##SDL_WINDOW_OPENGL             $00000002 |window usable with OpenGL context
##SDL_WINDOW_OCCLUDED           $00000004 |window is occluded
##SDL_WINDOW_HIDDEN             $00000008 |window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; SDL_ShowWindow() is required for it to become visible
##SDL_WINDOW_BORDERLESS         $00000010 |no window decoration
##SDL_WINDOW_RESIZABLE          $00000020 |window can be resized
##SDL_WINDOW_MINIMIZED          $00000040 |window is minimized
##SDL_WINDOW_MAXIMIZED          $00000080 |window is maximized
##SDL_WINDOW_MOUSE_GRABBED      $00000100 |window has grabbed mouse input
##SDL_WINDOW_INPUT_FOCUS        $00000200 |window has input focus
##SDL_WINDOW_MOUSE_FOCUS        $00000400 |window has mouse focus
##SDL_WINDOW_EXTERNAL           $00000800 |window not created by SDL
##SDL_WINDOW_HIGH_PIXEL_DENSITY $00002000 |window uses high pixel density back buffer if possible
##SDL_WINDOW_MOUSE_CAPTURE      $00004000 |window has mouse captured (unrelated to MOUSE_GRABBED)
##SDL_WINDOW_ALWAYS_ON_TOP      $00008000 |window should always be above others
##SDL_WINDOW_UTILITY            $00020000 |window should be treated as a utility window, not showing in the task bar and window list
##SDL_WINDOW_TOOLTIP            $00040000 |window should be treated as a tooltip and does not get mouse or keyboard focus, requires a parent window
##SDL_WINDOW_POPUP_MENU         $00080000 |window should be treated as a popup menu, requires a parent window
##SDL_WINDOW_KEYBOARD_GRABBED   $00100000 |window has grabbed keyboard input
##SDL_WINDOW_VULKAN             $10000000 |window usable for Vulkan surface
##SDL_WINDOW_METAL              $20000000 |window usable for Metal view
##SDL_WINDOW_TRANSPARENT        $40000000 |window with transparent buffer
##SDL_WINDOW_NOT_FOCUSABLE      $80000000 |window should not be focusable

##SDL_RENDERER_PRESENTVSYNC $00000004  | Present is synchronized with the refresh rate 

::SDLInit | "" w h --
	SDL_INIT_AUDIO SDL_INIT_VIDEO or SDL_INIT_EVENTS or SDL_Init 1? ( 4drop ; ) drop
	2dup 'sh ! 'sw !
	0 SDL_CreateWindow 'sdlwin !
	sdlwin SDL_ShowWindow
	sdlwin 0 SDL_RENDERER_PRESENTVSYNC
	SDL_CreateRenderer 'sdlscr !
	;

::SDLquit
	sdlscr SDL_DestroyRenderer
	sdlwin SDL_DestroyWindow 
	SDL_Quit ;
	
##SDLevent * 128

##SDLkey
##SDLchar
##SDLx ##SDLy ##SDLb
	
::SDLupdate
	0 'SDLkey !
	0 'SDLchar !
	10 SDL_delay
	( 'SDLevent SDL_PollEvent 1? drop 
		'SDLevent d@ 
		$300 =? ( drop 'SDLevent 32 + d@ dup $ffff and swap 16 >> or 'SDLkey ! ; ) |#SDL_KEYDOWN $300 
		$301 =? ( drop 'SDLevent 32 + d@ dup $ffff and swap 16 >> or $1000 or 'SDLkey ! ; ) |#SDL_KEYUP $301 
		$303 =? ( drop 'SDLevent 20 + c@ 'SDLchar ! ; ) |#SDL_TEXTINPUT	$303 |Keyboard text input
		$400 =? ( drop 'SDLevent 28 + d@+ fp2f 16 >> 'SDLx ! d@ fp2f 16 >> 'SDLy ! ; ) |#SDL_MOUSEMOTION	$400 Mouse moved
		$401 =? ( drop 'SDLevent 24 + c@ 1 - 1 swap << SDLb or 'SDLb ! ; ) |#SDL_MOUSEBUTTONDOWN $401 pressed
		$402 =? ( drop 'SDLevent 24 + c@ 1 - 1 swap << not SDLb and 'SDLb ! ; ) |#SDL_MOUSEBUTTONUP $402 released
				| #SDL_MOUSEWHEEL $403 Mouse wheel motion
		drop
		) drop ;			
		
#clickb 0
		
::SDLClick | 'event --
	SDLb 1? ( 'clickb ! drop ; ) drop
	clickb 0? ( 2drop ; ) drop
	ex 
	0 'clickb !
	;
	
##.exit 0

::SDLshow | 'word --
	0 '.exit !
	( .exit 0? drop
		SDLupdate
		dup ex ) 2drop
	SDLupdate
	0 '.exit ! ;

::exit
	1 '.exit ! ;
	
::SDLredraw | -- 
	sdlscr SDL_RenderPresent ;	
	
:rgb23 | rgb -- r g b
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and ;

:rgb24 | argb -- r g b
	dup 16 >> $ff and swap dup 8 >> $ff and swap dup $ff and swap 24 >> $ff and ;
	
::SDLColor | col --
	sdlscr swap rgb23 $ff SDL_SetRenderDrawColor ;
	
::SDLcls | color --
	SDLColor sdlscr SDL_RenderClear ;	
	
|------- BOOT
:
	"SDL3.DLL" loadlib
	dup "SDL_Init" getproc 'sys-SDL_Init !
	dup "SDL_Quit" getproc 'sys-SDL_Quit !
	dup "SDL_ShowWindow" getproc 'sys-SDL_ShowWindow !
	
	dup "SDL_CreateWindow" getproc 'sys-SDL_CreateWindow !
	dup "SDL_SetWindowFullscreen" getproc 'sys-SDL_SetWindowFullscreen !
	dup "SDL_GetWindowSurface" getproc 'sys-SDL_GetWindowSurface !
	dup "SDL_ShowCursor" getproc 'sys-SDL_ShowCursor !
	
	dup "SDL_RaiseWindow" getproc 'sys-SDL_RaiseWindow !
	dup "SDL_UpdateWindowSurface" getproc 'sys-SDL_UpdateWindowSurface !
	dup "SDL_DestroyWindow" getproc 'sys-SDL_DestroyWindow !
	dup "SDL_CreateRenderer" getproc 'sys-SDL_CreateRenderer !
	dup "SDL_CreateTexture" getproc 'sys-SDL_CreateTexture !
	dup "SDL_DestroyTexture" getproc 'sys-SDL_DestroyTexture !
	dup "SDL_DestroyRenderer" getproc 'sys-SDL_DestroyRenderer !
	dup "SDL_UpdateTexture" getproc 'sys-SDL_UpdateTexture !
	dup "SDL_RenderClear" getproc 'sys-SDL_RenderClear !
|	dup "SDL_RenderCopy" getproc 'sys-SDL_RenderCopy !
|	dup "SDL_RenderCopyEx" getproc 'sys-SDL_RenderCopyEx !
	dup "SDL_RenderPresent" getproc 'sys-SDL_RenderPresent !
	dup "SDL_CreateTextureFromSurface" getproc 'sys-SDL_CreateTextureFromSurface !
	dup "SDL_QueryTexture" getproc 'sys-SDL_QueryTexture !
	dup "SDL_SetTextureColorMod" getproc 'sys-SDL_SetTextureColorMod !
	dup "SDL_SetTextureAlphaMod" getproc 'sys-SDL_SetTextureAlphaMod !
	dup "SDL_SetRenderDrawColor" getproc 'sys-SDL_SetRenderDrawColor !
	dup "SDL_GetRenderDrawColor" getproc 'sys-SDL_GetRenderDrawColor !
	dup "SDL_CreateRGBSurface" getproc 'sys-SDL_CreateRGBSurface !
	dup "SDL_LockSurface" getproc 'sys-SDL_LockSurface !
	dup "SDL_UnlockSurface" getproc 'sys-SDL_UnlockSurface !
	dup "SDL_UpperBlit" getproc 'sys-SDL_BlitSurface !
	dup "SDL_SetSurfaceBlendMode" getproc 'sys-SDL_SetSurfaceBlendMode !

	dup "SDL_FreeSurface" getproc 'sys-SDL_FreeSurface !
	dup "SDL_LockTexture" getproc 'sys-SDL_LockTexture !
	dup "SDL_UnlockTexture" getproc 'sys-SDL_UnlockTexture !
	dup "SDL_RenderSetLogicalSize" getproc 'sys-SDL_RenderSetLogicalSize !
	dup "SDL_SetRenderDrawBlendMode" getproc 'sys-SDL_SetRenderDrawBlendMode !
	dup "SDL_SetTextureBlendMode" getproc 'sys-SDL_SetTextureBlendMode !
	dup "SDL_ConvertSurfaceFormat" getproc 'sys-SDL_ConvertSurfaceFormat !
	dup "SDL_RenderDrawPoint" getproc 'sys-SDL_RenderDrawPoint !
	dup "SDL_RenderDrawLine" getproc 'sys-SDL_RenderDrawLine !
	dup "SDL_RenderDrawRect" getproc 'sys-SDL_RenderDrawRect !
	dup "SDL_RenderFillRect" getproc 'sys-SDL_RenderFillRect !
	dup "SDL_RenderGeometry" getproc 'sys-SDL_RenderGeometry !
	dup "SDL_RenderSetClipRect" getproc 'sys-SDL_RenderSetClipRect	!
	dup "SDL_RenderReadPixels" getproc 'sys-SDL_RenderReadPixels !
	dup "SDL_Delay" getproc 'sys-SDL_Delay !
	dup "SDL_PollEvent" getproc 'sys-SDL_PollEvent !
	dup "SDL_GetTicks" getproc 'sys-SDL_GetTicks !
	
	dup "SDL_RWFromFile" getproc 'sys-SDL_RWFromFile !
	
	dup "SDL_GL_SetAttribute" getproc 'sys-SDL_GL_SetAttribute !
	dup "SDL_GL_CreateContext" getproc 'sys-SDL_GL_CreateContext !
	dup "SDL_GL_DeleteContext" getproc 'sys-SDL_GL_DeleteContext !
	dup "SDL_GL_SetSwapInterval" getproc 'sys-SDL_GL_SetSwapInterval !
	dup "SDL_GL_SwapWindow" getproc 'sys-SDL_GL_SwapWindow	!
	dup "SDL_GL_MakeCurrent" getproc 'sys-SDL_GL_MakeCurrent ! 
	dup "SDL_SetHint" getproc 'sys-SDL_SetHint !
	dup "SDL_GL_LoadLibrary" getproc 'sys-SDL_GL_LoadLibrary !
	dup "SDL_GL_GetProcAddress" getproc 'sys-SDL_GL_GetProcAddress !
	
	drop
|	'names 'sys-SDL_Init
|	( 'sys-SDL_SetHint <? swap dup .print >>0 swap @+ " %h ) " .print ) 2drop
|	getch getch
	;