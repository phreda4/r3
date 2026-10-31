| SDL2.dll
| PHREDA 2024

^r3/lib/core.r3

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

::SDL_Init | flags -- ; initialize the SDL subsystems (SDL_INIT_*)
	sys-SDL_Init sys1 drop ;
::SDL_GetCurrentDisplayMode | display 'mode -- ; fill the SDL_DisplayMode at 'mode (format w h refresh_rate driverdata) with the current mode of the display
	sys-SDL_GetCurrentDisplayMode sys2 drop ;
::SDL_Quit | -- ; shut down SDL
	sys-SDL_Quit sys0 drop ;
::SDL_GetNumVideoDisplays | -- n ; number of video displays
	sys-SDL_GetNumVideoDisplays sys0 ;
::SDL_CreateWindow | "title" x y w h flags -- window ; create a window (0 on error)
	sys-SDL_CreateWindow sys6 ;
::SDL_SetWindowFullscreen | window flags -- ; 0 windowed, 1 fullscreen, $1001 fullscreen desktop
	sys-SDL_SetWindowFullscreen sys2 drop ;
::SDL_RenderSetLogicalSize | renderer w h -- ; set a device independent resolution for the rendering
	sys-SDL_RenderSetLogicalSize sys3 drop ;
::SDL_RaiseWindow | window -- ; raise the window above the others and give it the input focus
	sys-SDL_RaiseWindow sys1 drop ;
::SDL_GetWindowSize | window 'w 'h -- ; store the size of the window in the integers at 'w and 'h
	sys-SDL_GetWindowSize sys3 drop ;
::SDL_SetWindowSize | window w h -- ; set the size of the window
	sys-SDL_SetWindowSize sys3 drop ;
::SDL_GetWindowSurface | window -- surface ; the surface of the window (for software drawing)
	sys-SDL_GetWindowSurface sys1 ;
::SDL_ShowCursor | toggle -- ; 1 shows the mouse cursor, 0 hides it
	sys-SDL_ShowCursor sys1 drop ;
::SDL_UpdateWindowSurface | window -- ; copy the surface of the window to the screen
	sys-SDL_UpdateWindowSurface sys1 drop ;
::SDL_DestroyWindow | window -- ; destroy the window
	sys-SDL_DestroyWindow sys1 drop ;
::SDL_CreateRenderer | window index flags -- renderer ; create a 2d renderer (index -1 = the first driver that supports the flags)
	sys-SDL_CreateRenderer sys3 ;
::SDL_CreateTexture | renderer format access w h -- texture ; create a texture (access 0 static, 1 streaming, 2 target)
	sys-SDL_CreateTexture sys5 ;
::SDL_QueryTexture | texture 'format 'access 'w 'h -- ; store the attributes of the texture in the variables (0 to ignore one)
	sys-SDL_QueryTexture sys5 drop ;
::SDL_SetTextureColorMod | texture r g b -- ; color modulation of the texture (0..255)
	sys-SDL_SetTextureColorMod sys4 drop ;
::SDL_SetTextureAlphaMod | texture alpha -- ; alpha modulation of the texture (0..255)
	sys-SDL_SetTextureAlphaMod sys2 drop ;
::SDL_DestroyTexture | texture -- ; free the texture
	sys-SDL_DestroyTexture sys1 drop ;
::SDL_DestroyRenderer | renderer -- ; free the renderer
	sys-SDL_DestroyRenderer sys1 drop ;
::SDL_UpdateTexture | texture 'rect 'pixels pitch -- result ; update an area of the texture (0 = all) with pixels, pitch = bytes per row; 0 if ok
	sys-SDL_UpdateTexture sys4 ;
::SDL_RenderClear | renderer -- ; clear the render target with the draw color
	sys-SDL_RenderClear sys1 drop ;
::SDL_RenderCopy | renderer texture 'src 'dst -- ; copy the rectangle 'src of the texture to the rectangle 'dst of the target (0 = whole)
	sys-SDL_RenderCopy sys4 drop ;
