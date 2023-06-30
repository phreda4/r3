^r3/win/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/bfont.r3

#sprites
#x 320.0 #y 380.0
#xv 0 #yv 0

#xa 0.0 #ya 100.0

:+alien
	-16.0 'ya ! 480.0 randmax 'xa ! ;

:alien
	xa int. ya int. 2.0 
	msec 7 >> $3 and 2 +
	sprites sspritez 
	2.0 'ya +!
	ya 480.0 >? ( +alien ) drop ;
	
:jugador
	x int. y int. 2.0 	
	msec 7 >> $1 and 
	sprites sspritez 
	xv 'x +! yv 'y +! ;
	
#xd #yd 

:disparo
	$ffffff SDLColor
	xd -? ( drop ; ) | si es negativo sale
	int. 1 - yd int. 3 8 SDLFRect
	-4.0 'yd +!
	yd -? ( -1.0 'xd ! ) drop ;

:+disparo
	xd +? ( drop ; ) drop 
	x 'xd ! y 'yd ! ;

#puntos 0
#vidas 3

:+punto
	1 'puntos +!
	-1 'xd !
	+alien ;
	
:choco?
	xa xd - abs 16.0 >? ( drop ; ) drop
	ya yd - abs 8.0 >? ( drop ; ) drop
	+punto ;

:perdio?
	xa x - abs 16.0 >? ( drop ; ) drop
	ya y - abs 16.0 >? ( drop ; ) drop
	-1 'vidas +!
	vidas 0? ( exit ) drop
	320.0 'x ! 
	380.0 'y !
	+alien ;

:juego
	0 SDLcls
	disparo jugador	alien	
	choco? perdio?
	10 8 bat puntos "puntos:%d" sprint bprint
	10 24 bat vidas "vidas:%d" sprint bprint
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1.0 'xv ! ) >le< =? ( 0 'xv ! )
	<ri> =? ( 1.0 'xv ! ) >ri< =? ( 0 'xv ! )
	<esp> =? ( +disparo )
	drop ;

:main
	"r3sdl" 640 480 SDLinit
	bfont1 
	16 16 "media/img/manual.png" ssload 'sprites !			
	+alien
	'juego SDLshow
	SDLquit ;	
	
: main ;
