| Resize windows, change sw and sh
| PHREDA 2024

^r3/lib/sdl2gfx.r3
^r3/util/bfont.r3

#vscrw #vscrh
#vscrtex
#vrect [ 0 0 0 0 ]

:vscreen | w h --
	'vscrh ! 'vscrw !
	SDLrenderer $16362004 2 vscrw vscrh SDL_CreateTexture 'vscrtex ! ;
	
:vresize
	;
	
:vini
	SDLrenderer vscrtex SDL_SetRenderTarget	;
	
:vredraw	
	SDLrenderer 0 SDL_SetRenderTarget	
	SDLrenderer swap 0 'rectd SDL_RenderCopy
	SDLredraw ;	
	
:demo
	0 SDLcls
	$ffffff bcolor 
	10 10 bat 
	"Resize Windows" bprint2
	bcr bcr
	sh sw "w:%d h:%d" bprint2
	$ff00 sdlcolor
	0 0 sw sh SDLline
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
	;
	
:main
	"r3sdl" 800 600 SDLinitR
	bfont1 | pc font 8x16
	'demo SDLshow
	SDLquit ;	
	
: main ;
