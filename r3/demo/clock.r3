| Clock
| PHREDA 2022

^r3/win/sdl2gfx.r3

#xc 400 #yc 300
#csize 200

#x #y
:op! 'y ! 'x ! ;

:line! x y SDLLine ;	

|--------- reloj
:aguja | ang largo --
	polar
	xc pick2 3 >> - yc pick2 3 >> + op!
	xc rot + yc rot - line! ;

:drawclock | --
	$ffffff SDLColor
	0 ( 1.0 <? 
		dup csize polar
		swap xc + swap yc + op!
		dup csize dup 4 >> - polar
		swap xc + swap yc + line!
		0.0834 + ) drop
	time | s m h --
	$ff0000 SDLColor
	dup 16 >> $ff and 1.0 12 */ csize 4 - 2/ aguja
	$ff00 SDLColor
	dup 8 >> $ff and 1.0 60 */ csize 4 - dup 2 >> - aguja
	$ffffff SDLColor
	$ff and 1.0 60 */ csize 4 - aguja ;
	
:clock	
	0 SDLcls
	drawclock
	SDLredraw
	
	SDLKey
	>esc< =? ( exit )
	drop
	;
	
:	|====================== INICIO 
	"r3sdl" 800 600 SDLinit

	'clock SDLShow
	
	SDLquit 
	;