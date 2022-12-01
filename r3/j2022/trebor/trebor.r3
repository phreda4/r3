| trebor en busca del oro

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/lib/gui.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

^r3/util/penner.r3

#sbtnj1 #sbtnj2
#sbtns1 #sbtns2

#sinicio
#sfin
#sfondo
#sprj
#spre

#fx 0 0

#xvp #yvp	| viewport

#xp 3616.0 #yp 256.0	| pos player
#vxp 0 #vyp 0		| vel player

#np 0
#vida
#mapajuego

:reset
	3616.0 'xp ! 
	256.0 'yp !
	0 'vxp !
	0 'vyp !		| vel player
	200 'vida !
	;
		
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
1.0 $100  128 128 11 11 0 4
1.0 $100  139 123 9 9 5 7
1.0 $100  137 137 11 11 0 4
1.0 $100  143 143 13 13 0 4
1.0 $100  147 147 13 13 0 4
1.0 $100  144 134 3 3 5 7
1.0 $100  141 141 5 5 0 4
1.0 $100  155 155 11 11 0 4
1.0 $100  161 161 14 14 0 4
1.0 $100  167 167 14 14 0 4
1.0 $100  171 160 12 12 5 7
1.0 $100  214 214 19 19 27 31
1.0 $100  207 215 38 38 8 11
1.0 $100  200 197 38 38 8 11
1.0 $100  192 196 38 38 12 14
1.0 $100  188 195 36 36 5 7
1.0 $100  187 179 38 38 12 14
1.0 $100  178 182 34 34 8 11
1.0 $100  172 178 38 38 8 11
1.0 $100  163 167 38 38 12 14
1.0 $100  151 155 36 36 8 11
1.0 $100  143 148 38 38 12 14
1.0 $100  111 111 37 37 32 38
1.0 $100  96 103 42 42 15 15
1.0 $100  97 97 46 52 16 19
1.0 $100  96 104 58 58 15 15
1.0 $100  93 93 51 46 16 19
1.0 $100  86 92 43 43 15 15
1.0 $100  77 84 41 41 15 15
1.0 $100  81 89 56 56 15 15
1.0 $100  80 80 47 53 16 19
1.0 $100  64 73 49 49 15 15
1.0 $100  65 65 40 46 16 19
1.0 $100  61 61 52 57 16 19
1.0 $100  55 55 42 47 16 19
1.0 $100  51 58 52 52 15 15
1.0 $100  57 57 58 49 16 19
1.0 $100  47 53 55 55 15 15
1.0 $100  49 49 44 50 16 19
1.0 $100  43 43 46 41 16 19
1.0 $100  37 42 48 48 15 15
1.0 $100  33 39 43 43 15 15
1.0 $100  36 41 57 57 15 15
1.0 $100  35 35 55 49 16 19
1.0 $100  32 32 54 49 16 19
1.0 $100  27 32 46 46 15 15
1.0 $100  29 35 48 48 15 15
1.0 $100  27 27 58 53 16 19
1.0 $100  31 31 44 50 16 19
1.0 $100  8 8 49 49 39 43
1.0 $100  7 10 69 69 12 14
1.0 $100  11 14 69 69 12 14
1.0 $100  18 18 60 69 20 25
1.0 $100  21 21 60 69 20 25
1.0 $100  25 29 69 69 12 14
1.0 $100  32 32 60 69 20 25
1.0 $100  44 52 69 69 12 14
1.0 $100  46 46 60 69 20 25
1.0 $100  51 51 60 69 20 25
1.0 $100  56 64 69 69 12 14
1.0 $100  57 60 65 65 12 14
1.0 $100  62 62 60 69 20 25
1.0 $100  67 67 60 69 20 25
1.0 $100  65 75 69 69 12 14
1.0 $100  68 73 65 65 12 14
1.0 $100  77 80 69 69 12 14
1.0 $100  105 105 69 69 44 71 
1.0 $100  114 118 88 88 12 14
1.0 $100  106 110 88 88 12 14
1.0 $100  84 80 88 88 12 14
1.0 $100  74 79 88 88 12 14
1.0 $100  66 70 85 85 12 14
1.0 $100  55 49 88 88 12 14
1.0 $100  48 44 88 88 12 14
1.0 $100  38 43 88 88 12 14
1.0 $100  10 8 101 101 12 14
1.0 $100  15 12 99 99 12 14
1.0 $100  22 18 98 98 12 14
1.0 $100  29 27 99 99 12 14
1.0 $100  36 32 98 98 12 14
1.0 $100  43 45 96 96 12 14
1.0 $100  47 49 98 98 12 14
1.0 $100  50 52 98 98 12 14
1.0 $100  65 62 98 98 12 14
1.0 $100  75 70 101 101 12 14
1.0 $100  80 78 101 101 12 14
1.0 $100  88 85 100 100 12 14
2.0 $100  126 130 100 100 72 75 
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
	spre
	2swap 
	yvp - swap
	xvp - swap 4 -
	100 dup tsdraws ;

