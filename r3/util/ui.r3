| UI
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/util/textb.r3

##uicons

|$878787ff | DEFAULT_BORDER_COLOR_NORMAL 
|$2c2c2cff | DEFAULT_BASE_COLOR_NORMAL 
|$c3c3c3ff | DEFAULT_TEXT_COLOR_NORMAL 

|$e1e1e1ff | DEFAULT_BORDER_COLOR_FOCUSED 
|$848484ff | DEFAULT_BASE_COLOR_FOCUSED 
|$181818ff | DEFAULT_TEXT_COLOR_FOCUSED 
|$f7f7f7ff | LABEL_TEXT_COLOR_FOCUSED 
|$b0b0b0ff | SLIDER_TEXT_COLOR_FOCUSED 
|$848484ff | PROGRESSBAR_TEXT_COLOR_FOCUSED 
|$f5f5f5ff | TEXTBOX_TEXT_COLOR_FOCUSED 
|$f6f6f6ff | VALUEBOX_TEXT_COLOR_FOCUSED 

|$000000ff | DEFAULT_BORDER_COLOR_PRESSED 
|$efefefff | DEFAULT_BASE_COLOR_PRESSED 
|$202020ff | DEFAULT_TEXT_COLOR_PRESSED 
|$898989ff | LABEL_TEXT_COLOR_PRESSED 

|$6a6a6aff | DEFAULT_BORDER_COLOR_DISABLED 
|$818181ff | DEFAULT_BASE_COLOR_DISABLED 
|$606060ff | DEFAULT_TEXT_COLOR_DISABLED 

|$00000010 | DEFAULT_TEXT_SIZE 
|$00000000 | DEFAULT_TEXT_SPACING 
|$9d9d9dff | DEFAULT_LINE_COLOR 
|$3c3c3cff | DEFAULT_BACKGROUND_COLOR 
|$00000018 | DEFAULT_TEXT_LINE_SPACING 

##uicfnt $ffffff	| font color
##uicbak $444444	| back color
##uicbor $878787	| border color
##uicfil $000087	| fill color

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
	uifont swap uicfnt TTF_RenderUTF8_Blended
	Surf>wh swap ;
	
:tt> | surf --
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

:ttemitl | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt< cury curx recbox! tt> ;

:ttemitc | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt<
	curh 2/ pick2 2/ - cury +
	curw 2/ pick2 2/ - curx +
	recbox! tt> ;

:ttemitr | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt<
	cury curw curx + pick2 - 
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
::uiRect	curx cury curw curh SDLFRect ;
::uiFill	curx cury curw curh SDLFRect ;
	
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
	
::uixy | x y --
	dup 'yl ! pady + 'cury ! 
	dup 'xl ! padx + 'curx ! ;

::uiSize | w h --
	'hl ! 'wl ! ;

::uiBox | w h --
	pady 2* - 'curh !
	padx 2* - 'curw ! ;

::uiGrid | c r --
	hl swap / pady 2* - 'curh ! 
	wl swap / padx 2* - 'curw ! ;
	
::uiStart
	gui
	sw 'wl ! sh 'hl !
	0 0 uixy uiH ;
	
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
	
::uiBtn | v "" --
	guiZone
	$66 [ $ff nip ; ] guiI 
	sdlcolor uiRect
|	[ $ffffff sdlcolor uiRect ; ] guiI 
	ttemitc onClick ui.. ;	
	
::uiTBtn | v "" -- ; width from text
	ttsize ttw 4 + 'curw !
	guiZone
	[ $ffffff sdlcolor uiRect ; ] guiI 
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
	over @ =? ( curx cury curh pady - + curw pady sdlFRect )
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
	$7f SDLColor uiFill
	$3f3fff [ $7f7fff nip ; ] guiI SDLColor
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

|----- LIST
| #vlist 0 0 

:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( $7f sdlcolor uiFill )
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
	$444444 sdlcolor
	curx curw + 16 -		| 'var max maxi x 
	pick3 8 + @ 			| 'var max maxi x ini
	cury backc - pick3 / 	| 'var max maxi x ini hp
	swap over *	backc +		| 'var max maxi x hp ini*hp
	16 rot
	sdlFrect	
	drop ;
	
::uiList | 'var cntlines list --
	mark makeindx
	curx cury dup 'backc ! 
	curw pick3 curh * guiBox 
	'cklist onclick
	0 ( over <? ilist 1+ ) drop
	cscroll
	2drop
	pady 'cury +!
	empty ;	

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
	pick3 @ =? ( $7f sdlcolor uiFill )
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
	'proinputa 'iniinput w/foco
	'clickfoco onClick
	drop
	ttemitl ui.. ;	

::uiText
	;
::uiEdit
	;
