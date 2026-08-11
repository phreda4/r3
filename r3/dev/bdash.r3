^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

^./bdashcave.r3

#cave * 960 | 40x24
#cavelast
#cavenow

#dir
#diam #diamt
#cavetime 

#xview -640.0 #yview -480.0
#xviewd 16.0 #yviewd 16.0

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
	globalframe $7 and + ;
	
#AMASK $00000F003F000480 $001000FF00000800	

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
:caveup 40 - ; :cavedn 40 + ; :caveri 1+ ; :cavele 1- ;

| inerte
:t0 |  -- 
	;
		
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
	
:explode | adr -- adr
	dup caveup cavele >a
	$9b ca!+ $9b ca!+ $9b ca! 
	40 2 - a+
	$9b ca!+ $9b ca!+ $9b ca! 
	40 2 - a+
	$9b ca!+ $9b ca!+ $9b ca! 
	;
	
:killplayer | adr -- adr
	dup c@ $2 nand? ( drop ; ) drop | only falling
	explode
	;
	
:t1 | adr -- adr 
	dup cavedn c@ | cell dn?
	0? ( drop space ; )
	$10 $16 in? ( drop roundfall ; )
	$38 =? ( drop killplayer ; ) 
	drop
	stopfall ;
	
|--- explosion	
:t2 | adr --  adr
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
	
:player
	deltadir over + dup c@ | adr adrd des@
	2 <? ( drop moveplay ; ) 
	$14 =? ( drop moveplay 1 'diam +! ; )
	$10 =? ( drop pullrock ; )
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
	
:t3 | adr --  adr
	dup c@
	$38 =? ( drop player ; )
	$fc and
	$08 =? ( 1 criatura ; )
	$30 =? ( -1 criatura ; )
	drop
	;

#tiposl 't0 't1 't2 't3 	
:updatetile | celda --
	-? ( drop ; ) | $80 ready
	$1b $1f in? ( drop t2 ; )
	$30 and 4 >> 3 << 'tiposl + @ ex ;
	
:updategame
	'cave 80 +
	dup ( 'cavelast <? | clear ready
		dup c@ $7f and swap c!+ 
		) drop 
	( 'cavelast <?	| traverse
		dup c@ updatetile
		1+ ) drop ;
			
|--------------	
:getCave | dc --
	cavenow +
	-? ( ncaves 1- nip )
	ncaves >=? ( 0 nip )
	dup 'cavenow ! 
	'cave decodecavenow | nro cavedst --
	a> $e + c@ 'cavetime ! | tick de fisica
	
	
	| --- reset game
	16.0 'xview ! 16.0 'yview !
	0 'diamt !
	'cave ( 'cavelast <? c@+ 
		$25 =? ( $38 nip )
		$26 =? ( $38 nip )
		$38 =? ( over 1- adrtoview drop ) 
		$14 =? ( 1 'diamt +! )
		drop ) drop 
		
	|'cave showsb .flush		
	;
		
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
	; 
	
:movecam
	xview xviewd over - 0.03 *. + 'xview !
	yview yviewd over - 0.03 *. + 'yview !
	;
	
|------------ MAIN	
:main
	0 cls	
	logic
	movecam
	showgame

	$ffffff txrgb
	0 0 txat 
	ncaves cavenow "%d/%d " txprint
	cavetime "%d" txprint
	sw 0 txat 
	diamt diam "%d/%d" txprintr
	|yviewd xviewd "%f %f" txprintr
	
	sdlRedraw
	sdlkey
	>esc< =? ( exit )
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
	
: 
	"r3 multisprite" 640 480 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont
	32 32  "media/img/bdash.png" ssload 'imgspr !

	msec 'mseca ! 0 'deltat !
	0 'cavenow ! 0 getCave
	0 'diam !
	
	'main sdlshow

	;