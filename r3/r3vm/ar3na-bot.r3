| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/util/sdlgui.r3
^r3/util/sdlbgui.r3
^r3/util/varanim.r3

^./arena-map.r3


|-------------------
#xo #yo

:dns
	sdlx 'xo ! sdly 'yo ! ;

:mos
	sdlx xo - 'viewpx +! 
	sdly yo - 'viewpy +! 
	dns ;

:mouse
	'dns 'mos onDnMove 
	SDLw 0? ( drop ; )
	0.1 * viewpz +
	0.2 max 6.0 min 'viewpz !
	;
	
	
#map * $ffff | 256x256
#mapcx 128 #mapcy 128
#maptx 32 #mapty 32

#mapsx	512 #mapsy 300

|-------------------
#lerror

:immex	
|	r3reset
|	'pad r3i2token drop 'lerror !
	0 'pad !
	refreshfoco
|	code> ( icode> <? 
	| vmcheck
|		vmstep ) drop
	;
	
:showstack
	8 532 bat
	" " bprint2
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ "%d " bprint2 
		) 2drop 
	TOS "%d " bprint2
	;
	
:showinput
	$7f00007f sdlcolorA	| cursor
	0 500 1024 600 SDLfRect
	$ff0000 bcolor
	0 502 bat ":" bprint2
	16 500 immat 1000 32 immbox
	'pad 128 immInputLine2	
	;		


|-------------------
:runscr
	vupdate
	immgui
	mouse
	timer.
	0 sdlcls
	
	$ffff bcolor 8 8 bat "Ar3na Bot" bprint2 bcr2
	|$ffffff bcolor viewpz viewpy viewpx "%d %d %f" bprint2

	$ffffff sdlcolor
	draw.map
	player
		
	showinput
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<ret> =? ( immex )
	
	|----
|	<f1> =? ( changemodo )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	64 vaini
	bfont1

	
	|"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	bot.ini
	bot.reset
	|fillmap
	
	'runscr SDLshow
	SDLquit 
	;
