| Value noise con FBM generico (N octavas, shift en vez de division, normalizado al final)
^r3/lib/sdl2gfx.r3

#textbitmap
#mpixel
#mpitch
#frame 0

:hash | v -- byte
	$27d4eb2f *
	dup 15 >>> xor
	$85ebca6b *
	dup 13 >>> xor
	$ff and ;

:frac | v -- f
	$ffff and ;

:vhash | ly lx -- byte
	10 << + hash ;

:fade | t -- v
	3.0 over 2* - over *. *. ;

:lerp | a b t -- v
	-rot over - rot *. + ;

#vx0 #vy0 
#vfx #vfy 

| lshift = 16 - log2(cell): cell=32 -> 11, cell=16 -> 12, cell=8 -> 13 ...
:voctaveOLD | ylat xlat -- byte
	dup int. 'vx0 ! frac fade 'vfx !
	dup int. 'vy0 ! frac fade 'vfy !
	vy0 vx0 vhash
	vy0 vx0 1+ vhash
	vfx lerp
	vy0 1+ vx0 vhash
	vy0 1+ vx0 1+ vhash
	vfx lerp
	vfy lerp ;

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


| ---- suma de N octavas: escala y amplitud por shift, normaliza al final ----
#fvlsh0 10
#foctaves 4
#facc #famp #ftotalamp 

:fbmvalue | y x octaves -- byte
	rot fvlsh0 <<
	rot fvlsh0 <<
	rot
	0 'facc ! 
	256 'famp !
	( 1? 1- >r
		2dup voctave 
		famp 
		dup 2/ 'famp !
		* 'facc +!
		2* swap 2* swap
		r> ) 3drop
|	facc ftotalamp / $ff and 
	facc
	;

:updatevalue
	textbitmap 0 'mpixel 'mpitch SDL_LockTexture
	mpixel >a
	480 ( 1? 1-
		640 ( 1? 1-
			over frame + 
			over frame + 
			foctaves fbmvalue
			| dup 8 << over 16 << or or 
			| $ffffff xor
			$ff000000 or da!+
		) drop
	) drop
	textbitmap SDL_UnlockTexture
	1 'frame +! ;

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
