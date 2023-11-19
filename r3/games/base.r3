| TILEMAP + ENEMY + PLAYER
| PHREDA 2022

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

^r3/util/penner.r3

#tilecity
#sprplayer

#fx 0 0

#xp 30.0 
#yp 30.0
#zp 0
#vzp 0
#np 65
	
#xvp #yvp	| viewport
	
#mapa1
0 | <--tileset
[ 32 32 32 32 ] | anchomap altomap tielancho tilealto
(
6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 2 2 3 3 3 6 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 6 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 5 6 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 4 3 6 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 2 3 3 7 7 7 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 8 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 8 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 8 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 6 6 6 6 6 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 9 9 3 3 3 3 3 3 3 3 3 3 1 1 1 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 3 3 3 3 1
1 3 3 3 3 5 5 5 5 5 5 5 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 11 11 11 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 13 13 13 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 2 3 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 2 3 2 3 3 3 3 3 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 3 3 3 3 3 2 3 2 3 3 3 3 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
)

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
1.9 $100  2 20 3  3 6 10
1.5 $1 10 10 5 15 6 10
1.5 $2 12 12 5 15 6 10
1.5 $3 14 14 5 15 6 10
1.5 $4 16 16 5 15 6 10
1.5 $101 18 18 5 15 6 10
1.5 $102 20 20 5 15 6 10
1.5 $103 22 22 5 15 6 10
1.1 $104 24 24 5 15 6 10
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
	8 + >a
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

#sanim ( 0 1 0 2 )

:panim | -- nanim	
	msec 7 >> $3 and 'sanim + c@ ;
	
:pstay 	65 'np ! ;
:prunl estela 94 panim + 'np ! -2.0 'xp +! ;
:prunr estela 91 panim + 'np ! 2.0 'xp +! ;
:prunu estela 68 panim + 'np ! -2.0 'yp +! ;
:prund estela 65 panim + 'np ! 2.0 'yp +!	;

:saltar 
	zp 1? ( drop ; ) drop
	4.0 'vzp ! ;
	
#ep 'pstay

:player	
	12 sprplayer 
	xp int. 2 + xvp -
	yp int. 2 + yvp -
	tsdraw	| sombra
	
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
	<up> =? ( 'prunu 'ep ! )
	<dn> =? ( 'prund 'ep ! )
	<le> =? ( 'prunl 'ep ! )
	<ri> =? ( 'prunr 'ep ! )
	>up< =? ( 'pstay 'ep ! )
	>dn< =? ( 'pstay 'ep ! )
	>le< =? ( 'pstay 'ep ! )
	>ri< =? ( 'pstay 'ep ! )
	<esp> =? ( saltar )
	drop 
	;
	
:demo
	0 SDLcls
	viewport
	26 20 
	xvp 5 >> yvp 5 >>
	xvp $1f and neg 
	yvp $1f and neg	
	'mapa1 tiledraw
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
	32 32 "media\img\open_tileset.png" tsload 
	dup 'tilecity !	
	'mapa1 !
	64 64 "media\img\sokoban_tilesheet.png" tsload 'sprplayer !

	'demo SDLshow

	SDLquit ;	
	
: main ;