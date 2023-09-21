| Heap data structure - PHREDA 2023 ( from r4 )
|
| #heap 0 0 | cnt adr
| 100 'heap heapini | max
| 2 'heap heap! | add 2 to heap
| 'heap heap@	| get first number
|
^r3/lib/mem.r3

#heapc
#heapv

:setheap | 'heap
	dup 8 + @ 'heapv ! 'heapc ! ;
	
:]heap | nro -- adr
	3 << heapv + ;

::heap! | nodo 'h --
	setheap
	heapc @ dup 1 + heapc !
	( 1? dup 1 - 1 >>	| v j i
		dup ]heap @		| v j i vi
		pick3 <? ( 2drop ]heap ! ; )
		rot ]heap !		| v i
		) drop
	heapv ! ;

:hless
	heapc @ >=? ( drop ; ) 
	]heap @					| val pos ch1 V1 V2
	<=? ( ; )
    drop 1 + dup ]heap @	| val pos chm Vm
	;

:moveDown | nodo pos --
	( heapc @ 1 >> <? 
		dup 1 << 1 +		| val pos ch1
		dup ]heap @			| val pos ch1 v1
		over 1 +			| val pos ch1 v1 ch2
		hless
		pick3 				| value pos chM vM va
		>=? ( 2drop ]heap ! ; )		| value pos chM vM
		rot over swap ]heap !	| value chM vM
		drop )
	]heap ! ;

::heap@ | 'h -- nodo
	setheap
	heapv @ heapc @
	1 - ]heap @ 0 MoveDown
	-1 heapc +!
	;

::heapini | max 'h --
	0 swap !+
	here swap !
	3 << 'here +! ;
