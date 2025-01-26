| arena MAP
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3
^r3/r3vm/rcodevm.r3

#level0 (
22 21 21 21 21 21 21 21 21 21 21 21 21 21 21 22
22  0  0  0  0  0  0  0  0  0  0  0  0  0  0 22
22  0  0  0  0  0  0  0  0  0  0  0  0  0  0 22
22  0  0  0  0  0  0 31  0  0 32  0  0 33  0 22
22  0  0  0  0  0  0  0  0  0  0  0  0  0  0 22
22  0  0  0  0  0  0  0  0  0  0  0  0  0  0 22
22  0  0  0  0  0  0  0  0  0  0  0  0  0  0 22
22  0  0  0  0  0  0  0  0  0  0  0  0  0  0 22
22  0  0  0  0 34  0  0 35  0  0  0  0  0  0 22
22  0  0  0  0  0  0  0  0  0  0  0  0  0  0 21
22  0  0  0  0  0  0  0  0  0  0  0  0  0 27 27
21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21
)

##imgspr

##viewpx ##viewpy ##viewpz

	
#tsize 16 
#tmul

#mpx #mpy
#mw 16 #mh 12
#marena * 8192

:]map | x y -- map
	mw * + 3 << 'marena + @ ;
	
:calc tsize viewpz *. 'tmul ! ;

::posmap | x y -- xs ys
	swap tmul * viewpx + tmul 2/ +
	swap tmul * viewpy + tmul 2/ +
	;
	
:drawtile
	|$ffffff sdlcolor postile tmul dup sdlRect
	a@+ $ff and 0? ( drop ; ) >r
	2dup swap posmap viewpz r> 1- imgspr sspritez
	;
	
::draw.map | x y --
	|'mvy ! 'mvx !
	'marena >a
	0 ( mh <? 
		0 ( mw <? 
			drawtile
			1+ ) drop
		1+ ) drop ;

:cpylevel | 'l --
	>b
	'marena >a
	mw mh * ( 1?
		cb@+ a!+
		1- ) drop ;

#xp 1 #yp 1 | position
#dp 0	| direction
#ap 0	| anima
#penergy
#pcarry

::resetplayer
	100 'penergy !
	0 'pcarry ! 
	1 'xp ! 1 'yp !
	'level0 cpylevel
	;

::player
	xp yp posmap
	viewpz
	dp 3 * 
	msec 7 >> abs 3 mod +
	imgspr sspritez
	;

:movepl | dx dy --
	yp + swap xp + swap
	2dup
	]map 1? ( 3drop ; ) drop
	'yp ! 'xp !
	;
	
::iup 2 'dp ! 0 -1 movepl ;
::idn 3 'dp ! 0 1 movepl ;
::ile 1 'dp ! -1 0 movepl ;
::iri 0 'dp ! 1 0 movepl ;
::ijm 
::ipu
	;

|------ IO interface 
:istep 
:icheck 
:itake 
:ileave
	;

#wordt * 80
#words "step" "check" "take" "leave"  0
#worde	istep icheck itake ileave
#wordd ( $f1 $f1 $f1 $f1 $00 ) 

::bot.reset
	;

::bot.ini
	tsize dup "media/img/arena-map.png" ssload 'imgspr !
	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio
	sw 2/ 'viewpx !
	sh 2/ 'viewpy !
	2.0 'viewpz !
	calc
	;

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
	
