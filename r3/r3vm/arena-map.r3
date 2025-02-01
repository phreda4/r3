| arena MAP
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3
^r3/util/arr16.r3
^r3/util/hash2d.r3

^./rcodevm.r3

##imgspr

##viewpx ##viewpy ##viewpz
	
#tsize 16 
#tmul

| MAP
#mw 16 #mh 12
#marena * $fff

| ITEMS
#items * $7ff
#items> 'items

#itemarr 0 0

| PLAYER
#xp 1 #yp 1 | position
#dp 0	| direction
#ap 0	| anima
#penergy
#pcarry


:]map | x y -- map
	mw * + 3 << 'marena + @ ;
	
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
	'marena >a
	0 ( mh <? 
		0 ( mw <? 
			drawtile
			1+ ) drop
		1+ ) drop ;

|-------------------------------	
:char2map
	$20 =? ( drop $012 ; ) | 
	$23 =? ( drop $10d ; ) | #
	$3d =? ( drop $10c ; ) | =
	;
	
:parsemap
	trim str>nro 'mw ! trim str>nro 'mh ! 
|	mh mw "map %d %d" .println
	>>cr trim >b 
	'marena >a
	mh ( 1? 1-
		mw ( 1? 1-
			cb@+ char2map a!+
			) drop 
		b> >>cr trim >b
		) drop 
	b> ;
	
|---------------------
| ITEMS
#aitem

::draw.items

	'itemarr p.draw
	
|	3 3 posmap
|	viewpz
|	aitem anim>n
|	imgspr sspritez
	
|	deltatime 'aitem +!
	;


|	30 8 128 ICS>anim  | init cnt scale -- val
|	'aitem ! | moneda

:drawitem
	8 + >a
	a@+ a@+
	posmap
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
		
::resetlevel
	'itemarr p.clear
	'items ( items> <?
		dup setitem
		|dup @+ "%h " .print @ "%h" .println
		2 3 << +
		) drop .cr ;

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
	resetlevel
	;
	
|---------------------

::resetplayer
	100 'penergy !
	0 'pcarry ! 
	1 'xp ! 1 'yp !
	;
	
::draw.player
	xp yp posmap
	viewpz
	ap anim>n
	imgspr sspritez
	
	deltatime 'ap +!
	;

:movepl | dx dy --
	yp + swap xp + swap
	2dup
	]map $ff00 and 8 >> 1? ( 3drop ; ) drop
	'yp ! 'xp !
	;
	
|------ IO interface 
|	701 
|	6 2
|	543
|
#mdir ( 0 -1	1 -1	1 0		1 1		0 1		-1 1	-1 0	-1 -1 )
#mani ( 6 3 3 3 9 0 0 0 )
	
::botstep
	$7 and dup 
	'mani + c@  3 128 ICS>anim 'ap ! | anima
	2* 'mdir + c@+ swap c@ 	movepl	| dx dy
	;
	
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

#wordt * 80
#words "step" "check" "take" "leave"  0
#worde	istep icheck itake ileave
#wordd ( $f1 $f1 $f1 $f1 $00 ) 

::bot.reset
	resetplayer
	;

::bot.ini
	tsize dup "media/img/arena-map.png" ssload 'imgspr !

	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio

	400 'viewpx !
	32 'viewpy !
	2.0 'viewpz !
	calc
	
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
	calc
	;
	
