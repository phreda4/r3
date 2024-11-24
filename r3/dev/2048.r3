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
	rot
	0? ( drop ; ) 
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
	
	
|---- v 0	
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

:up	1 0 fall newn ;
:dn	-1 0 fall newn ;
:le	0 1 fall newn ;
:ri	0 -1 fall newn ;

|-----------------------------------
#line 0 0 0 0

:]line | n -- adr
	3 << 'line + @ ;
	
:ldn | v n --
	3 << 'line + @+ 0 swap c! @ c! ;

:l+ | v n -- v
	1 pick2 1+ << 'score +!
	3 << 'line + @+ 0 swap c! @ over 1+ swap c! ;
	
:ck2
	2 ]line c@ 0? ( drop ; )
	3 ]line c@ 0? ( drop 2 ldn ; ) 
	=? ( 2 l+ ) drop ;
	
:ck1
	1 ]line c@ 0? ( drop ; )
	2 ]line c@ 0? ( drop 1 ldn ; )
	=? ( 1 l+ ) drop ;
	
:ck0
	0 ]line c@ 0? ( drop ; )
	1 ]line c@ 0? ( drop 0 ldn ; )
	=? ( 0 l+ ) drop ;	
	

:fall | delta ini --
	'line >a
	4 ( 1? swap 
		dup 'map + a!+
		pick2 + swap 1- ) 3drop 
	ck2 
	ck1 ck2 
	ck0 ck1 ck2
	;
	
:le	
	12 ( 16 <? 
		-4 over lcopy
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
