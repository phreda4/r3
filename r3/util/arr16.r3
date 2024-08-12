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
| n 'l p.adr 	| nro to adr 
| 'a 'l p.adr	| adr to nro
| 'v 'l p.mapd	| exe v for every
| 'v 'l p.map2	| exe v for every pair (triangle traverse)
| c 'l p.sort	| sort for c column (1pass)
| c 'l p.isort	| reverse sort for c column (1pass)
|----------------------------------------------------------

^r3/lib/mem.r3

::p.ini | cantidad list --
	here dup rot !+ ! 7 << 'here +! ;

::p.clear | list --
	dup 8 + @ swap ! ;

::p.cnt | list -- cnt
	@+ swap @ - 7 >> ;

::p.adr | nro list -- adr
	8 + @ swap 7 << + ;

::p.nro | adr list -- nro
	8 + @ - 7 >> ;

::p!+ | 'act list -- adr
	dup >r @ !+ 128 r> +! ;

::p! | list -- adr
	dup >r @ 128 r> +! ;

|---- borra desordenado (mas rapido)
:delp | list end now -- list end- now-
	nip over @ | recalc end!!
	128 - 2dup 16 move
	dup pick3 !
	swap 128 - ;

::p.draw | list --
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

::p.drawo | list --
	dup @+ swap @
	( over <?
		dup dup @ ex 0? ( drop delpo )
		128 + ) 3drop ;
	
::p.del | adr list --
	>r r@ @ 128 - 16 move -128 r> +! ; | not mix
|	dup @ 128 - swap ! ; | mix

::p.mapv | 'vector list --
	@+ swap @
	( over <?
		pick2 ex
		128 + ) 3drop ;

::p.mapd | 'vector list --
	@+ swap @
	( over <?
		pick2 ex 0? ( drop dup delp )
		128 + ) 3drop ;

::p.map2 | 'vec 'list ---
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

::p.sort | col 'list --
	@+ swap @ swap 128 - | first last
	( over >?
		dup 128 -
		pick3 3 << + @
		over pick4 3 << + @
		>? ( drop up dup ) drop
		128 - ) 3drop ;

::p.isort | col 'list --
	@+ swap @ swap 128 - | first last
	( over >?
		dup 128 -
		pick3 3 << + @
		over pick4 3 << + @
		<? ( drop up dup  ) drop
		128 - ) 3drop ;
		
