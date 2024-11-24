| 2048 game
| PHREDA 2024
^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/ttfont.r3

#colors $afa192 $eee4da $ede0c8 $f2b179 $ffcea4 $e8c064 $ffab6e $fd9982 $ead79c $76daff $beeaa5 $d7d4f0
#map * 16 | 4 * 4 
#score
#moves

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
	rot 0? ( drop ; ) 
	-rot
	$000000 ttcolor
	postile	8 + swap 8 + swap ttat
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
	1 'moves +!
	( 16 randmax 'map + dup c@ 1? 2drop ) drop
	1 swap c! ;
	
#l0 0 #l1 0 #l2 0 0

:add
	1+ 1 over << 'score +! 	| ....
:down
	0 pick2 @ c! swap 8 + @ c! ;
	
:ck | adr -- 
	dup @ 
	c@ 0? ( 2drop ; )				| adr c1
	over 8 + @ 
	c@ 0? ( drop down ; ) 			| adr c1 c2
	=? ( add ; ) 2drop ;

:fall | delta ini --
	'l0 >a
	4 ( 1? swap 
		dup 'map + a!+
		pick2 + swap 1- ) 3drop 
	'l2 ck
	'l1 ck 'l2 ck
	'l0 ck 'l1 ck 'l2 ck
	;
	
:le	
	12 ( 16 <? 
		-4 over fall
		1+ ) drop 	
	newn ;
:ri
	0 ( 4 <? 
		4 over fall
		1+ ) drop 	
	newn ;
:dn	
	0 ( 16 <?
		1 over fall
		4 + ) drop
	newn ;
:up	
	3 ( 16 <?
		-1 over fall
		4 + ) drop
	newn ;

:reset
	'map 0 16 cfill 
	newn newn 
	0 'score !
	0 'moves !
	;
		
:play
	0 SDLcls
	$ffffff ttcolor
	360 10 ttat "2048" tt.
	10 20 ttat moves "Moves:%d" ttprint
	640 20 ttat score "Score:%d" ttprint
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
	'play sdlshow
	SDLquit 
	;
