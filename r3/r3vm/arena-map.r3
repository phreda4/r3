| arena MAP
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/arr16.r3
^r3/util/ttext.r3

^./arena-term.r3
^./tedit.r3
^./rcodevm.r3

##imgspr

##viewpx ##viewpy ##viewpz

#xmap #ymap #wmap #hmap 

#mapw 16 #maph 12
#tilesize 16 
#tmul

::%w sW 16 *>> ; 
::%h sH 16 *>> ; 

| MAP
#marena * $ffff

| ITEMS
#items * $7ff
#items> 'items


#itemarr 0 0
#fxarr 0 0

| PLAYER
##xp 1 ##yp 1 | position in map
#dp 0	| direction
#ap 0	| anima
#penergy
#pcarry

##tilewin -1
##statemap 0 | 0-play 1-win 2-fail

#playerxyrz

:]m | x y -- map
	mapw * + 3 << 'marena + ;

:]m@ | x y -- map
	]m @ ;
	
::posmap | x y -- xs ys
	swap tmul * 2* viewpx +
	swap tmul * 2* viewpy +
	;

:map264 | mapxy -- 64pos
	dup $ffff and swap 16 >> $ffff and 
	posmap 0 viewpz xyrz64 ;
	
:fall264 | mapxy -- 64pos
	dup $ffff and swap 16 >> $ffff and 
	posmap 0 0.0 xyrz64 ;
	
:drawtile
	a@+ $ff and 0? ( drop ; ) >r
	2dup swap posmap 
	viewpz r> imgspr sspritez
	;
	
:drawmap | x y --
	'marena >a
	0 ( maph <? 
		0 ( mapw <? 
			drawtile
			1+ ) drop
		1+ ) drop ;

	
::mapwin | x y w h --
	'hmap ! 'wmap ! 'ymap ! 'xmap !

	hmap 16 << maph tilesize * /
	wmap 16 << mapw tilesize * /
	min 'viewpz !
	
	wmap
	mapw 1- tilesize * viewpz *. 
	- 2/ xmap + 
	tilesize viewpz *. 2/ +
	'viewpx ! 
	
	hmap
	maph 1- tilesize * viewpz *. 
	- 2/ ymap + 
	tilesize viewpz *. 2/ + 
	'viewpy !
	
	tilesize viewpz *. 2/ 'tmul ! | grid 2 screen
	;
	
|-------------------------------	
| map | type(8)|tile(8)
| $0xx no pasa - pared
| $1xx pasa - nada
| $2xx pasa - cae
| $3xx pasa - explota?
|
| xx00xxxx -- item nro
| 00xxxxxx -- item sin cuerpo

:char2map
	$23 =? ( drop $00d ; ) 				| #  pared
	$3d =? ( drop $00c ; ) 				| =	pared ladrillo
	$20 =? ( drop $133 4 randmax + ; )	|  	piso
	$5f =? ( drop $112 ; )				| _ baldosa
	$2c =? ( drop $114 1 randmax + ; )	| , pasto
	$2e =? ( drop $200 ; )				| .	agujero
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
	




|--------------------
| FX
:drawfx
	8 + >a
	a@+ 64xyrz a@ dup deltatime + a!+ anim>n
	imgspr sspriteRZ
	a@+ a@ deltatime + dup a!	| livetime
	swap >=? ( drop 0 ; ) drop ;

:+fx | live anima zryx --
	'drawfx 'fxarr p!+ >a a!+ a!+ 
	1000 *. a!+ 0 a! ;

:+fxcheck | x y -- x y 
	0.6 | live
	29 2 $ff ICS>anim
	2over posmap 0 viewpz xyrz64 
	+fx 
|.. animation	
|	a> -3 ncell+
|	pick2 pick2 posmap 0 viewpz xyrz64 
|	2over posmap 2.0 viewpz 2/ xyrz64 
|	24 0.5 0
|	+vboxanim | 'var fin ini ease dur. start --
	;

:drawlabel
	8 + >a
	a@+ 64xywh 
	2over 2swap
	$000000 sdlcolor sdlfrect
	2 + swap 2 + swap tat 	
	
	a@+ a@ deltatime + dup a!+ | livetime
	swap >=? ( drop 0 ; ) drop 
	
	a> | string in array!!
	6 tcol temits
	;
	
