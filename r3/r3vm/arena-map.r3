| arena MAP
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/arr16.r3
^r3/util/ttext.r3

^./rcodevm.r3

##imgspr

##viewpx ##viewpy ##viewpz
##mapw 16 ##maph 12
#tilesize 16 
#tmul

| MAP
#marena * $fff

| ITEMS
#items * $7ff
#items> 'items

#itemarr 0 0

| PLAYER
##xp 1 ##yp 1 | position
#dp 0	| direction
#ap 0	| anima
#penergy
#pcarry
##pstate


:]m | x y -- map
	mapw * + 3 << 'marena + ;

:]m@ | x y -- map
	]m @ ;
	
::posmap | x y -- xs ys
	swap tmul * 2* viewpx + tmul +
	swap tmul * 2* viewpy + tmul +
	;
	
:drawtile
	|$ffffff sdlcolor postile tmul dup sdlRect
	a@+ $ff and 0? ( drop ; ) >r
	2dup swap posmap 
|	over 16 - over 16 - tat $a tcol | debug
	viewpz r> imgspr sspritez
|	a> 8 - @ "%h" tprint | debug
	;
	
::draw.map | x y --
|	1.0 tsize | debug
	tilesize viewpz *. 2/ 'tmul ! | recalc
	'marena >a
	0 ( maph <? 
		0 ( mapw <? 
			drawtile
			1+ ) drop
		1+ ) drop ;

|-------------------------------	
| map | type(8)|tile(8)
| $0xx no pasa - pared
| $1xx pasa - nada
| $2xx pasa - cae
| $3xx pasa - explota?
:char2map
	$23 =? ( drop $00d ; ) | #  pared
	$3d =? ( drop $00c ; ) | =	pared ladrillo
	$20 =? ( drop $112 ; ) |  	piso
	$3b =? ( drop $114 1 randmax + ; ) | ; pasto
	$2e =? ( drop $200 ; ) | .	agujero
	| $300 |
	;
	
:parsemap
	trim str>nro 'mapw ! 
	trim str>nro 'maph ! 
	>>cr trim >b 
	'marena >a
	maph ( 1? 1-
		mapw ( 1? 1-
			cb@+ char2map a!+
			) drop 
		b> >>cr trim >b
		) drop 
	b> ;
	
|---------------------
| ITEMS
::draw.items
	'itemarr p.draw ;

:drawitem
	8 + >a
	a@+ a@+ posmap
|	2dup 16 + tat | **
	viewpz 
	a@ dup deltatime + a!+ anim>n
	imgspr sspritez
|	6 tcol a@+ "%h" tprint | **
	;

:+item | t a y x --
	'drawitem 'itemarr p!+ >a
	a!+ a!+ a!+ a! ;
	
:setitem | adr item
	@+ 0? ( drop @ dup $ffff and 'xp ! 16 >> $ffff and 'yp ! ; )
	swap @ 
	dup 32 >> $ffff and over 48 >> $ffff and $7f ICS>anim
	swap dup 16 >> $ffff and 
	swap $ffff and  | a y x
	+item
	;
		
:item+! items> !+ 'items> ! ;

:parseitem
	trim dup c@ 
	$2a =? ( drop ; ) |*
	0? ( nip ; ) drop
	str>nro -? ( drop ; ) item+! | tipo
	trim str>nro swap
	trim str>nro 16 << rot or swap 
	trim str>nro 32 << rot or swap 
	trim str>nro 48 << rot or 
	item+! | cnt frame y x
	>>cr parseitem ;
	
:parsescript	
	;
	
:parseline | adr -- adr
	0? ( ; )
	trim dup c@ 0? ( nip ; ) drop
|	dup "%w" .println
	"*MAP" =pre 1? ( drop >>cr parsemap parseline ; ) drop 
	"*ITEM" =pre 1? ( drop >>cr parseitem parseline ; ) drop 
	"*SCRIPT" =pre 1? ( drop >>cr parsescript parseline ; ) drop
	"*END" =pre 1? ( 2drop 0 ; ) drop
	>>cr parseline ;
	
::loadmap | "" --	
	here swap load 0 swap c!
	'items 'items> !
	here parseline drop
	;
	
|---------------------
::resetplayer
	100 'penergy ! 0 'pcarry ! 
	
	3 3 128 ICS>anim 'ap ! | anima'ap !
	
	'itemarr p.clear
	'items ( items> <?
		dup setitem 2 3 << +
		) drop ;
	
