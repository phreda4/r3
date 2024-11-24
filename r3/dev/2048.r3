| 2048 game
| PHREDA 2024
^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/ttfont.r3

#colors $afa192 $eee4da $ede0c8 $f2b179 $ffcea4 $e8c064 $ffab6e $fd9982 $ead79c $76daff $beeaa5 $d7d4f0

#map * 16 | 4 * 4 

:]map | x y -- adr
	2 << + 'map + ;
	
:postile | x y -- x y xs ys
	over 6 << 800 4 6 << - 2/ 1+ +
	over 6 << 600 4 6 << - 2/ 1+ +
	;
	
:tile | x y -- x y 
	ca@+ dup 3 << 'colors + @ sdlColor
	-rot
	postile 62 dup SDLFrect
	rot
	0? ( drop ; ) 
	-rot
	$AFA192 ttcolor
	postile	ttat
	rot 1 swap << "%d" ttprint
	;
	
:drawmap
	'map >a
	0 ( 4 <?
		0 ( 4 <?
			tile
			1+ ) drop
		1+ ) drop ;

:newn
	( 16 randmax 'map + dup c@ 1? 2drop ) drop
	1 swap c! ;
	
#mx 1 #my 0
#another

:check | x y -- x y 
	2dup ]map c@ 1? ( drop ; ) drop
	over mx + -? ( drop ; ) 3 >? ( drop ; )
	over my + -? ( 2drop ; ) 3 >? ( 2drop ; )
	]map dup c@ 0? ( 2drop ; ) 
	pick3 pick3 ]map c!
	0 swap c!
	1 'another !	
	;

:fall | mx my --
	'my ! 'mx !  
:rfall	
	0 'another !
	0 ( 4 <?
		0 ( 4 <?
			check
			1+ ) drop
		1+ ) drop 
	another 1? ( drop rfall ; ) drop ;

:checksum
	2dup ]map c@ 0? ( drop ; )
	
	over mx +
	over my +
	]map dup c@ 0? ( 2drop ;
	;
	
:sum
	0 ( 4 <?
		0 ( 4 <?
			checksum
			1+ ) drop
		1+ ) drop ;
	
:up
	1 0 fall
	newn ;
	
:dn
	-1 0 fall
	newn ;
:le
	0 1 fall
	newn ;
:ri
	0 -1 fall
	newn ;
	
:reset
	'map 0 16 cfill 
	newn newn ;
		
:jugar
	0 SDLcls
	$ffffff ttcolor
	360 10 ttat "2048" tt.
	drawmap
	sdlredraw
	sdlkey 
	>esc< =? ( exit )
	<up> =? ( up )
	<dn> =? ( dn )
	<le> =? ( le )
	<ri> =? ( ri )
	drop
	;
	
:
	"2048" 800 600 SDLinit
	SDLrenderer 800 600 SDL_RenderSetLogicalSize | fullscreen
	
	"media/ttf/Roboto-Medium.ttf" 24 ttf_OpenFont ttfont!
	reset
	'jugar sdlshow
	SDLquit 
	;
