| Neural Network
| PHREDA 2021

^r3/win/sdl2.r3
^r3/win/console.r3
^r3/lib/mem.r3
^r3/lib/rand.r3

^r3/util/bfont.r3

#numInputs 2
#numHidden 3
#numOutputs 1
    
#lr 0.1
    
#inputLayer 		| [numinputs]	
	
#hiddenLayer		|[numHidden];
#hiddenLayerBias	|[numHidden];
#hiddenWeights		|[numInputs][numHidden];
	
#outputLayer		|[numOutputs];
#outputLayerBias	|[numOutputs];
#outputWeights		|[numHidden][numOutputs];

#resultLayer		|[numOutputs];
#deltaOutput
#deltaHidden

#training
#ntraining 0

:nnmem | memory map
	here

	dup 'inputLayer ! numInputs ncell+ 
	
	dup 'hiddenLayer ! numHidden ncell+
	dup 'hiddenLayerBias ! numHidden ncell+
	
	dup 'outputLayer ! numOutputs ncell+
	dup 'outputLayerBias ! numOutputs ncell+
	
	dup 'resultLayer ! numOutputs ncell+
	
	dup 'hiddenWeights ! numInputs numHidden * ncell+
	dup 'outputWeights ! numHidden numOutputs * ncell+

	dup 'deltaOutput ! numOutputs ncell+
	dup 'deltaHidden ! numHidden ncell+
	
	dup 'training !
	'here !
	;
    
:r-1.1	2.0 randmax 1.0 - ;
:r0.1	1.0 randmax ;	

:iniw | cnt mem --
	>a ( 1? 1 - r-1.1 a!+ ) drop ;

:inib | cnt mem --
	>a ( 1? 1 - 1.0 a!+ ) drop ;

:iniz | cnt mem --
	>a ( 1? 1 - 0 a!+ ) drop ;
	
:nnini |
	rerand
	numInputs numHidden * hiddenWeights iniw
	numHidden numOutputs * outputWeights iniw
	numHidden hiddenLayerBias iniw
	numOutputs outputLayerBias iniw
	;

	
|-----------	
:sigmoid | v -- v ; activate function
|	neg exp. 1.0 + 1.0 swap /. ; 			| 1 / (1 + exp(-x)); ; 0..1
	neg 1 << exp. 1.0 + 2.0 swap /. 1.0 - ; | 2/(1+exp(-2*x)) -1 ; -1..1
	;
	
:dsigmoid | v -- v ; derivate activate function
|	1.0 over - *. ; 		| x*(1-x);	; 0..1
	sigmoid dup *. 1.0 swap - ; 	| 1-(f(x)^2) ; -1..1	

	
:forwardpp
	hiddenWeights >a
	hiddenLayer
	hiddenLayerBias
	numHidden ( 1? 1 - >r
		@+ 
		inputLayer >b
		numInputs ( 1? 1 - 
			a@+ b@+ *. rot +
			swap ) drop
		sigmoid	rot !+ swap
		r> ) 3drop
	
	outputWeights >a
	outputLayer
	outputLayerBias	
	numOutputs ( 1? 1 - >r
		@+
		hiddenLayer >b
		numHidden ( 1? 1 -
			a@+ b@+ *. rot +
			swap ) drop
		sigmoid rot !+ swap
		r> ) 3drop	;


:backwardpp
	outputLayer >b
	resultLayer >a
	deltaOutput
	numOutputs ( 1? 1 -					| delta num
		b@+ dup dsigmoid a@+ rot 
		- *. | delta num soutput*result-output*lr
		rot !+ swap				
		) 2drop
	outputWeights >b
	outputLayerBias
	deltaOutput
	numOutputs ( 1? 1 - >r
		@+ lr *. dup >r 			| output delta @delta r:@delta
		pick2 +! swap cell+ swap 	| output delta
		r> hiddenLayer >a			| output delta @delta
		numHidden ( 1? 1 -		| output delta @delta num
			over a@+ *. b@ + b!+	| output delta @delta num 
			) 2drop
		r> ) 3drop
	
	
	outputWeights >a	
	deltaHidden 
	numHidden ( 1? 1 -
		0.0
		deltaOutput >b
		numOutputs ( 1? 1 - 
			a@+ b@+ *. rot + swap
			) drop
		lr *. rot !+ swap
		) 2drop
	hiddenWeights >b
	hiddenLayerBias
	deltaHidden 
	numHidden ( 1? 1 - >r		| bias delta 
		@+ lr *. dup pick3 +! 			| bias delta @delta
		rot cell+ rot rot
		inputLayer >a
		numInputs ( 1? 1 -			| bias delta @delta num
			a@+ pick2 *. b@ + b!+		| bias delta 
			) 2drop
		r> ) 3drop
	;
	
:nnerror | -- n
	outputLayer >b
	resultLayer >a
	0.0
	numOutputs ( 1? 1 -					| delta num
		b@+ a@+ - abs 
		rot + swap
		) drop ;
	
:trainstep | adr --
	>a
	inputLayer >b
	numInputs ( 1? 1 - a@+ b!+ ) drop
	resultLayer >b
	numOutputs ( 1? 1 - a@+ b!+ ) drop
	forwardpp
	backwardpp
	;
	
