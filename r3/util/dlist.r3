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

::dc.ini | max 'dc -- ; initialize the list (count and start) with room for max values of 8 bytes at here
	here dup rot !+ ! 3 << 'here +! ;

::dc.clear | list -- ; empty the list
	dup 8 + @ swap ! ;
	
::dc? | list -- cnt ; number of values
	@+ swap @ - 3 >> ;
	
::dcn@ | n list -- v ; value number n (0 is the first)
	8 + @ swap 3 << + @ ;

::dc@ | list -- val ; first value (no check for an empty list)
	dup 8 + @ @ ;

::dc! | val list -- ; append the value at the end
	dup >r @ ! 8 r> +! ;
	
::dc@- | list -- val ; remove and return the first value, the others move down (no check for an empty list)
	dup 8 + @ @ | fetch first
	swap dup @+ swap @ | last first
|	dup @ -rot
	dup 8 + rot | first first+8 last
	over - 3 >> move | dsc
	-8 swap +!
	;
