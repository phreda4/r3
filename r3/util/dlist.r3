| row of cells - PHREDA 2023
| #dc 0 0 | last first
|
| 30 'dc dc.ini | room for 30 cells (empty now)
| 'dc dc? 		| cnt of cell
| 2 'dc dcn@ 	| see n value of list
| 12 'dc dc! 	| store a val
| 'dc dc@-		| fetch a val, remove from list
| 'dc dc@		| see the first val

^r3/lib/mem.r3

::dc.ini | mac 'dc dc.ini
	here dup rot !+ ! 3 << 'here +! ;

::dc.clear | list --
	dup 8 + @ swap ! ;
	
::dc? | list -- cnt
	@+ swap @ - 3 >> ;
	
::dcn@ | n l -- v
	8 + @ swap 3 << + @ ;

::dc@ | list -- val
	dup 8 + @ @ ;

::dc! | val list --
	dup >r @ ! 8 r> +! ;
	
::dc@- | list -- val
	dup 8 + @ @ | fetch first
	swap dup @+ swap @ | last first
|	dup @ -rot
	dup 8 + rot | first first+8 last
	over - 3 >> move | dsc
	-8 swap +!
	;
