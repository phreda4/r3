^r3/win/sdl2gfx.r3
^r3/util/arr16.r3
^r3/lib/rand.r3

| posicion jugador
#xp 400 #yp 500
| velocidad jugador
#xv #yv 

| Hojas de sprite
#sprj
	
|-------------------------------------------
:jugador	
	xp yp	| posicion
	0 4.0 	| rotacion escala
	msec 7 >> $1 and 2 + | NRO  
	sprj	| spritesheet
	sspriterz

	xv 'xp +!
	;

:teclado
	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1 'xv ! )
	<ri> =? ( 1 'xv !  )
	>le< =? ( 0 'xv !  )
	>ri< =? ( 0 'xv ! )	
	drop 
	;
	
:jugando
	$0 SDLcls	| limpia pantalla
	jugador 	 
	SDLredraw	| redibuja
	teclado 	
	;
	
|-------------------------------------------
:main
	"Sprite sheet" 800 600 SDLinit
	32 32 "media/img/tanque.png" loadssheet 'sprj !
	'jugando SDLshow
	SDLquit ;	
	
: main ;