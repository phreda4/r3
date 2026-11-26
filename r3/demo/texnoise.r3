| Value noise con FBM generico (N octavas, shift en vez de division, normalizado al final)
| - escala de grises: byte normalizado replicado en R G B
| - cada octava tiene su propio offset (x,y) que avanza con su propia velocidad
^r3/lib/sdl2gfx.r3

#textbitmap
#mpixel
#mpitch

:hash | v -- byte
	$27d4eb2f *
	dup 15 >>> xor
	$85ebca6b *
	dup 13 >>> xor
	$ff and ;

:frac | v -- f
	$ffff and ;

:fade | t -- v
	3.0 over 2* - over *. *. ;

:lerp | a b t -- v
	-rot over - rot *. + ;

#vfx #vfy

:voctave | ylat xlat -- byte
	dup frac fade 'vfx !
	over frac fade 'vfy !
	int. 10 << swap int. +
	dup hash
	over $400 + hash
	vfx lerp
	over $1 + hash
	rot  $401 + hash
	vfx lerp
	vfy lerp ;

| ---- offsets por octava (unidades 16.16 del reticulado de cada octava) ----
| tabla: x0 y0 x1 y1 ... (hasta 8 octavas)
#offs * 128
| velocidad por octava (por frame), x y, en punto fijo 16.16 (celdas de esa octava por frame)
| 0.01 = 1/100 de celda; las frecuencias altas van mas rapido y en otras direcciones
#vels 0.008 0.005 0.0025 0.016 0.0075 0.05 0.02 0.015 0.04 0.03 0.07 0.06 0.2 0.9 2.0 1.6


| ---- suma de N octavas: escala y amplitud por shift, normaliza al final ----
#fvlsh0 10
#foctaves 4
#facc #famp #ftotalamp

:moveoffs | --
	'offs >a 'vels >b
	foctaves 2* ( 1? 1-
		b@+ a@ + a!+
	) drop ;

:fbmvalue | y x octaves -- byte
	rot fvlsh0 <<
	rot fvlsh0 <<
	rot
	0 'facc !
	256 'famp !
	'offs >b
	( 1? 1- >r
		2dup
		b@+ + swap b@+ + swap	| aplica offset de esta octava
		voctave
		famp
		dup 2/ 'famp !
		* 'facc +!
		2* swap 2* swap
		r> ) 3drop
	facc ftotalamp / ;			| 0..255

:updatevalue
	moveoffs
	textbitmap 0 'mpixel 'mpitch SDL_LockTexture
	mpixel >a
	480 ( 1? 1-
		640 ( 1? 1-
			2dup foctaves fbmvalue
			dup 8 << over 16 << or or	| gris: v v v
			$ff000000 or da!+
		) drop
	) drop
	textbitmap SDL_UnlockTexture ;

:draw
	updatevalue
	SDLrenderer textbitmap 0 0 SDL_RenderCopy
	SDLredraw
	SDLkey >esc< =? ( exit ) drop ;

:main
	"r3sdl" 640 480 SDLinit
	640 480 SDLframebuffer 'textbitmap !

	256 2* dup foctaves >> - 'ftotalamp !

	'draw SDLshow
	SDLquit ;

: main ;
