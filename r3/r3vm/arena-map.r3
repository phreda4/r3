| arena MAP
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/arr16.r3
^r3/util/ttext.r3

^./tedit.r3
^./rcodevm.r3

##imgspr

#xmap #ymap #wmap #hmap 

##viewpx ##viewpy ##viewpz

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
##xp 1 ##yp 1 | position
#dp 0	| direction
#ap 0	| anima
#penergy
#pcarry

##sstate

:]m | x y -- map
	mapw * + 3 << 'marena + ;

:]m@ | x y -- map
	]m @ ;
	
::posmap | x y -- xs ys
	swap tmul * 2* viewpx +
	swap tmul * 2* viewpy +
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
	tilesize viewpz *. 2/ 'tmul ! | recalc
	'marena >a
	0 ( maph <? 
		0 ( mapw <? 
			drawtile
			1+ ) drop
		1+ ) drop 
		
|	$ffffff sdlcolor
|	xmap ymap wmap hmap sdlrect
	;
	
	
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
	;
	
|-------------------------------	
| map | type(8)|tile(8)
| $0xx no pasa - pared
| $1xx pasa - nada
| $2xx pasa - cae
| $3xx pasa - explota?
|
| 00xxxx -- iten nro

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
| SCRIPT

#script
#script>

##term * 8192
##term> 'term 

:teclr	'term 'term> ! ;
:,te 	term> c!+ 'term> ! ;
	
|----
#speed 

:dighex | c --  dig / -1 | :;<=>?@ ... Z[\]^_' ... 3456789
	$3A <? ( $30 - ; ) tolow $57 - ;

:copysrc | copy to edit
	>>cr 2 +
	fuente >a
	( c@+ $25 <>?
		10 <>? ( dup ca!+ ) drop
		) drop
	0 ca!+
	edset
	>>cr ;
	
:incode
	'xedit 16 -500 26 0.5 0.0 +vanim
	;
	
:outcode
	'xedit -500 16 25 0.5 0.0 +vanim
	;
	
:inmap
|	'viewpz 2.0 0.0 26 0.5 0.0 +vanim 
	'viewpx 
	SW viewpz mapw 16 * *. - 32 -
	1400 26 0.5 0.0 +vanim 
	;
	
:outmap
|	'viewpz 0.0 2.0 25 0.5 0.0 +vanim 
	'viewpx 1400 
	SW viewpz mapw 16 * *. - 32 -
	25 0.5 0.0 +vanim 
	;
	
:endless	
	outcode
	outmap
	'exit 2.0 +vexe
	;
	
#anilist 'incode 'outcode 'inmap 'outmap
	
:anima
	c@+ dighex
	$3 and 3 << 'anilist + @ ex
	>>cr
	;
	
:waitn	
	1 'sstate ! ;
	
:cntr | script -- 'script
	c@+
	0? ( drop 1- ; )
|	$25 =? ( ,te ; ) | %%
	$63 =? ( drop 12 ,te c@+ dighex ,te ; )	| %c1 color
	$2e =? ( drop teclr trim ; )	| %. clear
	$61 =? ( drop anima ; )			| %a1 animacion	
	$65 =? ( drop endless ; ) 		| %e end
	$69 =? ( drop 11 ,te ; )		| %i invert
	$73 =? ( drop copysrc trim ; ) 	| %s..%s source
	$77 =? ( drop >>sp waitn ; )	| %w1 espera
	
	,te
	;
	
:+t
	0? ( 2 'sstate ! 1- ) 
	$2c =? ( 0.4 'speed ! )	|,
	$2e =? ( 0.8 'speed ! ) |.
	$25 =? ( drop cntr ; )	|%
	13 <? ( drop ; ) 
	,te 
	;
	
:addscript
	0.05 'speed !
	script> c@+ +t 'script> !
	
	sstate 1? ( drop ; ) drop
	'addscript speed +vexe
	;

::nextchapter
	0 'sstate ! teclr 
	script> trim 'script> !
	addscript 
	;
	
::completechapter
	( sstate 0? drop
		script> c@+ +t 'script> ! ) drop ;

|--------------------
| FX
:drawfx
	8 + >a
	a@+ a@+ posmap
|	2dup 16 + tat | **
	viewpz 
	a@ dup deltatime + a!+ anim>n
	imgspr sspritez
|	6 tcol a@+ "%h" tprint | **
	;

:+fx | t a y x 
	'drawfx 'fxarr p!+ >a
	a!+ a!+ a!+ a! ;

|---------------------
| ITEMS
::draw.items
	'itemarr p.draw 
	'fxarr p.draw 
	;

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
	here parseline 'here !
	teclr | clear terminal
	0 fuente !
	edset	| clear code
	'addscript 2.0 +vexe	| start in 2 sec
	;
	
|---------------------
::resetplayer
	100 'penergy ! 0 'pcarry ! 
	
	3 0 128 ICS>anim 'ap ! | anima'ap !
	
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

|-----
:chki | item --
	dup 4 ncell+ @ 2 =? ( drop ; ) drop	| item sin cuerpo
	dup itemxy ]m@ 						| item map
	$300 and $200 =? ( drop 'itemarr p.del ; ) 
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

:botstep | dir --
	dup dir2dxdy
	item2map
	xp dirx + yp diry + | dir nx ny
	botmove	
	check2map
	;
	
::map.step
	moveplayer +? (  
		dup botstep 
		-1 'moveplayer ! 
		) drop
	item2map | to step
	xp yp ]m@ $300 and 
	$200 <>? ( drop ; ) drop
	| cae player
	;

::botstep | dir --
	'moveplayer ! ;
	
|-------- WORDS	
:istep 
	vmpop 32 >> 'moveplayer !
	;
	
:icheck
	vmpop 32 >> 
	$7 and 
	2* 'mdir + c@+ swap c@ 	| dx dy
	yp + swap xp + swap
	]m@ $ff00 and 24 <<   | xx00 --> xx00000000
	vmpush
	;

::bot.check
	$7 and 2* 'mdir + c@+ swap c@ 	| dx dy
	yp + swap xp + swap
	]m@	;
	
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


	50 'itemarr p.ini
	50 'fxarr p.ini
	;	
