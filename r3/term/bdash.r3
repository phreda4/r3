| Boulder Dash minimal
|
^r3/lib/console.r3
^r3/lib/rand.r3
^r3/lib/math.r3

#STAGE 0 #WALL 1 #EARTH 2 #PLAYER 3 #ROCK1 4 #ROCK2 5 #GEM 6 #DOOR 7 #ENEMY 8
#DDUP 1 #DRI 2 #DDN 3 #DLE 4
#MINGEMS 5 #MINROCKS 10

#curmap * $fff

#mapWidth 0 #mapHeight 0
#currentLevel 1 #currentScore 0 #remainingLives 3 #timeBonus 0
#playerX 0 #playerY 0
#enemyX 0 #enemyY 0 #enemyDirX 0 #enemyDirY 0 #enemySteps 0
#enemyTick 0 #enemyTickRate 8
#gemCounter 0 #totalGems 0 #totalRocks 0 #doorPlaced 0
#timeLeft 0 #lastSecondTimer 0
#playerDead 0 #flagRestart 0 #playerMoved 0 #exitRequested 0
#earthRatio 0 #rockRatio 0 #gemRatio 0
#anymoved 0
#msgline * 40

#gx #gy #ctile #cbelow #nx #sd
#pplaced
#espawned
#dx #dy #newx #newy #target #beyondx

#OX 4 #OY 4

:cur@ | x y -- t
	mapWidth * + 'curmap + c@ ;
	
:cur! | x y t --
	-rot mapWidth * + 'curmap + c! ;

:eq? | a b -- flag
	=? ( drop 1 ; )
	drop 0 ;

:fallable? | t -- flag
	ROCK1 =? ( drop 1 ; )
	ROCK2 =? ( drop 1 ; )
	GEM =? ( drop 1 ; )
	drop 0 ;

:tile-open? | t -- flag
	STAGE =? ( drop 1 ; )
	EARTH =? ( drop 1 ; )
	drop 0 ;

:tile-blocks-below? | t -- flag
	WALL =? ( drop 1 ; )
	ROCK1 =? ( drop 1 ; )
	ROCK2 =? ( drop 1 ; )
	drop 0 ;

:enemy-walkable? | t -- flag
	STAGE =? ( drop 1 ; )
	PLAYER =? ( drop 1 ; )
	drop 0 ;

:tilechar | t --
	WALL   =? ( drop 8   .fc "█" .write .Reset ; )
	EARTH  =? ( drop 94  .fc "░" .write .Reset ; )
	PLAYER =? ( drop 226 .fc "@" .write .Reset ; )
	ROCK1  =? ( drop 250 .fc "o" .write .Reset ; )
	ROCK2  =? ( drop 250 .fc "o" .write .Reset ; )
	GEM    =? ( drop 51  .fc "*" .write .Reset ; )
	DOOR   =? ( drop 46  .fc "D" .write .Reset ; )
	ENEMY  =? ( drop 196 .fc "X" .write .Reset ; )
	drop " " .write ;

:cellat | x y --
	OY + swap OX + swap .at ;

:draw-cell | x y -- x y
	2dup cur@ 'ctile !
	2dup cellat
	ctile tilechar ;

:draw-map
	0 ( mapWidth <?
		0 ( mapHeight <?
			draw-cell
		1+ ) drop
	1+ ) drop ;

:draw-hud
	4 1 .at .Bold
	remainingLives totalGems gemCounter currentScore currentLevel
	"Level %d  Score %d  Gems %d/%d  Lives %d" .print .Reset .eline .cr
	4 2 .at timeLeft " TIME: %d " .print .eline .cr
	4 3 .at 'msgline .write .eline .cr ;

:draw-all
	.home
	draw-hud
	draw-map
	.flush ;

