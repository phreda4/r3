| UI
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

^r3/util/datetime.r3

##uicons

#cifil $ff1F2229ff14161A	| over|normal -- color fill
#cisel $ff1967D2ff393F4C	| over|normal -- color select
#cifnt $ffffff		| fuente -- color
#cifoc $4055F4		| foco -- borde

::stDang $ffff8099ff85001B 'cifil ! ;	| danger
::stWarn $ffffBF29fff55D00 'cifil ! ;	| warning
::stSucc $ff5BCD9Aff1F6546 'cifil ! ;	| success
::stInfo $ff80D9FFff005D85 'cifil ! ;	| info
::stLink $ff4258FFff000F85 'cifil ! ;	| link
::stDark $ff393F4Cff14161A 'cifil ! ;	| dark
::stLigt $ffaaaaaaff888888 'cifil ! ;	| white

:overfil cifil guin? 32 and >> sdlcolor ;
:oversel cisel guin? 32 and >> sdlcolor ;

::stFDang $ff9980ffff1B0085 'cifnt ! ;	| danger
::stFWarn $ff005Df5ff29BFff 'cifnt ! ;	| warning
::stFSucc $ff46651Fff9ACD5B 'cifnt ! ;	| success
::stFInfo $ff855D00ffFFD980 'cifnt ! ;	| info
::stFLink $ff850F00ffFF5842 'cifnt ! ;	| link
::stFDark $ff1A1614ff4C3F39 'cifnt ! ;	| dark
::stFWhit $ffffffffffeaeaea 'cifnt ! ;	| white
::stfLigt $ffaaaaaaff888888 'cifnt ! ;	| white

#xl #yl #wl #hl
#padx #pady	
#curx #cury | cursorxy
#curw #curh	| cursorwh

#topVar 0
#topRect
#topSty 0 0 0
#topList
	
#poscopy 0 

:cur>64 | -- c64
	curh 16 << curw $ffff and or 16 << 
	cury $ffff and or 16 << curx $ffff and or ;
	
:64>cur | c64 --
	dup 48 << 48 >> 'curx ! 16 >>
	dup 48 << 48 >> 'cury ! 16 >>
	dup 48 << 48 >> 'curw ! 16 >>
	48 << 48 >> 'curh ! ;

:ccopy	cur>64 'poscopy ! ;
:cback	poscopy 64>cur ;
:topcpy	cur>64 'topRect ! 'topsty 'cifil 3 move ; |dsc
:topbak	topRect 64>cur 'cifil 'topsty 3 move cifnt txrgb ;

|---------------	
|---- FONT	
:ttemitl | "text" --
	curx
	curh txh - 2/ cury +
	txat txemits ;

:ttemitc | "text" --
	txw txh | "" w h  
	curw rot - 2/ curx +
	curh rot - 2/ cury +
	txat txemits ;

:ttemitr | "text" --
	txw txh | "" w h  
	curw curx + rot -
	curh rot - 2/ cury +
	txat txemits ;

#ttw #tth
:ttsize | "" -- "" 
	txh 'tth ! txw 'ttw ! ;

#backc
	
::ttcursor | str strcur -- 
	curx cury txat txcur ;

::ttcursori | str strcur -- 
	curx cury txat txcuri ;

::uiLabelMini
	curx cury txat txemits
	curh 'cury +! ;	

|--------------------
|----- draw/fill
::uiRectW 	xl yl wl hl SDLRect ;
::uiFillW	xl yl wl hl SDLFRect ;
::uiRRectW 	wl hl min 2 >> xl yl wl hl SDLRound ;
::uiRFillW	wl hl min 2 >> xl yl wl hl SDLFRound ;
::uiCRectW 	wl hl min 2/ xl yl wl hl SDLRound ;
::uiCFillW	wl hl min 2/ xl yl wl hl SDLFRound ;

::uiRRect10	10 xl yl wl hl SDLRound ;
::uiRFill10	10 xl yl wl hl SDLFRound ;

::uiRect	curx cury curw curh SDLRect ;
::uiFill	curx cury curw curh SDLFRect ;
::uiRRect	curw curh min 2 >> curx cury curw curh SDLRound ;
::uiRFill	curw curh min 2 >> curx cury curw curh SDLFRound ;
::uiCRect	curw curh min 2/ curx cury curw curh SDLRound ;
::uiCFill	curw curh min 2/ curx cury curw curh SDLFRound ;

