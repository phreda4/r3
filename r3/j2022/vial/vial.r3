| TILEMAP + ENEMY + PLAYER
| PHREDA 2022

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

^r3/util/penner.r3

#mapajuego
#sprplayer

#fx 0 0

#xp 30.0 
#yp 30.0
#zp 0
#vzp 0
#np 65
	
#xvp #yvp	| viewport


|--------------------------------
:viewport
	xp int. sw 1 >> - 'xvp !
	yp int. sh 1 >> - 'yvp !
	;
	
|--------------------------------
#hitene
#timeene

| velocidad pp+ease x1 x2 y1 y2 n1 n2
| $1xx = pingpong $0xx = ping

#listene [
0.1 $100 2 30 3 3 6 10
0.05 $100 2 30 4 4 6 10
0.01 $100 2 30 5 5 6 10

0 ]

:pp | pp|ease vel -- pp|ease mul
	over 
	$100 nand? ( drop $ffff and ; ) drop
	$1ffff and $10000 and? ( $1ffff xor )
	;
	
:calctime | pp|ease vel -- mult
	timeene 10 *>>
	pp swap $ff and ease ;
	
:calcxi | calc xi yi -- calc x
	over - pick2 *. + ;
	
:calcpos | v -- x y 
	da@+ swap 
	calctime 
	da@+ 6 << |32 * | 32 tile map size
	da@+ 6 << |32 * | vel x1 x2
	calcxi 	| vel x
	swap
	da@+ 6 << |32 * 
	da@+ 6 << |32 * | vel y1 y2
	calcxi nip 	| x y
	;
	
:drawene | x y --
	msec 1 >> $ff and 
	da@+ da@+ over - rot 8 *>> +
	sprplayer
	2swap 
	yvp - swap
	xvp - swap
	tsdraw ;

:hitplayer | x y -- x y
	over xp 16 >> - 
	over yp 16 >> - distfast
	32 <? ( a> 'hitene ! )
	drop
	;	
	
:enemys | 
	msec 'timeene !
	0 'hitene !
	'listene >a ( da@+ 1? 
		calcpos
		hitplayer
		drawene
		) drop  ;
	
|--------------------------------
:humo
	>a
	a@
	100 >? ( drop 0 ; ) 
	1 + a!+
	25 sprplayer 
	a@+ int. xvp -
	a@+ int. yvp -
	tsdraw
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
	xp yp zp - +humo
	;
	
|--------------------------------
:panim | -- nanim	
	msec 6 >> $7 and ;
	
:pstay 	65 'np ! ;
:prunl 10 panim + 'np ! -2.0 'xp +! ;
:prunr 0 panim + 'np ! 2.0 'xp +! ;
:prunu 0 'np ! -2.0 'yp +! ;
:prund 10 'np ! 2.0 'yp +!	;

:saltar 
	zp 1? ( drop ; ) drop
	4.0 'vzp ! ;
	
#ep 'pstay

:player	
|	12 sprplayer 
|	xp int. 2 + xvp -
|	yp int. 2 + yvp -
|	tsdraw	| sombra
	
	np sprplayer 
	xp int. xvp -
	yp zp - int. yvp -
	tsdraw
	
	ep ex
	
	zp vzp +
	0 <=? ( drop 0 'zp ! 0 'vzp ! ; )
	'zp !
	-0.1 'vzp +!
	;
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:demo
	0 SDLcls
	viewport
	
	$039be5 SDLcls

	5 3 
	xvp 8 >> yvp 8 >>
	xvp $ff and neg 
	yvp $ff and neg
	256 dup mapajuego tiledraws
	
	'fx p.draw
	
	enemys
	player
	
	2 2 bat 
	hitene "%h" sprint bprint
	
	SDLredraw
	teclado 
	;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	
	"r3\j2022\vial\mapa.map" loadtilemap 'mapajuego !
	
	124 124 "r3\j2022\vial\robot.png" loadts 'sprplayer !
	
	'demo SDLshow

	SDLquit ;	
	
: main ;