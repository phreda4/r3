| Markov Chain
| PHREDA 2025

^r3/lib/term.r3

#states 2
#trans [
	0.7 0.3
	0.2 0.8 
	]
#iniv [ 1 0 ]

#v0 
#v1
#iter 

:printvec | v --
	>a
	states ( 1? 1-
		da@+ "%f " .print
		) drop 
	.cr ;

:matmul | src dst -- 
	'trans >a
	states ( 1? 1- | src dst n 
		pick2 >b
		0
		states ( 1? 1-
			da@ db@+ *. 
			rot + swap
			states 2 << a+
			) drop | src dst n sum
		states dup * 1- 2 << neg a+
		rot d!+ | src n dst
		swap ) 3drop ;
		
:vdif | v0 v1 -- dif
	>a >b 0
	states ( 1? 1- 
		da@+ db@+ - abs | dif n dv
		pick2 >? ( -rot swap )
		drop ) drop ;
	
#MAX_ITER 200
#THRESHOLD 0.0001

:distribution
	v0 1.0 states / states dfill |dvc
	MAX_ITER ( 1? 1-
		v0 v1 matmul
		v0 v1 vdif 
		THRESHOLD <? ( 2drop ; ) drop
		v0 v1 states dmove |dsc
		) drop ;
		
:printvec | v --
	>a
	states ( 1? 1-
		da@+ "%f " .print
		) drop 
	.cr ;

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
	
	'trans printmat
|	'trans makealias
	
	|---- MEMMAP ----
	here 
	dup 'alias ! states dup * 2 << +
	dup 'v0 ! states 2 << +
	dup 'v1 ! states 2 << +
	'here !
	
	distribution
	v0 printvec
	
	.flush waitkey
	;
: main .free ;
