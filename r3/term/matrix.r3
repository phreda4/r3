| matrix effect
| PHREDA 2025
^r3/lib/rand.r3
^r3/lib/console.r3

#column

:agecolor | age -- age color 
	dup 2 >> 6 * 16 + ;

:drawc | col age n -- col age n
	2dup + 
	-? ( drop ; ) rows >? ( drop ; )
	pick3 swap 1+ .at
	agecolor .fc
	dup 1? ( 94 randmax nip ) 32 + .emit ;

:drawrow | age -- age
	0 ( 24 <? 
		drawc
		1+ ) drop ;
	
:drawscreen
	column >a
	0 ( cols <?
		ca@ 
		rows >? ( drop 10 randmax 10 - 24 - )
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
	.reset .cls
	column >a
	cols ( 1? 1-
		rows 24 + randmax 24 - ca!+
		) drop ;
		
: 
.hidec
here 'column !
'reset .onresize
reset
main 
.reset .free ;