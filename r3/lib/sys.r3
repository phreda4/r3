| SYSTEM
| PHREDA 2019
|----------------
^r3/lib/key.r3

##path * 1024

| extrat path from string, keep in path var
::getpath | str -- str
	'path over
	( c@+ $ff and 32 >=?
		rot c!+ swap ) 2drop
	1 -
	( dup c@ $2f <>? drop
		1 - 'path <=? ( 0 'path ! drop ; )
		) drop
	0 swap 1 + c! ;

::blink | -- 0/1
	msec $100 and ;

|--- copy and restore registers A B, to system?
::pushab | --
	r> >a >r b> >r >r ;
	
::popba | --
	r> r> >b r> >a >r ;
