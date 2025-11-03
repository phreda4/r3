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
	dup ln. swap /. 1.0 swap - ;
	
|---- graph	
#xmin -0.1
#xmax 4.0
#ymin -0.1
#ymax 4.0

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
	
|--- direct draw
#xp #yp
:xline 2dup xp yp sdlline
:xop 'yp ! 'xp ! ;	

:xfun | 'vec x -- 'vec x x' y'
	dup x>scr
	over pick3 ex y>scr ;
	
:drwfunc | vec --
	xmax xmin - cw / 'stepx !
	xmin 
	xfun xop
	( xmax <?
		xfun xline
		stepx +
		) 2drop ;

|---- function draw
#lines		| store the lines precalc
#lines>

:32uv | b -- x y 
	dup 15 >> $7fff and
	swap $7fff and ;
	
:uv32 | x y -- b
	$7fff and 
	swap $7fff and 15 << or ;
	
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

|---------------------------
|--- info for every func ---

#xs_start 0.0 
#xs_stop 4.0
#xs_step 0.1

#f	

#ms
#ls
#qs
#ps
#pa
#ss
#hs
#hA
#Z

#cntxs

:mktables | func -- 
	'f ! 
	here 
|--- 1. tabla	
	dup 'ms ! >a
	xs_start ( xs_stop <?
		dup f ex 
|		dup "%f " .print
		a!+ 
		xs_step + ) drop 
|	.cr
	a> ms - 3 >> 1- 'cntxs !
|--- 2. Integrar m() para obtener la función l().
	ms >b
	a> 'ls ! 
	0 
|	dup "%f " .print
	dup a!+
	cntxs ( 1? 1- 
		b@+	b@ + | ms[i]+ms[i+1] 
		xs_step *. 2/ rot +
|		dup "%f " .print
		dup a!+
		swap ) 2drop
|	.cr
|--- 3. Integrar exp(-l()) para obtener q().
	ls >b a> 'qs !
	cntxs ( 1? 1- 
		b@+ neg exp. 
|		dup "%f " .print
		a!+
		) drop
|	.cr
|--- 4. Integrar q() para obtener Q().
|--- 5. Integrar Q() para obtener un valor Z.
	qs >b |a> 'qa !
	0
	cntxs ( 1? 1- 
		b@+ b@ + xs_step *. 2/ 
		rot +
		swap ) drop
|	.cr
|	dup "Z:%f " .println
	'Z !
|--- 6. p() := q()/Z.
	qs >b a> 'ps ! 
	cntxs ( 1? 1- 
		b@+ Z /. 
|dup "%f " .print		
		a!+
		) drop
|.cr		
	ps >b a> 'pa !
	0 
	dup a!+
	cntxs ( 1? 1- 
		b@+ b@ + xs_step *. 2/ 
		rot +
|dup "%f " .print			
		dup a!+
		swap ) 2drop
|	.cr

|--- 7. Combinar p^-() del lado negativo y p^+() del lado positivo para obtener p() combinado.
|.cr "ss" .println
	pa >b a> 'ss !
	cntxs ( 1? 1- 
		b@+ neg 1.0 +
|dup "%f " .print		
		a!+ ) drop

|#hs
|.cr "hs" .println
	ss >b 
	a> 'hs !
	ps
	cntxs ( 1? 1- 
		swap @+ b@+ /.
|dup "%f " .print
		a!+ swap ) 2drop
		
|#hA
|.cr "HA" .println
	hs >b a> 'ha !
	0 
	dup a!+
	cntxs ( 1? 1- 
		b@+ b@ + xs_step *. 2/ 
		rot +
|dup "%f " .print			
		dup a!+
		swap ) 2drop

	;

:2>scr | x y -- x x' y'
	over x>scr swap y>scr ;

:func+ | table --
	|$ff00ff ,color
	ms >a
	xmin a@+ 2>scr ,op
	( stepx + xmax <? a@+ 2>scr ,line ) drop
	;
	
:gengra	
	|--- gen graphics
	lin.clear
	$ff00ff ,color
	ms >a
	xmin a@+ 2>scr ,op
	( stepx + xmax <? a@+ 2>scr ,line ) drop

	$ffff ,color
	ls >a
	xmin a@+ 2>scr ,op
	( stepx + xmax <? a@+ 2>scr ,line ) drop

	$ffff00 ,color
	qs >a
	xmin a@+ 2>scr ,op
	( stepx + xmax <? a@+ 2>scr ,line ) drop

	$ff00 ,color
	ps >a
	xmin a@+ 2>scr ,op
	( stepx + xmax <? a@+ 2>scr ,line ) drop
	
	0 lines> d! ;		
	;
	

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
	|__________		
	uiRest
	sfont txfont
	
	
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
	
	'm_linear mktables
|	'm_log mkxs
|	'm_const mkxs
|	'm_recip mkxs
|	'm_lgn mkxs
	
	'main SDLshow
	SDLquit ;	
