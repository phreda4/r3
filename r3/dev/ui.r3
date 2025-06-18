| UI
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/textb.r3
|^r3/util/ttext.r3


##uifont
##uifcol $ffffff

#xl #yl #wl #hl 

#padx #pady	#marx #mary
#curx #cury #curw #curh

#recbox 0 0

:tt>
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

:ttemitsize | "" -- "" ; cursor
	uifont over 'curw 'curh TTF_SizeUTF8 drop ;
	
:ttemitl | "text" --
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

::uiWin | x y w h --
	'hl ! 'wl ! 2dup 'yl ! 'xl ! 'cury ! 'curx ! ;

::uiCols | cols --
	wl swap /mod 'marx ! 'curw ! ;

::uiRows | rows --
	hl swap /mod 'mary ! 'curh ! ;

::uiBox | w h --
	'curh ! 'curw ! ;

:flow<	curw neg 'curx +! ;
:flow^	curh neg 'cury +! ;

:flowv	curh 'cury +! ;
:flowcr xl 'curx ! flowv ;
:flow>	curx curw + xl wl + >? ( drop flowcr ; ) 'curx ! ;

#flownext 'flowv

::ui> 'flow> 'flownext ! ;
::ui< 'flow< 'flownext ! ;
::uiv 'flowv 'flownext ! ;
::ui^ 'flow^ 'flownext ! ;


::uiFill | color --
	SDLcolor
	curx cury curw curh SDLFRect ;
	
::uiNext | -- ; next
	flownext ex ;
	
::uiLabel | "" --
	ttemitl uiNext ;
::uiLabec | "" --
	ttemitc uiNext ;
::uiLaber | "" --
	ttemitr uiNext ;
::uitlabel
	ttemitsize 
	padx 2* 4 + 'curw +!	
	ttemitc uiNext ;
	
::uiBtn | v "" --
	curx cury curw curh guiBox
	[ $ffffff sdlcolor curx cury curw curh sdlRect ; ] guiI 
	ttemitc onClick uiNext ;	
	
::uiTBtn | v "" -- ; width from text
	ttemitsize 
	padx 2* 4 + 'curw +!
	curx cury curw curh guiBox
	[ $ffffff sdlcolor curx cury curw curh sdlRect ; ] guiI 
	ttemitc onClick uiNext ;	
	
|----------------------
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

	
::uiCombo | 'var 'list --
	mark makeindx
	curx cury curw curh guiBox
	[ dup @ 1+ cntlist >=? ( 0 nip ) over ! ; ] onClick	
	@ nindx uiLabel
	empty ;

::uiList | 'var 'list --
	mark makeindx
	curx cury curw hl guiBox
	[ sdly cury - curh / over ! ; ] onClick
	indlist >a
	0 ( cntlist <?
		over @ =? ( $7f uiFill )
		a@+ uiLabel
		1+ ) 2drop
	empty ;	

	
:ir
	over @ and? ( "(o)" ; ) "( )" ;
	
:iradio | 'var n -- 'var n
	curx cury curw curh guiBox
	[ 1 over << pick2 @ xor over ! ; ] onClick
	ir a@+ swap "%s %s" sprint uiLabel
	;
		
::uiRadio
	mark makeindx
	indlist >a
	0 ( cntlist <? iradio 1+ ) 2drop
	empty ;	

:ic
	over @ =? ( "[X]" ; ) "[ ]" ;

:icheck | 'var n --
	curx cury curw curh guiBox
	[ 2dup swap ! ; ] onClick
	ic a@+ swap "%s %s" sprint uiLabel
	;

::uiCheck
	mark makeindx
	indlist >a
	0 ( cntlist <? icheck 1+ ) 2drop
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
	curx cury curw curh guiBox
	'proinputa 'iniinput w/foco

|	'clickfoco onClick
	drop
	ttemitl 
	uiNext ;	

|--------------------------------------


:pathpanel
	ui>
	uifont 18 TTF_SetFontSize
	48 4 512 300 uiWin
	256 22 uiBox
	'exit "r3" uitbtn
	"/" uitlabel
	'exit "juegos" uitbtn
	"/" uitlabel
	'exit "2025" uitbtn
	;

:dirpanel
	uiv
	uifont 18 TTF_SetFontSize
	48 32 256 300 uiWin
	256 22 uiBox
	10 ( 1?
		dup "-%d-" sprint uiLabel
		1- ) drop
	;
	
#pad * 1024
		
:namepanel
	32 500 512 24 uiWin
	512 24 uiBox
	'pad 1024 uiInputLine | 'buff max --
	;
|--------------------------------------
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

:main
	0 SDLcls gui
|	sw 2/ sh 2/ ttitle sprite
	
	pathpanel
	dirpanel
|	namepanel
	
	uiv
	600 32 512 300 uiWin
	256 24 uibox
	'vc 'listex uiCombo | 'var 'list --

	'vt 'treeex uiList
	|'vt 'treeex uiTree
	
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
	
	'main SDLshow
	SDLquit 
	;

: t ;