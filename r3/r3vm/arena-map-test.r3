| rcode - nivel 0
| basicos
| PHREDA 2024
|-------------------------
^r3/util/sdlbgui.r3
^r3/r3vm/arena-map.r3
	
|-----------------------------	
:main
	vupdate
	0 sdlcls 
	immgui
	
	$ffff bcolor
	8 8 bat "Arena MAP" bprint2 
	
	200 64 mapdraw
	player

	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	<up> =? ( iup )
	<dn> =? ( idn )
	<le> =? ( ile )
	<ri> =? ( iri )
	drop
	;

: |<<< BOOT <<<
	"r3mapa" 1024 600 SDLinit
	bfont1
	64 vaini
	arena.ini	
	resetplayer
	
	'main sdlShow 
	SDLquit 
	;
