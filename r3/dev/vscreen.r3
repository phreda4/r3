| Resize windows, change sw and sh
| PHREDA 2024

^r3/lib/sdl2gfx.r3
^r3/util/bfont.r3

#vscrw #vscrh
#vscrtex
#vrect [ 0 0 0 0 ]

#vscrz #vcenx #vceny
#sclx #scly

::vresize | nw nh --
	2dup vscrh 16 <</ swap vscrw 16 <</ min 'vscrz ! 
	2dup 2/ 'vceny ! 2/ 'vcenx !
	
	dup vscrh vscrz *. - -
	vscrh swap 16 <</ 'scly !
	dup vscrw vscrz *. - -
	vscrw swap 16 <</ 'sclx !	
	;

::vscreen | w h --
	'vscrh ! 'vscrw !
	SDLrenderer $16362004 2 vscrw vscrh SDL_CreateTexture
	dup 1 SDL_SetTextureScaleMode | 0 no blend
	'vscrtex ! 
	sw sh vresize ;

::vini
	SDLrenderer vscrtex SDL_SetRenderTarget	;
	
::vredraw	
	SDLrenderer 0 SDL_SetRenderTarget	
|	SDLrenderer vscrtex 0 'vrect SDL_RenderCopy
	vcenx vceny vscrz vscrtex spritez
	SDLredraw ;	
	
:sdlx-r sdlx vcenx - sclx *. vscrw 2/ +	;
::sdlx sdlx-r ;	

:sdly-r sdly vceny - scly *. vscrh 2/ + ;
::sdly sdly-r ;	
	
#preshsw	
:vchange
	sw sh 16 << or 
	preshsw =? ( drop ; ) 
	'preshsw ! 
	sw sh vresize 
	0 sdlcls ;
	
:demo
	vini
	$7f7f7f SDLcls
	$ffffff bcolor 
	10 10 bat 
	"Resize Windows" bprint2
	bcr bcr
	sh sw "w:%d h:%d" bprint2
	$ff00 sdlcolor
	0 0 sdlx sdly SDLline
	
	8 8 sdlx sdly sdlellipse
	vredraw
	SDLkey
	>esc< =? ( exit )
	drop 
	vchange
	;
	
:main
	"r3sdl" 800 600 SDLinitR
	620 240 vscreen 
	bfont1 | pc font 8x16
	'demo SDLshow
	SDLquit ;	
	
: main ;
