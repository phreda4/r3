| 2048 game
| PHREDA 2024
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/immi.r3

#colors $afa192 $eee4da $ede0c8 $f2b179 $ffcea4 $e8c064 $ffab6e $fd9982 $ead79c $76daff $beeaa5 $d7d4f0
#map * 16 | 4 * 4 
#score
#moves
#state * 32

:win
	"Win !" 'state strcpy ;
	
:postile | x y -- x y xs ys
	over 6 << 500 4 6 << - 2/ 1+ +
	over 6 << 600 4 6 << - 2/ 1+ +
	;
	
:tile | x y -- x y 
	ca@+ dup 3 << 'colors + @ sdlColor
	-rot
	postile 62 dup SDLFrect
	rot 0? ( drop ; ) 
	-rot
	$000000 txrgb
	postile	8 + swap 8 + swap txat
	rot 1 swap << "%d" txprint
	;
	
:drawmap
	'map >a
	0 ( 4 <?
		0 ( 4 <?
			tile
			1+ ) drop
		1+ ) drop ;

:newn
	state 1? ( drop ; ) drop
	1 'moves +!
	( 16 randmax 'map + dup c@ 1? 2drop ) drop | search a random place
	1 swap c! 
	'map ( 'score <?
		c@+ 0? ( 2drop ; ) drop		| any empty place?
		) drop 
	"Lose !" 'state strcpy 
	;
	
#l0 0 #l1 0 #l2 0 0

:add | adr c1 --
	1+ 1 over << 'score +! 	
	11 =? ( win )
	0 				| ....
:down | adr c1 c2 --
	pick2 @ c! swap 8 + @ c! ;
	
:ck | adr -- 
	dup @ 
	c@ 0? ( 2drop ; )		| adr c1
	over 8 + @ 
	c@ 0? ( down ; ) 		| adr c1 c2
	=? ( add ; ) 
	2drop ;

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
	0 'state ! newn newn 
	0 'score ! 0 'moves ! 
	;
		
:play
	0 sdlcls
	drawmap

	uiStart
	8 4 uiPading
	
	0.2 %w uiE
	$ffffff txrgb
	ui..
	"* 2048 *" uiLabelC
	ui..
	moves "Moves:%d" sprint uiLabel
	score "Score:%d" sprint uiLabel
	ui..
	'state uiLabelC
	ui..
	'reset "New Game" uiRbtn
	'exit "Exit" uiRbtn	
	uiEnd
	
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
	"media/ttf/Roboto-Medium.ttf" 24 txload txfont
	reset
	'play sdlshow
	SDLquit 
	;
