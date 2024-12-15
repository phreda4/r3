| arena war test
| PHREDA 2024
|-------------------------
^r3/util/sdlgui.r3
^r3/r3vm/arena-war.r3

	
:pasto	
	12343 'seed8 !
	16 ( sw <?
		16 ( sh <?
			2dup 2.0 rand8 4 >> $3 and 21 + imgspr sspritez
		32 + ) drop
	32 + ) drop	
	;
	
|-------------------
:runscr
	immgui
	timer.
	0 sdlcls
	
	pasto
	
	$ffff bcolor
	8 8 bat "Arena War" bprint2 

	war.draw
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	| ---- player control	
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 nand 'btnpad ! )
	>dn< =? ( btnpad %100 nand 'btnpad ! )
	>le< =? ( btnpad %10 nand 'btnpad ! )
	>ri< =? ( btnpad %1 nand 'btnpad ! )
	<esp> =? ( btnpad $10 or 'btnpad ! )
	
	<f1> =? ( war.+rtank )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"r3 robots" 1024 600 SDLinit
	bfont1
	
	"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	war.ini
	war.reset
	'runscr SDLshow
	SDLquit 
	;
