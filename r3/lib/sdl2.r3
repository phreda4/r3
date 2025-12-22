| SDL2.dll
| PHREDA 2024

|WIN|^r3/lib/win/core.r3
|LIN|^r3/lib/posix/core.r3

^r3/lib/console.r3
^r3/lib/sdlkeys.r3

#sys-SDL_Init 
#sys-SDL_GetCurrentDisplayMode
#sys-SDL_Quit 
#sys-SDL_GetNumVideoDisplays 
#sys-SDL_CreateWindow 
#sys-SDL_SetWindowFullscreen
#sys-SDL_RenderSetLogicalSize
#sys-SDL_GetWindowSurface 
#sys-SDL_RaiseWindow
#sys-SDL_GetWindowSize
#sys-SDL_SetWindowSize
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
#sys-SDL_GetRenderDrawColor
#sys-SDL_CreateTextureFromSurface
#sys-SDL_CreateRGBSurfaceWithFormatFrom
#sys-SDL_CreateRGBSurfaceWithFormat
#sys-SDL_QueryTexture
#sys-SDL_CreateRGBSurface 
#sys-SDL_LockSurface
#sys-SDL_UnlockSurface
#sys-SDL_BlitSurface
#sys-SDL_SetSurfaceBlendMode
#sys-SDL_FillRect
#sys-SDL_FreeSurface
#sys-SDL_LockTexture
#sys-SDL_UnlockTexture
#sys-SDL_SetRenderDrawBlendMode
#sys-SDL_SetTextureBlendMode
#sys-SDL_SetSurfaceAlphaMod
#sys-SDL_ConvertSurfaceFormat
#sys-SDL_UpdateYUVTexture

#sys-SDL_RenderDrawPoint
#sys-SDL_RenderDrawPoints
#sys-SDL_RenderDrawLine
#sys-SDL_RenderDrawRect
#sys-SDL_RenderFillRect
#sys-SDL_RenderGeometry
#sys-SDL_RenderReadPixels
#sys-SDL_RenderSetClipRect
#sys-SDL_SetTextureScaleMode
#sys-SDL_SetRenderTarget

#sys-SDL_Delay
#sys-SDL_PollEvent	
#sys-SDL_GetTicks
|#sys-SDL_StartTextInput	
|#sys-SDL_StopTextInput

#sys-SDL_RWFromFile
#sys-SDL_RWclose

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
#sys-SDL_GetError

#sys-SDL_OpenAudioDevice
#sys-SDL_QueueAudio
#sys-SDL_GetQueuedAudioSize
#sys-SDL_PauseAudioDevice
#sys-SDL_CloseAudioDevice

#sys-SDL_GetClipboardText
#sys-SDL_HasClipboardText
#sys-SDL_SetClipboardText
#sys-SDL_free

