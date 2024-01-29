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
:includes	

	;
	
|--------------- DICCIONARY
#inidic 0

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
	@+ 40 >>> src + "%w (" ,print
	@ ,mov ")" ,print
	
	,eol 
	empty
	here bprint
	;
	
:dicctionary
	cntdef 0? ( drop ; ) drop
	$545454 sdlcolor
	81 4 30 35 bfillline
	
	$0000 bcolor
	0 ( 20 <?
		81 over 4 + gotoxy
		dup inidic + 
		cntdef >=? ( 2drop ; )
		dicword
		1 + ) drop ;
		
|---------------- MENU
#ltit "- EDIT -" "- DEBUG -" 
#tit 'ltit

:menu
	$ffffff ttcolor
	0 0 ttat
	" R3d4 " ttprint
	$ff00 ttcolor
	tit ttprint	
|	$aaaaaa ttcolor
|	'edfilename " %s" ttprint
	;
	
:modo! | n --
	'ltit over n>>0 'tit ! 
	'modo !
	;
	
|--------------- TOKENS
#initok 0

:showtok | nro
	dup "%h. " bprint
	dup $ff and
	1 =? ( drop 24 << 32 >> " %d" bprint ; )				| lit
	6 =? ( drop 8 >> $ffffff and strm + 34 bemit bemits 34 bemit ; ) 	| str
	drop
	40 >> src + "%w " bprint ;
	
:tokens
	cntdef 0? ( drop ; ) drop
	$545454 sdlcolor
	121 4 30 35 bfillline
	
	<<ip 1? ( 
		dup 3 >> tok -
		10 - clamp0 'initok !
		) drop
		
	$7f bcolor
	0 ( 30 <?
		121 over 4 + gotoxy
		dup initok + 
		cnttok >=? ( 2drop ; )
		3 << tok + 
		<<ip =? ( $ff00 bcolor ) | save cursor position 
		dup @ showtok 
		<<ip =? ( $7f bcolor " <IP" bemits ) | save cursor position 
		drop
		1 + ) drop ;
	
		
|-----------------------------	
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
	resetvm
	cursor2ip
	;


|---------------- TOOLBAR
:toolbar
	;

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
	
:ttstack	
	'PSP 8 + ( NOS <=? @+ "%d " ttprint ) drop
	'PSP NOS <=? ( TOS "%d " ttprint ) drop ; 

|-----------------------------	
:main
	immgui 
	0 SDLcls
	edshow	
	modo 1? (
		dicctionary
		tokens
		) drop
	menu
	toolbar
	
	$ffffff ttcolor
	8 640 ttat 
	<<ip 3 >> tok - "IP:%h | " ttprint
	regb rega "A:%h B:%h " ttprint
	8 660 ttat ttstack 
	
	SDLredraw
	keyboard
	;

|-----------------------------
|-----------------------------
|-----------------------------	
:	
	"R3d4" 1280 720 SDLinit
	
	"media/ttf/Roboto-Medium.ttf" 20 TTF_OpenFont 
	dup ttfont immSDL
	
	bfont1
	1 4 80 36 edwin
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
