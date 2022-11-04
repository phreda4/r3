| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#sprj
#spre

#fx 0 0

#xvp #yvp	| viewport

#xp 30.0 #yp 30.0	| pos player
#vxp 0 #vyp 0		| vel player

#np 0

#mapajuego

|--------------------------------
	
:humo
	>a
	a@
	100 >? ( drop 0 ; ) 
	1 + a!+
	25 spre
	a@+ int. a@+ int. tsdraw
	;
	
:+humo | x y --
	'humo 'fx p!+ >a 
	0 a!+
	swap a!+ a!+
	;
	
#ev 0	
:estela	
	1 'ev +!
	ev 20 <? ( drop ; ) drop
	0 'ev !
	xp yp +humo
	;

:viewport
	xp int. sw 1 >> - 'xvp !
	yp int. sh 1 >> - 'yvp !
	;
		
|--------------------------------
:[map]@ | x y -- adr
	swap xvp - 
	swap yvp - 
	scr2tile c@ ;
	
:[map]@s | x y -- c
	[map]@
	11 =? ( ; ) 
	12 =? ( ; ) 
	drop 0 ;	
	
:wall? | -- piso?
	xp int. 10 + yp int. 32 + [map]@s
	xp int. 20 + yp int. 32 + [map]@s or	
	;

:debug
	$ffffff bcolor 
	10 10 bat 
	;

#btnpad

:animh | v --
	63 >> 2 and | 0/2
	2 << | 4 *
	msec 6 >> $3 and + 'np ! ;
	
:animv | v --
	neg 63 >> 2 and 1 + | 1/3
	2 << | 4 *
	msec 6 >> $3 and + 'np ! ;
	
:xmove
	dup 'xp +!
	wall? 0? ( drop animh ; )
	drop neg 'xp +! ; 
	
:ymove
	dup 'yp +!
	wall? 0? ( drop animv ; )
	drop neg 'yp +! ; 
	
:player	
	np sprj 
	xp int. xvp -
	yp int. yvp -
	32 32 tsdraws

	btnpad
	%1000 and? ( -1.0 ymove  )
	%100 and? ( 1.0 ymove  )
	%10 and? ( -1.0 xmove )
	%1 and? ( 1.0 xmove )
	drop

	viewport
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

|---- sin reemplazo	
:drawmapa
	26 20
	xvp 5 >> yvp 5 >>
	xvp $1f and neg 
	yvp $1f and neg
	32 32
	mapajuego tiledraws ;
	
	
|---- con reemplazo	
:vectortile | tile -- tile
	;
	
:drawmapar
	26 20
	xvp 5 >> yvp 5 >>
	xvp $1f and neg 
	yvp $1f and neg
	32 32
	mapajuego 'vectortile 
	tiledrawvs ;
	
	
:jugando
	$666666 SDLcls

	viewport
	drawmapa	
	'fx p.draw
	player
	
	SDLredraw
	
	teclado ;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	
	8 8 "r3\j2022\troll\troll-p.png" loadts 'sprj !
	"r3\j2022\troll\nivel.map" loadtilemap 'mapajuego !
	
	'jugando SDLshow
	SDLquit ;	
	
: main ;