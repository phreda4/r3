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
	mouseview
	$ffff bcolor
	8 8 bat "Arena MAP" bprint2 
	
	draw.map
	player

	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	<up> =? ( 0 botstep )
	<dn> =? ( 4 botstep  )
	<le> =? ( 6 botstep  )
	<ri> =? ( 2 botstep  )
	drop
	;

: |<<< BOOT <<<
	"r3mapa" 1024 600 SDLinit
	bfont1
	64 vaini
	bot.ini	
	resetplayer
	
	'main sdlShow 
	SDLquit 
	;
