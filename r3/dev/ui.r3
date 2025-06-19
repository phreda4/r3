| UI
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/textb.r3

##uifont
##uifcol $ffffff


#xl #yl #wl #hl 		| layer to put widget
#padx #pady	#advx #advy #marx #mary
#curx #cury #curw #curh	| actual widget

#recbox 0 0

:tt>
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

:ttemitsize | "" -- "" ; cursor
	uifont over 'curw 'curh TTF_SizeUTF8 drop ;
	
:ttemitl | "text" --
	dup c@ 0? ( 2drop ; ) drop
	uifont swap uifcol TTF_RenderUTF8_Blended
	Surf>wh swap | suf h w
	cury pady + curx padx + 'recbox d!+ d!+ d!+ d!
	tt> ;

:ttemitc | "text" --
	uifont swap uifcol TTF_RenderUTF8_Blended
	Surf>wh swap | suf h w
	curh 2/ pick2 2/ - cury +
	curw 2/ pick2 2/ - curx +
	'recbox d!+ d!+ d!+ d!
	tt> ;

:ttemitr | "text" --
	uifont swap uifcol TTF_RenderUTF8_Blended
	Surf>wh swap | suf h w
	cury pady + curw curx + pick2 - 'recbox d!+ d!+ d!+ d!
	tt> ;

|----- zone
::uiFull
	0 0 sw sh
::uiWin | x y w h --
	'hl ! 'wl ! 'yl ! 'xl ! ;

::uiGrid | cols rows --
	hl swap /mod 2/ 'mary ! 'advy !
	wl swap /mod 2/ 'marx ! 'advx ! ;

::uiBox | w h --
	dup 'advy ! pady 2* - 'curh !
	dup 'advx ! padx 2* - 'curw !
	;
	
|----- flow
::uihome
	xl marx + padx + 'curx ! 
	advx padx 2* - 'curw !
	yl mary + pady + 'cury !
	advy pady 2* - 'curh !
	;
	
::uiAt | x y --
	advy * mary + 'curx !
	advy pady 2* - 'curh !
	advx * mary + 'curx !
	advx padx 2* - 'curw !
	;

::uicr
	xl marx + padx + 'curx ! 
::uidn	
	advy 'cury +! ;

::uiNext 
	curx advx + xl wl + >? ( drop uicr ; ) 'curx ! ;

:guiZone 
	curx cury curw curh guiBox ;

|----- draw
::uiRectW 
	xl yl wl hl SDLRect ;
	
::uiFill
	curx cury curw curh SDLFRect ;
	
::uiLine
	xl 4 + cury 3 + wl 8 - 2 SDLRect
	8 'cury +! ;
	
	
|----- Widget	
::uiLabel | "" --
	ttemitl uiNext ;
::uiLabelc | "" --
	ttemitc uiNext ;
::uiLabelr | "" --
	ttemitr uiNext ;
::uitlabel
	ttemitsize 
	4 'curw +!	
	ttemitc 
	curw 'curx +!	
	;
	
::uiBtn | v "" --
	guiZone
	[ $ffffff sdlcolor curx cury curw curh sdlRect ; ] guiI 
	ttemitc onClick uiNext ;	
	
#auxw	
::uiTBtn | v "" -- ; width from text
	ttemitsize 
	4 'curw +!
	curx cury curw curh guiBox 
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

|----- more widget
::uiCombo | 'var 'list --
	mark makeindx
	guiZone
	[ dup @ 1+ cntlist >=? ( 0 nip ) over ! ; ] onClick	
	@ nindx uiLabel
	empty ;

::uiList | 'var 'list --
	mark makeindx
	curx cury curw hl guiBox
	[ sdly cury - curh / over ! ; ] onClick
	indlist >a
	0 ( cntlist <?
		over @ =? ( $7f sdlcolor uiFill )
		a@+ uiLabel
		1+ ) 2drop
	empty ;	

	
