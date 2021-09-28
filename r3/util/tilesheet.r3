| TileSheet Library
| PHREDA 2021
^r3/lib/mem.r3
	
#w #h

::loadts | w h filename -- ts
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

::freets | ts --
	@ SDL_DestroyTexture 
	empty ;
	
#rdes [ 0 0 0 0 ]
#rsrc [ 0 0 0 0 ]

::tsdraw | n 'ts x y --
	swap 'rdes d!+ d!
	dup 8 + @ dup 'rdes 8 + ! 'rsrc 8 + !
	SDLrenderer 	| n 'ts ren
	rot rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rsrc ! | ren txture rsrc
	'rsrc 'rdes 
	SDL_RenderCopy
	;

::tsdraws | n 'ts x y w h --
	swap 2swap swap 'rdes d!+ d!+ d!+ d!
	dup 8 + @ 'rsrc 8 + !
	SDLrenderer 	| n 'ts ren
	rot rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rsrc ! | ren txture rsrc
	'rsrc 'rdes 
	SDL_RenderCopy
	;
