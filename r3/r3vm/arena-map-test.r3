| rcode - nivel 0
| basicos
| PHREDA 2024
|-------------------------
^r3/lib/gui.r3
^r3/util/ttext.r3
^./arena-map.r3
	
|-----------------------------	
:main
	vupdate
	0 sdlcls 
	gui
	mouseview
	$1 tcol 2.0 tsize 
	8 8 tat "Arena MAP" tprint
	
	draw.map
	draw.items
	draw.player

	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	<up> =? ( 0 botstep )
	<dn> =? ( 4 botstep )
	<le> =? ( 6 botstep )
	<ri> =? ( 2 botstep )
	<f1> =? ( xp yp checkitem "%d" .println )
	drop
	;

: |<<< BOOT <<<
	"r3mapa" 1024 600 SDLinit
	"r3/r3vm/levels/level0.txt" loadmap
	
	tini
	64 vaini
	bot.ini	
	100 'viewpx !
	50 'viewpy !
	3.0 'viewpz !
	resetplayer
	
	'main sdlShow 
	SDLquit 
	;
