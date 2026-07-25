^r3/lib/sdl2gfx.r3
^r3/lib/math.r3

#t #y #k #e #d #q #c #xp #yp
#SCALEX #SCALEY
#colormode

#colortime |#phase1 #phase2 #phase3 |#hue #sat #val #bright

:rsin | rad -- s   
	0.1591549 *. sin ;

:point | xin --	e	
	d 39.0 *. |q c rsin *. + 440.0 - 
	'yp !
	;
: 
	1 point drop
;