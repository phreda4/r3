| Array 8 vals
| PHREDA 2017,2018
|------
^r3/lib/mem.r3

::p.ini | cantidad list --
	here dup rot !+ ! 6 << 'here +! ;

::p.clear | list --
	dup 8 + @ swap ! ;

::p!+ | 'act list -- adr
	dup >r @ !+
	64 r> +! ;

::p! | list -- adr
	dup >r @
	64 r> +! ;

|---- borra desordenado (mas rapido)
:delp | list end now -- list end- now-
	nip over @ | recalc end!!
	64 - 2dup 8 move
	dup pick3 !
	swap 64 - ;

::p.draw | list --
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

::p.drawo | list --
	dup @+ swap @
	( over <?
		dup @+ ex 0? ( drop delpo )
		64 + ) 3drop ;

::p.nro | nro list -- adr
	8 + @ swap 6 << + ;

::p.last | nro list -- adr
	@ 64 - ;

::p.cnt | list -- cnt
	@+ swap @ | last fist
	- 6 >> ;

::p.cpy | adr 'list --
	dup @ rot 8 move
	64 swap +! ;

::p.del | adr list --
	>a a@ 64 - 8 move a> dup @ 64 - swap ! ;

::p.mapv | 'vector list --
	@+ swap @
	( over <?
		pick2 ex
		64 + ) 3drop ;

::p.mapd | 'vector list --
	@+ swap @
	( over <?
		pick2 ex 0? ( drop dup delp )
		64 + ) 3drop ;

::p.mapi | 'vector fin ini list --
	8 + @
	rot 6 << over +
	rot 6 << rot +
	( over <?
		pick2 ex
		64 + ) 3drop ;

::p.deli | fin ini list --
	8 + @
	rot 6 << over +
	rot 6 << rot +
	( over <?
		dup delp
		64 + ) 3drop ;