#test 1.0 1.0 1.0	
:testrain
	'test trainstep ;
	
|--------------------------------------	color
:neuroncolor | ; 0..1 -> 0..$ff
	8 >> $ff clamp0max dup 8 << over 16 << or or ;
	
:linkcolor | ; -1..0 -> red  0..1 -> green
	-? ( 1.0 swap - $ff 16 *>> 16 << ; )
	$ff 16 *>> 8 << ;	
	
|--------------------------------------	train set
:cleartrain
	0 'ntraining ! ;

:atrain | n -- adr
	numInputs numOutputs + *
	training swap ncell+ ;
	
:addtrain | -- adr
	ntraining atrain
	1 'ntraining +! ;

:randtrainstep
	ntraining randmax atrain trainstep ;
	
:tomap | x y -- xm ym
	swap 400 16 *>> 200 +
	swap 400 16 *>>
	;
	
:drawtrain
	training >a
	ntraining ( 1? 1 -
		a> numInputs ncell+ @ neuroncolor	| result
		SDLColor
		8 dup a@+ a@+ 
		tomap SDLFillellipse
	
		numInputs 2 - numOutputs + cell * a+
		) drop ;
		
|--------------------------------------	draw nn
#x #y

:drawneuron	| 
	neuroncolor SDLColor
	10 dup x y SDLFillellipse
	;

:drawlayer | cnt layer --
	( swap 1? 1 - swap
		@+ drawneuron 
		40 'y +! ) 2drop ;
		
:drawlink | n2 n1 w -- n2 n1
	linkcolor SDLColor
	x
	over 40 * y + 
	x 40 +
	pick4 40 * y +
	SDLLine
	;
	
:draww 
	30 'x !
	30 'y !
	hiddenWeights >a
	0 ( numHidden <? 
		0 ( numInputs <?
			a@+ drawlink
			1 + ) drop
		1 + ) drop
	80 'x !
	30 'y !
	outputWeights >a
	0 ( numOutputs <?
		0 ( numHidden <? 
			a@+ drawlink
			1 + ) drop
		1 + ) drop	;	
	
:drawnn
	30 'x !
	30 'y !
	numInputs inputLayer drawlayer
	80 'x !
	30 'y !
	numHidden hiddenLayer drawlayer
	120 'x !
	30 'y !
	numOutputs outputLayer drawlayer
	;

:printnn
	"input:" .print
	inputLayer 
	numInputs ( 1? 1 - swap @+ "%f " .print swap ) 2drop 
	cr
	"hidden:" .print	
	hiddenLayer
	numHidden ( 1? 1 - swap @+ "%f " .print swap ) 2drop 
	cr
	"output:" .print	
	outputLayer
	numOutputs  ( 1? 1 - swap @+ "%f " .print swap ) 2drop 
	cr cr
	hiddenWeights 
	0 ( numHidden <? 
		0 ( numInputs <?
			rot @+ "%f " .print rot rot
			1 + ) drop
		cr
		1 + ) 2drop
	cr		
	outputWeights 
	0 ( numOutputs <?
		0 ( numHidden <? 
			rot @+ "%f " .print rot rot		
			1 + ) drop
		cr
		1 + ) 2drop	;		

|--------------------------------------	draw map
:dbox | color --
	SDLcolor x y 4 dup SDLFillRect ;
	
:drawmap
	0 'y !
	0 ( 1.0 <?
		200 'x !
		0  ( 1.0 <?
		
			2dup inputLayer !+ !
			forwardpp
			outputLayer @
			neuroncolor 
			dbox

			4 'x +!
			0.01 + ) drop
		4 'y +!
		0.01 + ) drop ;
		
|----------------------------------------- MAIN		
#entrenando 0
#value 0

:getval
	inputLayer >a
	SDLx 200 - 1.0 400 */ a!+
	SDLy 1.0 400 */ a!+
"-----------------------------" .println	
	forwardpp
	outputLayer @ 'value !
	printnn
	;
	
:main
	0 SDLclear
	
	drawmap	
	drawtrain	

	draww 
	drawnn	
	$ff00 bcolor
	0 0 bmat
	nnerror "Error: %f" sprint bmprint

	SDLRedraw 

	entrenando 1? ( 
		10 ( 1? 1 - randtrainstep ) drop 
		) drop
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( randtrainstep )
	<f2> =? ( nnini )
	<f3> =? ( entrenando 1 xor 'entrenando ! ) 
	<f4> =? ( printnn )
	<f5> =? ( testrain )
	drop	
	'getval SDLClick 
	;

:xortrain
	cleartrain
	addtrain >a 0.0 a!+ 0.0 a!+ 0.0 a!+	
	addtrain >a 0.0 a!+ 1.0 a!+ 1.0 a!+	
	addtrain >a 1.0 a!+ 0.0 a!+ 1.0 a!+	
	addtrain >a 1.0 a!+ 1.0 a!+ 0.0 a!+		
	;
	
:
	nnmem
	nnini
	xortrain
	
	"r3sdl" 800 600 SDLinit
	bfont1
	
	'main SDLShow
	SDLquit 
	;	
	