::SDL_Init sys-SDL_Init sys1 drop ;
::SDL_GetCurrentDisplayMode sys-SDL_GetCurrentDisplayMode sys2 drop ;
::SDL_Quit sys-SDL_Quit sys0 drop ;
::SDL_GetNumVideoDisplays sys-SDL_GetNumVideoDisplays sys0 ;
::SDL_CreateWindow sys-SDL_CreateWindow sys6 ;
::SDL_SetWindowFullscreen sys-SDL_SetWindowFullscreen sys2 drop ;
::SDL_RenderSetLogicalSize sys-SDL_RenderSetLogicalSize sys3 drop ;
::SDL_RaiseWindow sys-SDL_RaiseWindow sys1 drop ;
::SDL_GetWindowSize sys-SDL_GetWindowSize sys3 drop ;
::SDL_SetWindowSize sys-SDL_SetWindowSize sys3 drop ;
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
::SDL_RenderCopy sys-SDL_RenderCopy sys4 drop ;
::SDL_RenderCopyEx sys-SDL_RenderCopyEx sys7 drop ; |sys6f1 drop ;
::SDL_RenderPresent sys-SDL_RenderPresent sys1 drop ;
::SDL_CreateTextureFromSurface sys-SDL_CreateTextureFromSurface sys2 ;
::SDL_CreateRGBSurfaceWithFormatFrom sys-SDL_CreateRGBSurfaceWithFormatFrom sys6 ;
::SDL_CreateRGBSurfaceWithFormat sys-SDL_CreateRGBSurfaceWithFormat sys5 ;
::SDL_SetRenderDrawColor sys-SDL_SetRenderDrawColor sys5 drop ; 
::SDL_GetRenderDrawColor sys-SDL_GetRenderDrawColor sys5 drop ; 
::SDL_CreateRGBSurface sys-SDL_CreateRGBSurface sys8 ;
::SDL_LockSurface sys-SDL_LockSurface sys1 drop ;
::SDL_UnlockSurface sys-SDL_UnlockSurface sys1 drop ;
::SDL_BlitSurface sys-SDL_BlitSurface sys4 drop ;
::SDL_SetSurfaceBlendMode sys-SDL_SetSurfaceBlendMode sys2 drop ;
::SDL_SetSurfaceAlphaMod sys-SDL_SetSurfaceAlphaMod sys2 drop ;
::SDL_FillRect sys-SDL_FillRect sys3 drop ;

::SDL_FreeSurface sys-SDL_FreeSurface sys1 drop ;
::SDL_LockTexture sys-SDL_LockTexture sys4 drop ;
::SDL_UnlockTexture sys-SDL_UnlockTexture sys1 drop ;
::SDL_SetRenderDrawBlendMode sys-SDL_SetRenderDrawBlendMode sys2 drop ;
::SDL_SetTextureBlendMode sys-SDL_SetTextureBlendMode sys2 drop ;
::SDL_ConvertSurfaceFormat sys-SDL_ConvertSurfaceFormat sys3 ;
::SDL_UpdateYUVTexture sys-SDL_UpdateYUVTexture sys8 drop ;

::SDL_RenderDrawPoint sys-SDL_RenderDrawPoint sys3 drop ;
::SDL_RenderDrawPoints sys-SDL_RenderDrawPoints sys3 drop ;
::SDL_RenderDrawLine sys-SDL_RenderDrawLine sys5 drop ;
::SDL_RenderDrawRect sys-SDL_RenderDrawRect sys2 drop ;
::SDL_RenderFillRect sys-SDL_RenderFillRect sys2 drop ;
::SDL_RenderGeometry sys-SDL_RenderGeometry sys6 drop ;
::SDL_RenderReadPixels sys-SDL_RenderReadPixels sys5 drop ;
::SDL_RenderSetClipRect sys-SDL_RenderSetClipRect sys2 drop ;
::SDL_SetTextureScaleMode sys-SDL_SetTextureScaleMode sys2 drop ;
::SDL_SetRenderTarget sys-SDL_SetRenderTarget sys2 drop ;

::SDL_Delay sys-SDL_Delay sys1 drop ;
::SDL_PollEvent sys-SDL_PollEvent sys1 ; | &evt -- ok
::SDL_GetTicks sys-SDL_GetTicks sys0 ; | -- msec

|::SDL_StartTextInput sys-SDL_StartTextInput sys0 drop ;
|::SDL_StopTextInput sys-SDL_StopTextInput sys0 drop ;

::SDL_RWFromFile sys-SDL_RWFromFile sys2 ;
::SDL_RWclose sys-SDL_RWclose sys1 drop ;

::SDL_GL_SetAttribute sys-SDL_GL_SetAttribute sys2 drop ;
::SDL_GL_CreateContext sys-SDL_GL_CreateContext sys1 ;
::SDL_GL_DeleteContext sys-SDL_GL_DeleteContext sys1 drop ;
::SDL_GL_SetSwapInterval sys-SDL_GL_SetSwapInterval sys1 drop ;
::SDL_GL_SwapWindow sys-SDL_GL_SwapWindow sys1 drop ;
::SDL_GL_LoadLibrary sys-SDL_GL_LoadLibrary sys1 drop ;
::SDL_GL_GetProcAddress sys-SDL_GL_GetProcAddress sys1 ;

