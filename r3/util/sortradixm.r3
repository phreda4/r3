| RadixSort
| PHREDA 2012
|-----------------------------------------
^r3/lib/mem.r3

#count * 1024

:inicount
	'count 0 256 dfill ;

:addcount
	'count >a 0 256
	( 1? 1- swap da@ + dup da!+ swap ) 2drop ;

:radix8bitd | cnt '2array 'destino 'vector -- cnt '2array 'destino
	>b
	inicount
	over pick3
	( 1? 1-
		swap @+ b> ex
		$ff and 2 << 'count + 1 swap d+!
		swap ) 2drop
	addcount
	over pick3 | '2array cnt
	( 1? 1-
		over @ b> ex | nbuck
		$ff and 2 << 'count +
		dup d@ 1- dup rot d!	| posicion-1
		3 << pick3 +			| '2array cnt-1 'destino
		rot	@+ rot !  			| 'hasta 'desde copia
		swap ) 2drop ;

:getvalue0	;
:getvalue8	8 >> ;
:getvalue16	16 >> ;
:getvalue24	24 >> ;
:getvalue32	32 >> ;
:getvalue40	40 >> ;
:getvalue48	48 >> ;
:getvalue56	56 >> ;

::radixsort | cnt 'array --
	here 'getvalue56 radix8bitd
	swap 'getvalue48 radix8bitd
	swap 'getvalue40 radix8bitd
	swap 'getvalue32 radix8bitd
	swap 'getvalue24 radix8bitd
	swap 'getvalue16 radix8bitd
	swap 'getvalue8 radix8bitd
	swap 'getvalue0 radix8bitd
	3drop ;

::radixsortm | cnt 'array --
	here 'getvalue56 radix8bitd
	swap 'getvalue48 radix8bitd
	swap 'getvalue40 radix8bitd
	swap 'getvalue32 radix8bitd
	swap 'getvalue24 radix8bitd
	swap 'getvalue16 radix8bitd
	3drop ;
