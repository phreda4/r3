|Julian dates library
|Algorithm: http://mathforum.org/library/drmath/view/51907.html
|MC 2010
|------------------------------------------------------------
| date2jul: day month year -> juliandate
| jul2date: juliandate -> day month year
| date2day: day month year -> day of the week as an integer (0:monday, 6:sunday)
| jul2day: juliandate -> day of the week as an integer (0:monday, 6:sunday)
| date2daystr: day month year -> day of the week as a (pointer to) string
| jul2daystr: juliandate -> day of the week as a (pointer to) string
|------------------------------------------------------------
^r3/win/core.r3

:4/ 2 >> ;
:4* 2 << ;

::now2jul | -- jul
	date 
	dup $ff and swap 		| d
	dup 8 >> $ff and swap	| m
	16 >> $ffff and 		| y
|...	
::date2jul | d m y -- jul 
	4800 + swap dup 14 - 12 / dup >r rot + >r        
	r@ 1461 * 4/ r> 100 + 100 / 3 * 4/ -
	swap 2 - r> 12 * - 367 * 12 / + + 32075 - ;

::jul2date | jul -- d m y 
	68569 + dup 4* 146097 / dup >r 
	146097 * 3 + 4/ - dup 1 + 4000 * 1461001 / dup >r 
	1461 * 4/ - 31 + dup 80 * 2447 / 2dup 2447 * 80 / - rot 
	drop swap dup 11 / dup >r 
	12 * neg + 2 + 
	r> r> r> 49 - 100 * + + ;

|------------------------------------------------------------
#mo "Monday"
#tu "Tuesday"
#we "Wednesday"
#th "Thursday"
#fr "Friday"
#sa "Saturday"
#su "Sunday"

#days 'mo 'tu 'we 'th 'fr 'sa 'su

::date2day | d m y -- num 
	date2jul 7 mod ;                                 

::jul2day | jul -- num 
	7 mod ;                                 	    

::date2daystr 
	date2day 3 << 'days + @ ;

::jul2daystr 
	jul2day 3 << 'days + @ ;
