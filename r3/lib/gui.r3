|------------------------------
| gui.r3 - PHREDA
| Immediate mode gui for r3
|------------------------------
^r3/lib/sys.r3
^r3/lib/print.r3
^r3/lib/sprite.r3
^r3/lib/cursor.r3
^r3/util/polygr.r3

|--- state
##hot	| activo actual
#hotnow	| activo anterior
#foco	| activo teclado
#foconow	| activo teclado

|--- id
#id		| id gui actual
#idf	| id gui foco actual (teclado)
#idl	| id foco ultimo

|--- region
##xr1 ##yr1
##xr2 ##yr2

::whin | x y -- -1/0
	yr2 over - swap yr1 - or swap
	xr2 over - swap xr1 - or or
	63 >> not ;

::guiAll
	0 'xr1 ! 0 'yr1 ! sw 'xr2 ! sh 'yr2 ! ;

::guiBox | x1 y1 w h --
	pick2 + 'yr2 ! pick2 + 'xr2 ! 'yr1 ! 'xr1 ! ;

::guiRect | x1 y1 x2 y2 --
	'yr2 ! 'xr2 ! 'yr1 ! 'xr1 ! ;

::guiFill
	xr1 yr1 xr2 yr2 fillbox ;

::guiBorde
	xr1 1 - yr1 1 - xr2 yr2 rectbox ;

::guizone
	xr1 yr1 xr2 yr2 rectbox ;

|---------
::gui
	idf 'idl ! hot 'hotnow !
	0 'id ! 0 'idf ! 0 'hot !
	guiAll
	;

::guidump
	"idl:" print idl .d print cr
	"hotnow:" print hotnow .d print cr
	"foco:" print foco .d print cr
	"foconow:" print foconow .d print cr
	;

|-- boton
::onClick | 'click --
	1 'id +!
	xypen whin 0? ( 2drop ; ) drop
	bpen 0? ( id hotnow =? ( 2drop ex ; ) 3drop ; ) 2drop
	id 'hot ! ;

|-- move
::onMove | 'move --
	1 'id +!
	bpen 0? ( 2drop ; ) drop
	xypen whin 0? ( 2drop ; ) drop
	id 'hot !
	ex ;

|-- dnmove
::onDnMove | 'dn 'move --
	1 'id +!
	bpen 0? ( 3drop ; ) drop
	xypen whin 0? ( 3drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 2drop ex ; )
	drop nip ex ;

::onDnMoveA | 'dn 'move -- | si apreto adentro.. mueve siempre
	1 'id +!
	bpen 0? ( 3drop ; ) drop
	hotnow 1? ( id <>? ( 3drop ; ) ) drop | solo 1
	xypen whin 0? ( id hotnow =? ( 'hot ! drop nip ex ; ) 4drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 2drop ex ; )
	drop nip ex ;


|-- mapa
::guiMap | 'dn 'move 'up --
	1 'id +!
	xypen whin 0? ( 4drop ; ) drop
	bpen 0? ( id hotnow =? ( 2drop nip nip ex ; ) 4drop drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 3drop ex ; )
	2drop nip ex ;

::guiDraw | 'move 'up --
	1 'id +!
	xypen whin 0? ( 3drop ; ) drop
	bpen 0? ( id hotnow =? ( 2drop nip ex ; ) 4drop ; ) drop
	id dup 'hot !
	hotnow <>? ( 3drop ; )
	2drop ex ;

::guiEmpty | --		; si toca esta zona no hay interaccion
	1 'id +!
	xypen whin 1? ( id 'hot ! )
	drop ;

|----- test adentro/afuera
::guiI | 'vector --
	xypen whin 0? ( 2drop ; ) drop ex ;

::guiO | 'vector --
	xypen whin 1? ( 2drop ; ) drop ex ;

::guiIO | 'vi 'vo --
	xypen whin 1? ( 2drop ex ; ) drop nip ex ;


::waitms | ms --
	redraw
	msec +
	( msec >? update )
	drop ;

##col-prim $337ab7
##col-succ $5cb85c
##col-info $5bc0de
##col-warn $f0ad4e
##col-dang $d9534f

|---------------------------------------------------
| manejo de foco (teclado)

::nextfoco
	foco 1 + idl >? ( 0 nip ) 'foco ! ;

::prevfoco
	foco 1 - 0 <=? ( idl nip ) 'foco ! ;

::setfoco | nro --
	'foco ! -1 'foconow ! ;

::ktab
	mshift 1? ( drop prevfoco ; ) drop
	nextfoco ;

::clickfoco
	idf foco =? ( drop ; ) 'foco ! ;

::clickfoco1
	idf 1 + 'foco ! -1 'foconow ! ;

::refreshfoco
	-1 'foconow ! 0 'foco ! ;

::w/foco | 'in 'start --
	idf 1 +
	foco 0? ( drop dup dup 'foco ! ) | quitar?
	<>? ( 'idf ! 2drop ; )
	foconow <>? ( dup 'foconow ! swap ex 'idf ! drop ; )
	nip 'idf ! ex ;

::focovoid | --
	idf 1 +
	foco 0? ( drop dup dup 'foco ! ) | quitar?
	<>? ( 'idf ! ; )
	foconow <>? ( dup 'foconow ! )
	'idf ! ;

::esfoco? | -- 0/1
	idf 1 + foconow - not ;

::in/foco | 'in --
	idf 1 +
	foco 0? ( drop dup dup 'foco ! )
	<>? ( 'idf ! drop ; )
	'idf !
	ex ;

 | no puedo retroceder!
::lostfoco | 'acc --
	idf 1 + foco <>? ( 'idf ! drop ; ) 'idf !
	ex
	nextfoco
	;
