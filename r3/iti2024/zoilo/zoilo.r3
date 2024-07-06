| pampa zoilo
| PHREDA 2024
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/arr16.r3
^r3/lib/rand.r3

^r3/iti2024/zoilo/bmap.r3

#aap2
	

|----
#mapa1
#btnpad
#obj 0 0

#xvp #yvp		| viewport
#xvpd #yvpd	| viewport dest



|person array
| x y ang anim ss vx vy ar
| 1 2 3   4    5  6  7  8
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.ani 4 ncell+ ;
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;
:.va 8 ncell+ ;

#fullscr
	
:toglefs
	fullscr 1 xor 'fullscr !
	SDL_windows fullscr $1 and SDL_SetWindowFullscreen 
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
	<f> =? ( toglefs )
	drop 
	;

|---------------------
:viewpostmove
	xvpd xvp - 5 >> 'xvp +!
	yvpd yvp - 5 >> 'yvp +!
	;
	
:viewportx | x -- x
	dup sw 1 >> - 'xvpd ! ;
	
:viewporty | y -- y
	dup sh 1 >> - 'yvpd ! ;	
	
#persona1 ( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
#persona2 ( 12 13 12 14 15 16 15 17 18 19 18 20 21 22 21 23 )
#persona3 ( 24 25 24 26 27 28 27 29 30 31 30 32 33 34 33 35 )
#persona4 ( 36 37 36 38 39 40 39 41 42 43 42 44 45 46 45 47 )

	
:anim! | 'anim --
	a> 2 3 << + ! ; 
	
:anim@
	a> 2 3 << + @+ 2 << swap @ + ;

:sumax | adv -- tilew
	0? ( ; ) -? ( drop -20 ; ) drop 16 ;

:xymove | dx dy --
	a> @ pick2 + 
	a> 8 + @ pick2 + |16 >> 32 + | piso
	xyinmap@
	$1000000000000 and? ( 3drop ; ) 
	
	drop
	a> 8 + +!
	a> +!
	;

|0 12 $3f ICS>anim 'aap2 !
|12 12 $3f ICS>anim 'aap2 !

#btnpadp

:setvel
	a> .vy !
	a> .vx !
	;
	
	
:dobtn
	btnpad btnpadp =? ( drop ; ) 
	%1000 and? ( 0 -2.0 xymove )
	%100 and? ( 0 2.0 xymove  )
	%10 and? ( 12 12 $3f ICS>anim aap2 $ffffffff and or 'aap2 ! -2.0 0.0 xymove )
	%1 and? ( 0 12 $3f ICS>anim aap2 $ffffffff and or 'aap2 ! 2.0 0.0 xymove )
	'btnpadp !
	;

|  x y anim 
:player	
	8 + >a
	btnpad
	%1000 and? ( 0 -2.0 xymove )
	%100 and? ( 0 2.0 xymove  )
	%10 and? ( 12 12 $3f ICS>anim aap2 $ffffffff and or 'aap2 ! -2.0 0.0 xymove )
	%1 and? ( 0 12 $3f ICS>anim aap2 $ffffffff and or 'aap2 ! 2.0 0.0 xymove )
	1? ( msec 7 >> $3 and nip ) anim@ + c@
	a@+ int. a@+ int. 
	xytrigger
	swap viewportx xvp -
	swap viewporty yvp -
	+sprite | a x y --
	;	

:+jugador | 'per x y --
	'player 'obj p!+ >a
	swap a!+ a!+
	0 a!+ a!+ 
	;	

|---------------------

#randmove ( %0000 %0001 %0010 %0100 %0101 %0110 %1000 %1001 %1010 )

:randir
	40 randmax 1? ( drop ; ) drop
	9 randmax 'randmove + c@
	a> 4 3 << + !
	;
	
:npc
	8 + >a
	randir
	a> 4 3 << + @
	%1000 and? ( 3 anim! 0 -2.0 xymove )
	%100 and? ( 0 anim! 0 2.0 xymove  )
	%10 and? ( 1 anim! -2.0 0.0 xymove )
	%1 and? ( 2 anim! 2.0 0.0 xymove )
	1? ( msec 7 >> $3 and nip ) anim@ + c@
	a@+ int. a@+ int.
	xytrigger
	swap xvp -
	swap yvp -
	+sprite	| a x y
	;	

:+npc | 'dib x y --
	'npc 'obj p!+ >a
	swap a!+ a!+
	0 a!+ a!+ 0 a!+
	;	

|-----------------------------------
:cosa
	8 + >a
	a> 2 3 << + @
	a@+ int. xvp -
	a@+ int. yvp -
	+sprite	| a x y
	;	

:+cosa | ndib x y --
	'cosa 'obj p!+ >a
	swap a!+ a!+
	a!+ 
	;	

	
|----- JUGAR
:jugar
	timer.
	0 SDLcls
	immgui		| ini IMMGUI	

	inisprite
	'obj p.draw
	
	xvp yvp drawmaps
	viewpostmove
	
	aap2 timer+ 'aap2 !
	500 300 aap2 anim>n sprplayer2 ssprite

	SDLredraw
	teclado
	;
	
:reset
	'obj p.clear
	;
		
:randnpc
	4 randmax 4 << 'persona1 +
	( 	2800.0 randmax 32.0 + 
		1200.0 randmax 64.0 +
		2dup xyinmap@ $1000000000000 and? 
		3drop ) drop
	+npc
	;
	
:randcosa	
	48
	( 	2800.0 randmax 32.0 + 
		1200.0 randmax 64.0 +
		2dup xyinmap@ $1000000000000 and? 
		3drop ) drop
	+cosa
	;
	
:juego
	inisprite
	reset
	'persona1 130.0 300.0 +jugador
|	200 ( 1? 1 - randnpc ) drop
|	10 ( 1? 1 - randcosa ) drop
	'jugar SDLshow
	;	

:main
	"r3sdl" 1024 600 SDLinit
	SDLrenderer 1024 600 SDL_RenderSetLogicalSize | fullscreen
	
	"media/ttf/Roboto-Medium.ttf" 12 TTF_OpenFont immSDL
	"r3/iti2024/zoilo/mapa.bmap" loadmap 'mapa1 !
	32 32 "r3/iti2024/zoilo/sprites.png" ssload 'sprplayer !
	
	128 128 "r3/iti2024/zoilo/jugador.png" ssload 'sprplayer2 !
	
	1000 'obj p.ini
	juego
	SDLquit
	;
	
: main ;