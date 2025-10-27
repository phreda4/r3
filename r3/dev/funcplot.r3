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
	
#xmin -0.1
#xmax 4.0
#ymin -3.0
#ymax 3.0

#stepx
#stepy

:calcstep
	xmax xmin - cw / 'stepx !
	ymax ymin - ch / 'stepy ! 
	;

:x>scr | x -- xscr
	xmin - cw xmax xmin - */ cx + ;
	
:y>scr | y -- yscr
	ymin - ch ymax ymin - */ ch swap - cy + ;
		
:axisx
	cx 0.0 y>scr cw 1 sdlrect ;
	
:axisy
	0.0 x>scr cy 1 ch sdlrect ;
	
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
	
:drawGrid
	axisx
	axisy
	;

:main
	$0 sdlcls
	uiStart
	8 8 uiPading
	calcstep
	font txfont
	|__________
	0.05 %h uiN
	"Function Plot" uiLabelC
|	0 y>scr "%f" sprint uiLabel
	|__________
	0.2 %w uiE
	'exit "Exit" uiCBtn 
	|__________		
	uiRest
	sfont txfont
	
	$666666 sdlcolor
	drawGrid
	
	$ffffff sdlcolor
	'm_log drwfunc
	
	$ffff sdlcolor
	'm_recip drwfunc
	
	uiEnd
	
	sdlredraw
	sdlkey
	>esc< =? ( exit ) 
	drop
	;
	
: 	
	"r3sdl" 1024 600 SDLinitR
	"media/ttf/Roboto-Medium.ttf" 20 txloadwicon 'font !
	"media/ttf/Roboto-Medium.ttf" 12 txload 'sfont !
	
	'main SDLshow
	SDLquit ;	
