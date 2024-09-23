| Clock
| PHREDA 2022

^r3/lib/sdl2gfx.r3
^r3/lib/sdl2poly.r3

#xc 400 #yc 300
#csize 200

|--------- reloj
:aguja | ang largo --
	polar
	xc pick2 3 >> - yc pick2 3 >> + gop
	xc rot + yc rot - gline ;

:drawclock | --
	$ffffff SDLColor
	3 linegr!
	0 ( 1.0 <? 
		dup csize polar
		swap xc + swap yc + gop
		dup csize dup 4 >> - polar
		swap xc + swap yc + gline
		0.0834 + ) drop
	time | s m h --
	$ff0000 SDLColor
	8 linegr!
	dup 16 >> $ff and 60 *	| hora
	over 8 >> $ff and	| minuto
	+
	1.0 720 */ csize 4 - 1 >> aguja
	$ff00 SDLColor
	4 linegr!
	dup 8 >> $ff and 1.0 60 */ csize 4 -  aguja
	$ffffff SDLColor
	1 linegr!
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
