| tilesheet sprite
| PHREDA 2021
|------------------

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/lib/key.r3

#ts_alien
#ts_ship
#ts_explo

|--------------------------------
	
#w #h

:loadts | w h filename -- ts
	loadimg
	dup 0 0 'w 'h SDL_QueryTexture
	mark here >a
	a!+ | texture
	2dup swap da!+ da!+ | w h 
	0 ( h <? 
		0 ( w <? | w h y x
			2dup da!+ da!+
			pick3 + ) drop 
		over + ) drop
	2drop 
	here a> 'here ! 
	;

:freets | ts --
	@ SDL_DestroyTexture 
	empty ;
	
#rdes [ 0 0 0 0 ]
#rsrc [ 0 0 0 0 ]

:tsdraw | n 'ts x y --
	swap 'rdes d!+ d!
	dup 8 + @ dup 'rdes 8 + ! 'rsrc 8 + !
	SDLrenderer 	| n 'ts ren
	rot rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rsrc ! | ren txture rsrc
	'rsrc 'rdes 
	SDL_RenderCopy
	;

|----------------------------------------
:sdlcolor | col --
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;
	
:demo
	0 sdlcolor SDLrenderer SDL_RenderClear
	
	msec 5 >> $3 and ts_alien 10 10 tsdraw 
	msec 6 >> $3 and ts_ship 200 10 tsdraw 
	msec 6 >> $f and ts_explo 300 100 tsdraw 	
	
	SDLrenderer SDL_RenderPresent
	
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	mark
	"r3sdl" 800 600 SDLinit

	40 30 "media/img/alien_40x30.png" loadts 'ts_alien !
	64 29 "media/img/ship_64x29.png" loadts 'ts_ship !
	64 64 "media/img/explo_64x64.png" loadts 'ts_explo !	
	
	'demo SDLshow
	
	SDLquit
	;
	
: main ;