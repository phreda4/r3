| gui v.3
| immediate mode inteface
| PHREDA 2025
|
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

|--- Layout
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
#idfl		| idf last

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
	drop ;

#uilastwidget 0
#uilastpos 0 
#uilaststy 0 0 0 0
#uiLastfont 0
#uidata1 0 
#uidata2 0 

:fitinwin | x y w h -- x y w h 
	2swap 	| w h x y 
	dup pick3 + sh - 0 max - 0 max swap | 1.0 %h
	dup pick4 + sw - 0 max - 0 max swap | 1.0 %w
	2swap ;

:isavepos | x y w h -- 
	'uilastpos w!+ w!+ w!+ w! ;
	
:iloadpos | --
	'uilastpos w@+ 'ch ! w@+ 'cw ! w@+ 'cy ! w@ 'cx ! ;
	

|------- LAST WIDGET
#idfs

::uiExitWidget
	idfs dup 'idfh ! 'idfa !
	0 'uilastwidget ! ;

::uiSaveLast | x y w h 'vector --
	'uiLastWidget !	| save vector
	isavepos
	| save style
|	'cx dims>64 'uilastpos !
|	'uilaststy 'cifil 3 move	|dsc style
	txFont@ 'uiLastfont !		| save font	
	idfa 'idfs !
	idfl dup 'idfh ! 'idfa !
	;
	
:uiBacklast |--
	iloadpos
	| pos style font
|	'cifil 'uilaststy 3 move 
	uiLastfont txfont ;
	
::uiEnd
	id 1+ 'idfl !
	uilastWidget 0? ( drop ; ) 
	idfa idfl <? ( 2drop uiExitWidget ; ) drop
	uiBacklast
	ex ;
	
| 0 = normal
| 1 = over (not all sytems)
| 2 = in
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click
#chx

:uIn? | x y -- 0/-1
	sdlx cx - $ffff and cw >? ( drop 0 ; ) drop
	sdly cy - $ffff and chx >? ( drop 0 ; ) drop 
	-1 ;
|#idfx 
:stMouse | -- state
	flagClear 
	1 'id +! 
	ida -1 =? ( drop 			| no active
		uIn? 0? ( ; ) drop		| out->0
		sdlb 0? ( drop 1 ; ) drop	| over->1
|		id dup 'idh ! 'idfh ! -1 'idfx ! 1 ; )	| in->2(prev)
		id dup 'idh ! 'idfh ! 2 ; )	| in->2(prev)
	id <>? ( drop 0 ; ) 	|	 active no this->0