::SDL_RenderCopyEx | renderer texture 'src 'dst angle 'center flip -- ; like SDL_RenderCopy with rotation (angle in degrees, a double in C; with sys7 it goes in an integer register: check it), center point (0 = middle) and flip
	sys-SDL_RenderCopyEx sys7 drop ;
::SDL_RenderPresent | renderer -- ; show what was drawn
	sys-SDL_RenderPresent sys1 drop ;
::SDL_CreateTextureFromSurface | renderer surface -- texture ; create a texture from a surface
	sys-SDL_CreateTextureFromSurface sys2 ;
::SDL_CreateRGBSurfaceWithFormatFrom | 'pixels w h depth pitch format -- surface ; surface that uses existing pixels
	sys-SDL_CreateRGBSurfaceWithFormatFrom sys6 ;
::SDL_CreateRGBSurfaceWithFormat | flags w h depth format -- surface ; create a surface with a pixel format
	sys-SDL_CreateRGBSurfaceWithFormat sys5 ;
::SDL_SetRenderDrawColor | renderer r g b a -- ; color for the drawing operations (0..255)
	sys-SDL_SetRenderDrawColor sys5 drop ;
::SDL_GetRenderDrawColor | renderer 'r 'g 'b 'a -- ; store the draw color in the variables
	sys-SDL_GetRenderDrawColor sys5 drop ;
::SDL_CreateRGBSurface | flags w h depth rmask gmask bmask amask -- surface ; create a surface
	sys-SDL_CreateRGBSurface sys8 ;
::SDL_LockSurface | surface -- ; lock the surface to access its pixels
	sys-SDL_LockSurface sys1 drop ;
::SDL_UnlockSurface | surface -- ; unlock the surface
	sys-SDL_UnlockSurface sys1 drop ;
::SDL_BlitSurface | src 'srcrect dst 'dstrect -- ; copy a surface to another one (0 = whole)
	sys-SDL_BlitSurface sys4 drop ;
::SDL_SetSurfaceBlendMode | surface mode -- ; blend mode of the surface
	sys-SDL_SetSurfaceBlendMode sys2 drop ;
::SDL_SetSurfaceAlphaMod | surface alpha -- ; alpha modulation of the surface (0..255)
	sys-SDL_SetSurfaceAlphaMod sys2 drop ;
::SDL_FillRect | surface 'rect color -- ; fill a rectangle of the surface (0 = whole) with the color
	sys-SDL_FillRect sys3 drop ;

::SDL_FreeSurface | surface -- ; free the surface
	sys-SDL_FreeSurface sys1 drop ;
::SDL_LockTexture | texture 'rect 'pixels 'pitch -- ; lock a streaming texture for writing: 'pixels and 'pitch receive the address and the bytes per row
	sys-SDL_LockTexture sys4 drop ;
::SDL_UnlockTexture | texture -- ; unlock the texture
	sys-SDL_UnlockTexture sys1 drop ;
::SDL_SetRenderDrawBlendMode | renderer mode -- ; blend mode of the drawing (0 none, 1 alpha blend, 2 add, 4 mod)
	sys-SDL_SetRenderDrawBlendMode sys2 drop ;
::SDL_SetTextureBlendMode | texture mode -- ; blend mode of the texture (0 none, 1 alpha blend, 2 add, 4 mod)
	sys-SDL_SetTextureBlendMode sys2 drop ;
::SDL_ConvertSurfaceFormat | surface format flags -- surface ; copy of the surface in another pixel format
	sys-SDL_ConvertSurfaceFormat sys3 ;
::SDL_UpdateYUVTexture | texture 'rect 'y ypitch 'u upitch 'v vpitch -- ; update a planar YUV texture
	sys-SDL_UpdateYUVTexture sys8 drop ;

::SDL_RenderDrawPoint | renderer x y -- ; draw a point
	sys-SDL_RenderDrawPoint sys3 drop ;
::SDL_RenderDrawPoints | renderer 'points count -- ; draw an array of SDL_Point (two int32 each)
	sys-SDL_RenderDrawPoints sys3 drop ;
