| floodit ! 
| PHREDA 2023
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3

#map * $ffff
#w 8 #h 8 
#turn 0
#state * 32

:]map | x y -- adr
	w * + 'map + ;

:makemap | --
	'map w h * ( 1? 1 - 
		6 randmax rot c!+
		swap ) 2drop ;

:xymap | x y -- x y xs ys
	over 4 << 8 + over 4 << 8 + ;
	
#colors $ff0000 $ff00 $ff $ffff00 $ffff $ff00ff

:drawc	| x y -- x y
	2dup ]map c@ 3 << 'colors + @ SDLColor
	xymap 16 dup SDLFRect ;
	
:drawmap
	0 ( w <? 0 ( h <? drawc 1 + ) drop 1 + ) drop ;

:mapwin? | -- 0/1
	'map c@+ swap 
	w h * 1 - over + swap 
	( over <? 
		c@+ pick3 <>? ( 4drop 0 ; ) drop
		) 3drop 1 ; 

#colnow
#colold

|----------- fill
#last>

:addcell | x y -- 
	swap 0 <? ( 2drop ; ) w >=? ( 2drop ; ) 
	swap 0 <? ( 2drop ; ) h >=? ( 2drop ; )
	2dup ]map c@ colold <>? ( 3drop ; ) drop
	2dup last> c!+ c!+ 'last> !
	]map colnow swap c! ;
	
:markcell | x y --
	over 1 - over addcell
	over 1 + over addcell
	over over 1 - addcell
	1 + addcell ;

:fillcol | x y --
	2dup ]map c@ colnow =? ( 3drop ; )
	'colold !
	here 'last> !
	addcell
	here ( last> <? 
		c@+ swap c@+ rot markcell
		) drop ;
		
|-----------		
:reset	'h ! 'w ! makemap  0 'turn ! "" 'state strcpy ;
:reset1 10 10 reset ;
:reset2 20 20 reset ;
:reset3 30 30 reset ;

:floodit | color --
	'colnow ! 
	0 0 fillcol 
	1 'turn +!
	mapwin? 1? ( "Win !" 'state strcpy ) 
	drop ;
	
:game
	0 SDLcls
	immgui 	
	drawmap

	32 32 immbox
	16 500 immat
	'colors 0 ( 6 <? 
		swap @+ 'immcolorbtn !
		swap [ dup floodit ; ] "" immbtn imm>>
		1 + ) 2drop
		
	$ff 'immcolorbtn !
	200 28 immbox
	500 16 immat
	"Floodit !" immlabelc		immdn
	'reset1 "Beginner" immbtn 	immdn
	'reset2 "Intermediate" immbtn 	immdn
	'reset3 "Advance" immbtn 		immdn 
	'state immlabelc			immdn
	turn "turn:%d" sprint immlabelc immdn
	'exit "Exit" immbtn 
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;

:	
	msec time rerand
	"Floodit!" 800 600 SDLinit
	"media/ttf/ProggyClean.TTF" 24 TTF_OpenFont immSDL
	reset1
	'game SDLshow
	SDLquit 
	;
