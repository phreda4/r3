| Text User Inteface
| PHREDA 2025
|--------
^r3/lib/console.r3
^r3/util/utfg.r3

|^r3/lib/trace.r3

|--- Layout
##fx ##fy ##fw ##fh 

::flin? | x y -- 0/-1
	fy - $ffff and fh >? ( 2drop 0 ; ) drop | limit 0--$ffff
	fx - $ffff and fw >? ( drop 0 ; ) drop
	-1 ;

::flin?1 | x y -- 0/-1
	fy - $ffff and 0 >? ( 2drop 0 ; ) drop | limit 0--$ffff
	fx - $ffff and fw >? ( drop 0 ; ) drop
	-1 ;

#flstack * 64 | 8 niveles
#flstack> 'flstack

:xywh>fl | x y w h -- v
	$ffff and 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or 16 <<
	swap $ffff and or ; | hhwwyyxx
	
|:fl>xywh | v -- x y w h 
|	dup $ffff and swap
|	dup 16 >> $ffff and swap
|	dup 32 >> $ffff and swap
|	48 >> $ffff and ;
|::flx@ | -- x y w h
|	flstack> 8 - @ fl>xywh ;
	
:fl>now | v --
	w@+ 'fx ! w@+ 'fy ! w@+ 'fw ! w@ 'fh ! ;
	
::flxvalid? | -- 0= not valid
	fw 1 <? ( drop 0 ; ) drop 
	fh 1 <? ( drop 0 ; ) drop 
	-1 ;
	
::flx! | x y w h --
	2over 'fy ! 'fx !
	2dup 'fh ! 'fw ! 
	xywh>fl 'flstack !+ 'flstack> ! ;
	
::flx | --
	1 1 cols rows flx! ;
	
:flx+! flstack> 8 - dup w@ rot + clamp0 swap w! ;
:fly+! flstack> 8 - 2 + dup w@ rot + clamp0 swap w! ;
:flw+! flstack> 8 - 4 + dup w@ rot + clamp0 swap w! ;
:flh+! flstack> 8 - 6 + dup w@ rot + clamp0 swap w! ;

::flxpush	
	fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
::flxpop	
	-8 'flstack> +! flstack> fl>now ;
::flxRest 
	flstack> 8 - fl>now ;

| N=^ S=v E=> O=<
| - is full minus the number
::flxN | lineas --
	-? ( fh + ) flxRest dup fly+! dup neg flh+!	'fh ! ;
::flxS | lineas --
	-? ( fh + ) flxRest dup neg flh+! fh fy + over - 'fy ! 'fh ! ;
::flxE | cols --
	-? ( fw + ) flxRest dup neg flw+! fw fx + over - 'fx ! 'fw ! ;
::flxO | cols --
	-? ( fw + ) flxRest dup flx+! dup neg flw+! 'fw ! ;
	
::fw% fw 16 *>> ;
::fh% fh 16 *>> ;

::flpad | x y --
	dup 'fy +! 2* neg 'fh +!
	dup 'fx +! 2* neg 'fw +! ;
	
	
|---- Events
#vecdraw

#id		| now
#idh	| hot
#ida 	| activa
#idf	| id foco
#idfh	
#idfa 
#wid	| panel now
#wida	| panel activa

#rflag	| exit|render|change
##uikey	| tecla
|##uimouse | mouse

:tuireset
	-1 'ida ! -1 'idfa !
	0 'wid ! 0 'rflag !
	;

::exit	rflag $4 or 'rflag ! ; 

:tucl	rflag $2 nand 'rflag ! ;	| exec action is for every widget
:tuX!	rflag $2 or 'rflag ! ;	| exec action need (click or enter)
::tuX?	rflag $2 and ;			| ask for acion (local)

::tuR!	rflag $8 or 'rflag ! ;	| redraw again, some changes
::tuC!	rflag $1 or 'rflag ! ; | cursor ON

|******************
::.tdebug
	wida idf ida id "id:%d ida:%d idf:%d wida:%d " .print
	rflag "%d " .println
	;
