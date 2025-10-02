| matrix effect
| PHREDA 2025
^r3/lib/rand.r3
^./console.r3

#column_age 

:agecolor | age -- age color 
	0? ( 46 ; )
	3 <? ( 40 ; )
	6 <? ( 34 ; )
	10 <? ( 22 ; )
	0 ;

:drawc | col col_age row age --
	pick3 pick2 1+ rows >? ( 2drop ; ) .at
	agecolor .fc
	1? ( 94 randmax nip )
	32 + dup .emit ;
		
:drawrow | age -- age
	0 ( rows <? 
		dup pick2 - | col col_age row age
		0 10 in? ( drawc ) 
		drop 
		1+ ) drop ;
	
:newcol
	50 randmax 1? ( drop ; ) drop | 2%
	drop 0 dup ca! ;
	
:drawscreen
	column_age >a
	0 ( cols <?
		ca@ 
		rows >? ( newcol )
		drawrow
		1+ ca!+
		1+ ) drop ;
		
:main
	.cls
	drawscreen
	.flush
	inkey [esc] =? ( drop ; ) drop
	100 ms
	main ;

: .console .hidec 
here 'column_age !
cols 'here +!
column_age 100 cols cfill
main 
.reset .free ;