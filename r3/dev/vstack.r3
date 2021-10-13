
^r3/win/console.r3
^r3/system/r3stack.r3

:.stack
	mark ,printstk empty here .println ;

: 
"vstack test" .println
.stack
33 push.nro .stack
0 push.cte .stack
1 push.wrd .stack
1 push.var .stack
12 push.reg .stack
1 PUSH.STk  .stack
0 PUSH.CTEM	 .stack
1 PUSH.ANO  .stack
.rot .stack
.swap .stack
;