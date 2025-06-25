|------------------------------
| gui.r3 - PHREDA
| Immediate mode gui for r3
|------------------------------
^r3/lib/sdl2.r3

|--- state
##hot	| activo actual
#hotnow	| activo anterior
#actnow | real activo 
#foco	| activo teclado
#foconow	| activo teclado

##clkbtn
|--- id
#id		| id gui actual
#idf	| id gui foco actual (teclado)
#idl	| id foco ultimo

|--- region
##xr1 ##yr1
##xr2 ##yr2

##guin? | mouse in rect?

:guiIn	| b x y --
	1 'id +!
	yr2 over - swap yr1 - or swap	
	xr2 over - swap xr1 - or or
	63 >> not 						| x y -- -1/0
	'guin? ! ;

::guiBox | x1 y1 w h --
	pick2 + 'yr2 ! pick2 + 'xr2 ! 'yr1 ! 'xr1 ! 
	SDLx SDLy guiIn ;

::guiRect | x1 y1 x2 y2 --
	'yr2 ! 'xr2 ! 'yr1 ! 'xr1 ! 
	SDLx SDLy guiIn ;

|---------
::gui
	idf 'idl ! hot 'hotnow !
	0 'id ! 0 'idf ! 0 'hot !
	0 0 sw sh guiRect
	;

|-- boton
::onClick | 'click --
	guin? 0? ( 2drop ; ) drop
	SDLb 0? ( id hotnow =? ( 2drop ex ; ) 3drop ; ) 
	'clkbtn !
	drop
	id 'hot ! ;

|-- move
::onMove | 'move --
	SDLb 0? ( 2drop ; ) drop
	guin? 0? ( 2drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 2drop ; ) drop
	ex ;

|-- dnmove
::onDnMove | 'dn 'move --	
	SDLb 0? ( 3drop ; ) drop
	hotnow 1? ( id <>? ( 3drop ; ) ) drop | solo 1
	guin? 0? ( 3drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 2drop ex ; )
	drop nip ex ;	

::onDnMoveA | 'dn 'move -- | si apreto adentro.. mueve siempre
	SDLb 0? ( 3drop ; ) drop
	hotnow 1? ( id <>? ( 3drop ; ) ) drop | solo 1
	guin? 0? ( id hotnow =? ( 'hot ! drop nip ex ; ) 4drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 2drop ex ; )
	drop nip ex ;

::onMapA | 'dn 'move 'up -- | si apreto adentro.. mueve siempre, con up
	SDLb 0? ( hotnow id =? ( 2drop nip nip ex ; ) nip 4drop ; ) drop
	hotnow 1? ( id <>? ( 4drop ; ) ) drop | solo 1
	guin? 0? ( id hotnow =? ( 'hot ! 2drop nip ex ; ) nip 4drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 3drop ex ; )
	2drop nip ex ;

|-- mapa
::guiMap | 'dn 'move 'up --
	guin? 0? ( 4drop ; ) drop
	SDlb 0? ( id hotnow =? ( 2drop nip nip ex ; ) 4drop drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 3drop ex ; )
	2drop nip ex ;

::guiDraw | 'move 'up --
	guin? 0? ( 3drop ; ) drop
	SDLb 0? ( id hotnow =? ( 2drop nip ex ; ) 4drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 3drop ; )
	2drop ex ;

::guiEmpty | --		; si toca esta zona no hay interaccion
	guin? 1? ( id 'hotnow ! )
	drop ;

|----- test adentro/afuera
::guiI | 'vector --
	guin? 0? ( 2drop ; ) drop ex ;

::guiO | 'vector --
	guin? 1? ( 2drop ; ) drop ex ;

::guiIO | 'vi 'vo --
	guin? 1? ( 2drop ex ; ) drop nip ex ;

|---------------------------------------------------
| manejo de foco (teclado)

::nextfoco
	foco 1+ idl >? ( 0 nip ) 'foco ! ;

::prevfoco
	foco 1- 0 <=? ( idl nip ) 'foco ! ;

::setfoco | nro --
	'foco ! -1 'foconow ! ;

|::ktab
|	mshift 1? ( drop prevfoco ; ) drop
|	nextfoco ;

::clickfoco
	idf foco =? ( drop ; ) 'foco ! ;

::clickfoco1
	idf 1+ 'foco ! -1 'foconow ! ;

::refreshfoco
	-1 'foconow ! 0 'foco ! ;

::w/foco | 'in 'start --
	idf 1+
	foco 0? ( drop dup dup 'foco ! ) | quitar?
	<>? ( 'idf ! 2drop ; )
	foconow <>? ( dup 'foconow ! swap ex 'idf ! drop ; )
	nip 'idf ! ex ;

::focovoid | --
	idf 1+
	foco 0? ( drop dup dup 'foco ! ) | quitar?
	<>? ( 'idf ! ; )
	foconow <>? ( dup 'foconow ! )
	'idf ! ;

::esfoco? | -- 0/1
	idf 1+ foconow - not ;

::in/foco | 'in --
	idf 1+
	foco 0? ( drop dup dup 'foco ! )
	<>? ( 'idf ! drop ; )
	'idf !
	ex ;

 | no puedo retroceder! (idea: separa id for text input)
::lostfoco | 'acc --
	idf 1+ foco <>? ( 'idf ! drop ; ) 'idf !
	ex
	nextfoco
	;
