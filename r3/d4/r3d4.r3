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

:codename | adr' info1 -- str
	$2 and? ( $3a ,c ) $3a ,c 
	40 >>> src + "%w | " ,print
	@ ,mov 
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
#cnttoka 10

#biglit * 160 | 20 bigliteral
#biglit>
#tokana * $ffff | 8192 tokens
#tokana>

|-------------------------------- PRINT
|  0     1    2     3     4    5     6
| .lits .lit .word .wadr .var .vadr .str ...
:.lits 
	8 >> 'biglit + @ "$%h" sprint ;
:.lit 
	8 >> "$%h" sprint ; | literal in opt is bigger

:.name
	8 >> $ffffffff and 4 << dic + @ dic>name ;
	
:.word 
	.name "%w" sprint ;
:.wadr 
	.name "'%w" sprint ;
:.var 
	.name "%w" sprint ;
:.vadr 
	.name "'%w" sprint ;
:.str 
	"%h" sprint ;
	
#bmacro .lits .lit .word .wadr .var .vadr .str 

:tokenstr | tok -- str
	dup $ff and 
	6 >? ( 7 - basename nip ; )
	3 << 'bmacro + @ ex ;

|--------------------------------	

:reseta	
	'tokana 'tokana> ! 
	'biglit 'biglit> ! ;
:,t		
	tokana> !+ 'tokana> !  ;

:,nlit | nro --
	dup 8 << 8 >> =? ( 8 << 1 or ,t ; ) drop | fit in 56bits
	biglit> !+ 'biglit> !
	biglit> 'biglit - 8 << ,t | big nro  0 in token
	;
		
:,lit | token --
	40 >> src + str>anro nip | get the number
	,nlit ;
	
:1lit?	
	tokana> 8 - 'tokana <? ( drop 0 ; ) 
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
:2lit?	
	tokana> 16 - 'tokana <? ( drop 0 ; ) 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
:3lit?	
	tokana> 24 - 'tokana <? ( drop 0 ; ) 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 
	@+ $ff and 1 >? ( 2drop 0 ; ) drop 	
	@ $ff and 1 >? ( drop 0 ; ) drop 1 ;
:nlit? | n -- n 0/1
	tokana> over 3 << - 'tokana <? ( drop 0 ; ) | n tok
	over ( 1? 1 - swap							| n n tok
		@+ $ff and 1 >? ( 3drop 0 ; ) drop		| n n tok 
		swap ) 2drop 1 ; 						| n 1

:litpush | tok --
	dup $ff and 1? ( drop 8 >> 
|		dup ">>%d<< " .print
		NPUSH ; ) drop
	8 >> 'biglit + @ NPUSH ;
	
:1litpush
	tokana> 8 - dup 'tokana> !
	@ litpush ;	
:2litpush
	tokana> 16 - dup 'tokana> !
	@+ litpush @ litpush ;
:3litpush
	tokana> 24 - dup 'tokana> !
	@+ litpush @+ litpush @ litpush ;
	
:nlitpush | n --
	tokana> over 3 << - dup 'tokana> !
	swap ( 1? 1 - swap
		@+ litpush swap ) 2drop ;

:,TOSLIT | -- ; TOS to tokana>
	TOS ,nlit .drop ;
:,2TOSLIT | --
	NOS 8 - @ ,nlit TOS ,nlit .2drop ;
:,ntoslit | n --
	0? ( drop ; ) 1 -
	NOS over 3 << - over | n NOS n
	( 1? 1 - swap @+ ,nlit swap ) 2drop
	TOS ,nlit
	( .drop 1? 1 - ) drop ;
	
:dic@	
	8 >> $ffffffff and 4 << dic + @ ;
:dic@v	
	8 >> $ffffffff and 4 << dic + 8 + @ 32 >>> fmem + @ ;
:dic@use | tok -- usestack
	8 >> $ffffffff and 4 << dic + 8 + @ $ff and ;
:dic@load | tok -- loadstack
	8 >> $ffffffff and 4 << dic + 8 + @ 
	dup $ff and swap 48 << 56 >> + ;
	
