| UI
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/util/textb.r3

##uicons

#cifil $ff1F2229ff14161A	| over|normal -- color fill
#cisel $ff1967D2ff393F4C	| over|normal -- color select
#cifoc $4055F4		| foco -- borde
#cifnt $ffffff		| fuente -- color

::stDang $ffff8099ff85001B 'cifil ! ;	| danger
::stWarn $ffffBF29fff55D00 'cifil ! ;	| warning
::stSucc $ff5BCD9Aff1F6546 'cifil ! ;	| success
::stInfo $ff80D9FFff005D85 'cifil ! ;	| info
::stLink $ff4258FFff000F85 'cifil ! ;	| link
::stDark $ff393F4Cff14161A 'cifil ! ;	| dark

:overfil
	cifil guin? 32 and >> sdlcolor ;
:oversel	
	cisel guin? 32 and >> sdlcolor ;

::stFDang 
$ff9980ffff1B0085
'cifnt ! ;	| danger
::stFWarn 
$ff005Df5ff29BFff
'cifnt ! ;	| warning
::stFSucc 
$ff46651Fff9ACD5B
'cifnt ! ;	| success
::stFInfo 
$ff855D00ffFFD980
'cifnt ! ;	| info
::stFLink 
$ff850F00ffFF5842
'cifnt ! ;	| link
::stFDark 
$ff1A1614ff4C3F39
'cifnt ! ;	| dark
::stFWhit 
$ffffffffffeaeaea 
'cifnt ! ;	| whait

#xl #yl #wl #hl
#padx #pady	
#curx #cury | cursorxy
#curw #curh	| cursorwh

#copy 0 0 0 0
:ccopy
	curh curw cury curx 'copy !+ !+ !+ ! ;
:cback
	'copy @+ 'curx ! @+ 'cury ! @+ 'curw ! @ 'curh ! ;

#recbox 0 0

:recbox! | h w y x --
	'recbox d!+ d!+ d!+ d! ;
	
|---- FONT	

##uifont
##uifonts	| size font

:tt< | "" -- surf h w
	uifont swap cifnt TTF_RenderUTF8_Blended
	Surf>wh swap ;
	
:tt> | surf --
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

:ttemitl | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt< 
	curh pick2 - 2/ cury +
	curx recbox! tt> ;

:ttemitc | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt<
	curh pick2 - 2/ cury +
	curw pick2 - 2/ curx +
	recbox! tt> ;

:ttemitr | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt<
	curh pick2 - 2/ cury +
	curw curx + pick2 - 
	recbox! tt> ;
	
#ttw #tth
:ttsize | "" -- "" 
	uifont over 'ttw 'tth TTF_SizeUTF8 drop ;
	
