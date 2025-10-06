^./console.r3
^./utfg.r3

#.exit 0 
::exit 1 '.exit ! ;

#vecdraw

#flag

#id		| id 
#idn	| id now 
#idf	| id foco

#wid
#widn

#keyin
#info "ok" * 256

::.tdebug
	widn idf idn "id:%d idf:%d wid:%d " .print
	keyin ">>%h<<" .print
	'info .write
	;
	
::inwin? | -- 1.2.3/0 ; dn-hold-up
	1 'id +! 
	evtmb 0? ( 
		id idn <>? ( drop ; ) drop
		-1 'idn !
		drop 3 ; ) drop | up
	evtmxy .inwin? 0? ( ; ) drop
	id idn =? ( drop 2 ; ) | move
	'idn ! 1 ; | dn

:hkey
	evtkey
	[esc] =? ( exit ) 
	|[tab] =? ( 1 'widn +! ) | cambia id y luego wid
|	[f1] =? ( run ) 
	'keyin ! ;
	
:hmouse
	evtmb 
	1? ( evtmxy .at "." .fwrite ) 
	drop
	;
	
:tredraw
	.hidec
	vecdraw ex 
	flag
	1 and? ( .ovec .restorec .showc )
	drop
	.flush ;
	
::onTui | 'vector --
	dup .onresize
	dup ex
	'vecdraw !
	( .exit 0? drop
		0 'keyin !
		inevt	
		1 =? ( hkey )
|		2 =? ( hmouse )
|		1? ( )
		drop
		tredraw		
		10 ms
		) drop ;

::tui
	0 'flag !
	idn id >? ( 0 'idn ! ) drop
|	idf id >? ( 0 'idf ! ) drop
	-1 'id !
	widn wid >? ( 0 'widn ! ) drop
	0 'wid ! ;
	
::tuWin | x y w h --
	.win
	wid widn =? ( .wborde ) 1+ 'wid !
	;
	
::tuBtn | 'ev "" --
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
	modo 'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;

:kbInputLine | --
	keyin 0? ( drop ; )	
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
	
::tuInputLine | 'buff max --
	inwin?
	1 =? ( >r inInput r> id 'idf ! ) | in
|	2 =? ( ) | hold
|	3 =? ( ) | up
	2drop
	id idf =? ( 
		kbInputLine 
		.wat@ swap 
		pad> padi> - + | !! falta utf
		swap .at .savec | cursor
		1 'flag !		
		) drop
	.wtext
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

#overl
:ilist | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( .rever )
|	overl =? ( overfil uiFill )
	uiNindx .wtext .reset ;

::tuList | 'var cntlines list --
	inwin? 1? ( id 'idn ! wid 1- 'widn ! ) drop
	mark makeindx
	0 ( over <? ilist 1+ ) drop
|	cscroll
	2drop
	empty 
	1 'id +! ;	
	
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

#fold "▸" "▾"
:,iicon | n -- 
	$20 nand? ( drop 32 ,c ; )
	7 >> 1 and 2 << 'fold + ,s ; 
	
:itree | 'var max n  -- 'var max n
	pick2 8 + @ over +
	pick3 @ =? ( .rever )
|	overl =? ( overfil uiFill )
	uiNindx c@+ 0? ( 2drop ; )
	dup $1f and 2* .wmargin
	mark ,iicon ,s ,eol empty
	here .wtext .reset ;
	
::tuTree | 'var cntlines list --
	inwin? 1? ( id 'idn ! wid 1- 'widn ! ) drop
	mark maketree
|	cntlist over - clamp0 pick2 8 + @ <? ( dup pick3 8 + ! ) drop
|	chtree
	0 ( over <? itree 1+ ) drop
|	cscroll
	2drop
	empty 
	1 'id +! ;	

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
