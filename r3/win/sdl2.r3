| SDL2.dll
|
^r3/win/kernel32.r3
^r3/win/core.r3
^r3/lib/key.r3

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
#sys-SDL_LockSurface
#sys-SDL_UnlockSurface
#sys-SDL_FreeSurface
#sys-SDL_LockTexture
#sys-SDL_UnlockTexture
#sys-SDL_RenderSetLogicalSize
#sys-SDL_SetRenderDrawBlendMode
#sys-SDL_RenderDrawPoint
#sys-SDL_RenderDrawLine
#sys-SDL_RenderDrawRect
#sys-SDL_RenderFillRect
#sys-SDL_RenderReadPixels

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
::SDL_LockSurface sys-SDL_LockSurface sys1 drop ;
::SDL_UnlockSurface sys-SDL_UnlockSurface sys1 drop ;
::SDL_FreeSurface sys-SDL_FreeSurface sys1 drop ;
::SDL_LockTexture sys-SDL_LockTexture sys4 drop ;
::SDL_UnlockTexture sys-SDL_UnlockTexture sys1 drop ;
::SDL_RenderSetLogicalSize sys-SDL_RenderSetLogicalSize sys3 drop ;
::SDL_SetRenderDrawBlendMode sys-SDL_SetRenderDrawBlendMode sys2 drop ;

::SDL_RenderDrawPoint sys-SDL_RenderDrawPoint sys3 drop ;
::SDL_RenderDrawLine sys-SDL_RenderDrawLine sys5 drop ;
::SDL_RenderDrawRect sys-SDL_RenderDrawRect sys2 drop ;
::SDL_RenderFillRect sys-SDL_RenderFillRect sys2 drop ;
::SDL_RenderReadPixels sys-SDL_RenderReadPixels sys5 drop ;

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
	
##SDLevent * 56 

##SDLkey
##SDLkeychar
##SDLx ##SDLy ##SDLb
	