::uiTitleF
	xl cury pady - wl curh pady 2* + sdlFrect ;
	
::uiTitle | str --
	curw wl 'curw ! 'wl !
	ttemitc
	curw wl 'curw ! 'wl !
	curh pady 2* + 'cury +! ;

::uiLineH
	curx cury 1 + curw 2 SDLRect
	pady 7 + 'cury +! ;
	
::uiLineV
	curx curw 2/ + 1- cury 1+ 2 curh 2 - SDLRect ;
	
::uiLineWH
	xl cury curh + pady + wl 1 sdlrect ;
	
::uiGridBV
	padx 2* curw +
	0 ( wl pick2 2* - <=?
		over +
		dup xl + yl hl over + SDLLineV
		) 2drop ;
		
::uiGridBH
	pady 2* curh +
	0 ( hl pick2 2* - <=?
		over +
		xl over yl + over wl + SDLLineH
		) 2drop ;
	
::uiGrid# 
	uiGridBH uiGridBV ;

|----- zone

::uicr
	xl padx + 'curx ! 
::uidn	
	curh pady 2* +  'cury +! ;
::uiri
	curx curw + padx 2* + | new x
	xl wl + 
	>? ( drop uicr ; ) 'curx ! ;

#vflex 'uiri

::uiH	'uiri 'vflex ! ;	| << horizontal flow
::uiV	'uidn 'vflex ! ;	| << vertical flow
	
::ui<
	curw padx 2* + neg 'curx +! ;
	
::ui>>
	xl wl + curw - padx 2* - 'curx ! 
	'ui< 'vflex ! ;


:ui..	vflex ex ;

::uiPad | padx pady --
	'pady ! 'padx ! ;

::uiWinBox | x y x2 y2 --
	pick2 - 'hl ! pick2 - 'wl ! 'yl ! 'xl ! ;

::uiWin | x y w h --
	'hl ! 'wl ! 'yl ! 'xl ! ;
	
::uixy | x y --
	pady + 'cury ! padx + 'curx ! ;

::uiBox | w h --
	pady 2* - 'curh ! padx 2* - 'curw ! ;

::uiGAt | x y --
	curh pady 2* + * pady + yl + 'cury !
	curw padx 2* + * padx + xl + 'curx ! 
	;

::uiGrid | c r --
	hl swap / pady 2* - 'curh ! 
	wl swap / padx 2* - 'curw ! 
	0 0 uiGat ;

::uiGridA | c r -- ; adjust for fit
	hl swap /mod dup 2/ 'yl +! neg 'hl +! pady 2* - 'curh ! 
	wl swap /mod dup 2/ 'xl +! neg 'wl +! padx 2* - 'curw ! 
	0 0 uiGat ;
	
::uiStart
	gui uiH
	0 0 sw sh uiWin 
	0 'topVar ! ;

::uiZone	
	curx cury curw curh guiBox ;
	
|----- icon
::uiconxy | x y nro --
	uicons ssprite ;
	
::uicon | nro --
	curx 14 + cury curh 2/ +
	rot uicons ssprite 
::uicone | -- ; empty icon
	26 'curx +! ;
	
|----- Widget	
::uiLabel | "" --
	ttemitl ui.. ;
::uiLabelc | "" --
	ttemitc ui.. ;
::uiLabelr | "" --
	ttemitr ui.. ;
	
::uiTlabel
	ttsize ttw 4 + 'curw !	
	ttemitc 
	curw 'curx +!	
	;
	
	
|dup 0.1 %h TTF_SetFontSize dup %1 TTF_SetFontStyle | KUIB %0001	
#des 0 0

::uiMDText | 'var "" --
	|$f0000020ffff curw curh
	|uifont textbox 
	|curh curw cury curx 'des d!+ d!+ d!+ d!
	|SDLrenderer over 0 'des SDL_RenderCopy
	|SDL_DestroyTexture
	|ui.. 
	;

|----- Botones	
:focoBtn
	cifoc sdlColor uiRect
	sdlKey
	<tab> =? ( nextfoco )
	drop ;

:focoRBtn
	cifoc sdlColor uiRRect
	sdlKey
	<tab> =? ( nextfoco )
	drop ;

:focoCBtn
	cifoc sdlColor uiCRect
	sdlKey
	<tab> =? ( nextfoco )
	drop ;
	
