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

:touch | f mask -- f
	over 'floor + dup c@ 
	rot xor swap c! ;

:floor@ | f -- f v
	dup 'floor + c@ ;
	
:checkbtn | f mask $c1c2 -- f color
	pick2 'floor + c@ rot and 
	0? ( swap 24 >> swap ) drop
	$ffffff and $ff000000 or 
	'guicolorbtn !
	;

:go | f --
	16 << dup 'delevator !
	pelevator <? ( drop -0.01 'velevator ! ; ) 
	drop 0.01 'velevator ! ;

|---------------------------
:listdel | 'list 'from --
	dup 1 + pick2 @ cmove
	-1 swap +! ;

:list! | f 'list --
	1 over +! @+ + 1 - c! ;
	
:list- | f 'list
	swap over @+ | 'adr cnt
	( 1? 1- swap
		c@+ pick3 
		=? ( drop nip nip swap listdel ; )
		drop swap ) 
	4drop ;
		
:list@ | 'list -- f/0
	dup @ 0? ( nip ; ) drop
	dup c@
	swap 8 + dup listdel ;
	
:list? | f 'list -- f/0
	@+ ( 1? 1- swap
		c@+ pick3 =? ( 2drop ; )
		drop swap ) 
	3drop 0 ;
	
#testlist 0 * 32
	
|--- list for elevator
#flist * 32
#nlist

:addf | f --
	nlist 'flist + c!
	1 'nlist +! ;
	
:delf | f --
	'flist nlist ( 1? 1- swap
		c@+ pick3 =? ( drop 1 - dup 1 + nlist cmove 2drop -1 'nlist +! ; )
		drop swap ) 3drop ;
	
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

:addbf | f --
	bnlist 'bflist + c!
	1 'bnlist +! ;

:delbf | f --
	'bflist bnlist ( 1? 1- swap
		c@+ pick3 =? ( drop 1 - dup 1 + bnlist cmove 2drop -1 'nlist +! ; )
		drop swap ) 3drop ;
	
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


|--- buttons
:pushup	| f --
	1 touch 
	floor@ 1 and? ( drop addbf ; )
	drop delbf 
	; 
	
:pushdn	| f --
	2 touch 
	floor@ 2 and? ( drop addbf ; )
	drop delbf ;

:pushbtnf | f --
	4 touch 
	floor@ 4 and? ( drop addf ; )
	drop delf ;
	
:offbtn | f --
	0 swap 'floor + c!
	;
	
#door

|--- elevator state
:idle
	nlist 1? ( drop getf go 2 'state ! ; ) drop | runing
	bnlist 1? ( drop getbf go 2 'state ! ; ) drop | runing
	;
	
:wait
	nlist 1? ( 4 'state ! ) drop | close
	bnlist 1? ( 4 'state ! ) drop | close	
	;
:run
	velevator 'pelevator +!
	pelevator delevator - 
	$ffc00 and 1? ( drop ; ) drop
	0 'velevator ! 
	delevator 'pelevator ! 
	3 'state !	| open
	delevator 16 >> offbtn
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
	
|--- main loop	
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
		1 $040404007f00 checkbtn 
		[ dup pushup ; ] "up" sprint gltbtn 
		gl>>
		2 $040404007f00 checkbtn
		[ dup pushdn ; ] "dn" sprint gltbtn 		
		gl<<dn
		1 - ) drop
		
	$ff007f00 'guicolorbtn !
	340 60 60 36 glwin
	cntfloors ( 1? 	
		4 $00007f0000ff checkbtn
		[ dup pushbtnf ; ]
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
	drop ;	

|----------- BOOT
:
	"Elevator" 800 600 SDLinitGL
	
	GLFontIni
	"media/msdf/roboto-bold" glFontLoad

	'main SDLshow
	SDL_Quit 
	;	