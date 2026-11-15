| RIMM backend: SDL2 render
| Reuses sdl2gfx + txfont (nothing is copied). Adds only what the gui needs
| and the stock backend does not have:
|   gclipPush gclipPop  nested clip (intersection with the previous one)
|
| BACKEND CONTRACT (what rimmcore/rimmwid use; a new backend must give these)
|   color colorA frect rect fround round lineH lineV lineHg lineVg line fcircle circle triangle
|   gclip gclip0 imageb
|   txfont txfont@ txrgb txat txw txh txwrite txText txalign txcur txcuri
|   + the two of this file: gclipPush gclipPop
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
#pon 0

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

#nx #ny #nx2 #ny2

::gclipPush | x y w h -- ; clip to the rectangle intersected with the current clip; gclipPop goes back
	gcsp 8 >=? ( drop 4drop ; ) drop
	gcsp 40 * 'gcst + >a
	gcon a!+ gcx a!+ gcy a!+ gcw a!+ gch a!+
	1 'gcsp +!
	gcon 0? ( drop gclip ; ) drop
	| intersection: x y w h with gcx gcy gcw gch
	pick2 + 'ny2 ! pick2 + 'nx2 ! 'ny ! 'nx !
	nx gcx max 'nx ! ny gcy max 'ny !
	nx2 gcx gcw + min 'nx2 ! ny2 gcy gch + min 'ny2 !
	nx ny nx2 nx - 0 max ny2 ny - 0 max gclip ;

::gclipPop | -- ; back to the clip before gclipPush
	gcsp 0? ( drop ; ) drop
	-1 'gcsp +!
	gcsp 40 * 'gcst + >a
	a@+ 'pon ! a@+ a@+ a@+ a@
	pon 0? ( drop 4drop 0 'gcon ! gclip0 ; ) drop
	gclip ;
