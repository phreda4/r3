| Peter Jakacki lift challenge forth2020 
| simple state machine. no up-dn diference
| PHREDA 2023

^r3/win/sdl2.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3
^r3/util/blist.r3
^r3/util/arr16.r3

#cntfloors 8	| cnt of floor

#delevator 1.0	| destination
#pelevator 1.0	| position
#velevator 0.01	| velocity 

#ylift 500	

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
	-1 'ylift +!
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
#per 0 0

#prevt
#dtime
#reloj

:time.start
	msec 'prevt ! 0 'dtime ! 
	0 'reloj ! ;

:time.delta
	msec dup prevt - 'dtime ! 'prevt ! 
	dtime 'reloj +! ;

:animcntm | cnt msec -- 0..cnt-1
	55 << 1 >>> 63 *>> ; | 55 speed
	
| guy
| 'vec time anim x y vx vy sprite	
|--

:guyload | v a -- v
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + 
	
	a@+ int. |-32 <? ( 3drop ; ) 	| X
	ylift
|	a@+ int. 						| y
|	a@+ a> 24 - +!	| vx
|	a@+ a> 24 - +!	| vy
	3 3 << a+
	rot 2.0 swap
	a@ sspritez		
	;	

:guywait | v a -- v
	>a
	a@ dup dtime + a!+ drop
	8 a+ |a@+ dup 16 >> swap $ffff and rot animcntm + 
	$9
	a@+ int. |-32 <? ( 3drop ; ) 	| X
	a@+ int. 						| y
|	a@+ a> 24 - +!	| vx
|	a@+ a> 24 - +!	| vy
	16 a+
	rot 2.0 swap
	a@ sspritez		
	;	
	
:guywalk | v a -- v
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + 
	
	a@+ int. 
		280 >? ( 'guywait pick3 ! ) 
		-32 <? ( 2drop 0 ; ) 	| X
	a@+ int. 						| y
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	rot 2.0 swap
	a@ sspritez		
	;	




#plist person1 person2 person3

:ntoy | n -- y
	70.0 * 46.0 + ;

:+guyin | n --
	'guywalk 'per p!+ >a 
	0 a!+		| tiempo
	$a0008 a!+	| animacion
	-16.0 a!+ dup ntoy a!+	| x y 
	1.0 a!+ 0.0 a!+					| vx vy
	3 randmax 3 << 'plist + @ @ a!+ | sprite
	a!+								| floor
	;

:+guyout | n --
	'guywalk 'per p!+ >a 
	0 a!+		| tiempo
	$10008 a!+	| animacion
	400.0 a!+ dup ntoy a!+	| x y 
	-1.0 a!+ 0.0 a!+				| vx vy
	3 randmax 3 << 'plist + @ @ a!+ | sprite
	a!+								| floor
	;
	
:+guywait | n --
	'guywalk 'per p!+ >a 
	0 a!+		| tiempo
	$90001 a!+	| animacion
	390.0 a!+ dup ntoy a!+	| x y 
	0.0 a!+ 0.0 a!+				| vx vy
	3 randmax 3 << 'plist + @ @ a!+ | sprite
	a!+								| floor
	;
	
:+guyload
	'guyload 'per p!+ >a 
	0 a!+		| tiempo
	$00001 a!+	| animacion
	400.0 a!+ |pelevator 
	cntfloors 16 << pelevator - ntoy
	a!+	| x y 
	0.0 a!+ 0.0 a!+				| vx vy
	3 randmax 3 << 'plist + @ @ a!+ | sprite
	a!+								| floor
	;

	
:animacion
	time.delta
	'per p.drawo
	4 'per p.sort
	;
	
|---  draw elevator	
:drawelevator
	$ff007f00 'immcolorbtn !
	600 4 40 66 immnowin
	cntfloors ( 1? 	
		4 $00007f0000ff checkbtn
		[ dup pushbtnf ; ]
		over "%d" sprint sprint immbtn 		
		imm<<dn
		1 - ) drop		
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
	
:drawbuiling
	$21B8B8 SDLColor
	0 0 300 560 SDLfrect
	560 ( 60 >? 
		$DEDEDE SDLColor
		0 over 300 10 SDLFRect
		$B8B8B8 SDLColor
		0 over 10 + 300 6 SDLFRect
		70 - ) drop

	
	$B8B8B8 SDLColor
	301 ylift 80 76 SDLFRect
	340 0 4 ylift SDLFRect
	
|	$FFB8DE SDLColor
|	301 ylift 80 70 SDLFRect

	$DEDEDE SDLColor
	301 ylift 60 + 80 10 SDLFRect
	;
	
|--- main loop	
:main
	0 SDLcls
	immgui
	
	drawbuiling
	
	$ffff0000 'immcolorbtn !
	sw 70 - 10 60 30 immnowin
	'exit "Exit" immbtn immdn
	
	drawfloors	
	drawelevator
	runelevator
	animacion
	
	10 480 780 40 immnoWin
	pelevator 16 >> "- %d -" sprint immLabelC immdn
	'strelevator state n>>0 immLabelC immdn
	
	SDLredraw 
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( 8 randmax +guyin )
	<f2> =? ( 8 randmax +guyout )
	<f3> =? ( 8 randmax +guywait )
	<f4> =? ( 8 randmax +guyload )	
	drop ;	

|----------- BOOT
:
	"Lift Challenge2" 800 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 22 immSDL
	16 32 "media/img/p1.png" ssload 'person1 !
	16 32 "media/img/p2.png" ssload 'person2 !
	16 32 "media/img/p3.png" ssload 'person3 !	
	200 'per p.ini
	
	'main SDLshow
	SDL_Quit 
	;	