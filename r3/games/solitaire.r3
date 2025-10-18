| Solitaire
| PHREDA 2025
^r3/lib/rand.r3
^r3/util/immi.r3

#font
#sprites

| 64bytes every stack
#deck * 64
#foundation * 256 | 64 * 4 fundations
#table * 448 | 64 * 7 tables
#stock * 64
#waste * 64

#dragp * 64	| stack for drag

#xc #yc #nc -1

:inipiles
	'deck 0 64 15 * cfill 
	'deck 1+ >a
	0 ( 52 <? dup $80 or ca!+ 1+ ) drop
	52 'deck c! ;

:chg | a b -- 
	over c@ over c@ | a b a@ b@
	swap rot c! 	| a b@
	swap c! ;
		
:shuffle
	'deck 1+ >a
	0 ( 52 <?
		dup randmax | n rand
		a> + over a> + chg
		1+ ) drop ;

:]table | n -- adr
	64 * 'table + ;

:]foundation | n -- adr
	64 * 'foundation + ;

|--- stack of cards (until 127 places)
:pushc	| n 'adr --
	dup -rot c@+ + c! 1 swap c+! ;
	
:popc | 'adr -- n 
	-1 over c+! c@+ + c@ ;
	
:getc | 'adr -- n
	c@+ 1- + c@ ;	

:getcnt | 'adr -- cnt
	c@ ;
	
|-------
:face
	$80 and? ( 6 >> $1 and 52 + ; )
	$3f and ;

:xyndrawcardz | x y zoom n --
	face sprites sspritez ;

:xyndrawcard | x y n --
	$40 and? ( 3drop ; )  | hide, need exist for drag
	face sprites ssprite ;

|-------
:dealCards
	inipiles
	shuffle
	0 ( 7 <?
		0 ( over <=? | tab cnt
			'deck popc
			pick2 ]table pushc
			1+ ) drop
		dup ]table dup popc $80 xor swap pushc 
		1+ ) drop
	'deck
	( dup c@ 1? drop
		dup popc
		'stock pushc 
		) 2drop ;
	
|-------
:drawpile | x y 'pila --
	ab[ >a
	ca@+ ( 1? 	| x y M 
		ca@+  
		pick3 int. pick3 int. rot xyndrawcard
		swap 0.5 + swap
		1- ) 3drop 
	]ba ;

|----
:onFoundation? | nfund -- 0=ok
	]foundation dup c@ 0? ( 2drop nc 13 mod ; ) drop
	getc 13 /mod | suit nro
	nc 13 /mod	| suit nro
	rot 1+ <>? ( 3drop -1 ; ) drop
	<>? ( drop -1 ; ) drop 0 ;
	
| suit 0-n 1-r 2-r 3-n
:onTable? | n -- 0/1
	]table dup c@ 0? ( 2drop nc 13 mod 12 - ; ) drop
	getc -? ( ; ) 
	13 /mod
	nc 13 /mod | suit nro suit nro
	rot 1- <>? ( 3drop -1 ; ) drop
	1+ swap 1+ xor $2 and $2 xor 
	; | 1+ -> %1x red, %0x black

::drawpiledrag | x y --
	ab[
	'dragp >a
	ca@+ ( 1? 	| x y M 
		ca@+  
		pick3 pick3 rot 1.2 swap xyndrawcardz
		swap 18 + swap
		1- ) 3drop 	
	]ba ;

|--------------------	
:resetgame
	inipiles 
	shuffle 
	dealCards ;

:backstock
	'waste c@ ( 1?
		'waste popc $80 or 'stock pushc
		1- ) drop ;
		
:clkstock
	'stock getcnt 0? ( drop backstock ; ) drop
	'stock popc $80 nand | flip
	'waste pushc ;

|---- drag
:drgclear
	0 'dragp c! -1 'nc ! ;
	
:drgmove
	sdlx 'xc ! sdly 'yc ! ;
	
:dwnWaste	
	'waste getcnt 0? ( drop ; ) drop
	'waste popc dup 'nc !
	'dragp pushc
	drgMove ;
	