::SDL_RenderDrawLine | renderer x1 y1 x2 y2 -- ; draw a line
	sys-SDL_RenderDrawLine sys5 drop ;
::SDL_RenderDrawRect | renderer 'rect -- ; draw the outline of a rectangle x y w h (int32 each; 0 = whole target)
	sys-SDL_RenderDrawRect sys2 drop ;
::SDL_RenderFillRect | renderer 'rect -- ; fill a rectangle x y w h (int32 each; 0 = whole target)
	sys-SDL_RenderFillRect sys2 drop ;
::SDL_RenderGeometry | renderer texture 'vertices nvertices 'indices nindices -- ; draw triangles
	sys-SDL_RenderGeometry sys6 drop ;
::SDL_RenderReadPixels | renderer 'rect format 'pixels pitch -- ; read pixels back from the target
	sys-SDL_RenderReadPixels sys5 drop ;
::SDL_RenderSetClipRect | renderer 'rect -- ; clipping rectangle (0 = no clipping)
	sys-SDL_RenderSetClipRect sys2 drop ;
::SDL_SetTextureScaleMode | texture mode -- ; scale mode of the texture (0 nearest, 1 linear, 2 best)
	sys-SDL_SetTextureScaleMode sys2 drop ;
::SDL_SetRenderTarget | renderer texture -- ; draw into a target texture (0 = back to the window)
	sys-SDL_SetRenderTarget sys2 drop ;

::SDL_Delay | ms -- ; wait ms milliseconds
	sys-SDL_Delay sys1 drop ;
::SDL_PollEvent | 'event -- ok ; fill the SDL_Event at 'event with the next pending event; 1 if there was one, 0 if not
	sys-SDL_PollEvent sys1 ;
::SDL_GetTicks | -- msec ; milliseconds since SDL started
	sys-SDL_GetTicks sys0 ;

|::SDL_StartTextInput sys-SDL_StartTextInput sys0 drop ;
|::SDL_StopTextInput sys-SDL_StopTextInput sys0 drop ;

::SDL_RWFromFile | "file" "mode" -- rwops ; open a file as an SDL_RWops (0 on error)
	sys-SDL_RWFromFile sys2 ;
::SDL_RWclose | rwops -- ; close and free the rwops
	sys-SDL_RWclose sys1 drop ;

::SDL_GL_SetAttribute | attr value -- ; set an OpenGL attribute (before creating the window)
	sys-SDL_GL_SetAttribute sys2 drop ;
::SDL_GL_CreateContext | window -- context ; create an OpenGL context for the window
	sys-SDL_GL_CreateContext sys1 ;
::SDL_GL_DeleteContext | context -- ; delete the OpenGL context
	sys-SDL_GL_DeleteContext sys1 drop ;
::SDL_GL_SetSwapInterval | n -- ; swap interval (0 immediate, 1 vsync)
	sys-SDL_GL_SetSwapInterval sys1 drop ;
::SDL_GL_SwapWindow | window -- ; swap the OpenGL buffers of the window
	sys-SDL_GL_SwapWindow sys1 drop ;
::SDL_GL_LoadLibrary | "path" -- ; load the OpenGL library (0 = the default one)
	sys-SDL_GL_LoadLibrary sys1 drop ;
::SDL_GL_GetProcAddress | "name" -- address ; address of an OpenGL function
	sys-SDL_GL_GetProcAddress sys1 ;

::SDL_GL_MakeCurrent | window context -- ; make the OpenGL context current for the window
	sys-SDL_GL_MakeCurrent sys2 drop ;
::SDL_SetHint | "name" "value" -- ; set an SDL configuration hint
	sys-SDL_SetHint sys2 drop ;
::SDL_GetError | -- "message" ; text of the last SDL error
	sys-SDL_GetError sys0 ;

::SDL_OpenAudioDevice | "device" iscapture 'desired 'obtained changes -- id ; open an audio device (device 0 = the default one)
	sys-SDL_OpenAudioDevice sys5 ;
