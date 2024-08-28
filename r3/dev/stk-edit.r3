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

:now2mem | -- inimem
	nz nx maxres * + ny maxres2 * + 2 << model + ;

#xscr #yscr
	
:xy2memx | x y -- mem
	maxres2 * + nz + 2 << now2mem + ;	

:xy2memy | x y -- mem
	maxres * swap maxres2 * + 2 << now2mem + ;
:xy2memz | x y -- mem
	maxres * + 2 << now2mem + ;

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
	
|------------------- POINTS
:posxy
	sdlx xscr - 2 >> sdly yscr - 2 >> ;

:draw0in
	;

:res0 ;
:in0dn posxy vop ; |inreset sdlx sdly >poly ;
:in0move 
	posxy vline
|	xymem ex
|	$000000 swap d!
	|"%d %d" .println 
	; |sdlx sdly +poly ;
	
:in0up ;

|------------------- LINE
:draw1in
	;

:res1 ;
:in1dn ; |sdlx sdly +poly ;
:in1move ; |poly< sdlx sdly +poly ;
:in1up ;

|------------------- VIEWPORT
#vax #vay #vaz 

:draw2in ;
:res2 ;
:in2dn ; |sdlx 'vax ! sdly 'vay ! viewz 'vaz ! ;
:in2move ;
:in2up ;


|-------------------
| point line rect circle fill paint select magic

#mode0 'draw0in 'in0dn 'in0move 'in0up 'res0 
#mode1 'draw1in 'in1dn 'in1move 'in1up 'res1 
#mode2 'draw2in 'in2dn 'in2move 'in2up 'res2 

#moded 'mode0

:mode! | m --
	|inreset
	dup 4 ncell+ @ ex 'moded ! ;
	
|--------------
#inix #iniy
:showlayerx | adr x y
	'iniy ! 'inix !
	now2mem >a
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
	now2mem	>a
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
	now2mem >a
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
	
:rulerx | n --
	>r over r@ 2 << + 2 - over 8 - 4 6 sdlfrect
	over r> 2 << + 2 - over hwm + 2 + 4 6 sdlfrect ;
	
:rulery | n --
	>r
	over 8 - over r@ 2 << + 2 - 6 4 sdlfrect
	over wwm + 2 + over r> 2 << + 2 - 6 4 sdlfrect ;
	
:views
	'xy2memx 'xymem !
	vx1 xwm + vy1 ywm +
	2dup 'yscr ! 'xscr !
	$ff0000 sdlcolor drawframe
	2dup wwm hwm guibox
	moded @+ ex @+ swap @+ swap @ onMapA | 'dn 'move 'up --	
	$ff sdlcolor nz rulerx
	$ff00 sdlcolor ny rulery
	showlayerx
	
	'xy2memy 'xymem !
	vx2 xwm + vy2  ywm +
	2dup 'yscr ! 'xscr !
	$ff00 sdlcolor drawframe
	2dup wwm hwm guibox
	moded @+ ex @+ swap @+ swap @ onMapA | 'dn 'move 'up --	
	$ff0000 sdlcolor nx rulerx
	$ff sdlcolor nz rulery
	showlayery

	'xy2memz 'xymem !
	vx1 xwm + vy2 ywm +
	2dup 'yscr ! 'xscr !
	$ff sdlcolor drawframe
	2dup wwm hwm guibox
	moded @+ ex @+ swap @+ swap @ onMapA | 'dn 'move 'up --	
	$ff0000 sdlcolor nx rulerx
	$ff00 sdlcolor ny rulery
	showlayerz

	$888888 sdlcolor
	vx2 vy1 sw pick2 - sh 2/ pick2 - sdlrect | ISO
	;
	
:workarea
	$ffffff sdlcolor
	
	views
	128 32 sw pick2 - sh pick2 -
|	2over 2over sdlrect 	
	guibox
	
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
	
	$696969 sdlcolor
	0 0 sw 32 sdlfrect
|	$ffffff sdlcolor
|	0 32 64 sh 32 - sdlrect
|	sw 64 - 32 64 sh 32 - sdlrect
|	0 sh 128 - sw 128 sdlrect
	
	$ffffff bcolor
	0 0 bat " Stk-Edit" bprint2 

	workarea
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( 'mode0 mode! )
	<f2> =? ( 'mode1 mode! )
	<f3> =? ( 'mode2 mode! )
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