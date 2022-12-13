| SDL2.dll
|
^r3/win/kernel32.r3
^r3/win/core.r3
^r3/win/console.r3
^r3/lib/key.r3

#sys-SDL_Init 
#sys-SDL_Quit 
#sys-SDL_GetNumVideoDisplays 
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
#sys-SDL_RenderCopy 
#sys-SDL_RenderCopyEx
#sys-SDL_RenderPresent 
#sys-SDL_SetRenderDrawColor
#sys-SDL_CreateTextureFromSurface
#sys-SDL_QueryTexture
#sys-SDL_CreateRGBSurface 
#sys-SDL_LockSurface
#sys-SDL_UnlockSurface
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
#sys-SDL_StartTextInput	
#sys-SDL_StopTextInput

#sys-SDL_RWFromFile

#sys-SDL_GL_SetAttribute
#sys-SDL_GL_CreateContext
#sys-SDL_GL_DeleteContext
#sys-SDL_GL_SetSwapInterval
#sys-SDL_GL_SwapWindow
#sys-SDL_GL_MakeCurrent

#sys-SDL_SetTextureColorMod
#sys-SDL_SetHint

::SDL_Init sys-SDL_Init sys1 drop ;
::SDL_Quit sys-SDL_Quit sys0 drop ;
::SDL_GetNumVideoDisplays sys-SDL_GetNumVideoDisplays sys0 ;
::SDL_CreateWindow sys-SDL_CreateWindow sys6 ;
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
::SDL_DestroyTexture sys-SDL_DestroyTexture sys1 drop ;
::SDL_DestroyRenderer sys-SDL_DestroyRenderer sys1 drop ;
::SDL_UpdateTexture sys-SDL_UpdateTexture sys4 ;
::SDL_RenderClear sys-SDL_RenderClear sys1 drop ;
::SDL_RenderCopy sys-SDL_RenderCopy sys4 drop ;
::SDL_RenderCopyEx sys-SDL_RenderCopyEx sys7 drop ; |sys6f1 drop ;
::SDL_RenderPresent sys-SDL_RenderPresent sys1 drop ;
::SDL_CreateTextureFromSurface sys-SDL_CreateTextureFromSurface sys2 ;
::SDL_SetRenderDrawColor sys-SDL_SetRenderDrawColor sys5 drop ; 
::SDL_CreateRGBSurface sys-SDL_CreateRGBSurface sys8 ;
::SDL_LockSurface sys-SDL_LockSurface sys1 drop ;
::SDL_UnlockSurface sys-SDL_UnlockSurface sys1 drop ;
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
::SDL_StartTextInput sys-SDL_StartTextInput sys0 drop ;
::SDL_StopTextInput sys-SDL_StopTextInput sys0 drop ;

::SDL_RWFromFile sys-SDL_RWFromFile sys2 ;

::SDL_GL_SetAttribute sys-SDL_GL_SetAttribute sys2 drop ;
::SDL_GL_CreateContext sys-SDL_GL_CreateContext sys1 ;
::SDL_GL_DeleteContext sys-SDL_GL_DeleteContext sys1 drop ;
::SDL_GL_SetSwapInterval sys-SDL_GL_SetSwapInterval sys1 drop ;
::SDL_GL_SwapWindow sys-SDL_GL_SwapWindow sys1 drop ;

::SDL_GL_MakeCurrent sys-SDL_GL_MakeCurrent sys2 drop ; 
::SDL_SetHint sys-SDL_SetHint sys2 drop ; 

|----------------------------------------------------------
	
##SDL_windows
##SDL_screen
##SDLrenderer

##sw
##sh

::SDLinit | "titulo" w h --
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 dup sw sh $0 SDL_CreateWindow dup 'SDL_windows !
	SDL_GetWindowSurface 'SDL_screen !
|	0 SDL_ShowCursor | disable cursor
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	SDL_windows SDL_RaiseWindow
	;

::SDLmini | "" w h --
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 dup sw sh $0 SDL_CreateWindow dup 'SDL_windows !
	SDL_GetWindowSurface 'SDL_screen !
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	;

|int displays=SDL_GetNumVideoDisplays()-1;
|	window=SDL_CreateWindow(title,
|		SDL_WINDOWPOS_CENTERED_DISPLAY(displays),
|		SDL_WINDOWPOS_CENTERED_DISPLAY(displays),XRES,YRES,
|		SDL_WINDOW_FULLSCREEN_DESKTOP | SDL_WINDOW_SHOWN);
|	screen = SDL_GetWindowSurface(window);
|	XRES=screen->w;
|	YRES=screen->h;

::SDLinitScr | "titulo" display w h --
	'sh ! 'sw !
	$3231 SDL_init 
	$2fff0000 or dup 
|	$1FFF0000 dup
	sw sh $0 SDL_CreateWindow dup 'SDL_windows !
	SDL_GetWindowSurface 'SDL_screen !
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	SDL_windows SDL_RaiseWindow
	;

::SDLinitGL | "titulo" w h --
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 dup
	sw sh $6 SDL_CreateWindow dup 'SDL_windows ! 
	SDL_GetWindowSurface 'SDL_screen !
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	SDL_windows SDL_RaiseWindow
	;
	
	
::SDLfull | --
	SDL_windows 1 SDL_SetWindowFullscreen ;
	
::SDLframebuffer | w h -- texture
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
| SDL_WINDOW_VULKAN = 0x10000000
  
::SDLquit
	SDLrenderer SDL_DestroyRenderer
	SDL_windows SDL_DestroyWindow 
	SDL_Quit ;
	
##SDLevent * 56 

##SDLkey
##SDLchar
##SDLx ##SDLy ##SDLb
	
::SDLupdate
	0 'SDLkey !
	0 'SDLchar !
	10 SDL_delay
	( 'SDLevent SDL_PollEvent 1? drop 
		'SDLevent d@ 
		$300 =? ( drop 'SDLevent 20 + d@ dup $ffff and swap 16 >> or 'SDLkey ! ; ) |#SDL_KEYDOWN $300 
		$301 =? ( drop 'SDLevent 20 + d@ dup $ffff and swap 16 >> or $1000 or 'SDLkey ! ; ) |#SDL_KEYUP $301 
		$303 =? ( drop 'SDLevent 12 + c@ 'SDLchar ! ; ) |#SDL_TEXTINPUT	$303 |Keyboard text input
		$400 =? ( drop 'SDLevent 20 + d@+ 'SDLx ! d@ 'SDLy ! ; ) |#SDL_MOUSEMOTION	$400 Mouse moved
		$401 =? ( drop 'SDLevent 16 + c@ SDLb or 'SDLb ! ; ) |#SDL_MOUSEBUTTONDOWN $401 Mouse but pressed
		$402 =? ( drop 'SDLevent 16 + c@ not SDLb and 'SDLb ! ; ) |#SDL_MOUSEBUTTONUP $402 Mouse but released
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
	
#rec [ 0 0 1 1 ]
#cc
	
::SDLGetPixel | x y -- v
	swap 'rec d!+ d!
	SDLrenderer 'rec $16362004 'cc 1 SDL_RenderReadPixels 
	cc $ffffff and ;
	
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
	
	dup "SDL_RaiseWindow" getproc 'sys-SDL_RaiseWindow !
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
	dup "SDL_CreateRGBSurface" getproc 'sys-SDL_CreateRGBSurface !
	dup "SDL_LockSurface" getproc 'sys-SDL_LockSurface !
	dup "SDL_UnlockSurface" getproc 'sys-SDL_UnlockSurface !
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
	drop
	;