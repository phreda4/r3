^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

^./bdashcave.r3

#cavenow

#direccion

| --- timer
#mseca
#deltat
#globalframe
#globalupdate
#globaldivide 16

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


|?*****
#ANIM_MASK $040F000200500F28
:animasprite | base -- sprite
	ANIM_MASK over >> 1 and dup 2* or dup 2* or | base mask
	globalframe swap and 
	swap 'sprconv + c@ + ;
|?*****
	
:drawtile | y x tile -- y x
	0? ( drop ; )
	over 32 * 16 +	| x
	pick3 32 * 16 +	| y
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
:t0 |  -- | inerte
	;
	
:swaptile | xy xy --
	cavea -rot cavea 
	dup c@ -rot | d2c d1 d2 
	over c@ swap c! c! ;
	
:t1 | y x  -- y x | gravedad
	dup pick2 1+ cave@
	1? ( drop ; ) drop
	dup pick2 2dup 1+ swaptile
	;
:t2 |  -- | criatura
	 ;
:t3 |  -- | amoeba
	 ;
:t4 |  -- | magico
	 ;
:t5 |  -- | player
	 ;

#tiposl 't0 't1 't2 't3 	
:updatetile | celda --
	|$0c and 2* 'tiposl + @ ex
	$10 =? ( drop t1 ; ) drop
	;
	
:updategame
	'cave 80 + >a
	1 ( 23 <? 1+ 
		0 ( 40 <? 
			ca@+ updatetile
			1+ ) drop
		) drop ;
		
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
	sw 0 txat globalframe "%d" txprintr

	showgame
	
	sdlRedraw
	sdlkey
	>esc< =? ( exit )
	<up> =? ( 1 'direccion ! )
	<dn> =? ( 2 'direccion ! )
	<le> =? ( 3 'direccion ! )
	<ri> =? ( 4 'direccion ! )
	>up< =? ( 0 'direccion ! )
	>dn< =? ( 0 'direccion ! )
	>le< =? ( 0 'direccion ! )
	>ri< =? ( 0 'direccion ! )
	
	<f1> =? ( -1 cave+! )
	<f2> =? ( 1 cave+! )
	drop
	;
	
: 
	"r3 multisprite" 640 480 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont
	32 32  "media/img/bdash.png" ssload 'imgspr !

|	showsb .flush
	msec 'mseca ! 0 'deltat !
	
	0 'cavenow ! 0 cave+!
	
	'main sdlshow

	;