:backtowaste
	nc 'waste pushc 
	drgClear ;
	
:tofund | n --
	dup onFoundation? 1? ( 2drop backtowaste ; ) drop
	]foundation nc swap pushc
	drgClear ;
	
:upWaste	
	mdrag 
	-? ( drop backtowaste ; ) 
	4 <? ( tofund ; )
	4 - | table
	dup onTable? 1? ( 2drop backtoWaste ; ) drop
	]table nc swap pushc
	drgClear ;

|---- table
#ntable
#ftable | from
#dtable | destanation

:dwnTable | cnt card -- cnt cart ; cnt=0 top
	-? ( ; )
	over 'dragp c!
	'dragp 1+ ntable c@+ + pick3 - pick3 cmove  | dsc
	
	ntable c@+ + pick2 - 
	pick2 ( 1? swap dup c@ $40 or swap c!+ swap 1- ) 2drop | mark hide
	
	ntable 'ftable ! | src
	ntable 'dtable ! | des
	'dragp 1+ c@ 'nc ! 
	drgmove 
	;

:backpile | cnt card -- cnt cart
	'dragp c@ | cnt
	dup neg ftable c+!
	dtable c@+ + 'dragp 1+ pick2 cmove
	dtable c+!
	drgClear ;
	
:dwnFund | cnt card -- cnt cart
	'dragp c@ 1 >? ( drop backpile ; ) drop
	'dragp popc 
	dup onFoundation? 1? ( 2drop backpile ; ) drop
	]foundation nc swap pushc
	drgClear ;
	
:upTable | cnt card -- cnt cart
	mdrag -? ( drop backpile ; ) 
	4 <? ( drop dwnFund ; ) 
	4 - 
	dup onTable? 1? ( 2drop backpile ; ) drop
	]table 'dtable !
	backpile ;
	
:ckTable | cnt card -- cnt cart
	over 1 <>? ( drop ; ) drop
	ntable
	dup getc +? ( 2drop ; ) drop
	dup popc $80 xor swap pushc ;
	
:drawpilemouse | x y 'pila --
	dup 'ntable !
	ab[ >a
	ca@+ ( 1? 	| x y M 
		ca@+  
		pick3 int. 25 - pick3 int. 40 - 50 80 uiBox uiUser
		'ckTable uiClk
		'upTable uiUp
		'drgmove uiSel
		'dwnTable uiDwn 
		pick3 int. pick3 int. rot xyndrawcard
		swap 18.0 + swap
		1- ) 3drop 
	]ba ;	
	
:game
	uiStart
	$6600 SDLcls
	$ffffff txrgb 10 4 txat "R3 Solitaire" txprint
	
	$3f00 sdlcolor
	55 40 50 80 uiBox uiUser 8 uiRFill 
	'clkstock uiClk
	80.0 80.0 'stock drawpile

	135 40 50 80 uiBox uiUser 8 uiRFill
	'dwnWaste uiDwn 
	'drgmove uiSel
	'upWaste uiUp
	160.0 80.0 'waste drawpile
	
	0 ( 4 <?
		dup over 100 * 325 + 40 50 80 uiBox uiUser uiPlace 8 uiRFill		
		dup 100.0 * 350.0 + | X
		80.0 | Y
		pick2 ]foundation drawpile
		1+ ) drop
	0 ( 7 <?
		dup 4 + over 100 * 75 + 160 50 400 uiBox uiUser uiPlace |8 miRfill
		dup 100.0 * 100.0 +  | X
		200.0 |y
		pick2 ]table drawpilemouse
		1+ ) drop 

	nc +? ( xc yc drawpiledrag ) drop

	SDLredraw
	SDLkey 
	>esc< =? ( exit )
	drop ;
	
:	|<<<<<<<<<<<<<<<<<<
	"Solitaire" 800 600 SDLinit
	50 80 "media/img/cards.png" ssload 'sprites !
	"media/ttf/roboto-bold.ttf" 24 txload dup txfont 'font !
	resetgame
	'game SDLshow
	SDLquit 
	;
