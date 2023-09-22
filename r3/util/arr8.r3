| Array 8 vals
| PHREDA 2017,2018
|------
^r3/lib/mem.r3

::p8.ini | cantidad list --
	here dup rot !+ ! 6 << 'here +! ;

::p8.clear | list --
	dup 8 + @ swap ! ;

::p8!+ | 'act list -- adr
	dup >r @ !+
	64 r> +! ;

::p8! | list -- adr
	dup >r @
	64 r> +! ;

|---- borra desordenado (mas rapido)
:delp | list end now -- list end- now-
	nip over @ | recalc end!!
	64 - 2dup 8 move
	dup pick3 !
	swap 64 - ;

::p8.draw | list --
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

::p8.drawo | list --
	dup @+ swap @
	( over <?
		dup @+ ex 0? ( drop delpo )
		64 + ) 3drop ;

::p8.nro | nro list -- adr
	8 + @ swap 6 << + ;

::p8.last | nro list -- adr
	@ 64 - ;

::p8.cnt | list -- cnt
	@+ swap @ | last fist
	- 6 >> ;

::p8.cpy | adr 'list --
	dup @ rot 8 move
	64 swap +! ;

::p8.del | adr list --
	>a a@ 64 - 8 move a> dup @ 64 - swap ! ;

::p8.mapv | 'vector list --
	@+ swap @
	( over <?
		pick2 ex
		64 + ) 3drop ;

::p8.mapd | 'vector list --
	@+ swap @
	( over <?
		pick2 ex 0? ( drop dup delp )
		64 + ) 3drop ;

::p8.mapi | 'vector fin ini list --
	8 + @
	rot 6 << over +
	rot 6 << rot +
	( over <?
		pick2 ex
		64 + ) 3drop ;

::p8.deli | fin ini list --
	8 + @
	rot 6 << over +
	rot 6 << rot +
	( over <?
		dup delp
		64 + ) 3drop ;
