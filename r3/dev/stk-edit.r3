| stk edit
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/lib/vdraw.r3
^r3/util/arr16.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlbgui.r3
^r3/util/dlgcol.r3

#maxres $40 	| 64
#maxres2 $1000	| 64x64

#model
#mx #my #mz
#nx #ny #nz

#ssheet 0 0
#obj 0 0

| -- mem
:now2memx	nx maxres * 2 << model + ;
:now2memy	ny 2 << model + ;
:now2memz	nz maxres2 * 2 << model + ; 
| x y -- mem	
:xy2memx	maxres2 * + 2 << now2memx + ;	
:xy2memy	maxres * swap maxres2 * + 2 << now2memy + ;
:xy2memz	maxres * + 2 << now2memz + ;

#xymem 'xy2memz

:adri | x y -- adr
	swap 0 <? ( 2drop 0 ; ) maxres >=? ( 2drop 0 ; )
	swap 0 <? ( 2drop 0 ; ) maxres >=? ( 2drop 0 ; )
	xymem ex ;

:pntset | x y --
	adri 0? ( drop ; ) 
	colord swap d! ;

:pntget | x y -- c
	adri 0? ( ; ) d@ ;

|------ draw in panels
#xscr #yscr
#xa #ya

:xypen	sdlx sdly ;
:xy2g	swap xscr - 2 >> swap yscr - 2 >> ;

|------------------- POINTS
:draw0in ;
:res0 ;
:in0dn xypen xy2g vop ; 
:in0move xypen xy2g vline ; 
:in0up ;

|------------------- LINE
:draw1in ;
:res1 ;
:in1dn xypen 'ya ! 'xa ! ; 
:in1move colord SDLColor xa ya xypen SDLLine ;
:in1up xa ya xy2g vop xypen xy2g vline ;

|------------------- RECT
:2sort
	over <? ( swap ) ;

:sortrect | x1 y1 x2 y2 -- x1 y1 w h
	rot 2sort over - | x1 x2 y1 h
	2swap 2sort over - | y1 h x1 w
	2swap rot swap ;
	
:draw2in ;
:res2 ;
:in2dn xypen 'ya ! 'xa ! ; 
:in2move colord SDLColor xa ya xypen sortrect SDLRect ;
:in2up xa ya xy2g xypen xy2g vrect ;

|------------------- FRECT
:draw3in ;
:res3 ;
:in3dn xypen 'ya ! 'xa ! ; 
:in3move colord SDLColor xa ya xypen sortrect SDLRect ;
:in3up xa ya xy2g xypen xy2g vfrect ;

|------------------- CIRC
:border2cenrad
	rot 2dup + 2/ >r - abs 2/ >r
	2dup + 2/ >r - abs 2/ r> r> swap r> ;			| xr yr xm ym

:draw4in ;
:res4 ;
:in4dn xypen 'ya ! 'xa ! ; 
:in4move colord SDLColor xa ya xypen border2cenrad SDLEllipse ; 
:in4up xa ya xy2g xypen xy2g border2cenrad vellipseb ; 

|------------------- FCIRC
:draw5in ;
:res5 ;
:in5dn xypen 'ya ! 'xa ! ; 
:in5move colord SDLColor xa ya xypen border2cenrad SDLEllipse ; 
:in5up xa ya xy2g xypen xy2g border2cenrad vellipse ; 

|------------------- FILL
:draw6in ;
:res6 ;
:in6dn ; 
:in6move colord xypen xy2g vfill ; 
:in6up ;


|-------------------
| point line rect frect circle fcircle fill paint select magic

#mode0 'draw0in 'in0dn 'in0move 'in0up 'res0 
#mode1 'draw1in 'in1dn 'in1move 'in1up 'res1 
#mode2 'draw2in 'in2dn 'in2move 'in2up 'res2 
#mode3 'draw3in 'in3dn 'in3move 'in3up 'res3
#mode4 'draw4in 'in4dn 'in4move 'in4up 'res4 
#mode5 'draw5in 'in5dn 'in5move 'in5up 'res5 
#mode6 'draw6in 'in6dn 'in6move 'in6up 'res6

#moded 'mode0

:mode! | m --
	|inreset
	dup 4 ncell+ @ ex 'moded ! ;
	
|--------------
#inix #iniy
:showlayerx | adr x y
	'iniy ! 'inix !
	now2memx >a
	0 ( my <? 
		0 ( mx <? 
				da@+ sdlcolor 
				over 2 << iniy + 
				over 2 << inix +
				swap 4 4 sdlfrect
			1+ ) drop
			maxres2 mx - 2 <<  a+
		1+ ) drop ;

:showlayery | adr x y
	'iniy ! 'inix ! 
	now2memy >a
	0 ( my <? 
		0 ( mx <? 
				da@ sdlcolor maxres2 2 << a+
				over 2 << iniy + 
				over 2 << inix +
				swap 4 4 sdlfrect
			1+ ) drop
			maxres maxres2 mx * - 2 << a+
		1+ ) drop ;

