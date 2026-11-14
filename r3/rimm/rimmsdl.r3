| RIMM backend: SDL2 render
| Reuses sdl2gfx + txfont (nothing is copied). Adds only what the gui needs
| and the stock backend does not have:
|   gclipPush gclipPop  nested clip (intersection with the previous one)
|   frectg              rectangle with a color in each corner
|
| BACKEND CONTRACT (what rimmcore/rimmwid use; a new backend must give these)
|   color colorA frect rect fround round lineH lineV line fcircle circle triangle
|   gclip gclip0 imageb
|   txfont txfont@ txrgb txat txw txh txwrite txText txalign txcur txcuri
|   + the two of this file: gclipPush gclipPop frectg
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

#nx #ny #nx2 #ny2

::gclipPush | x y w h -- ; clip to the rectangle intersected with the current clip; gclipPop goes back
	gcsp 8 >=? ( drop 4drop ; ) drop
	gcsp 40 * 'gcst + >a
	gcon a!+ gcx a!+ gcy a!+ gcw a!+ gch a!+
	1 'gcsp +!
	gcon 0? ( drop gclip ; ) drop
	| intersection: x y w h with gcx gcy gcw gch
	pick3 + 'ny2 ! pick2 + 'nx2 ! 'ny ! 'nx !
	nx gcx max 'nx ! ny gcy max 'ny !
	nx2 gcx gcw + min 'nx2 ! ny2 gcy gch + min 'ny2 !
	nx ny nx2 nx - 0 max ny2 ny - 0 max gclip ;

::gclipPop | -- ; back to the clip before gclipPush
	gcsp 0? ( drop ; ) drop
	-1 'gcsp +!
	gcsp 40 * 'gcst + 
	@+ swap @+ swap @+ swap @+ swap @+ nip	| on x y w h
	rot 0? ( drop 4drop gclip0 ; ) drop
	gclip ;

|--- rectangle with four colors (bilinear), colors $RRGGBB
#gvert * 80
#gidx * 24
#gx #gy #gw #gh #gc1 #gc2 #gc3 #gc4

:c>v | rgb -- sdlcolor
	bgr2rgb $ff000000 or ;

::frectg | x y w h tl tr bl br -- ; fills with color in each corner
	'gc4 ! 'gc3 ! 'gc2 ! 'gc1 !
	'gh ! 'gw ! 'gy ! 'gx !
	'gvert >a
	gx i2fp da!+ gy i2fp da!+ gc1 c>v da!+ 8 a+
	gx gw + i2fp da!+ gy i2fp da!+ gc2 c>v da!+ 8 a+
	gx gw + i2fp da!+ gy gh + i2fp da!+ gc4 c>v da!+ 8 a+
	gx i2fp da!+ gy gh + i2fp da!+ gc3 c>v da!+ 8 a+
	SDLrenderer 0 'gvert 4 'gidx 6 SDL_RenderGeometry ;

: 'gidx >a 0 da!+ 1 da!+ 3 da!+ 1 da!+ 2 da!+ 3 da!+ ;