::uiBtn | v "" --
	uiZone
	overfil uiFill
	'focoBtn in/foco 
	'clickfoco onClick
	ttemitc onClick ui.. ;	

::uiRBtn | v "" --
	uiZone
	overfil uiRFill
	'focoRBtn in/foco 
	'clickfoco onClick	
	ttemitc onClick ui.. ;	

::uiCBtn | v "" --
	uiZone
	overfil uiCFill
	'focoCBtn in/foco 
	'clickfoco onClick	
	ttemitc onClick ui.. ;	
	
::uiTBtn | v "" -- ; width from text
	ttsize ttw 4 + 'curw !
	uiZone
	overfil uiFill
	ttemitc onClick 
	curw 'curx +!
	;	

|----- list mem (intern)
#cntlist
#indlist

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
	|a> 8 - @ dup c@ $df and swap c! 
	a> dup here - 3 >> 'cntlist !
	'here ! ;

|----- COMBO
:focoCombo | 'var 'list --
	curh 'cury +! topCpy curh neg 'cury +!
	over 'topVar ! dup 'topList !
	cifoc sdlColor uiRRect
	SDLkey
	<tab> =? ( nextfoco )
	drop 
	;
	
::uiCombo | 'var 'list --
	uiZone overfil uiRFill
	'focoCombo in/foco 
	'clickfoco onClick
	mark makeindx	
	curx curw + 14 - cury curh 2/ + 146 uiconxy
	8 'curx +!
	@ uiNindx uiLabel
	-8 'curx +!
	empty ;

|:nexlst	dup @ 1+ cntlist >=? ( 0 nip ) over ! ;
|:prelst	dup @ 1- -? ( cntlist 1- nip ) over ! ;
|:focolst
|	cifoc sdlColor uiRect
|	sdlKey
|	<le> =? ( drop nexlst ; ) 
|	<ri> =? ( drop prelst ; )
|	<tab> =? ( nextfoco )
|	drop ;

|----- CHECK
:ic	over @ 1 pick2 << |and? ( drop "[x]" ; ) drop "[ ]" ;
	and? ( drop 57 ; ) drop 58 ;
	
:icheck | 'var n -- 'var n
	uiZone 
	'focoBtn in/foco 
	[ 1 over << pick2 @ xor pick2 ! clickfoco ; ] onClick
	ccopy
	ic uicon a@+ uiTLabel 
	cback ui.. ;
		
::uiCheck | 'var 'list --
	mark makeindx
	indlist >a
	0 ( cntlist <? icheck 1+ ) 2drop
	empty ;	

|----- RADIO
:ir over @ |=? ( "(o)" ; ) "( )" ;
	=? ( 226 ; ) 228 ;

:iradio | 'var n --
	uiZone
	'focoBtn in/foco 
	[ 2dup swap ! clickfoco ; ] onClick
	ccopy
	ir uicon a@+ uitlabel 
	cback ui.. ;

::uiRadio | 'var 'list --
	mark makeindx
	indlist >a
	0 ( cntlist <? iradio 1+ ) 2drop
	empty ;	

|----- TAB
:itab | 'var n --
	uiZone
	[ 2dup swap ! ; ] onClick
	over @ =? ( curx cury curh pady 2/ - + curw pady 2/ sdlFRect )
	a@+ uilabelc ;

::uiTab | 'var 'list --
	mark makeindx
	indlist >a
	0 ( cntlist <? itab 1+ ) 2drop
	empty ;	

|---- Horizontal slide
:slideh | 0.0 1.0 'value --
	sdlx curx - curw clamp0max 
	2over swap - | Fw
	curw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	overfil uiFill
	oversel
	dup @ pick3 - 
	curw 8 - pick4 pick4 swap - */ curx 1+ +
	cury 2 + 
	6 
	curh 4 - 
	SDLFRect ;
	
::uiSliderf | 0.0 1.0 'value --
	uiZone
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow
	'focoBtn in/foco 
	'clickfoco onClick	
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | 0 255 'value --
	uiZone
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow	
	'focoBtn in/foco 
	'clickfoco onClick		
	@ .d uiLabelC
	2drop ;	

|---- 8 bits
:slideh8 | 0 255 'value --
	sdlx curx - curw clamp0max 
	2over swap - | Fw
	curw */ pick3 +
	over c! ;

