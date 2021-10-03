| ShellSort
| PHREDA 2009
|-----------------------------------------
#trylist [ 2391484 797161 265720 88573 29524 9841 3280 1093 364 121 40 13 4 1 0 ]
#pl

:xch | j i -- j i
	over 1 - 4 << pl + 		| j i dj
	over 1 - 4 << pl + >a	| j i dj di r:di
	a@ over @ 				| j i dj vi vj
	a!+ swap !+				| j i dj+ r:di+
	a@ over @
	a! swap ! ;

|--------------------
:sort | len h i v j -- len h i
	( pick3 >?
      	dup pick4 - 		| len h i v j j-h
		dup 1 - 4 << pl + @ 	| len h i v j j-h list[j-h]
		pick3 <=? ( 4drop ; )
		drop xch nip )
	2drop ;

::shellsort | len lista -- ; lista es valor-dato
	'pl !
	'trylist
	( d@+ 1? dup 			| len h i
		( pick3 <?
			dup 1 - 4 << pl + @	| list[i]=v
			over 				| len h i v j
			sort 1 + )
		2drop )
	3drop ;

|--------------------
:sort | len h i v j -- len h i
	( pick3 >?
      	dup pick4 - 		| len h i v j j-h
		dup 1 - 4 << pl + 8 + @ 	| len h i v j j-h list[j-h]
		pick3 <=? ( 4drop ; )
		drop xch nip )
	2drop ;

::shellsort2 | len lista -- ; lista es dato-valor
	'pl !
	'trylist
	( d@+ 1? dup 			| len ty h i
		( pick3 <?
			dup 1 - 4 << pl + 8 + @	| list[i]=v
			over 				| len h i v j
			sort 1 + )
		2drop )
	3drop ;

|-------------------- string
| a<b -- -
| a=b -- 0
| a>b -- +
:cmpstr | a b -- a c
	over 1 - 3 << pl + @
	swap 1 - 3 << pl + @		| a aS bS
	( c@+ 1? $ff and rot	| a bS b1 aS
		c@+ $ff and rot -	| a bS aS a1-b1
		-? ( nip nip ; )
		1 - +? ( nip nip 1 + ; )	| 0 pasa
		drop swap )
	rot c@ - 0? ( nip ; )	| a bS b1 a1
	2drop 1 ;

:sort | len t1 h i -- len t1 h i
	( over >? 	|
      	dup pick2 -	| len t1 h i i-h
		over cmpstr 1 -	| <= ; len t1 h i i-h s
		-? ( 2drop ; ) drop
		xch nip ) ;

::sortstr | len lista -- ; lista es pstr-valor
	'pl ! 1 +
	'trylist
	( d@+ 1? dup 			| len tl h i
		( pick3 <? sort 1 + )
		2drop )
	3drop ;

