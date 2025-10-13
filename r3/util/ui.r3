| UI
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

##cifil $ff1F2229ff14161A	| over|normal -- color fill
#cisel $ff1967D2ff393F4C	| over|normal -- color select
#cifnt $ffffff		| fuente -- color
##cifoc $4055F4		| foco -- borde

::stDang $ffff8099ff85001B 'cifil ! ;	| danger
::stWarn $ffffBF29fff55D00 'cifil ! ;	| warning
::stSucc $ff5BCD9Aff1F6546 'cifil ! ;	| success
::stInfo $ff80D9FFff005D85 'cifil ! ;	| info
::stLink $ff4258FFff000F85 'cifil ! ;	| link
::stDark $ff393F4Cff14161A 'cifil ! ;	| dark
::stLigt $ffaaaaaaff888888 'cifil ! ;	| white

::overfil cifil guin? 32 and >> sdlcolor ;
::oversel cisel guin? 32 and >> sdlcolor ;

::stFDang $ff9980ffff1B0085 'cifnt ! ;	| danger
::stFWarn $ff005Df5ff29BFff 'cifnt ! ;	| warning
::stFSucc $ff46651Fff9ACD5B 'cifnt ! ;	| success
::stFInfo $ff855D00ffFFD980 'cifnt ! ;	| info
::stFLink $ff850F00ffFF5842 'cifnt ! ;	| link
::stFDark $ff1A1614ff4C3F39 'cifnt ! ;	| dark
::stFWhit $ffffffffffeaeaea 'cifnt ! ;	| white
::stfLigt $ffaaaaaaff888888 'cifnt ! ;	| white

#padx #pady	
#winx #winy #winw #winh	| window
##curx ##cury #curw #curh	| cursorwh

#winstack * 1024
#winstack> 'winstack

#uilastwidget 0

::uiExitWidget
	-1 'foco ! 0 'uilastwidget ! ;

#uilastpos 0 
#uilaststy 0 0 0 0
#uiLastfont 0
#uidata1 0 
#uidata2 0 

|----- backup dims
:dims>64 | 'adr -- 64dim
	@+ $ffff and 16 << 
	swap @+ $ffff and rot or 16 << 
	swap @+ $ffff and rot or 16 << 
	swap @ $ffff and or ;
	
:64>dims | 'adr 64dim --	
	dup 48 >> rot !+ swap 16 <<
	dup 48 >> rot !+ swap 16 <<
	dup 48 >> rot !+ swap 16 <<
	48 >> swap ! ;

::uiPush
	'curx dims>64 
	winstack> !+ 'winstack> ! ; 
	
::uiPop
	-8 'winstack> +! 
	'curx winstack> @ 64>dims ;
	
::uiPushA
	'curx dims>64 'winx dims>64 
	winstack> !+ !+ 'winstack> ! ; 

::uiPopA	
	-16 'winstack> +! 
	'winstack> @+ 'winx swap 64>dims @ 'curx swap 64>dims ;
	
|---------------	
|---- FONT	
::ttemitl | "text" --
	curx
	curh txh - 2/ cury +
	txat txwrite ;

::ttemitc | "text" --
	txw txh | "" w h  
	curw rot - 2/ curx +
	curh rot - 2/ cury +
	txat txwrite ;

::ttemitr | "text" --
	txw txh | "" w h  
	curw curx + rot -
	curh rot - 2/ cury +
	txat txwrite ;

::uiLabelMini
	curx cury curh txh - 1- + txat txwrite
	curh 'cury +! 
	;	

|--------------------
|----- draw/fill
::uiRectW 	winx winy winw winh SDLRect ;
::uiFillW	winx winy winw winh SDLFRect ;
::uiRRectW 	winw winh min 2 >> winx winy winw winh SDLRound ;
::uiRFillW	winw winh min 2 >> winx winy winw winh SDLFRound ;
::uiCRectW 	winw winh min 2/ winx winy winw winh SDLRound ;
::uiCFillW	winw winh min 2/ winx winy winw winh SDLFRound ;