::SDL_QueueAudio | id 'data len -- ; queue len bytes of audio data
	sys-SDL_QueueAudio sys3 drop ;
::SDL_GetQueuedAudioSize | id -- bytes ; bytes of audio still queued
	sys-SDL_GetQueuedAudioSize sys1 ;
::SDL_PauseAudioDevice | id pause -- ; 1 pauses the audio device, 0 plays it
	sys-SDL_PauseAudioDevice sys2 drop ;
::SDL_CloseAudioDevice | id -- ; close the audio device
	sys-SDL_CloseAudioDevice sys1 drop ;

::SDL_GetClipboardText | -- "text" ; text of the clipboard (free it with SDL_free)
	sys-SDL_GetClipboardText sys0 ;
::SDL_HasClipboardText | -- bool ; 1 if the clipboard has text
	sys-SDL_HasClipboardText sys0 ;
::SDL_SetClipboardText | "text" -- result ; put the text in the clipboard (0 if ok)
	sys-SDL_SetClipboardText sys1 ;
::SDL_free | mem -- ; free memory allocated by SDL
	sys-SDL_free sys1 drop ;

|----------------------------------------------------------
	
##SDL_windows | handle of the window created by SDLinit
##SDLrenderer | handle of the renderer created by SDLinit

##sw | width of the window in pixels (updated when it is resized)
##sh | height of the window in pixels (updated when it is resized)

::SDLinit | "title" w h -- ; initialize SDL, create a centered window w x h with its renderer (SDL_windows, SDLrenderer, sw, sh) and raise it
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 dup sw sh $0 SDL_CreateWindow dup 'SDL_windows !
	-1 0 SDL_CreateRenderer 'SDLrenderer !
	SDL_windows SDL_RaiseWindow
	;

::SDLmini | "title" w h -- ; like SDLinit without raising the window
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

::SDLinitScr | "title" display w h -- ; like SDLinit on the display number given
	'sh ! 'sw !
	$3231 SDL_init 
	$2fff0000 or dup 
|	$1FFF0000 dup
	sw sh $0 SDL_CreateWindow dup 'SDL_windows !
	dup -1 0 SDL_CreateRenderer 'SDLrenderer !
	SDL_RaiseWindow
	;
	
::sdlinitR | "title" w h -- ; like SDLinit with a resizable window
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

::SDLdfullsw | display -- sw sh ; current resolution of the display
	here SDL_GetCurrentDisplayMode
	here 4 + d@+ swap d@ ;
	
::SDLfullw | "title" display -- ; borderless window with the size of the display (sets sw sh)
	$3231 SDL_init 
	dup SDLdfullsw 'sh ! 'sw !
	$2fff0000 or dup | display nro
	sw sh $10 SDL_CreateWindow dup 'SDL_windows !
	-1 0 SDL_CreateRenderer 'SDLrenderer !
	;

::SDLfull | -- ; switch the window to fullscreen
	SDL_windows 1 SDL_SetWindowFullscreen ;
	
::SDLframebuffer | w h -- texture ; streaming texture w x h in ARGB8888 format, to draw pixels
	>r >r SDLrenderer $16362004 1 r> r> SDL_CreateTexture ;
	
::SDLblend | -- ; enable alpha blending for the renderer drawing
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
  
::SDLquit | -- ; destroy the renderer and the window and quit SDL
	SDLrenderer SDL_DestroyRenderer
	SDL_windows SDL_DestroyWindow 
	SDL_Quit ;
	
##SDLevent * 56 | buffer (SDL_Event, 56 bytes) where SDLupdate reads the events

##SDLkey | key of the last key event of the SDLupdate: 16 bits (ASCII, or $4000 + scancode for special keys), $1000 added when released, 0 if none
##SDLchar | first byte of the last text input of the SDLupdate (0 if none)
##SDLx | mouse x position (16 bits)
##SDLy | mouse y position
##SDLb | mask of the pressed mouse buttons (1 left, 2 middle, 4 right)
##SDLw | vertical mouse wheel movement of the last SDLupdate

