| trebor en busca del oro

^r3/win/sdl2gl.r3
^r3/win/sdl2gfx.r3
^r3/util/arr16.r3

#sprj
#spre

#fx 0 0

#xvp #yvp	| viewport

#xp 30.0 #yp 30.0	| pos player
#vxp 0 #vyp 0		| vel player

#np 0

:viewport
	xp int. sw 1 >> - 'xvp !
	yp int. sh 1 >> - 'yvp !
	;
		
|--------------------------------
#btnpad

:panim | -- nanim	
	msec 5 >> $3 and ;

:dirv	
	-? ( 1 2 << ; ) 2 2 << ;
:xmove
	
	dirv panim + 'np !
	'xp +!
	;
	
:dirh
	-? ( 3 2 << ; ) 0 ;
:ymove
	dirh panim + 'np !
	'yp +!
	;
	
:player	
	xp int. xvp -
	yp int. yvp -
	0 2.0 
	np sprj 
	sspritez

	btnpad
	%1000 and? ( -1.0 ymove  )
	%100 and? ( 1.0 ymove  )
	%10 and? ( -1.0 xmove )
	%1 and? ( 1.0 xmove )
	drop
	
	;
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 not and 'btnpad ! )
	>dn< =? ( btnpad %100 not and 'btnpad ! )
	>le< =? ( btnpad %10 not and 'btnpad ! )
	>ri< =? ( btnpad %1 not and 'btnpad ! )	
	drop 
	;


:jugando
	$666666 SDLcls
	|viewport
	player
	
	SDLredraw
	
	teclado ;

:main
	"r3sdl" 800 600 SDLinit

	17 26 "media\img\scientist.png" loadssheet 'sprj !
	
	viewport
	'jugando SDLshow
	SDLquit ;	
	
: main ;