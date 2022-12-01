| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3
^r3/util/penner.r3
^r3/lib/gui.r3


#sprj
#spre
#sinicio
#sganaste
#sperdiste
#sbtnj1 #sbtnj2
#sbtns1 #sbtns2

#fx 0 0

#xvp #yvp	| viewport

#xp 30.0 #yp 30.0	| pos player
#vxp 0 #vyp 0		| vel player

#np 0
#vida

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
1.0 $100  39 39 10 14 16 19
1.0 $100  5 9 22 22 16 19
1.0 $100  8 8 43 50 16 19
1.0 $100  10 10 50 43 16 19
1.5 $100  13 13 46 49 16 19
1.0 $100  34 34 54 54 16 19
1.0 $100  19 21 50 50 16 19
1.0 $100  42 42 52 52 16 19
1.0 $100  36 36 54 54 16 19
1.0 $100  6 6 68 68 16 19
1.0 $100  10 10 69 69 16 19
1.0 $100  68 68 45 45 16 19
1.0 $100  38 38 69 69 16 19
1.0 $100  63 63 5 5 16 19
1.0 $100  56 56 7 7 16 19
1.0 $100  68 68 23 23 16 19
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
		) drop  
	hitene 0? ( drop ; ) drop
	-1 'vida +!
	vida 0? ( exit ) drop
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
	wall? 0? ( drop animh ; )
	drop neg 'yp +! ; 
	
:player	
	np sprj 
	xp int. xvp -
	yp int. yvp -
	32 32 tsdraws

	btnpad
	%1000 and? ( -3.0 ymove  )
	%100 and? ( 3.0 ymove  )
	%10 and? ( -3.0 xmove )
	%1 and? ( 3.0 xmove )
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
	
:barra
	$ff00 SDLColor
	10 10 vida 10 + 20 SDLFRect ;	
	
:jugando
	$666666 SDLcls

	viewport
	drawmapa	
	barra
	'fx p.draw
	player
	enemigos
	
	SDLredraw
	
	teclado ;
	
:reset
	200 'vida !
	30.0 'xp ! 30.0 'yp !	| pos player
	;
	
:jugar
	reset 
	'jugando sdlshow

|	vidas 0? ( drop perdio ; ) drop
|	gano
	;	
|------------
:btni | 'vecor 'i x y -- 
	pick2 @ SDLImagewh guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;
	
:menu
	gui
|	$0 SDLcls
	0 0 sinicio SDLImage

	'jugar 'sbtnj1 100 400 btni
	'exit 'sbtns1 500 400 btni
	SDLredraw
	
	SDLkey
	>ESC< =? ( exit )
	drop
	;
		

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	
	8 8 "r3\j2022\troll\sprites.png" loadts 'sprj !
	"r3\j2022\troll\nivel.map" loadtilemap 'mapajuego !
	"r3\j2022\troll\img\inicio.png" loadimg 'sinicio !		

	"r3\j2022\troll\img\btnj1.png" loadimg 'sbtnj1 !		
	"r3\j2022\troll\img\btnj2.png" loadimg 'sbtnj2 !		
	"r3\j2022\troll\img\btns1.png" loadimg 'sbtns1 !		
	"r3\j2022\troll\img\btns2.png" loadimg 'sbtns2 !		
		
	
	|'jugando SDLshow
	'menu SDLshow
	SDLquit ;	
	
: main ;