#eventr	

::SDLeventR | 'vec -- ; word to execute when the window is resized (sw and sh are updated first)
	'eventr ! ;

:changews | change windowsize
	'SDLevent 12 + c@ 
	5 <>? ( drop ; ) drop
	'SDLevent 16 + 
	d@+ 'sw ! d@ 'sh !
	eventr 0? ( drop ; ) ex ;
	
::SDLupdate | -- ; wait 10 ms and process the pending events, updating SDLkey, SDLchar, SDLx, SDLy, SDLb and SDLw
	0 'SDLkey ! 0 'SDLchar ! 0 'SDLw !
	10 SDL_delay
	( 'SDLevent SDL_PollEvent 1? drop 
		'SDLevent d@ 
		$200 =? ( drop changews ; ) | WINDOWEVENT
		$300 =? ( 'SDLevent 20 + d@ dup $ffff and swap 16 >> or 'SDLkey ! ) |#SDL_KEYDOWN $300 
		$301 =? ( drop 'SDLevent 20 + d@ dup $ffff and swap 16 >> or $1000 or 'SDLkey ! ; ) |#SDL_KEYUP $301 
		$303 =? ( drop 'SDLevent 12 + c@ 'SDLchar ! ; ) |#SDL_TEXTINPUT	$303 |Keyboard text input
		|$400 =? ( drop 'SDLevent 20 + d@+ 'SDLx ! d@ 'SDLy ! ; ) |#SDL_MOUSEMOTION	$400 Mouse moved
		$400 =? ( 'SDLevent 20 + @ dup $ffff and 'SDLx ! 32 >> 'SDLy ! ) |#SDL_MOUSEMOTION	$400 Mouse moved
		$401 =? ( drop 'SDLevent 16 + c@ 1 - 1 swap << SDLb or 'SDLb ! ; ) |#SDL_MOUSEBUTTONDOWN $401 pressed
		$402 =? ( drop 'SDLevent 16 + c@ 1 - 1 swap << not SDLb and 'SDLb ! ; ) |#SDL_MOUSEBUTTONUP $402 released
		$403 =? ( 'SDLevent 20 + d@ 'SDLw ! ) |#SDL_MOUSEWHEEL $403 Mouse wheel motion
		drop
		) drop ;			
		
#clickb 0
		
::SDLClick | 'event -- ; execute 'event once when the mouse button is released after being pressed (call it every frame)
	SDLb 1? ( 'clickb ! drop ; ) drop
	clickb 0? ( 2drop ; ) drop
	ex 
	0 'clickb !
	;
	
##.exit 0 | 1 ends the SDLshow loop (set by exit)

::SDLshow | 'word -- ; main loop: SDLupdate and execute 'word every frame until exit is called
	0 '.exit !
	( .exit 0? drop
		SDLupdate
		dup ex ) 2drop
	SDLupdate
	0 '.exit ! ;

::exit | -- ; end the SDLshow loop
	1 '.exit ! ;
	
::SDLredraw | -- ; show the frame (SDL_RenderPresent of the renderer)
	SDLrenderer SDL_RenderPresent ;	
	
::sdlbreak | -- ; debug stop: redraw and wait until F12 or ESC is pressed
	SDLredraw
	( SDLkey >f12< <>? >esc< <>? drop SDLupdate ) drop
	;

| tex 0 0 'xm 'ym SDL_QueryTexture		
::SDLTexwh | tex -- w h ; width and height of a texture (reads the SDL_Texture structure)
	16 + d@+ swap d@ ;
	
::%w | frac -- px ; fixed point fraction of the screen width (1.0 = sw) in pixels
	SW 16 *>> ;
::%h | frac -- px ; fixed point fraction of the screen height (1.0 = sh) in pixels
	SH 16 *>> ;
		
|------- BOOT
:
|WIN|	"dll/SDL2.DLL" loadlib
|LIN|   "libSDL2-2.0.so.0" loadlib
|MAC|   "libSDL2.dylib" loadlib	
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