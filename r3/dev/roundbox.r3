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
	xc over - 		yc pick3 - 		xc wb + pick3 + sdlLineH
	xc over - 		yc hb + pick3 + xc wb + pick3 + sdlLineH
	xc pick2 - 		yc pick2 - 		yc hb + pick3 + sdlLineV
	xc wb + pick2 + yc pick2 - 		yc hb + pick3 + sdlLineV	 ;

:stepd
	d -? ( over 2 << 6 + + 'd ! ; )
	over pick3 - 2 << 10 + + 'd ! 
	rect swap 1- swap ;

:frrect | r x y w h --
	1- pick4 2* - 'hb ! 
	1- pick3 2* - 'wb !
	pick2 + 'yc ! over + 'xc !
	3 over 2* - 'd ! 
	0 ( over <=? stepd 1+ ) drop
	xc over - yc pick2 -
	rot 2* 1+ wb over + hb rot +
	SDLfRect ;
	
:rect
	xc wb + over +	yc hb + pick3 + SDLPoint
	xc wb + over +	yc pick3 - SDLPoint
	xc over - 		yc hb + pick3 + SDLPoint
	xc over - 		yc pick3 - SDLPoint
	xc wb + pick2 + yc hb + pick2 + SDLPoint
	xc wb + pick2 + yc pick2 - SDLPoint	
	xc pick2 - 		yc hb + pick2 + SDLPoint
	xc pick2 - 		yc pick2 - SDLPoint ;
	
:stepd
	d -? ( over 2 << 6 + + 'd ! ; )
	over pick3 - 2 << 10 + + 'd ! 
	swap 1- swap ;

:rrect | r x y w h --
	1- pick4 2* - 'hb ! 
	1- pick3 2* - 'wb !
	pick2 pick2 + over wb pick2 + SDLLineH
	pick2 pick2 + over hb + pick4 2* + wb pick2 + SDLLineH
	over over pick4 + hb over + SDLLineV
	over wb + pick3 2* + over pick4 + hb over + SDLLineV
	pick2 + 'yc ! over + 'xc !
	3 over 2* - 'd ! 
	0 ( rect over <=? stepd 1+ ) 2drop ;

|-------------- V2, less vertex, more redraw
:rect 
	xc over - 		
	yc pick3 - 		
	xc wb + pick3 + pick2 - | xc wb + x + xc x + -	
	pick4 yc + hb + pick2 -
	SDLRect
	xc pick2 - 		
	yc pick2 - 		
	xc wb + pick4 + pick2 -
	yc hb + pick4 + pick2 -
	SDLRect ;

:rectf 
	xc over - 		
	yc pick3 - 		
	xc wb + pick3 + pick2 -
	pick4 yc + hb + pick2 -
	SDLfRect
	xc pick2 - 		
	yc pick2 - 		
	xc wb + pick4 + pick2 -
	yc hb + pick4 + pick2 -
	SDLfRect ;

:frrect2 | r x y w h --
	'hb ! 'wb !
	pick2 + 'yc ! over + 'xc !
	3 over 2* - 'd ! 
	dup 2* neg dup 'hb +! 'wb +!
	0 ( over <=? stepd 1+ ) 
	rectf 2drop ;
|-----------------------------
	
|-----------------------------
:main
	0 sdlcls
	
	$ffffff sdlcolor
	20 112 300 circle
	30 312 300 circle

	$ffffff sdlcolor
	400 200 256 dup sdlrect
	399 199 258 dup sdlrect
	
	$ff sdlcolor
	msec 6 >> $7f and 
	dup 400 200 256 dup frrect	
	$ff00 sdlcolor
	400 200 256 dup rrect
	
	$7f7f sdlcolor
	20 700 200 100 200 frrect
	$ffffff sdlcolor
	20 700 200 100 200 rrect 
	
	$ff00 sdlcolor
	20 300 410 200 100 sdlfround
	$ffffff sdlcolor
	10 320 470 160 30 sdlfround
	0 sdlcolor
	10 320 470 160 30 sdlround
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:
"roundbox" 1024 600 sdlinit
'main sdlshow
;