::draw.player
	xp yp posmap
	viewpz
	ap anim>n
	imgspr sspritez
	
	deltatime 'ap +!
	;
	
|------ IO interface 
|	701 
|	6 2
|	543
|
#mdir ( 0 -1	1 -1	1 0		1 1		0 1		-1 1	-1 0	-1 -1 )
#mani ( 6 3 3 3 9 0 0 0 )

#dirx #diry

:dir2dxdy | dir -- dx dy
	$7 and 2* 'mdir + c@+ 'dirx ! c@ 'diry ! ;

|--- type of item 

:moveitem | d nx ny -- d nx ny 1/0
	a> 8 + @ dirx +
	a> 16 + @ diry + | nx ny
	]m@ 
	$300 nand? ( 0 nip ; )		| wall
	$ff0000 and? ( 0 nip ; )	| item
	drop | tipo 0
	dirx a> 8 + +!
	diry a> 16 + +! 
	1 ;

:overitem | d nx ny -- d nx ny 0
	1 ;
	
:eatitem | d nx ny -- d nx ny 0
	a> 'itemarr p.del
	1 ;
	
:winitem
	1 ;
	
#typeitem 'moveitem 'overitem 'eatitem 'winitem

|---	

:realmove
	'yp ! 'xp !
	'mani + c@ 3 128 ICS>anim 'ap ! | anima
	;
	
:chainmove | d nx ny wall --
	16 >> 1- 'itemarr p.adr >a		| item
	a> 4 ncell+ @ 1- $3 and 3 << 'typeitem + @ ex 
	0? ( 4drop ; ) drop
	realmove
	;
	
:botmove | d nx ny --
	2dup ]m@
	$300 nand? ( 4drop ; )			| wall
	$ff0000 and? ( chainmove ; )	| item
	drop 
	realmove ;
	
	
|---- item to map	
| n 'l p.adr 	| nro to adr 
| 'a 'l p.nro	| adr to nro

:itemxy	| item -- item x y
	dup 1 ncell+ @ over 2 ncell+ @ ;
	
:seti | item --
	dup 4 ncell+ @ 2 =? ( drop ; ) drop	| item sin cuerpo
	dup itemxy ]m 						| item map
	
|	dup @ $300 and $200 =? ( 2drop 'itemarr p.del ; ) drop | agujero
	
	over 'itemarr p.nro 1+ 16 << 		| item map nitem
	rot 4 ncell+ @ 2 + 12 << or			| add item to map

	over @ or swap ! ;
	
:item2map
	'marena >a maph mapw * ( 1? 1- a@ $0fff and a!+ ) drop
	'seti 'itemarr p.mapv ;

:chki | item --
	dup 4 ncell+ @ 2 =? ( drop ; ) drop	| item sin cuerpo
	dup itemxy ]m 						| item map
	@ $300 and $200 =? ( drop 'itemarr p.del ; ) 
	2drop ;
	
:check2map
	'chki 'itemarr p.mapv ;
	
|------------------	
	
::botstep | dir --
	dup dir2dxdy
	item2map
	xp dirx + yp diry + | dir nx ny
	botmove	
	check2map
	;
		
|-------- WORDS	
#moveplayer

:istep 
	vmpop 32 >> 'moveplayer !
	;
	
:icheck
	item2map | to step
	vmpop 32 >> 
	$7 and 
	2* 'mdir + c@+ swap c@ 	| dx dy
	yp + swap xp + swap
	]m@ $ff00 and 24 <<   | xx00 --> xx00000000
	vmpush
	;
	
:itake 
	vmpop 32 >> 
	$7 and 
	2* 'mdir + c@+ swap c@ 	| dx dy
	yp + swap xp + swap
	2drop
	;
	
:ileave
	vmpop 32 >> 
	$7 and 
	2* 'mdir + c@+ swap c@ 	| dx dy
	yp + swap xp + swap
	2drop
	;
	
:irand
	vmpop 32 >>
	randmax
	32 << vmpush ;

#wordt * 80
#words "step" "check" "take" "leave" "rand" 0
#worde	istep icheck itake ileave irand
#wordd ( $f1 $01 $f1 $f1 $f1 $00 ) 

::bot.ini
	tilesize dup "media/img/arena-map.png" ssload 'imgspr !

	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio

	480 'viewpx !
	220 'viewpy !
	3.0 'viewpz !
	
	50 'itemarr p.ini
	;
	
:map.check	
	;
	
::map.step
	
	moveplayer botstep 
	map.check
	0 'moveplayer !
	item2map | to step
	;


	
