| Demo Flapybird
| PHRED 2021

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/lib/key.r3
^r3/lib/rand.r3

| dibujos del juegos

#sprbird
#sprpipe


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
	dup 8 + @ dup 1 << 'rdes 8 + ! 'rsrc 8 + !
	SDLrenderer 	| n 'ts ren
	rot rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rsrc ! | ren txture rsrc
	'rsrc 'rdes 
	SDL_RenderCopy
	;

|--------------------------------
#rbox [ 0 0 64 64 ]

:sprite | tex x y w h -- 
	swap 2swap swap
	'rbox d!+ d!+ d!+ d!
	SDLrenderer swap 0 'rbox SDL_RenderCopy ;
	
:sdlcolor | col --
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;
	
|--------------------------------	
| posicion y velocidad 
#px 200.0 #py 10.0
#vx 0.0 #vy 0.0

:jugador
	msec 8 >> $3 and sprbird px 16 >> py 16 >> tsdraw

	py 16 >> sh >? ( -10.0 'vy ! ) drop
	vy 'py +!
	0.1 'vy +! 
	;
	
#pxp 400.0
#pyp 300
#pxp2 800.0
#pyp2 300

	
:drawpipe | x y --
	sprpipe pick2 0 60 pick4 80 - sprite 
	sprpipe pick2 5 - pick2 80 - 70 40 sprite
	sprpipe pick2 5 - pick2 80 + 70 40 sprite
	sprpipe pick2 pick2 120 + 60 sh pick2 - sprite 
	2drop ;

:newpipe
	pxp2 'pxp ! pyp2 'pyp !
	800.0 'pxp2 ! 500 randmax 'pyp2 ! ;
	
:fondo	
	pxp2 16 >> pyp2 drawpipe 
	pxp 16 >> pyp drawpipe 
	-2.4 'pxp +!
	-2.4 'pxp2 +!
	pxp -80.0 <? ( newpipe ) drop
	;
	
:juego
	0 sdlcolor SDLrenderer SDL_RenderClear
	fondo
	jugador
	SDLrenderer SDL_RenderPresent
	
	SDLkey
	>esc< =? ( exit )
	<esp> =? ( -4.0 'vy ! )	
	drop
	;

:main
	"r3sdl" 800 600 SDLinit

	"media/img/pileline.png" loadimg 'sprpipe !
	36 25 "media/img/bird.png" loadts 'sprbird !

	'juego SDLshow
	
	SDLquit
	;
		

:
mark main
;
