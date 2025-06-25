^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

#yc #xc
#d #y #x

:points
	xc over + yc y + SDLPoint
	xc over - yc y + SDLPoint
	xc over + yc y - SDLPoint
	xc over - yc y - SDLPoint
	xc y + yc pick2 + SDLPoint
	xc y - yc pick2 + SDLPoint
	xc y + yc pick2 - SDLPoint
	xc y - yc pick2 - SDLPoint
	;
	
:stepd	
	d 0 >? ( -1 'y +! over y - 2 << 10 + + dup 'd ! )
	over 2 << 6 + + 'd ! ;
	
:circle | r x y --
	'yc ! 'xc !
	3 over 2* - 'd !
	'y !
	0 points
	( y <=?
		stepd 1+ points
		) drop ;
	
#ym #xm
#dx #dy

:inicircle | rx ry x y --
	'ym ! 'xm !				| rx ry
	over dup * dup 1 <<		| rx ry rxrx 2rxry
	swap dup >a 'dy ! 		| rx ry 2rxry  ; a:dy:rxrx
	-rot over neg 1 << 1+	| 2rxrx rx ry -2rx+1
	swap dup * dup 1 << 	| 2rxrx rx -2rx+1 ryry 2ryry
	-rot * dup a+ 'dx !		| 2rxrx rx 2ryry ; -2rx+1*ryry ; a+ dx
	1+ swap 1				| 2rxrx 2ryry+1 rx 1
	pick3 'dy +! dy a+
	;

:qf
	xm pick2 - ym pick2 - xm pick4 + SDLLineH 
	xm pick2 - ym pick2 + xm pick4 + SDLLineH  ;

::circle2 | rx ry x y --
	inicircle
	xm pick2 - ym xm pick4 + over SDLLine 
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1- -rot pick3 'dx +! dx a+ )
		dy <=? ( -rot qf 1+ rot pick4 'dy +! dy a+ )
		drop
		)
	4drop ;	
	
:main
	0 sdlcls
	
	$ffffff sdlcolor
	80 112 300 circle
	60 312 300 circle
	
	80 80 512 300 circle2
	80 60 812 300 circle2
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:
"roundbox" 1024 600 sdlinit
'main sdlshow
;