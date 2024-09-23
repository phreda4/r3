| Arco
| GALILEOG 2016
| PHREDA 2016
|---------------
^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

#mx
#my

:calc | a b d -- c
	>r + 2/ 1.0 randmax 0.5 - r> *. + ;

:light | x1 y1 x2 y2 d --
	5 <? ( drop SDLLine ; )
	>r
	2swap
	pick3 pick2 r@ calc dup 'mx !
	pick3 pick2 r@ calc dup 'my !	| x2 y2 x1 y1 mx my
	r@ 2/ light
	mx my r> 2/ light ;


:light2 | x1 y1 x2 y2 d --
	5 <? ( drop SDLLine ; ) 
	>r
	2swap
	pick3 pick2 r@ calc
	pick3 pick2 r@ calc
	2swap 2over
	r@ 2/ light2
	r> 2/ light2 ;

:main
	0 SDLcls
	$ffffff SDLColor
	SDLx SDLy 0 0 pick3 pick2 - abs 2/
	light

	$ffff00 SDLColor
	SDLx SDLy 0 0 pick3 pick2 - abs 2/
	light2
		
	SDLredraw 
	sdlkey 
	>esc< =? ( exit )
	drop ;

	
:	|====================== INICIO 
	"r3sdl" 800 600 SDLinit
	'main SDLShow 
	;
