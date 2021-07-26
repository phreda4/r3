| SYSTEM
| PHREDA 2019
|----------------
^r3/lib/key.r3

#.exit 0

::onshow | 'word --
	0 '.exit !
	( .exit 0? drop
		SDLupdate
		dup ex
		SDLredraw ) 2drop
	0 '.exit ! ;

::exit
	1 '.exit ! ;

:wk
	SDLkey >esc< =? ( exit ) drop ;

::waitesc
	'wk onshow ;

#mwait

::framelimit | fps --
	( SDL_GetTicks mwait <? drop )
	1000 rot / + 'mwait !
	;

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
	SDL_GetTicks $100 and ;