::uiRRect10	10 winx winy winw winh SDLRound ;
::uiRFill10	10 winx winy winw winh SDLFRound ;

::uiRect	curx cury curw curh SDLRect ;
::uiFill	curx cury curw curh SDLFRect ;
::uiRRect	curw curh min 2 >> curx cury curw curh SDLRound ;
::uiRFill	curw curh min 2 >> curx cury curw curh SDLFRound ;
::uiCRect	curw curh min 2/ curx cury curw curh SDLRound ;
::uiCFill	curw curh min 2/ curx cury curw curh SDLFRound ;

::uiTitleF
	winx cury pady - winw curh pady 2* + sdlFrect ;
	
::uiTitle | str --
	curw winw 'curw ! 'winw !
	ttemitc
	curw winw 'curw ! 'winw !
	curh pady 2* + 'cury +! ;

::uiLineH
	curx cury 1 + curw 2 SDLRect
	pady 7 + 'cury +! ;
	
::uiLineV
	curx curw 2/ + 1- cury 1+ 2 curh 2 - SDLRect ;
	
::uiLineWH
	winx cury curh + pady + winw 1 sdlrect ;
	
::uiGridBV
	padx 2* curw +
	0 ( winw pick2 2* - <=?
		over +
		dup winx + winy winh over + SDLLineV
		) 2drop ;
		
::uiGridBH
	pady 2* curh +
	0 ( winh pick2 2* - <=?
		over +
		winx over winy + over winw + SDLLineH
		) 2drop ;
	
::uiGrid# 
	uiGridBH uiGridBV ;

|----- zone

::uicr
	winx padx + 'curx ! 
::uidn	
	curh pady 2* +  'cury +! ;
::uiri
	curx curw + padx 2* + | new x
	winx winw + 
	>? ( drop uicr ; ) 'curx ! ;

#vflex 'uiri

::uiH	'uiri 'vflex ! ;	| << horizontal flow
::uiV	'uidn 'vflex ! ;	| << vertical flow
	
::ui<
	curw padx 2* + neg 'curx +! ;
	
::ui>>
	winx winw + curw - padx 2* - 'curx ! 
	'ui< 'vflex ! ;


::ui..	vflex ex ;

::uiPad | padx pady --
	'pady ! 'padx ! ;

::uiWinBox! | x y x2 y2 --
	pick2 - 'winh ! pick2 - 'winw ! 'winy ! 'winx ! ;

::uiWin! | x y w h --
	2over 2over guiBox
	'winh ! 'winw ! 'winy ! 'winx ! ;

:fitinwin | x y w h 
	2swap 	| w h x y 
	dup pick3 + sh - 0 max - 0 max swap
	dup pick4 + sw - 0 max - 0 max swap
	2swap ;
	
::uiWinFit! | x y w h --
	fitinwin
	uiWin! ;
	
::uiWin@ | x y w h --
	winx winy winw winh ;	
	
::uiGAt | x y --
	curh pady 2* + * pady + winy + 'cury !
	curw padx 2* + * padx + winx + 'curx ! ;
	
::uiGTo | gw gh -- 
	dup curh * swap 1- pady 2* * + 'curh !
	dup curw * swap 1- padx 2* * + 'curw ! ;

::uiGrid | c r --
	winh swap / pady 2* - 'curh ! 
	winw swap / padx 2* - 'curw ! 
	0 0 uiGat ;

::uiGridA | c r -- ; adjust for fit
	winh swap /mod dup 2/ 'winy +! neg 'winh +! pady 2* - 'curh ! 
	winw swap /mod dup 2/ 'winx +! neg 'winw +! padx 2* - 'curw ! 
	0 0 uiGat ;
	
::uiStart
	gui uiH
	0 0 sw sh uiWin! 
	|0 'uiLastWidget !
	;

::uiZone! | x y w h --
	'curh ! 'curw ! 'cury ! 'curx ! ;
	
