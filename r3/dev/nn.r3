| Neural Network
| PHREDA 2021

^r3/win/sdl2.r3
^r3/win/console.r3
^r3/lib/mem.r3
^r3/lib/rand.r3

#nnsize 3
#nninput 3	| 1+ for bias
#nnhidden 3
#nnoutput 1

#Nodes
#Nodesl
#nni	| nodos input
#nnh	| nodos hidden
#getout	| nodos output

#Weights
#Weightsl
#wi		| wi input
#wh		| wh input

#Errors | array for error

#TrainVector

:nnsizel | n -- size
	3 << 'nninput + @ ;
	
:initnn | memory organization
	here
	
	dup 'TrainVector ! 
	nninput nnoutput + ncell+
	
	dup 'Nodes !
	dup 'nni ! nninput ncell+
	dup 'nnh ! nnhidden ncell+
	dup 'getout ! nnoutput ncell+
	
	dup 'Weights !
	dup 'wi ! nninput nnhidden * ncell+
	dup 'wh ! nnhidden nnoutput * ncell+
	
	dup 'Errors !
	nninput nnhidden max nnoutput max
	ncell+
	'here !
	;

:r-1.1	2.0 randmax 1.0 - ;

:randnn
	1.0 Nodes ! | bias in 1
	Weights	>a
	nninput nnhidden * nnhidden nnoutput * +
	( 1? 1 - r-1.1 a!+ ) drop ;
	
|-------------------------------------- draw NN
:neuroncolor | ; 0..1 -> 0..$ff
	8 >> $ff clamp0max dup 8 << over 16 << or or ;
	
:drawneuron	| layer tot now
	a@+ neuroncolor SDLColor

	pick2 40 * 30 + over 40 * 30 + | x y
	10 dup 2swap SDLFillellipse
	;
	
:linkcolor | ; -1..0 -> red  0..1 -> green
	-? ( 1.0 swap - $ff 16 *>> 16 << ; )
	$ff 16 *>> 8 << ;
	
:drawlink | l t1 n1 t2 n2
	a@+ linkcolor SDLColor

	pick4 40 * 30 + pick3 40 * 30 +
	over 40 + pick3 40 * 30 +
	SDLLine
	;
	
:drawnn
	Weights >a
	0 ( nnsize 1 - <?
		dup nnsizel
		0 ( over <? | layer lsize nro
			pick2 1 + nnsizel
			0 ( over <? | l lsize1 n1 lsize2 n2
				drawlink
				1 + ) 2drop
			1 + ) 2drop
		1 + ) drop
		
	Nodes >a
	0 ( nnsize <? 
		dup nnsizel
		0 ( over <? | layer lsize nro
			drawneuron
			1 + ) 2drop
		1 + ) drop ;
	
|--------------------------------------	debug, print	
:printnn
	Nodes >b
	0 ( nnsize <? 
		dup "L %d-" .print
		dup nnsizel
		dup "%d:" .print
		0 ( over <? | layer lsize nro
			b@+ "%f " .print
			1 + ) 2drop
		cr
		1 + ) drop
	cr
	Weights >a
	0 ( nnsize 1 - <?
		dup nnsizel
		0 ( over <? | layer lsize nro
			pick2 1 + nnsizel
			0 ( over <? | l lsize1 n1 lsize2 n2
				b@+ "%f " .print
				1 + ) 2drop
			cr
			1 + ) 2drop
		cr
		1 + ) drop ;
	
|--------------------------------------	foward propagation
:fact | v -- v ; activate function
	neg exp. 1.0 + 1.0 swap /. ; 			| 1 / (1 + exp(-x)); ; 0..1
|	neg 1 << exp. 1.0 + 2.0 swap /. 1.0 - ; | 2/(1+exp(-2*x)) -1 ; -1..1
	
:fdact | v -- v ; derivate activate function
	1.0 over - *. ; 		| x*(1-x);	; 0..1
|	fact dup *. 1.0 swap - ; 	| 1-(f(x)^2) ; -1..1
	
:setin | 'vector --
	>b 
	Nodes cell+ >a | skip bias
	|0 nnsizel 1 - 
	2
	( 1? b@+ a!+ 1 - ) drop ;
	
:calcsum | sizelayer -- result ; a:weigth b:node
	0.0 ( swap 1? 1 - 
		a@+ b@+ *. rot + 
		) drop 
	fact 
	;
	
:fowardpp | -- 
	nnh
	nnhidden ( 1? 1 - 
		wi >a
		nni >b
		nninput calcsum
		rot !+ swap
		) 2drop
		
	getout
	nnoutput ( 1? 1 -
		wh >a
		nnh >b
		nnhidden calcsum 
		rot !+ swap
		) 2drop
	;
	

:calerr | error sizelayer -- ; error:vector to store error a: output layer b:training
	( 1? 1 -
		a@+ b@+ over - swap fdact *.
		rot !+ swap
		) drop ;

:backpp
	nnoutput ( 1? 1 -
		wh >a
		trainvector nninput ncell+ >b
		errors nnoutput calerr
		
		) drop
	
	
	;

:train | 'vector --
	TrainVector setin
	fowardpp
	backpp
	;
	
:trainstep	

	;
|--------------------------------------	draw map
#vec 0 0 

#x #y
:dbox | color --
	SDLcolor x y 4 dup SDLFillRect ;
	
:drawmap
	10 'y !
	0 ( 1.0 <?
		200 'x !
		0  ( 1.0 <?
			2dup 'vec !+ !

			'vec setin
			fowardpp
			getout @
			$ff and 
			|neuroncolor 
			dbox

			4 'x +!
			0.01 + ) drop
		4 'y +!
		0.01 + ) drop ;
	
:printmap
	0 ( 1.0 <?
		0  ( 1.0 <?
			2dup 'vec !+ !

			'vec setin
			fowardpp
			getout @ "%f " .print
			
			0.1 + ) drop
		cr
		0.1 + ) drop ;	
		
|--------------------------------------	main
:main
	0 SDLclear
	
	drawmap	
	drawnn
	
	SDLRedraw 
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( trainstep )
	<f2> =? ( randnn )
	drop	
	;

: 
	initnn
	rerand
	randnn
	
	.cls
	printnn	
	1.0 1.0 'vec !+ ! 'vec setin fowardpp printnn
	printmap
	0.0 1.0 'vec !+ ! 'vec setin fowardpp printnn
	printmap

	|-3.0 ( 3.0 <? dup fdact over "%f %f" .println 0.4 + ) drop
	
	"r3sdl" 800 600 SDLinit
	'main SDLShow
	SDLquit 
;