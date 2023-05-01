| list of cells - PHREDA 2023
| #dc 0 0 | last first
|
| 30 'dc dc.ini | room for 30 cells (empty now)

^r3/lib/mem.r3

::dc.ini | mac 'dc dc.ini
	here dup rot !+ ! 3 << 'here +! ;

::dc.clear | list --
	dup 8 + @ swap ! ;
	
::dc? | list -- cnt
	@+ swap @ - 3 >> ;
	
::dc.n | n l -- v
	8 + @ swap 3 << + @ ;

::dc! | val list --
	dup >r @ ! 8 r> +! ;
	
::dc@ | list -- val
	dup 8 + @ @ | fetch first
	swap dup @+ swap @ | last first
	dup 8 + rot | first first+8 last
	over - 3 >> move | dsc
	-8 swap +!
	;
	
