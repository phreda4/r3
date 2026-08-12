^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3
^r3/lib/rand.r3

^./bdashcave.r3

#cave * 960 | 40x24
#cavenow	| limit for cave too
#level 1

#dir
#diam 

#score
#bestscore

#cavediam
#cavetime 
#doorplace

#xview 0 #yview 0
#xviewd 0 #yviewd 0

| --- timer
#mseca
#deltat
#globalframe
#globalupdate
#globaldivide 6

|------------ SPRITES
#imgspr
#sprconv ( 
48 57 51 52 49 49  0 49 | $00 a $07
72 72 72 72  0  0  0  0 | $08 a $0F
56  0 56  0 80  0 80  0 | $10 a $17
 0  0  0 59 60 61 60 59 | $18 a $1F
59 60 61 60 59 49  1  2 | $20 a $27
 3  0  0  0  0  0  0  0 | $28 a $2F
88 88 88 88  0  0  0  0 | $30 a $37
 0  0 64  0  0  0  0  0  | $38 a $3F
)

#aniplayer ( 8 32 40 32 40 ) | dir

:player
	dir 'aniplayer + c@ 
	|*** wait for piecito
	globalframe 2 >> $7 and + ;
	
#AMASK $00000F003F000F00 $00F000FF00000F00

:animasprite | base -- sprite
	$3f and 
	$38 =? ( drop player ; ) 
	'AMASK over 5 >> 3 << + @ over $1f and 2* >> $3 and 
	1 swap << 1-
	globalframe and
	swap 'sprconv + c@ + ;
	;
	
:drawtile | y x tile -- y x
	0? ( drop ; )
	over 32 * xview int. +	| x
	pick3 32 * yview int. +	| y
	rot 
	animasprite
	imgspr ssprite
	;
	
:showgame
	'cave 80 + >a
	1 ( 23 <? 1+ 
		0 ( 40 <? 
			ca@+ drawtile
			1+ ) drop
		) drop ;

|--------------
#wingame

:deadplayer
	0 'wingame !
	exit ;

:winplayer
	1 'wingame !
	exit ;

:caveup 40 - ; :cavedn 40 + ; :caveri 1+ ; :cavele 1- ;
		
|---- gravedad		
:space | adr -- adr
	dup c@ $82 or | falling + mark ready
	over cavedn c!
	0 over c! ;

:stopfall | adr -- adr
	dup c@ $2 nand over c! ; 
		
:roundr
	dup caveri c@ 1? ( drop stopfall ; ) drop
	dup caveri cavedn c@ 1? ( drop stopfall ; ) drop
	dup c@ $80 or 
	over caveri cavedn c!
	0 over c! ;
		
:roundfall | adr -- adr
	dup cavele c@ 1? ( drop roundr ; ) drop
	dup cavele cavedn c@ 1? ( drop roundr ; ) drop
	dup c@ $80 or 
	over cavele cavedn c!
	0 over c! ;
	
:eca!+ | value -- value
	ca@ $ff and 
	$38 =? ( 0 nip deadplayer ) 
	1 >? ( drop 1 a+ ; ) drop
	dup ca!+ ;
	
:eline!+
	eca!+ eca!+ eca!+ 40 3 - a+	;
	
:explode | adr val -- adr
	over cavele >a
	eline!+ eline!+ eline!+ drop ;
	
:killplayer | adr -- adr
	dup c@ $2 nand? ( drop ; ) drop | only falling
	$9b explode
	;
	
:gravity | adr -- adr 
	dup cavedn c@ | cell dn?
	0? ( drop space ; )
	$10 $16 in? ( drop roundfall ; )
	$38 =? ( drop killplayer ; ) 
	$fc and
	$08 =? ( drop $9b explode ; )
	$30 =? ( drop $a0 explode ; )
	$38 =? ( drop $9b explode ; )
	drop
	stopfall ;
	
|--- explosion	
:explo | adr --  adr
	dup c@
	$1f =? ( drop 0 over c! ; )
	$24 =? ( drop $14 over c! ; )
	$28 =? ( drop $38 over c! ; )
	1+ over c! 
	;
	
