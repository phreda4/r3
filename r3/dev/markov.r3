^r3/lib/term.r3

#MAX_ITER 200
#THRESHOLD 0.001

#states 4
#trans [
0.1 0.3 0.4 0.2
0.2 0.2 0.3 0.3
0.4 0.1 0.3 0.2
0.3 0.3 0.2 0.2
]

#pi * 32 |[N] = {SCALE/N, SCALE/N, SCALE/N, SCALE/N};
#new_pi * 32 |[N];
#iter 

|void matrix_vector_mult_shift(long long pi[N], long long new_pi[N]) {
|mdif=0;
|for (int j = 0; j < N; j++) {
|	long sum = 0;
|	for (int i = 0; i < N; i++) {
|		sum += (pi[i] * P_shift_scaled[i][j]) >> 24; 
|		}
|	new_pi[j] = sum;
|	ndif=abs(p[j]-sum);
|	if (mdif<ndif) mdif=ndif;
|	}
:matmul | dst src -- diff
	>a >b
	0 states ( 1? 1-
		
		) drop
	;
	
| Bucle de iteración (Método de Potencias)
#MAX_ITER 100
:distribution
	0.25 0.25 0.25 0.25 'pi d!+ d!+ d!+ d!
	MAX_ITER ( 1? 1-
		'new_pi 'pi matmul
		THRESHOLD <? ( 2drop ; ) drop
		'new_pi 'pi 4 dmove |dsc
		) drop ;
		

|------------------------------
#alias 

:makealiasv | 'trans 'alias -- 'alias
	nip
	;

:makealias | 'trans -- 
	alias >a
	0 ( states <?
		dup "state:%d : " .print
		swap
		dup states ( 1? swap
			d@+ "%f " .print
			swap 1- ) 2drop
		.cr
		dup a> makealiasv >a
		states 2 << +
		swap 1+ ) drop ;

:printmat | adr --
	>a
	states ( 1?
		states ( 1?
			da@+ "%f " .print
			1- ) drop
		.cr
		1- ) drop
	;
	
	
:main
	"markov chain" .fprintln
	
	'trans |printmat
	makealias
	
	here 'alias !
	states dup * 2 << 'here +!
	
	
	.flush waitkey
	;
: main .free ;
