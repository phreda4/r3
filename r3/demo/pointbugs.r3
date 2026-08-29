| from many posts of @yuruyurau
|
^r3/lib/sdl2gfx.r3
^r3/lib/math.r3
^r3/lib/color.r3
^r3/util/immi.r3

#t #m #k #e #d #p #c 
#s #q #y #xp #yp

#SCALEX #SCALEY

| trig in radians
:rsin | rad -- s
	0.1591549 *. sin ;
:rcos | rad -- s
	0.1591549 *. cos ;


:qpoint0 | i --
	dup int. $f and 13.0 * 'm !
	dup 5.0 *. rcos 9.0 *. over rsin *. 'k !
	dup 3.0 *. rcos 9.0 *. over 2* rcos *. 'e !

	k dup *. e dup *. + sqrt.
	dup dup *. *. 1999.0 /. 1.5 +
	t 2/ m + rsin dup dup *. *. 3.0 /. -
	'd !

	d 4 >> t 48.0 /. - m + 'c !

	d dup *. t - m + rsin
	d swap pow. 'p !

	k $ff0000 and e $ff00 and or m $ff and or |$ffffff 
	color
	
	c rsin 99.0 *. k p *. + 200.0 + 
	SCALEX *. int.
	c 2 << rsin 99.0 *. e p *. + 200.0 + 
	SCALEY *. int.
	point ;

|------------ 
#colormode
#colortime

:setcolor | --
	t 2/ 'colortime !
	xp 0.01 *. colortime + rsin 0.5 *. 0.5 + |'phase1 !
	colortime 0.0555 *. + |'hue !
	yp 0.1 *. colortime 1.3 *. + rsin 0.5 *. 0.5 + |'phase2 !
	0.4 *. 0.6 + |'sat !
	d 0.5 *. colortime 0.7 *. + rsin 0.5 *. 0.5 + |'phase3 !
	0.2 *. 0.8 +
	t 2.0 *. xp 0.001 *. + rsin abs 0.5 + |'bright ! 
	*. 1.0 min |'val !
	hsv2rgb 
	color ;
	
:qpoint1 | xin --
	dup 235.0 /. 'y !
	dup 11.0 /. 8.0 t *. + rsin 4.0 +
	over 14.0 /. rcos *. 'k !
	y 9.0 /. 19.0 - 'e !
	k dup *. e dup *. + sqrt.
	y 9.0 /. 3.0 t *. + rsin + 'd !
	k 2.0 *. rsin 2.0 *.
	y 17.0 /. rsin k *.
	y d 3.0 *. - rsin 2.0 *. 9.0 +
	*. + 'q !
	d dup *. 49.0 /. t - 'c !
	q c rcos 50.0 *. + 200.0 + 'xp !
	d 39.0 *. q c rsin *. + 440.0 - 'yp !
	setcolor

	xp SCALEX *. int. 
	yp SCALEY *. int.
	point ;
	
|------------ 2	
:setcolor | col --
	dup 155 + $ff and 8 << swap
	255 swap - $ff and or
	$ff0000 or color ;

:qpoint2 | xin --
	dup 235.0 /. 'y !
	dup 21.0 /. rcos 2 << 'k !

	y 8.0 /. 20.0 - 'e !
	k dup *. e dup *. + sqrt. 'd !

	k 2* rsin 3.0 *.
	0.3 k /. +
	y 19.0 /. rsin k *.
	e 14.0 *. d 3.0 *. - t 2.0 *. + rsin 2.0 *. 9.0 +
	*. + 'q !
	d t - 'c !

	k 3.0 *. rsin 100.0 *. int. 
	setcolor

	q c rcos 50.0 *. + 200.0 + 
	SCALEX *. int.

	q c rsin *. d 39.0 *. + 475.0 - 
	SCALEY *. int.
	point ;	
	
|------------ 3
:setcolor | col --
	dup 155 + $ff and 8 << swap
	255 swap - $ff and or
	$ff0000 or color ;
:nbr
	19.0 <? ( t 3.0 *. d 4.0 *. + ; ) 
	d 2.0 /. 4.0 + ;
	
:qpoint3 | iin -- iin
	dup $10000 and 9 * 'm !
	dup 81.0 /. rcos 9.0 *. 'k !
	dup 765.0 /. 13.0 - 'e !
	|k dup *. e dup *. + sqrt. 4.0 /. 'd !
	k e distfast 2 >> 'd !
	k k *. nbr nip |'branch ! drop
	79.0
	k 3.0 *. rsin 2* -
	swap rsin 2/ k *.
	d d *. e 6.0 /. - t - m + rsin 5.0 *. 9.0 +
	*. + 'q !
	d d *. 9.0 /. t 16.0 /. - m + 'c !

	k 3.0 *. rsin 100.0 *. int. 
	setcolor
	q c rsin *. 200.0 + 
	SCALEX *. int.
	q 50.0 + c rcos *. 200.0 + 
	SCALEY *. int.
	point ;
	
#cntpoints 10000.0
#addpoints 0.25

#addtime 0.25
#limtime 1000.0
#qpoint 'qpoint0

:curve | --
	0.0 ( cntpoints <?
		qpoint ex addpoints +
		) drop ;
		
:advance-t | --
	t addtime + 
	limtime >? ( limtime - ) 
	't ! ;

:form0
	10000.0 'cntpoints !
	0.25 'addpoints !
	0.25 'addtime !
	1000.0 'limtime !
	'qpoint0 'qpoint !	
	;

:form1
	12000.0 'cntpoints !
	0.5 'addpoints !
	3.14159265 240.0 /. 'addtime !
	1000.0 'limtime !
	'qpoint1 'qpoint !	
	;

:form2
	10000.0 'cntpoints !
	1.0 'addpoints !
	0.0125 'addtime !
	6.2831853 'limtime !
	'qpoint2 'qpoint !	
	;

:form3
	20000.0 'cntpoints !
	1.0 'addpoints !
	0.125 'addtime !
	100.53096 'limtime !
	'qpoint3 'qpoint !	
	;

:draw
	0 cls
	curve
	
	advance-t
	
	uiStart
	8 4 uiPading
	$ffffff txrgb
	0.05 %h uiN
	
	"Points Bugs" uiLabelC
	
	0.2 %w uiE
	stDang 'exit "Exit" uiRbtn		
	ui.. stLink 
	5000.0 20000.0 'cntpoints uiSliderf 
	0.0 2.0 'addtime uiSliderf 
	
	stDark 
	'form0 "frm 0" uiCBtn 
	'form1 "frm 1" uiCBtn 
	'form2 "frm 2" uiCBtn 
	'form3 "frm 3" uiCBtn 
	uiEnd
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"point bugs" 800 600 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 20 txload txfont
	800.0 400.0 /. 'SCALEX !
	600.0 400.0 /. 'SCALEY !
	0.0 't !
	'draw SDLshow
	SDLquit ;

: main ;
