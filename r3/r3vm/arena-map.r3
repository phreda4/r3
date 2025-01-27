| arena MAP
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3

^./rcodevm.r3

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
	ap anim>n
	imgspr sspritez
	
	deltatime 'ap +!
	;

:movepl | dx dy --
	yp + swap xp + swap
	2dup
	]map 1? ( 3drop ; ) drop
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
	]map 32 << 
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

	sw 2/ 'viewpx !
	sh 2/ 'viewpy !
	2.0 'viewpz !
	calc
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
	