|	idfx <>? ( 'idfx ! 2 ; ) | in->2
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
::uiZone | -- ; Interaction is cx,cy,cw,th
	txh 'chx !
	stMouse stFocus or 'uistate ! ;

::uiZoneL | nlines -- ; Interaction is cx,cy,cw,th*lines
	txh * 'chx !
	stMouse stFocus or 'uistate ! ;

::uiZoneW | --	; Interaction is cx,cy,cw,ch
	ch 'chx !
	stMouse stFocus or 'uistate ! ;
	
#auxbox
::uiZoneBox | x y w h --
	cx cy cw ch 'auxbox w!+ w!+ w!+ w!
	dup 'ch ! 'chx ! 'cw ! 'cy ! 'cx !
	stMouse stFocus or 'uistate ! ;
	
::uiBackBox
	'auxbox w@+ 'ch ! w@+ 'cw ! w@+ 'cy ! w@ 'cx ! ;
	
	
|-- place to go in drag (index n)	
::uiPlace | n --
	ch 'chx !
	uIn? 0? ( 2drop ; ) drop 'mdragh ! ;

|-- interact	
::uiOvr		uiState $f and 1 <>? ( 2drop ; ) drop ex ;  | 'v --
::uiDwn		uiState $f and 2 <>? ( 2drop ; ) drop ex ; | 'v --
::uiSel		uiState $f and 3 <? ( 2drop ; ) drop ex ;  | 'v --
::uiClk		uiState $f and 6 <>? ( 2drop ; ) drop ex ; | 'v --
::uiUp		uiState $f and 5 <? ( 2drop ; ) drop ex ;  | 'v --

::uiFocusIn uiState $10 nand? ( 2drop ; ) drop ex ;
::uiFocus 	uiState $20 nand? ( 2drop ; ) drop ex ;

::uiRefocus	-1 'idfa ! ;
::uiFocus>> 1 'idfh +! ; | cambia id y luego wid
::uiFocus<< -1 'idfh +! ;

::tabfocus
	keymd 1 and? ( drop uiFocus<< ; ) drop uiFocus>> ;

:ui+a
	dup 'cx +! 'cy +! ;
:ui+c
	dup ui+a
	2* neg dup 'cw +! 'ch +! ;
	
|---- Draw words 
#recbox [ 0 0 0 0 ] | for sdl2

:c2recbox
	ch cw cy cx 'recbox d!+ d!+ d!+ d! ;

:cl2recbox
	chx cw cy cx 'recbox d!+ d!+ d!+ d! ;
	
::uiFill	cx cy cw ch SDLFRect ;
::uiRect	cx cy cw ch SDLRect ;
::uiRFill	cx cy cw ch SDLFRound ; | round --
::uiRRect	cx cy cw ch SDLRound ; | round --
::uiCRect	cw ch min 2/ cx cy cw ch SDLRound ;
::uiCFill	cw ch min 2/ cx cy cw ch SDLFRound ;
::uiTex		c2recbox 'recbox swap SDLImageb ; | texture --

|--- grid lines
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
#colBac	$ff222222ff111111 | background
#colFil $ff80D9FFff005D85 | fill
#colTxt $ffffffffffffffff | texto

#colFoc $ffffff 

::stDang $ffff8099ff85001B 'colfil ! ;	| danger
::stWarn $ffffBF29fff55D00 'colfil ! ;	| warning
::stSucc $ff5BCD9Aff1F6546 'colfil ! ;	| success
::stInfo $ff80D9FFff005D85 'colfil ! ;	| info
::stLink $ff4258FFff000F85 'colfil ! ;	| link
::stDark $ff393F4Cff14161A 'colfil ! ;	| dark
::stLigt $ffaaaaaaff888888 'colfil ! ;	| white

|--- fill widget
::uilFill
|	colBac sdlcolor 
	cx cy cw chx SDLFRect ;
::uilRFill	
|	colBac sdlcolor 
	cx cy cw chx SDLFRound ; | round --
::uilCFill	
|	colBac sdlcolor 
	cw chx min 2/ cx cy cw chx SDLFRound ;
::uilTex	
	cl2recbox 'recbox swap SDLImageb ; | texture --

|--- focus
::uilRect	cx 1- cy 1- cw 2 + chx 2 + SDLRect ;
::uilRRect	cx 1- cy 1- cw 2 + chx 2 + SDLRound ; | round --
::uilCRect	cw 2 + chx 2 + min 2/ cx 1- cy 1- cw 2 + chx 2 + SDLRound ;

:colBack
	colBac sdlcolor ;
	
:colFill
	colFil sdlcolor ;
	
:colFocus
	colFoc sdlcolor ;
	
:colText
	colTxt txrgb ;

|---- text cursor
::uil..
	txh 'cy +! ;
::ui..
	txh flpady + 'cy +! ;
	
::ui--
	colFill
	cx cy 1+ cw 2 SDLRect
	flpady 7 + 'cy +! ;
	

|---- helptext
::ttwrite | "text" --
	cx 
	|ch txh - 2/ cy +
	cy txat txwrite ;

::ttwritec | "text" --
	txw | "" w   
	cw swap - 2/ cx +
	|ch txh  - 2/ cy +
	cy txat txwrite ;

::ttwriter | "text" --
	txw | "" w 
	cw cx + swap -
	|ch txh - 2/ cy +
	cy txat txwrite ;
	
:txicon | char --
	txh over txch - 2/  | char ny
	0 over tx+at
	swap txemit
	0 swap neg tx+at ;
	
::uiTlabel
	txw 4 + 'cw ! ttwritec cw 'cx +! ;
	
|---- widget
::uiLabel
	ttwrite	ui.. ;
	
::uiLabelC
	ttwritec ui.. ;
	
::uiLabelR
	ttwriter ui.. ;

::uiText | "" align --
	txalign >r cw ch cx cy r> txText ;	

:kbBtn
	sdlkey 
	<ret> =? ( flagEx! )
	<tab> =? ( tabfocus ) 
	drop ;

	
::uiTBtn | 'click "" align --	
	uiZoneW 
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill 8 uilRFill 
	[ kbBtn colFocus 8 uiRrect ; ] uiFocus
	colText uiText
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiNBtn | v "" -- ; width from text
	txw 4 + 'cw !
	uiZone
	'flagex! uiClk
	colFill uilFill 
	[ kbBtn colFocus uiLRect ; ] uiFocus
	ttwritec
	cw 'cx +! 
	uiEx? 0? ( 2drop ; ) drop ex ;	
	
::uiBtn | 'click "" --	
	uiZone
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill uilFill 
	[ kbBtn colFocus uiLRect ; ] uiFocus
	colText uiLabelC 
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiRBtn | 'click "" --	
	uiZone
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill 6 uiLRFill 
	[ kbBtn colFocus 6 uiLRRect ; ] uiFocus
	colText uiLabelc 
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

::uiCBtn | 'click "" --	
	uiZone
	'flagex! uiClk
	[ 2 ui+a ; ] uiSel 
	colFill uiLCFill 
	[ kbBtn colFocus uiLCRect ; ] uiFocus
	colText uiLabelc
	[ -2 ui+a ; ] uiSel 
	uiEx? 0? ( 2drop ; ) drop ex ;

|---- Horizontal slide
:kbSlide
	sdlkey 
	<tab> =? ( tabfocus ) 
	<le> =? ( <dn> nip ) 
	<dn> =? ( over dup @ 1- clamp0 swap ! )
	<ri> =? ( <up> nip ) 
	<up> =? ( over dup @ 1+ pick4 clampmax swap ! )	
	drop ;

:slideh | 0.0 1.0 'value --
	sdlx cx - cw clamp0max 
	2over swap - | Fw
	cw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	colBack uiLFill
	[ kbSlide colFocus uiLRect ; ] uiFocus
	colFill
	dup @ pick3 - 
	cw 8 - pick4 pick4 swap - */ cx 1+ +
	cy 2 + 
	6 txh 4 - 
	SDLFRect ;
	
::uiSliderf | 0.0 1.0 'value --
	uiZone
	'slideh uiSel |
	slideshow
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | 0 255 'value --
	uiZone
	'slideh uiSel | 'dn 'move --	
	slideshow
	@ .d uiLabelC
	2drop ;	
	
:progreshow | 0.0 1.0 'value --
	colBack uiLFill
	[ kbSlide colFocus uiLRect ; ] uiFocus	
	colFill
	dup @ pick3 - cw pick4 pick4 swap - */
	txh
	cx cy 2swap
	SDLFRect ;

::uiProgressf | 0.0 1.0 'value --
	uiZone
	'slideh uiSel | 'dn 'move --	
	progreshow
	@ .f2 uiLabelC
	2drop ;

::uiProgressi | 0 255 'value --
	uiZone
	'slideh uiSel | 'dn 'move --	
	progreshow
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
	[ kbBtn colFocus uiLRect ; ] uiFocus	
	ColFill
	dup @ pick3 - 
	ch 8 - pick4 pick4 swap - */ cy 1+ +
	cx 2 + swap
	cw 4 - 6 
	SDLFRect ;

::uiVSliderf | 0.0 1.0 'value --
	uiZone
	'slidev uiSel
	slideshowv
	@ .f2 uiLabelC
	2drop ;

::uiVSlideri | 0 255 'value --
	uiZone
	'slidev uiSel
	slideshowv	
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

#lvl	|  $1f:level $20:have_more $80:is_open	
:getval	| adr c@ ; a
	$1f and 
	lvl <=? ( 'lvl ! ; ) 
	a> 8 - @ dup 				
	c@ $20 or over c!
	c@ $80 and? ( drop 'lvl ! ; ) | draw
	2drop
	( >>0 dup c@ 1? 
		$1f and lvl >? drop )
	drop ;
	
:maketree |
	0 'lvl !
	here dup 'indlist ! >a
	( dup a!+ >>0
		dup c@ 1? 
		getval
		) 2drop
	a> dup here - 3 >> 'cntlist !
	'here ! ;

|----- CHECK
:focoCheck
	colFocus uiLRect 
	sdlkey
	<tab> =? ( tabfocus  )
	<ret> =? ( 1 pick2 << pick3 @ xor pick3 ! ) | 'var n key -- 'var n key
	drop ;

:ic	over @ 1 pick2 << |and? ( drop "[x]" ; ) drop "[ ]" ;
	and? ( drop 139 ; ) drop 138 ;
	
:icheck | 'var n -- 'var n
	uiZone 
	'focoCheck uiFocus 
	[ 1 over << pick2 @ xor pick2 ! ; ] uiClk
	cx cy txat 
	ic txicon 32 txemit a@+ txwrite
	ui.. ;
		
::uiCheck | 'var 'list --
	mark makeindx
	indlist >a
	0 ( cntlist <? icheck 1+ ) 2drop
	empty ;	

|----- RADIO
:focoRadio
	colFocus uiLRect 
	sdlkey
	<tab> =? ( tabfocus  )
	<ret> =? ( over pick3 ! ) | 'var n key -- 'var n key
	drop ;

:ir over @ |=? ( "(o)" ; ) "( )" ;
	=? ( 137 ; ) 136 ;

:iradio | 'var n --
	uiZone
	'focoRadio uiFocus
	[ 2dup swap ! ; ] uiClk
	cx cy txat 
	ir txicon 32 txemit a@+ txwrite
	ui.. ;

::uiRadio | 'var 'list --
	mark makeindx
	indlist >a
	0 ( cntlist <? iradio 1+ ) 2drop
	empty ;	
	
|--------
#lx #ly

:wwlist	| 'var max d -- 'var max d ; Wheel 
	dup pick3 8 + 
	dup @ rot + 
	cntlist pick4 -
	clamp0max
	swap ! ;
	
:backline 
	lx ly cw txh sdlFRect ;
	
:slidev | 'var max -- 'var max
	cntlist over - 1+	| maxi
	sdly cy - chx 1- clamp0max | 'v max rec (0..curh)
	chx */ pick2 8 + ! ;

:cscroll | 'var max -- 'var max
	cntlist >=? ( ; ) 
	$ffffff sdlcolor 
	cntlist over - 1+	| maxi
	cx cw + 10 -		| 'var max maxi x 
	pick3 8 + @ 		| 'var max maxi x ini
	chx pick3 / 	| 'var max maxi x ini hp
	swap over *	cy +	| 'var max maxi x hp ini*hp
	8 rot
	>r >r 4 -rot r> r> sdlfRound	
	drop ;
	
:kbList
	SDLw 1? ( wwlist ) drop 
	sdlkey 
	<ret> =? ( flagEx! )
	<tab> =? ( tabfocus ) 
	<up> =? ( pick2 dup @ 1- clamp0 swap ! )
	<dn> =? ( pick2 dup @ 1+ cntlist 1- clampmax swap ! )	
	drop 
	cscroll ;

:cklist | 'var max --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop slidev ; ) drop )
	sdly cy - txh / pick2 8 + @ + cntlist 1- clampmax pick2 !
	;
	
:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colFill backline )
	|overl =? ( colBack uiFill )
	uiNindx 
	lx ly txat txwrite txh 'ly +!
	;

::uiList | 'var cntl 'list --
	over uiZoneL
	mark makeindx
	cx 'lx ! cy 'ly !
	0 ( over <? ilist 1+ ) drop
	[ kblist colFocus uiLRect ; ] uiFocus	
	'cklist uiClk
	2drop
	empty 
	chx flpady + 'cy +! ;
	
|----- TREE
| #vtree 0 0

:cktree | 'var cnt --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop slidev ; ) drop )
	sdly cy - txh / pick2 8 + @ + cntlist 1- clampmax
	pick2 @ <>? ( pick2 ! ; )
	3 << indlist + @ 
	dup c@ $80 xor swap c! ;

:iicon | n -- 
	$20 nand? ( drop 32 txicon ; )
	7 >> 1 and 129 + txicon ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colFill backline )
|	overl =? ( overfil uiFill )
	uiNindx 
	c@+ 0? ( 2drop ch 'ly +! ; )
	dup $1f and 4 << lx + ly txat iicon txwrite 
	txh 'ly +! ;

::uiTree | 'var cntl list --
	over uiZoneL
	mark maketree
	cx 'lx ! cy 'ly !
	0 ( over <? itree 1+ ) drop
	[ kblist colFocus uiLRect ; ] uiFocus
	'cktree uiClk
	2drop
	empty 
	chx flpady + 'cy +! ;
	
|----- COMBO
:comboclk | 'var cnt -- 'var cnt
	cntlist <? ( sdlx cx - cw 12 - >? ( drop slidev ; ) drop )
	sdly cy - txh / pick2 8 + @ + cntlist 1- clampmax pick2 !
	uiExitWidget ;

:combolist | --
	uidata1 uidata2 
	mark makeindx
	cntlist 6 min
	dup uiZoneL
	colBack uiLFill
	colFocus uiLRect
	cx 'lx ! cy 'ly !
	0 ( over <? ilist 1+ ) drop
	cscroll
	kblist
	'comboclk uiClk
	2drop
	empty ;	
	
	
:iniCombo | 'var 'list -- 'var 'list 
	2dup 'uidata2 ! 'uidata1 !
	cx cy cw ch 'combolist uiSaveLast ;
	
:kblistc	
	colFocus uiLRect
	'iniCombo uiClk 
	kblist ;
	
::uiCombo | 'var 'list --
	uiZone 
	'kblistc uiFocus
	mark makeindx	
	cx cy txat
	@ uiNindx txwrite
	cx cw + txh - cy txat 130 txicon
	empty ui.. ;
	

|--- Edita linea
#cmax
#padi>	| inicio
#pad>	| cursor
#padf>	| fin

:lins  | c -- ;
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1- padf> over - 1+ cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> <=? ( drop ; )
	dup padi> - cmax >=? ( swap 1- swap -1 'pad> +! ) drop
	'padf> ! ;
:0lin 0 padf> c! ;
:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> padi> <=? ( drop ; ) dup 1- swap padf> over - 1+ cmove -1 'padf> +! -1 'pad> +! ;
:kder pad> padf> <? ( 1+ ) 'pad> ! ;
:kizq pad> padi> >? ( 1- ) 'pad> ! ;
:kup
	pad> ( padi> >?
		1- dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1- 'pad> ! ;

#modo 'lins

:cursor | 'var max
	msec $100 and? ( drop ; ) drop
	$a0a0a0 SDLColor
	cx cy txat 
	padi> pad> 
	modo 'lins =? ( drop txcur ; ) drop
	txcuri ;
	
|----- ALFANUMERICO
:iniinput | 'var max -- 'var max
	dup 1- 'cmax !
	over dup 'padi> !
	( c@+ 1? drop ) drop 1-
	dup 'pad> ! 'padf> !
	'lins 'modo !
	;

:chmode
	modo 'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;

:proinputa | --
	colFocus cx 1- cy 1- cw 2 + txh 2 + SDLRect 
	$ffffff SDLColor |	uiRect
	cursor 
	SDLchar 1? ( modo ex ; ) drop
	SDLkey 0? ( drop ; )
	<ins> =? ( chmode )
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )
	
	<ret> =? ( flagEx! )
	<tab> =? ( tabfocus ) 
|	<dn> =? ( nextfoco ) <up> =? ( prevfoco )
	drop
	
	;

::uiInputLine | 'buff max --
	uiZone
	Colback uiLFill
	'iniinput uiFocusIn
	'proinputa uiFocus 
	drop
	ttwrite ui.. ;	
		