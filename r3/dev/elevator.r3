^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/opengl/glgui.r3

#cntfloors 6

#delevator 5.0
#pelevator 1.0
#velevator 0.01
#state 3 | idle wait run open close broke

|--- buttons on floor
#floor * 32 | 32 floor max

:reset	'floor 0 32 cfill ;
	
:pushup	'floor + dup c@ 1 xor swap c! ; | f --
	
:pushdn	'floor + dup c@ 2 xor swap c! ; | f --

:light | f mask -- f color
	over 'floor + c@ and 
	0? ( drop $ff040404 ; ) drop $ff007f00 ;
	
	
:setdest | f --
	16 << dup 'delevator !
	pelevator <? ( drop -0.01 'velevator ! ; ) 
	drop 0.01 'velevator ! ;

|--- list for elevator
#flist * 32
#nlist

:addf | f --
	nlist 'flist + c!
	1 'nlist +! ;
	
:getf | -- f/0
	nlist 0? ( ; ) drop
	'flist dup c@
	swap dup 1 + nlist cmove
	-1 'nlist +! ;

:inlist? | f -- f/0
	'flist nlist ( 1? 1- swap
		c@+ pick3 =? ( 2drop ; )
		drop swap ) 
	3drop 0 ;

|--- list for floor
#bflist * 32
#bnlist 

:addbf
	bnlist 'bflist + c!
	1 'bnlist +! ;
	
:getbf | -- f/0
	bnlist 0? ( ; ) drop
	'bflist dup c@
	swap dup 1 + bnlist cmove
	-1 'bnlist +! ;

:inlistb? | f -- f/0
	'bflist bnlist ( 1? 1- swap
		c@+ pick3 =? ( 2drop ; )
		drop swap ) 
	3drop 0 ;

	
:debug
	'flist nlist ( 1? 1- swap
		c@+ "%d " .print
		swap ) 2drop
	.cr
	;

#door

|--- elevator state
:idle
	nlist 0? ( drop ; ) drop
	getf setdest
	2 'state ! | runing
	;
:wait
	nlist 0? ( drop ; ) drop
	4 'state !  | close
	;
:run
	velevator 'pelevator +!
	pelevator delevator - 
	$ffc00 and 1? ( drop ; ) drop
	0 'velevator ! 
	delevator 'pelevator ! 
	3 'state !	| open
	;
:open
	door
	0.9 >? ( 1 'state ! ) | wait
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
	$ff0f0fff glColor
	500 
	cntfloors 16 << pelevator - 40 *. 60 +
	60 40 frect
	$ff7f7fff glColor
	
	530 door 1 >> 29 *. -
	cntfloors 16 << pelevator - 40 *. 60 +
	door 29 *. 1 + 40 frect
	;
	
:main
	SDLGLcls 
	GLgui
	
	24.0 'glFontSize !
	
	$ffff0000 'guicolorbtn !
	sw 70 - 10 60 40 glwin
	'exit "Exit" gltbtn gldn
	
	$ff0000ff 'guicolorbtn !
	10 60 80 36 glwin
	cntfloors ( 1? 	
		100 glwidth
		dup "piso %d" sprint glLabel gl>>
		60 glwidth
		1 light 'guicolorbtn !
		[ dup pushup ; ] "up" sprint gltbtn 
		gl>>
		2 light 'guicolorbtn !
		[ dup pushdn ; ] "dn" sprint gltbtn 		
		gl<<dn
		1 - ) drop
		
	$ff007f00 'guicolorbtn !
	340 60 60 36 glwin
	cntfloors ( 1? 	
		[ dup addf ; ]
		over "%d" sprint sprint gltbtn 		
		gl<<dn
		1 - ) drop		

	drawelevator
	runelevator
	
	40.0 'glFontSize !
	10 480 780 40 glWin
	pelevator 16 >> "- %d -" sprint glLabelC gldn
	'strelevator state n>>0 glLabelC gldn
	
	
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( msec addf )
	<f2> =? ( getf drop )
	<f3> =? ( debug )
	drop ;	

|----------- BOOT
:
	"Elevator" 800 600 SDLinitGL
	
	GLFontIni
	"media/msdf/roboto-bold" glFontLoad

	'main SDLshow
	SDL_Quit 
	;	