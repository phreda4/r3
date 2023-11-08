| Peter Jakacki lift challenge forth2020 
| simple state machine. no up-dn diference
| PHREDA 2023

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/util/blist.r3

^r3/opengl/glgui.r3

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
	'guicolorbtn !
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
	
|---  draw elevator	
:drawelevator
	$ff007f00 'guicolorbtn !
	340 60 60 36 glnowin
	cntfloors ( 1? 	
		4 $00007f0000ff checkbtn
		[ dup pushbtnf ; ]
		over "%d" sprint sprint gltbtn 		
		gl<<dn
		1 - ) drop		

	$ff0f0fff glColor
	500 
	cntfloors 16 << pelevator - 40 *. 60 +
	60 40 frect
	$ff7f7fff glColor
	
	530 door 1 >> 29 *. -
	cntfloors 16 << pelevator - 40 *. 60 +
	door 29 *. 1 + 40 frect
	;

:drawfloors	
	$ff0000ff 'guicolorbtn !
	10 60 80 36 glnowin
	cntfloors ( 1? 	
		100 glwidth
		dup "floor %d " sprint glLabelR gl>>
		60 glwidth
		1 $040404007f00 checkbtn 
		[ dup pushup ; ] "up" sprint gltbtn 
		gl>>
		2 $040404007f00 checkbtn
		[ dup pushdn ; ] "dn" sprint gltbtn 		
		gl<<dn
		1 - ) drop ;
	
|--- main loop	
:main
	SDLGLcls 
	GLgui
	
	24.0 'glFontSize !
	
	$ffff0000 'guicolorbtn !
	sw 70 - 10 60 40 glnowin
	'exit "Exit" gltbtn gldn
	
	drawfloors	
	drawelevator
	runelevator
	
	40.0 'glFontSize !
	10 480 780 40 glnoWin
	pelevator 16 >> "- %d -" sprint glLabelC gldn
	'strelevator state n>>0 glLabelC gldn
	
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	

|----------- BOOT
:
	"Lift Challenge" 800 600 SDLinitGL
	
	GLFontIni
	"media/msdf/roboto-bold" glFontLoad

	'main SDLshow
	SDL_Quit 
	;	