::+label | live x y "" --
	'drawlabel 'fxarr p!+ >a 
	tsbox 4 + -rot 4 + -rot 
	>r | x y w h
	2swap 48 - swap pick3 2/ - swap 2swap | center
	xywh64 a!+ 
	1000 *. a!+ 0 a!+ | timelive
	r> a> strcpy | string in array!!
|.. animation
|	-3 3 << a+
|	a> 
|	a@ 64xywh rot 32 - -rot xywh64 
|	a@ 
|	2 0.8 0
|	+vboxanim | 'var fin ini ease dur. start --

	;


|---------------------
| ITEMS
:drawitem
	16 + >a
	a@+ 64xyrz 
	a@ dup deltatime + a!+ anim>n
	imgspr sspriterz
	;
	
:moveitemscr | ; a> item
	a> 16 +		| var
	a> 8 + @ map264	| fin
	a> 16 + @ 	| ini
	0 0.1 0
	+vboxanim | 'var fin ini ease dur. start --	
	;
	
:+item | t a mapxy --
	'drawitem 'itemarr p!+ >a
	dup a!+ 
	map264 | map>scr
	a!+ a!+ a! ;
	
:setitem | adr item
	@+ 0? ( drop @ dup $ffff and 'xp ! 16 >> $ffff and 'yp ! ; )
	swap @ 
	dup 32 >> $ffff and over 48 >> $ffff and $7f ICS>anim
	swap
	+item
	;
		
:item+! 
	items> !+ 'items> ! ;

:parseitem
	trim dup c@ 
	$2a =? ( drop ; ) |*
	0? ( drop ; ) drop
	str>nro -? ( drop ; ) item+! | tipo
	trim str>nro swap
	trim str>nro 16 << rot or swap 
	trim str>nro 32 << rot or swap 
	trim str>nro 48 << rot or 
	item+! | cnt frame y x
	>>cr parseitem ;
	
:parsescript	
	trim dup 'script ! dup 'script> ! ;
	
:parseline | adr -- adr
	trim dup c@ 0? ( drop ; ) drop
|	dup "%w" .println
	"*MAP" =pre 1? ( drop >>cr parsemap parseline ; ) drop 
	"*ITEM" =pre 1? ( drop >>cr parseitem parseline ; ) drop 
	"*SCRIPT" =pre 1? ( drop >>cr parsescript >>0 ; ) drop
	>>cr parseline ;
	
::loadlevel | "" --	
	'items 'items> !
	0 dup 'script ! 'script> !
	here swap load 0 swap c! 
	here only13 0 swap c!
	here parseline 'here !
	teclr | clear terminal
	0 fuente !
	edset	| clear code
	0 'sstate ! 
	'addscript 1.0 +vexe	| start in 1 sec
	;
	
	
|---- item to map	
| back(8)nro(8)item(4)type(4)tile(8)

:itemxy	| item -- item x y
	dup 1 ncell+ @ 
	dup $ffff and 
	swap 16 >> $ffff and ;
	
:iteminv | item --

	dup itemxy ]m 						| item map
	
|	dup @ $300 and $200 =? ( 2drop 'itemarr p.del ; ) drop | agujero
	
	|over 
	swap 'itemarr p.nro 1+ 24 << 		| item map nitem
	|swap 4 ncell+ @ 2 + 12 << or			| add item to map

	over @ or swap ! ;
	
:item2m | item --
	dup 4 ncell+ @ 
	2 =? ( drop iteminv ; ) | item sin cuerpo
	drop	
	dup itemxy ]m 						| item map
	
|	dup @ $300 and $200 =? ( 2drop 'itemarr p.del ; ) drop | agujero
	
	over 'itemarr p.nro 1+ 16 << 		| item map nitem
	rot 4 ncell+ @ 2 + 12 << or			| add item to map

	over @ or swap ! ;
	
:item2map
	'marena >a maph mapw * 
	( 1? 1- 
		a@ $0fff and a!+ ) drop
	'item2m 'itemarr p.mapv 
	;

|-----
:fallitem | item --

	dup 16 +		| var
	over 8 + @ map264
	pick2 16 + @ 	| ini
	0 0.1 0
	+vboxanim | 'var fin ini ease dur. start --	
	
	dup 16 +		| var
	over 8 + @ fall264
	pick2 8 + @ map264
	0 0.5 0.1
	+vboxanim  | 'var fin ini ease dur. start --	

	2 swap 4 ncell+ ! | converto to nobody
	;
	
:chki | item --
	dup 4 ncell+ @ 2 =? ( drop ; ) drop	| item sin cuerpo
	dup itemxy ]m@ 						| item map
	8 >> tilewin =? ( 1 'statemap ! ) 
	$3 and $2 =? ( drop fallitem ; ) | fall item
	2drop ;
	
:check2map
	'chki 'itemarr p.mapv ;

|----------------
|	701 
|	6 2
|	543
|
#mdir ( 0 -1	1 -1	1 0		1 1		0 1		-1 1	-1 0	-1 -1 )
#mani ( 6 3 3 3 9 0 0 0 )

#dirx #diry

:dir2dxdy | dir -- dx dy
	$7 and 2* 'mdir + c@+ 'dirx ! c@ 'diry ! ;

#moveplayer -1

|--- type of item 
:moveitem | d nx ny -- d nx ny 1/0
	a> 8 + @
	dup $ffff and dirx +
	swap 16 >> $ffff and diry +
	]m@ 
	$300 nand? ( 0 nip ; )		| wall
	$ff0000 and? ( 0 nip ; )	| item solid
	drop | tipo 0

	a> 8 + 
	dup @
