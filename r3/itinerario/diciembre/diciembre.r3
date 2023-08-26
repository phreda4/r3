| DICIEMBRE - JUEGO ITINERARIO 2023
|
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/arr16.r3

#tileset
#tilew #tileh	| tile size in file

#mapgame
#mapw #maph 	| size map

#maptw #mapth	| tile size
#mapx #mapy		| ini screen
#mapsx #mapsy	| size screen
#mapsw #mapsh	| size screen

#map

#sprjug

#btnpad
#xp 130.0 #yp 330.0	| pos player
#vxp 0 #vyp 0		| vel player
#np 0
#xvp #yvp


#rec [ 0 0 0 0 ]
#rdes [ 0 0 0 0 ]

|------ DRAW MAP
#tsimg
#tsmap

|--------------	
:map>
	mapw * + 3 << mapgame + ;

:layer | ts n -- 
	$fff and 0? ( drop ; )
	3 << tsmap + @ 'rec ! | texture 'ts n  r
	SDLrenderer tsimg 'rec 'rdes SDL_RenderCopy 
	;
	
:drawtile | y x -- 
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	dup layer | background
	dup 12 >> layer | background2
	dup 24 >> layer | From
	36 >> layer | Up
	;

:setxy | y x --	
	over mapth * mapy + 32 << 
	over maptw * mapx + $ffffffff and or
	'rdes ! ;
	
:drawmaps | --
	xvp $3f and neg 'mapx !
	yvp $3f and neg 'mapy !
	xvp 6 >> 'mapsx !
	yvp 6 >> 'mapsy !
	0 ( mapsh <? 
		0 ( mapsw <?
			setxy 
			drawtile 
			1 + ) drop
		1 + ) drop ;

	
:loadmap | filename -- map
	here dup rot load | inimem endmem
	over =? ( 2drop 0 ; ) 'here !
	d@+ 'mapw ! d@+ 'maph !
	24 'tileh ! 64 'mapth ! 
	24 'tilew ! 64 'maptw ! 
	maptw mapth 32 << or 'rdes 8 + ! 
	tilew tileh 32 << or 'rec 8 + ! | w h 
	17 'mapsw ! 
	11 'mapsh !	
	tileset @+ 'tsimg ! 8 + 'tsmap !
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

	
#anidn ( 0 1 0 2 )
#anile ( 3 4 3 5 )
#aniri ( 6 7 6 8 )
#aniup ( 9 10 9 11 )

:panim | -- nanim	
	msec 7 >> $3 and + c@ ;
	
:dirv | v --
	-? ( 'anile ; ) 'aniri ;
	
:xmove
	dirv panim 'np ! 'xp +! ;
	
:dirh | v --
	-? ( 'aniup ; ) 'anidn ;

:ymove
	dirh panim 'np ! 'yp +! ;
	
:player	
	xp int. xvp -
	yp int. yvp -
	2.0 np sprjug
	sspritez | x y n ssprite --

	btnpad
	%1000 and? ( -1.0 ymove  )
	%100 and? ( 1.0 ymove  )
	%10 and? ( -1.0 xmove )
	%1 and? ( 1.0 xmove )
	drop
	xp int. sw 1 >> - 'xvp !
	yp int. sh 1 >> - 'yvp !
	;	
	
|----- MAIN
:editor
	0 SDLcls
	immgui		| ini IMMGUI	
|	drawmap
drawmaps
	player
	SDLredraw
	teclado
	;

:main
	"r3sdl" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 12 TTF_OpenFont immSDL

	24 24 "r3/itinerario/diciembre/classroom.png" tsload 'tileset !
	"r3/itinerario/diciembre/escuela1.map" loadmap 'mapgame !
	32 32 "r3/itinerario/diciembre/protagonista.png" ssload 'sprjug !

	'editor SDLshow
	SDLquit
	;
	
: main ;