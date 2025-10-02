| matrix effect
| PHREDA 2025
^r3/lib/rand.r3
^./console.r3

#column

:agecolor | age -- age color 
	0? ( 46 ; )
	3 <? ( 40 ; )
	6 <? ( 34 ; )
	10 <? ( 22 ; )
	0 ;

:drawc | col age n -- col age n
	2dup + 
	-? ( drop ; ) rows >? ( drop ; )
	pick3 swap 1+ .at
	agecolor .fc
	dup 1? ( 94 randmax nip ) 32 + .emit ;

:drawrow | age -- age
	0 ( 10 <? 
		drawc
		1+ ) drop ;
	
:drawscreen
	column >a
	0 ( cols <?
		ca@ 
		rows >? ( drop 20 randmax 20 - )
		drawrow
		1+ ca!+
		1+ ) drop ;
		
:main
	.home
	drawscreen
	.flush
	inkey [esc] =? ( drop ; ) drop
	50 ms
	main ;

:reset
	.cls
	column >a
	cols ( 1? 1-
		rows randmax ca!+
		) drop ;
		
: 
.console .hidec
here 'column !
'reset .onresize
reset
main 
.reset .free ;