|	dup $ffff and dirx + $ffff and
|	swap 16 >> $ffff and diry + $ffff and 16 << or
	dup dirx + $ffff and
	swap diry 16 << + $ffff0000 and or
	swap !
	moveitemscr
	
	1 ;

:overitem | d nx ny -- d nx ny 0
	1 ;
	
:eatitem | d nx ny -- d nx ny 0
	a> 'itemarr p.del
	1 ;
	
:winitem
	1 ;
	
#typeitem 'moveitem 'overitem 'eatitem 'winitem

:checkfall
	xp yp ]m@ $300 and 
	$200 <>? ( drop ; ) drop
	
	| cae player
	'playerxyrz
	xp yp posmap 0 0 xyrz64 
	playerxyrz
	0 0.5 0
	+vboxanim | 'var fin ini ease dur. start --	
	2 'statemap ! | fail
	;
	
:realmove | x y --
	'yp ! 'xp !
	'mani + c@ 3 $ff ICS>anim 'ap ! | anima
	'playerxyrz
	xp yp posmap 0 viewpz xyrz64 
	playerxyrz
	0 0.1 0 +vboxanim | 'var fin ini ease dur. start --	
	[ ap anim>stop 'ap ! checkfall ; ] 0.1 +vexe | stop animation
	;
	
:chainmove | d nx ny wall --
	16 >> $ff and 1- 'itemarr p.adr >a		| n item
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

:botstep | dir --
	dup dir2dxdy
	xp dirx + yp diry + | dir nx ny
	botmove	
	item2map
	check2map
	;
	
:map.step
	moveplayer +? (  
		dup botstep 
		-1 'moveplayer ! 
		) drop
	;

|-------- WORDS	
::botstep 'moveplayer ! ;

:istep 
	vmpop 32 >> 'moveplayer !
	;
	
:icheck
	vmpop 32 >> 
	$7 and 
	2* 'mdir + c@+ swap c@ 	| dx dy
	yp + swap xp + swap
	+fxcheck
	]m@ $ff00 and 24 <<   | xx00 --> xx00000000
	vmpush
	;

::bot.check	
	$7 and 
	2* 'mdir + c@+ swap c@ 	| dx dy
	yp + swap xp + swap
	]m@ |$ff00 and    | xx00 --> xx00000000
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
	
:isay
	2.0
	xp yp posmap
	vmpop vmtokstrf 
	+label ;

#wordt * 80
#words "step" "check" "take" "leave" "rand" "say" 0
#worde	istep icheck itake ileave irand isay 
#wordd ( $f1 $01 $f1 $f1 $f1 $f1 0 ) 

::draw.map
	drawmap
	
	'itemarr p.draw 

	playerxyrz 64xyrz 
	ap dup deltatime + 'ap ! 
	anim>n
	imgspr sspriteRZ

	'fxarr p.draw 
	
	map.step
	;

::reset.map
	100 'penergy ! 0 'pcarry ! 
	
	'fxarr p.clear
	'itemarr p.clear
	'items ( items> <?
		dup setitem 2 3 << +
		) drop 
		
	xp yp posmap
	0 viewpz xyrz64 
	'playerxyrz !
	
	3 0 128 ICS>anim 'ap ! | anima'ap !	
	
	;
	
::ini.map
	tilesize dup "media/img/arena-map.png" ssload 'imgspr !

	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio

	50 'itemarr p.ini
	50 'fxarr p.ini
	reset.map
	;	
