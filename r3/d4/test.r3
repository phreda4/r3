|main
^r3/lib/console.r3

#var1 33

:cua 
	dup * ;
	

:tt
	var1 + cua 
	10 <? ( 1 + ) 
	over
	;

:
2 1 over 3 + 
"hola" over tt 
cua 
"%d" .println
128 129 130
;

