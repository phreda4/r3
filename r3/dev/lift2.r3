| Peter Jakacki lift challenge forth2020 
| simple state machine. no up-dn diference
| PHREDA 2023

^r3/win/sdl2.r3
^r3/util/sdlgui.r3

^r3/util/blist.r3

#cntfloors 8	| cnt of floor

#delevator 1.0	| destination
#pelevator 1.0	| position
#velevator 0.01	| velocity 

#state 3 | idle wait run open close broke

|--- buttons on floor
#floor * 32 	| 32 floor max

:reset	'floor 0 32 cfill ;

:touch | f mask -- f		
	over 'floor + dup c@ 
	rot xor swap c! ;

:floor@ | f -- f v
	dup 'floor + c@ ;

:offbtn | f --
	0 swap 'floor + c! ;
	
:checkbtn | f mask $c1c2 -- f color	; Color for button
	pick2 'floor + c@ rot and 
	0? ( swap 24 >> swap ) drop
	$ffffff and $ff000000 or 
	'immcolorbtn !
	;

:go | f --
	16 << dup 'delevator !
	pelevator <? ( drop -0.01 'velevator ! ; ) 
	drop 0.01 'velevator ! ;

#flist * 32 | list for elevator
#bflist * 32 | list for floor

|--- buttons
:pushup	| f --
	1 touch 
	floor@ 1 and? ( drop 'bflist blist! ; )
	drop 'bflist blist- ; 
	
:pushdn	| f --
	2 touch 
	floor@ 2 and? ( drop 'bflist blist! ; )
	drop 'bflist blist- ;

:pushbtnf | f --
	4 touch 
	floor@ 4 and? ( drop 'flist blist! ; )
	drop 'flist blist- ;
	
#door		| door position
#waitdoor 	| wait for buttons

|--- elevator state
:idle
	flist 1? ( drop 'flist blist@ go 2 'state ! ; ) drop | button in elevator
	bflist 1? ( drop 'bflist blist@ go 2 'state ! ; ) drop | button in floor
	;
:wait
	0.01 'waitdoor +! | count time
	waitdoor 0.5 <? ( drop ; ) drop | wait allways
	flist 1? ( 4 'state ! ) drop 	| close	if button in elevator
	waitdoor 2.0 <? ( drop ; ) drop	| wait for buton in elevator
	bflist 1? ( 4 'state ! ) drop 	| close	if button in floor
	;
:run
	velevator 'pelevator +! | velocity
	pelevator delevator - $ffc00 and | in floor? (adjust)
	1? ( drop ; ) drop 
	0 'velevator ! 
	delevator 'pelevator ! 
	3 'state !				| open
	delevator 16 >> offbtn	| turn off buttons
	;
:open
	door
	0.9 >? ( 1 'state ! 0 'waitdoor ! ) | wait
	0.01 + 'door !
	;
:close
	door 
	0.1 <? ( 0 'state ! 0 'door ! ) | idle
	0.01 - 'door !
	;
:broke
	;
	
#vstate 'idle 'wait 'run 'open 'close 'broke	

:runelevator
	state 3 << 'vstate + @ ex ;

#strelevator "idle" "wait" "run" "open" "close" "broke"
	
	
|---
#person1 #person2 #person3
	
|---  draw elevator	
:drawelevator
	$ff007f00 'immcolorbtn !
	340 60 60 36 immnowin
	cntfloors ( 1? 	
		4 $00007f0000ff checkbtn
		[ dup pushbtnf ; ]
		over "%d" sprint sprint immbtn 		
		imm<<dn
		1 - ) drop		

	$ff0f0fff SDLColor
	500 
	cntfloors 16 << pelevator - 40 *. 60 +
	60 40 SDLfrect
	$ff7f7fff SDLColor
	
	530 door 1 >> 29 *. -
	cntfloors 16 << pelevator - 40 *. 60 +
	door 29 *. 1 + 40 sdlfrect
	;

:drawfloors	
	$ff0000ff 'immcolorbtn !
	10 60 80 36 immnowin
	cntfloors ( 1? 	
		100 immwidth
		dup "floor %d " sprint immLabelR imm>>
		60 immwidth
		1 $040404007f00 checkbtn 
		[ dup pushup ; ] "up" sprint immbtn 
		imm>>
		2 $040404007f00 checkbtn
		[ dup pushdn ; ] "dn" sprint immbtn 		
		imm<<dn
		1 - ) drop ;
	
|--- main loop	
:main
	0 SDLcls
	immgui
	
	
	$ffff0000 'immcolorbtn !
	sw 70 - 10 60 40 immnowin
	'exit "Exit" immbtn immdn
	
	drawfloors	
	drawelevator
	runelevator
	
	10 480 780 40 immnoWin
	pelevator 16 >> "- %d -" sprint immLabelC immdn
	'strelevator state n>>0 immLabelC immdn
	
	SDLredraw 
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	

|----------- BOOT
:
	"Lift Challenge2" 800 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 22 immSDL
	16 32 "media/img/p1.png" ssload 'person1 !
	16 32 "media/img/p2.png" ssload 'person2 !
	16 32 "media/img/p3.png" ssload 'person3 !	
	'main SDLshow
	SDL_Quit 
	;	