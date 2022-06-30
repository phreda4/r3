| r3 sdl program
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#tilecity
#sprplayer

#fx 0 0

#xp 30.0 
#yp 30.0
#zp 0
#vzp 0
#np 65
	
#wmap 32
#hmap 32

#map (
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


|------ DRAW MAP

:gettilea | x y -- t
	4 >> swap 4 >> swap 32 * + 'map + ;

:gettile | x y -- t
	4 >> swap 4 >> swap 32 * + 'map + c@ ;

:drawtile | x y adr tile -- y x adr  
	0? ( drop ; ) tilecity 
	pick4 5 << pick4 5 << swap
	tsdraw ;

:drawmap
	'map 
	0 ( 32 <? 
		0 ( 32 <?
			rot c@+ drawtile rot rot 
			1 + ) drop
		1 + ) 2drop ;

|--------------------------------

#mapw
#maph
#mapm
#mapx
#mapy

:map! | w h mem --
	'mapm ! 'maph ! 'mapw ! ;

:map> | x y -- a
	mapw * + mapm + ;
	
:[map]@ | x y -- v
	mapw clamp0max swap
	maph clamp0max swap
	map> c@ ;
	
:maptile
	;
		
#xm #ym		
:mapdraw | w h x y xs ys --
	'ym ! 'xm !
	( 1? 1 - over
		( 1? 1 - 
			maptile
			) drop
		) 2drop ;

|--------------------------------
	
:humo
	>a
	a@
	100 >? ( drop 0 ; ) 
	1 + a!+
	25 sprplayer 
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
	xp yp zp - +humo
	;
	
|--------------------------------

#sanim ( 0 1 0 2 )

:panim | -- nanim	
	msec 7 >> $3 and 'sanim + c@ ;
	
:pstay
	65 'np !
	;
:prunl
	estela	
	94 panim + 'np !
	-2.0 'xp +!
	;
:prunr
	estela	
	91 panim + 'np !
	2.0 'xp +!
	;
:prunu
	estela	
	68 panim + 'np !
	-2.0 'yp +!
	;
:prund
	estela	
	65 panim + 'np !
	2.0 'yp +!
	;

:saltar
	zp 1? ( drop ; ) drop
	4.0 'vzp !
	;
	
#ep 'pstay


:player	
	$ffffff bcolor 
	10 10 bat 
	yp xp "%f %f" sprint bprint

	12 sprplayer xp int. 2 + yp int. 2 + tsdraw	| sombra
	np sprplayer xp int. yp zp - int. tsdraw
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

	drawmap
	'fx p.draw
	player
	SDLredraw
	
	teclado ;

:main
	1000 'fx p.ini
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	32 32 "media\img\open_tileset.png" loadts 'tilecity !	
	64 64 "media\img\sokoban_tilesheet.png" loadts 'sprplayer !

	'demo SDLshow
	SDLquit ;	
	
: main ;