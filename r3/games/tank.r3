| frobots
| PHREDA 2021-2024 (r3)
|-------------------------

^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3

#tsprites 

#tanks 0 0
#disp 0 0
#fx 0 0

#viewpx #viewpy

:viewreset
	sw 1 >> 'viewpx !
	sh 1 >> 'viewpy !
	;

| tank
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

|----------- Disparo
:disparo | adr --
	dup 8 + >a
	a@+ int. viewpx + 
	a@+ int. viewpy +	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz

	|..... add velocity to position
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	dup .va @ over .a +!
	drop
	;

:+disparo | vel ang x y --
	'disparo 'disp p!+ >a
	swap a!+ a!+ 
	a!+	| angulo
	polar a!+ a!+
	;

|-------------------
:dtank | adr -- adr
	dup 8 + >a
	a@+ int. viewpx + 
	a@+ int. viewpy +	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz

	|..... add velocity to position
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	dup .va @ over .a +!
	drop
	;
	
:+tank | sheet anim zoom ang x y --
	'dtank 'tanks p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+	a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	0 a!			| vrz
	
	;
	
|-------------------
:runscr
	timer.
	0 sdlcls
	$ffff bcolor
	0 0 bat "Tanks" bprint bcr

	'tanks p.draw
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( tsprites 
		0 2 $ff ICS>anim | init cnt scale -- 
		2.0 1.0 randmax 
		600.0 randmax 300.0 -
		400.0 randmax 200.0 -
		+tank )
	drop ;

|-------------------
: |<<< BOOT <<<
	"r3 robots" 1024 600 SDLinit
	viewreset
	"media/ttf/roboto-bold.TTF" 20 TTF_OpenFont immSDL
	16 16 "media/img/tank.png" ssload 'tsprites !
	40 'fx p.ini
	50 'tanks p.ini
	100 'disp p.ini
	
	bfont1
	'runscr SDLshow
	SDLquit 
	;
