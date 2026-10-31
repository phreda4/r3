|------------------------------
| gui.r3 - PHREDA
| Immediate mode gui for r3
|------------------------------
^r3/lib/sdl2.r3

|--- region
##xr1 | left of the region of the current widget
##yr1 | top of the region of the current widget
##xr2 | right of the region of the current widget
##yr2 | bottom of the region of the current widget

|--- state
#hot	| activo actual
#hotnow	| activo anterior
#hotc	| foco

##foco | number of the focusable widget that has the keyboard focus (1 = the first, 0 = none)
#foconow | activo teclado

##clkbtn | mouse button of the last press over a widget (see onClick)

|--- id
#id		| id gui actual
##idf | id of the last focusable widget registered in this frame (focus counter)
##idl | number of focusable widgets of the previous frame

##guin? | -1 if the mouse is inside the region of the current widget and it is the topmost one, else 0

::gui | -- ; start of a gui frame: call it once per frame before the widgets (resets the widget ids)
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
	
::guiBox | x1 y1 w h -- ; start a widget with the rectangle x1 y1 w h: takes the next id and tests the mouse (sets guin?)
 	pick2 + 'yr2 ! pick2 + 'xr2 ! 'yr1 ! 'xr1 ! 
	guiIn ;

::guiPrev | -- ; the next guiBox or guiRect reuses the id of the last widget (several regions with the same id)
	-1 'id +! ;
	
::guiRect | x1 y1 x2 y2 -- ; like guiBox but with the two corners of the rectangle
	'yr2 ! 'xr2 ! 'yr1 ! 'xr1 ! 
	guiIn ;

|---- click up
::onClick | 'click -- ; execute 'click when the mouse button is released over the widget that was pressed (clkbtn = the button)
	guin? 0? ( 2drop ; ) drop
	sdlb 1? ( nip 'clkbtn ! id 'hotc ! ; ) drop
	id hotc <>? ( 2drop ; ) drop
	ex 0 'hotc ! ;

::onClickFoco | 'click -- ; like onClick and also gives the keyboard focus to the widget
	guin? 0? ( 2drop ; ) drop
	sdlb 1? ( nip 'clkbtn ! id 'hotc ! ; ) drop
	id hotc <>? ( 2drop ; ) drop
	ex 0 'hotc ! 
	idf foco =? ( drop ; ) 'foco ! ;
	
|---- move
::onMoveA | 'move -- ; execute 'move while the button is held after pressing over the widget, even if the mouse leaves it
	id hotc =? ( sdlb 1? ( 2drop ex ; ) drop ) drop | no si captura otro
	guin? 0? ( 2drop ; ) drop
	SDLb 0? ( 2drop ; ) drop
	ex 
	id 'hotc ! ;

::onMove | 'move -- ; execute 'move while the button is pressed and the mouse is over the widget
	guin? 0? ( 2drop ; ) drop
	SDLb 0? ( 2drop ; ) drop
	ex ;

