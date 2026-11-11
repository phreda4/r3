| virtual screen
| PHREDA 2025
^r3/lib/sdl2.r3

#vscrw #vscrh
#vscrtex
#vscrz #vcenx #vceny
#scl
#recd 0 0

:vresize | --
	sw sh 
	2dup vscrh 16 <</ 
	swap vscrw 16 <</ min
	$100000000 over / 'scl !
	'vscrz ! 
	2/ 'vceny ! 2/ 'vcenx ! 

	'recd >a
	vscrw vscrz *. sw over - 2/ da!+
	vscrh vscrz *. sh over - 2/ da!+
	swap da!+ da! ;
	
:screenformat | rend -- rend tex
	dup here SDL_GetRendererInfo | rendered 'renderinfo --
	here 16 + d@ ;
	
::vscreen | w h -- ; create a virtual screen of w x h pixels (a render target) shown in the window centered with the aspect ratio kept and linear filtering; it follows the window resizes
	'vscrh ! 'vscrw !
	SDLrenderer screenformat 2 vscrw vscrh SDL_CreateTexture
	dup 1 SDL_SetTextureScaleMode | 0 no blend
	'vscrtex ! 
	'vresize SDLeventR
	vresize ;

::vscreenf | w h -- ; like vscreen with nearest neighbor scaling (sharp pixels)
	'vscrh ! 'vscrw !
	SDLrenderer screenformat 2 vscrw vscrh SDL_CreateTexture
	dup 0 SDL_SetTextureScaleMode | 0 no blend
	'vscrtex ! 
	'vresize SDLeventR
	vresize ;

::vini | -- ; start drawing into the virtual screen (it becomes the render target)
	SDLrenderer vscrtex SDL_SetRenderTarget	;
	
::vredraw | -- ; draw the virtual screen in the window and present it
	SDLrenderer 0 SDL_SetRenderTarget	
	SDLrenderer vscrtex 0 'recd SDL_RenderCopy
	SDLredraw ;	
	
::vfree | -- ; free the virtual screen texture
	vscrtex SDl_destroyTexture ;
	
	
:(sdlx) sdlx vcenx - scl *. vscrw 2/ + ;
::sdlx | -- x ; mouse x in virtual screen pixels (it replaces the sdlx of sdl2 for the code that follows)
	(sdlx) ;

:(sdly) sdly vceny - scl *. vscrh 2/ + ;
::sdly | -- y ; mouse y in virtual screen pixels (it replaces the sdly of sdl2 for the code that follows)
	(sdly) ;

::%w | frac -- px ; fixed point fraction of the virtual screen width (1.0 = all) in pixels (it replaces the one of sdl2)
	vscrw 16 *>> ;
::%h | frac -- px ; fixed point fraction of the virtual screen height (1.0 = all) in pixels (it replaces the one of sdl2)
	vscrh 16 *>> ;

