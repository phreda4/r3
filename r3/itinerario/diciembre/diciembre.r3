| DICIEMBRE - JUEGO ITINERARIO 2023
|
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/arr16.r3
^r3/lib/rand.r3

|----
#sprplayer

#btnpad
#np 0

#xvp #yvp		| viewport

#obj 0 0

|----
#mapgame
#mapw #maph 	| size map
#mapx #mapy		| ini screen
#maptw #mapth	| tile size
#mapsx #mapsy	| size screen
#mapsw #mapsh	| size screen

#tileset
#tilew #tileh	| tile size in file
#tsimg
#tsmap

#boxsrc [ 0 0 0 0 ]
#boxdst [ 0 0 0 0 ]


|------ DRAW MAP
:map>
	mapw * + 3 << mapgame + ;

:layer | ts n -- 
	$fff and 0? ( drop ; )
	3 << tsmap + @ 'boxsrc ! | texture 'ts n  r
	SDLrenderer tsimg 'boxsrc 'boxdst SDL_RenderCopy ;

:setxy | y x --	
	over mapth * mapy + 32 << 
	over maptw * mapx + $ffffffff and or
	'boxdst ! ;
	
:drawtile1 | y x -- 
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	dup layer | back
	12 >> layer | back2
	;

| capa de arriba
:drawtile2 | y x -- 
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	dup 24 >> layer | Front
	36 >> layer | Front2
	;

#sprinscr 
#sprinscr> 
#sprinscr<

:inisprite
	here 1 63 << dup rot !+ !+ 
	dup 'sprinscr ! 
	dup 'sprinscr> ! 
	'sprinscr< ! 
	;
	
:+sprite | adr x y --
	mapth neg <? ( 3drop ; ) sh mapth + >? ( 3drop ; )
	32 << swap $ffffffff and or | compress
	sprinscr>
	( 16 - dup @ 						| adr yx adr' yx'
		pick2 >? 
		over 8 + @ swap
		pick2 16 + !+ !
		) drop
	16 + !+ !
	16 'sprinscr> +! 
	;

:drawobj | ylim a vyx -- ylim 'a
	dup 32 << 32 >> | x
	swap 32 >>		| adr x y
	2.0 np sprplayer sspritez | x y n ssprite --
	8 +
	;

:drawlineobj | y -- y
	dup mapth * mapy + | y limit
	32 << | in high
	sprinscr< ( @+ 1? pick2 <? drawobj ) drop 
	8 - 'sprinscr< !
	drop
	;
	
:drawmaps | --
	0 sprinscr> !
	|sprinscr ( sprinscr> <? @+ "%h " .print @+ "%h" .println ) drop 
		
	xvp $1f and neg 'mapx !
	yvp $1f and neg 'mapy !
	xvp 5 >> 'mapsx !
	yvp 5 >> 'mapsy !
	0 ( mapsh <? 
		0 ( mapsw <?
			setxy drawtile1
			1 + ) drop
		1 + ) drop 
	0 ( mapsh <? 
		drawlineobj | antes de dibujar la linea dibujo los sprite que estan arriba
		0 ( mapsw <?
			setxy drawtile2
			1 + ) drop
		1 + ) drop ;


|------ LOAD MAP
:loadmap | filename -- 
	here dup rot load | inimem endmem
	over =? ( 2drop 0 ; ) 'here !
	8 +
	d@+ 'mapw ! d@+ 'maph !
	dup 'mapgame !
	mapw maph * 3 << +					| map size
	d@+ 'tilew ! d@+ 'tileh !
	| muchos mapas, 1 tileset?
	tilew tileh rot tsload 'tileset !	| tileset
	32 'maptw ! 32 'mapth ! 
	maptw mapth 32 << or 'boxdst 8 + !	| size dst
	tilew tileh 32 << or 'boxsrc 8 + ! 	| size src w h 
	tileset @+ 'tsimg ! 8 + 'tsmap !
	34 'mapsw ! 22 'mapsh !	
	;
	
|------ PLAYER
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
	
	<f1> =? ( sprinscr ( sprinscr> <? @+ "%h " .print @+ "%h" .println ) drop .cr )
	<f2> =? ( 1 0 500 randmax +sprite )
	drop 
	;

|---------------------
#anidn ( 0 1 0 2 )
#anile ( 3 4 3 5 )
#aniri ( 6 7 6 8 )
#aniup ( 9 10 9 11 )
	
#anidn ( 12 13 12 14 )
#anile ( 15 16 15 17 )
#aniri ( 18 19 18 20 )
#aniup ( 21 22 21 23 )

:panim | -- nanim	
	msec 7 >> $3 and + c@ ;

:dirv | v --
	-? ( 'anile ; ) 'aniri ;
:xmove
	dirv panim 'np ! a> +! ;
	
:dirh | v --
	-? ( 'aniup ; ) 'anidn ;
:ymove
	dirh panim 'np ! a> 8 + +! ;

:viewportx | x -- x
	dup sw 1 >> - 'xvp ! ;
	
:viewporty | y -- y
	dup sh 1 >> - 'yvp ! ;
	
:player	
	dup >a
	btnpad
	%1000 and? ( -1.0 ymove  )
	%100 and? ( 1.0 ymove  )
	%10 and? ( -1.0 xmove )
	%1 and? ( 1.0 xmove )
	drop	
	a@+ int. viewportx xvp -
	a@+ int. viewporty yvp -
	+sprite | a x y
|	2.0 
|	np 
|	sprplayer
|	sspritez | x y n ssprite --
	;	

:+jugador | x y --
	'player 'obj p!+ >a
	swap a!+ a!+

	$40000 a!+ | anim
	sprplayer a!+ | sprite
	
	;	

|---------------------
:npc	
	dup >a
	a@+ int. xvp -
	a@+ int. yvp -
	+sprite	| a x y
|	2.0 np sprplayer
|	sspritez | x y n ssprite --
	;	

:+npc | x y --
	'npc 'obj p!+ >a
	swap a!+ a!+
	
	$40000 a!+ | anim
	sprplayer a!+ | sprite
	
	;	

	
|----- JUGAR
:jugar
	0 SDLcls
	immgui		| ini IMMGUI	

	inisprite
	'obj p.draw
	drawmaps

	SDLredraw
	teclado
	;
	
:reset
	'obj p.clear
	;
		
:juego
	inisprite
	
	reset
	130.0 300.0 +jugador
	300.0 200.0 +npc
	400.0 600.0 +npc
	'jugar SDLshow
	;	

:main
	"r3sdl" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 12 TTF_OpenFont immSDL
	"r3/itinerario/diciembre/escuela1.bmap" loadmap 
	32 32 "r3/itinerario/diciembre/protagonista.png" ssload 'sprplayer !
	200 'obj p.ini
	juego
	SDLquit
	;
	
: main ;