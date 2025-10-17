| gui v.3
| 
| PHREDA 2025
|
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

|--- Layout
#flFsize 18

#fx #fy #fw #fh 
#flpadx 0 #flpady 0
#flcols 1 #flrows 1 #flcur 0
#flcolm	1 #flrowm 1
##cx ##cy ##cw ##ch | cursor

:f2c
	flpadx fw over 2* - 'cw ! fx + 'cx !
	flpady fh over 2* - 'ch ! fy + 'cy ! ;

::%cw fw 16 *>> ;
::%ch fh 16 *>> ;

::uiPading | x y --
	'flpady ! 'flpadx ! f2c ;
	
#flstack * 64 | 8 niveles
#flstack> 'flstack

:fl>now | v --
	w@+ 'fx ! w@+ 'fy ! w@+ 'fw ! w@ 'fh ! ;
	
::uiValid? | -- 0= not valid
	cw 1 <? ( drop 0 ; ) drop 
	ch 1 <? ( drop 0 ; ) drop 
	-1 ;

:xywh>fl | x y w h -- v
	$ffff and 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or ; | hhwwyyxx
	
::uiBox | x y w h --
	2over 'fy ! 'fx ! 2dup 'fh ! 'fw ! 
	xywh>fl 'flstack !+ 'flstack> ! 
	f2c ;
	
::uiFull | --
	0 0 sw sh uiBox ;
	
:flx+! flstack> 8 - dup w@ rot + clamp0 swap w! ;
:fly+! flstack> 8 - 2 + dup w@ rot + clamp0 swap w! ;
:flw+! flstack> 8 - 4 + dup w@ rot + clamp0 swap w! ;
:flh+! flstack> 8 - 6 + dup w@ rot + clamp0 swap w! ;
	
::uiPush	fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
::uiPop		-8 'flstack> +! flstack> fl>now f2c ;
:uiGet		flstack> 8 - fl>now ;
::uiRest	uiGet f2c ;

| N=^ S=v E=> O=<
| - is full minus the number
::uiN | lineas --
	-? ( fh + ) uiGet dup fly+! dup neg flh+!	'fh ! f2c ;
::uiS | lineas --
	-? ( fh + ) uiGet dup neg flh+! fh fy + over - 'fy ! 'fh ! f2c ;
::uiE | cols --
	-? ( fw + ) uiGet dup neg flw+! fw fx + over - 'fx ! 'fw ! f2c ;
::uiO | cols --
	-? ( fw + ) uiGet dup flx+! dup neg flw+! 'fw ! f2c ;
	
::uiAt | x y --
	flrowm dup flpady 2* - 'ch !
	* fy + flpady + 'cy !
	flcolm dup flpadx 2* - 'cw !
	* fx + flpadx + 'cx ! ;
	
::uiTo | w h -- 
	flrowm * flpady 2* - 'ch !
	flcolm * flpadx 2* - 'cw ! ;

::uiGrid | c r -- ; adjust for fit
	2dup 'flrows ! 'flcols ! 0 'flcur !
	fh swap /mod dup 2/ 'fy +! neg 'fh +! 'flrowm !
	fw swap /mod dup 2/ 'fx +! neg 'fw +! 'flcolm !
	0 0 uiAt ;
	
::uiNext	
::uiNextV
	flcur 1+ 
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod swap uiAt ;
::uiNextH
	flcur 1+
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod uiAt ;
	
::flFontSize
	;
	
|---- IMMGUI
#id	#idh #ida 	| now hot active
#idf #idfh #idfa | focus
#wid #wida	| panel now active
#mdrag #mdragh	| drag place

#flag
#keymd
#uistate

:flagClear 
	0 'flag ! ;
:flagEx!
	flag 1 or 'flag ! ;
::uiEx?
	flag 1 and ;

