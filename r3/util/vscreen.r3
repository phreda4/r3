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
	
::vscreen | w h --
	'vscrh ! 'vscrw !
	SDLrenderer $16362004 2 vscrw vscrh SDL_CreateTexture
	dup 1 SDL_SetTextureScaleMode | 0 no blend
	'vscrtex ! 
	'vresize SDLeventR
	vresize ;

::vini | --
	SDLrenderer vscrtex SDL_SetRenderTarget	;
	
::vredraw | --
	SDLrenderer 0 SDL_SetRenderTarget	
	SDLrenderer vscrtex 0 'recd SDL_RenderCopy
	SDLredraw ;	
	
::vfree
	vscrtex SDl_destroyTexture ;
	
	
:(sdlx) sdlx vcenx - scl *. vscrw 2/ + ;
::sdlx (sdlx) ;	

:(sdly) sdly vceny - scl *. vscrh 2/ + ;
::sdly (sdly) ;	

::%w vscrw 16 *>> ; 
::%h vscrh 16 *>> ; 	

