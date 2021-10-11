| tilesheet sprite
| PHREDA 2021
|------------------

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/util/tilesheet.r3

#ts_alien
#ts_ship
#ts_explo

|----------------------------------------
:demo
	0 SDLclear
	
	msec 5 >> $3 and ts_alien 10 10 tsdraw 
	msec 6 >> $3 and ts_ship 200 10 tsdraw 
	msec 6 >> $f and ts_explo 300 100 tsdraw 	
	
	SDLRedraw
	
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"r3sdl" 800 600 SDLinit

	40 30 "media/img/alien_40x30.png" loadts 'ts_alien !
	64 29 "media/img/ship_64x29.png" loadts 'ts_ship !
	64 64 "media/img/explo_64x64.png" loadts 'ts_explo !	
	
	'demo SDLshow
	
	SDLquit
	;
	
: main ;