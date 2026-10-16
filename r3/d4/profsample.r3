| ejemplo para profdemo
^r3/lib/console.r3

:fib | n -- f
	2 <? ( ; ) 1- dup fib swap 1- fib + ;

:suma | n -- s
	0 swap ( 1? dup rot + swap 1- ) drop ;

:dos 2 + ;

: 24 fib "%d" .println
	100000 suma "%d" .println
	3 dos "%d" .println ;
