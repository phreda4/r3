| programa 2 
| puntos en pantalla

^r3/win/sdl2.r3
^r3/lib/rand.r3
 
#puntos * 8192 		| memoria para x,y de cada punto
#puntos> 'puntos

:dibujarpuntos
	$ffffff sdlcolor 
	'puntos ( puntos> <?	| desde la memoria hasta el final
		d@+		| dir x
		swap	| x dir
		d@+		| x dir y
		rot 	| dir y x
		swap	| dir x y
		SDLPoint | dir
		) drop ;

:dibujarymoverpuntos
	$ffffff sdlcolor 
	'puntos ( puntos> <?	| desde la memoria hasta el final
		d@+ 			| dir x
		-? ( sw nip )	| dir x (si es negativo se cambia por sw (ancho)
		dup 			| dir x x
		1 - 			| dir x x-1
		pick2 			| dir x x-1 dir
		4 - 			| dir x x-1 dir-4 (donde estaba x)
		d!				| dir x  ( grabo nuevo x )
		swap 			| x dir
		d@+ 			| x dir y
		rot swap 		| dir x y
		SDLPoint
		) drop ;

:llenapuntos
	rerand			| numeros al azar
	'puntos >a		| memoria donde lo graba
	1024 ( 1? 1 -
		sw randmax da!+	| entre 0 y sw (ancho de pantalla)
		sh randmax da!+ | entre 0 y sh (alto de pantalla)
		) drop
	a> 'puntos> ! ;	| graba el fin del esta lista


:dibuja
	0 SDLcolor 
	SDLrenderer SDL_RenderClear
	
	dibujarpuntos	
	| dibujarymoverpuntos | comentada.. no ocurre
	
	SDLrenderer SDL_RenderPresent

	SDLkey
	>esc< =? ( exit )
	drop
	;

:	|====================== INICIO 
	"r3sdl" 800 600 SDLinit

	llenapuntos
	'dibuja SDLshow
	
	SDLquit 
	;
