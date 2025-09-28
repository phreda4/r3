| busqueda binaria en lista ordenada
| PHREDA 2012(r4)-2025(r3)
|---------------------------------

:cond
	pick4 <? ( drop 1+ rot drop swap ; ) drop nip ;
		
::binsearch | valor cantida 'lista -- 'adr
	>a 			| v max   r: list
	1- 0 swap			| v lo hi
	( over <>? 		| v lo hi
		2dup + 2/		| v lo hi medio
		dup 4 << a> + @ cond
		)				| v lo hi
	nip 4 << a> + dup @ rot
	=? ( drop ; )
	2drop -1 ;

::binsearch | valor cantida 'lista -- 'adr
	>a 			| v max   r: list
	1- 0 swap			| v lo hi
	( over <>? 		| v lo hi
		2dup + 2/		| v lo hi medio
		dup 4 << a> + @ cond
		)				| v lo hi
	nip 4 << a> + dup @ rot
	=? ( drop ; )
	drop 1+ neg ; | near
