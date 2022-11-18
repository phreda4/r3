| exact animation
| PHREDA 2022
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/tilesheet.r3

:anima | jug --
	dup cell+ @
	msec >? ( 2drop ; ) drop
:nextframe | jug --
	dup 2 ncell+ 			| jug 'acc
	@ @+ 					| jug 'acc+ time
	0? ( drop 
		@ over 2 ncell+ ! 
		nextframe ; )		| 0  new anim
	-? ( drop 
		@+ ex over 2 ncell+ ! 
		nextframe ; ) 			| - exec
	1000 16 *>> msec +			| j 'a+ next
	pick2 cell+ !				| save next time
	@+ pick2 !
	swap 2 ncell+ ! ;
	
:anim! | anim jug --
	2 ncell+ ! ;
	
|-------------------------
| time(seg) nro ..
| 0 'nextanim
| -1 'action	
#camiizq
	0.1 6 0.1 7 0.1 8 0.1 9 0.1 10 0.1 11
	0 'camiizq
	
#quieizq
	0.1 13 
	0 'quieizq

#camider
	0.1 0 0.1 1 0.1 2 0.1 3 0.1 4 0.1 5
	0 'camider
	
#quieder	
	0.1 12
	0 'quieder

| nro-actual ntime 'animaarra

#spr1 0 0 'quieder 
#spr2 0 0 'quieizq 

#tsguy	| dibujo

#xp 100.0 #yp 400.0		| posicion
#xv #yv		| velocidad

:teclado
	SDLkey
	>esc< =? ( exit )

	<a> =? ( xv -1.0 <>? ( -1.0 'xv ! 'camiizq 'spr1 anim! ) drop )
	>a< =? ( 0 'xv ! 'quieizq 'spr1 anim! )
	
	<d> =? ( xv 1.0 <>? ( 1.0 'xv ! 'camider 'spr1 anim! ) drop )
	>d< =? ( 0 'xv ! 'quieder 'spr1 anim! )	
	
	drop ;

:demo
	0 SDLcls
	
	spr1 tsguy 
	xp int. yp int. 
	tsdraw 
	
	|100 SDL_Delay
	
	'spr1 anima
	
	|'spr1 @+ "%d " .print @+ "%d " .print @ "%h " .println
	
	SDLredraw
	
	xv 'xp +!
	yv 'yp +!
	
	teclado
	;
	
:main
	"r3sdl" 800 600 SDLinit
	104 150 "media/img/guybrush.png" loadts 'tsguy !
	'demo SDLshow
	SDLquit 
	;	
	
: main ;	