::uiStart
	uiFull
	idfh -? ( id nip ) id >? ( 0 nip ) dup 'idf ! 'idfh !
	idh 'ida ! -1 'id !
	mdragh 'mdrag ! -1 'mdragh ! 
	0 'wid ! 
	sdlkey
	<shift> =? ( keymd 1 or 'keymd ! ) 
	>shift< =? ( keymd 1 nand 'keymd ! ) 
	drop
	;

| 0 = normal
| 1 = over (not all sytems)
| 2 = in
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click
:uIn? | x y -- 0/-1
	sdlx cx - $ffff and cw >? ( drop 0 ; ) drop
	sdly cy - $ffff and ch >? ( drop 0 ; ) drop 
	-1 ;

:stMouse | -- state
	flagClear 
	1 'id +! 
	ida -1 =? ( drop 			| no active
		uIn? 0? ( ; ) drop		| out->0
		sdlb 0? ( drop 1 ; ) drop	| over->1
		id 'idh ! -1 'idfh ! 1 ; )	| in->2(prev)
	id <>? ( drop 0 ; ) 	|	 active no this->0
	idfh <>? ( 'idfh ! 2 ; ) | in->2
	drop
	uIn? 0? ( drop
		sdlb 1? ( drop 4 ; ) drop	| active out->4
		-1 'idh ! 5 ; ) drop		| out up->5
	sdlb 1? ( drop 3 ; ) drop 		| active->3
	-1 'idh ! 6 ; 					| click->6		

| 0 - No
| 1 - Start focus
| 2 - In focus
:stFocus | -- flag
	id 
	idf <>? ( drop 0 ; )
	wid 1- 'wida ! 
	idfa <>? ( 'idfa ! $10 ; ) | in 
	drop $20 ; | stay

|-- interactive box
::uiUser
	stMouse stFocus or 'uistate ! ;
	
|-- place to go in drag (index n)	
::uiBoxIn | n --
	uIn? 0? ( 2drop ; ) drop 'mdragh ! ;

|-- interact	
::uiDwn		uiState $f and 2 <>? ( 2drop ; ) drop ex ; | 'v --
::uiSel		uiState $f and 3 <? ( 2drop ; ) drop ex ;  | 'v --
::uiClk		uiState $f and 6 <>? ( 2drop ; ) drop ex ; | 'v --
::uiUp		uiState $f and 5 <? ( 2drop ; ) drop ex ;  | 'v --

::uiFocusIn uiState $10 nand? ( 2drop ; ) drop ex ;
::uiFocus 	uiState $20 nand? ( 2drop ; ) drop ex ;

::uiRefocus	-1 'idfa ! ;
::uiFocus>> 1 'idfh +! ; | cambia id y luego wid
::uiFocus<< -1 'idfh +! ;

:ui+a
	dup 'cx +! 'cy +! ;
:ui+c
	dup ui+a
	2* neg dup 'cw +! 'ch +! ;
	
|---- draw
#recbox [ 0 0 0 0 ] | for sdl2

:c2recbox
	ch cw cy cx 'recbox d!+ d!+ d!+ d! ;
	
::uiFill
	cx cy cw ch SDLFRect ;
::uiRect
	cx cy cw ch SDLRect ;
::uiRFill | round --
	cx cy cw ch SDLFRound ;
::uiRRect | round --
	cx cy cw ch SDLRound ;
::uiCRect
	cw ch min 2/ cx cy cw ch SDLRound ;
::uiCFill
	cw ch min 2/ cx cy cw ch SDLFRound ;
::uiTexture	| texture --
	c2recbox 'recbox swap SDLImageb ;

|---- widget	

::uiText | "" align --
	txalign >r cw ch cx cy r> txText ;	
	
:kbBtn
	$ffffff sdlcolor 10 uiRrect 
	sdlkey 
	<ret> =? ( flagEx! )
	drop ;
	
::uiBtn | 'click "" align --	
	uiUser
	'flagex! uiClk
	[ 4 ui+a ; ] uiSel 
	10 uiRFill 
	'kbBtn uiFocus
	uiText
	uiEx? 0? ( 2drop ; ) drop ex ;

|--------------------------------	
:uiTest
	uiUser
	8 cx cy cw ch SDLFRound 
	ch cw cy cx "x:%d y:%d;w:%d h:%d"
	sprint $11 uiText
	[ $ffffff sdlcolor 10 uiRrect ; ] uiFocus
	;

:uit2
	uiCRect
	ch cw cy cx "x:%d y:%d;w:%d h:%d"
	sprint $11 uiText
	;

#font1
#ali

:tt
"Texto muy largo
y con varias lineas
para ver como se comporta
cuando cambia de tamanio"
	ali uiText	
	;

:grillain
	4 3 uiGrid
	4 3 * ( 1? 1-
		uit2 dup "%d" sprint $11 uiText
		uiNext ) drop
	;

:test1
	|0.1 %w 0.1 %h 0.5 %w 0.8 %h uiBox
	4 4 uiPading
	$7f00 sdlcolor
	0.1 %h uiN 
		uiTest
	$3f00 sdlcolor	
	0.1 %h uiN 
		uiTest
	$7f0000 sdlcolor		
	3 32 * uiS 
		uiTest
	$3f0000 sdlcolor				
	4 32 * uiO 
		uiTest
	$7f sdlcolor				
	8 32 * uiE 
	uiPush
		4 32 * uiN 	
			|uiTest
			'exit "Salir" $11 uiBtn
|		$3f sdlcolor							
|		uiRest
	uiPop
	uiTest
	$7f7f sdlcolor					
	uiRest
	grillain
	;

|---------------
#cart "normal" "over" "in" "active" "active(outside)" "out" "click"

#pad * 64
:bbt
	uiUser
	8 uiRFill
	'cart uistate $f and n>>0 
	$11 uiText
	0 'pad !
	[ "dn " 'pad strcat ; ] uiDwn
	[ "sel " 'pad strcat ; ] uiSel
	[ "clk " 'pad strcat ; ] uiClk
	[ "up " 'pad strcat ; ] uiUp	
	'pad $00 uiText
	;
	
	
:test2
	$7f0000 sdlcolor
	50 50 200 100 uiBox
	bbt
	
	$7f00 sdlcolor
	100 120 200 100 uibox
	bbt
	
	$7f sdlcolor
	300 50 200 100 uiBox
	bbt
	;
	
|-----------------------------
:main
	0 SDLcls
	font1 txfont
	
	uiStart
	test2
	50 sleep
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( ali $1 + $33 and 'ali ! )
	<f2> =? ( ali $10 + $33 and 'ali ! )
	<tab> =? ( keymd 
		1 and? ( uiFocus<< )
		1 nand? ( uiFocus>> )
		drop )	
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinitR
	
	"media/ttf/Roboto-bold.ttf" 20 txloadwicon 'font1 !
 	20 flFontSize
	
	'main SDLshow
	SDLquit 
	;
