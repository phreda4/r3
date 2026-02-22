
^r3/lib/sdl2gfx.r3

#anima
#at #dt

:main
	5 4 5.0 aniInit | 6 frames start in 5 at 1.5fps
	'anima !
	msec 'at !
	( inkey [esc] <>? drop
		msec dup at - 'dt ! 'at !
		dt 'anima ani+!
		
		anima dup "%h " .print
		aniFrame "%d " .println
		
		100 ms
		) drop
	;
	
: main ;