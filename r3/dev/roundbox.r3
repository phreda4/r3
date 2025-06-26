^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

#yc #xc #d 

:rect 
	xc over - yc pick3 + xc pick3 + sdlLineH
	xc over - yc pick3 - xc pick3 + sdlLineH
	xc pick2 + yc pick2 - yc pick3 + sdlLineV
	xc pick2 - yc pick2 - yc pick3 + sdlLineV
	;
	
:stepd	| y x -- y x
	d -? ( over 2 << 6 + + 'd ! ; )
	over pick3 - 2 << 10 + + 'd ! 
	swap 1- swap rect ;
	
:circle | r x y --
	'yc ! 'xc !
	3 over 2* - 'd !
	0 ( over <=? stepd 1+ ) 2drop ;

|-------------------------------------------	
#wb #hb
:rect 
	xc over - yc pick3 - xc wb + pick3 + sdlLineH
	xc over - yc hb + pick3 + xc wb + pick3 + sdlLineH
	xc pick2 - yc pick2 - yc hb + pick3 + sdlLineV
	xc wb + pick2 + yc pick2 - yc hb + pick3 + sdlLineV	 ;

:stepd
	d -? ( over 2 << 6 + + 'd ! ; )
	over pick3 - 2 << 10 + + 'd ! 
	swap 1- swap rect ;

:frrect | r x y w h --
	'hb ! 'wb !
	pick2 + 'yc ! over + 'xc !
	3 over 2* - 'd ! 
	dup 2* neg dup 'hb +! 'wb +!
	0 ( over <=? stepd 1+ ) drop 
	xc over - yc pick2 -
	rot 2*
	wb over + hb rot +
	SDLfRect ;
	
:main
	0 sdlcls
	
	$ffffff sdlcolor
	20 112 300 circle
	30 312 300 circle
	
	$ff sdlcolor
	msec 5 >> $3f and 400 200 200 200 frrect
	
|	$ffffff sdlcolor
|	400 200 200 200 sdlrect
	
	$ff7f sdlcolor
	20 700 200 100 200 frrect
	
	$ff00 sdlcolor
	20 300 410 200 100 sdlfround
	$ffffff sdlcolor
	10 320 470 160 30 sdlfround
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:
"roundbox" 1024 600 sdlinit
'main sdlshow
;