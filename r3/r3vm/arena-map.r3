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

#mrot 0.0
#tzoom 2.0
#tsize 16 
#tmul

#mvx 8 #mvy 64
#mw 16 #mh 12
#marena * 8192

:]map | x y -- map
	mw * + 3 << 'marena + @ ;
	
:calc tsize tzoom *. 'tmul ! ;

:posspr | x y -- xs ys
	swap tmul * mvx + tmul 2/ +
	swap tmul * mvy + tmul 2/ +
	;
	
:drawtile
	|$ffffff sdlcolor postile tmul dup sdlRect
	a@+ $ff and 0? ( drop ; ) >r
	2dup swap posspr tzoom r> 1- imgspr sspritez
	;
	
::mapdraw | x y --
	'mvy ! 'mvx !
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
	xp yp posspr
	tzoom
	dp 2* 
	msec 7 >> $1 and +
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

|------ IO interface 0
#wordt * 80

#words "up" "down" "left" "right" "jump" "push" 0
#worde	iup idn ile iri ijm ipu
#wordd ( $00 $00 $00 $00 $00 $00  ) 

::map-ins0
	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio
	;
	
|------ IO interface 1	
#words "step" "check" "get" "put"  0
#worde	iup idn ile iri ijm ipu
#wordd ( $f1 $f1 $f1 $f1 $00 $00  ) 

::map-ins1
	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio
	;
	
::arena.ini
	tsize dup "media/img/arena-map.png" ssload 'imgspr !
	calc
	;
