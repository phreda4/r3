| r3d4 sdl debbuger
| PHREDA 2024
|

^r3/util/sdlgui.r3
^r3/win/sdl2gfx.r3
^r3/win/sdledit.r3

^r3/d4/r3token.r3
^r3/d4/r3vmd.r3

#modo 0

|--------------- SOURCE	
:cursor2ip
	<<ip 0? ( drop ; )
	@ 40 >>> src + 'fuente> ! ;

|--------------- INCLUDES
#liincnt
#liinnow
#liinini
#liinlines 10
#liinscroll
#winsetinc 1 [ 940 0 300 200 ] "INCLUDES"
	
:liinset
	inc> 'inc - 4 >> 'liincnt !
	0 'liinnow !
	0 'liinini !
	liincnt liinlines - 0 max 'liinscroll !
	;
	
:colorlisti
	;
		
:clicklisti
	;
	
:printlinei	
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
	'winsetinc immwin 0? ( drop ; ) drop
	290 18 immbox
	liinlines dup immListBox
	'clicklisti onClick	
	0 ( over over >?  drop
		dup liinini + liincnt <? 
		colorlisti immback printlinei
		1 + ) 2drop	
	listscroll immln ;
	
|	'inc ( inc>  <? 
|		@+ "%w" immLabel
|		@+ "%h" immLabelR
|		immln
|		) drop ;

	
|--------------- DICCIONARY
#lidinow
#lidiini
#lidilines 20
#lidiscroll
#winsetwor 1 [ 940 200 340 390 ] "DICCIONARY"

:lidiset
	0 'lidinow !
	0 'lidiini !
	cntdef lidilines - 0 max 'lidiscroll !
	;
	
:info1 | n --
	|dup "%h " ,print
	dup 1 and ":#" + c@ ,c		| code/data
	dup 1 >> 1 and " e" + c@ ,c	| local/export
	dup 2 >> 1 and " '" + c@ ,c	| /use adress
	dup 3 >> 1 and " >" + c@ ,c	| /R unbalanced
	dup 4 >> 1 and " ;" + c@ ,c	| /many exit
	dup 5 >> 1 and " R" + c@ ,c	| /recursive
	dup 6 >> 1 and " [" + c@ ,c	| /have anon
	dup 7 >> 1 and " ." + c@ ,c	| /not end
|	dup 8 >> $ff and "%h" ,print
	dup 8 >> 1 and " m" + c@ ,c	| /mem access
	dup 9 >> 1 and " A" + c@ ,c	| />A
	dup 10 >> 1 and " a" + c@ ,c	| /A
	dup 11 >> 1 and " B" + c@ ,c	| />B
	dup 12 >> 1 and " b" + c@ ,c	| /B
	" " ,s
	|dup 1 and 3 << 'colpal + @ ex
	|dup $3 and 1 << " ::: ###" + c@+ ,c c@ ,c
	dup 40 >>> src + "%w " ,print
	
	|dup 16 >> $ffffff and pick2 8 + @ 16 >> $ffffff and swap - "%d " ,print
	drop
	;
	
:info2 | n --
	dup ,mov | stack move
|	dup $ff and "%d " ,print		| duse unsigned
|	dup 48 << 56 >> "%d " ,print	| ddelta signed

	dup 16 >> $ffff and "%d " ,print	| calls
	dup 32 >> " %d " ,print			| len
	drop
|	dup @ 16 >> $ffffff and over 16 - @ 16 >> $ffffff and - "%d " ,print
	dup 16 - toklend nip " %d" ,print | len for data
	;
	
:dicword | nro --
	mark	
	4 << dic + 
	|@+ info1
	|@+ info2
	|drop
	@+ 40 >>> src + "%w | " ,print
	@ ,mov 
	
	,eol 
	empty
	here 
	;

:printlinew
	dicword immBLabel immln ;
	
:clicklistw
	sdly cury - boxh / lidiini + 
|	filenow =? ( linenter ; )
| dup set
	'lidinow !
	;
	
:colorlistw | n --
	lidinow =? ( $7f00 ; ) $3a3a3a ;

:listscroll | n --
	lidiscroll 0? ( 2drop ; ) 
	immcur> >r 
	
	boxh rot *
	curx boxw + 2 + | pad?
	cury pick2 -
	rot boxh swap immcur

	0 swap 'lidiini immScrollv 
	r> imm>cur
	;
	
