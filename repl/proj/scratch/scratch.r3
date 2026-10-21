| r3repl - project scratch
^r3/lib/rand.r3

#board
0 0 0
0 0 0
0 0 0
:cell | a -- b
	3 <<
	'board + ;

:put | ab -- 
	cell ! ;

:get | a -- b
	cell @ ;

:.c | a -- 
	".XO" +
	c@ .emit ;

:.row | a -- 
	3 *
	dup 3 +
	swap (
		over <?
		dup get .c
		.sp 1+
	) 2drop .cr ;

:.board |  -- 
	0 (
		3 <?
		dup .row
		1+
	) drop ;

:ia |  -- a
	9 randmax dup get 0 <>? (
		2drop ia ;
	) 2 swap put ;

