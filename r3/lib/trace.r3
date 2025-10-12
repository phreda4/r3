^r3/lib/term.r3

::trace | --
	.reset
	"stack <<" .write
	pick4 .d .write .sp
	pick3 .d .write .sp 
	pick2 .d .write .sp 
	over .d .write .sp
	dup .d .write .sp 
	">>" .write .cr 
	.flush waitkey ;
	
::traceh | --
	.reset
	"stack <<" .write
	pick4 .h .write .sp
	pick3 .h .write .sp 
	pick2 .h .write .sp 
	over .h .write .sp
	dup .h .write .sp 
	">>" .write .cr 
	.flush waitkey ;

::memdump | adr cnt --
	.reset "memdump: " .write 
	"ADR:" .write  over .h .write 
	.cr
	( 1? 1- 
		swap c@+ $ff and .h .write .sp 
		swap ) 2drop 
	.cr
	.flush waitkey ;

::memdumpc | adr cnt --
	.reset "memdump char:" .write .cr
	( 1? 1- 
		swap c@+ 32 <? ( $2e nip ) .emit
		swap ) 2drop 
	.cr
	.flush waitkey ;

|----- file log 
::clearlog
	"filelog.txt" delete ;

::filelog | .. str --
	sprint count "filelog.txt" append ;
	
|----- view memory	
#memini

:showmem
	.cls
	":Memmap: [esc]exit [up] [dn] [pgup] [pgdn] :" .write 
	memini .h 8 .r. .write

	.cr
	cols "─" .rep .cr
	memini 0
	( rows 5 - <? swap
		dup .h 8 .r. .write ": " .write
		dup 32 ( 1? 1 - swap c@+ $ff and .h 2 .r. .write swap ) 2drop
		": " .write
		32 ( 1? 1 - swap c@+ 32 <? ( $2e nip ) .emit swap ) drop
		.cr
		swap 1 + ) 2drop 
	cols "─" .rep .cr		
	.flush ;
	
::memmap | inimem --
	.reset 
	'memini !
	( showmem
		getch [esc] <>? 
		[up] =? ( -32 'memini +! ) 
		[dn] =? ( 32 'memini +! )
		[pgup] =? ( -32 23 * 'memini +! ) 
		[pgdn] =? ( 32 23 * 'memini +! )		
		drop ) drop ;

#vmem
#cntbytes
	
:showmem
	.cls
	cols "─" .rep .cr
	memini 0
	( rows 5 - <? swap
		pick2 ex .cr
		swap 1 + ) 2drop 
	cols "─" .rep .cr		
	.flush ;
	 
::memmapv | 'v mem --
	.reset 
	'memini !
	memini over ex memini - 'cntbytes !
	( showmem
		getch [esc] <>? 
		[up] =? ( cntbytes neg 'memini +! ) 
		[dn] =? ( cntbytes 'memini +! )
		[pgup] =? ( cntbytes -23 * 'memini +! ) 
		[pgdn] =? ( cntbytes 23 * 'memini +! )		
		drop ) 2drop ;
	