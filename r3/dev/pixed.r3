| PIXED - simple pixel art editor over rimm (SDL2)
| ./r3lin r3/dev/pixed.r3
|
| mouse: left draws, right erases, wheel zooms, middle button pans
| keys (mouse over the canvas): B pencil, E eraser, L line, R rect, O ellipse, G fill, I picker
|   left/right arrows: previous/next frame
| Ctrl+Z / Ctrl+Y undo-redo, Ctrl+S saves PNG, Ctrl+O loads PNG, ESC quits

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3
^r3/rimm/rimmsdl.r3
^r3/rimm/rimmwid.r3
^r3/rimm/rimmcolor.r3
^r3/rimm/rimmfile.r3

|--- document: [w][h] dwords + ARGB pixels (0 = transparent), max 128x128
#pdoc * 65800
#pbase * 65800		| copy of the canvas for the shape preview
#pundomem 0		| 16 undo slots
#pucur 0 #pucnt 0 #prcnt 0

#pfont 0
#pfname * 1024
#pfsn * 1040

|--- frames: all share the size of the document; the current one lives in pdoc
#pfmem 0		| 32 slots of 64KB
#pfcnt 1 #pfcur 0 #pfscr 0 #pplay 0

|--- tools and state
#ptool 0
#ptools "Pencil (B)" "Eraser (E)" "Line (L)" "Rect (R)" "Filled rect" "Ellipse (O)" "Filled ellipse" "Fill (G)" "Picker (I)" 0
#popts 4
#poptl "Mirror X" "Mirror Y" "Grid" 0
#pbsz 1
#ppc 0			| pixel value used to paint (0 = erase)
#pcol $FF0000

#ppal [
$000000 $1D2B53 $7E2553 $008751 $AB5236 $5F574F $C2C3C7 $FFF1E8
$FF004D $FFA300 $FFEC27 $00E436 $29ADFF $83769C $FF77A8 $FFCCAA
$FFFFFF $DDDDDD $BBBBBB $999999 $777777 $555555 $333333 $111111
$FF0000 $00FF00 $0000FF $FFFF00 $00FFFF $FF00FF $885533 $FF8800 ]

#pzoom 12 #ppanx 0 #ppany 0
#pcax 0 #pcay 0 #pcaw 0 #pcah 0
#pox 0 #poy 0
#pinit 0
#pcmod 0
#ppopen 0		| a pop-up was open in this frame
#pdrag 0
#pnb 0 #ppb 0
#plmx 0 #plmy 0
#pmx 0 #pmy 0		| pixel under the mouse
#plpx 0 #plpy 0		| last pixel of the stroke
#ptx0 0 #pty0 0		| start of the stroke

|--- pixel access
:pimw 'pdoc d@ ;
:pimh 'pdoc 4 + d@ ;

:ppxa | x y -- adr|0
	pimh >=? ( 2drop 0 ; ) -? ( 2drop 0 ; )
	swap pimw >=? ( 2drop 0 ; ) -? ( 2drop 0 ; )
	swap pimw * + 2 << 'pdoc 8 + + ;

:pclear | --
	'pdoc 8 + 0 pimw pimh * dfill ;

|--- undo / redo (ring of 16 slots, each a full copy)
:pslot | n -- adr
	65800 * pundomem + ;

:pexch | a b --
	>b >a 8225 ( 1? 1-
		a@ b@ a!+ b!+ ) drop ;

:pundopush | --
	pucur pslot 'pdoc 8225 move
	pucur 1+ $f and 'pucur !
	pucnt 1+ 16 min 'pucnt !
	0 'prcnt ! ;

:pundo | --
	pucnt 0? ( drop ; ) drop
	pucur 1- $f and 'pucur !
	'pdoc pucur pslot pexch
	-1 'pucnt +! 1 'prcnt +! ;

:predo | --
	prcnt 0? ( drop ; ) drop
	'pdoc pucur pslot pexch
	pucur 1+ $f and 'pucur !
	1 'pucnt +! -1 'prcnt +! ;

|--- brush, mirror
#psx #psy

:pset | x y --
	ppxa 0? ( drop ; ) ppc swap d! ;

:pstamp | x y --
	pbsz 2/ - 'psy ! pbsz 2/ - 'psx !
	pbsz ( 1? 1-
		pbsz ( 1? 1-
			dup psx + pick2 psy + pset
		) drop
	) drop ;