|******************	

| 0 = normal
| 1 = over (not all sytems)
| 2 = in
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click
::tuiw | -- flag
	1 'id +! tucl
	ida 
	-1 =? ( drop | !active
		evtmxy flin? 0? ( ; ) drop	| out->0
		evtmb 0? ( drop 1 ; ) drop		| over->1
		id dup 'ida ! 'idfh !
		2 ; )	| in->2
	id =? ( drop | =active
		evtmxy flin? 0? ( drop
			evtmb 0? ( drop -1 'ida ! 5 ; ) drop	| out->5
			4 ;	) drop						| active outside->4
		evtmb 0? ( drop -1 'ida ! 6 ; ) drop		| click->6
		3 ; ) 	 							| active->3
	drop 0 ;

::tuiw1 | -- flag ; 1 line only zone
	1 'id +! tucl
	ida 
	-1 =? ( drop | !active
		evtmxy flin?1 0? ( ; ) drop	| out->0
		evtmb 0? ( drop 1 ; ) drop		| over->1
		id dup 'ida ! 'idfh !
		2 ; )	| in->2
	id =? ( drop | =active
		evtmxy flin?1 0? ( drop
			evtmb 0? ( drop -1 'ida ! 5 ; ) drop	| out->5
			4 ;	) drop						| active outside->4
		evtmb 0? ( drop -1 'ida ! 6 ; ) drop		| click->6
		3 ; ) 	 							| active->3
	drop 0 ;

::tuRefocus
	-1 'idfa ! ;
	
::tuif | -- flag
	id 
	idf <>? ( drop 0 ; )
	wid 1- 'wida ! 
	idfa <>? ( 'idfa ! 1 ; ) | in 
	drop 2 ; | stay
	
::tui
	idfh 
	-? ( id nip )
	id >? ( 0 nip ) 
	dup 'idf ! 'idfh !
	-1 'id ! 0 'wid ! 
	flx ;

|-------------- EVENT
:Focus>> 1 'idfh +! tuR! ; |<<trace ; | cambia id y luego wid
:Focus<< -1 'idfh +! tuR! ;
	
:hkey
	evtkey
	[esc] =? ( exit ) 
	'uikey ! ;
	
|:hmouse 
	|evtmb 1? ( evtmxy .at "." .fwrite ) drop 
|	evtmw 1? ( dup 32 << 'uimouse ! ) drop
|	;
:exvector | --
	.cl .hidec tui vecdraw ex ;

:tuiredraw
	exvector
	rflag
	$8 and? ( 0 'uikey ! exvector ) | redraw
	$1 and? ( .restorec .showc )	| with cursor
	drop
	.flush ;
	
::onTui | 'vector --
	'exvector .onresize
	tuireset 0 'uikey !
	vecdraw swap 'vecdraw ! | stack old value
	tuiredraw
	( rflag $4 nand? drop
		0 'uikey ! 0 'rflag ! |0 'uimouse !
		|inevt
		getevt
		1 =? ( hkey ) |	2 =? ( hmouse )
		1? ( tuiredraw ) | ?? animation
		drop
		) drop 
	tuireset 0 'uikey ! |tuR! 	
	'vecdraw ! | restore old draw
	tuR! | redraw prev screen
	;

::onTuia | 'vector --
	'exvector .onresize
	tuireset 0 'uikey !
	vecdraw swap 'vecdraw ! | stack old value
	tuiredraw
	( rflag $4 nand? drop
		0 'uikey ! 0 'rflag ! |0 'uimouse !
		inevt
		1 =? ( hkey ) |	2 =? ( hmouse )
|		1? ( tuiredraw ) | ?? animation
		drop
		tuiredraw
		20 ms
		) drop 
	tuireset 0 'uikey !
	'vecdraw ! | restore old draw
	tuR! | redraw prev screen
	;

|---------------------	
::.wfill fx fy fw fh .boxf ;
::.wborde fx fy fw fh .boxl ;
::.wborded fx fy fw fh .boxd ;
::.wbordec fx fy fw fh .boxc ;

:x0 fx ;
:x1 fx 1+ ;
:x2 fx pick2 - fw + ;
:x3 fx pick2 - 1- fw + ;
:x4 fx fw pick3 - 2/ + ;
:x5 fx fw + ;
:x6 fx pick2 - fw - fw + ;
#xpl x0 x1 x2 x3 x4 x5 x6 x0
:y0 fy ;
:y1 fy 1+ ;
:y2 fy fh + 1- ;
:y3 fy 2 - fh + ;
:y4 fy fh 2/ + ;
:y5 fy fh + ;
:y6 fy 2 - ;
#ypl y0 y1 y2 y3 y4 y5 y6 y0

|$44 center*
:place | count place -- x y
	dup $7 and 3 << 'xpl + @ ex
	swap 4 >> $7 and 3 << 'ypl + @ ex
	rot drop ;

::.wtitle | place "" --
	utf8count | place "" count
	rot place .at .write ;
	
::tuWin | --
	wid wida =? ( .wbordec ) 1+ 'wid ! ;

::tuWina | --
	wid wida =? ( .Bold ) 1+ 'wid ! .wbordec ;

	
|--- Button	
:kbBtn | 'ev "" -- 'ev ""
	tuif 1 <? ( drop ; ) drop
	uikey 0? ( drop ; )	
	[enter] =? ( tuX! )
	[tab] =? ( focus>> ) 
	[shift+tab] =? ( focus<< ) 
	drop ;
	
::tuTBtn | 'ev "" --
	tuiw dup .bc
	6 =? ( tuX! )
	drop
	kbBtn
	>r fw fh fx fy r> xText
	tuX? 0? ( 2drop ; ) drop ex ;
	
::tuBtn	
	tuiw1 dup .bc
	6 =? ( tuX! )
	drop
	kbBtn
	fx fy .at
	fw swap calign here .write 
	.reset 1 'fy +!
	tuX? 0? ( 2drop ; ) drop ex ;
	
::tuLabel | "" --
	fx .col fw swap lwrite 1 'fy +! .cr ;
::tuLabelC | "" --
	fx .col fw swap cwrite 1 'fy +! .cr ;
::tuLabelR | "" --
	fx .col fw swap rwrite 1 'fy +! .cr ;
	
|--------------------------------	
|---- write line
#(xwrite) 'lwrite

::xwrite!
	'(xwrite) ! ;
	
::xwrite.reset
	'lwrite '(xwrite) ! ;

|---- list mem (intern)
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
	
|---- CLICK
:clicklist | 'var h e -- 'var h e
	evtmy fy -
	cntlist >=? ( drop ; )
	pick3 8 + @ + cntlist 1- min 
	pick3 ! tuX! ;

|---- WHEEL & SCROLL
:calccs | 'var h -- 'v h size pos
	cntlist over <=? ( drop 0 -1 ; )
	pick2 8 + @ | offset
	pick2 dup * pick2 / 0? ( 1+ ) | 'var alto total offst siz
	pick3 over -	| 'var alto total offst siz espacio
	rot *			| 'var alto total siz espacio*off
	rot pick3 - /	| 'var alto siz espacio*off/total
	;

#dnbk ( $e2 $96 $92 $1b $5b $42 $1b $5b $44	0 ) | scroll char+dn+left

:cscroll | 'var h --
	calccs -? ( 2drop ; ) 
	fx fw + 1-  fy rot + .at
	1+ 
	'dnbk .rep ;
	
:chwheel | 'v h 
	cntlist >=? ( ; ) 
	evtmw 0? ( drop ; )  | 'v h w
	pick2 8 + dup 		| 'v h w S S
	@ rot + clamp0 
	cntlist pick3 - clampmax swap !
	;

:pageadj | 'var n key -- 'var n key
	pick2 @+ swap @ | value page
	over >? ( drop pick3 8 + ! ; ) 
	pick3 +
	over <=? ( drop pick2 - 1+ clamp0 pick3 8 + ! ; )
	2drop ;
		
|----- LIST
| #vlist 0 0 

:chsel | 'var n key delta -- 'var n key
	pick3 dup @ rot + cntlist 1- clamp0max swap ! | 'v n k nv
	pageadj
	tuX! ;

:focList | 'var h --
	tuif 0? ( drop ; ) 
	1 =? ( pageadj )
	drop
	chwheel
	uikey 0? ( drop ; )	
	[up] =? ( -1 chsel ) [dn] =? ( 1 chsel )
	[tab] =? ( focus>> ) [shift+tab] =? ( focus<< ) 	
	[pgup] =? ( over neg chsel ) [pgdn] =? ( over chsel )
	drop ;	

:mouList | 'var h --
	tuiw	| mouse
	6 =? ( clicklist )
	drop ;

:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	fx .col | color?
	cntlist >=? ( drop fw .nsp .cr ; ) 
	pick3 @ =? ( .rev )
	uiNindx 
	fw swap (xwrite) ex .cr
	.reset 
	;

::tuList | 'var list --
	fx fy .at
	mark makeindx
	fh
	mouList
	focList
	0 ( over <? ilist 1+ ) drop
	cscroll
	2drop
	empty ;	

|--- list n [words], 0 end
:lwriten
	.d cwrite ;
	
#(xwriten) 'lwriten

::xwriten!
	'(xwriten) ! ;
	
::xwriten.reset
	'lwriten '(xwriten) ! ;

:makeindxn | 'adr -- 
	dup 'indlist !
	dup ( w@+ 1? drop ) drop
	swap - 2/ 1-
	'cntlist ! ;

::uiNindxn
	cntlist >=? ( drop 0 ; )
	2* indlist + w@ ;

:ilistn | 'var max n  -- 'var max n
	pick2 8 + @ over +
	fx .col | color?
	cntlist >=? ( drop fw .nsp .cr ; ) 
	pick3 @ =? ( .rev )
	uiNindxn 
	fw swap (xwriten) ex .cr
	.reset ;
	
::tuListN | 'var listn --
	fx fy .at
	makeindxn
	fh
	mouList
	focList
	0 ( over <? ilistn 1+ ) drop
	cscroll
	2drop ;	
	
|----- TREE
| #vtree 0 0

#lvl	|  $1f:level $20:have_more $80:is_open	
:getval	| adr lvl -- adr nlvl
	lvl <=? ( ; ) 
	a> 8 - @ dup 				
	c@ $20 or over c! | need this mark
	c@ $80 and? ( drop ; )
	2drop
	( >>0 dup c@ 1? 
		$1f and lvl >? drop ) ;

:maketree |
	0 'lvl !
	here dup 'indlist ! >a
	( dup a!+ >>0
		dup c@ 1? 
		$1f and getval 'lvl !
		) 2drop
	a> dup here - 3 >> 'cntlist !
	'here ! ;

::flVisibleIndex | listadr adr -- idx/-1 ; adr debe ser un item de listadr	
	swap
	mark
	maketree 'indlist @ >a
	0 ( cntlist <?
		a@+ pick2 =? ( drop nip empty ; )
		drop 1+ ) 2drop 
	empty -1 ;

:chsel | 'var n key delta -- 'var n key
	pick3 dup @ rot + cntlist 2 - clamp0max swap ! | 'v n k nv (2 -) !!
	pageadj
	tuX! ;

:kbclick	
	pick2 @ 3 << indlist + @ 
	dup c@ $80 xor swap c! 
|	0 chsel
	tuX! tuR! ;
	
:focTree | 'var h --
	tuif 0? ( drop ; ) 
	1 =? ( pageadj )
	drop
	chwheel
	uikey 0? ( drop ; )	
	[up] =? ( -1 chsel ) [dn] =? ( 1 chsel )
	[tab] =? ( focus>> ) [shift+tab] =? ( focus<< ) 
	[enter] =? ( kbclick ) 
	[pgup] =? ( over neg chsel )
	[pgdn] =? ( over chsel )
	drop ;	
	
:mouTree | 'var h --
	tuiw	| mouse
	6 =? ( clicklist kbclick )
	drop ;

#foldicon "▸" "▾"
:,iicon | n -- 
	$20 nand? ( drop 32 ,c ; )
	7 >> 1 and 2 << 'foldicon + ,s ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( .rev )
	fx .col
	uiNindx c@+ 0? ( 2drop fw .nsp .cr ; )
	mark dup $1f and 2* ,nsp ,iicon ,s ,eol empty
	fw here (xwrite) ex .cr 
	.reset ;
	
::tuTree | 'var list --
	fx fy .at
	mark maketree
	fh
	mouTree
	focTree	| focus
	0 ( over <? itree 1+ ) drop
	cscroll
	2drop
	empty ;	

|---- text
::tuText | "" align --
	xalign >r fw fh fx fy r> xText ;

|--- Edita linea
#cmax
##padi>	| inicio
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
:kback pad> padi> <=? ( drop ; ) dup 1- swap 
	padf> over - 1+ cmove -1 'padf> +! -1 'pad> +! ;
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
	
|----- ALFANUMERICO
:chmode
	modo 'lins =? ( drop 'lover 'modo ! .ovec ; )
	drop 'lins 'modo ! .insc ;

:kbInputLine | --
	uikey 0? ( drop ; )	
	32 126 in? ( modo ex ; ) 
	[ins] =? ( chmode )
	[le] =? ( kizq ) [ri] =? ( kder )
	[back] =? ( kback ) [del] =? ( kdel )
	[home] =? ( padi> 'pad> ! ) [end] =? ( padf> 'pad> ! )
	[dn] =? ( focus>> ) [up] =? ( focus<< )
	[tab] =? ( focus>> ) [shift+tab] =? ( focus<< ) 
	
	[enter] =? ( tuX! )
	drop ;	

:inInput | 'var max -- 'var max
	dup 1- 'cmax !
	over dup 'padi> !
	( c@+ 1? drop ) drop 1-
	dup 'pad> ! 'padf> !
	'lins  'modo ! ;

:tuInputfoco | 'buff max -- 'buff max 
	tuif 0? ( drop ; )
	1 =? ( drop inInput dup ) drop
	kbInputLine 
	fx fy swap 
	pad> padi> - + | !! falta utf
	swap .at .savec | cursor
	tuC!		| activate cursor
	;
	
::tuInputLine | 'buff max --
	tuiw1 drop
	tuInputfoco
	drop
	fx fy .at
	fw 2 <? ( 2drop ; ) 
	swap lwrite
	;
	
|--- check
:checkr
	1? ( drop "[X] " ; ) drop "[ ] " ;
	
::tuCheck | 'var "label" --
	tuiw1
	6 =? ( pick2 dup @ 1 xor swap ! tuX! tuR! )
	dup .bc
	drop
	fx fy .at
	over @ checkr .write .write 
	.reset 1 'fy +!
	tuif 0? ( 2drop ; ) drop
	uikey 
	[enter] =? ( over dup @ 1 xor swap ! tuX! tuR! )
	[tab] =? ( focus>> ) [shift+tab] =? ( focus<< )
	2drop ;
  
|--- radio
:checkr
	=? ( drop "(•) " ; ) drop "( ) " ; 
	
::tuRadio | n 'var "label" --
	tuiw1
	6 =? ( pick3 pick3 ! tuX! tuR! )
	dup .bc
	drop
	fx fy .at
	pick2 pick2 @ checkr .write .write 
	.reset 1 'fy +!
	tuif 0? ( 3drop ; ) drop
	uikey 
	[enter] =? ( pick2 pick2 ! tuX! tuR! )
	[tab] =? ( focus>> ) [shift+tab] =? ( focus<< )
	3drop ;

|--- slide

::tuSlider | 'var min max --
	tuiw1
	3 =? ( 3 + )
	6 =? ( | Dragging
		evtmx fx - pick2 pick4 - fw 1- */ pick3 +
		pick4 !
		tuR! tuX! )
	drop
	fx fy .at fw "─" .rep
	rot @ | min max var
	pick2 - fw 2swap swap - */
	fx + fy .at "●" .write
	.reset 1 'fy +! ;

|--- progress
::tuProgress | percent --
	fx fy .at
	100 clamp0max fw 100 */ "█" .rep
	.reset 1 'fy +! ;

|--- combo

|--- paleta ($rrggbb) 
##pal.dark [
	$000000 $18181c $24242a $383842		| bg0 bg1 bg2 bg3
	$eeeeee $8c8c98 $585862 $fab283		| fTx fMu fDi fPr
	$5c9cf5 $9d7cd8 $7fd88f $e06c75 $f5a742	] | fBl fPu fGr fRd fYe

#palp 'pal.dark

::pal! | 'pal --
	'palp ! ;

:rgb@ | n -- r g b
	2 << palp + d@
	dup 16 >> $ff and swap
	dup 8 >> $ff and swap
	$ff and ;

::cbg | n --
	rgb@ .bgrgb ;
::cfg | n --
	rgb@ .fgrgb ;

::bg0 0 cbg ;	::bg1 1 cbg ;	::bg2 2 cbg ;	::bg3 3 cbg ;
::fTx 4 cfg ;	::fMu 5 cfg ;	::fDi 6 cfg ;	::fPr 7 cfg ;
::fBl 8 cfg ;	::fPu 9 cfg ;	::fGr 10 cfg ;	::fRd 11 cfg ;	::fYe 12 cfg ;

|--- cursor / linea -------------------------------------------------
#tdef #tdef0

::fhome | -- ; arriba-izquierda del panel
	fx fy .at ;
::fcr | -- ; baja linea (y reinicia columnas de tabla)
	.cr fx .col tdef0 'tdef ! ;
|--- lineas: "" -- (ancho fw, bajan linea) -----------------------------
::.lw	fw swap lwrite fcr ;
::.cw	fw swap cwrite fcr ;
::.rw	fw swap rwrite fcr ;

|--- numeros: n w -- ----------------------------------------------------
::.nd .d swap .r. .write ;
::.nh .h swap .r. .write ;
::.nf .f swap .r. .write ;
::.nb .b swap .r. .write ;

|--- panel ----------------------------------------------------------
::pan | "title" -- ; fondo bg1, padding 1, titulo en acento
	bg1 .wfill 1 1 flpad fhome
	fPr .Bold .write fcr .NBold fTx ;

::.lines | 'v n -- ; v ( i -- ) escribe trozos de la fila i; lines agrega .nl
	0 ( over <? pick2 over swap ex fcr 1+ ) 3drop ;

|--- tabla: def = ( w just ... 0 ) just 0 izq 1 centro 2 der -----------
::tcols | 'def --
	dup 'tdef0 ! 'tdef ! ;
::cell | "" -- ; el color es el activo
	tdef c@+ $ff and 0? ( 3drop ; )
	swap c@+ $ff and swap 'tdef !
	rot swap
	0? ( drop lwrite .sp ; )
	1 =? ( drop cwrite .sp ; )
	drop rwrite .sp ;
::row | "a|b|c" -- ; fila completa desde texto separado por |
	mark here swap
	( c@+ 1? $7c =? ( 0 nip ) ,c ) ,c 0 ,c drop
	( dup c@ 1? drop dup cell >>0 ) 2drop
	fcr empty ;
::hdr | "a|b|c" --
	fMu .Bold row .NBold fTx ;

|--- tabla con recuadro: mismo def que tcols, widths w ---------------
| linea  ┌──┬──┐ / ├──┼──┤ / └──┴──┘  ;  fila  │ a │ b │
| cada columna ocupa w+2 entre bordes; ancho total = tbw
| bordes en fDi, el contenido usa el color de la fila (tbrowc) y el fondo activo
:tbline | "l" "m" "r" -- ; linea horizontal
	>r >r .write
	tdef0 dup c@ $ff and
	( 1? 2 + "─" .rep
		2 + dup c@ $ff and
		1? ( r@ .write ) )
	2drop r> drop r> .write fcr ;

::tbw | -- n ; ancho total de la tabla con recuadro
	1 tdef0
	( dup c@ $ff and 1? 3 + rot + swap 2 + ) 2drop ;

::tbtop fDi "┌" "┬" "┐" tbline ;
::tbsep fDi "├" "┼" "┤" tbline ;
::tbbot fDi "└" "┴" "┘" tbline ;

:tbcol | 'color -- ; borde izquierdo de una columna y color del contenido
	fDi "│" .write .sp ex ;

::tbrowc | "a|b|c" 'color -- ; fila con recuadro, 'color = palabra de color
	>r mark here swap
	( c@+ 1? $7c =? ( 0 nip ) ,c ) ,c 0 ,c drop
	( dup c@ 1? drop
		r@ tbcol dup cell >>0 ) 2drop
	( tdef c@ $ff and 1? drop			| columnas sin dato
		r@ tbcol "" cell ) drop
	fDi "│" .write r> drop fcr empty ;

::tbrow | "a|b|c" -- ; fila con recuadro
	'fTx tbrowc ;
::tbhdr | "a|b|c" -- ; cabecera con recuadro
	.Bold 'fMu tbrowc .NBold fTx ;

|--- texto ajustado: "" n wrap ----------------------------------------
| corta por palabra (o duro si no hay espacio) en fw columnas, UTF-8, \n corta
| linea; escribe como mucho n lineas (usar fh).
| sin variables: q = puntero, ch = columnas, p = inicio de linea (en la pila)

:wstep | q ch -- q ch f ; avanza un caracter, f = 0 fin de linea
	over c@ $ff and
	0? ( ; )
	32 <? ( drop 0 ; )
	$c0 and $80 =? ( drop swap 1+ swap 1 ; )	| byte de continuacion utf8
	drop dup fw >=? ( drop 0 ; ) drop
	1+ swap 1+ swap 1 ;

:wscan | p -- q ch ; hasta fin de linea o fw columnas
	0 ( wstep 1? drop ) drop ;

:wbrk | p q -- sp/0 ; ultimo espacio en [p,q)
	( over >? 1- dup c@ $ff and 32 =? ( drop nip ; ) drop ) 2drop 0 ;

:ncol | n b -- n' ; suma 1 si b no es byte de continuacion utf8
	$ff and $c0 and $80 <>? ( drop 1+ ; ) drop ;

:wcols | p e -- n ; columnas utf8 entre p y e
	over - 0						| p L n
	( over 1? drop
		pick2 c@ ncol				| p L n'
		rot 1+ -rot					| p' L n'
		swap 1- swap				| p' L' n'
		) drop nip nip ;

:wcut | p q ch -- p c e s ; c columnas escritas, e fin del texto, s bytes a saltar
	over c@ $ff and
	0? ( drop swap 0 ; )			| fin de texto
	33 <? ( drop swap 1 ; )			| salto de linea o espacio justo en el corte
	drop pick2 pick2 wbrk			| p q ch sp
	0? ( drop swap 0 ; )			| sin espacio: corte duro
	nip nip 2dup wcols swap 1 ;		| p c sp 1

:wlin | p -- n ; escribe una linea, devuelve el comienzo de la siguiente
	dup wscan wcut					| p c e s
	over + >r						| p c e        r: n
	rot swap over - .type			| c
	fw swap -
	2 >=? ( .nsp r> ; )
	1? ( .sp ) drop r> ;

::wrap | "" n --
	( 1? over c@ $ff and 0? ( 3drop ; ) drop
		swap wlin fcr swap 1- ) 2drop ;
