| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3
^r3/util/penner.r3

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
	
|--------------------------------
#hitene
#timeene

| velocidad pp+ease x1 x2 y1 y2 n1 n2
| $1xx = pingpong $0xx = ping

#listene [
1.0 $100  1 4 2 8 0 4
0 ]

:pp | pp|ease vel -- pp|ease mul
	over 
	$100 nand? ( drop $ffff and ; ) drop
	$1ffff and $10000 and? ( $1ffff xor )
	;
	
:calctime | pp|ease vel -- mult
	timeene 10 *>> pp swap $ff and ease ;
	
:calcxi | calc xi yi -- calc x
	over - pick2 *. + ;
	
:calcpos | v -- x y 
	da@+ swap 
	calctime 
	da@+ 5 << |32 * | 32 tile map size
	da@+ 5 << |32 * | vel x1 x2
	calcxi 	| vel x
	swap
	da@+ 5 << |32 * 
	da@+ 5 << |32 * | vel y1 y2
	calcxi nip 	| x y
	;
	
:drawene | x y --
	msec 1 >> $ff and 
	da@+ da@+ over - rot 8 *>> +
	sprj
	2swap 
	yvp - swap
	xvp - swap
	32 dup tsdraws ;

:hitplayer | x y -- x y
	over xp 16 >> - 
	over yp 16 >> - distfast
	32 <? ( a> 'hitene ! )
	drop
	;	
	
:enemigos | --
	msec 'timeene !
	0 'hitene !
	'listene >a ( da@+ 1? 
		calcpos
		hitplayer
		drawene
		) drop  ;
		
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
	enemigos
	
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