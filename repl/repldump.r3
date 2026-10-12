| repldump - internal library of r3repl (not listed in mlibs, not offered by autocomplete)
| .rbegin  -- g g g g       4 guard values at the bottom of the stack
| .rdump   g g g g v1..vn --  dumps the stack to mem/repl.out
| mem/repl.out format (qwords): n, v1 .. vn   (v1 = bottom)
| .rs      -- ; prints the stack (down to the guards) and keeps it: a stack trace for your code
| n = -1 stack too large ; n = -2 the line consumed the guards (underflow)
^r3/lib/console.r3

#rn 0
#rg 0
#rbuf * 2048
#rout * 2064

::.rbegin
	$3A5C7E1F9B2D4680 dup dup dup ;

:wrfail | code --
	'rout ! 'rout 8 "mem/repl.out" save ;

:wrdump | n --
	dup 'rout !
	0 ( over <?
		over 1- over - 3 << 'rbuf + @
		over 1+ 3 << 'rout + !
		1+ ) 
	drop 1+ 3 << 'rout swap "mem/repl.out" save ;

::.rdump
	0 'rn !
	( $3A5C7E1F9B2D4680 <>?
		rn 255 >=? ( 2drop -1 wrfail ; ) drop
		rn 3 << 'rbuf + ! 1 'rn +! )
	drop 0 'rg !
	( $3A5C7E1F9B2D4680 =? drop 1 'rg +! )
	rg 3 <>? ( drop -2 wrfail ; ) drop
	rn wrdump ;

:rsback | pushes the rn stored values back, bottom first
	rn ( 1? 1- dup 3 << 'rbuf + @ swap ) drop ;

:rsprint
	mark "[ " ,s
	rn ( 1? 1- dup 3 << 'rbuf + @ "%d " ,print ) drop
	"]" ,s ,eol empty here .println ;

::.rs
	0 'rn !
	( $3A5C7E1F9B2D4680 <>?
		rn 255 >=? ( drop rsback "rs: guards not found" .println ; ) drop
		rn 3 << 'rbuf + ! 1 'rn +! )
	rsback rsprint ;
