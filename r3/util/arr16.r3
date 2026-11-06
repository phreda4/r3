| Array 16 vals - PHREDA 2021
| 
| #l 0 0 | last first
|
| cnt 'l p.ini	| create list
| 'l p.clear 	| remove all
| 'l p.cnt 		| cnt
| 've 'l p!+	| add exe and give adr for add parameters
| 'l p!			| give adr (first)
| 'l p.draw		| traverse exe every ( return 0 for delete )
| 'l p.drawo	| traverse exe every ( return 0 for delete in order )
| 'a 'l p.del	| delete 
| n 'l p.adr 	| nro -- adr 
| 'a 'l p.nro	| adr -- nro
| 'v 'l p.mapv	| exe v for every
| 'v 'l p.mapd	| exe v for every (ret 0 when delete row)
| 'v 'l p.map2	| exe v for every pair (triangle traverse)
| c 'l p.sort	| sort for c column (1pass)
| c 'l p.isort	| reverse sort for c column (1pass)
|----------------------------------------------------------

^r3/lib/mem.r3

::p.ini | cnt list -- ; initialize the list (two cells: end and start) and reserve at here room for cnt records of 16 cells (128 bytes)
	here dup rot !+ ! 7 << 'here +! ;

::p.clear | list -- ; empty the list
	dup 8 + @ swap ! ;

::p.cnt | list -- cnt ; number of records
	@+ swap @ - 7 >> ;

::p.adr | nro list -- adr ; address of record nro (0 is the first)
	8 + @ swap 7 << + ;

::p.nro | adr list -- nro ; number of the record at adr
	8 + @ - 7 >> ;

::p!+ | 'act list -- adr ; add a record whose first cell is 'act and return the address of its second cell, where the parameters go
	dup >r @ !+ 128 r> +! ;

::p! | list -- adr ; add a record and return its address (first cell)
	dup >r @ 128 r> +! ;

|---- borra desordenado (mas rapido)
:delp | list end now -- list end- now-
	nip over @ | recalc end!!
	128 - 2dup 16 move
	dup pick3 !
	swap 128 - ;

::p.draw | list -- ; execute the first cell of every record: the word receives the address of the record and must consume it; if it leaves a 0 the record is deleted (the last record takes its place)
	dup @+ swap @
	( over <?
		dup dup @ ex 0? ( drop delp )
		128 + ) 3drop ;
		
|---- borra ordenado!!
:delpo | list end now --
	dup dup 128 +
	pick3 over - 3 >> move
	swap 128 - dup pick3 !
	swap 128 - ;

::p.drawo | list -- ; like p.draw but deleting keeps the order (the next records move down)
	dup @+ swap @
	( over <?
		dup dup @ ex 0? ( drop delpo )
		128 + ) 3drop ;
	
::p.del | adr list -- ; delete the record at adr (the last record takes its place)
	>r r@ @ 128 - 16 move -128 r> +! ; | not mix
|	dup @ 128 - swap ! ; | mix

::p.mapv | 'vector list -- ; execute 'vector for every record with its address on the stack; the word must leave it there
	@+ swap @
	( over <?
		pick2 ex
		128 + ) 3drop ;

::p.mapd | 'vector list -- ; like p.mapv deleting the records for which the vector leaves a 0 (BUG: it calls the deleting code with 'vector instead of the list, so deleting ends in a segmentation fault)
	@+ swap @
	( over <?
		pick2 ex 0? ( drop dup delp )
		128 + ) 3drop ;

::p.map2 | 'vec 'list -- ; execute 'vec for every pair of records (the first with each one after it) with the two addresses on the stack
	@+ swap @
	( over <?
		dup 128 + ( pick2 <?
			pick3 ex
			128 + ) drop
		128 + ) 3drop ;
		
|------- sort by column
| only 1 pass, not full order
| if sort in every frame yo get full order array!

:up | adr -- adr ; swap 64 -
	dup dup 128 - >a | p1 r:p2
	16 ( 1? 1 - swap
		a@ over @ a!+ swap !+
		swap )
	2drop ;

::p.sort | col 'list -- ; one pass of a bubble sort, ascending, by the cell col of the records (call it every frame to get the whole order)
	@+ swap @ swap 128 - | first last
	( over >?
		dup 128 -
		pick3 3 << + @
		over pick4 3 << + @
		>? ( drop up dup ) drop
		128 - ) 3drop ;

::p.isort | col 'list -- ; like p.sort but descending
	@+ swap @ swap 128 - | first last
	( over >?
		dup 128 -
		pick3 3 << + @
		over pick4 3 << + @
		<? ( drop up dup  ) drop
		128 - ) 3drop ;
		
