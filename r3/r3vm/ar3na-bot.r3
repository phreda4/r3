| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/util/sdlgui.r3
^r3/util/sdlbgui.r3
^r3/util/varanim.r3
^r3/util/textb.r3

^./arena-map.r3
^./rcodevm.r3


#font

#cpu

#cdtok * 1024
#cdtok> 'cdtok
#cdcnt

#lev
#cdspeed 0.2

:linecode | adr -- adr
	cdtok> =? ( ">" bemits2 )
	@+ dup 8 >> $ff and 'lev !
	vmtokstr bemits2 bsp ;
	
:showcode
	2 64 bat
	'cdtok
	0 ( cdcnt <? swap 
		linecode
		swap 1+ ) 2drop ;

:processlevel	
	cdcnt 'cdtok vmcheckcode 
	cdcnt 'cdtok vmcheckjmp
	;

:stepvm
	cdtok> 0? ( drop ; ) 
	vmstepck 'cdtok> !
	terror 1 >? ( drop -8 'cdtok> +! ; ) drop
	;
	
:stepvma
	stepvm
	cdtok> 'cdtok - 3 >> 
	cdcnt <? ( 'stepvma cdspeed +vexe ) drop
	;
	
|-----------------------
	
#aitem
	
::item
	-3 -3 posmap
	viewpz
	aitem anim>n
	imgspr sspritez
	
	deltatime 'aitem +!
	;
	
|-------------------

:compilar
	vmtokreset
|	0 'cdcnt !
|	'cdtok 'cdtok> !
	'pad 'cdtok vmtokenizer 'cdtok> ! 

	cdtok> 'cdtok - 3 >> 'cdcnt !
	'cdtok 'cdtok> !
	;
	
:immex	
|	r3reset
|	'pad r3i2token drop 'lerror !
	compilar
	0 'pad !
	refreshfoco
|	code> ( icode> <? 
	| vmcheck
|		vmstep ) drop
	;
	
:showstack
	8 532 bat
	" " bprint2
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ vmcell "%s " bprint2 
		) 2drop 
	TOS vmcell "%s " bprint2
	;
	
	
:showinput
	$7f00007f sdlcolorA	| cursor
	0 500 1024 600 SDLfRect
	$ff0000 bcolor
	0 502 bat ":" bprint2
	32 500 immat 1000 32 immbox
	'pad 128 immInputLine2	
	;		

|-------------------
:runscr
	vupdate
	immgui
	mouseview
	0 sdlcls
	
	$ffff bcolor 8 8 bat "Ar3na Bot" bprint2 bcr2
	|$ffffff bcolor viewpz viewpy viewpx "%d %d %f" bprint2
	showcode
	showstack
	
	$ffffff sdlcolor
	draw.map
	player
	item
	
	showinput
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<ret> =? ( immex )
	
	|----
	<f1> =? ( stepvm )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	"media/ttf/seguiemj.ttf" 20 TTF_OpenFont 'font !		
	bfont1
	64 vaini
	
	bot.ini
	bot.reset
	'cdtok 8 vmcpu 'cpu ! | 8 variables

	|------- test
	7 'cdcnt !
	'cdtok >a
	$300000000 a!+
	$10a a!+
	$110 a!+
	$100000100 a!+
	$14c a!+
	$10b a!+
	$09 a!+
	processlevel	
	
	30 8 128 ICS>anim  | init cnt scale -- val
	'aitem !
	
	'runscr SDLshow
	SDLquit 
	;