|---- dn->move
::onDnMove | 'dn 'move -- ; execute 'dn when the button is pressed over the widget and 'move while it is held there
	guin? 0? ( 3drop ; ) drop
	SDLb 0? ( 3drop -1 'hotc ! ; ) drop
	id 
	hotc =? ( drop nip ex ; )
	'hotc ! 
	drop ex 
	;	

::onDnMoveA | 'dn 'move -- ; like onDnMove but it keeps calling 'move after the mouse leaves the widget
	id hotc =? ( sdlb 1? ( 2drop nip ex ; ) drop ) drop | no si captura otro
	guin? 0? ( 3drop ; ) drop
	SDLb 0? ( 3drop -1 'hotc ! ; ) drop
	id 
	hotc =? ( drop nip ex ; )
	'hotc ! 
	drop ex
	;

|---- map dn->move->up
::onMap | 'dn 'move 'up -- ; 'dn when pressed over the widget, 'move while held, 'up when released
	SDLb 0? ( id hotc =? ( 2drop nip nip ex -1 'hotc ! ; ) nip 4drop ; ) 2drop
	guin? 0? ( 3drop ; ) drop
	id 
	hotc =? ( drop nip ex ; )
	'hotc ! 
	drop ex ;

::onMapA | 'dn 'move 'up -- ; like onMap but it keeps tracking after the mouse leaves the widget
	SDLb 0? ( id hotc =? ( 2drop nip nip ex -1 'hotc ! ; ) nip 4drop ; ) 2drop
	guin? 0? ( 3drop ; ) drop
	id 
	hotc =? ( drop nip ex ; )
	'hotc ! 
	drop ex ;

|----- test adentro/afuera
::guiI | 'vector -- ; execute 'vector if the mouse is inside the widget
	guin? 0? ( 2drop ; ) drop ex ;

::guiO | 'vector -- ; execute 'vector if the mouse is outside the widget
	guin? 1? ( 2drop ; ) drop ex ;

::guiIO | 'vi 'vo -- ; execute 'vi if the mouse is inside the widget, else 'vo
	guin? 1? ( 2drop ex ; ) drop nip ex ;

|---------------------------------------------------
| manejo de foco (teclado)

::nextfoco | -- ; move the keyboard focus to the next focusable widget (wraps to the first) and clear sdlkey
	foco 1+ idl >? ( 0 nip ) 'foco ! 0 'sdlkey ! -1 'foconow ! ;

::prevfoco | -- ; move the keyboard focus to the previous focusable widget (wraps to the last) and clear sdlkey
	foco 1- 0 <=? ( idl nip ) 'foco ! 0 'sdlkey ! -1 'foconow ! ;

::setfoco | nro -- ; give the keyboard focus to the focusable widget number nro (1 = the first)
	'foco ! -1 'foconow ! ;

|::ktab
|	mshift 1? ( drop prevfoco ; ) drop
|	nextfoco ;

::clickfoco | -- ; give the keyboard focus to the last registered focusable widget (call it after its w/foco, for example when it is clicked)
	idf foco =? ( drop ; ) 'foco ! ;

::clickfoco1 | -- ; give the keyboard focus to the next focusable widget to be registered
	idf 1+ 'foco ! -1 'foconow ! ;

::refreshfoco | -- ; clear the keyboard focus: the first focusable widget takes it in the next frame
	-1 'foconow ! 0 'foco ! ;

::w/foco | 'in 'start -- ; focusable widget: with the keyboard focus it executes 'start the first frame and 'in in the next ones; without focus it only registers itself
	idf 1+
	foco 0? ( drop dup dup 'foco ! ) | quitar? dup 'foconow !
	<>? ( 'idf ! 2drop ; )
	foconow <>? ( dup 'foconow ! 'idf ! nip ex ; )
	nip 'idf ! ex ;

::focovoid | -- ; register a focusable widget without code (it takes a place in the focus order)
	idf 1+
	foco 0? ( drop dup dup 'foco ! ) | quitar?
	<>? ( 'idf ! ; )
	foconow <>? ( dup 'foconow ! )
	'idf ! ;

::esfoco? | -- n ; -1 if the next focusable widget to be registered has the keyboard focus, another nonzero value if not (compare with -1)
	idf 1+ foconow - not ;

::in/foco | 'in -- ; focusable widget that executes 'in while it has the keyboard focus
	idf 1+
	foco 0? ( drop dup dup 'foco ! )
	|foconow <>? ( dup 'foconow ! )
	<>? ( 'idf ! drop ; )
	'idf ! ex ;

 | no puedo retroceder! (idea: separa id for text input)
::lostfoco | 'acc -- ; focusable widget: when it has the focus it executes 'acc and moves the focus to the next widget
	idf 1+ foco <>? ( 'idf ! drop ; ) 'idf !
	ex
	nextfoco
	;
