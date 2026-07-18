| 
| PHREDA 2026

^r3/lib/sdl2gl.r3
^./rlhud.r3
^./gllib.r3


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

| 0 = none
| 1 = over
| 2 = in (btn dwn)
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click (btn up)
#statec ( 0 0 32 32 0 0 32 ) 
:colorFill
	colfil uistate 'statec + c@ >> 'fcolor ! ;
:colorBack
	colbac uistate 'statec + c@ >> 'fcolor ! ;
:colorText
	colTxt 'fcolor ! ;
	
#marx 4 #mary 4 | margin
#padx 9 #pady 2 | pad

|--------------------------------------------------------------
| LAYOUT
#fx #fy #fw #fh	| win layout

#flcols 1 #flrows 1 #flcur 0
#flcolm	1 #flrowm 1

#cx #cy #cw 0 #ch 0 | cursor

#flstack * 64 | 8 niveles
#flstack> 'flstack

::%cw fw 16 *>> ;
::%ch fh 16 *>> ;

:f2c
|	marx fw over 2* - 'wiw ! fx + 'wix !
|	mary fh over 2* - 'wih ! fy + 'wiy ! 
	marx 'cx ! 
	mary 'cy ! 
	fw marx 2* - 'cw ! 
	fh mary 2* - 'ch ! 
	
	|fx fy fw fh immBox
	;

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
	
::uiPush
	fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
::uiPop
	-8 'flstack> +! flstack> fl>now f2c ;

:uiGet
	flstack> 8 - fl>now ;
::uiFill
	uiGet f2c
	fx fy fw fh immBox
	;

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
	flrowm dup mary 2* - 'wih !
	* fy + mary + 'wiy !
	flcolm dup marx 2* - 'wiw !
	* fx + marx + 'wix ! ;
	
::uiTo | w h -- 
	flrowm * mary 2* - 'wih !
	flcolm * marx 2* - 'wiw ! ;

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

|--------------------------------------------------
::gZoneAll
	fx fy fw fh ;

::gZoneEle
	fx marx + fy mary + wiw marx 2* - wih mary 2* - ;
		
::tlwrite | "text" --
	fsize nip | w h
	wix marx + padx +
	wiy wih 2/ + rot 2/ -
	fat ftext ;
	
:tcwrite | "text" --
	fsize | w h
	wix wiw 2/ + rot 2/ -
	wiy wih 2/ + rot 2/ -
	fat
	ftext ;
	
:trwrite | "text" --
	fsize | w h
	wix wiw + mary 2* pady 2* + - rot -
	wiy wih 2/ + rot 2/ -
	fat
	ftext ;

:zonefline
	fx cx +
	fy cy +
	fw marx 2* - 
	fsizeh pady 2* + 
	immBox immZone ;

:zonecline | cnt --
	>r
	fx cx +
	fy cy +
	fw marx 2* - 
	fsizeh r> * pady 2* + 
	immBox immZone ;


#lx #ly

:fillboxb 
	wix wiy wiw wih 2 frectb ;

:fillline 
	lx ly wiw fsizeh FRect ;

:drawfocus
	colFoc 'fcolor !
	wix wiy wiw wih rect ;
	
|--------------------------------------	
| fullwidth button down
::uiFTBtn | 'v "" --
	zonefline

	colorFill fillboxb 
	colorText tcwrite 
	
	uiClk 
	fsizeh 
	pady 2* + mary + 'cy +!
	;
	
::uiTBtn | 'click "" --
	fsize drop | w h 
	fx cx +
	fy cy +
	rot padx 2* + dup >r 
	fsizeh pady 2* + 
	immBox immZone
	
	colorFill fillboxb 
	colorText tcwrite 

	uiClk 
	r> marx 2* + 'cx +!
	|pady 2* + mary + 'cy +!	
	;

::uiWrite | "" --
	fsize nip swap
	fx cx + marx + fy cy + mary + fat
	colorText ftext 
	marx + 'cx +!
	;
	
::uiLabel | "" --
	fx cx + padx + 
	fy cy +
	fat colorText ftext 
	fsizeh mary + 'cy +! ;
	
::uiLabelC | "" --
	fsize  | w h
	fx fw 2/ + rot 2/ -
	fy cy + rot >r
	fat colorText ftext 
	r> mary + 'cy +! ;

::uiLabelR | "" --
	fsize  | w h
	fx fw + padx - rot -
	fy cy + rot >r
	fat colorText ftext 
	r> mary + 'cy +! ;

|---- Horizontal slide
:kbSlide
	sdlkey 
	<tab> =? ( tabfocus ) 
	<le> =? ( <dn> nip ) 
	<dn> =? ( over dup @ 1- clamp0 swap ! uiEx! )
	<ri> =? ( <up> nip ) 
	<up> =? ( over dup @ 1+ pick4 clampmax swap ! uiEx! )	
	drop ;

:slideh | 0.0 1.0 'value --
	sdlx wix - wiw clamp0max 
	2over swap - | Fw
	wiw */ pick3 +
	over ! 
	uiEx! ;
	