|--- criaturas	 
#dirlist ( 0 -40 40 -1 1 )

:deltadir | dir -- delta
	dir 'dirlist + c@ ;

:adrtoview | adr -- adr
	dup 'cave -
	40 /mod 
	10 - 32.0 *
	-16.0 max 624.0 min  
	neg 'xviewd !
	7 - 32.0 *
	16.0 max 272.0 min
	neg 'yviewd !
	;
	
:moveplay
	$38 $80 or swap c! 0 over c! 
	adrtoview
	;
	
:pullrock | adr adrd -- adr
	dir 3 <? ( 2drop ; ) drop | left or right only
	deltadir over +
	dup c@ | adr adrd adrd2 d2@
	1? ( 3drop ; ) | not empy space !! add count for delay move
	drop
	$90 swap c!
	$B8 swap c! | player ready
	0 over c!
	;

:opendoor
	$5 doorplace ! 
	;
	
:player
	deltadir over + dup c@ | adr adrd des@
	2 <? ( drop moveplay ; ) 
	$14 =? ( drop moveplay 
		diam 1+ cavediam >=? ( opendoor ) 'diam ! 
		; )
	$10 =? ( drop pullrock ; )
	$05 =? ( drop 
		diam cavediam >=? ( drop winplayer ; ) 
		)
	2drop
	;
	
#dirs ( -40 1 40 -1 ) 	

:dir2dad | dir -- deltaa
	$3 and 'dirs + c@ ;
	
:criatura | adr base pref -- adr 
	pick2 c@  	| adr base pref diract
	over +		| adr base pref dirpref
	dir2dad pick3 + | adr base pref adrpref
	dup c@ 0? ( drop	| adr base pref adrpref 
		-rot 			| adr adrpref base pref 
		pick3 c@ + $3 and or $80 or | adr adrpref v
		swap c!
		0 over c!
		; ) 2drop			| adr base pref 
	pick2 dup c@ dir2dad +	| adr base pref diract
	dup c@ 0? ( drop		| adr base pref diract
		nip nip over c@ $80 or 
		swap c!
		0 over c!
		; ) 2drop 			| adr base pref
	neg pick2 c@ + $3 and or
	over c! ;
	
:amoeba	| adr -- adr
	rand8 dir2dad over + 
	dup c@ $7f and 
	$38 =? ( deadplayer 1 nip ) 
	1 >? ( 2drop ; ) drop
	$3a $80 or swap c!
	;
	
:things | adr --  adr
	dup c@
	$38 =? ( drop player ; )
	$fc and
	$08 =? ( 1 criatura ; )
	$30 =? ( -1 criatura ; )
	$38 =? ( drop amoeba ; )
	drop
	;

#GRUPO (
    0 0 0 0 0 0 0 0  | Inerte (Vacío Tierra Muros)
    3 3 3 3 0 0 0 0  | 0x08-0x0B = Luciérnagas (Grupo 3 - Entidades)
    1 1 1 1 1 1 1 1  | Gravedad (Rocas Diamantes)
    1 1 1 2 2 2 2 2  | 0x1B-0x1F = Explosiones (Grupo 2)
    2 2 2 2 2 2 2 2  | Explosiones y Prerockford (Grupo 2)
    2 0 0 0 0 0 0 0  | 0x28 = Prerockford final (Grupo 2)
    3 3 3 3 0 0 0 0  | 0x30-0x33 = Mariposas (Grupo 3 - Entidades)
    3 0 3 0 0 0 0 0   | 0x38 = Rockford 0x3A = Ameba (Grupo 3 - Entidades)
	)
	
:updatetile | celda --
	-? ( drop ; ) | $80 ready
	$3f and 'GRUPO + c@
	0? ( drop ; ) 
	1- 0? ( drop gravity ; )
	1- 0? ( drop explo ; ) 
	drop
	things ;
	
	
:updategame
	'cave 80 + dup 
	( 'cavenow <? | clear ready
		dup c@ $7f and swap c!+ 
		) drop 
	( 'cavenow <?	| traverse
		dup c@ updatetile
		1+ ) drop ;
			
