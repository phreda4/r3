| UI
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/textb.r3

#uicons
##uifont
##uifonts
##uifcol $ffffff

#xl #yl #wl #hl		| 
#padx #pady	
#curx #cury 
#curw #curh	| actual widget

#copy 0 0 0 0
:ccopy
	curh curw cury curx 'copy !+ !+ !+ ! ;
:cback
	'copy @+ 'curx ! @+ 'cury ! @+ 'curw ! @ 'curh ! ;

#recbox 0 0

:tt<
	uifont swap uifcol TTF_RenderUTF8_Blended
	Surf>wh swap ; | suf h w
	
:tt>
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

:ttemitl | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt<
	cury curx 'recbox d!+ d!+ d!+ d!
	tt> ;

:ttemitc | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt<
	curh 2/ pick2 2/ - cury +
	curw 2/ pick2 2/ - curx +
	'recbox d!+ d!+ d!+ d!
	tt> ;

:ttemitr | "text" --
	dup c@ 0? ( 2drop ; ) drop
	tt<
	cury curw curx + pick2 - 
	'recbox d!+ d!+ d!+ d!
	tt> ;

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
	SDLFrect
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

|----- zone
#xend

::uicr
	xl padx + 'curx ! 
::uidn	
	hl 'cury +! ;
::uiri
	curx wl + xend >? ( drop uicr ; ) 'curx ! ;
	
#vflex 'uiri

::uiH	'uiri 'vflex ! ;	| << horizontal flow
::uiV	'uidn 'vflex ! ;	| << vertical flow

:ui..	vflex ex ;

::uiHome
	sw 'xend ! uiH
	0 0 
::uixy
	dup 'yl ! pady + 'cury ! 
	dup 'xl ! padx + 'curx ! ;
::uiPad
	dup 'pady ! yl + 'cury !
	dup 'padx ! xl + 'curx ! ;
::uiBox | w h --
	dup 'hl ! pady 2* - 'curh !
	dup 'wl ! padx 2* - 'curw ! ;
::uiEndx | xend
	'xend ! ;
	
:guiZone 
	curx cury curw curh guiBox ;

|----- draw/fill
::uiRectW 
	xl yl wl hl SDLRect ;
	
::uiFill
	curx cury curw curh SDLFRect ;
	
::uiLine
	curx cury 1 + curw 2 SDLRect
	pady 7 + 'cury +! ;
	
|----- icon
::uiconxy | x y nro --
	uicons ssprite ;
	
::uicon | nro --
	curx 14 + cury curh 2/ +
	rot uicons ssprite 
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
	$666666 [ $ffffff nip ; ] guiI 
	sdlcolor curx cury curw curh sdlRect
|	[ $ffffff sdlcolor curx cury curw curh sdlRect ; ] guiI 
	ttemitc onClick ui.. ;	
	
::uiTBtn | v "" -- ; width from text
	ttsize ttw 4 + 'curw !
	guiZone
	[ $ffffff sdlcolor curx cury curw curh sdlRect ; ] guiI 
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
	
:nindx | n -- str
	3 << indlist + @ ;

|----- COMBO
::uiCombo | 'var 'list --
	mark makeindx
	guiZone
	[ dup @ 1+ cntlist >=? ( 0 nip ) over ! ; ] onClick	
	curx curw + 14 - cury curh 2/ + 146 uiconxy
	@ nindx uiLabel
	empty ;

:ilist | 'var n -- 'var n
	guiZone
	[ 2dup swap ! ; ] onClick
	over @ =? ( $7f sdlcolor uiFill )
	a@+ uiLabel ;
		
::uiList
	mark makeindx
	indlist >a
	0 ( cntlist <? ilist 1+ ) 2drop
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
		
::uiCheck
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

::uiRadio
	mark makeindx
	indlist >a
	0 ( cntlist <? iradio 1+ ) 2drop
	empty ;	

|---- Horizontal slide
:slideh | 0.0 1.0 'value --
	sdlx curx - curw clamp0max 
	2over swap - | Fw
	curw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	$7f SDLColor
	curx cury curw curh SDLFRect
	$3f3fff [ $7f7fff nip ; ] guiI SDLColor
	dup @ pick3 - 
	curw 8 - pick4 pick4 swap - */ 
	curx 1 + +
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

|-----
::uiTable
	;
::uiTree
	;
::uiTab
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
	padf> >? (
		dup padi> - cmax >=? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
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
	$ffffff SDLColor
	curx cury curw curh sdlRect

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
	ttemitl
	ui.. ;	

|-------- example
#pad * 1024
	
#listex "uno" "dos" "tres" 0

#treeex
"+uno"
" .aaa"
" .bbb"
".dos"
".tres"
"+listado"
" .uno"
" .dos"
0

#vc
#vt
#vh
#vr
#si #sf

:ui----
	$444444 sdlcolor uiLine ;
	
:main
	0 SDLcls gui

	uiHome 
	3 4 uiPad
	48 4 uiXy |	$ffffff sdlcolor uiRectW
	256 uiFonts 16 + uiBox 

	'exit "r3" uitbtn "/" uitlabel
	'exit "juegos" uitbtn "/" uitlabel
	'exit "2025" uitbtn

	48 uiFontS 16 + uiXy |	uiRectW
	128 uiFonts 8 + uiBox
	
	'exit "btn1"  uiBtn 
	'exit "btn2"  uiBtn 
	uicr

	uiV | vertical
	256 uiFonts 8 + uiBox
	"* Widget *" uiLabelc

	'vt 'treeex uiList
	ui----
	|'vt 'treeex uiTree

	
	308 uiFontS 16 + uiXy |	$888888 sdlcolor uiRectW
	256 uiFonts 8 + uiBox
	|ui-
	'vc 'listex uiCombo | 'var 'list --
	ui----
	'vh 'listex uiCheck
	ui----
	'vr 'listex uiRadio
	ui----
	'pad 512 uiInputLine
	ui----
	0 255 'si uiSlideri
	ui----
	-1.0 1.0 'sf uiSliderf
	ui----
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:t	
	"R3d4 UI" .println
	|"R3d4" 0 SDLfullw | full windows | 
	"UI" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 16 TTF_OpenFont 'uifont !
	24 21 "media/img/icong16.png" ssload 'uicons !
	20 uifontsize

	'main SDLshow
	SDLquit 
	;

: t ;