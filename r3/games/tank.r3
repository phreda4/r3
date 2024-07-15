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

#btnpad

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
:.end 8 ncell+ ;


|------------------- fx
:fxobj | x y --
	dup 8 + >a
	a@+ int. viewpx + 
	a@+ int. viewpy +	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz
	16 + a@ over .a anim>n =? ( 2drop 0 ; ) drop 
	|..... add velocity to position
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	drop
	;

:+fxobj | last ss anim zoom ang x y --
	'fxobj 'fx p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+ a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	a!			| vrz
	;

:+fxdisp | ang x y --
	'fxobj 'fx p!+ >a
	swap a!+ a!+	| x y 
	32 << 2.0 or a!+	| ang zoom
	10 5 $3f ICS>anim | init cnt scale
	a!+ 
	tsprites a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	14 a!			| vrz
	;
	
:+fxexplo | ang x y --
	'fxobj 'fx p!+ >a
	swap a!+ a!+	| x y 
	32 << 2.0 or a!+	| ang zoom
	15 6 $3f ICS>anim | init cnt scale
	a!+ 
	tsprites a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	19 a!			| vrz
	;
	
|------------------- bomb
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
	drop
	;

:+disparo | vel ang x y --
	'disparo 'disp p!+ >b
	swap b!+ b!+ 
	dup 0.25 + 32 << 2.0 or b!+	| angulo zoom
	14 1 0 ICS>anim | init cnt scale
	b!+ | ani
	tsprites b!+ |ss
	swap polar 
	b!+ b!+
	;

:+disp | -- | a in obj
	3.0
	a> .a @ 32 >> 0.25 + neg
	a> .x @ 
	a> .y @ +disparo
	btnpad $10 not and 'btnpad !
	;

|------------------- player tank
	
:motor | m --
 	a> .a @ 32 >> swap polar 
	a> .y +! a> .x +! ;
	
:turn | a --
	32 << a> .a +! ;

:ptank | adr -- adr
	dup >a
	btnpad
	$1 and? ( -0.01 turn )
	$2 and? ( 0.01 turn )
	$4 and? ( 0.2 motor )
	$8 and? ( -0.2 motor )
	$10 and? ( +disp )
	drop
	8 a+
	a@+ int. viewpx + 
	a@+ int. viewpy +	| x y
	a@+ dup 32 >> neg swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz
	drop
	;

:+ptank | sheet ani zoom ang x y --
	'ptank 'tanks p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+ a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	0 a!			| vrz
	;

|------------------- NPC tank
:dtank | adr -- adr
	dup 8 + >a
	a@+ int. viewpx + 
	a@+ int. viewpy +	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz
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
	16 32 bat "Tanks" bprint2 
	
	'disp p.draw
	'tanks p.draw
	'fx p.draw
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( tsprites 
		0 2 $ff ICS>anim | init cnt scale -- 
		2.0 1.0 randmax 
		600.0 randmax 300.0 -
		400.0 randmax 200.0 -
		+tank )
	| ---- player control	
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 not and 'btnpad ! )
	>dn< =? ( btnpad %100 not and 'btnpad ! )
	>le< =? ( btnpad %10 not and 'btnpad ! )
	>ri< =? ( btnpad %1 not and 'btnpad ! )
	<esp> =? ( btnpad $10 or 'btnpad ! )
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
	
	tsprites 
	0 0 0 ICS>anim | init cnt scale -- 
	2.0 0.0 
	0 0 +ptank 
	
	bfont1
	'runscr SDLshow
	SDLquit 
	;
