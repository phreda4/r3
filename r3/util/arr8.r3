| Array 8 vals PHREDA 2017,2018
| 
| #l 0 0 | last first
|
| cnt 'l p8.ini	| create list
| 'l p8.clear 	| remove all
| 'l p8.cnt 	| cnt
| 've 'l p8!+	| add exe and give adr for add parameters
| 'l p8!			| give adr (first)
| 'l p8.draw		| traverse exe every ( return 0 for delete )
| 'l p8.drawo	| traverse exe every ( return 0 for delete in order )
| 'a 'l p8.del	| delete 
| n 'l p8.adr 	| nro -- adr 
| 'a 'l p8.nro	| adr -- nro
| 'v 'l p8.mapv	| exe v for every
| 'v 'l p8.mapd	| exe v for every (ret 0 when delete row)
| 'v 'l p8.map2	| exe v for every pair (triangle traverse)
| c 'l p8.sort	| sort for c column (1pass)
| c 'l p8.isort	| reverse sort for c column (1pass)
|----------------------------------------------------------

^r3/lib/mem.r3

::p8.ini | cnt list -- ; initialize the list (two cells: end and start) and reserve at here room for cnt records of 8 cells (64 bytes)
	here dup rot !+ ! 6 << 'here +! ;

::p8.clear | list -- ; empty the list
	dup 8 + @ swap ! ;

::p8.cnt | list -- cnt ; number of records
	@+ swap @ - 6 >> ;

::p8.adr | nro list -- adr ; address of record nro (0 is the first)
	8 + @ swap 6 << + ;

::p8.nro | adr list -- nro ; number of the record at adr
	8 + @ - 6 >> ;

::p8!+ | 'act list -- adr ; add a record whose first cell is 'act and return the address of its second cell, where the parameters go
	dup >r @ !+ 64 r> +! ;

::p8! | list -- adr ; add a record and return its address (first cell)
	dup >r @ 64 r> +! ;

|---- borra desordenado (mas rapido)
:delp | list end now -- list end- now-
	nip over @ | recalc end!!
	64 - 2dup 8 move
	dup pick3 !
	swap 64 - ;

::p8.draw | list -- ; execute the first cell of every record: the word receives the address of the cell after it and must consume it; if it leaves a 0 the record is deleted (the last record takes its place)
	dup @+ swap @
	( over <?
		dup @+ ex 0? ( drop delp )
		64 + ) 3drop ;

|---- borra ordenado!!
:delpo | list end now --
	dup dup 64 +
	pick3 over - 3 >> move
	swap 64 - dup pick3 !
	swap 64 - ;

::p8.drawo | list -- ; like p8.draw but deleting keeps the order (the next records move down)
	dup @+ swap @
	( over <?
		dup @+ ex 0? ( drop delpo )
		64 + ) 3drop ;

::p8.del | adr list -- ; delete the record at adr (the last record takes its place)
	>a a@ 64 - 8 move a> dup @ 64 - swap ! ;

::p8.last | list -- adr ; address of the last record
	@ 64 - ;

::p8.cpy | adr 'list -- ; append a copy of the record at adr
	dup @ rot 8 move 64 swap +! ;

::p8.mapv | 'vector list -- ; execute 'vector for every record with its address on the stack; the word must leave it there
	@+ swap @
	( over <?
		pick2 ex
		64 + ) 3drop ;

::p8.mapd | 'vector list -- ; like p8.mapv deleting the records for which the vector leaves a 0 (BUG: it calls the deleting code with 'vector instead of the list, so deleting ends in a segmentation fault)
	@+ swap @
	( over <?
		pick2 ex 0? ( drop dup delp )
		64 + ) 3drop ;

::p8.map2 | 'vec 'list -- ; execute 'vec for every pair of records (the first with each one after it) with the two addresses on the stack
	@+ swap @
	( over <?
		dup 64 + ( pick2 <?
			pick3 ex
			64 + ) drop
		64 + ) 3drop ;

|------- sort by column
| only 1 pass, not full order
| if sort in every frame yo get full order array!

:up | adr -- adr ; swap 64 -
	dup dup 64 - >a | p1 r:p2
	8 ( 1? 1 - swap
		a@ over @ a!+ swap !+
		swap )
	2drop ;

::p8.sort | col 'list -- ; one pass of a bubble sort, ascending, by the cell col of the records (call it every frame to get the whole order)
	@+ swap @ swap 64 - | first last
	( over >?
		dup 64 -
		pick3 3 << + @
		over pick4 3 << + @
		>? ( drop up dup ) drop
		64 - ) 3drop ;

::p8.isort | col 'list -- ; like p8.sort but descending
	@+ swap @ swap 64 - | first last
	( over >?
		dup 64 -
		pick3 3 << + @
		over pick4 3 << + @
		<? ( drop up dup  ) drop
		64 - ) 3drop ;
		