:pmirx | x y --
	popts 1 nand? ( 3drop ; ) drop
	over pimw 1- swap - over pstamp 2drop ;

:pmiry | x y --
	popts 2 nand? ( 3drop ; ) drop
	2dup pimh 1- swap - pstamp 2drop ;

:pmirxy | x y --
	popts 3 and 3 <>? ( 3drop ; ) drop
	over pimw 1- swap - over pimh 1- swap - pstamp 2drop ;

:pplot | x y --
	2dup pstamp 2dup pmirx 2dup pmiry pmirxy ;

|--- shapes
#plx #ply #plx1 #ply1 #pldx #pldy #plsx #plsy #plerr
#prx0 #pry0 #prx1 #pry1
#pew #peh #pew2 #peh2 #pecx #pecy #pefill

:psgn | a b -- s
	<? ( drop 1 ; ) drop -1 ;

:pline | x0 y0 x1 y1 --
	'ply1 ! 'plx1 ! 'ply ! 'plx !
	plx1 plx - abs 'pldx !
	ply1 ply - abs neg 'pldy !
	plx plx1 psgn 'plsx !
	ply ply1 psgn 'plsy !
	pldx pldy + 'plerr !
	( plx ply pplot
		plx plx1 xor ply ply1 xor or 1? drop
		plerr 2* pldy >=? ( pldy 'plerr +! plsx 'plx +! )
		pldx <=? ( pldx 'plerr +! plsy 'ply +! ) drop
	) drop ;

:prect | x0 y0 x1 y1 --
	'pry1 ! 'prx1 ! 'pry0 ! 'prx0 !
	prx0 pry0 prx1 pry0 pline
	prx1 pry0 prx1 pry1 pline
	prx1 pry1 prx0 pry1 pline
	prx0 pry1 prx0 pry0 pline ;

:pfrect | x0 y0 x1 y1 --
	'pry1 ! 'prx1 ! 'pry0 ! 'prx0 !
	pry0 pry1 min ( pry0 pry1 max <=?
		prx0 prx1 min ( prx0 prx1 max <=?
			dup pick2 pplot 1+ ) drop
		1+ ) drop ;

:pell? | dx dy w h -- f
	'peh2 ! 'pew2 !
	pew2 * dup *
	swap peh2 * dup * +
	pew2 peh2 * dup *
	<=? ( drop 1 ; ) drop 0 ;

:pinner? | x y -- x y f
	pew 2 <=? ( drop 0 ; ) drop
	peh 2 <=? ( drop 0 ; ) drop
	over 2* pecx - over 2* pecy - pew 2 - peh 2 - pell? ;

:pellpix | x y --
	over 2* pecx - over 2* pecy - pew peh pell? 0? ( 3drop ; ) drop
	pefill 1? ( drop pplot ; ) drop
	pinner? 1? ( 3drop ; ) drop
	pplot ;

:pell | x0 y0 x1 y1 --
	'pry1 ! 'prx1 ! 'pry0 ! 'prx0 !
	prx1 prx0 - abs 1+ 'pew !
	pry1 pry0 - abs 1+ 'peh !
	prx0 prx1 + 'pecx !
	pry0 pry1 + 'pecy !
	pry0 pry1 min ( pry0 pry1 max <=?
		prx0 prx1 min ( prx0 prx1 max <=?
			dup pick2 pellpix 1+ ) drop
		1+ ) drop ;

:pwith1 | 'w -- ; ejecuta w con pincel 1
	pbsz swap 1 'pbsz ! ex 'pbsz ! ;