|--------------	
:buildcave | --
	level cavenow 'cave decodecavenow | nro cavedst --
	
	a> $e + level + c@ $ff and 'cavetime ! | tick de fisica
	a> $9 + level + c@ $ff and 'cavediam !
	| --- reset game
	16.0 'xview ! 16.0 'yview !
	'cave ( 'cavenow <? c@+ 
		$4 =? ( over 1- 'doorplace ! )
		$5 =? ( over 1- 'doorplace ! )
		$25 =? ( $38 nip )
		$26 =? ( $38 nip )
		$38 =? ( over 1- adrtoview drop 
			xviewd 'xview ! yviewd 'yview ! ) 
		drop ) drop 
	doorplace c@ $4 =? ( $7 doorplace c! ) drop
	
	'cave showsb .flush		
	;

:getCave | dc --
	cavenow +
	-? ( ncaves 1- nip )
	ncaves >=? ( 0 nip )
	'cavenow ! 
	buildcave ;

|---------------------------------------
#ticktime	
:logic
	msec dup mseca - 'deltat +! 'mseca !
	deltat 20 <? ( drop ; )  | 50 fps
	20 - 'deltat ! 
	1 'globalframe +!
	
	globalupdate 1+
	globaldivide >=? ( 
		0 nip
		updategame 
		)
	'globalupdate !
	
	ticktime 1+ 50 <? ( 'ticktime ! ; )  drop | 1 sec
	0 'ticktime !
	-1 'cavetime +!
	; 

	
:movecam
	xview xviewd over - 0.03 *. + 'xview !
	yview yviewd over - 0.03 *. + 'yview !
	;
	
|------------ MAIN	
:game
	0 cls	
	logic
	movecam
	showgame

	$ffffff txrgb
	0 0 txat 
	ncaves cavenow "%d/%d " txprint
	140 0 tx+at cavetime "%d" txprint
	sw 0 txat 
	score cavediam diam "%d/%d : %d" txprintr
	|yviewd xviewd "%f %f" txprintr
	
	sdlRedraw
	sdlkey
	>esc< =? ( 0 'wingame ! exit )
	<up> =? ( 1 'dir ! )
	<dn> =? ( 2 'dir ! )
	<le> =? ( 3 'dir ! )
	<ri> =? ( 4 'dir ! )
	>up< =? ( 0 'dir ! )
	>dn< =? ( 0 'dir ! )
	>le< =? ( 0 'dir ! )
	>ri< =? ( 0 'dir ! )
	
	<f1> =? ( -1 getCave )
	<f2> =? ( 1 getCave )
	drop
	;
	
:playgame
	0 'score !
	0 'diam !
	0 'wingame !
	
	( buildcave
		'game SDLShow
		
		1 'cavenow +!
		cavenow 20 =? ( 
			1 'level +! 
			level 5 =? ( 0 'wingame ) drop
			) drop
			
		wingame 1? drop 			
		) drop
	
	score bestscore >? ( dup 'bestscore ! ) drop
	;
	
#xhor
	
:main
	0 cls
	$ffffff txrgb
	$11 txalign
	sw 64 0 16 "BDash Clone in r3forth" txText
	
	32 128 txat
	level 1+ cavenow "Cave: %d - Level: %d " txPrint txcr
	32 0 tx+at
	bestscore "Best Score:%d" txPrint
	
	$7fff7f txrgb
	sw 64 0 sh 64 -
	"<Space> - Start" txText

	sw 2/ sh dup 2 >> - 
	4.0 msec 6 >> $7 and 16 + 
	imgspr
	sspritez
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<up> =? ( level 1+ 4 min 'level ! )
	<dn> =? ( level 1- 0 max 'level ! )
	<le> =? ( cavenow 1- 0 max 'cavenow ! )
	<ri> =? ( cavenow 1+ 19 min 'cavenow ! )
	<spc> =? ( playgame )
	drop
	;
	
: 
	"r3 multisprite" 640 480 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont
	32 32  "media/img/bdash.png" ssload 'imgspr !

	msec 'mseca ! 0 'deltat !
|	0 'cavenow ! 0 getCave

	playgame		
	
|	'main sdlshow

	;