::SDL_GL_MakeCurrent sys-SDL_GL_MakeCurrent sys2 drop ; 
::SDL_SetHint sys-SDL_SetHint sys2 drop ; 
::SDL_GetError sys-SDL_GetError sys0 ;

::SDL_OpenAudioDevice sys-SDL_OpenAudioDevice sys5 ; 
::SDL_QueueAudio sys-SDL_QueueAudio sys3 drop ;
::SDL_GetQueuedAudioSize sys-SDL_GetQueuedAudioSize sys1 ;
::SDL_PauseAudioDevice sys-SDL_PauseAudioDevice sys2 drop ;
::SDL_CloseAudioDevice sys-SDL_CloseAudioDevice sys1 drop ;

::SDL_GetClipboardText sys-SDL_GetClipboardText sys0 ;
::SDL_HasClipboardText sys-SDL_HasClipboardText sys0 ;
::SDL_SetClipboardText sys-SDL_SetClipboardText sys1 ;
::SDL_free sys-SDL_free sys1 drop ;

|----------------------------------------------------------
	
##SDL_windows
##SDLrenderer

##sw
##sh

::SDLinit | "titulo" w h --
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 dup sw sh $0 SDL_CreateWindow dup 'SDL_windows !
	-1 0 SDL_CreateRenderer 'SDLrenderer !
	SDL_windows SDL_RaiseWindow
	;

::SDLmini | "titulo" w h --
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 dup sw sh $0 SDL_CreateWindow dup 'SDL_windows !
	-1 0 SDL_CreateRenderer 'SDLrenderer !
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
	dup -1 0 SDL_CreateRenderer 'SDLrenderer !
	SDL_RaiseWindow
	;
	
::sdlinitR | "titulo" w h -- | resize windows
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 dup sw sh $20 SDL_CreateWindow dup 'SDL_windows !
	-1 0 SDL_CreateRenderer 'SDLrenderer !
	SDL_windows SDL_RaiseWindow
	;

