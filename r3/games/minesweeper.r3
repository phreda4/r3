| BUscaminas
| PHREDA 2023
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3

#sprites
#map * $ffff
#w 8 #h 8 #bombs 2
#sb 0	
#sumw
#state * 32

:]map | x y -- adr
	8 << + 'map + ;

:mrand | -- adr
	w randmax 1 + h randmax 1 + ]map ;
	
:makemap | --
	'map 20 $ffff cfill | clear all
	bombs ( 1? 1 -
		( mrand dup c@ 20 <>? 2drop ) drop | only empty
		21 swap c!
		) drop ;

:xymap | x y c -- x y c xs ys
	pick2 4 << 8 + pick2 4 << 8 + ;
	
:drawc	| x y c -- x y
	2dup ]map c@ xymap rot 1 >> sprites ssprite ;
	
:drawmap
	1 ( w <=? 1 ( h <=? drawc 1 + ) drop 1 + ) drop ;

:drawb	| x y c -- x y
	2dup ]map c@ 
	xymap rot 1 and 0? ( 3drop ; ) 
	8 + sprites ssprite ;
	
:drawmapr
	1 ( w <=? 1 ( h <=? drawb 1 + ) drop 1 + ) drop ;

:win?
	2dup ]map c@
	23 =? ( 1 'sumw +! )
	drop ;
	
:checkwin | -- 
	0 'sumw !
	1 ( w <=? 1 ( h <=? win? 1 + ) drop 1 + ) drop 
	sumw bombs <>? ( drop ; ) drop
	1 'sb ! "You WiN !" 'state strcpy
	;
	
:checkc | x y -- x y c
	0 >a
	-1 ( 1 <=? 
		-1 ( 1 <=? 
			pick3 pick2 + pick3 pick2 +
			]map c@ $1 and a+
			1 + ) drop
		1 + ) drop 
	a> ;
	
:marca | x y --
	]map dup c@ 
	20 <? ( 2drop ; )
	$2 xor swap c!
	checkwin ;
	
|----------- recursive (overflow if big)
:clearcell | x y --
	2dup ]map c@ 20 <>? ( 3drop ; ) drop
	checkc 1? ( 
		1 << -rot ]map c!
		; ) 
	pick2 pick2 ]map c!
	over 1 - 1 max over clearcell 
	over 1 + w min over clearcell
	over over 1 - 1 max clearcell
	1 + h min clearcell ;

|----------- list
#last>

:addcell | x y -- 
	2dup ]map c@ 20 <>? ( 3drop ; ) drop
	checkc 0? ( pick2 pick2 last> c!+ c!+ 'last> ! ) | expand if 0
	1 << -rot ]map c! 
	;
	
:markcell | x y --
	over 1 - 1 max over addcell
	over 1 + w min over addcell
	over over 1 - 1 max addcell
	1 + h min addcell ;
	
:clearcell | x y --
	here 'last> !
	addcell
	here ( last> <? 
		c@+ swap c@+ rot 
		markcell
		) drop ;
|-----------		

:click
	SDLx 4 >> -? ( drop ; ) w >? ( drop ; )
	SDLy 4 >> -? ( 2drop ; ) h >? ( 2drop ; )
	clkbtn 1 >? ( drop marca ; ) drop
	checkc 0? ( drop clearcell ; )
	-rot ]map 
	dup c@ $1 and 
	1? ( 1 'sb ! "You Loose !" 'state strcpy ) 
	rot 1 << or 
	swap c!	;

:showbomb?	
	sb 0? ( drop ; ) drop
	drawmapr ;

:reset1
	9 'w ! 9 'h ! 10 'bombs !
	makemap 0 'sb ! "" 'state strcpy ;
:reset2
	16 'w ! 16 'h ! 40 'bombs !
	makemap 0 'sb ! "" 'state strcpy ;
:reset3
	24 'w ! 24 'h ! 99 'bombs !
	makemap 0 'sb ! "" 'state strcpy ;
	
:game
	0 SDLcls
	immgui 0 0 sw sh guibox 
	drawmap
	showbomb?	
	'click onClick 
	200 28 immbox
	500 16 immat
	"Minesweeper" immlabelc		immdn
	'reset1 "Beginner" immbtn 	immdn
	'reset2 "Intermediate" immbtn 	immdn
	'reset3 "Advance" immbtn 		immdn 
	'state immlabelc			immdn
	'exit "Exit" immbtn 
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;

:	
	msec time rerand
	"Minesweeper" 800 600 SDLinit
	16 16 "media/img/mines.png" ssload 'sprites !
	"media/ttf/ProggyClean.ttf" 24 TTF_OpenFont immSDL
	reset1
	'game SDLshow
	SDLquit 
	;
