| Peter Jakacki lift challenge forth2020 
| simple state machine. no up-dn diference
| PHREDA 2023

^r3/win/sdl2.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3
^r3/util/dlist.r3
^r3/util/arr16.r3

|.... time control
#prevt
#dtime

:time.start		msec 'prevt ! 0 'dtime ! ;
:time.delta		msec dup prevt - 'dtime ! 'prevt ! ;


#cntfloors	8	| cnt of floor

#maxcapacity	3	| elevator capacity
#capacity		0	| elevator capacity
#pinasc * 80	| 10 max

#nowelevator 0 
#toelevator 0

#yelev 500.0
#ytoelev 500.0	
#vyelev 0

#state 3 | idle wait run open close broke

|--- buttons on floor
#floor * 32 	| 32 floor max

:reset	'floor 0 32 cfill ;

:touch | f mask -- f		
	over 'floor + dup c@ 
	rot or swap c! ; | mark always

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

:entoy | n -- y
	-70.0 * 500.0 + ;

:go | f --
	dup 'toelevator !
	entoy dup 'ytoelev !
	yelev <? ( drop -2.0 'vyelev ! ; ) 
	drop 2.0 'vyelev ! ;

| queue for Elevator and wait in Floor
#erow 0 0 
#frow 0 0 

|--- buttons
:pushup	| f --
	1 touch 
	floor@ 1 and? ( drop 'frow dc! ; )
	2drop ; 
	
:pushdn	| f --
	2 touch 
	floor@ 2 and? ( drop 'frow dc! ; )
	2drop ;

:pushbtnf | f --
	4 touch 
	floor@ 4 and? ( drop 'erow dc! ; )
	2drop ;
	
#door		| door position
#waitdoor 	| wait for buttons

| guy
|		0	1	2	3	4	5	6	7		8
| 'vec time anim x 	y 	vx 	vy 	spr to|fr 	sta
|--

|--- elevator state
:idle
	'erow dc?
	1? ( drop 
		'erow dc@- go 
		2 'state ! ; ) drop | button in elevator
	'frow dc?
	1? ( drop 
		'frow dc@- go 
		2 'state ! ; ) drop | button in floor
	;
	
:wait
	0.1 'waitdoor +! | count time
	waitdoor 1.0 <? ( drop ; ) drop | wait allways
	'erow dc? 1? ( 4 'state ! ) drop 	| close	if button in elevator
	waitdoor 2.0 <? ( drop ; ) drop	| wait for buton in elevator
	'frow dc? 1? ( 4 'state ! ) drop 	| close	if button in floor
	nowelevator offbtn	
	;
	
:run
	vyelev 'yelev +! 
	yelev ytoelev - $ffffc00 and
	1? ( drop ; ) drop
	0 'vyelev !
	ytoelev 'yelev !
	3 'state !				| open
	toelevator offbtn	| turn off buttons
	toelevator 'nowelevator !
	;
:open
	door
	0.9 >? ( 1 'state ! 0 'waitdoor ! ) | wait
	0.1 + 'door !
	;
:close
	door 
	0.1 <? ( 0 'state ! 0 'door ! ) | idle
	0.1 - 'door !
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

| anim $0ini0cnt (16.16)
:nanim | time namin -- n
	dup 16 >> swap $ffff and rot |  add cnt msec
	55 << 1 >>> 63 *>> + ; | 55 speed

:gpushbutton | ad --
	7 3 << + @
	dup $ff and swap 8 >>  | a from to
	<? ( pushup ; ) pushdn ;

|-- states	
:gcntfloor | ad -- cnt
	7 3 << + @ $ff and  ; | queue len

:gwalk | adr -- adr
	dup 2 3 << + @ int. | pos x
	over gcntfloor 4 << neg 280 +
	>? (
		1 pick2 8 3 << + ! 		| wait
		0 pick2 4 3 << + ! 		| stop x
		$90001 pick2 1 3 << + !	| anim stop
		over gpushbutton 
		) 
	drop
	;
|...........

:gfrom@
	7 3 << + @ $ff and ;
	
:loadpeople
|	nowelevator plistn dc@- 
	2 over 8 3 << + ! | in asc
	$00001 over 1 3 << + ! 
	320.0 rot 3 << + over 2 3 << + !
|	dup capacity 3 << 'pinasc + !
	1 'capacity +!
	7 3 << + @ 8 >> pushbtnf
	0 'waitdoor ! 
	;

:gwait | adr -- adr
|	dup gfrom@ nowelevator =? ( loadpeople ) drop
	;

|...........

:gto@
	7 3 << + @ 8 >> $ff and ;

:exitpeople | 
	-8 a+ a@ 
	$10008 over 1 3 << + ! 	| anim
	-5.0 over 4 3 << + !	| vx
	3 over 8 3 << + !		| run 
	drop
	a> dup 8 + capacity move
	-1 'capacity +!
	0 'waitdoor ! 
	;
	
:gINelevator | adr -- adr
	yelev 38.0 + 
	over 3 3 << + !
	
|	dup gto@ nowelevator =? ( exitpeople ) drop
	
	;

|...........	
:gwalkout | adr -- adr
	dup 
	2 3 << + @ int. 
	-32 <? ( drop 0 ; ) | delete
	drop
	;
	
	
#guystate gwalk gwait gInelevator gwalkout

:guydraw | v -- 
	dup 8 3 << + @ $3 and 3 << 'guystate + @ ex
	0? ( nip ; )
	>a
	a@ dup dtime + a!+ | time
	a@+ nanim | nsprite
	a@+ int. a@+ int.  | x y
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	rot 2.0 swap a@ sspritez
	;
	
|---------------------------------
#plist person1 person2 person3

| floor to y coord
:ntoy | n -- y
	-70.0 * 534.0 + 
	7.0 randmax 1.0 - + | rand y
	;

| chose the destination floor
:randto | from -- from to
	( cntfloors randmax over =? drop ) ;
	
:+guy | n --
	'guydraw 'per p!+ >a 
	0 a!+		| tiempo
	$a0008 a!+	| animacion
	-16.0 a!+ dup ntoy a!+	| x y 
	5.0 a!+ 0.0 a!+					| vx vy
	3 randmax 3 << 'plist + @ @ a!+ | sprite
	randto 8 << or	a!+				| floor
	0 a!+							| walk in
	;

:animacion
	time.delta
	'per p.drawo
	|4 'per p.sort
	;
	
|---  draw elevator	
:drawelevator
	$ff007f00 'immcolorbtn !
	600 4 40 26 immnowin
	cntfloors ( 1? 1 -	
		4 $00007f0000ff checkbtn
		[ dup pushbtnf ; ]
		over "%d" sprint sprint immbtn 		
		imm<<dn
		) drop		
	;

:drawfloors	
	$ff0000ff 'immcolorbtn !
	400 4 40 26 immnowin
	cntfloors ( 1? 1 -
		40 immwidth
		dup "%d " sprint immLabelR imm>>
		30 immwidth
		1 $040404007f00 checkbtn 
		[ dup pushup ; ] "u" sprint immbtn 
		imm>>
		2 $040404007f00 checkbtn
		[ dup pushdn ; ] "d" sprint immbtn 		
		imm>>
|		dup plistn dc? "%d" sprint immLabel

		imm<<dn
		) drop ;
	
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
	301 yelev 16 >> 80 76 SDLFRect
	340 0 4 yelev 16 >> SDLFRect
	
|	$FFB8DE SDLColor
|	301 yelev 16 >> 80 70 SDLFRect

	$DEDEDE SDLColor
	301 yelev 16 >> 60 + 80 10 SDLFRect
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
	|pelevator 16 >> "- %d -" sprint immLabelC immdn
	yelev ytoelev vyelev "%f %f %f" sprint immLabelR immdn
	capacity toelevator nowelevator "%d %d %d" sprint immLabelR immdn
	'strelevator state n>>0 immLabelC immdn
	
	SDLredraw 
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( 8 randmax +guy )
	<f2> =? ( 0 +guy )
	<f3> =? ( 1 +guy )
	<f4> =? ( 2 +guy )	
	drop ;	

|----------- BOOT
:
	"Lift Challenge2" 800 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 20 immSDL
	16 32 "media/img/p1.png" ssload 'person1 !
	16 32 "media/img/p2.png" ssload 'person2 !
	16 32 "media/img/p3.png" ssload 'person3 !	
	time.start
	
	200 'per p.ini
	100 'erow dc.ini
	100 'frow dc.ini
	0 entoy 'yelev !
	
	'main SDLshow
	SDL_Quit 
	;	