::uiZone	
	curx cury curw curh guiBox ;
	
::uiZone@ | -- x y w h 
	curx cury curw curh ;
	
|----- Widget	
::uiLabel | "" --
	ttemitl ui.. ;
::uiLabelc | "" --
	ttemitc ui.. ;
::uiLabelr | "" --
	ttemitr ui.. ;

:txicon | char --
	curh over txch - 2/  | char ny
	0 over tx+at
	swap txemit
	0 swap neg tx+at ;
	
::uiTlabel
	txw 4 + 'curw !	
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
:kbBtn
	sdlkey
	<tab> =? ( nextfoco )
	<ret> =? ( >r >r dup >r ex r> r> r> ) | click "" key -- click "" key
	drop ;
	
:focoBtn
	cifoc sdlColor uiRect kbBtn ;
:focoRBtn
	cifoc sdlColor uiRRect kbBtn ;
:focoCBtn
	cifoc sdlColor uiCRect kbBtn ;
	
::uiBtn | v "" --
	uiZone
	overfil uiFill
	'focoBtn in/foco 
	ttemitc onClickFoco ui.. ;	

::uiRBtn | v "" --
	uiZone
	overfil uiRFill
	'focoRBtn in/foco 
	ttemitc onClickFoco ui.. ;	

::uiCBtn | v "" --
	uiZone
	overfil uiCFill
	'focoCBtn in/foco 
	ttemitc onClickFoco ui.. ;	
	
::uiTBtn | v "" -- ; width from text
	txw 4 + 'curw !
	uiZone
	overfil uiFill
	ttemitc onClickFoco 
	curw 'curx +! ;	

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
	a> dup here - 3 >> 'cntlist !
	'here ! ;

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
:focoCheck
	cifoc sdlColor uiRect
	sdlkey
	<tab> =? ( nextfoco )
	<ret> =? ( 1 pick2 << pick3 @ xor pick3 ! ) | 'var n key -- 'var n key
	drop ;

:ic	over @ 1 pick2 << |and? ( drop "[x]" ; ) drop "[ ]" ;
	and? ( drop 139 ; ) drop 138 ;
	
:icheck | 'var n -- 'var n
	uiZone 
	'focoCheck in/foco 
	[ 1 over << pick2 @ xor pick2 ! ; ] onClickFoco
	curx curh txh - 2/ cury + txat 
	ic txicon 32 txemit a@+ txwrite
	ui.. ;
		
::uiCheck | 'var 'list --
	mark makeindx
	indlist >a
	0 ( cntlist <? icheck 1+ ) 2drop
	empty ;	

|----- RADIO
:focoRadio
	cifoc sdlColor uiRect
	sdlkey
	<tab> =? ( nextfoco )
	<ret> =? ( over pick3 ! ) | 'var n key -- 'var n key
	drop ;

:ir over @ |=? ( "(o)" ; ) "( )" ;
	=? ( 137 ; ) 136 ;

:iradio | 'var n --
	uiZone
	'focoRadio in/foco 
	[ 2dup swap ! ; ] onClickFoco
	curx curh txh - 2/ cury + txat 
	ir txicon 32 txemit a@+ txwrite
	ui.. ;

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
	6 curh 4 - 
	SDLFRect ;
	
::uiSliderf | 0.0 1.0 'value --
	uiZone
	'slideh onMoveA | 'dn 'move --	
	slideshow
	'focoBtn in/foco 
	'clickfoco onClick	
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | 0 255 'value --
	uiZone
	'slideh onMoveA | 'dn 'move --	
	slideshow
	'focoBtn in/foco
	'clickfoco onClick		
	@ .d uiLabelC
	2drop ;	

:progreshow | 0.0 1.0 'value --
	overfil uiFill
	oversel
	dup @ pick3 - curw pick4 pick4 swap - */
	curh
	curx cury 2swap
	SDLFRect ;

