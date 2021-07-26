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

::date2jul 4800 + swap dup 14 - 12 / dup >r rot + >r        | ( d m y - jul )
	  r@ 1461 * 4 / r> 100 + 100 / 3 * 4 / -
	  swap 2 - r> 12 * - 367 * 12 / + + 32075 - ;

|------------------------------------------------------------

:_p 68569 + ;
:_q 4 * 146097 / ;
:_r 146097 * 3 + 4 / - ;
:_s 1 + 4000 * 1461001 / ;
:_t 1461 * 4 / - 31 + ;
:_u 80 * 2447 / ;
:_v 11 / ;

:_m 12 * neg + 2 + ;
:_d 2447 * 80 / - ;
:_y 49 - 100 * + + ;

::jul2date _p dup _q dup >r _r dup _s dup >r _t             | ( jul - d m y )
	   dup _u 2dup _d rot drop swap dup _v dup >r _m
	   r> r> r> _y ;

|------------------------------------------------------------

#mo "Monday"
#tu "Tuesday"
#we "Wednesday"
#th "Thursday"
#fr "Friday"
#sa "Saturday"
#su "Sunday"

#days 'mo 'tu 'we 'th 'fr 'sa 'su

::date2day date2jul 7 mod ;                                 | ( d m y - num )

::jul2day 7 mod ;                                 	    | ( d m y - num )

::date2daystr date2day 2 << 'days + @ ;

::jul2daystr jul2day  'days + @ ;
