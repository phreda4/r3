| ploting function
| for Kiyoshi YONEDA
| PHREDA 2025

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3
^r3/util/immi.r3

#font
#sfont

| Funciones de motivación
:m_0 
	-? ( 0 nip ; ) ;

:l_0
	-? ( 0 nip ; ) 
	dup *. 2/ ;

:m_linear
	;

:m_const
	1.0 <=? ( ; ) 
	1.0 nip ;

:m_log
	1.0 <=? ( ; )
	1.0 + log2. ;

:m_recip
	1.0 <? ( ; )
	1.0 + 2.0 swap /. ;

:m_lgn
	1.0 <? ( ; )
	1.0 over log2. - swap /. ;
	
:m_sin
	dup sin swap 2* sin *. ;
	
|-- soft
	
:_softclip
	0.8 <? ( 
		dup dup 16 *>> over 16 *>> 
		0.185 16 *>> - ; )
	1.6 <? ( 0.8 -
		dup dup 16 *>> 0.05625 16 *>> neg
		swap 0.32599 16 *>> 0.70528 + + ; )
	2.4 <? ( 1.6 -
		dup dup 16 *>> 0.02281 16 *>> neg
		swap 0.08625 16 *>> 0.92167 + + ; )
	2.4 -
	0.02722 16 *>> 0.98367 +
	1.0 <? ( ; ) 1.0 nip ;
	
::soft_clip
	-? ( neg _softclip neg ; ) _softclip ;
	
|---- graph	
#xmin -4.0
#xmax 4.0
#ymin -3.0
#ymax 3.1

#stepx

:x>scr | x -- xscr
	xmin - cw xmax xmin - */ cx + ;
	
:y>scr | y -- yscr
	ymin - ch ymax ymin - */ ch swap - cy + ;
	
:drawGrid
	$444444 sdlcolor
	xmin $ffff + $ffff nand
	( xmax <?
		dup x>scr cy 1 ch sdlrect
		1.0 + ) drop
	ymin $ffff + $ffff nand
	( ymax <?
		cx over y>scr cw 1 sdlrect
		1.0 + ) drop
		
	$888888 sdlcolor
	cx 0.0 y>scr cw 1 sdlrect
	0.0 x>scr cy 1 ch sdlrect 
	;
	
|--- draw
#xp #yp
:xline 2dup xp yp sdlline
:xop 'yp ! 'xp ! ;	

:xfun | 'vec x -- 'vec x x' y'
	dup x>scr
	over pick3 ex y>scr ;
	
:drwfunc | vec --
	xmax xmin - cw / 2* 'stepx !
	xmin 
	xfun xop
	( xmax <?
		xfun xline
		stepx +
		) 2drop ;

|---- function draw
| 32bits 
| sign = point
| x(15bits) y(16bits)
#lines		| store the lines precalc
#lines>

:32uv | b -- x y 
	dup 33 << 64 15 - >>
	swap 48 << 48 >> ;
	
:uv32 | x y -- b
	$ffff and swap $7fff and 16 << or ;
	
:lin.clear
	lines 'lines> ! 
	0 lines> d! ;
	
:,lin
	lines> d!+ 'lines> ! ;
	
:linplot
	-? ( sdlcolor d@+ 32uv xop ; )
	32uv xline ;
	
:lin.draw
	lines ( d@+ 1?
		linplot
		) 2drop ;
		
:,color | color --
	$80000000 or ,lin ;
	
:,op | x y --
	uv32 ,lin ;
	
:,line | x y -- 
	uv32 ,lin ;
	
:,func | 'vec color --
	,color
	xmax xmin - cw / 'stepx !
	xmin xfun ,op
	( xmax <?
		xfun ,line
		stepx + ) 2drop 
	0 lines> d! ;

|--------------------
:main
	$0 sdlcls
	uiStart
	8 8 uiPading
	font txfont
	|__________
	0.05 %h uiN
	"Function Plot" uiLabelC
|	0 y>scr "%f" sprint uiLabel
	|__________
	0.1 %w uiE
	'exit "Exit" uiCBtn 
	"[F1]" uiLabel
	"[F2]" uiLabel
	"[F3]" uiLabel
	|__________
	uiRest
	sfont txfont
	
	$666666 sdlcolor
	drawGrid
	lin.draw
|	$ffffff sdlcolor
|	'm_log drwfunc
	
|	$ffff sdlcolor
|	'm_recip drwfunc
	
	uiEnd
	
	sdlredraw
	sdlkey
	>esc< =? ( exit ) 
	<f1> =? ( 'm_log $ff0000 ,func )
	<f2> =? ( 'm_lgn $ff00 ,func )
	<f3> =? ( 'm_sin $ff00 ,func )
	<f4> =? ( 'gamma $ff ,func )
	<f5> =? ( 'tanh $ffff ,func )
	<f6> =? ( 'soft_clip  $ffff00 ,func )
	drop
	;
	
: 	
	"r3sdl" 1024 600 SDLinitR
	"media/ttf/Roboto-Medium.ttf" 20 txloadwicon 'font !
	"media/ttf/Roboto-Medium.ttf" 14 txload 'sfont !
	|___ MEM
	here 'lines !
	$ffff 'here +!
	lin.clear	
	mark
	
	'main SDLshow
	SDLquit ;	
