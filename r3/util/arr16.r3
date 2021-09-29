| Array 16 vals
| PHREDA 2021
| uso
| #list 0 0 | last first
| cnt 'list p.ini | create list
|------
^r3/lib/mem.r3

::p.ini | cantidad list --
	here dup rot !+ ! 7 << 'here +! ;

::p.clear | list --
	dup 8 + @ swap ! ;

::p.cnt | list -- cnt
	@+ swap @ | last fist
	- 7 >> ;

::p.nro | nro list -- adr
	8 + @ swap 7 << + ;

::p!+ | 'act list -- adr
	dup >r @ !+
	128 r> +! ;

::p! | list -- adr
	dup >r @
	128 r> +! ;

:delp | list end now -- list end- now-
	nip over @ | recalc end!!
	128 - 2dup 16 move
	dup pick3 !
	swap 128 - ;

::p.draw | list --
	dup @+ swap @
	( over <?
		dup @+ ex 0? ( drop delp )
		128 + ) 3drop ;

::p.del | adr list --
	>r r@ @ 128 - 16 move -128 r> +! ; | not mix
|	dup @ 128 - swap ! ; | mix

::p.nnow | adr list -- adr nro
	8 + @ | adr first 
	- 7 >> ;

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
