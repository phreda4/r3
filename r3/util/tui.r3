| Text User Inteface
| PHREDA 2025
|--------
^r3/lib/term.r3
|^r3/lib/trace.r3
^r3/util/utfg.r3

|--- Layout
##fx ##fy ##fw ##fh 

::flin? | x y -- 0/-1
	fy - $ffff and fh >? ( 2drop 0 ; ) drop | limit 0--$ffff
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
	
::flcr
	.cr fx .col ;
	
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
	rflag "%d " .print
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
:exvector
	.cl .hidec tui vecdraw ex ;
	
:tuiredraw
	exvector
	rflag
	$8 and? ( 0 'uikey ! exvector ) | redraw
	$1 and? ( .restorec .showc )	| with cursor
	drop
	.flush ;
	
::onTui | 'vector --
	'vecdraw !
	'exvector .onresize
	tuireset
	tuiredraw
	( rflag $4 nand? drop
		0 'uikey ! 0 'rflag ! |0 'uimouse !
		inevt
		1 =? ( hkey ) |	2 =? ( hmouse )
		1? ( tuiredraw ) | ?? animation
		drop
		5 ms
		) drop 
	tuireset ;


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
	tuiw 
	dup .bc
	drop
	kbBtn
	>r fw fh fx fy r> xText
	tuX? 0? ( 2drop ; ) drop ex ;
	
::tuBtn	
	tuiw dup .bc
	drop
	kbBtn
	fx fy .at
	fw swap calign here .write .reset 1 'fy +!
	tuX? 0? ( 2drop ; ) drop ex ;
	
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
	pick3 8 + @ + cntlist min 
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
	1+ 'dnbk .rep ;
	
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
	cntlist >=? ( drop ; ) 
	pick3 @ =? ( .rever )
	uiNindx 
	fx .col | color?
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
	
|----- TREE
| #vtree 0 0

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
	pick3 @ =? ( .rever )
	uiNindx c@+ 0? ( 2drop ; )
	fx .col | color
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

:tuInputfoco
	tuif 0? ( drop ; )
	1 =? ( drop inInput dup ) drop
	kbInputLine 
	fx fy swap 
	pad> padi> - + | !! falta utf
	swap .at .savec | cursor
	tuC!		| activate cursor
	;
	
::tuInputLine | 'buff max --
	tuiw drop
	tuInputfoco
	drop
	fx fy .at	
	fw 2 <? ( 2drop ; ) 
	swap lwrite
	;
	
|--- check
|--- radio
|--- combo
|--- slide
|--- progress
	
