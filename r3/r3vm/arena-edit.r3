| ar3na bot 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/util/ttext.r3

^./tedit.r3
^./rcodevm.r3

|----------- marcas
| y|x|ini|cnt|colorf|colorb
| ttco1co2wwhhxxyy
| 8(t)12(col1)12(col2)8(w)8(h)8(x)8(y)
#marcas * $ff | 32 marcadores
#marcas> 'marcas

#vard * 1024

::clearmark	'marcas 'marcas> ! ;

::addmark	marcas> !+ 'marcas> ! ;

::addsrcmark | src color --
	32 << swap
	dup >>sp over - 24 << 
	swap src2pos
	ycursor or 
	xcursor 8 << or 
	$010000 or	| h
	or addmark ;

:linemark | mark --
	dup $ff and ylinea -
	-? ( 2drop ; ) hcode >=? ( 2drop ; ) | fuera de pantalla
	over >a
	advy * yedit +   | y real
	over 8 >> $ff and 
	lnsize + advx * xedit +  | x real
	swap rot | x y vv
	dup 24 >> $ff and advx * | w
	swap 16 >> $ff and advy * | h
	pick3 1- pick3 1- pick3 2 + pick3 2 +
	a> 32 >> 4bcol sdlcolor sdlRect
	a> 48 >> 4bcol sdlcolor sdlFRect
	;

:showmark
	ab[ 'marcas ( marcas> <? @+ linemark ) drop ]ba ;

|------------------
::varplace | src -- val
	src2pos
	ycursor  
	xcursor 8 << or 
	;

::buildvars
	ab[
	'vard >a
	data >b
	code 8 - @ 32 >> 3 >>
	( 1? 1-
		b@+
		16 >> $ffff and fuente + varplace 
		a!+ 
		) a!		 
	]ba ;

:linevar
	dup $ff and ylinea -
	-? ( 2drop ; ) hcode >=? ( 2drop ; ) | fuera de pantalla
	advy * yedit +   | y real
	swap 8 >> $ff and 
	lnsize + advx * xedit +  | x real
	swap tat
	a@+ 

	vmcellcol tcol
	vmtokstr trect swap advx 2* + swap sdlfrect | cler 2 char more
	temits
	;
	
:showvars
	$0 sdlcolor 
	data >a 
	'vard ( @+ 1? linevar ) 2drop 
	;

|------------	
##state | 0 - view | 1 - edit | 2 - run | 3 - error
#cdspeed 0.1

::stepvm
	ip 0? ( drop ; ) 
	|vmstepck 
	vmstep
	1? ( dup vm2src 'fuente> ! )
	'ip !
	;
	
::stepvma
	ip 0? ( drop ; ) 
	vmstepck 
	|vmstep
	terror 1 >? ( 2drop 
		3 'state ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop
	|cdtok> >=? ( drop 0 ) | fuera de codigo
	0? ( 'ip ! 1 'state ! ; ) | fin
	dup vm2src 'fuente> ! 
	'ip !
	'stepvma cdspeed +vexe 
	;

::stepvmas
	ip 0? ( drop ; ) 
	vmstepck 
	|vmstep
	terror 1 >? ( 2drop 
		3 'state ! 
		clearmark
		fuente> $f00ffff addsrcmark 
		; ) drop
|	cdtok> >=? ( drop 0 ) | fuera de codigo
	0? ( 'ip ! 1 'state ! ; ) | fin
	dup vm2src 'fuente> ! 
	'ip !
	;

|------------ STACK
#sty 

:cellstack | cell --
	vmcellcol $7 and 
	tpal 2/ $7f7f7f and |$00000 col50% | obscure
	sdlcolor 
	xedit wedit + 2 +
	sty 2 - 
	112 28 sdlfrect
	xedit wedit + 2 +
	sty tat vmcell temits
	-30 'sty +!
	;
	
:draw.stack
	xedit -? ( drop ; ) | not show without editor
	wedit + 2 + 
	yedit hedit + 
	110 16 sdlfrect
	6 tcol
	xedit wedit + 3 +
	yedit hedit + 
	tat "Stack" temits
	vmdeep 0? ( drop ; ) 
	yedit hedit + 27 - 'sty ! 
	stack -? ( 2drop ; ) 16 +
	( swap 1- 1? swap
		@+ cellstack
		) 2drop 
	TOS cellstack ;

	
|-----------------------
:showread
	$003f00 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit 64 + yedit 16 - tat "CODE:" tprint
	$7f00003f sdlcolorA	xedit yedit wedit hedit sdlFRect
	
|	edfocus
	edcodedraw
	edtoolbar
	;

:showeditor
	$003f00 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit 64 + yedit 16 - tat "CODE: EDIT" tprint
	$7f00007f sdlcolorA	xedit yedit wedit hedit sdlFRect
	
	edfocus
	edcodedraw
	|draw.stack
	edtoolbar
	;	
	
:showruning
	$003f3f sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit 64 + yedit 16 - tat "CODE: RUN" tprint
	$7f00003f sdlcolorA	xedit yedit wedit hedit sdlFRect
	
	clearmark
	
	fuente> $007ffff addsrcmark | ip
	RTOS ( @+ 1? 				| rstack
		8 - @ vmcode2src $0070000 addsrcmark 
		) 2drop
	showmark
	edcodedraw
	draw.stack
	showvars	
	edtoolbar
	;	

:showerror
	$3f0000 sdlcolor xedit yedit 16 - wedit 16 SDLFrect
	$ffffff trgb xedit 64 + yedit 16 - tat "CODE: " tprint vmerror tprint
	$7f00007f sdlcolorA xedit yedit wedit hedit sdlFRect

	showmark
	
	edfocus
	edcodedraw
	edtoolbar
	;
	
#serror

	
#statevec 'showread 'showeditor 'showruning 'showerror 

::draw.code
	2.0 tsize
	state $3 and 3 << 'statevec + @ ex ;
	
