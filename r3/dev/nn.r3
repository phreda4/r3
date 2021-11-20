^r3/win/sdl2.r3
^r3/win/console.r3
^r3/lib/mem.r3
^r3/lib/rand.r3

#nninput 2
#nnhidden 3
#nnoutput 1

#nnsize 3
#nnlsize 2 3 1

#nni	| nodos input
#nnh	| nodos hidden
#nno	| nodos output

#Weights
#wi		| wi input
#wh		| wh input

:initnn | memory organization
	here
	dup 'nni ! nninput 3 << +
	dup 'nnh ! nnhidden 3 << +
	dup 'nno ! nnoutput 3 << +
	
	dup 'Weights !
	dup 'wi ! nninput nnhidden * 3 << +
	dup 'wh ! nnhidden nnoutput * 3 << +
	'here !
	;

	
:drawneuron	| layer tot now
	$666666 SDLColor
	
	pick2 40 * 30 + over 40 * 30 + | x y
	10 dup 2swap SDLFillellipse
	;
	
:drawlink | l t1 n1 t2 n2
	$ff00 SDLColor
	pick4 40 * 30 + 
	pick3 40 * 30 +
	over 40 +
	pick3 40 * 30 +
	SDLLine
	;
	
:drawnn
	0 ( nnsize 1 - <?
		dup 3 << 'nnlsize + @
		0 ( over <? | layer lsize nro
			pick2 1 + 3 << 'nnlsize + @
			0 ( over <? | l lsize1 n1 lsize2 n2
				drawlink
				1 + ) 2drop
			1 + ) 2drop
		1 + ) drop
	0 ( nnsize <? 
		dup 3 << 'nnlsize + @
		0 ( over <? | layer lsize nro
			drawneuron
			1 + ) 2drop
		1 + ) drop
		
	;
	
:fowardpp
	;
	
:backpp
	;
	
:main
	0 SDLclear
	drawnn
	SDLRedraw 
	SDLkey
	>esc< =? ( exit )
	drop	
	;

: 
	initnn
	"r3sdl" 800 600 SDLinit
	'main SDLShow
	SDLquit 
;