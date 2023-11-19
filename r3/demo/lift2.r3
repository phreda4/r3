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


#debugmode 0
#automode 0

#cntfloors	8	| cnt of floor

#maxcapacity	3	| elevator capacity
#capacity		0	| elevator capacity

#nowelevator 0 
#toelevator 0

#yelev 500.0
#ytoelev 500.0	
#vyelev 0

#state 3 | idle wait run open close broke

#floor * 32 	| buttons in floor 

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

| guy
|		0	1	2	3	4	5	6	7			8
| 'vec time anim x 	y 	vx 	vy 	spr q|to|fr 	sta
|--
:g>a! 1 3 << + ! ;
:g>x 2 3 << + ;
:g>xy 2 3 << + @+ int. swap @ int. ;
:g>vx 4 3 << + ;
:g>f 7 3 << + ;
:g>s! 8 3 << + ! ;

#queuef * 32	| queue in floors, cnt of guys in queue

:gcntfloor | ad -- cnt
	g>f @ $ff and 'queuef + c@ ; | queue len

:gqueue+ | ad --
	g>f dup @ $ff and 'queuef + 1 over +! 
	c@ 1 - 16 << swap +! ;

:entoy | n -- y
	-70.0 * 500.0 + ;

:go | f --
	nowelevator =? ( drop ; )
	dup 'toelevator !
	entoy dup 'ytoelev !
	yelev <? ( drop -2.0 'vyelev ! ; ) 
	drop 2.0 'vyelev ! ;

| queue for Elevator and wait in Floor
#erow 0 0 

|--- buttons
:pushup	| f --
	floor@ 1 and? ( 2drop ; ) drop
	1 touch drop ; 
	
:pushdn	| f --
	floor@ 2 and? ( 2drop ; ) drop
	2 touch drop ; 

:pushbtnf | f --
	floor@ 4 and? ( 2drop ; ) drop
	4 touch 
	'erow dc! ;
	
#door		| door position
#waitdoor 	| wait for buttons

|... choose near floor call
:this? | min minvalue floor button -- min minvalue floor
	$3 and 0? ( drop ; ) drop
	nowelevator =? ( ; )
	nowelevator over - abs 
	pick2 >? ( drop ; ) 
	2swap 2drop over ;
	
:searchfloor
	-1 cntfloors | min minvalue
	dup ( 1? 1 -
		floor@ this? 
		) 2drop ;
	
|.... elevator states 
:idle
	'erow dc?
	1? ( drop 
		'erow dc@- go 
		2 'state ! ; ) drop | button in elevator
		
	| search for the close floor
	searchfloor -? ( drop ; ) go 
	2 'state !
	;
:wait
	0.1 'waitdoor +! | count time
	waitdoor 1.0 <? ( drop ; ) drop | wait allways
	'erow dc? 1? ( 4 'state ! ) drop 	| close	if button in elevator
	waitdoor 2.0 <? ( drop ; ) drop	| wait for buton in elevator
	searchfloor 0 >? ( 4 'state ! ) drop
|	nowelevator offbtn	
	;
:run
	vyelev 'yelev +! 
	yelev ytoelev - 1? ( drop ; ) drop
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
	
|------ persons -------
#person1 #person2 #person3
#per 0 0

|.... stat
#statcnt
#statsum

:gpushbutton | ad --
	g>f @ dup $ff and swap 8 >> $ff and  | a from to
	<? ( pushup ; ) pushdn ;

|........... walking to exit
:guyout | adr -- adr
	dup g>x @ int. 
	-32 <? ( drop dup @ 'statsum +! 1 'statcnt +! 0 ; ) | delete
	drop
	;

|........... in elevator
:guyinasc | adr -- adr
	yelev 38.0 + over 3 3 << + !
	dup g>f @ 8 >> $ff and		| destination floor
	nowelevator <>? ( drop ; ) drop
	| exit guy from elevator
	$10008 over g>a! 	| anim
	-5.0 over g>vx !	| vx
	'guyout over g>s!	| walk to exit
	-1 'capacity +!
	0 'waitdoor ! 
	;

|........... advance in queue
:advanceq
	dup 8 3 << + @ $ff and nowelevator <>? ( drop ; ) drop
	dup 8 3 << + dup @ 
	dup 16 >> 1 - -? ( 3drop ; ) 	| no negative
|	0? ( pick4 gpushbutton ) | push button
	16 << swap $ffff and or swap !	| advance in row
	dup 8 3 << + @ 16 >> 8.0 * neg 280.0 +
	over 3 3 << + !					| move coord x
	;

:gqueue- | ad --
	g>f @ $ff and 'queuef + -1 swap +! 
	'advanceq 'per p.mapv 
	'queuef nowelevator + c@ 0? ( drop nowelevator offbtn ; ) drop
	nowelevator 1 touch drop 
	;
	
|........... waint in 	
:guywait | adr -- adr
	dup g>f @ 
	$ffff00ff and nowelevator <>? ( drop ; ) drop | not in elevator and in place 0
	state 1 <>? ( drop ; ) drop				| elevator is waiting
	capacity maxcapacity >=? ( drop ; ) drop | capacity?
	| load guy to elevator
	'guyinasc over g>s! | now in elevator
	$00001 over g>a! 	| animation
	320.0 capacity 8.0 * + over g>x !	| position
	dup g>f @ 8 >> $ff and pushbtnf		| push button
	dup gqueue-
	1 'capacity +!
	0 'waitdoor ! 
	;

|........... walking to elevator
:guyin | adr -- adr
	dup g>x @ int. | pos x
	over gcntfloor 3 << neg 280 +
	<? ( drop ; ) drop 
	| put the guy waiting
	'guywait over g>s! 		| wait
	0 over g>vx ! 		| stop x
	$90001 over g>a!	| anim stop
	dup gpushbutton 
	dup gqueue+
	;

	
:dbg | adr dbg - adr dbg
	$ffffff ttcolor
	over g>xy 40 - ttat
	over g>f @ 16 >> "%d" sprint ttprint
	;
	
| anim $0ini0cnt (16.16)
:nanim | time namin -- n
	dup 16 >> swap $ffff and rot |  add cnt msec
	55 << 1 >>> 63 *>> + ; | 55 speed
	
:guydraw | v -- 
	dup 8 3 << + @ ex 0? ( nip ; )	| execute the state
	debugmode 1? ( dbg ) drop
	>a
	a@ dup dtime + a!+ 	| time
	a@+ nanim			| nsprite
	a@+ int. a@+ int.	| x y
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
	randto 8 << or a!+				| floor
	'guyin a!+						| state
	;

|---  draw elevator	
:buttonfloorcolor
	ca@+
	$3 and? ( drop		| active?
		msec $100 and? ( $ffffff nip ; ) | blink
		$ff0000 nip ; )					
	$0 nip ; 
	
:drawbuiling
	$21B8B8 SDLColor
	0 0 300 560 SDLfrect
	'floor >a
	560 ( 60 >? 
		$DEDEDE SDLColor
		0 over 300 10 SDLFRect
		$B8B8B8 SDLColor
		0 over 10 + 300 6 SDLFRect
		buttonfloorcolor SDLColor
		294 over 26 - 4 4 SDLFRect
		70 - ) drop

	$B8B8B8 SDLColor
	301 yelev 16 >> 80 76 SDLFRect
	340 0 4 yelev 16 >> SDLFRect
	
	$DEDEDE SDLColor
	301 yelev 16 >> 60 + 80 10 SDLFRect
	;
	
|--- gui	
#win1 1 [ 400 4 300 500 ] "Lift Challenger"
#interv	2000
#sec 	

:guiwindow
	'win1 immwin 0? ( drop ; ) drop

	94 immwidth
	imm>> imm>> $ffff0000 'immcolorbtn !
	'exit "exit" immbtn 
	immcr
	
	cntfloors ( 1? 1 -
		40 immwidth
		dup "%d " sprint immLabelR imm>>
		30 immwidth
		1 $040404007f00 checkbtn [ dup pushup ; ] "u" sprint immbtn imm>>
		2 $040404007f00 checkbtn [ dup pushdn ; ] "d" sprint immbtn imm>> 
		|dup 'queuef + c@ "%d" sprint immLabel imm>>
		40 immwidth
		4 $00007f0000ff checkbtn [ dup pushbtnf ; ] over "%d" sprint sprint immbtn 		
		immcr
		) drop 	
	
	290 immwidth
	'strelevator state n>>0 immLabelC
	immcr
	statcnt " cnt: %d" sprint immLabel immdn
	statsum statcnt 0? ( 1 + ) | avoid 0/
	/ " media: %d ms" sprint immLabel immdn
	immdn
	'automode " Automatic (ms)" immCheck immdn	
	500 5000 'interv  immSlideri immdn
	'debugmode " Debug" immCheck immdn	
	debugmode 1? ( 
|		yelev ytoelev vyelev "%f %f %f" sprint immLabelR immdn
		capacity toelevator nowelevator "ne:%d te:%d capacity:%d" sprint immLabelR immdn
		) drop
	immdn
	;
	
:automatic
	automode 0? ( drop ; ) drop
	sec dtime +
	interv <? ( 'sec ! ; ) drop
	0 'sec !
	8 randmax +guy
	;
		
|--- main loop	
:main
	0 SDLcls
	immgui		| ini IMMGUI
	drawbuiling
	runelevator
	time.delta		| calc time 
	'per p.drawoo	| draw sprites
	4 'per p.sort	| sort for draw
	guiwindow		| GUI
	SDLredraw 
	
	automatic
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( 8 randmax +guy )
	<f2> =? ( msec time rerand )
	drop ;	

|----------- BOOT
:
	"Lift Challenge" 800 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 18 TTF_OpenFont immSDL
	16 32 "media/img/p1.png" ssload 'person1 !
	16 32 "media/img/p2.png" ssload 'person2 !
	16 32 "media/img/p3.png" ssload 'person3 !	
	time.start
	
	200 'per p.ini
	100 'erow dc.ini
	0 entoy 'yelev !
	
	'main SDLshow
	SDL_Quit 
	;	