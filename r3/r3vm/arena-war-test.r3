| arena war test
| PHREDA 2024
|-------------------------
^r3/lib/gui.r3
^r3/util/ttext.r3
^./arena-war.r3

	
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
	vupdate
	gui
	0 sdlcls
	
	pasto
	
	3.0 tsize
	$0 tcol 10 10 tat "Arena War" tprint
	$2 tcol 8 8 tat "Arena War" tprint

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
	
	|<f2> =? ( )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"r3 robots" 1024 600 SDLinit
	tini

	war.ini
	war.reset
	'runscr SDLshow
	SDLquit 
	;