:showlayerz | x y --
	'iniy ! 'inix !
	now2memz >a
	0 ( my <? 
		0 ( mx <? 
				da@+ sdlcolor
				over 2 << iniy + 
				over 2 << inix +
				swap 4 4 sdlfrect
			1+ ) drop
		maxres mx - 2 << a+
		1+ ) drop ;

#vx1 #vx2 #vy1 #vy2	
#xwm #ywm #wwm #hwm

:drawframe 
	over 1- over 1- wwm 2 + hwm 2 + sdlrect ;
	
:movrulex sdlx pick3 - 2 >> over ! ;
	
:rulerx | x y n --
	pick2 pick2 8 - wwm 6 guibox 'movrulex dup onDnMoveA
	pick2 pick2 hwm + 2 + wwm 6 guibox 'movrulex dup onDnMoveA
	@ >r
	over r@ 2 << + 2 - over 8 - 4 6 sdlfrect
	over r> 2 << + 2 - over hwm + 2 + 4 6 sdlfrect ;

:movruley sdly pick2 - 2 >> over ! ;
	
:rulery | x y n --
	pick2 8 - pick2 6 hwm guibox 'movruley dup onDnMoveA
	pick2 wwm + 2 + pick2 6 hwm guibox 'movruley dup onDnMoveA
	@ >r
	over 8 - over r@ 2 << + 2 - 6 4 sdlfrect
	over wwm + 2 + over r> 2 << + 2 - 6 4 sdlfrect ;

:exmode	
	moded @+ ex @+ swap @+ swap @ onMapA ; | 'dn 'move 'up --	
	
:views
	'xy2memx 'xymem !
	vx1 xwm + vy1 ywm +
	2dup 'yscr ! 'xscr !
	$ff0000 sdlcolor drawframe
	$ff sdlcolor 'nz rulerx
	$ff00 sdlcolor 'ny rulery
	2dup wwm hwm guibox
	showlayerx exmode	
	
	'xy2memy 'xymem !
	vx2 xwm + vy2  ywm +
	2dup 'yscr ! 'xscr !
	$ff00 sdlcolor drawframe
	$ff0000 sdlcolor 'nx rulerx
	$ff sdlcolor 'nz rulery
	2dup wwm hwm guibox
	showlayery exmode	

	'xy2memz 'xymem !
	vx1 xwm + vy2 ywm +
	2dup 'yscr ! 'xscr !
	$ff sdlcolor drawframe
	$ff0000 sdlcolor 'nx rulerx
	$ff00 sdlcolor 'ny rulery
	2dup wwm hwm guibox	
	showlayerz exmode	

	$888888 sdlcolor
	vx2 vy1 sw pick2 - sh 2/ pick2 - sdlrect | ISO
	;
|---------------------------------------

:redoingmodel	
	;
	
	
:workarea
	views
|	128 32 sw pick2 - sh pick2 - guibox
	;
	
:resetv
	128 'vx1 !
	32 'vy1 !
	sw 128 - 2/ 128 + 'vx2 !
	sh 32 - 2/ 32 + 'vy2 !
	mx 2 << 'wwm ! my 2 << 'hwm !
	sw 128 - 2/ mx 2 << - 2/ 'xwm ! 
	sh 32 - 2/ my 2 << - 2/ 'ywm !
	;
	
|-------------------
:main
	timer.
	immgui 
	0 sdlcls

	dlgColor
	
	$696969 sdlcolor 0 0 sw 32 sdlfrect
	$ffffff bcolor
	0 0 bat " Stk-Edit" bprint2 

	workarea
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( 'mode0 mode! )
	<f2> =? ( 'mode1 mode! )
	<f3> =? ( 'mode2 mode! )
	<f4> =? ( 'mode3 mode! )
	<f5> =? ( 'mode4 mode! )
	<f6> =? ( 'mode5 mode! )
	<f7> =? ( 'mode6 mode! )
	<esp> =? ( redoingmodel )
	drop ;
	
:reset
	timer<
	'ssheet p.clear
	'obj p.clear
|	inreset
	
	64 'mx ! 64 'my ! 64 'mz !	| size
	31 'nx ! 31 'ny ! 31 'nz !		| layer now
	resetv
	
	|model ( here <? dup swap d!+ ) drop
	;
	
|-------------------
: |<<< BOOT <<<
	"Stk-Edit" 1024 700 SDLinit |R | no resize
	bfont1
	
	0 32 xydlgColor!
	dlgColorIni
	
	'pntset vset!
	'pntget vget!
	maxres dup vsize!
	
	32 'ssheet p.ini
	50 'obj p.ini
	
	| ---- MEM MAP ----
	here dup 'model !
	maxres dup dup * *
	2 << | add paleta !!
	|$1fffff  | 64^3 limit
	+ 'here !
	
	reset
	'main SDLshow
	SDLquit 
	;