:pshape | -- ; shape from (ptx0,pty0) to the current pixel
	ptool
	2 =? ( ptx0 pty0 pmx pmy pline )
	3 =? ( ptx0 pty0 pmx pmy prect )
	4 =? ( [ ptx0 pty0 pmx pmy pfrect ; ] pwith1 )
	5 =? ( 0 'pefill ! ptx0 pty0 pmx pmy pell )
	6 =? ( 1 'pefill ! [ ptx0 pty0 pmx pmy pell ; ] pwith1 )
	drop ;

|--- fill (flood fill with its own stack)
#pftg #pffc #pfsp
#pfstk * 65536

:pfpush | x y --
	2dup ppxa 0? ( 3drop ; )
	dup d@ $ffffffff and pftg <>? ( 4drop ; ) drop
	pffc swap d!
	16 << or pfsp 2 << 'pfstk + d! 1 'pfsp +! ;

:pflood | x y --
	2dup ppxa 0? ( 3drop ; ) d@ $ffffffff and 'pftg !
	ppc $ffffffff and 'pffc !
	pftg pffc =? ( 3drop ; ) drop
	0 'pfsp !
	pfpush
	( pfsp 1? drop
		-1 'pfsp +! pfsp 2 << 'pfstk + d@
		dup $ffff and swap 16 >> $ffff and
		2dup 1- pfpush 2dup 1+ pfpush
		over 1- over pfpush over 1+ over pfpush
		2drop ) drop ;

|--- view, mouse
:pfdiv | n d -- q ; floor division
	swap 4096 pick2 * + swap / 4096 - ;

:pinarea | -- f
	SDLx pcax <? ( drop 0 ; ) pcax pcaw + >=? ( drop 0 ; ) drop
	SDLy pcay <? ( drop 0 ; ) pcay pcah + >=? ( drop 0 ; ) drop 1 ;

:playout
	pcax pcaw pimw pzoom * - 2/ + ppanx + 'pox !
	pcay pcah pimh pzoom * - 2/ + ppany + 'poy ! ;

:pfit
	pcaw 16 - pimw / pcah 16 - pimh / min 1 max 64 min 'pzoom !
	0 'ppanx ! 0 'ppany ! ;

:pmousepix
	SDLx pox - pzoom pfdiv 'pmx !
	SDLy poy - pzoom pfdiv 'pmy ! ;

:psetpc | -- ; stroke color from the button and the tool
	0 'ppc !
	ptool 1 =? ( drop ; ) drop
	pdrag 1 nand? ( drop ; ) drop
	pcol $ffffff and $ff000000 or 'ppc ! ;

:psetcol | rgb --
	$ffffff and 'pcol ! ;

:ppick | --
	pmx pmy ppxa 0? ( drop ; ) d@ 0? ( drop ; ) $ffffff and psetcol ;

:pstrokemove | --
	ptool 2 >=? ( drop 'pdoc 'pbase 8225 move pshape ; ) drop
	plpx plpy pmx pmy pline pmx 'plpx ! pmy 'plpy ! ;

:pstrokestart | btn --
	'pdrag ! psetpc
	pmx 'ptx0 ! pmy 'pty0 ! pmx 'plpx ! pmy 'plpy !
	ptool 8 =? ( drop ppick 0 'pdrag ! ; ) drop
	pundopush
	ptool 7 =? ( drop pmx pmy pflood 0 'pdrag ! ; )
	2 >=? ( drop 'pbase 'pdoc 8225 move pshape ; )
	drop pmx pmy pplot ;

:pdostroke | --
	pdrag 1? ( drop SDLb pdrag and 0? ( drop 0 'pdrag ! ; ) drop pstrokemove ; ) drop
	uiPopup? 1? ( drop ; ) drop
	pnb 5 and 0? ( drop ; )
	pinarea 0? ( 2drop ; ) drop
	1 and? ( drop 1 pstrokestart ; ) drop 4 pstrokestart ;

:pdopan | --
	uiPopup? 1? ( drop ; ) drop
	SDLb 2 and 0? ( drop ; ) drop
	pinarea 0? ( drop ; ) drop
	SDLx plmx - 'ppanx +! SDLy plmy - 'ppany +! ;

:pdozoom | --
	uiPopup? 1? ( drop ; ) drop
	SDLw 0? ( drop ; ) drop
	pinarea 0? ( drop ; ) drop
	SDLw pzoom + 1 max 64 min 'pzoom ! ;

|--- canvas drawing
:pcellrect | x y -- ; image pixel on the screen
	pzoom * poy + swap pzoom * pox + swap pzoom dup frect ;

:pgrid | --
	popts 4 nand? ( drop ; ) drop
	pzoom 6 <? ( drop ; ) drop
	$505058 color
	0 ( pimw <=?
		dup pzoom * pox + poy poy pimh pzoom * + 1- lineV
		1+ ) drop
	0 ( pimh <=?
		dup pzoom * poy + pox swap pox pimw pzoom * + 1- lineH
		1+ ) drop ;

:pcursor | --
	pinarea 0? ( drop ; ) drop
	$ffffff color
	pmx pbsz 2/ - pzoom * pox + pmy pbsz 2/ - pzoom * poy + pbsz pzoom * dup rect ;

:pcdraw | --
	$26262c color pcax pcay pcaw pcah frect
	$707070 color pox poy pimw pzoom * pimh pzoom * frect
	$909090 color
	0 ( pimh <?
		0 ( pimw <?
			over over + 1 and 1? ( over pick3 pcellrect ) drop
			1+ ) drop
		1+ ) drop
	0 ( pimh <?
		0 ( pimw <?
			dup pick2 ppxa d@ 1? ( dup $ffffff and color over pick3 pcellrect ) drop
			1+ ) drop
		1+ ) drop
	pgrid
	$000000 color pox 1- poy 1- pimw pzoom * 2 + pimh pzoom * 2 + rect
	pcursor ;

:pcanvas | --
	uiWinBox 'pcah ! 'pcaw ! 'pcay ! 'pcax !
	pinit 0? ( 1 'pinit ! pfit ) drop
	playout pmousepix
	pdopan pdozoom
	playout pmousepix
	pdostroke
	pcax pcay pcaw pcah gclip
	pcdraw
	gclip0
	$ffffff txrgb pcax 8 + pcay pcah + txh - 6 - txat
	pzoom pmy pmx "%d,%d  %dx" txprint
	pcax 150 + pcay pcah + txh - 6 - txat 'pfname "%s" txprint ;

|--- palette
#pps #pqx #pqy

:psetpal | n -- n ; color n of the palette
	dup 2 << 'ppal + d@ ;

:pcellat | n -- n
	dup 7 and pps * cx + 'pqx !
	dup 3 >> pps * cy + 'pqy ! ;

:pswatch | n -- n
	pcellat
	psetpal dup color pqx pqy pps 1- dup frect
	pcol $ffffff and =? ( $ffffff color pqx pqy pps 1- dup rect ) drop ;

:pcellhit | n -- n ; click on the cell: left picks, right stores the current color
	uiPopup? 1? ( drop ; ) drop
	pnb 5 and 0? ( drop ; ) drop
	SDLx pqx <? ( drop ; ) pqx pps + >=? ( drop ; ) drop
	SDLy pqy <? ( drop ; ) pqy pps + >=? ( drop ; ) drop
	pnb 1 and? ( drop psetpal psetcol ; ) drop
	pcol $ffffff and over 2 << 'ppal + d! ;

:ppalette | --
	cw 8 / 'pps !
	0 ( 32 <?
		pswatch pcellhit
		1+ ) drop
	pps 4 * uiAdvH ;

|--- frames
:pfslot | n -- adr
	16 << pfmem + ;

:pfbase | f -- adr ; pixels of frame f
	pfcur =? ( drop 'pdoc 8 + ; ) pfslot ;

:pfstore | -- ; save the current frame in its slot
	pfcur pfslot 'pdoc 8 + pimw pimh * dmove ;

:pfload | n -- ; the frame n becomes the current pixels
	'pdoc 8 + swap pfslot pimw pimh * dmove ;

:pfgoto | n --
	pfstore dup 'pfcur ! pfload
	0 'pucnt ! 0 'prcnt ! ;

:pfreset | -- ; one blank-slate frame list, no undo history
	1 'pfcnt ! 0 'pfcur ! 0 'pfscr ! 0 'pucnt ! 0 'prcnt ! ;

:pfins | -- ; gap after the current frame (pfstore done)
	pfcnt ( pfcur 1+ >?
		dup pfslot over 1- pfslot 8192 move
		1- ) drop
	1 'pfcnt +! ;

:pfadd | --
	pfcnt 32 >=? ( drop ; ) drop
	pfstore pfins
	pfcur 1+ pfslot 0 8192 fill
	pfcur 1+ pfgoto ;

:pfdup | --
	pfcnt 32 >=? ( drop ; ) drop
	pfstore pfins
	pfcur 1+ pfslot pfcur pfslot 8192 move
	pfcur 1+ pfgoto ;

:pfdel | --
	pfcnt 2 <? ( drop pundopush pclear ; ) drop
	pfcur ( pfcnt 1- <?
		dup pfslot over 1+ pfslot 8192 move
		1+ ) drop
	-1 'pfcnt +!
	pfcur pfcnt 1- min dup 'pfcur ! pfload
	0 'pucnt ! 0 'prcnt ! ;

:pfnext | --
	pfcur 1+ pfcnt <? ( pfgoto ; ) drop ;

:pfprev | --
	pfcur 1- -? ( drop ; ) pfgoto ;

|--- draw a frame (sampled so it fits in a box of box pixels)
#pdfx #pdfy #pdfs #pdft #pdfb #pdfa

:pdrawfr | f x y box --
	'pdfb ! 'pdfy ! 'pdfx ! pfbase 'pdfa !
	pimw pimh max 31 + 32 / 'pdft !
	pdfb pimw pimh max pdft / / 1 max 'pdfs !
	$505050 color pdfx pdfy pimw pdft + 1- pdft / pdfs * pimh pdft + 1- pdft / pdfs * frect
	0 ( pimh <?
		0 ( pimw <?
			over pimw * over + 2 << pdfa + d@ 1? ( dup $ffffff and color
				over pdft / pdfs * pdfx + pick3 pdft / pdfs * pdfy + pdfs dup frect ) drop
			pdft + ) drop
		pdft + ) drop ;

:pprevf | -- f ; frame shown in the preview
	pplay 0? ( drop pfcur ; ) drop
	SDL_GetTicks 125 / pfcnt mod ;

:ppreview | --
	pprevf cx cw 128 - 2/ + cy 128 pdrawfr
	128 uiAdvH ;

|--- frame strip (thumbnails)
#pstx #psty #pstw #psth #psvis #psn #psx #psyy #psi

:pshit | -- ; click on the thumbnail psi
	uiPopup? 1? ( drop ; ) drop
	pnb 1 and 0? ( drop ; ) drop
	SDLx psx <? ( drop ; ) psx 42 + >=? ( drop ; ) drop
	SDLy psyy <? ( drop ; ) psyy 42 + >=? ( drop ; ) drop
	psi pfgoto ;

:pstrip | --
	uiWinBox 'psth ! 'pstw ! 'psty ! 'pstx !
	pstw 16 - 52 / 1 max 'psvis !
	pfcur pfscr <? ( dup 'pfscr ! ) drop
	pfcur pfscr psvis + >=? ( dup psvis - 1+ 'pfscr ! ) drop
	pfscr pfcnt psvis - 0 max min 0 max 'pfscr !
	pfcnt pfscr - psvis min 'psn !
	psty 4 + 'psyy !
	0 ( psn <?
		dup 52 * pstx + 8 + 'psx !
		dup pfscr + 'psi !
		$606068 color
		psi pfcur =? ( $ffffff color ) drop
		psx psyy 42 42 rect
		psi psx 1+ psyy 1+ 40 pdrawfr
		$ffffff txrgb psx psyy 44 + txat psi 1+ "%d" txprint
		pshit
		1+ ) drop ;

|--- files: PNG with alpha (run at the end of the frame)
#ppend 0 #pshs #pshp
#pltex #plw #plh #plsurf

:psave | --
	pimw pimh createSurf Surf>pix
	'pdoc 8 + pimw pimh * dmove
	dup 'pfname IMG_SavePNG SDL_FreeSurface ;

:prgba | v -- argb ; RGBA8888 to ARGB, alpha 0 = transparent (0)
	$ffffffff and dup $ff and 0? ( 2drop 0 ; ) 24 << swap 8 >> or ;

:pconv | --
	'pdoc 8 + pimw pimh * ( 1? 1-
		over d@ prgba pick2 d! swap 4 + swap ) 2drop ;

:pload | --
	'pfname loadimg 0? ( drop ; ) 'pltex !
	0 'plw ! 0 'plh !
	pltex 0 0 'plw 'plh SDL_QueryTexture
	plw 128 min 1 max 'plw ! plh 128 min 1 max 'plh !
	plw pimw <>? ( pfreset ) drop plh pimh <>? ( pfreset ) drop
	pundopush
	plw 'pdoc d! plh 'pdoc 4 + d!
	plw plh texIni 0 0 pltex image texEnd
	Tex2Surface dup 'plsurf ! Surf>pixpi drop
	'pdoc 8 + swap plw plh * dmove
	SDL_DestroyTexture plsurf SDL_FreeSurface pltex SDL_DestroyTexture
	pconv pfit ;

:psheetname | -- adr ; file name + -sheet.png
	'pfname 'pfsn strcpy
	'pfsn count + 4 - dup ".png" cmpstr 0? ( drop "-sheet.png" swap strcpy 'pfsn ; ) 2drop
	"-sheet.png" 'pfsn strcat 'pfsn ;

:psheet | -- ; all the frames side by side in one PNG
	pfstore
	pimw pfcnt * pimh createSurf dup 'pshs ! Surf>pix 'pshp ! drop
	0 ( pfcnt <?
		0 ( pimh <?
			dup pimw pfcnt * * pick2 pimw * + 2 << pshp +
			pick2 pfslot pick2 pimw * 2 << +
			pimw dmove
			1+ ) drop
		1+ ) drop
	pshs psheetname IMG_SavePNG pshs SDL_FreeSurface ;

:pdopend | --
	ppend 1 =? ( psave ) 2 =? ( pload ) 3 =? ( psheet ) drop
	0 'ppend ! ;

:pnewdoc | n --
	dup 'pdoc d! 'pdoc 4 + d!
	pclear pfreset pfit ;

:pclearc | --
	pundopush pclear ;

|--- panels
:pleft | --
	190 uiO uiPanelBg
	"PIXED" uiLabelC
	'ptool 'ptools uiRadio
	ui--
	"Brush" 1 8 'pbsz uiSlideriL
	'popts 'poptl uiCheck
	ui--
	2 uiCols
	'pundo "Undo" uiBtn 'predo "Redo" uiBtn
	'pfit "Fit" uiBtn 'pclearc "Clear" uiBtn
	1 uiCols ui--
	"New image" uiLabel
	4 uiCols
	[ 16 pnewdoc ; ] "16" uiBtn [ 32 pnewdoc ; ] "32" uiBtn
	[ 64 pnewdoc ; ] "64" uiBtn [ 128 pnewdoc ; ] "128" uiBtn
	1 uiCols
	uiRest ;

:pright | --
	210 uiE uiPanelBg
	"Color" uiLabel
	'pcol uiColorH
	ui--
	"Palette (right: store)" uiLabel
	ppalette
	ui--
	ppreview
	pfcnt pfcur 1+ "Frame %d/%d" sprint uiLabel
	3 uiCols
	'pfadd "Add" uiBtn 'pfdup "Copy" uiBtn 'pfdel "Delete" uiBtn
	1 uiCols
	'pplay "Play" uiToggle
	ui--
	'pfname 1024 uiFileName
	2 uiCols
	[ 1 'ppend ! ; ] "Save" uiBtn [ 2 'ppend ! ; ] "Load" uiBtn
	1 uiCols
	[ 3 'ppend ! ; ] "Export sheet" uiBtn
	uiRest ;

|--- keyboard
:pctrlkey | key --
	<z> =? ( pundo ) <y> =? ( predo )
	<s> =? ( 1 'ppend ! ) <o> =? ( 2 'ppend ! ) drop ;

:ptoolkey | key --
	<b> =? ( 0 'ptool ! ) <e> =? ( 1 'ptool ! ) <l> =? ( 2 'ptool ! )
	<r> =? ( 3 'ptool ! ) <o> =? ( 5 'ptool ! ) <g> =? ( 7 'ptool ! )
	<i> =? ( 8 'ptool ! ) <le> =? ( pfprev ) <ri> =? ( pfnext ) drop ;

:pkeys | key --
	<ctrl> =? ( 1 'pcmod ! ) <ctr2> =? ( 1 'pcmod ! )
	>ctrl< =? ( 0 'pcmod ! ) >ctr2< =? ( 0 'pcmod ! )
	ppopen 1? ( 2drop ; ) drop
	>esc< =? ( exit )
	pcmod 1? ( drop pctrlkey ; ) drop
	pinarea 1? ( drop ptoolkey ; ) drop
	drop ;

:main
	$1c1c20 cls
	uiStart
	8 6 uiPad
	pfont txfont
	SDLb ppb nand 'pnb !
	pleft
	pright
	80 uiS uiPanelBg pstrip uiRest
	pcanvas
	uiPopup? 'ppopen !
	uiEnd
	SDLb 'ppb ! SDLx 'plmx ! SDLy 'plmy !
	pdopend
	SDLredraw
	sdlkey pkeys ;

:
	"PIXED" 1100 720 SDLinitR
	"media/ttf/Roboto-Medium.ttf" 16 txload 'pfont !
	here 'pundomem ! $102000 'here +!
	here 'pfmem ! $200000 'here +!
	"pixel.png" 'pfname strcpy
	"png" uiFileFilter
	32 'pdoc d! 32 'pdoc 4 + d! pclear
	'main SDLshow
	SDLquit ;
