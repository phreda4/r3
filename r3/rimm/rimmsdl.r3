| RIMM backend: SDL2 render
|
^r3/lib/sdl2.r3
^r3/lib/sdl2gfx.r3
^r3/lib/color.r3
^r3/util/txfont.r3

|--- clip: gclip/gclip0 as immsdl.r3, plus a stack
#clipbox [ 0 0 0 0 ]
#gcon 0 #gcx #gcy #gcw #gch
#gcst * 320 | 8 levels: on x y w h (qwords)
#gcsp 0

::gclip | x y w h -- ; clip the drawing to the rectangle
	1 'gcon !
	dup 'gch ! 'clipbox 12 + d!
	dup 'gcw ! 'clipbox 8 + d!
	dup 'gcy ! 'clipbox 4 + d!
	dup 'gcx ! 'clipbox d!
	SDLrenderer 'clipbox SDL_RenderSetClipRect ;

::gclip0 | -- ; remove the clip
	0 'gcon !
	SDLrenderer 0 SDL_RenderSetClipRect ;

:gcisect | p l cp cl -- p' l'	; interseccion 1D: inicio y largo
	over +
	pick3 pick3 + min
	rot drop
	-rot max
	swap over - 0 max ;

::gclipPush | x y w h -- ; clip to the rectangle intersected with the current clip; gclipPop goes back
	gcsp 8 >=? ( drop 4drop ; ) drop
	gcsp 40 * 'gcst + >a
	gcon a!+ gcx a!+ gcy a!+ gcw a!+ gch a!+
	1 'gcsp +!
	gcon 0? ( drop gclip ; ) drop
	| intersection: x y w h with gcx gcy gcw gch
	rot swap gcy gch gcisect 2swap gcx gcw gcisect 2swap rot swap gclip ;

::gclipPop | -- ; back to the clip before gclipPush
	gcsp 0? ( drop ; ) drop
	-1 'gcsp +!
	gcsp 40 * 'gcst + >a
	a@+ 0? ( drop 0 'gcon ! gclip0 ; ) drop
	a@+ a@+ a@+ a@
	gclip ;