|===== level parameters =====
:level-params
	8 currentLevel - 'enemyTickRate !
	currentLevel 
	1 =? ( drop
		40 'mapWidth ! 28 'mapHeight !
		11 randmax 45 + 'earthRatio !
		4 randmax 3 + 'rockRatio !
		3 randmax 3 + 'gemRatio !
		; )
	2 =? ( drop
		42 'mapWidth ! 28 'mapHeight !
		6 randmax 45 + 'earthRatio !
		4 randmax 7 + 'rockRatio !
		3 randmax 3 + 'gemRatio !
		; )
	3 =? ( drop
		44 'mapWidth ! 28 'mapHeight !
		6 randmax 40 + 'earthRatio !
		4 randmax 12 + 'rockRatio !
		3 randmax 6 + 'gemRatio !
		; )
	4 =? ( drop
		48 'mapWidth ! 28 'mapHeight !
		6 randmax 35 + 'earthRatio !
		4 randmax 15 + 'rockRatio !
		3 randmax 8 + 'gemRatio !
		; ) 
	drop
	50 'mapWidth ! 28 'mapHeight !
	6 randmax 45 + 'earthRatio !
	3 randmax 1+ 'rockRatio !
	4 randmax 9 + 'gemRatio ! ;

:create-map
	'curmap 0 mapWidth mapHeight * cfill
	0 ( mapWidth <?
		dup 0 WALL cur!
		dup mapHeight 1- WALL cur!
	1+ ) drop
	0 ( mapHeight <?
		0 over WALL cur!
		mapWidth 1- over WALL cur!
	1+ ) drop ;

:randomize-cell | x y -- x y
	100 randmax 
	earthRatio <? ( drop 2dup EARTH cur! ; )
	earthRatio rockRatio + <? ( drop
		1 'totalRocks +!
		2 randmax 0? ( drop 2dup ROCK1 cur! ; ) drop
		2dup ROCK2 cur! ; )
	earthRatio rockRatio + gemRatio + <? ( drop
		1 'totalGems +!
		2dup GEM cur! ; ) 
	drop
	2dup STAGE cur! ;

:randomize-pass
	0 'totalGems ! 0 'totalRocks !
	1 ( mapWidth 1- <?
		1 ( mapHeight 1- <?
			randomize-cell
		1+ ) drop
	1+ ) drop ;

:randxy
	1 mapWidth 2 - randminmax 
	1 mapHeight 2 - randminmax ;

:ensure-min-gems
	totalGems ( MINGEMS <?
		( randxy 2dup cur@ tile-open? 0? drop ) drop
		GEM cur!
		1+ ) drop ;

:ensure-min-rocks
	totalRocks ( MINROCKS <?
		( randxy 2dup cur@ tile-open? 0? drop ) drop
		ROCK1 
		2 randmax 0? ( 2drop ROCK2 dup ) drop
		cur!
		1+ ) drop ; 

:randomize-map
	randomize-pass
	ensure-min-gems
	ensure-min-rocks ;

:place-player
	0 'pplaced !
	2000 ( 1? 1-
		pplaced 0? ( 
			randxy
			2dup cur@ tile-open?
			pick2 pick2 1- cur@ EARTH eq? and
			pick2 pick2 1+ cur@ tile-blocks-below? 0 eq? and
			1? ( 
				pick2 'playerX ! over 'playerY !
				pick2 pick2 PLAYER cur!
				1 'pplaced !
			) 3drop
		) drop
	) drop
	pplaced 0? ( 
		1 'playerX ! 1 'playerY !
		1 1 PLAYER cur!
	) drop ;

:place-door
	( randxy 2dup cur@ tile-open? 0? drop ) drop
	DOOR cur!
	"FIND THE DOOR" 'msgline strcpy ;

:spawn-enemy
	0 'espawned !
	200 ( 1? 1-
		espawned 0? (
			randxy
			2dup cur@ STAGE =? (
				pick2 'enemyX ! over 'enemyY !
				pick2 pick2 ENEMY cur!
				1 'espawned !
			) 3drop
		) drop
	) drop ;

