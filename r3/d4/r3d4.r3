| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/sdl2gfx.r3

^r3/util/sdlbgui.r3
^r3/util/sdledit.r3

^r3/d4/r3token.r3
^r3/d4/r3vmd.r3
^r3/d4/r3opt.r3

#modo 0
#panel 0

|--------------- SOURCE	
:cursor2ip
	<<ip 0? ( drop ; )
	@ 40 >>> src + 'fuente> ! ;

:codename | adr' info1 -- str
	$2 and? ( $3a ,c ) $3a ,c 
	40 >>> src + "%w | " ,print
	@ ,mov |,movd
	,eol empty here ;
	
:dataname | adr' info1 -- str
	$2 and? ( $23 ,c ) $23 ,c 
	40 >>> src + "%w" ,print
	drop
	,eol empty here ;
	
:nameword | dicadr -- str
	mark @+ 1 and? ( dataname ; ) codename ;
		
|--------------- ANALYSIS
#anaword
#initoka 0
#cnttoka 0


#winsettoka 1 [ 600 0 360 500 ] "ANALYSIS"

:infoword | adr -- str
	mark
	@+
	|dup "%h " ,print
	dup 1 and ":#" + c@ ,c		| code/data
	dup 1 >> 1 and " e" + c@ ,c	| local/export
	dup 2 >> 1 and " '" + c@ ,c	| /use adress
	dup 3 >> 1 and " >" + c@ ,c	| /R unbalanced
	dup 4 >> 1 and " ;" + c@ ,c	| /many exit
	dup 5 >> 1 and " R" + c@ ,c	| /recursive
	dup 6 >> 1 and " [" + c@ ,c	| /have anon
	dup 7 >> 1 and " ." + c@ ,c	| /not end
	dup 8 >> 1 and " m" + c@ ,c	| /mem access
	dup 9 >> 1 and " A" + c@ ,c	| />A
	dup 10 >> 1 and " a" + c@ ,c	| /A
	dup 11 >> 1 and " B" + c@ ,c	| />B
	dup 12 >> 1 and " b" + c@ ,c	| /B
	drop
	@
	dup 16 >> $ffff and " call:%d" ,print	| calls
	dup 32 >> " len:%d" ,print			| len
	drop
	,eol empty here 
	;


:showtoka | nro --
	dup $ff and 6 =? ( 2drop """str""" immLabel ; ) drop
	tokenstr
	immLabel ;
	
:dbgfocus
	600 0 immwinxy

	anaword 4 << dic + dup
	nameword immLabel immln
	infoword immlabel immln
	immln
|	immln
	0 ( 20 <?
		initoka over + 
		cnttoka >=? ( 2drop ; )
		3 << 'tokana + @ showtoka 
		immln
		1 + ) drop ;		
	
|--------------- DICCIONARY
#lidinow
#lidiini
#lidilines 20
#lidiscroll
#winsetwor 1 [ 940 200 340 390 ] "DICCIONARY"

:lidiset
	0 'lidinow !
	0 'lidiini !
	cntdef lidilines - 0 max 
	'lidiscroll !
	;
	
:dicword | nro --
	4 << dic + nameword ;

:printlinew
	cntdef >=? ( drop immln ; )
	dicword immBLabel immln ;
	
:clicklistw
	sdly cury - boxh / lidiini + 
|	filenow =? ( linenter ; )
	dup 'lidinow !
	dup 'anaword !
	wordanalysis
	tokana> 'tokana - 3 >> 'cnttoka !
	;
	
:colorlistw | n -- n c
	lidinow =? ( $7f00 ; ) $3a3a3a ;

:listscroll | n --
	lidiscroll 0? ( 2drop ; ) 
	immcur> >r 
	
	boxh rot *
	curx boxw + 2 + | pad?
	cury pick2 -
	rot boxh swap immcur

	0 swap 
	'lidiini immScrollv 
	r> imm>cur
	;
	
:wordfocus
	940 200 immwinxy
	316 18 immbox
	lidilines dup immListBox
	'clicklistw onClick	
	0 ( over over >?  drop
		dup lidiini + |cntdef <? 
		colorlistw immback printlinew
		1 + ) 2drop	
	listscroll immln
	
	;

:listwdraw
	;
	
|--------------- INCLUDES
#liincnt
#liinnow
#liinini
#liinlines 8
#liinscroll
#winsetinc 1 [ 940 0 300 176 ] "INCLUDES"
	
:liinset
	inc> 'inc - 4 >> 'liincnt !
	0 'liinnow !
	0 'liinini !
	liincnt liinlines - 0 max 'liinscroll !
	;
	
:incset | nroinc --
	dup 'liinnow !
	4 << 'inc + 8 + @
	32 >> dup 'lidiini ! 'lidinow !	;
	
:colorlisti
	liinnow =? ( $7f00 ; ) $3a3a3a ;
		
:clicklisti
	sdly cury - boxh / liinini + incset ;
	
:printlinei	
	liincnt >=? ( drop immln ; ) 
	4 << 'inc + @ "%w" immBLabel immln ;
	
:listscroll | n --
	liinscroll 0? ( 2drop ; ) 
	immcur> >r 
	
	boxh rot *
	curx boxw + 2 + | pad?
	cury pick2 -
	rot boxh swap immcur

	0 swap 'liinini immScrollv 
	r> imm>cur
	;	
	
:wininclude
	|'winsetinc immwin 0? ( drop ; ) drop
	940 0 immwinxy
	290 18 immbox
	liinlines dup immListBox
	'clicklisti onClick	
	0 ( over over >? drop
		dup liinini + |liincnt <? 
		colorlisti immback 
		printlinei
		1 + ) 2drop	
	listscroll immln ;
	
