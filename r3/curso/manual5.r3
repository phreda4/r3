^r3/win/sdl2gfx.r3
^r3/lib/rand.r3

#spr1
#x 320.0 #y 380.0
#xv 0 #yv 0

#alien
#xa 0.0 #ya 100.0

:+alien
	-16.0 'ya ! 
	480.0 randmax 'xa !
	;

#xd #yd 

:disparo
	$ffffff SDLColor
	xd -? ( drop ; ) | si es negativo sale
	int. yd int. over yd int. 8 + SDLLine
	-4.0 'yd +!
	yd -? ( -1.0 'xd ! ) drop ;

:+disparo
	xd +? ( drop ; ) drop 
	x 'xd ! y 'yd ! ;

#puntos 0

:+punto
	1 'puntos +!
	-1 'xd !
	+alien ;
	
:choco? | -- c ; si no choco=0
	xa xd - abs 16.0 >? ( drop ; ) drop
	ya yd - abs 16.0 >? ( drop ; ) drop
	+punto
	;

:juego
	0 SDLcls
	
	x int. y int. spr1 SDLImage
	xv 'x +!
	yv 'y +!
	
	xa int. ya int. alien SDLImage
	2.0 'ya +!
	ya 480.0 >? ( +alien ) drop
	
	disparo
	choco?
	
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1.0 'xv ! ) >le< =? ( 0 'xv ! )
	<ri> =? ( 1.0 'xv ! ) >ri< =? ( 0 'xv ! )
	<esp> =? ( +disparo )
	drop ;

:main
	"r3sdl" 640 480 SDLinit
	"media/img/ball.png" loadimg 'spr1 ! 
	|"media/img/alien.png" 
	"media/img/ball.png" 
	loadimg 'alien ! 		
	
	'juego SDLshow
	SDLquit ;	
	
: main ;