:slideshow8 | 0 255 'value --
	overfil uiFill
	oversel
	dup c@ pick3 - 
	curw 8 - pick4 pick4 swap - */ curx 1+ +
	cury 2 + 
	6 curh 4 - SDLFRect ;

::uiSlideri8 | 0 255 'value --
	uiZone
	'focoBtn in/foco 
	'clickfoco onClick	
	'slideh8 dup onDnMoveA | 'dn 'move --	
	slideshow8
	c@ .d uiLabelC
	2drop ;	
	
|----- LIST
| #vlist 0 0 

#overl

:wwlist	| 'var max d -- 'var max d ; Wheel mouseAdd commentMore actions
	dup pick3 8 + 
	dup @ rot + 
	cntlist pick4 -
	clamp0max
	swap ! ;
	
:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( oversel uiFill )
	overl =? ( overfil uiFill )
	uiNindx ttemitl 
	curh 'cury +! ;

:clist | 'var max --
	cntlist <? ( sdlx curx - curw 16 - >? ( drop ; ) drop )
	overl pick2 ! ;
	
:chlist
	-1 'overl !
	guin? 0? ( drop ; ) drop
	SDLw 1? ( wwlist ) drop
	sdly cury - curh / 
	pick2 8 + @ + 
	cntlist 1- 
	clampmax 'overl ! 
	'clist onclick
	;
	
:slidev | 'var max rec --
	sdly backc - cury backc - 1- clamp0max | 'v max rec (0..curh)
	over cury backc - */ pick3 8 + ! ;
	
:cscroll | 'var max -- 'var max
	cntlist >=? ( ; ) 
	guin? 0? ( drop ; ) drop
	curx curw + 10 - backc
	10 cury backc - |2over 2over sdlRect
	guiBox 
	cntlist over - 1+	| maxi
	'slidev dup onDnMoveA 
	oversel |	$444444 sdlcolor

	curx curw + 10 -		| 'var max maxi x 
	pick3 8 + @ 			| 'var max maxi x ini
	cury backc - pick3 / 	| 'var max maxi x ini hp
	swap over *	backc +		| 'var max maxi x hp ini*hp
	8 rot
	>r >r 4 -rot r> r>
	$ffffff sdlcolor sdlRound	
	|sdlFRound	
	drop ;
	
:uiFillL	
	curx cury curw pick3 curh * SDLFRect ;

:focolist
	cifoc sdlColor 
	curx 1- cury 1- curw 2 + pick3 curh * 2 + sdlRect
	sdlKey
	<tab> =? ( nextfoco )
	drop ;
	
