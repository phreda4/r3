| RIMM backend: OpenGL (glgfx)
| Reuses glgfx (nothing is copied; the batched glgfx already has colorA, line, circle,
| fcircle, triangle...) and adds what the gui needs and glgfx lacks:
|   txcw txemit          width of a character / draw one (for the editor, rimmedit)
|   gclipPush gclipPop  nested clip
|   frectg              rectangle with a color in each corner (rimmfall, over frect)
| Same contract as rimmsdl.r3.
| IMPORTANT: glgfx must be called once after GLini (rimmGLini does both), and every
| frame the gui goes between fini and fend:  GLcls fini uiStart ... uiEnd fend GLUpdate
| On a window resize call fixFontResize (glgfx).
|
^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/util/glgfx.r3
^r3/rimm/rimmfall.r3

::rimmGLini | "title" w h -- ; open the GL window and prepare glgfx (shader and font): GLini + glgfx. Without glgfx nothing is drawn
	GLini glgfx ;

::txcw | adr car -- adr' w ; width of a character (the bitmap font of glgfx is monospace)
	drop "M" txw nip ;

#txe 0
::txemit | adr car -- adr' ; draw the character at the cursor and advance it
	'txe c! 'txe txwrite ;

|--- nested clip over gclip/gclip0
#gcon 0 #gcx2 #gcy2 #gcw2 #gch2
#gcst * 320 | 8 levels: on x y w h
#gcsp 0
#pon 0
#nx #ny #nx2 #ny2

:gset | x y w h --
	1 'gcon ! 'gch2 ! 'gcw2 ! 'gcy2 ! 'gcx2 !
	gcx2 gcy2 gcw2 gch2 gclip ;

::gclipPush | x y w h -- ; clip to the rectangle intersected with the current clip
	gcsp 8 >=? ( drop 4drop ; ) drop
	gcsp 40 * 'gcst + >a
	gcon a!+ gcx2 a!+ gcy2 a!+ gcw2 a!+ gch2 a!+
	1 'gcsp +!
	gcon 0? ( drop gset ; ) drop
	pick2 + 'ny2 ! pick2 + 'nx2 ! 'ny ! 'nx !
	nx gcx2 max 'nx ! ny gcy2 max 'ny !
	nx2 gcx2 gcw2 + min 'nx2 ! ny2 gcy2 gch2 + min 'ny2 !
	nx ny nx2 nx - 0 max ny2 ny - 0 max gset ;

::gclipPop | -- ; back to the clip before gclipPush
	gcsp 0? ( drop ; ) drop
	-1 'gcsp +!
	gcsp 40 * 'gcst + >a
	a@+ 'pon ! a@+ a@+ a@+ a@
	pon 0? ( drop 4drop 0 'gcon ! gclip0 ; ) drop
	gset ;
