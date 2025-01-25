| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/util/sdlgui.r3
^r3/util/sdlbgui.r3
^r3/util/varanim.r3
^r3/util/textb.r3

^./arena-map.r3


#font

#cpu

#cdtok * 1024
#cdtok> 'cdtok
#cdcnt

#lev
#cdspeed 0.2

:linecode
	a@+ dup 8 >> $ff and 'lev !
	vmtokstr bemits2 bsp ;
	
:showcode
	2 64 bat
	'cdtok >a
	0 ( cdcnt <?
		linecode
		1+ ) drop ;

:processlevel	
	cdcnt 'cdtok vmcheckcode 
	cdcnt 'cdtok vmcheckjmp
	;

:stepvm
	cdtok> 
	0? ( drop ; ) 
	vmstepck 'cdtok> !
	terror 1? ( drop -8 'cdtok> +! ; ) drop
	cdtok> 'cdtok - 3 >> 
	cdcnt <? ( 'stepvm cdspeed +vexe ) drop
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
#lerror

:immex	
|	r3reset
|	'pad r3i2token drop 'lerror !
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
		@+ "%d " bprint2 
		) 2drop 
	TOS "%d " bprint2
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
|	<f1> =? ( changemodo )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	64 vaini
	bfont1

|	'cdtok 32 vmcpu 'cpu !

	"media/ttf/seguiemj.ttf" 20 TTF_OpenFont 'font !		
	bot.ini
	bot.reset
	
	
	|fillmap
	30 8 128 ICS>anim  | init cnt scale -- val
	'aitem !
	
	'runscr SDLshow
	SDLquit 
	;