|typedef struct SDL_DisplayMode {
|    Uint32 format;        /**< formato de píxeles */
|    int w;                /**< ancho, en coordenadas de pantalla */
|    int h;                /**< alto, en coordenadas de pantalla */
|    int refresh_rate;     /**< frecuencia de actualización (o cero para no especificado) */
|    void *driverdata;     /**< datos específicos del controlador, inicializar a 0 */
|
#dm 0 0 0

::SDLfullw | "titulo" display --
	$3231 SDL_init 
	dup 'dm SDL_GetCurrentDisplayMode
	'dm 4 + d@+ 'sw ! d@ 'sh ! 
	$2fff0000 or dup | display nro
	sw sh $10 SDL_CreateWindow dup 'SDL_windows !
	-1 0 SDL_CreateRenderer 'SDLrenderer !
	;
	
::SDLfull | --
	SDL_windows 1 SDL_SetWindowFullscreen ;
	
::SDLframebuffer | w h -- texture
	>r >r SDLrenderer $16362004 1 r> r> SDL_CreateTexture ;
	
::SDLblend	
	SDLrenderer 1 SDL_SetRenderDrawBlendMode ;
	
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
##SDLx ##SDLy ##SDLb ##SDLw


#eventr	0

::SDLeventR | 'vec --
	'eventr ! ;

:changews | change windowsize
	SDL_windows 'sw 'sh SDL_GetWindowSize 
	eventr 0? ( drop ; ) ex
	;
	
::SDLupdate
	0 'SDLkey ! 0 'SDLchar ! 0 'SDLw !
	10 SDL_delay
	( 'SDLevent SDL_PollEvent 1? drop 
		'SDLevent d@ 
		$200 =? ( drop changews ; ) | WINDOWEVENT
		$300 =? ( drop 'SDLevent 20 + d@ dup $ffff and swap 16 >> or 'SDLkey ! ; ) |#SDL_KEYDOWN $300 
		$301 =? ( drop 'SDLevent 20 + d@ dup $ffff and swap 16 >> or $1000 or 'SDLkey ! ; ) |#SDL_KEYUP $301 
		$303 =? ( drop 'SDLevent 12 + c@ 'SDLchar ! ; ) |#SDL_TEXTINPUT	$303 |Keyboard text input
		|$400 =? ( drop 'SDLevent 20 + d@+ 'SDLx ! d@ 'SDLy ! ; ) |#SDL_MOUSEMOTION	$400 Mouse moved
		$400 =? ( drop 'SDLevent 20 + @ dup $ffff and 'SDLx ! 32 >> 'SDLy ! ; ) |#SDL_MOUSEMOTION	$400 Mouse moved
		$401 =? ( drop 'SDLevent 16 + c@ 1 - 1 swap << SDLb or 'SDLb ! ; ) |#SDL_MOUSEBUTTONDOWN $401 pressed
		$402 =? ( drop 'SDLevent 16 + c@ 1 - 1 swap << not SDLb and 'SDLb ! ; ) |#SDL_MOUSEBUTTONUP $402 released
		$403 =? ( drop 'SDLevent 20 + d@ 'SDLw ! ; ) |#SDL_MOUSEWHEEL $403 Mouse wheel motion
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
	SDLrenderer SDL_RenderPresent ;	
	
::sdlbreak | f12 contiue ESC end
	SDLredraw
	( SDLkey >f12< <>? >esc< <>? drop SDLupdate ) drop
	;

| tex 0 0 'xm 'ym SDL_QueryTexture		
::SDLTexwh | tex -- w h
	16 + d@+ swap d@ ;
	
::%w SW 16 *>> ; ::%h SH 16 *>> ; 	
		
|------- BOOT
:
|WIN|	"dll/SDL2.DLL" loadlib
|LIN|   "libSDL2-2.0.so.0" loadlib	
	dup "SDL_Init" getproc 'sys-SDL_Init !
	dup "SDL_GetCurrentDisplayMode" getproc 'sys-SDL_GetCurrentDisplayMode !
	dup "SDL_Quit" getproc 'sys-SDL_Quit !
	dup "SDL_GetNumVideoDisplays" getproc 'sys-SDL_GetNumVideoDisplays !
	dup "SDL_CreateWindow" getproc 'sys-SDL_CreateWindow !
	dup "SDL_SetWindowFullscreen" getproc 'sys-SDL_SetWindowFullscreen !
	dup "SDL_RenderSetLogicalSize" getproc 'sys-SDL_RenderSetLogicalSize !
	dup "SDL_GetWindowSurface" getproc 'sys-SDL_GetWindowSurface !
	dup "SDL_ShowCursor" getproc 'sys-SDL_ShowCursor !
	dup "SDL_RaiseWindow" getproc 'sys-SDL_RaiseWindow !
	dup "SDL_GetWindowSize" getproc 'sys-SDL_GetWindowSize !
	dup "SDL_SetWindowSize" getproc 'sys-SDL_SetWindowSize !
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
	dup "SDL_CreateRGBSurfaceWithFormatFrom" getproc 'sys-SDL_CreateRGBSurfaceWithFormatFrom !
	dup "SDL_CreateRGBSurfaceWithFormat" getproc 'sys-SDL_CreateRGBSurfaceWithFormat !
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
	dup "SDL_SetSurfaceAlphaMod" getproc 'sys-SDL_SetSurfaceAlphaMod !
	dup "SDL_FillRect" getproc 'sys-SDL_FillRect !
	dup "SDL_FreeSurface" getproc 'sys-SDL_FreeSurface !
	dup "SDL_LockTexture" getproc 'sys-SDL_LockTexture !
	dup "SDL_UnlockTexture" getproc 'sys-SDL_UnlockTexture !
	dup "SDL_SetRenderDrawBlendMode" getproc 'sys-SDL_SetRenderDrawBlendMode !
	dup "SDL_SetTextureBlendMode" getproc 'sys-SDL_SetTextureBlendMode !
	dup "SDL_ConvertSurfaceFormat" getproc 'sys-SDL_ConvertSurfaceFormat !
	dup "SDL_UpdateYUVTexture" getproc 'sys-SDL_UpdateYUVTexture !
	dup "SDL_RenderDrawPoint" getproc 'sys-SDL_RenderDrawPoint !
	dup "SDL_RenderDrawPoints" getproc 'sys-SDL_RenderDrawPoints !
	dup "SDL_RenderDrawLine" getproc 'sys-SDL_RenderDrawLine !
	dup "SDL_RenderDrawRect" getproc 'sys-SDL_RenderDrawRect !
	dup "SDL_RenderFillRect" getproc 'sys-SDL_RenderFillRect !
	dup "SDL_RenderGeometry" getproc 'sys-SDL_RenderGeometry !
	dup "SDL_RenderSetClipRect" getproc 'sys-SDL_RenderSetClipRect	!
	dup "SDL_RenderReadPixels" getproc 'sys-SDL_RenderReadPixels !
	dup "SDL_SetTextureScaleMode" getproc 'sys-SDL_SetTextureScaleMode !
	dup "SDL_SetRenderTarget" getproc 'sys-SDL_SetRenderTarget !
	dup "SDL_Delay" getproc 'sys-SDL_Delay !
	dup "SDL_PollEvent" getproc 'sys-SDL_PollEvent !
	dup "SDL_GetTicks" getproc 'sys-SDL_GetTicks !
	
	dup "SDL_RWFromFile" getproc 'sys-SDL_RWFromFile !
	dup "SDL_RWclose" getproc 'sys-SDL_RWclose !
	
	dup "SDL_GL_SetAttribute" getproc 'sys-SDL_GL_SetAttribute !
	dup "SDL_GL_CreateContext" getproc 'sys-SDL_GL_CreateContext !
	dup "SDL_GL_DeleteContext" getproc 'sys-SDL_GL_DeleteContext !
	dup "SDL_GL_SetSwapInterval" getproc 'sys-SDL_GL_SetSwapInterval !
	dup "SDL_GL_SwapWindow" getproc 'sys-SDL_GL_SwapWindow	!
	dup "SDL_GL_MakeCurrent" getproc 'sys-SDL_GL_MakeCurrent ! 
	dup "SDL_SetHint" getproc 'sys-SDL_SetHint !
	dup "SDL_GetError" getproc 'sys-SDL_GetError !
	dup "SDL_GL_LoadLibrary" getproc 'sys-SDL_GL_LoadLibrary !
	dup "SDL_GL_GetProcAddress" getproc 'sys-SDL_GL_GetProcAddress !

	dup "SDL_OpenAudioDevice" getproc 'sys-SDL_OpenAudioDevice !
	dup "SDL_QueueAudio" getproc 'sys-SDL_QueueAudio !
	dup "SDL_GetQueuedAudioSize" getproc 'sys-SDL_GetQueuedAudioSize !
	dup "SDL_PauseAudioDevice" getproc 'sys-SDL_PauseAudioDevice !
	dup "SDL_CloseAudioDevice" getproc 'sys-SDL_CloseAudioDevice !

	dup "SDL_GetClipboardText" getproc 'sys-SDL_GetClipboardText !
	dup "SDL_HasClipboardText" getproc 'sys-SDL_HasClipboardText !
	dup "SDL_SetClipboardText" getproc 'sys-SDL_SetClipboardText !
	dup "SDL_free" getproc 'sys-SDL_free !

	drop
	;