:hitplayer | x y -- x y
	over xp 16 >> - 
	over yp 16 >> - distfast
	32 <? ( a> 'hitene ! )
	drop
	;	
	
:enemigos | 
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
	
|--------------------------------
:viewport
	xp int. sw 1 >> - 'xvp !
	yp int. sh 1 >> - 'yvp !
	;
		
|--------------------------------
:[map]@ | x y -- c
	swap xvp - 
	swap yvp - 
	scr2tile c@ ;

:[map]! | c x y -- 
	swap xvp - 
	swap yvp - 
	scr2tile c! ;

:[map]@s | x y -- c
	[map]@
	4 =? ( ; ) 
	9 21 bt? ( ; ) 
	drop 0 ;
	
:roof? | -- techo?
	xp int. 32 + 
	yp int. 8 +
	[map]@s ;

:floor? | -- piso?
	xp int. 18 + yp int. 64 + [map]@s
	xp int. 32 + yp int. 64 + [map]@s or	
	;

:water? | -- 
	xp int. 32 +
	yp int. 64 + 
	[map]@
	22 33 bt? ( ; ) 
	drop 0 ;

:wall? | dx -- wall?
	xp int. +
	yp int. 32 +
	[map]@s ;
	
:panim | -- nanim	
	msec 5 >> 7 mod abs ;
	
:pstay
	|0 'np !
	;
	
:prunl
|	estela	
	8 wall? 1? ( drop ; ) drop
	22 panim + 'np !
	-2.9 'xp +!
	;
	
:prunr
|	estela	
	48 wall? 1? ( drop ; ) drop
	0 panim + 'np !
	2.9 'xp +!
	;

	
#ep 'pstay

:enagua
	0.09 'vyp +! 
	SDLkey
	<up> =? ( -3.5 'vyp ! )
	<dn> =? ( 0.2 'vyp +! )
	drop ;
	
|#testy	
:pisoysalto
	water? 1? ( drop enagua ; ) drop
	floor? 0? ( drop
		|7 panim + 'np !
		0.3 'vyp +!
|		10.0 clampmax
		roof? 1? ( vyp -? ( 0 'vyp ! ) drop ) drop
		; ) drop
		
	vyp 20.0 >? ( exit ) drop
	
|	vyp 1? ( dup 'testy ! ) drop

	0 'vyp !
	yp $ffffe00000 and 'yp ! | fit y to map (64.0)
	
	SDLkey
	<up> =? ( -8.0 'vyp ! )
	drop
	;

:debug
	$ffffff bcolor 
	10 10 bat 
	floor? "f:%d " sprint bprint  	
	roof? "r:%d " sprint bprint
	;
	
:player	
	np sprj 
	xp int. xvp -
	yp int. 6 + yvp -
	64 64 tsdraws
	ep ex
	pisoysalto
	
	vyp 'yp +!
	vxp 'xp +!
	;
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<le> =? ( 'prunl 'ep ! )
	<ri> =? ( 'prunr 'ep ! )
	>le< =? ( 'pstay 'ep ! )
	>ri< =? ( 'pstay 'ep ! )
	drop 
	;

:barra
	$ff00 SDLColor
	10 10 vida 10 + 20 SDLFRect ;
	
:btni | 'vecor 'i x y -- 
	pick2 @ SDLImagewh guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;
	
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
	31 33 bt? ( drop msec 8 >> 3 mod abs 31 + ; )
	34 36 bt? ( drop msec 8 >> 3 mod abs 34 + ; )
	;
	
:drawmapa
	26 20
	xvp 5 >> yvp 5 >>
	xvp $1f and neg 
	yvp $1f and neg
	32 32
	mapajuego 'vectortile 
	tiledrawvs ;
	
| 2240 1050
:jugando
	$256BCB SDLcls
	
	viewport
	xvp neg 8 + yvp neg 80 + 7168 3360 sfondo SDLImages
	drawmapa	
	barra
	
	'fx p.draw
	enemigos
	player
	
	10 20 bat
|	testy "%f" sprint bprint
|xvp yvp "%d %d " sprint bprint	
|hitene "%h" sprint bprint
	
	SDLredraw
	
	teclado ;
	
:jugar
	reset
	'jugando SDLshow
	;

:menu
	gui
|	$0 SDLcls
	0 0 sinicio SDLImage

	'jugar 'sbtnj1 150 300 btni
	'exit 'sbtns1 450 300 btni
	SDLredraw
	
	SDLkey
	<f1> =? ( jugar )
	>ESC< =? ( exit )
	drop
	;		

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	"r3/j2022/trebor/mapatrebor.png" loadimg 'sfondo ! 
	
	"r3/j2022/trebor/inicio.jpg" loadimg 'sinicio !
	"r3/j2022/trebor/fin.png" loadimg 'sfin !

	32 32 "r3\j2022\trebor\treborj.png" loadts 'sprj !
	50 50 "r3\j2022\trebor\enemigos.png" loadts 'spre !
	"r3\j2022\trebor\nivel.map" loadtilemap 'mapajuego !
	
	"r3\j2022\trebor\btnj1.png" loadimg 'sbtnj1 !		
	"r3\j2022\trebor\btnj2.png" loadimg 'sbtnj2 !		
	"r3\j2022\trebor\btns1.png" loadimg 'sbtns1 !		
	"r3\j2022\trebor\btns2.png" loadimg 'sbtns2 !		
	'menu SDLshow
	SDLquit ;	
	
: main ;