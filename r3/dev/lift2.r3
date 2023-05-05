| Peter Jakacki lift challenge forth2020 
| simple state machine. no up-dn diference
| PHREDA 2023

^r3/win/sdl2.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3
^r3/util/dlist.r3
^r3/util/arr16.r3

#cntfloors	8	| cnt of floor

#maxcapacity	3	| elevator capacity
#capacity		0	| elevator capacity
#pinasc * 80	| 10 max

|#delevator 1.0	| destination
|#pelevator 1.0	| position
|#velevator 0.1	| velocity 

#nowelevator 0 
#toelevator 0

#yelev 500.0
#ytoelev 500.0	
#vyelev 0

#state 3 | idle wait run open close broke

| guy
|		0	1	2	3	4	5	6	7		8
| 'vec time anim x 	y 	vx 	vy 	spr to|fr 	sta
|--

| queue for every floor
#plist 

:plistini | listmax --
	here dup dup 'plist !
	cntfloors 4 << + 'here ! 
	cntfloors ( 1? swap
		pick2 over dc.ini
		16 + swap 1 - ) 3drop ;

:plistn | n -- adr
	4 << plist + ;

	
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
	drop 'frow dc@- ; 
	
:pushdn	| f --
	2 touch 
	floor@ 2 and? ( drop 'frow dc! ; )
	drop 'frow dc@-	;

:pushbtnf | f --
	4 touch 
	floor@ 4 and? ( drop 'erow dc! ; )
	drop 'erow dc@- ;

	
#door		| door position
#waitdoor 	| wait for buttons

:loadpeople
	nowelevator plistn
	dc? 0? ( drop ; ) 
	nowelevator plistn dc@- 
	2 over 8 3 << + ! | in asc
	$00001 over 1 3 << + ! 
	320.0 rot 3 << + over 2 3 << + !
	dup nowelevator 3 << 'pinasc + !
	1 'nowelevator +!
	7 3 << + @ 8 >> pushbtnf
	0 'waitdoor ! 
	;

:gto@
	7 3 << + @ 8 >> $ff and ;

:donwpeople | 
	|"%d" .println
	-8 a+
	a@ 
	$10008 over 1 3 << + ! 
	-5.0 over 4 3 << + !
	0 over 8 3 << + ! | in asc	
	drop
	a> dup 8 + swap capacity move
	-1 'capacity +!
	;
	
:downpeople	
	'pinasc >a
	0 ( over <?
		a@+ gto@ nowelevator =? ( donwpeople ) drop
		) drop  ;
	
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
	capacity 
	1? ( downpeople )				| any for donwload
	maxcapacity <? ( loadpeople ) 	| any for load
	drop

	0.1 'waitdoor +! | count time
	waitdoor 1.0 <? ( drop ; ) drop | wait allways
	'erow dc? 1? ( 4 'state ! ) drop 	| close	if button in elevator
	waitdoor 2.0 <? ( drop ; ) drop	| wait for buton in elevator
	'frow dc? 1? ( 4 'state ! ) drop 	| close	if button in floor
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

#prevt
#dtime

:time.start		msec 'prevt ! 0 'dtime ! ;
:time.delta		msec dup prevt - 'dtime ! 'prevt ! ;

| anim $0ini0cnt (16.16)
:nanim | time namin -- n
	dup 16 >> swap $ffff and rot |  add cnt msec
	55 << 1 >>> 63 *>> + ; | 55 speed


:gstate! | ad xx state --
	pick2 8 3 << + ! ;
:gvelx! | ad xx v --
	pick2 4 3 << + ! ;
:ganim! | ad xx ani --
	pick2 1 3 << + ! ;
	
:gfloor@
	7 3 << + @ $ff and ;
:gto@
	7 3 << + @ 8 >> $ff and ;
	
:gcntfloor | ad -- cnt
	7 3 << + @ $ff and plistn dc? ;

:pushud | from to
	<? ( dup pushup ; )
	dup pushdn ;
	
:gpushbutton | ad --
	dup 7 3 << + @
	dup $ff and swap 8 >>  | a from to
	pushud			| push up or down
	plistn dc! 		| add to row
	;

|-- states	
:gwalk
	dup 
	2 3 << + @ int. 
	over gcntfloor 4 << neg
	280 +
	>? (
		1 gstate! 			| wait
		0 gvelx! 			| stop x
		$90001 ganim! 		| anim stop
		over gpushbutton 
		) 
	-32 <? ( 2drop 0 ; ) | delete
	drop
	;

:gwait
	;
	
:glift
	yelev 38.0 + 
	over 3 3 << + !
	;
	
	
#guystate gwalk gwait glift gwalk

:guydraw | v -- 
	dup 8 3 << + @ $3 and 3 << 'guystate + @ ex
	0? ( ; )
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
	randto 8 << or	a!+								| floor
	;

|:+guyout | n --
|	$10008 a!+	| animacion
|	400.0 a!+ dup ntoy a!+	| x y 
	
:animacion
	time.delta
	'per p.drawo
	4 'per p.sort
	;
	
|---  draw elevator	
:drawelevator
	$ff007f00 'immcolorbtn !
	600 4 40 36 immnowin
	cntfloors ( 1? 1 -	
		4 $00007f0000ff checkbtn
		[ dup pushbtnf ; ]
		over "%d" sprint sprint immbtn 		
		imm<<dn
		) drop		
	;

:drawfloors	
	$ff0000ff 'immcolorbtn !
	400 4 40 36 immnowin
	cntfloors ( 1? 1 -
		40 immwidth
		dup "%d " sprint immLabelR imm>>
		40 immwidth
		1 $040404007f00 checkbtn 
		[ dup pushup ; ] "up" sprint immbtn 
		imm>>
		2 $040404007f00 checkbtn
		[ dup pushdn ; ] "dn" sprint immbtn 		
		imm>>
		dup dup plistn dc? "%d %d" sprint immLabel

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
	yelev ytoelev vyelev "%f %f %f" sprint immLabelC immdn
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
	"media/ttf/Roboto-Medium.ttf" 22 immSDL
	16 32 "media/img/p1.png" ssload 'person1 !
	16 32 "media/img/p2.png" ssload 'person2 !
	16 32 "media/img/p3.png" ssload 'person3 !	
	
	200 'per p.ini
	32 plistini
	100 'erow dc.ini
	100 'frow dc.ini
	0 entoy 'yelev !
	
	'main SDLshow
	SDL_Quit 
	;	