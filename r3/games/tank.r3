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

:drawspr | arr -- arr
	dup 8 + >a
	a@+ int. viewpx + 
	a@+ int. viewpy +	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	a@+ sspriterz
	;

|------------------- fx
:fxobj | adr --
	dup .ani @ anim>n 
	over .end @ 
	=? ( 2drop 0 ; ) drop 
	drawspr
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
	a!				| last
	;

:+fxdisp | ang x y --
	'fxobj 'fx p!+ >b
	swap b!+ b!+	| x y 
	32 << 2.0 or b!+	| ang zoom
	10 4 $ff ICS>anim | init cnt scale
	b!+ 
	tsprites b!+	| anim sheet
	0 b!+ 0 b!+ 	| vx vy
	13 b!			| vrz
	;
	
:+fxexplo | x y --
	'fxobj 'fx p!+ >a
	swap a!+ a!+	| x y 
	2.0 a!+			| ang zoom
	15 6 $ff ICS>anim | init cnt scale
	a!+ 
	tsprites a!+	| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	19 a!			| vrz
	;
	
|------------------- bomb
:disparo | adr --
	dup .end dup @ timer- -? ( 
		2drop dup .x @ swap .y @ +fxexplo
		0 ; ) swap !
	drawspr
	|..... add velocity to position
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	drop
	;

:+disparo | vel ang x y --
	pick2 neg 0.5 + pick2 pick2 +fxdisp
	'disparo 'disp p!+ >b
	swap b!+ b!+ 
	neg 0.25 + dup 32 << 2.0 or b!+	| angulo zoom
	14 1 0 ICS>anim | init cnt scale
	b!+ | ani
	tsprites b!+ |ss
	swap polar 
	b!+ b!+
	1000 b!
	;

|------------------- player tank
:+disp | -- 
	3.0	| vel
	a> .a @ 32 >> neg 0.5 +
	a> .x @ a> .y @
	pick2 32.0 
	xy+polar | x y bangle r -- x y
	+disparo
	btnpad $10 not and 'btnpad !
	;

:motor | m --
 	a> .a @ 32 >> neg 0.5 + swap polar 
	a> .y +! a> .x +! ;

:turn | a --
	32 << a> .a +! ;

:ptank | adr -- adr
	dup >a
	btnpad
	$1 and? ( 0.01 turn )
	$2 and? ( -0.01 turn )
	$4 and? ( -0.4 motor )
	$8 and? ( 0.4 motor )
	$10 and? ( +disp )
	drop
	drawspr	
	drop
	;

:+ptank | sheet ani zoom ang x y --
	'ptank 'tanks p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+ a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	0 a!			| end
	;

|------------------- NPC tank
:dtank | adr -- adr
	drawspr	
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
	
	<f1> =? ( tsprites 
		0 2 $ff ICS>anim | init cnt scale -- 
		2.0 1.0 randmax 
		600.0 randmax 300.0 -
		400.0 randmax 200.0 -
		+tank )
	drop ;

:reset
	sw 1 >> 'viewpx !
	sh 1 >> 'viewpy !

	'fx p.clear
	'tanks p.clear
	'disp p.clear
	
	tsprites 
	0 0 0 ICS>anim | init cnt scale -- 
	2.0 0.0 
	0 0 +ptank 
	;
	
|-------------------
: |<<< BOOT <<<
	"r3 robots" 1024 600 SDLinit
	bfont1
	
	"media/ttf/roboto-bold.TTF" 20 TTF_OpenFont immSDL
	16 16 "media/img/tank.png" ssload 'tsprites !
	40 'fx p.ini
	50 'tanks p.ini
	100 'disp p.ini
	reset
	'runscr SDLshow
	SDLquit 
	;