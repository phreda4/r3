| arena MAP
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3
^r3/util/arr16.r3

^./rcodevm.r3

##imgspr

##viewpx ##viewpy ##viewpz
##mapw 16 ##maph 12
#tsize 16 
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


:]m | x y -- map
	mapw * + 3 << 'marena + ;

:]map | x y -- map
	mapw * + 3 << 'marena + @ ;
	
:calc tsize viewpz *. 2/ 'tmul ! ;

::posmap | x y -- xs ys
	swap tmul * 2* viewpx + tmul +
	swap tmul * 2* viewpy + tmul +
	;
	
:drawtile
	|$ffffff sdlcolor postile tmul dup sdlRect
	a@+ $ff and 0? ( drop ; ) >r
	2dup swap posmap viewpz r> imgspr sspritez
	;
	
::draw.map | x y --
	calc
	'marena >a
	0 ( maph <? 
		0 ( mapw <? 
			drawtile
			1+ ) drop
		1+ ) drop ;

|-------------------------------	
:char2map
	$20 =? ( drop $012 ; ) |  	piso
	$23 =? ( drop $10d ; ) | #  pared
	$3d =? ( drop $10c ; ) | =	pared ladrillo
	$2e =? ( drop $200 ; ) | .	agujero
	$3b =? ( drop $14 1 randmax + ; ) | ; pasto
	;
	
:parsemap
	trim str>nro 'mapw ! trim str>nro 'maph ! 
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
	viewpz 
	a@ dup deltatime + a!+ anim>n
	imgspr sspritez
	;

:+item | a y x --
	'drawitem 'itemarr p!+ >a
	a!+ a!+ a!
	;
	
:setitem | adr item
	@+ 0? ( drop @ dup $ffff and 'xp ! 16 >> $ffff and 'yp ! ; )
	drop @ 
	dup 32 >> $ffff and over 48 >> $ffff and $7f ICS>anim
	swap dup 16 >> $ffff and 
	swap $ffff and  | a y x
	+item
	;
		
:item+! items> !+ 'items> ! ;

:parseitem
	trim dup c@ 0? ( nip ; ) drop
	str>nro -? ( drop ; ) item+! | tipo
	trim str>nro swap
	trim str>nro 16 << rot or swap 
	trim str>nro 32 << rot or swap 
	trim str>nro 48 << rot or 
	item+! | cnt frame y x
	>>cr parseitem ;
	
:parseline | adr -- adr
	0? ( ; )
	trim dup c@ 0? ( nip ; ) drop
|	dup "%w" .println
	"*MAP" =pre 1? ( drop >>cr parsemap parseline ; ) drop 
	"*ITEM" =pre 1? ( drop >>cr parseitem parseline ; ) drop 
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
	;
	
::draw.player
	xp yp posmap
	viewpz
	ap anim>n
	imgspr sspritez
	
	deltatime 'ap +!
	;


:checkmap | dx dy -- map
	yp + swap xp + swap ]map ;

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

:moveitem | d nx ny -- d nx ny 1/0
	a> 8 + @ dirx +
	a> 16 + @ diry + | nx ny
	]map $ffff00 and 8 >> 1? ( ; ) drop 
	dirx a> 8 + +!
	diry a> 16 + +! 
	0
	;

:realmove
	'yp ! 'xp !
	'mani + c@ 3 128 ICS>anim 'ap ! | anima
	;
	
:chainmove | d nx ny wall --
	$ff and? ( 4drop ; ) | realwall
	8 >> 1- 'itemarr p.adr >a | item
	moveitem
	1? ( 4drop ; ) drop
	realmove
	;
	
:botmove | d nx ny --
	2dup ]map $ffff00 and 8 >> 1? ( chainmove ; ) drop 
	realmove ;
	
| n 'l p.adr 	| nro to adr 
| 'a 'l p.nro	| adr to nro

:itemxy		dup 8 + @ over 16 + @ ;
:seti		dup itemxy ]m swap 'itemarr p.nro 1+ 16 << over @ or swap ! ;
:item2map	'seti 'itemarr p.mapv ;
:clri		itemxy ]m dup @ $ffff and swap ! ;
:itemCmap	'clri 'itemarr p.mapv ;
	
::botstep | dir --
	dup dir2dxdy
	item2map
	xp dirx + yp diry + | dir nx ny
	botmove	
	itemCmap
	;
	
|-------- WORDS	
:istep 
	vmpop 32 >> botstep ;
	
:icheck 
	vmpop 32 >> 
	$7 and 
	2* 'mdir + c@+ swap c@ 	| dx dy
	yp + swap xp + swap
	]map $ff00 and 24 <<   | xx00 --> xx00000000
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
#wordd ( $f1 $f1 $f1 $f1 $00 $01 ) 

::bot.reset
	resetplayer
	;

::bot.ini
	tsize dup "media/img/arena-map.png" ssload 'imgspr !

	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio

	480 'viewpx !
	300 'viewpy !
	2.0 'viewpz !
	
	50 'itemarr p.ini
	;
	

|----- move view
#xo #yo

:dns
	sdlx 'xo ! sdly 'yo ! ;

:mos
	sdlx xo - 'viewpx +! 
	sdly yo - 'viewpy +! 
	dns ;

::mouseview
	'dns 'mos onDnMove 
	SDLw 0? ( drop ; )
	0.1 * viewpz +
	0.2 max 6.0 min 'viewpz !
	;
	
