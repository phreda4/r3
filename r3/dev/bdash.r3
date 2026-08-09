^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

^./bdashcave.r3

#cavenow

#dir
#diam

#xview 16 #yview 16
#xviewd 16 #yviewd 16

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



#AMASK $00000F003F000480 $001000FF00000800

:animasprite | base -- sprite
	$3f and 
	'AMASK over 5 >> 3 << + @ over $1f and 2* >> $3 and 
	1 swap << 1-
	globalframe and
	swap 'sprconv + c@ + ;
	;
	
:drawtile | y x tile -- y x
	0? ( drop ; )
	over 32 * xview +	| x
	pick3 32 * yview +	| y
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
		
:roundr
	dup caveri c@ 1? ( drop ; ) drop
	dup caveri cavedn c@ 1? ( drop ; ) drop
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
	$ab ca!+ $ab ca!+ $ab ca! 
	40 2 - a+
	$ab ca!+ $ab ca!+ $ab ca! 
	40 2 - a+
	$ab ca!+ $ab ca!+ $ab ca! 
	;
	
:killplayer | adr -- adr
	dup c@ $2 nand? ( drop ; ) drop | only falling
	explode
	;
	
:t1 | adr -- adr 
	dup cavedn c@ 
	0? ( drop space ; )
	$10 $17 in? ( drop roundfall ; )
	$12 =? ( $2 nand over c! ; ) | clear falling
	$16 =? ( $2 nand over c! ; ) | clear falling
	$38 =? ( drop killplayer ; ) 
	drop
	;
	
|--- explosion	
:t2 | adr --  adr
	dup c@
	$2f =? ( drop 0 over c! ; )
	$24 =? ( drop $14 over c! ; )
	$28 =? ( drop $38 over c! ; )
	1+ over c! 
	;
	
|--- criaturas	 
#dirlist ( 0 -40 40 -1 1 )

:deltadir | dir -- delta
	dir 'dirlist + c@ ;
	
:moveplay
	$38 $80 or swap c! 0 over c! ;
	
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
	
:adrtoview | adr -- adr
	dup 'cave -
	40 /mod | y x
	10 - 32 * 16 max 'xviewd !
	10 - 32 * 16 max 'yviewd !
	;
:player
	deltadir over + dup c@ | adr adrd des@
	2 <? ( drop moveplay ; ) 
	$14 =? ( drop moveplay 1 'diam +! ; )
	$10 =? ( drop pullrock ; )
	2drop
	;
	
:t3 | adr --  adr
	dup c@
	$38 =? ( drop player ; )
	drop
	;

#tiposl 't0 't1 't2 't3 	
:updatetile | celda --
	-? ( drop ; ) | $80 ready
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
:cave+! | dc --
	cavenow +
	-? ( ncaves 1- nip )
	ncaves >=? ( 0 nip )
	dup 'cavenow ! 
	decodecavenow 
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
	
|------------ MAIN	
:main
	logic
	
	0 cls	
	$ffffff txrgb
	0 0 txat ncaves cavenow "%d/%d " txprint
	sw 0 txat diam "%d" txprintr

	showgame
	
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
	
	<f1> =? ( -1 cave+! )
	<f2> =? ( 1 cave+! )
	drop
	;
	
: 
	"r3 multisprite" 640 480 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont
	32 32  "media/img/bdash.png" ssload 'imgspr !

	msec 'mseca ! 0 'deltat !
	0 'cavenow ! 0 cave+!
	0 'diam !
	|showsb .flush
	
	'main sdlshow

	;