:slideshow | 0.0 1.0 'value --
	|colorBack
	[ kbSlide drawfocus ; ] uiFocus
	colorFill
	dup @ pick3 - 
	wiw 8 - pick4 pick4 swap - */ wix 1+ +
	wiy 2 + 
	6 wih mary -
	FRect ;

::uiSliderf | 0.0 1.0 'value --
	zonefline

	'slideh uiSel 
	slideshow
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | 0 255 'value --
	zonefline

	'slideh uiSel
	slideshow
	@ .d uiLabelC
	2drop ;	
	
:progreshow | 0.0 1.0 'value --
	|colBack uiLFill
	[ kbSlide drawfocus  ; ] uiFocus	
	colorFill
	dup @ pick3 - wiw pick4 pick4 swap - */
	wih
	wix wiy 2swap
	FRect ;

::uiProgressf | 0.0 1.0 'value --
	zonefline
	'slideh uiSel | 'dn 'move --	
	progreshow
	@ .f2 uiLabelC
	2drop ;

::uiProgressi | 0 255 'value --
	zonefline
	'slideh uiSel | 'dn 'move --	
	progreshow
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
	
:calcindx | 'adr -- 'adr
	0 over ( dup c@ 1? drop
		>>0 swap 1+ swap ) 2drop
	'cntlist ! ;
	
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
	'lvl ! ;
	
:maketree |
	0 'lvl !
	here dup 'indlist ! >a
	( dup a!+ >>0
		dup c@ 1? 
		getval
		) 2drop
	a> dup here - 3 >> 'cntlist !
	'here ! ;


|--------
:wwlist	| 'var max d -- 'var max d ; Wheel 
	dup pick3 8 + 
	dup @ rot + 
	cntlist pick4 -
	clamp0max
	swap ! ;
	
:slidev | 'var max -- 'var max
	cntlist over - 1+	| maxi
	sdly wiy - fsizew 1- clamp0max | 'v max rec (0..curh)
	fsizew */ pick2 8 + ! ;

:cscroll | 'var max -- 'var max
	cntlist >=? ( ; ) 
	|$ffffff sdlcolor 
	cntlist over - 1+	| maxi
	wix wiw + 10 -		| 'var max maxi x 
	pick3 8 + @ 		| 'var max maxi x ini
	fsizew pick3 / 	| 'var max maxi x ini hp
	swap over *	wiy +	| 'var max maxi x hp ini*hp
	8 rot
	>r >r 4 -rot r> r> frectb	
	drop ;
	
:kbList
	SDLw 1? ( wwlist ) drop 
	sdlkey 
	<ret> =? ( uiEx! )
	<tab> =? ( tabfocus ) 
	<up> =? ( pick2 dup @ 1- clamp0 swap ! uiEx! )
	<dn> =? ( pick2 dup @ 1+ cntlist 1- clampmax swap ! uiEx! )	
	drop 
	|cscroll 
	;

:cklist | 'var max --
	cntlist <? ( sdlx wix - wiw 12 - >? ( drop slidev ; ) drop )
	sdly wiy - fsizeh / pick2 8 + @ + cntlist 1- clampmax pick2 !
	;

|::tabfocus
	|keymd 1 and? ( drop uiFocus<< ; ) drop uiFocus>> ;

:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colorFill fillline colorText )
	|overl =? ( colBack uiFill )
	uiNindx 
	lx ly fat ftext fsizeh 'ly +!
	;

::uiList | 'var cntl 'list --
	over zonecline
	
	wix wiy wiw wih Rect 
	|drawfocus
	
	mark makeindx
	wix 'lx ! wiy 'ly !
	0 ( over <? ilist 1+ ) drop
	'kblist uiFocus	
	'cklist uiClk
	2drop
	empty 
	|chx flpady + 'cy +! 
	;

|----- TREE
| #vtree 0 0

:cktree | 'var cnt --
	cntlist <? ( sdlx cx - cw 12 - >? ( drop slidev ; ) drop )
	sdly cy - fsizeh / pick2 8 + @ + cntlist 1- clampmax
	pick2 @ <>? ( pick2 ! ; )
	3 << indlist + @ 
	dup c@ $80 xor swap c! ;

:iicon | n -- 
	$20 nand? ( drop " " ftext ; )
	7 >> 1 and $3d + " " dup rot c! ftext ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( colorFill fillline colorText )
|	overl =? ( overfil uiFill )
	uiNindx 
	c@+ 0? ( 2drop ch 'ly +! ; )
	dup $1f and 4 << lx + ly fat iicon ftext
	fsizeh 'ly +! ;

::uiTree | 'var cntl list --
	over zonecline
	mark maketree
	cx 'lx ! cy 'ly !
	0 ( over <? itree 1+ ) drop
	|[ kblist colFocus uiLRect ; ] uiFocus
	'kblist uiFocus
	'cktree uiClk
	2drop
	empty 
|	chx flpady + 'cy +! 
	;
	
	
	
