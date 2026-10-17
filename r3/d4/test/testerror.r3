^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/arr8.r3

#imgspr

#listene 0 0

:.x 0 + ;
:.y 4 + ;
:.r 8 + ;
:.vx 12 + ;
:.vy 16 + ;
:.vr 20 + ;
:.s 24 + ;
:.a 28 + ;

:+enemy
	'listene p8! >a
	0.0 800.0 randminmax da!+ |x
	0.0 600.0 randminmax da!+ |y
	0 da!+ |r
	0 da!+ 
	0 da!+ 
	-0.001 0.001 randminmax da!+
	0 da!+ 0 a! ;

:venemy
	dup >a
	a> .x d@ int. a> .y d@ int.
	a> .r d@ 
	|2.0 <-- need this number but debug crash..not stop
	
	2 imgspr sspriterz 

	a> .vx d@ a> .x d+!
	a> .vy d@ a> .y d+!
	a> .vr d@ a> .r d+!
	;

:game 
	$0 cls
	'venemy 'listene p8.mapv
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( +enemy )
	drop
	;

:
	"marcianos" 800 600 sdlinit
	16 16  "media/img/manual.png" ssload 'imgspr !
	64 'listene p8.ini
	'game sdlshow
;
