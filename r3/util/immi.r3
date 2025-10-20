| gui v.3
| immediate mode inteface
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
	flcur 1+ 
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod swap uiAt ;
	
::uiNextV
	flcur 1+
	flrows flcols * >? ( 0 nip )
	dup 'flcur !
	flcols /mod uiAt ;
	

|---- IMMGUI
#id	#idh #ida 	| now hot active
#idf #idfh #idfa | focus
#wid #wida	| panel now active
##mdrag 	| drag place <<<
#mdragh	

#flag
##keymd		| key modify <<<
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
::uiPlace | n --
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

:tabfocus
	keymd 1 and? ( drop uiFocus>> ; ) drop uiFocus<< ;
	
:ui+a
	dup 'cx +! 'cy +! ;
:ui+c
	dup ui+a
	2* neg dup 'cw +! 'ch +! ;
	
|---- Draw words 
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

::uiLineGridV
	fx flcolm +
	flcols 1- ( 1? 1-
		over fy fh over + sdlLineV
		swap flcolm + swap ) 2drop ;
		
::uiLineGridH
	fy flrowm +
	flrows 1- ( 1? 1-
		fx pick2 fw pick2 + sdlLineH
		swap flrowm + swap ) 2drop ;
	
::uiLineGrid
	uiLineGridH uiLineGridV ;

|---- Style
|  disable|focus|over|normal
#colBac	$333333 | background
#colFil $00007f | fill
#colBor	$888888 | borde
#colTxt $aaaaaa | texto
#colFoc $ffffff 

:colBack
	colBac sdlcolor ;
:colFill
	colFil sdlcolor ;
:colBorde
	colBor sdlcolor ;
:colText
	colTxt txrgb ;
:colFocus
	colFoc sdlcolor ;

|---- widget	
:ttwrite | "text" --
	cx
	ch txh - 2/ cy +
	txat txwrite ;

:ttwritec | "text" --
	txw txh | "" w h  
	cw rot - 2/ cx +
	ch rot - 2/ cy +
	txat txwrite ;

:ttwriter | "text" --
	txw txh | "" w h  
	cw cx + rot -
	ch rot - 2/ cy +
	txat txwrite ;
	
::uiLabel
	ttwrite	;
	
::uiLabelC
	ttwritec ;
	
::uiLabelR
	ttwriter ;

::uiText | "" align --
	txalign >r cw ch cx cy r> txText ;	

	
:kbBtn
	sdlkey 
	<ret> =? ( flagEx! )
	<tab> =? ( tabfocus ) 
	drop ;
	
::uiTBtn | 'click "" align --	
	uiUser
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill 8 uiRFill 
	[ kbBtn colFocus 8 uiRrect ; ] uiFocus
	colText uiText
	uiEx? 0? ( 2drop ; ) drop ex ;
	
::uiBtn | 'click "" --	
	uiUser
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill uiFill 
	[ kbBtn colFocus uiRect ; ] uiFocus
	colText uiLabelc
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiRBtn | 'click "" --	
	uiUser
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill 6 uiRFill 
	[ kbBtn colFocus 6 uiRRect ; ] uiFocus
	colText uiLabelc
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiCBtn | 'click "" --	
	uiUser
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill uiCFill 
	[ kbBtn colFocus uiCRect ; ] uiFocus
	colText uiLabelc
	uiEx? 0? ( 2drop ; ) drop ex ;

|---- Horizontal slide
:slideh | 0.0 1.0 'value --
	sdlx cx - cw clamp0max 
	2over swap - | Fw
	cw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	colBack uiFill
	[ kbBtn colFocus uiRect ; ] uiFocus
	colFill
	dup @ pick3 - 
	cw 8 - pick4 pick4 swap - */ cx 1+ +
	cy 2 + 
	6 ch 4 - 
	SDLFRect ;
	
::uiSliderf | 0.0 1.0 'value --
	uiUser
	'slideh uiSel | 'dn 'move --	
	slideshow
|	'focoBtn in/foco 
|	'clickfoco onClick	
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | 0 255 'value --
	uiUser
	'slideh uiSel | 'dn 'move --	
	slideshow
|	'focoBtn in/foco
|	'clickfoco uiClk		
	@ .d uiLabelC
	2drop ;	
	
|---- Vertical slide
:slidev | 0.0 1.0 'value --
	sdly cy - ch clamp0max 
	2over swap - | Fw
	ch */ pick3 +
	over ! ;
	
:slideshowv | 0.0 1.0 'value --
	ColBack uiFill
	[ kbBtn colFocus uiRect ; ] uiFocus	
	ColFill
	dup @ pick3 - 
	ch 8 - pick4 pick4 swap - */ cy 1+ +
	cx 2 + swap
	cw 4 - 6 
	SDLFRect ;

::uiVSliderf | 0.0 1.0 'value --
	uiUser
	'slidev uiSel
	slideshowv
|	'focoBtn in/foco 
|	'clickfoco onClick	
	@ .f2 uiLabelC
	2drop ;

::uiVSlideri | 0 255 'value --
	uiUser
	'slidev uiSel
	slideshowv	
|	'focoBtn in/foco 
|	'clickfoco onClick		
	@ .d uiLabelC
	2drop ;		
	
|----- list mem (intern)
#cntlist #indlist

:makeindx | 'adr -- 
	here dup 'indlist ! >a
	( dup a!+ >>0
		dup c@ 1? drop ) 2drop
	a> dup here - 3 >> 'cntlist !
	'here ! ;
	
::uiNindx | n -- str
	cntlist >=? ( drop "" ; )
	3 << indlist + @ ;

#listx #listy
|--------
:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colFill uiFill )
	|overl =? ( colBack uiFill )
	uiNindx 
	listx listy txat txwrite 
	txh 'listy +!
	;

::uiList | 'var 'list --
	uiUser
	mark makeindx
	ch txh / | 'var cntlineas
	cx 'listx !
	cy 'listy !
	|mouList
	|focList
	0 ( over <? ilist 1+ ) drop
|	cscroll
	2drop
	empty ;	
	