:check-crush | x y --
	swap 0 <? ( 2drop ; ) mapWidth >=? ( 2drop ; )  
	swap 0 <? ( 2drop ; ) mapHeight >=? ( 2drop ; )  
	cur@ PLAYER =? ( drop 1 'playerDead ! ; ) drop ;

:try-slide | d --
	gx + 'nx !
	nx 
	0 <? ( drop ; ) 
	mapWidth >=? ( drop ; ) 
	drop
	nx gy cur@ STAGE <>? ( drop ; ) drop
	nx gy 1+ cur@ STAGE <>? ( drop ; ) drop
	nx gy 2 + check-crush
	nx gy 1+ ctile cur!
	gx gy STAGE cur!
	1 'anymoved ! ;

:gravity-cell | x y -- x y
	2dup 'gy ! 'gx !
	gx gy cur@ 'ctile !
	ctile fallable? 0? ( drop ; ) drop
	gx gy 1+ cur@ 'cbelow !
	cbelow STAGE =? ( drop
		gx gy 2 + check-crush
		gx gy 1+ ctile cur!
		gx gy STAGE cur!
		1 'anymoved ! ; ) drop
	cbelow fallable? 0? ( drop ; ) drop
	-1 try-slide
	1 try-slide ;

:gravity-row | y --
	'gy !
	0 ( mapWidth <?
		dup gy gravity-cell 2drop
	1+ ) drop ;

:gravity-scan
	mapHeight 1- ( 1? dup gravity-row 1- ) drop ;

:apply-gravity
	gravity-scan ;

:try-push
	dy 1? ( drop ; ) drop
	newx dx + 'beyondx !
	beyondx 
	0 <? ( drop ; ) 
	mapWidth >=? ( drop ; ) 
	drop
	beyondx newy cur@ STAGE <>? ( drop ; ) drop
	beyondx newy target cur!
	newx newy PLAYER cur!
	playerX playerY STAGE cur!
	newx 'playerX !
	newy 'playerY !
	1 'playerMoved ! ;

:handle-open-move
	target 
	GEM =? ( 100 'currentScore +! 1 'gemCounter +! ) 
	EARTH =? ( 1 'currentScore +! )
	DOOR =? ( drop
		timeLeft 'timeBonus !
		currentLevel 1+ 5 >? ( drop 1 ) 'currentLevel !
		1 'flagRestart !
		; ) drop
	newx newy PLAYER cur!
	playerX playerY STAGE cur!
	newx 'playerX !
	newy 'playerY !
	1 'playerMoved ! ;

:move-player | dx dy --
	'dy ! 'dx !
	playerX dx + 'newx !
	playerY dy + 'newy !
	newx 0 <? ( drop ; ) mapWidth >=? ( drop ; ) drop
	newy 0 <? ( drop ; ) mapHeight >=? ( drop ; ) drop
	newx newy cur@ 'target !
	target tile-open? 1? ( drop handle-open-move ; ) drop
	target 
	DOOR =? ( drop handle-open-move ; ) 
	GEM =? ( drop handle-open-move ; )
	ROCK1 =? ( drop try-push ; )
	ROCK2 =? ( drop try-push ; ) 
	drop
	;

:move-enemy
	1 'enemyTick +!
	enemyTick enemyTickRate <? ( drop ; ) drop
	0 'enemyTick !
	enemySteps 0 <=? ( 
		4 randmax 
		0 =? ( -1 'enemyDirX ! 0 'enemyDirY ! ) 
		1 =? ( 1 'enemyDirX ! 0 'enemyDirY ! ) 
		2 =? ( 0 'enemyDirX ! -1 'enemyDirY ! ) 
		3 =? ( 0 'enemyDirX ! 1 'enemyDirY ! )
		drop
		3 randmax 2 + 'enemySteps !
		) drop
	enemyX enemyDirX + 
	1 <? ( drop 0 'enemySteps ! ; ) 
	mapWidth >=? ( drop 0 'enemySteps ! ; ) 
	
	enemyY enemyDirY + 
	1 <? ( 2drop 0 'enemySteps ! ; ) 
	mapHeight >=? ( 2drop 0 'enemySteps ! ; ) 

	2dup cur@ enemy-walkable? 0? ( 3drop 0 'enemySteps ! ; ) drop
	playerY =? ( swap playerX =? ( 2drop 1 'playerDead ! ; ) swap ) 
	enemyX enemyY STAGE cur!
	2dup ENEMY cur!
	'enemyY ! 'enemyX !
	-1 'enemySteps +! ;

:update-timer
	msec lastSecondTimer - 1000 <? ( drop ; ) drop
	msec 'lastSecondTimer !
	timeLeft 1- 
	1 <? ( 1 'playerDead ! )
	'timeLeft ! ;

:process-death
	playerX playerY cellat 196 .fc "X" .write .Reset .flush
	200 ms ;

:check-win
	"LEVEL COMPLETE" 'msgline strcpy
	draw-all
	400 ms ;

:wait-space
	( getch
		[ESC] =? ( drop 1 'exitRequested ! ; )
		32 <>? drop
	) drop ;

:game-over-sequence
	.cls
	4 3 .at .Bold "G A M E   O V E R" .println .Reset
	currentScore " score: %d" .println
	" Press SPACE to restart" .println .flush
	wait-space
	1 'currentLevel !
	0 'currentScore !
	3 'remainingLives !
	0 'timeBonus ! ;

:setup-level
	0 'playerMoved ! 0 'gemCounter ! 0 'doorPlaced !
	0 'timeLeft ! 0 'enemyTick ! 0 'enemyDirX ! 0 'enemyDirY ! 0 'enemySteps !
	0 'playerDead ! 0 'flagRestart !
	msec 'lastSecondTimer !
	"" 'msgline strcpy

	level-params
	create-map
	randomize-map

	spawn-enemy
	place-player

	timeBonus 200 + 'timeLeft !

	apply-gravity
	draw-all ;

:handle-death
	process-death
	-1 'remainingLives +!
	remainingLives 0 <=? ( game-over-sequence ) drop
	setup-level ;

:handle-input
	inkey
	[LE] =? ( -1 0 move-player )
	[UP] =? ( 0 -1 move-player )
	[RI] =? ( 1 0 move-player )
	[DN] =? ( 0 1 move-player )
	[ESC] =? ( 1 'exitRequested ! )
	drop ;

:game-loop
	handle-input
	exitRequested 1? ( drop ; ) drop
	playerMoved 1? ( 1 'anymoved ! 0 'playerMoved ! ) drop
	anymoved 1? ( 0 'anymoved ! apply-gravity ) drop
	gemCounter 
	totalGems =? (
		doorPlaced 0? ( place-door 1 'doorPlaced ! ) drop
		) drop
	move-enemy
	update-timer
	draw-all

	playerDead 1? ( handle-death game-loop ; ) drop
	flagRestart 1? ( 0 'flagRestart ! setup-level ) drop

	20 ms game-loop ;

:splash-screen
	.cls .hidec
	4 3 .at .Bold "BOULDER.BAS" .println .Reset
	4 5 .at "Collect all gems to open the exit door" .println
	4 6 .at "The door appears on the same map" .println
	4 7 .at "Reach it before the timer runs out" .println
	4 8 .at "Remaining time is added as a bonus" .println
	4 10 .at "Arrows: move  |  ESC: quit" .println
	4 12 .at "* Press SPACE to continue *" .println
	.flush
	wait-space
	.showc ;

|===== boot =====
:
	msec time rerand
	splash-screen
	exitRequested 1? ( drop .free ; ) drop
	.alsb .hidec
	setup-level
	game-loop
	.masb .showc
	.free ;