:ic	over @ 1 pick2 << and? ( drop "[x]" ; ) drop "[ ]" ;
	
:icheck | 'var n -- 'var n
	guiZone
	[ 1 over << pick2 @ xor pick2 ! ; ] onClick
	ic a@+ swap "%s %s" sprint uiLabel ;
		
::uiCheck
	mark makeindx
	indlist >a
	0 ( cntlist <? icheck 1+ ) 2drop
	empty ;	


:ir over @ =? ( "(o)" ; ) "( )" ;

:iradio | 'var n --
	guiZone
	[ 2dup swap ! ; ] onClick
	ir a@+ swap "%s %s" sprint uiLabel ;

::uiRadio
	mark makeindx
	indlist >a
	0 ( cntlist <? iradio 1+ ) 2drop
	empty ;	


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

#textbox 0 0

::ttsize | "" -- "" w h
	uifont over 'textbox dup 8 + swap 12 + TTF_SizeUTF8 drop
	'textbox 8 + d@+ swap d@ ;
			
#backc	
:sizechar | -- w 
	backc 0? ( drop 8 ; ) drop
	uifont 'backc 'textbox dup 8 + swap 12 + TTF_SizeUTF8 drop
	'textbox 8 + d@ ;
	
::ttcursor | str strcur -- str
	dup c@ 'backc c! | str strcur
	0 over c!		| set end
	swap ttsize  | strcur str w h
	curx rot + cury rot 
	sizechar
	swap SDLFrect
	backc rot c!
	;

::ttcursori | str strcur -- str
	dup c@ 'backc c! | str strcur
	0 over c!		| set end
	swap ttsize  | strcur str w h
	curx rot + cury rot 
	sizechar | x y h w
	rot 	| x h w y
	rot + 2 -	| x w y+h
	swap 2 sdlFrect
	backc rot c!
	;

:cursor | 'var max
	msec $100 and? ( drop ; ) drop
	$a0a0a0 SDLColor
	modo 'lins =? ( drop padi> pad> ttcursor drop ; ) drop
	padi> pad> ttcursori drop ;
	
|----- ALFANUMERICO
:iniinput | 'var max IDF -- 'var max IDF
	pick2 1 - 'cmax !
	pick3 dup 'padi> !
	( c@+ 1? drop ) drop 1 -
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
	uiNext ;	

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

:main
	0 SDLcls gui
	
	2 'padx ! 2 'pady !
	uiFull
|	1 10 uiGrid
|	uiHome

	48 4 512 22 uiWin
|	$ffffff sdlcolor uiRectW
	256 22 uiBox uiHome

	'exit "r3" uitbtn
	"/" uitlabel
	'exit "juegos" uitbtn
	"/" uitlabel
	'exit "2025" uitbtn

|	6 10 uiGrid

	48 32 256 300 uiWin
|	uiRectW
	128 28 uibox
	uiHome
	
	'exit "btn1"  uiBtn
	'exit "btn2"  uiBtn
	uicr

	256 26 uiBox
	"* Widget *" uiLabelc
	uicr
	'vt 'treeex uiList
	$444444 sdlcolor
	uiLine
	|'vt 'treeex uiTree

	
	308 32 512 300 uiWin
|	$888888 sdlcolor uiRectW
	256 26 uibox
	uiHome
	
	'vc 'listex uiCombo | 'var 'list --
	$444444 sdlcolor uiLine uicr
	'vh 'listex uiCheck
	$444444 sdlcolor uiLine uicr
	'vr 'listex uiRadio
	$444444 sdlcolor uiLine uicr
	'pad 512 uiInputLine
	$444444 sdlcolor uiLine uicr
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:t	
	"R3d4 UI" .println
	|"R3d4" 0 SDLfullw | full windows | 
	"UI" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 24 TTF_OpenFont 'uifont !
	uifont 18 TTF_SetFontSize
	
	'main SDLshow
	SDLquit 
	;

: t ;