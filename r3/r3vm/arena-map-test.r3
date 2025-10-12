| rcode - nivel 0
| basicos
| PHREDA 2024
|-------------------------
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
	
	draw.map

	$2 tcol 2.0 tsize 
	8 8 tat "Arena MAP " tprint
	0 ( 8 <? dup bot.check 8 >> "%h " tprint 1+ ) drop
	8 32 tat statemap "%d" tprint

	
	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	<up> =? ( 0 botstep )
	<dn> =? ( 4 botstep )
	<le> =? ( 6 botstep )
	<ri> =? ( 2 botstep )
|	<esp> =?  ( xp yp xytest )
	drop
	;

: |<<< BOOT <<<
	"r3mapa" 1024 600 SDLinit
	2.0 8 8 "media/img/atascii.png" tfnt 
	64 vaini
	edram
	ini.map
	
	"r3/r3vm/levels/levels.txt" loadlevel
	0 32 sw sh 32 - mapwin
	reset.map
	$10231 'tilewin !
	
	'main sdlShow 
	SDLquit 
	;