|--------------- TOKENS
#initok 0

:showtok | nro
|	40 16 immbox
|	dup $ffffff and 
|	"%h" immLabel imm>>
	180 16 immbox
	dup $ff and
	1 =? ( drop 24 << 32 >> "%d" immLabel ; )				| lit
|	6 =? ( drop 8 >> $ffffff and strm + mark 34 ,c ,s 34 ,c ,eol empty here immLabel ; ) 	| str
	drop
	40 >> src + "%w" immLabel
	;
		
|#winsettok 1 [ 500 440 190 270 ] "TOKENS"
	
:wintokens
	500 440 immwinxy
	
	<<ip 1? ( 
		dup tok - 3 >>
		7 - clamp0 'initok !
		) drop

	0 ( 14 <?
		initok over + 
		cnttok >=? ( 2drop ; )
		3 << tok + 
		<<ip =? ( 0 immback $ff00 'immcolortex ! )
		dup @ showtok 
		<<ip =? ( "< IP" immLabelR $ffffff 'immcolortex ! )
		drop
		immln
		1 + ) drop ;

|-----------------------------	
|-----------------------------	
:modo! | n --
	'modo !	;
		
:errormode
|	3 'edmode ! | no edit src
|	lerror 'ederror !
	;
	
:play
	empty mark
	fuente 'edfilename r3loadmem
	error 1? ( drop errormode ; ) drop
|	4 'edmode ! | no edit src
	1 modo! 
	lidiset
	liinset
	inc> 'inc - 4 >> 1 - incset
	$ffff 'here +!
	resetvm
	cursor2ip
	
	mark
	'filename ,s ,cr ,cr
	debugmemmap
	"r3/d4/gen/map.txt" savemem
	empty
	;		
		
|---------------- CONSOLE
:dstack	
	mark
	"D:" ,s
	'PSP 8 + ( NOS <=? @+ "%d " ,print ) drop
	'PSP NOS <=? ( TOS "%d " ,print ) drop 
	,eol
	empty
	here bprint bcr
	; 

:rstack	
	mark
	"R:" ,s
	'RSP 8 + ( RTOS <=? @+ "%h " ,print 	) drop 
	,eol
	empty
	here bprint bcr
	; 

#pad * 512	
	
#cmax
#padi>	| inicio
#pad>	| cursor
#padf>	| fin
#cmodo

:lins  | c -- ;
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1 - padf> over - 1 + cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> >? (
		dup padi> - cmax >=? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
:0lin 0 padf> c! ;
:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> padi> <=? ( drop ; ) dup 1 - swap padf> over - 1 + cmove -1 'padf> +! -1 'pad> +! ;
:kder pad> padf> <? ( 1 + ) 'pad> ! ;
:kizq pad> padi> >? ( 1 - ) 'pad> ! ;
	
:chmode
	cmodo 'lins =? ( drop 'lover 'cmodo ! ; )
	drop 'lins 'cmodo ! ;	
	
:cursor
	msec $100 and? ( drop ; ) drop
	cmodo 'lins =? ( drop pad> padi> - bcursori2 ; ) drop
	pad> padi> - bcursor2
	;	

#xcon 1 
#ycon 3
#wcon 40 
#hcon 

:conreset
	511 'cmax !
	'pad dup 'padi> !
	( c@+ 1? drop ) drop 1 -
	dup 'pad> ! 'padf> !
	'lins 'cmodo !	
	;
	
:conwin
	'hcon ! 'wcon ! 'ycon ! 'xcon ! ;
	
:consoledraw
	$ffffff bcolor
	xcon ycon gotoxy

	">" bprint2 
	panel 1 =? ( cursor ) drop
	'pad bprint2 
	bcr bcr
	
	<<ip |tok - 3 >> 
	regb rega "IP:%h A:%h B:%h" bprint bcr
	dstack 
|	rstack 
	;
	
:conexec
	0 'pad ! conreset
	;
	
:confocus
	xcon ycon wcon hcon bsrcsize 
	$ffffff sdlcolor
	2over 2over sdlRect 
	guiBox
	SDLchar 1? ( cmodo ex ; ) drop
	sdlkey
	<ret> =? ( conexec )
	<ins> =? ( chmode )
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )	
	drop
	;

|-----------------------------

#focuslist 'edfocus 'confocus 'wordfocus 'dbgfocus

#pad2 * 1024

:main
	0 SDLcls 
	immgui 
	edfill
	panel 3 << 'focuslist + @ ex
	edcodedraw
	consoledraw
	listwdraw
	
|	70 10 gotoxy
|	'pad2 >a
|	inisel 1? ( ( finsel <=? c@+ ca!+ ) ) drop
|	0 ca!+
|	'pad2 bprint2
	
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( panel 1+ $3 and 'panel ! ) 
	<f2> =? ( play ) 
	drop
	;

#colsrc
#rowsrc
:layout
	sw wp / 'colsrc !
	sh hp / 'rowsrc !
	
	0 2 65 30 edwin
	0 32 65 rowsrc 32 - conwin
	conreset
	;
	
|-----------------------------
|-----------------------------
|-----------------------------	
:	
	"R3d4" 1280 720 SDLinit
	bfont1
	edram 
	
|	'filename "mem/main.mem" load drop
|	"r3/test/testasm.r3"
	"r3/opengl/16-iqmloader.r3" 
	'filename strcpy
	
	'filename edload
	deferwi | for opt
	mark |  for redoing tokens
	
	layout
	'main SDLshow
	SDLquit 
	;
