| programa 3
| puntos en pantalla

^r3/win/sdl2.r3
^r3/lib/rand.r3


#puntos * $3fff 		| memoria para x,y de cada punto
#puntos> 'puntos

:dibujarpuntos
	$ffffff sdlcolor 
	'puntos ( puntos> <?	| desde la memoria hasta el final
		w@+		| dir+ x
		swap	| x dir
		w@+		| x dir+ y
		rot 	| dir y x
		swap	| dir x y
		SDLPoint | dir
		) drop ;

:dibujarymoverpuntos
	$ffffff sdlcolor 
	'puntos ( puntos> <?	| desde la memoria hasta el final
		dup w@ 			| dir x
		-? ( sw nip )	| dir x (si es negativo se cambia por sw (ancho)
		dup 			| dir x x
		1 - 			| dir x x-1
		rot 			| x x-1 dir
		w!+				| x dir+ ( grabo nuevo x )
		w@+ 			| x dir y
		rot swap 		| dir x y
		SDLPoint
		) drop ;

:llenapuntos
	rerand			| numeros al azar
	'puntos 		| mem    ; memoria donde lo graba
	$fff ( 1? 1 -	| mem cnt
		sw randmax 	| mem cnt rand ; entre 0 y sw (ancho de pantalla)
		rot w!+		| cnt mem+
		sh randmax 	| cnt mem rand ; entre 0 y sh (alto de pantalla)
		swap w!+	| cnt mem
		swap ) drop | mem
	'puntos> ! ;	| graba el fin del esta lista


:dibuja
	0 SDLclear
	
	|dibujarpuntos	 | comentada.. no ocurre
	dibujarymoverpuntos

	SDLRedraw

	SDLkey
	>esc< =? ( exit )
	drop
	;

|-------------------------- INICIO 
:	
	"r3sdl" 800 600 SDLinit
	llenapuntos
	'dibuja SDLshow
	SDLquit 
	;
