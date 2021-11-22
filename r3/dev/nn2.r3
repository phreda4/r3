| Neural Network
| PHREDA 2021

^r3/win/sdl2.r3
^r3/win/console.r3
^r3/lib/mem.r3
^r3/lib/rand.r3

#numInputs 2
#numHiddenNodes 3
#numOutputs 1
    
#lr 0.1
    
#inputLayer 		| [numinputs]	
	
#hiddenLayer		|[numHiddenNodes];
#hiddenLayerBias	|[numHiddenNodes];
#hiddenWeights		|[numInputs][numHiddenNodes];
	
#outputLayer		|[numOutputs];
#outputLayerBias	|[numOutputs];
#outputWeights		|[numHiddenNodes][numOutputs];

#resultLayer		|[numOutputs];
#deltaOutput
#deltaHidden

:nnmem | memory map
	here

	dup 'inputLayer ! numInputs ncell+ 
	
	dup 'hiddenLayer ! numHiddenNodes ncell+
	dup 'hiddenLayerBias ! numHiddenNodes ncell+
	
	dup 'outputLayer ! numOutputs ncell+
	dup 'outputLayerBias ! numOutputs ncell+
	
	dup 'resultLayer ! numOutputs ncell+
	
	dup 'hiddenWeights ! numInputs numHiddenNodes * ncell+
	dup 'outputWeights ! numHiddenNodes numOutputs * ncell+

	dup 'deltaOutput ! numOutputs ncell+
	dup 'deltaHidden ! numHiddenNodes ncell+
	
	'here !
	;
    
:r-1.1	2.0 randmax 1.0 - ;
	
:iniw | cnt mem --
	>a ( 1? 1 - r-1.1 a!+ ) drop ;

:inib | cnt mem --
	>a ( 1? 1 - 1.0 a!+ ) drop ;
	
:nnini |
	rerand
	numInputs numHiddenNodes * hiddenWeights iniw
	numHiddenNodes numOutputs * outputWeights iniw
	numHiddenNodes hiddenLayerBias inib
	numOutputs outputLayerBias inib
	;

|-----------	
:sigmoid | v -- v ; activate function
	neg exp. 1.0 + 1.0 swap /. ; 			| 1 / (1 + exp(-x)); ; 0..1
|	neg 1 << exp. 1.0 + 2.0 swap /. 1.0 - ; | 2/(1+exp(-2*x)) -1 ; -1..1
	
:dsigmoid | v -- v ; derivate activate function
	1.0 over - *. ; 		| x*(1-x);	; 0..1
|	sigmoid dup *. 1.0 swap - ; 	| 1-(f(x)^2) ; -1..1	

:forwardpp
	hiddenWeights >a
	hiddenLayer
	hiddenLayerBias
	numHiddenNodes ( 1? 1 - >r
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
		numHiddenNodes ( 1? 1 -
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
		numHiddenNodes ( 1? 1 -		| output delta @delta num
			over a@+ *. b@ + b!+	| output delta @delta num 
			) 2drop
		r> ) 3drop
	
	
	outputWeights >a	
	deltaHidden 
	numHiddenNodes ( 1? 1 -
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
	numHiddenNodes ( 1? 1 - >r		| bias delta 
		@+ lr *. dup pick3 +! 			| bias delta @delta
		rot cell+ rot rot
		inputLayer >a
		numInputs ( 1? 1 -			| bias delta @delta num
			a@+ pick2 *. b@ + b!+		| bias delta 
			) 2drop
		r> ) 3drop
	;
	
:trainstep |

	forwardpp
	backwardpp
	;
	

|--------------------------------------	draw nn
#x #y

:neuroncolor | ; 0..1 -> 0..$ff
	8 >> $ff clamp0max dup 8 << over 16 << or or ;
	
:drawneuron	| 
	neuroncolor SDLColor
	10 dup x y SDLFillellipse
	;

:drawlayer | cnt layer --
	( swap 1? 1 - swap
		@+ drawneuron 
		40 'y +! ) 2drop ;
:draww | 	
:drawnn
	30 'x !
	30 'y !
	numInputs inputLayer drawlayer
	80 'x !
	30 'y !
	numHiddenNodes hiddenLayer drawlayer
	120 'x !
	30 'y !
	numOutputs outputLayer drawlayer
	;

|--------------------------------------	draw map

:dbox | color --
	SDLcolor x y 4 dup SDLFillRect ;
	
:drawmap
	10 'y !
	0 ( 1.0 <?
		200 'x !
		0  ( 1.0 <?
		
			2dup inputLayer !+ !
			forwardpp
			outputLayer @
			|neuroncolor 
			dbox

			4 'x +!
			0.01 + ) drop
		4 'y +!
		0.01 + ) drop ;
		
|----------------------------------------- MAIN		
:main
	0 SDLclear
	
	drawmap	
	drawnn
	
	SDLRedraw 
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( trainstep )
	<f2> =? ( nnini )
	drop	
	;
	
:
	nnmem
	nnini
	
	"%d " .println
	"r3sdl" 800 600 SDLinit
	'main SDLShow
	SDLquit 
	;	
	