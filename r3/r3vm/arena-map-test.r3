| rcode - nivel 0
| basicos
| PHREDA 2024
|-------------------------
^r3/lib/trace.r3

^r3/lib/gui.r3
^r3/util/ttext.r3

^./arena-map.r3
	
|----- move view
#xo #yo

:dns
	sdlx 'xo ! sdly 'yo ! ;

:mos
	sdlx xo - 'viewpx +! 
	sdly yo - 'viewpy +! 
	dns ;

::mouseview
	'dns 'mos onDnMove 
	SDLw 0? ( drop ; )
	0.1 * viewpz +
	0.2 max 6.0 min 'viewpz !
	;
	
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
	map.step

	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	<up> =? ( 0 botstep )
	<dn> =? ( 4 botstep )
	<le> =? ( 6 botstep )
	<ri> =? ( 2 botstep )
	drop
	;

: |<<< BOOT <<<
	"r3mapa" 1024 600 SDLinit
	2.0 8 8 "media/img/atascii.png" tfnt 
	
	"r3/r3vm/levels/level0.txt" loadlevel
	
	64 vaini
	edram
	bot.ini	

	100 'viewpx !
	50 'viewpy !
	3.0 'viewpz !
	resetplayer
	
	'main sdlShow 
	SDLquit 
	;
