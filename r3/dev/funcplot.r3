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

	
|---- graph	
#xmin -0.1
#xmax 4.0
#ymin -3.0
#ymax 3.0

#stepx

:x>scr | x -- xscr
	xmin - cw xmax xmin - */ cx + ;
	
:y>scr | y -- yscr
	ymin - ch ymax ymin - */ ch swap - cy + ;
		

	

	
|--- draw
#xp #yp
:xline 2dup xp yp sdlline
:xop 'yp ! 'xp ! ;	

:xfun | 'vec x -- 'vec x x' y'
	dup x>scr
	over pick3 ex y>scr 
	cy max ch min ;
	
:drwfunc | vec --
	xmax xmin - cw / 2* 'stepx !
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

|----
#f

#ms
#ls
#qs
#q2
#ps
#Z

:2>scr | x y -- x x' y'
	over x>scr
	swap y>scr
	cy max ch min 
	;
	
:calculate | f -- 
	'f ! 
	xmax xmin - cw / 'stepx !
	empty mark | reuse memory
	here
	dup 'ms ! cw 1+ 3 << +
	dup 'ls ! cw 1+ 3 << +
	dup 'qs ! cw 1+ 3 << +
	dup 'ps ! cw 1+ 3 << +
	'here !
	
|--- 1. Interpolar la tabla M para obtener la función m().
	ms >a
	xmin ( xmax <?
		dup f ex a!+
		stepx + ) drop

|--- 2. Integrar m() para obtener la función l().
	ls >a ms >b
	0
	xmin ( xmax <?
		b@+	| ms[i]
		b@ + | ms[i+1] 
		stepx *. 2/. swap +
		dup a!+
		swap 
		stepx + ) 2drop

|--- 3. Integrar exp(-l()) para obtener q().
|--- 4. Integrar q() para obtener Q().
|--- 5. Integrar Q() para obtener un valor Z.
	qs >a ls >b
	0
	xmin ( xmax <?
		b@+ neg exp. 
		b@ neg exp. + 
		stepx *. 2/. swap +
		dup a!+
		swap 
		stepx + ) drop
	'Z !

|--- 6. p() := q()/Z.
	ps >a qs >b
	0
	xmin ( xmax <?
		b@+ Z /. 
		b@ Z /. + 
		stepx *. 2/. swap +
		dup a!+
		swap 
		stepx + ) 2drop
|--- 7. Combinar p^-() del lado negativo y p^+() del lado positivo para obtener p() combinado.
|--- 8. Realizar varias modificaciones de p() que impliquen transformaciones e integraciones. Compararlas con las modificaciones de otros p().	
	
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
	
|--------------------
:axisx
	cx 0.0 y>scr cw 1 sdlrect ;
	
:axisy
	0.0 x>scr cy 1 ch sdlrect ;

:drawGrid
	axisx
	axisy
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
	<f4> =? ( 'm_log calculate ) 
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
