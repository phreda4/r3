| reanimator
| PHREDA 2024
|-------------------------
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3
^r3/util/immi.r3

#font
#ssheet 0 0
#obj 0 0
#fx 0 0
#point 0 0

| sprite
| x y a/z ani ss z 
| 1 2 3   4   5  6 
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.az 3 ncell+ ;
:.ani 4 ncell+ ;
:.ss 5 ncell+ ;
:.z 6 ncell+ ;

:drawspr | arr -- arr
	dup 8 + >a
	a@+ int. a@+ int. | x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a> ani+timer! a@+ aniFrame
	a@+ sspriterz
	;
|------------------- viewport
#viewx #viewy #viewz #viewr

|------------------- input points
#inpoly
#inpoly>

:2p 32 << or ; | x y -- v
:p2 dup 32 << 32 >> swap 32 >> ; | v -- x y 

:inreset inpoly 'inpoly> ! ;

:>poly 2p inpoly> !+ 'inpoly> ! ; | x y --
:+poly 2p 
	inpoly> 8 - @ =? ( drop ; ) 
	inpoly> !+ 'inpoly> ! ; | x y --
:poly< -8 'inpoly> +! ;

|------------------- LINE
:draw0in
	$ffffff color
	inpoly >a a@+ p2 
	( a> inpoly> <? drop
		a@+ p2 2swap 2over line
		) 3drop ;

:res0 ;
:in0dn inreset sdlx sdly >poly ;
:in0move sdlx sdly +poly ;
:in0up ;

|------------------- POINTS
:draw1in
	$ffffff color
	inpoly ( inpoly> <? 
		@+ p2 5 5 2swap fellipse
		) drop ;

:res1 ;
:in1dn sdlx sdly +poly ;
:in1move poly< sdlx sdly +poly ;
:in1up ;

|------------------- VIEWPORT
#vax #vay #vaz 

:draw2in ;
:res2 ;
:in2dn sdlx 'vax ! sdly 'vay ! viewz 'vaz ! ;
:in2move ;
:in2up ;


|-------------------
#mode0 'draw0in 'in0dn 'in0move 'in0up 'res0 
#mode1 'draw1in 'in1dn 'in1move 'in1up 'res1
#mode2 'draw2in 'in2dn 'in2move 'in2up 'res2

#moded 'mode1

:mode! | m --
	inreset
	dup 4 ncell+ @ ex 'moded ! ;
	
:workarea
	$ffffff color
	64 32 sw 64 - pick2 - sh 128 - pick2 -
	2over 2over rect
	uiZoneBox

	moded
	@+ ex
	@+ uiDwn
	@+ uiSel
	@ uiUp
	uiBackBox
	;
	
|-------------------
:main
	timer.
	uiStart
	0 cls
	font txfont
	$696969 color
	0 0 sw 32 frect
|	$ffffff color
|	0 32 64 sh 32 - rect
|	sw 64 - 32 64 sh 32 - rect
|	0 sh 128 - sw 128 rect
	
	$ffffff txrgb
	0 0 txat "ReAnimator" txprint 
	
	0 32 txat 
	inpoly> inpoly - 3 >> "%d" txprint
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
	'fx p.clear
	'point p.clear
	inreset
	sw 2/ 'viewx ! 
	sh 2/ 'viewy !
	1.0 'viewz !
	0.0 'viewr !
	;
	
|-------------------
: |<<< BOOT <<<
	"reAnimator" 1024 600 SDLinitR
	
	32 'ssheet p.ini
	100 'obj p.ini
	100 'fx p.ini
	100 'point p.ini
	here 'inpoly !
	$ffff 'here +!
	
	"media/ttf/RobotoMono-Bold.ttf" 24 txload 'font !
	reset
	'main SDLshow
	SDLquit 
	;