::uiList | 'var cntlines list --
	mark makeindx
	curx cury dup 'backc ! 
	curw pick3 curh * guiBox 
	'focoList in/foco 
	'clickfoco onClick
	chlist
	0 ( over <? ilist 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	


|----- UIGridBtn
:griblist
	;
	
:glist	
	;
	
::UIGridBtn | 'var 'list 4 4 --
	mark makeindx
	curx cury dup 'backc ! 
	curw pick3 curh * guiBox
	overfil uiFillL
	'griblist onclick
	0 ( over <? glist 1+ ) drop
	pady 'cury +!
	empty ;	
	;
	
	
|----- TREE
| #vtree 0 0

:cktree
	cntlist <? ( sdlx curx - curw 16 - >? ( drop ; ) drop )
	overl pick2 @ <>? ( pick2 ! ; ) | click on select
	pick2 !
	overl 3 << indlist + @ 
	dup c@ $80 xor swap c! ;

:chtree
	-1 'overl !
	guin? 0? ( drop ; ) drop
	SDLw 1? ( wwlist ) drop
	sdly cury - curh / pick2 8 + @ + 
	cntlist 1- clampmax 'overl ! 
	'cktree onclick
	;

:iicon | n -- 
	$20 nand? ( drop uicone ; )
	7 >> 1 and 1 xor 36 + uicon ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( oversel uiFill )
	overl =? ( overfil uiFill )
	uiNindx 
	c@+ 0? ( 2drop curh 'cury +! ; )
	curx 'ttw !
	dup $1f and 4 << 'curx +!
	iicon ttemitl 
	ttw 'curx !
	curh 'cury +! ;

::uiTree | 'var cntlines list --
	mark maketree
	cntlist over - clamp0 pick2 8 + @ <? ( dup pick3 8 + ! ) drop
	curx cury dup 'backc ! 
	curw pick3 curh * guiBox 
	
	'focoList in/foco 
	'clickfoco onClick
	
	chtree
	0 ( over <? itree 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	
	
::uiTreePath | n -- str
	here 1024 + dup >b >a
	mark
	( dup uiNindx c@+ $1f and 
		swap a!+ 1? 'lvl ! 
		( 1- dup uiNindx c@ $1f and 
			lvl >=? drop ) drop
		) 2drop
	a> 8 - ( b> >=? dup @ ,s  "/" ,s 8 - ) drop
	0 ,c
	empty here ;
	
|------ folders for tree
#stckhdd>
#basepath * 1024

#l1 0 #l2 0 
:backdir | -- ;  2 '/' !!
	0 'l1 !
	'basepath ( c@+ 1? 
		$2f =? ( l1 'l2 ! over 'l1 ! )
		drop ) 2drop
	0 l2 1? ( c! ; ) 2drop ;	

:pushdd | --
	stckhdd> findata 520 cmove |dsc
	520 'stckhdd> +! ;
	
:pophdd
	-520 'stckhdd> +!
	findata stckhdd> 520 cmove ;

:scand | level "" --
	'basepath strcat "/" 'basepath strcat
	'basepath 
|WIN| "%s/*" sprint
	ffirst drop fnext drop 
	( fnext 1?
		dup fdir 1? (
			pushdd
|			pick2 64 + .emit over fname .write .cr
			pick2 64 + ,c over fname ,s 0 ,c
			pick2 1+ pick2 fname scand
			pophdd
			) 2drop
		) 2drop 	
	backdir ;

::uiScanDir | "" --
	0 'basepath !
	here $ffff + 'stckhdd> ! 
	0 swap scand 0 , ;

|-----
::uiTable
	;
	
	

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
	modo 'lins =? ( drop padi> pad> ttcursor ; ) drop
	padi> pad> ttcursori ;
	
|----- ALFANUMERICO
:iniinput | 'var max IDF -- 'var max IDF
	pick2 1- 'cmax !
	pick3 dup 'padi> !
	( c@+ 1? drop ) drop 1-
	dup 'pad> ! 'padf> !
	'lins 'modo !
	;

:chmode
	modo 'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;

:proinputa | --
	cifoc sdlColor 
	curx 1- cury 1- curw 2 + curh 2 + SDLRect 
	$ffffff SDLColor |	uiRect
	cursor 
	SDLchar 1? ( modo ex ; ) drop
	SDLkey 0? ( drop ; )
	<ins> =? ( chmode )
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )
	
	<tab> =? ( nextfoco )
	<ret> =? ( nextfoco )
|	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )
|	<dn> =? ( nextfoco ) <up> =? ( prevfoco )
	drop
	
	;

::uiInputLine | 'buff max --
	uiZone
	overfil uiFill
	'proinputa 'iniinput w/foco
	'clickfoco onClick
	drop
	ttemitl ui.. ;	

::uiText
	;
::uiEdit
	;

:datetimefoco
	cifoc sdlColor uiRRect
	sdlkey
	<tab> =? ( nextfoco )
	drop ;
	
::uiDateTime | 'var --
	uiZone
	overfil uiRFill
	'datetimefoco in/foco 
	'clickfoco onClick	
	mark 
	@ ,64>dtf 0 ,c
	empty here ttemitc ui.. ;
	
::uiDate | 'var --
	uiZone
	overfil uiRFill
	[ cifoc sdlColor uiRRect ; ] in/foco 
	'clickfoco onClick	
	mark
	@ ,64>dtd 0 ,c
	empty here ttemitc ui.. ;

::uiTime | 'var --
	uiZone
	overfil uiRFill
	[ cifoc sdlColor uiRRect ; ] in/foco 
	'clickfoco onClick	
	mark
	@ ,64>dtt 0 ,c
	empty here ttemitc ui.. ;

|-------------------
| lista para combo
| datetime
| date
| time
| menu (separa y niveles)

:uiListL | 'var list --
	mark makeindx
	cntlist 6 min
	overfil 
	curx cury dup 'backc ! 
	curw pick3 curh * 
	2over 2over sdlFRect
	guiBox 
	'focoList in/foco 
	'refreshfoco onClick
	chlist
	0 ( over <? ilist 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	


::uiEnd
	topVar 0? ( drop ; ) 
	topbak 
	topList uiListL | 'var list --
	;
	
	