:winwords
	'winsetwor immwin 0? ( drop ; ) drop
	316 18 immbox
	lidilines dup immListBox
	'clicklistw onClick	
	0 ( over over >?  drop
		dup lidiini + cntdef <? 
		colorlistw immback printlinew
		1 + ) 2drop	
	listscroll immln
	;

	
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
		
#winsettok 1 [ 530 0 190 400 ] "TOKENS"
	
:wintokens
	'winsettok immwin 0? ( drop ; ) drop

	<<ip 1? ( 
		dup tok - 3 >>
		10 - clamp0 'initok !
		) drop

	0 ( 20 <?
		initok over + 
		cnttok >=? ( 2drop ; )
		3 << tok + 
		<<ip =? ( 0 immback $ff00 'immcolortex ! )
		dup @ showtok 
		<<ip =? ( "< IP" immLabelR $ffffff 'immcolortex ! )
		drop
		immln
		1 + ) drop ;
		
|--------------- ANALYSIS
#initoka 0

:showtoka | nro
	120 16 immbox
	dup |$ffffff and 
	"%h" immLabel imm>>
	180 16 immbox
	dup $ff and
	1 =? ( drop 24 << 32 >> "%d" immLabel ; )				| lit
|	6 =? ( drop 8 >> $ffffff and strm + mark 34 ,c ,s 34 ,c ,eol empty here immLabel ; ) 	| str
	drop
	40 >> src + "%w" immLabel
	;
		
#winsettoka 1 [ 600 0 300 400 ] "ANALYSIS"
	
:wintokensa
	'winsettoka immwin 0? ( drop ; ) drop

	0 ( 20 <?
		initoka over + 
		cnttok >=? ( 2drop ; )
		3 << tok + @ showtoka 
		immln
		1 + ) drop ;		
	
	
|-----------------------------	
|-----------------------------	
:modo! | n --
	'modo !	;
		
:errormode
	3 'edmode ! | no edit src
|	lerror 'ederror !
	;
	
:play
	empty
	fuente 'edfilename r3loadmem
	mark
	error 1? ( drop errormode ; ) drop
	
	4 'edmode ! | no edit src
	1 modo! 
	lidiset
	liinset
	resetvm
	cursor2ip
	;		
		
|---------------- MENU
#winsetcon 1 [ 8 516 700 200 ] "R3d4"

:dstack	
	mark
	"D:" ,s
	'PSP 8 + ( NOS <=? @+ "%d " ,print ) drop
	'PSP NOS <=? ( TOS "%d " ,print ) drop 
	,eol
	empty
	here immLabel
	; 

:rstack	
	mark
	"R:" ,s
	'RSP 8 + ( RTOS <=? @+ "%h " ,print 	) drop 
	,eol
	empty
	here immLabel
	; 
	
#pad * 512	

:winconsole	
	'winsetcon immwin 0? ( drop ; ) drop
	80 20 immbox
	$7f 'immcolorbtn !
	'play "PLAY" immbtn imm>>
	$7f0000 'immcolorbtn !
	'exit "EXIT" immbtn  imm>> | winclose
	<<ip |tok - 3 >> 
	"IP:%h" immLabel
	immln
	790 20 immbox
	regb rega "A:%h B:%h" immLabel immln
	
	dstack immln
	rstack immln
|	'pad 256 immInputLine
	;
	

|---------------- TOOLBAR
:keysrc
	SDLkey
	>esc< =? ( exit  )
	<f1> =? ( play )
	drop 
	;
	
:keydbg
	SDLkey
	>esc< =? ( 0 modo! 0 'edmode ! )
	<f1> =? ( stepvm cursor2ip )
	<f2> =? ( stepvmn cursor2ip )
	drop 
	;
	
#keyb 'keysrc 'keydbg
	
:keyboard
	modo 3 << 'keyb + @ ex ;

|-----------------------------	
:main
	0 SDLcls immgui 
	edshow	

	winconsole
	modo 1? (
		|wininclude
		winwords
		wintokens
		wintokensa
		) drop
	
	keyboard
	SDLredraw
	;

|-----------------------------
|-----------------------------
|-----------------------------	
:	
	"R3d4" 1280 720 SDLinit
	
	"media/ttf/Roboto-Medium.ttf" 16 TTF_OpenFont 
	dup ttfont immSDL
	
	bfont1
	0 0 90 30 edwin
	edram 
|	'filename "mem/main.mem" load drop
|	"r3/demo/textxor.r3" 
	"r3/democ/palindrome.r3" 
|	"r3/test/testasm.r3"
	edload
	mark |  for redoing tokens
	'main SDLshow

	SDLquit 
	;