#backc
:sizechar | -- 
	backc 0? ( drop 8 'ttw ! ; ) drop
	'backc ttsize drop ;
	
::ttcursor | str strcur -- str
	dup c@ 'backc c! 0 over c!		| set end
	swap ttsize  | strcur str 
	curx ttw + cury sizechar ttw tth
	sdlFrect
	backc rot c! ;

::ttcursori | str strcur -- str
	dup c@ 'backc c! 0 over c!	| set end
	swap ttsize  | strcur str
	curx ttw + cury tth + 4 - sizechar ttw 4
	sdlFrect
	backc rot c! ;

::uiFontSize | size --
	uifont over TTF_SetFontSize
	4 + 'uiFonts ! ;

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
::ui>>
	xl wl + curw - padx 2* - 'curx ! ;
::ui<
	curw padx 2* + neg 'curx +! ;
	
#vflex 'uiri

::uiH	'uiri 'vflex ! ;	| << horizontal flow
::uiV	'uidn 'vflex ! ;	| << vertical flow

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
	0 0 sw sh uiWin ;
	
:guiZone 
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
	
::uitlabel
	ttsize ttw 4 + 'curw !	
	ttemitc 
	curw 'curx +!	
	;
	
	
|dup 0.1 %h TTF_SetFontSize dup %1 TTF_SetFontStyle | KUIB %0001	
#des 0 0

::uiMDText | 'var "" --
	$f0000020ffff curw curh
	uifont textbox 
	curh curw cury curx 'des d!+ d!+ d!+ d!
	SDLrenderer over 0 'des SDL_RenderCopy
	SDL_DestroyTexture
	ui.. ;


|----- Botones	
::uiBtn | v "" --
	guiZone
	overfil uiFill
	ttemitc onClick ui.. ;	

::uiRBtn | v "" --
	guiZone
	overfil uiRFill
	ttemitc onClick ui.. ;	

::uiCBtn | v "" --
	guiZone
	overfil uiCFill
	ttemitc onClick ui.. ;	
	
::uiTBtn | v "" -- ; width from text
	ttsize ttw 4 + 'curw !
	guiZone
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
	
::nindx | n -- str
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
::uiCombo | 'var 'list --
	mark makeindx
	guiZone
	[ dup @ 1+ cntlist >=? ( 0 nip ) over ! ; ] onClick	
	curx curw + 14 - cury curh 2/ + 146 uiconxy
	@ nindx uiLabel
	empty ;

|----- CHECK
:ic	over @ 1 pick2 << |and? ( drop "[x]" ; ) drop "[ ]" ;
	and? ( drop 57 ; ) drop 58 ;
	
:icheck | 'var n -- 'var n
	guiZone
	[ 1 over << pick2 @ xor pick2 ! ; ] onClick
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
	guiZone
	[ 2dup swap ! ; ] onClick
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
	guiZone
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
	guiZone
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow
	@ .f2 uiLabelC
	2drop ;

::uiSlideri | 0 255 'value --
	guiZone
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow	
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
	guiZone
	'slideh8 dup onDnMoveA | 'dn 'move --	
	slideshow8
	c@ .d uiLabelC
	2drop ;	
	
|----- LIST
| #vlist 0 0 

:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( oversel uiFill )
	nindx ttemitl 
	curh 'cury +! ;
		
:cklist
	cntlist <? ( sdlx curx - curw 16 - >? ( drop ; ) drop )
	sdly cury - curh / pick2 dup 8 + @ rot + 
	cntlist 1- clampmax swap ! ;

:slidev | 'var max rec --
	sdly backc - cury backc - 1- clamp0max | 'v max rec (0..curh)
	over cury backc - */ pick3 8 + ! ;
	
:cscroll | 'var max -- 'var max
	cntlist >=? ( ; ) 
	curx curw + 16 - backc
	16 cury backc - |2over 2over sdlRect
	guiBox 
	cntlist over - 1+	| maxi
	'slidev dup onDnMoveA 
	oversel |	$444444 sdlcolor

	curx curw + 16 -		| 'var max maxi x 
	pick3 8 + @ 			| 'var max maxi x ini
	cury backc - pick3 / 	| 'var max maxi x ini hp
	swap over *	backc +		| 'var max maxi x hp ini*hp
	14 rot
	>r >r 4 -rot r> r>
	sdlFRound	
	drop ;
	
:uiFillL	
	curx cury curw pick3 curh * SDLFRect ;

::uiList | 'var cntlines list --
	mark makeindx
	curx cury dup 'backc ! 
	curw pick3 curh * guiBox 
	|overfil uiFillL
	'cklist onclick
	0 ( over <? ilist 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	

::uiListStr
	nindx ;
	
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
	sdly cury - curh / pick2 dup 8 + @ rot + 
	cntlist 1- clampmax 
	dup rot !
	|sdlx curx - 16 >? ( 2drop ; ) drop
	3 << indlist + @ 
	dup c@ $80 xor swap c! ;

:iicon | n -- 
	$20 nand? ( drop uicone ; )
	7 >> 1 and 1 xor 36 + uicon ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( oversel uiFill )
	nindx 
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
	|overfil uiFillL
	'cktree onclick
	0 ( over <? itree 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	
	
::uiTreePath | n -- str
	here 1024 + dup >b >a
	mark
	( dup nindx c@+ $1f and 
		swap a!+ 1? 'lvl ! 
		( 1- dup nindx c@ $1f and 
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
	modo 'lins =? ( drop padi> pad> ttcursor drop ; ) drop
	padi> pad> ttcursori drop ;
	
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
	guiZone
	overfil uiFill
	'proinputa 'iniinput w/foco
	'clickfoco onClick
	drop
	ttemitl ui.. ;	

::uiText
	;
::uiEdit
	;
