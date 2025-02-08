| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^./tedit.r3
^./arena-map.r3
^./rcodevm.r3

#script
#script>
#scrstate

:dialogo
	;
	
:loadlevel | "" --
|	"loading tutor..." plog
	here dup 'script ! dup 'script> !
	swap load 
	0 swap c!+ 'here ! 
	0 'scrstate	!
	;

:addline
	script> dup >>cr 0 swap c!
	dup >>0 trim 'script> ! 
|	"*w" =pre 1? ( ) 
|	plog
drop
	;
	
:runscript
	scrstate
	drop
	;

|------------	
#font
#cpu
#state

|----- code
#cdtok * 1024
#cdtok> 'cdtok
#cdnow>
#cdcnt

#lev
#cdspeed 0.2

:linecode | adr -- adr
	cdnow> =? ( ">" temits )
	@+ dup 8 >> $ff and 'lev !
	vmtokstr temits tsp ;
	
:showcode
	2 64 tat
	'cdtok
	0 ( cdcnt <? swap 
		linecode
		swap 1+ ) 
	2drop  ;

:processlevel	
|	cdcnt 'cdtok vmcheckcode 
	cdcnt 'cdtok vmcheckjmp
	;

:stepvm
	cdnow> 0? ( drop ; ) 
	|vmstepck 
	vmstep
	1? ( dup vm2src 'fuente> ! )
	'cdnow> !
	;
	
:stepvma
	cdnow> 0? ( drop ; ) 
	vmstepck 
	|vmstep
	terror 1 >? ( 2drop 
		2 'state ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop
	
	1? ( dup vm2src 'fuente> ! 'stepvma cdspeed +vexe )
	0? ( dup 'state ! ) 
	'cdnow> !
	;
	
|-----------------------
:showeditor
	$007f00 sdlcolor 4 190 330 32 SDLFrect
	$ffffff trgb 1 6 txy "CODE: EDIT" tprint
	$7f00007f sdlcolorA	edfill
	edfocus
	edcodedraw
	| Help en MARK
	|showmark
	;	
	
:showruning
	$007f7f sdlcolor 4 190 330 32 SDLFrect
	$ffffff trgb 1 6 txy "CODE: RUN" tprint

	$7f00007f sdlcolorA	edfill
	
	clearmark
	fuente> $00fffff addsrcmark
	RTOS ( @+ 1?
		8 - @ vmcode2src $00f0000 addsrcmark
		) 2drop
	showmark
	
	edcodedraw
	;	

:showerror
	$7f0000 sdlcolor 4 190 330 32 SDLFrect
	$ffffff trgb 1 6 txy "CODE: " tprint vmerror tprint
	$7f00007f sdlcolorA	edfill
	$7f0000 sdlcolor

	showmark
	
	edfocus
	edcodedraw
	;
	
|-----------------------
:editcompilar
	clearmark

	vmtokreset
	fuente 'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	cdtok> 'cdtok - 3 >> 'cdcnt !
	
|	vmdicc | ** DEBUG
|processlevel
	terror 1 >? ( drop 
		2 'state ! 
		serror 'fuente> ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop

	1 'state ! 
	vmboot 
	1? ( dup vm2src 'fuente> ! )
	dup vm2src 'fuente> ! 
	'cdnow> !
	'stepvma cdspeed +vexe
	;

:showstack
	8 532 tat
	" " tprint
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ vmcell temits tsp
		) 2drop 
	TOS vmcell temits tsp
	;
	
	
:draw.code
|	showcode
	
	
	state 
	0? ( showeditor )
	1 =? ( showruning )
	2 =? ( showerror ) 
	drop
	
	showstack
	;
	
#textitle

|-------------------
:runscr
	vupdate
	gui
	mouseview
	0 sdlcls

	2.0 tsize
	3 tcol 2 2 tat " Ar3na" temits 2 tcol " Code" temits
	
	
|	100 100 textitle sprite
	
	draw.map
	draw.player
	draw.items
	
	2.0 tsize	
	draw.code

	runscript
	|showterm
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( editcompilar )
	<f2> =? ( addline ) 
|	<f3> =? ( "test" plog )
	drop ;
	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	
	tini
	
|	"media/ttf/Roboto-Medium.ttf" 30 TTF_OpenFont 'font !		
|	"Code Ar3na" $ffff0025f000 200 80 font textbox 'textitle !	
		
	64 vaini
	
| editor
	0 7 30 20 edwin
	edram
	
	bot.ini
	bot.reset
	'cdtok 8 vmcpu 'cpu ! | 8 variables

	"r3/r3vm/code/test.r3" edload | "" --
	
	"r3/r3vm/levels/level0.txt" loadmap
	"r3/r3vm/levels/tuto.txt" loadlevel	
	
	0 'state !
	
	'runscr SDLshow
	SDLquit 
	;
