| draw animate
| PHREDA 2023

^r3/lib/sdl2gfx.r3	
^r3/lib/gui.r3	
^r3/lib/rand.r3	

#ink $ff00

#aline * 8192
#aline>

| color 0 x y - op
|       1 dx dy - line
#lines
#lines>
#prev

:rando+
	7 randmax 3 - + ;
	
:a>xy | a -- x y
	dup 48 << 48 >> rando+
	swap 32 << 48 >> rando+ ;

:nodel | x y -- 'x 'y
	a>xy 2swap 2over sdlline ;

:node | x y n -- 'x 'y
	$100000000 and? ( nodel ; )	
	dup 33 >> SDLColor
	a>xy 2swap 2drop ;
	
:anidraw	
	lines >a 
	0 0 ( a@+ 1? node ) 3drop ;
	
|---- in screen	
:alinedraw
	$ffffff sdlcolor
	'aline @+ a>xy rot
	( aline> <? >a
		a@+ a>xy 2swap 2over SDLLine
		a> ) 3drop ;
	
#prev 
:pendn
	sdlx sdly 16 << or 
	dup $fff8fff8 and 'prev ! | 15 pixels are the same!
	ink 33 << or
	'aline !+ 'aline> ! ;
	
:penmv
	sdlx sdly 16 << or 
	dup $fff8fff8 and prev =? ( 2drop ; ) | don't store same point
	'prev !
	aline> !+ 'aline> ! ;
	
:pencopy	
	lines> >a
	'aline @+ a!+
	( aline> <? 
		@+ $100000000 or a!+
		) drop 
	0 a! a> 'lines> !
	rand 'ink ! 
	'aline 'aline> !
	;
	
:drawline
	0 sdlcls
	gui		
	0 0 sw sh guiRect
	'pendn 'penmv 'pencopy onMap
	anidraw
	alinedraw
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

: 
	"AniDraw" 800 600 SDLinit
	here 
	0 over ! | en with 0
	dup 'lines ! 'lines> ! 
	'drawline SDLshow 
	SDLquit
	;