::uiProgressf | 0.0 1.0 'value --
	uiZone
	'slideh onMoveA | 'dn 'move --	
	progreshow
	'focoBtn in/foco 
	'clickfoco onClick	
	@ .f2 uiLabelC
	2drop ;

::uiProgressi | 0 255 'value --
	uiZone
	'slideh onMoveA | 'dn 'move --	
	progreshow
	'focoBtn in/foco 
	'clickfoco onClick		
	@ .d uiLabelC
	2drop ;	

|---- 
:slidev | 0.0 1.0 'value --
	sdly cury - curh clamp0max 
	2over swap - | Fw
	curh */ pick3 +
	over ! ;
	
:slideshowv | 0.0 1.0 'value --
	overfil uiFill
	oversel
	dup @ pick3 - 
	curh 8 - pick4 pick4 swap - */ cury 1+ +
	curx 2 + swap
	curw 4 - 6 
	SDLFRect ;

::uiVSliderf | 0.0 1.0 'value --
	uiZone
	'slidev onMoveA
	slideshowv
	'focoBtn in/foco 
	'clickfoco onClick	
	@ .f2 uiLabelC
	2drop ;

::uiVSlideri | 0 255 'value --
	uiZone
	'slidev onMoveA
	slideshowv	
	'focoBtn in/foco 
	'clickfoco onClick		
	@ .d uiLabelC
	2drop ;	

:progreshowv | 0.0 1.0 'value --
	overfil uiFill
	oversel
	dup @ pick3 - curh pick4 pick4 swap - */
	curw swap
	curx cury 2swap
	SDLFRect ;

::uiVProgressf | 0.0 1.0 'value --
	uiZone
	'slidev onMoveA
	progreshowv
	'focoBtn in/foco 
	'clickfoco onClick	
	@ .f2 uiLabelC
	2drop ;

::uiVProgressi | 0 255 'value --
	uiZone
	'slidev onMoveA
	progreshowv
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
	'slideh8 onMoveA
	slideshow8
	c@ .d uiLabelC
	2drop ;	

:slidev8 | 0 255 'value --
	sdly cury - curh clamp0max 
	2over swap - | Fw
	curh */ pick3 +
	over c! ;

:slideshow8 | 0 255 'value --
	overfil uiFill
	oversel
	dup c@ pick3 - 
	curh 8 - pick4 pick4 swap - */ cury 1+ +
	curx 2 + swap
	curw 4 - 6 SDLFRect ;

::uiVSlideri8 | 0 255 'value --
	uiZone
	'focoBtn in/foco 
	'clickfoco onClick	
	'slidev8 onMoveA
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
::guiNextlist	
	curh 'cury +! ;

:clist | 'var max --
	cntlist <? ( sdlx curx - curw 16 - >? ( drop ; ) drop )
	overl pick2 ! ;

|----
#listh
#backc 

::GuiBoxlist | n --
	curh * 'listh !
	curx cury dup 'backc ! 
	curw listh guiBox ;
	
::sdlBoxListY | -- n
	sdly cury - curh / ;

|----
:slidev | 'var max rec --
	sdly backc - cury backc - 1- clamp0max | 'v max rec (0..curh)
	over cury backc - */ pick3 8 + ! ;
	
:chlist
	-1 'overl !
	guin? 0? ( drop ; ) drop
	SDLw 1? ( wwlist ) drop
	sdlBoxListY
	pick2 8 + @ + 
	cntlist 1- 
	clampmax 'overl ! 
	'clist onClickFoco ;

:cscroll | 'var max -- 'var max
	cntlist >=? ( ; ) 
	guin? 0? ( drop ; ) drop

	guiPrev | guiBox 1'id+! >>
	
	curx curw + 10 - 
	backc
	10 cury backc - |2over 2over sdlRect
	guiBox 
	cntlist over - 1+	| maxi
	'slidev onMove

	$ffffff sdlcolor 
	curx curw + 10 -		| 'var max maxi x 
	pick3 8 + @ 			| 'var max maxi x ini
	cury backc - pick3 / 	| 'var max maxi x ini hp
	swap over *	backc +		| 'var max maxi x hp ini*hp
	8 rot
	>r >r 4 -rot r> r> sdlfRound	
	drop ;
	
