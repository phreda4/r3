| RIMM backend: OpenGL (glgfx)

| Same contract as rimmsdl.r3. Fonts: txload (gltxfont, TTF atlas) + txfont, as txfont.r3 in SDL.
| Load the fonts after rimmGLini.
| IMPORTANT: glgfx must be called once after GLini (rimmGLini does both), and every
| frame the gui goes between fini and fend:  GLcls fini uiStart ... uiEnd fend GLUpdate
| On a window resize fixFontResize (glgfx) is called by rimmGLini through SDLeventR
| (if the program sets its own SDLeventR, it must call fixFontResize inside it).
|
^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/util/glgfx.r3
^r3/util/gltxfont.r3

::rimmGLini | "title" w h -- ; open the GL window and prepare glgfx (shader): GLini + glgfx. Without glgfx nothing is drawn
	GLini glgfx
	'fixFontResize SDLeventR ;

|--- nested clip over gclip/gclip0
#gcon 0 #gcx2 #gcy2 #gcw2 #gch2
#gcst * 320 | 8 levels: on x y w h
#gcsp 0

:gset | x y w h --
	1 'gcon ! 'gch2 ! 'gcw2 ! 'gcy2 ! 'gcx2 !
	gcx2 gcy2 gcw2 gch2 gclip ;

:gcisect | p l cp cl -- p' l'	; interseccion 1D: inicio y largo
	over +
	pick3 pick3 + min
	rot drop
	-rot max
	swap over - 0 max ;

::gclipPush | x y w h -- ; clip to the rectangle intersected with the current clip
	gcsp 8 >=? ( drop 4drop ; ) drop
	gcsp 40 * 'gcst + >a
	gcon a!+ gcx2 a!+ gcy2 a!+ gcw2 a!+ gch2 a!+
	1 'gcsp +!
	gcon 0? ( drop gset ; ) drop
	rot swap gcy2 gch2 gcisect 2swap gcx2 gcw2 gcisect 2swap rot swap gset ;

::gclipPop | -- ; back to the clip before gclipPush
	gcsp 0? ( drop ; ) drop
	-1 'gcsp +!
	gcsp 40 * 'gcst + >a
	a@+ 0? ( drop 0 'gcon ! gclip0 ; ) drop
	a@+ a@+ a@+ a@
	gset ;