:,inlinecode | ; inline code ?
	,t ;
	
:,code
	dup dic@ $100 and? ( 2drop ,inlinecode ; ) drop	| no pure code -> normal tokenizer
	dup dic@use										| tok stack use
	nlit? 0? ( 2drop ,inlinecode ; ) drop			| all are literal?
	2dup "%d %h." .println
	nlitpush		| push the numbers in virtual stack
	dup "%h<<" .println
	dup exncode		| exec code in compile time
	dup "%h<<" .println
	2dup "%d %h.." .println
	dic@load
	2dup "%d %h.." .println
	.input
	,ntoslit		| pop the numbers to code
	;
	
:,data
	dup dic@ $4 and? ( drop ,t ; ) drop | real var
	dic@v ,nlit		| detect cte var
	;
	

:,AND
	2lit? 1? ( 2drop 2litpush .AND ,TOSLIT ; ) drop
	,t ;
:,OR
	2lit? 1? ( 2drop 2litpush .OR ,TOSLIT ; ) drop
	,t ;
:,XOR
	2lit? 1? ( 2drop 2litpush .XOR ,TOSLIT ; ) drop 
	,t ;
:,+
	2lit? 1? ( 2drop 2litpush .+ ,TOSLIT ; ) drop 
	,t ;
:,- 
	2lit? 1? ( 2drop 2litpush .- ,TOSLIT ; ) drop 
	,t ;
:,* 
	2lit? 1? ( 2drop 2litpush .* ,TOSLIT ; ) drop 
	,t ;
:,/ 
	2lit? 1? ( 2drop 2litpush ./ ,TOSLIT ; ) drop 
	,t ;
:,<< 
	2lit? 1? ( 2drop 2litpush .<< ,TOSLIT ; ) drop 
	,t ;
:,>> 
	2lit? 1? ( 2drop 2litpush .>> ,TOSLIT ; ) drop 
	,t ;
:,>>>	
	2lit? 1? ( 2drop 2litpush .>>> ,TOSLIT ; ) drop 
	,t ;
:,mod
	2lit? 1? ( 2drop 2litpush .mod ,TOSLIT ; ) drop 
	,t ;
:,/mod
	2lit? 1? ( 2drop 2litpush ./mod ,2TOSLIT ; ) drop
	,t ;
:,*/
	3lit? 1? ( 2drop 3litpush .*/ ,TOSLIT ; ) drop
|	2lit? 1? ( ) drop
	,t ;
:,*>> 
	3lit? 1? ( 2drop 3litpush .*>> ,TOSLIT ; ) drop
|	2lit? 1? ( ) drop	
	,t ;
:,<</
	3lit? 1? ( 2drop 3litpush .<</ ,TOSLIT ; ) drop
|	2lit? 1? ( ) drop	
	,t ;
:,NOT 
	1lit? 1? ( 2drop 1litpush .not ,TOSLIT ; ) drop 
	,t ;
:,NEG 
	1lit? 1? ( 2drop 1litpush .neg ,TOSLIT ; ) drop 
	,t ;
:,ABS 
	1lit? 1? ( 2drop 1litpush .abs ,TOSLIT ; ) drop 
	,t ;
:,SQRT 
	1lit? 1? ( 2drop 1litpush .sqrt ,TOSLIT ; ) drop 
	,t ;
:,CLZ 
	1lit? 1? ( 2drop 1litpush .clz ,TOSLIT ; ) drop 
	,t ;

	
