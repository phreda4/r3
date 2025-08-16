|------------------------------
| gui.r3 - PHREDA
| Immediate mode gui for r3
|------------------------------
^r3/lib/sdl2.r3

|--- region
##xr1 ##yr1
##xr2 ##yr2

|--- state
#hot	| activo actual
#hotnow	| activo anterior
#hotc	| foco

##foco	| activo teclado
#foconow | activo teclado

##clkbtn

|--- id
#id		| id gui actual
##idf	| id gui foco actual (teclado)
##idl	| id foco ultim

##guin? | mouse in rect? and last in touch

::gui
	idf 'idl ! hot 'hotnow ! 
	0 'id ! 0 'idf ! 0 'hot !
	;

:guiIn	| --
	1 'id +!
	sdly yr1 <? ( drop 0 'guin? ! ; ) yr2 >? ( drop 0 'guin? ! ; ) drop
	sdlx xr1 <? ( drop 0 'guin? ! ; ) xr2 >? ( drop 0 'guin? ! ; ) drop

	id 
	hotnow <>? ( 'hot ! 0 'guin? ! ; )
	'hot ! 
	-1 'guin? ! ;
	
::guiBox | x1 y1 w h --
 	pick2 + 'yr2 ! pick2 + 'xr2 ! 'yr1 ! 'xr1 ! 
	guiIn ;

::guiPrev | -- ; same id 
	-1 'id +! ;
	
::guiRect | x1 y1 x2 y2 --
	'yr2 ! 'xr2 ! 'yr1 ! 'xr1 ! 
	guiIn ;

|---- click up
::onClick | 'click --
	guin? 0? ( 2drop ; ) drop
	sdlb 1? ( nip 'clkbtn ! id 'hotc ! ; ) drop
	id hotc <>? ( 2drop ; ) drop
	ex 0 'hotc ! ;

::onClickFoco
	guin? 0? ( 2drop ; ) drop
	sdlb 1? ( nip 'clkbtn ! id 'hotc ! ; ) drop
	id hotc <>? ( 2drop ; ) drop
	ex 0 'hotc ! 
	idf foco =? ( drop ; ) 'foco ! ;
	
|---- move
::onMoveA | 'move --
	id hotc =? ( sdlb 1? ( 2drop ex ; ) drop ) drop | no si captura otro
	guin? 0? ( 2drop ; ) drop
	SDLb 0? ( 2drop ; ) drop
	ex 
	id 'hotc ! ;

::onMove | 'move --
	guin? 0? ( 2drop ; ) drop
	SDLb 0? ( 2drop ; ) drop
	ex ;

|---- dn->move
::onDnMove | 'dn 'move --	
	guin? 0? ( 3drop ; ) drop
	SDLb 0? ( 3drop -1 'hotc ! ; ) drop
	id 
	hotc =? ( drop nip ex ; )
	'hotc ! 
	drop ex 
	;	

::onDnMoveA | 'dn 'move -- | si apreto adentro.. mueve siempre
	id hotc =? ( sdlb 1? ( 2drop nip ex ; ) drop ) drop | no si captura otro
	guin? 0? ( 3drop ; ) drop
	SDLb 0? ( 3drop -1 'hotc ! ; ) drop
	id 
	hotc =? ( drop nip ex ; )
	'hotc ! 
	drop ex
	;

|---- map dn->move->up
::onMap | 'dn 'move 'up --
	SDLb 0? ( id hotc =? ( 2drop nip nip ex -1 'hotc ! ; ) nip 4drop ; ) 2drop
	guin? 0? ( 3drop ; ) drop
	id 
	hotc =? ( drop nip ex ; )
	'hotc ! 
	drop ex ;

::onMapA | 'dn 'move 'up -- | si apreto adentro.. mueve siempre, con up
	SDLb 0? ( id hotc =? ( 2drop nip nip ex -1 'hotc ! ; ) nip 4drop ; ) 2drop
	guin? 0? ( 3drop ; ) drop
	id 
	hotc =? ( drop nip ex ; )
	'hotc ! 
	drop ex ;

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
	foco 1+ idl >? ( 0 nip ) 'foco ! 0 'sdlkey ! -1 'foconow ! ;

::prevfoco
	foco 1- 0 <=? ( idl nip ) 'foco ! 0 'sdlkey ! -1 'foconow ! ;

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
	foco 0? ( drop dup dup 'foco ! ) | quitar? dup 'foconow !
	<>? ( 'idf ! 2drop ; )
	foconow <>? ( dup 'foconow ! 'idf ! nip ex ; )
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
	|foconow <>? ( dup 'foconow ! )
	<>? ( 'idf ! drop ; )
	'idf ! ex ;

 | no puedo retroceder! (idea: separa id for text input)
::lostfoco | 'acc --
	idf 1+ foco <>? ( 'idf ! drop ; ) 'idf !
	ex
	nextfoco
	;