::SDLupdate
	0 'SDLkey !
	0 'SDLkeychar !
	10 SDL_delay
	( 'SDLevent SDL_PollEvent 1? drop
		'SDLevent d@ 
			|#SDL_KEYDOWN	$300     | Key pressed		
		$300 =? ( 'SDLevent 20 + d@ dup $ffff and swap 16 >> or 'SDLkey ! )
			|#SDL_KEYUP		$301     | Key released		
		$301 =? ( 'SDLevent 20 + d@ dup $ffff and swap 16 >> or $1000 or 'SDLkey ! )
			|#SDL_TEXTINPUT	$303 | Keyboard text input		
		$303 =? ( 'SDLevent 12 + c@ 'SDLkeychar ! )
			|#SDL_MOUSEMOTION	$400     | Mouse moved		
		$400 =? ( 'SDLevent 20 + d@+ 'SDLx ! d@ 'SDLy ! )
			|#SDL_MOUSEBUTTONDOWN $401    | Mouse button pressed		
		$401 =? ( 'SDLevent 16 + c@ SDLb or 'SDLb ! )
			|#SDL_MOUSEBUTTONUP	$402     | Mouse button released		
		$402 =? ( 'SDLevent 16 + c@ not SDLb and 'SDLb ! )
			|#SDL_MOUSEWHEEL	$403     | Mouse wheel motion		
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

#rec [ 0 0 0 0 ] | aux rect
#w 0 #h 0

::SDLFillRect | x y w h --	
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderFillRect ;

::SDLRect | x y w h --	
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderDrawRect ;

::SDLimages | x y w h img --
	>r
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLrenderer r> 0 'rec SDL_RenderCopy ;
	
::SDLimage | x y img --		
	dup 0 0 'w 'h SDL_QueryTexture >r
	swap 'rec d!+ d!+ h w rot d!+ d!
	SDLrenderer r> 0 'rec SDL_RenderCopy ;
	
::SDLclear | color --
	SDLcolor SDLrenderer SDL_RenderClear ;
	
::SDLRedraw | -- 
	SDLrenderer SDL_RenderPresent ;
	
#ym #xm
#dx #dy

:inielipse | x y --
	'ym ! 'xm !
	over dup * dup 1 <<		| a b c 2aa
	swap dup >a 'dy ! 		| a b 2aa
	rot rot over neg 1 << 1 +	| 2aa a b c
	swap dup * dup 1 << 		| 2aa a c b 2bb
	rot rot * dup a+ 'dx !	| 2aa a 2bb
	1 + swap 1				| 2aa 2bb x y
	pick3 'dy +! dy a+
	;

:qf
	xm pick2 - ym pick2 - xm pick4 + over SDLLine 
	xm pick2 - ym pick2 + xm pick4 + over SDLLine  ;

::SDLFillellipse | rx ry x y --
	a> >r
	inielipse
	xm pick2 - ym xm pick4 + over SDLLine 
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - rot rot pick3 'dx +! dx a+ )
		dy <=? ( rot rot qf 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop 
	r> >a ;
	
:borde | x y x
	over SDLPoint SDLPoint ;

:qfb
	xm pick2 - ym pick2 - xm pick4 + borde
	xm pick2 - ym pick2 + xm pick4 + borde ;

::SDLEllipse | rx ry x y --
	a> >r
    inielipse
	xm pick2 - ym xm pick4 + borde
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - rot qfb rot pick3 'dx +! dx a+ )
		dy <=? ( rot rot qfb 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop 
	r> >a ;
	
|-------------------
#dx1 0
#dx2 0

:tri | yf x1. x2. yi -- x1. x2.
	( pick3 <? 
		pick2 16 >> over pick3 16 >> over SDLLine
		rot dx1 + rot dx2 + rot
		1 + ) 
	drop rot drop ;
	
:triL | yx1 yx2 yx3 --  ; L
	dup 32 >> >r
	32 << 32 >> rot
	32 << 32 >> rot
	32 << 32 >> 
	pick2 pick2 pick2 min min
	>r max max
	>r >r | max min y
	rot over SDLLine ;

:triV | yx1 yx2 yx3 --  ; V
	pick2 32 >> over 32 >> -
	0? ( drop triL ; ) 
	pick3 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	32 << 32 >> 16 <<
	pick2 32 >> swap	| yx1 yx2 yf x3. 
	2swap 				| yf x3. yx1 yx2 
	over 32 << 32 >> over 32 << 32 >> - 16 << | x1 - x2 (fp)
	rot 32 >> pick2 32 >> - 
	/  'dx2 !
	dup	32 << 32 >> 16 <<	|  yf x3. yx2 x2. 
	swap 32 >>
	tri 2drop ;
		
:triangle | yx1 yx2 yx3 --
	over >? ( swap ) 
	pick2 >? ( rot ) >r 
	over >? ( swap ) r> | yxmax yxmed yxmin
	over 32 >> over 32 >> -
	0? ( drop triV ; )
	pick2 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	pick2 32 << 32 >> over 32 << 32 >> - 16 <<
	pick3 32 >> pick2 32 >> - /  'dx2 ! 
	over 32 >> 	over 32 << 32 >> 16 << dup  | yf x1 x1 
	pick3 32 >> | yf x1 x1 yi
	tri
	>r >r drop
	over 32 >> over 32 >> -
	0? ( 3drop r> r> 2drop ; )
	pick2 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	swap 32 >> swap
	r> r> rot 32 >>
	tri 2drop ;	
	
:xy 32 << swap $ffffffff and or ;
	
::SDLtriangle | x y x y x y --
	xy >r xy >r xy r> r> triangle ;

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
	dup "SDL_LockSurface" getproc 'sys-SDL_LockSurface !
	dup "SDL_UnlockSurface" getproc 'sys-SDL_UnlockSurface !
	dup "SDL_FreeSurface" getproc 'sys-SDL_FreeSurface !
	dup "SDL_LockTexture" getproc 'sys-SDL_LockTexture !
	dup "SDL_UnlockTexture" getproc 'sys-SDL_UnlockTexture !
	dup "SDL_RenderSetLogicalSize" getproc 'sys-SDL_RenderSetLogicalSize !
	dup "SDL_SetRenderDrawBlendMode" getproc 'sys-SDL_SetRenderDrawBlendMode !
	dup "SDL_RenderDrawPoint" getproc 'sys-SDL_RenderDrawPoint !
	dup "SDL_RenderDrawLine" getproc 'sys-SDL_RenderDrawLine !
	dup "SDL_RenderDrawRect" getproc 'sys-SDL_RenderDrawRect !
	dup "SDL_RenderFillRect" getproc 'sys-SDL_RenderFillRect !
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
	drop
	;