| demo particles
| PHREDA 2021

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/lib/key.r3
^r3/lib/rand.r3
^r3/util/arr8.r3

#spr_ball

#list 0 0 

|--------------------------------
:loadtexture | "" -- texture
	IMG_Load SDLrenderer over SDL_CreateTextureFromSurface swap SDL_FreeSurface ;

|--------------------------------
:choque
	a> 8 + dup @ neg swap ! ;
	
#rbox [ 0 0 64 64 ]

:ballexec | adr -- 
	>a
	a@+ 16 >> 0 <? ( choque ) sw 64 - >? ( choque )
	a@+ 16 >> 0 <? ( choque ) sh 64 - >? ( choque )
	swap 'rbox d!+ d!
	a@+ a> 24 - +!
	a@+ a> 24 - +!	
	SDLrenderer a@+ 0 'rbox SDL_RenderCopy ;

:+obj | 'spr vy vx y x --
	'ballexec 'list p!+ >a a!+ a!+ a!+ a!+ a! ;

|--------------------------------
:demo
	SDLrenderer SDL_RenderClear
	'list p.draw
	SDLrenderer SDL_RenderPresent

	SDLkey
	<f1> =? ( 
		spr_ball 
		6.0 randmax 3 - 
		6.0 randmax 3 - 
		10.0 10.0 +obj )	
	>esc< =? ( exit )
	drop ;
	
:main
	"r3sdl" 800 600 SDLinit
	$3 IMG_Init
	SDLrenderer  0 0 0 $ff SDL_SetRenderDrawColor 

	"media/img/ball.png" loadtexture 'spr_ball !
	1000 'list p.ini
	
	'demo SDLshow
	
	SDLquit ;
	
	
: mark main ;