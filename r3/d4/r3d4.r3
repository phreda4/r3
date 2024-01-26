| r3d4 sdl debbuger
| PHREDA 2024
|

^r3/util/sdlgui.r3
^r3/win/sdl2gfx.r3
^r3/win/sdledit.r3

^r3/d4/r3edit.r3
^r3/d4/r3token.r3
^r3/d4/r3vmd.r3

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
	,mov 
|	dup $ff and "%d " ,print		| duse unsigned
|	dup 48 << 56 >> "%d " ,print	| ddelta signed
	
	dup 16 >> $ffff and "%d " ,print	| calls
	9 ,c
	dup 32 >> " %d " ,print			| len
	drop
|	dup @ 16 >> $ffffff and over 16 - @ 16 >> $ffffff and - "%d " ,print
	dup 16 - toklend nip " %d" ,print | len for data
	;
	
:dicword | nro --
	mark	
	dup "%d." ,print
	4 << dic + 
	@+ info1
	@+ info2
	drop
	,eol 
	empty
	here ttprint
	;
	
:viewDicc
	$ff00 ttcolor
	0 ( 20 <?
		680 over 5 << immat
		dup inidic + 
		dup "%d" ttprint
		cntdef >=? ( 2drop ; )
		drop
		1 + ) drop ;
		
|-----------------------------
:menu
	$ffffff sdlcolor
	80 20 immbox
	680 16 immat
	"DEBUG" immlabelc immdn
	'exit "Exit" immbtn 
	;

:nivel0
	immgui 	
	0 SDLcls

	viewDicc
	menu
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;

|-----------------------------	
:play
|	'filename "mem/main.mem" load drop
|	"r3/demo/textxor.r3" 
|	"r3/democ/palindrome.r3" 
	"r3/test/testasm.r3"
	r3load
	src code-set
	
	resetvm
	|cursor2ip  
	'nivel0 SDLshow
	;

|-----------------------------
:menu
	$ffffff sdlcolor
	80 20 immbox
	680 16 immat
	"EDIT" immlabelc		immdn
	'play "Play" immbtn 	immdn
	'exit "Exit" immbtn 
	;
	
|-----------------------------	
:main
	immgui 
	0 SDLcls
	edshow	
	menu
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( play )
	drop ;

|-----------------------------
|-----------------------------
|-----------------------------	
:	
	"R3d4" 1280 720 SDLinit
	
	"media/ttf/zx-spectrum.ttf" 16 TTF_OpenFont 
	dup ttfont immSDL
	
	bfont1
	1 1 80 35 edwin
	edram "r3/d4/r3d4.r3" edload
	
	'main SDLshow

	SDLquit 
	;
