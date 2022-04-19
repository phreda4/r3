^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/tilesheet.r3

#tsguy	| dibujo
#nroguy 12	| frame inicio
#sumguy 0	| suma para animacion
#maxguy 0	| frame maximo

#xp 100.0 #yp 400.0		| posicion

#xv #yv		| velocidad

:int. 16 >> ;

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
	maxguy >=? ( drop nroguy int. 0 'sumguy ! ) 
	;
	
:teclado
	SDLkey
	>esc< =? ( exit )
	
	<a> =? ( -1.0 'xv ! 12 6 animacion )
	>a< =? ( 0 'xv ! 0 13 animacion )
	
	<d> =? ( 1.0 'xv ! 6 0 animacion )
	>d< =? ( 0 'xv ! 0 12 animacion )	
	
	drop ;

	
:demo
	0 SDLClear
	
	nroimagen
	tsguy
	xp int. yp int. 
	tsdraw 
	
	SDLRedraw
	
	xv 'xp +!
	yv 'yp +!
	
	teclado
	;
	
:main
	"r3sdl" 800 600 SDLinit
	104 150 "media/img/guybrush.png" loadts 'tsguy !
	'demo SDLshow
	SDLquit ;	
	
: main ;