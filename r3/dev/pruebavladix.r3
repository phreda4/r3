^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/tilesheet.r3

#vladix
#nrovladix 102
#sumvladix 0
#maxvladix 0
#xp 100.0 #yp 400.0
#xv #yv

:int. 16 >> ;

:animacion	| cnt nro -- 
	16 << 
	nrovladix =? ( 2drop ; )
	'nrovladix ! 
	'maxvladix ! 
	0 'sumvladix !
	;
:nroimagen	| -- nro
	0.09 'sumvladix +!		| velocidad de cambio de imagen
	
	nrovladix sumvladix + int.
	maxvladix >=? ( drop nrovladix int. 0 'sumvladix ! ) 
	;

#gelatina
#nrogelatina 12
#sumgelatina 0
#maxgelatina 0
#xp1 200.0 #yp1 400.0
#xv1 #yv1


:animacion2	| cnt nro -- 
	16 << 
	nrogelatina =? ( 2drop ; )
	'nrogelatina ! 
	'maxgelatina ! 
	0 'sumgelatina !
	;
:nroimagen1	| -- nro
	0.09 'sumgelatina +!		| velocidad de cambio de imagen
	
	nrogelatina sumgelatina + int.
	maxgelatina >=? ( drop nrogelatina int. 0 'sumgelatina ! ) 
	;
	
#vida
#nrovida 5
#sumvida 0
#maxvida 0
#xp2 100.0 #yp2 200.0
#xv2 #yv2


:animacion3	| cnt nro -- 
	16 << 
	nrovida =? ( 2drop ; )
	'nrovida ! 
	'maxvida ! 
	0 'sumvida !
	;
:nroimagen2	| -- nro
	0.09 'sumvida +!		| velocidad de cambio de imagen
	
	nrovida sumvida + int.
	maxvida >=? ( drop nrovida int. 0 'sumvida ! ) 
	;

:teclado
	SDLkey
	>esc< =? ( exit )
	

	
	<w> =? ( 0 'xv !  4 0 animacion )
	>w< =? ( 0 'xv ! 3 3  animacion )
	
	<a> =? ( -1.0 'xv ! 6 6 animacion )
	>a< =? ( 0 'xv ! 3 3 animacion )
	
	<d> =? ( 1.0 'xv ! 14 13 animacion )
	>d< =? ( 0 'xv ! 3 3 animacion )
	
	<q> =? ( 0 'xv ! 24 24 animacion )
	>q< =? ( 0 'xv ! 3 3 animacion )
	
	<e> =? ( 0 'xv ! 35 30 animacion )
	>e< =? ( 0 'xv ! 3 3 animacion )
	
	<r> =? ( 0 'xv ! 58 42 animacion )
	>r< =? ( 0 'xv ! 3 3 animacion )
	
	<f> =? ( 0 'xv ! 23 18 animacion )
	>f< =? ( 0 'xv ! 3 3 animacion )
	
	<x> =? ( 0 'xv ! 38 36 animacion )
	>x< =? ( 0 'xv ! 3 3 animacion )
	
	<j> =? ( -1.0 'xv1 ! 6 6 animacion2 )
	>j< =? ( 0 'xv1 ! 6 6 animacion2 )
	
	<l> =? ( 1.0 'xv1 ! 0 0 animacion2 )
	>l< =? ( 0 'xv1 ! 0 0 animacion2 )
	
	>i< =? ( 0 'xv1 ! 1 1 animacion2 )
	<k> =? ( 0 'xv1 ! 0 0 animacion2 )
	
	<u> =? ( -1.0 'xv1 ! 7 7 animacion2 )
	>u< =? ( 0 'xv1 ! 7 7 animacion2 )
	
	<o> =? ( 1.0 'xv1 ! 1 1 animacion2 )
	>o< =? ( 0 'xv1 ! 1 1 animacion2 )
	
	<n> =? ( 0 'xv1 ! 11 8 animacion2 )
	>n< =? ( 0 'xv1 ! 7 7 animacion2 )
	
	<m> =? ( 0 'xv1 ! 5 2 animacion2 )
	>m< =? ( 0 'xv1 ! 1 1 animacion2 )
	
	<z> =? ( 0 'xv2 !  4 0 animacion3 )
	>z< =? ( 0 'xv2 !  0 0 animacion3 )
	
	drop ;

	
:demo
	0 SDLcls
	
	nroimagen
	vladix
	xp int. yp int.
	tsdraw
	
	nroimagen1
	gelatina
	xp1 int. yp1 int.
	tsdraw 
	
	nroimagen2
	vida
	xp2 int. yp2 int.
	200 104
	tsdraws
	
	SDLredraw
	
	xv 'xp +!
	yv 'yp +!
	xv1 'xp1 +!
	yv1 'yp1 +!
	xv2 'xp2 +!
	yv2 'yp2 +!
	
	teclado
	;
	
:main
	"r3sdl" 800 600 SDLinit
	45 60 "media/img/guybrush.png" loadts 'vladix !
	64 64 "media/img/guybrush.png" loadts 'gelatina !
	50 26 "media/img/guybrush.png" loadts 'vida !
	'demo SDLshow
	SDLquit ;	
	
: main ;