|------ listbox
:focolist
	cifoc sdlColor 
	curx 1- cury 1- curw 2 + listh 2 + sdlRect
	sdlKey
	<tab> =? ( nextfoco )
	<up> =? ( pick2 dup @ 1- clamp0 swap ! )
	<dn> =? ( pick2 dup @ 1+ cntlist 1- clampmax swap ! )
	drop ;
	
::uiList | 'var cntlines list --
	mark makeindx
	
	dup guiBoxList
	
	'focoList in/foco 
	chlist
	0 ( over <? ilist 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	

::uiListV | 'var ntlines vlist --

	;

|------- LAST WIDGET
::uisaveLast | 'vector --
	'uiLastWidget !
	'curx dims>64 'uilastpos !
	'uilaststy 'cifil 3 move	|dsc style
	txFont@ 'uiLastfont !		| font	
	idl 'foco ! ;
	
:uiBacklast |--
	'curx uilastpos 64>dims 
	'cifil 'uilaststy 3 move 
	uiLastfont txfont ;

|----- COMBO
:chlisto
	-1 'overl !
	guin? 0? ( drop ; ) drop
	SDLw 1? ( wwlist ) drop
	sdlBoxListY
	pick2 8 + @ + 
	cntlist 1- 
	clampmax 'overl ! 
	[ clist uiExitWidget ; ] onClick ;


:combolist | --
	uidata1 uidata2 
	mark makeindx
	cntlist 6 min
	overfil 
	
	curx cury dup 'backc ! 
	curw listh
	2over 2over sdlFRect
	cifoc sdlColor 2over 2over sdlRect
	guiBox 
	
	chlisto
	0 ( over <? ilist 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	
	
:iniCombo | 'var 'list -- 'var 'list 
	cifoc sdlColor uiRRect
	
	2dup 'uidata2 ! 'uidata1 !
	curh dup 'cury +! 
	'combolist uisaveLast
	
	neg 'cury +!
	
	SDLkey
	<tab> =? ( nextfoco )
	drop 
	;
	
::uiCombo | 'var 'list --
	uiZone overfil uiRFill
	'iniCombo in/foco
	'clickfoco onClick
	mark makeindx	
	curx 8 + cury txat
	@ uiNindx txwrite
	curx curw + 16 - cury txat 130 txicon
	empty 
	ui.. ;

|----- UIGridBtn
:griblist
	;
	
:glist	
	;
	
::UIGridBtn | 'var 'list 4 4 --
	mark makeindx
	
	dup guiBoxlist
	
	overfil 
	curx cury curw listh SDLFRect 
	'griblist onClickFoco
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
	sdlBoxListY
	pick2 8 + @ + 
	cntlist 1- clampmax 'overl ! 
	'cktree onClickFoco
	;

:iicon | n -- 
	$20 nand? ( drop 32 txemit ; )
	7 >> 1 and 129 + txicon  ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( oversel uiFill )
	overl =? ( overfil uiFill )
	uiNindx 
	c@+ 0? ( 2drop curh 'cury +! ; )
	dup $1f and 4 << curx +
	curh txh - 2/ cury + 
	txat iicon txwrite 
	curh 'cury +! ;

::uiTree | 'var cntlines list --
	mark maketree
	cntlist over - clamp0 pick2 8 + @ <? ( dup pick3 8 + ! ) drop
	
	dup guiBoxlist
		
	'focoList in/foco 
	chtree
	0 ( over <? itree 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	
	
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
	curx cury txat 
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

|-------------------
::uiEnd
	1 'idf +!
|	10 10 txat uilastfoco idl idf foco "foco:%d idf:%d idl:%d uilf:%d" txprint
	uilastWidget 0? ( drop ; ) 
	foco idf <? ( 2drop uiExitWidget ; ) drop
	uiBacklast
	ex ;
	

	