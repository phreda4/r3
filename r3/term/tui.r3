^r3/lib/term.r3
^./utfg.r3

#.exit 0 
::exit 1 '.exit ! ;

#vecdraw

#wflag	| widget flag
#rflag	| render flag

#id		| now
#idh	| hot
#ida 	| activa
#idf	| id foco
#idfa 

#wid	| panel now
#wida	| panel activa

##uikey	| tecla

#info "ok" * 256

::.tdebug
	wida idf ida id "id:%d ida:%d idf:%d wida:%d " .print
|	uikey ">>%h<<" .print
|	'info .write
	;

:tuireset
	-1 'ida !
	-1 'idfa !
	0 'idf !
	0 'wid !
	;

| 0 = normal
| 1 = over (not all sytems)
| 2 = in
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click

::tuiw | -- flag
	1 'id +! 
	ida 
	-1 =? ( drop | !active
		evtmxy .inwin? 0? ( ; ) drop	| out->0
		evtmb 0? ( drop 1 ; ) drop		| over->1
		id dup 'ida ! 'idf !
		2 ; )	| in->2
	id =? ( drop | =active
		evtmxy .inwin? 0? ( drop
			evtmb 0? ( drop -1 'ida ! 5 ; ) drop	| out->5
			4 ;	) drop						| active outside->4
		evtmb 0? ( drop -1 'ida ! 6 ; ) drop		| click->6
		3 ; ) 	 							| active->3
	drop 0 ;

::tuif | -- flag
	id 
	idf <>? ( drop 0 ; )
	wid 1- 'wida ! 
	idfa <>? ( 'idfa ! 1 ; ) | in 
	drop 2 ; | stay
	
::tui
	idf 
	-? ( id 'idf ! )
	id >? ( 0 'idf ! ) 
	drop
	-1 'id !
|	wida wid >? ( 0 'wida ! ) drop
	0 'wid ! ;

|-------------- EVENT
:hkey
	evtkey
	[esc] =? ( exit ) 
	[tab] =? ( 1 'idf +! ) | cambia id y luego wid
	[shift+tab] =? ( -1 'idf +! ) | cambia id y luego wid
	'uikey ! ;
	
|:hmouse evtmb 1? ( evtmxy .at "." .fwrite ) drop ;
	
:tredraw
	.hidec
	0 'rflag !
	vecdraw ex 
	rflag
	1 and? ( .restorec .showc )
	drop
	.flush ;
	
::onTui | 'vector --
	dup .onresize
	'vecdraw !
	tuireset
	tredraw
	( .exit 0? drop
		0 'uikey !
		inevt	
		1 =? ( hkey ) |	2 =? ( hmouse )
		1? ( tredraw ) | ?? animation
		drop
		10 ms
		) drop 
	tuireset ;

|---------------------	
::tuWin | x y w h --
	.win
	wid wida =? ( .wborde ) 1+ 'wid !
	;
	
::tuBtn | 'ev "" --
	.wtext
	drop
	;
	
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
|	<tab> =? ( nextfoco ) <ret> =? ( nextfoco )
|	<dn> =? ( nextfoco ) <up> =? ( prevfoco )
	drop ;	

:inInput | 'var max -- 'var max
	dup 1- 'cmax !
	over dup 'padi> !
	( c@+ 1? drop ) drop 1-
	dup 'pad> ! 'padf> !
	'lins  'modo ! ;

:tuInputfoco
	tuif 0? ( drop ; )
	1 =? ( drop inInput ; ) drop
	kbInputLine 
	.wat@ swap 
	pad> padi> - + | !! falta utf
	swap .at .savec | cursor
	1 'rflag !		| activate cursor
	;
	
::tuInputLine | 'buff max --
	tuiw drop
	tuInputfoco
	drop .wtext
	;
	
|--------------------------------	
|--------------------------------	
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
	
|----- LIST
| #vlist 0 0 

:focList | --
	tuif 0? ( drop ; ) drop
	uikey 0? ( drop ; )	
	[up] =? ( pick2 dup @ 1- clamp0 swap ! )
	[dn] =? ( pick2 dup @ 1+ cntlist 1- clampmax swap ! )
	drop ;	

:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( .rever )
	uiNindx .wtext .reset ;

::tuList | 'var cntlines list --
	mark makeindx
	tuiw drop
	focList
	0 ( over <? ilist 1+ ) drop
|	cscroll
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

:kbclick	
	pick2 @ 3 << indlist + @ 
	dup c@ $80 xor swap c! ;
	
:focTree | --
	tuif 0? ( drop ; ) drop
	uikey 0? ( drop ; )	
	[up] =? ( pick2 dup @ 1- clamp0 swap ! )
	[dn] =? ( pick2 dup @ 1+ cntlist 1- clampmax swap ! )
	[enter] =? ( kbclick ) 
	drop ;	

#foldicon "▸" "▾"
:,iicon | n -- 
	$20 nand? ( drop 32 ,c ; )
	7 >> 1 and 2 << 'foldicon + ,s ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( .rever )
	uiNindx c@+ 0? ( 2drop ; )
	dup $1f and 2* .wmargin
	mark ,iicon ,s ,eol empty
	here .wtext .reset ;
	
::tuTree | 'var cntlines list --
	mark maketree
	tuiw drop
	focTree	
	0 ( over <? itree 1+ ) drop
|	cscroll
	2drop
	empty ;	

|--------------------------------	
|--------------------------------	
##uiDirs
##uiFiles

#basepath * 1024

#stckhdd>
#l1 0 #l2 0 

|------ folders for tree
:backdir | -- ;  2 '/' !!
	0 'l1 !
	'basepath ( c@+ 1? 
		$2f =? ( l1 'l2 ! over 'l1 ! )
		drop ) 2drop
	0 l2 1? ( c! ; ) 2drop ;	

:pushdd | --
	stckhdd> findata 
|WIN|	520 
|LIN|	8
	cmove |dsc
|WIN|	520 
|LIN|	8
	'stckhdd> +! ;
	
:pophdd
|WIN|	-520 
|LIN|	-8
	'stckhdd> +!
	findata stckhdd>
|WIN|	520 
|LIN|	8
	cmove ;

:dir.?
	dup fname 
	dup "." = 1? ( 2drop 0 ; ) drop
	dup ".." = 1? ( 2drop 0 ; ) drop
	drop
	dup fdir ;
	
:scand | level "" --
	'basepath strcat "/" 'basepath strcat
	'basepath 
|WIN| "%s/*" sprint
	ffirst 0? ( drop ; ) |drop fnext drop 
	( dir.? 1? (
		pushdd
|		pick2 64 + .emit over fname .write .cr
		pick2 64 + ,c over fname ,s 0 ,c
		pick2 1+ pick2 fname scand
		pophdd
		) 2drop
	fnext 1? ) 2drop 	
	backdir ;

	
|----- Files
:+file | f --
	dup FDIR 1? ( 2drop ; ) drop | nodirs
	dup FNAME
	dup ".." = 1? ( 3drop ; ) drop
	dup "." = 1? ( 3drop ; ) drop
	,s |" " ,s
|	dup FSIZEF 12 >> ,d " Kb" ,s
|	dup FDIR ,d
	|dup FWRITEDT dt>64 ,64>dtf
	drop 
	0 ,c ;
	
::scanfiles | filename -- | file2list
	mark uiFiles 'here !
|WIN|	"%s//*" sprint
	ffirst ( +file fnext 1? ) drop 0 , 
	empty ;
	
::scandir | "" --
	here 'uiDirs !
	0 'basepath !
	here $ffff + 'stckhdd> ! 
	0 swap scand 0 , 
	here 'uiFiles !
	$ffff + 'here +!
	;
