| Animation example
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

#tsguy	| dibujo
#nroguy 12	| frame inicio
#sumguy 0	| suma para animacion
#maxguy 0	| frame maximo

#xp 100.0 #yp 400.0		| posicion

#xv #yv		| velocidad

:animacion	| cnt nro -- 
	16 << 
	nroguy =? ( 2drop ; )
	'nroguy ! 
	'maxguy ! 
	0 'sumguy !
	;
	
:nroimagen	| -- nro
	0.09 'sumguy +!		| velocidad de cambio de imagen
	
	nroguy sumguy + int.
	maxguy >? ( drop nroguy int. 0 'sumguy ! ) 
	;
	
:teclado
	SDLkey
	>esc< =? ( exit )
	
	<a> =? ( -1.0 'xv ! 8 1 animacion )
	>a< =? ( 0 'xv ! 0 0 animacion )
	
	<d> =? ( 1.0 'xv ! 17 10 animacion )
	>d< =? ( 0 'xv ! 0 9 animacion )	
	
	drop ;

	
:demo
	0 SDLcls
	
	xp int. yp int. 3.0 nroimagen tsguy sspritez	
	
	SDLredraw
	
	xv 'xp +!
	yv 'yp +!
	
	teclado
	;
	
:main
	"sdl" 800 600 SDLinit
	16 32 "media/img/p2.png" ssload 'tsguy !
	'demo SDLshow
	SDLquit ;	
	
: main ;