#optw
,LIT ,LIT ,CODE ,t ,DATA ,t ,t 	|.lit .lit .code .acode .data .adata .str
,t ,t ,t ,t ,t 				|.; .( .) .[ .] 
,t ,t ,t ,t ,t 				|.EX .0? .1? .+? .-? 
,t ,t ,t ,t ,t ,t ,t ,t ,t 	|.<? .>? .=? .>=? .<=? .<>? .A? .N? .B? 
,t ,t ,t ,t ,t ,t ,t ,t 	|.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP 
,t ,t ,t ,t ,t ,t ,t 		|.ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP 
,t ,t ,t 					|.>R .R> .R@ 
,AND ,OR ,XOR ,+ ,- ,* ,/ ,<< ,>> ,>>>
,MOD ,/MOD ,*/ ,*>> ,<</ 			
,NOT ,NEG ,ABS ,SQRT ,CLZ 
,t ,t ,t ,t 				|.@ .C@ .W@ .D@ 
,t ,t ,t ,t 				|.@+ .C@+ .W@+ .D@+ 
,t ,t ,t ,t 				|.! .C! .W! .D! 
,t ,t ,t ,t 				|.!+ .C!+ .W!+ .D!+ 
,t ,t ,t ,t 				|.+! .C+! .W+! .D+! 
,t ,t ,t ,t ,t ,t ,t 		|.>A .A> .A+ .A@ .A! .A@+ .A!+ 
,t ,t ,t ,t |.cA@ .cA! .cA@+ .cA!+ 
,t ,t ,t ,t |.dA@ .dA! .dA@+ .dA!+ 
,t ,t ,t ,t ,t ,t ,t |.>B .B> .B+ .B@ .B! .B@+ .B!+ 
,t ,t ,t ,t |.cB@ .cB! .cB@+ .cB!+ 
,t ,t ,t ,t |.dB@ .dB! .dB@+ .dB!+ 
,t ,t ,t |.MOVE .MOVE> .FILL 
,t ,t ,t |.CMOVE .CMOVE> .CFILL 
,t ,t ,t |.DMOVE .DMOVE> .DFILL 
,t 				|.MEM
,t ,t 				|.LOADLIB .GETPROC
,t ,t ,t ,t ,t ,t 	| .SYS0 .SYS1 .SYS2 .SYS3 .SYS4 .SYS5
,t ,t ,t ,t ,t 		|.SYS6 .SYS7 .SYS8 .SYS9 .SYS10 
0	
	
:,ana | nro --
	dup $ff and 3 << 'optw + @ ex ;
	
|--------------
:dataw
	toklend		| dc tok len
	( 1? 1 - swap
		@+ ,ana
		swap ) 2drop 
	tokana> 'tokana - 3 >> 'cnttoka !		
	;
	
:codew
	toklen 
	( 1? 1 - swap
		@+ ,ana
		swap ) 2drop 
	tokana> 'tokana - 3 >> 'cnttoka !
	;
	

:wordanalysis | nro --
	reseta
	dup 'anaword !
	4 << dic + 
	dup @ 1 and? ( drop dataw ; ) drop
	codew ;


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


:showtoka | nro
	tokenstr
|	"%h" 
	immLabel ;
	
:wintokensa
	'winsettoka immwin 0? ( drop ; ) drop

	anaword 4 << dic + dup
	nameword immLabel immln
	infoword immlabel immln
	immln
|	immln
	0 ( 15 <?
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
	wordanalysis
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

	0 swap 
	'lidiini immScrollv 
	r> imm>cur
	;
	
:winwords
	'winsetwor immwin 0? ( drop ; ) drop
	316 18 immbox
	lidilines dup immListBox
	'clicklistw onClick	
	0 ( over over >?  drop
		dup lidiini + |cntdef <? 
		colorlistw immback printlinew
		1 + ) 2drop	
	listscroll immln
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
	'winsetinc immwin 0? ( drop ; ) drop
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
		
#winsettok 1 [ 500 440 190 270 ] "TOKENS"
	
:wintokens
	'winsettok immwin 0? ( drop ; ) drop

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
	3 'edmode ! | no edit src
|	lerror 'ederror !
	;
	
:play
	empty mark
	fuente 'edfilename r3loadmem
	error 1? ( drop errormode ; ) drop
	4 'edmode ! | no edit src
	1 modo! 
	lidiset
	liinset
	inc> 'inc - 4 >> 1 - incset
	$ffff 'here +!
	reseta
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
		wininclude
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
|	"r3/democ/palindrome.r3" 
	"r3/test/testasm.r3"
	edload
	mark |  for redoing tokens
	'main SDLshow

	SDLquit 
	;
