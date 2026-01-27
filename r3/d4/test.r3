
^r3/lib/console.r3

#var1 33

:cua dup * ;

:tt
	var1 + cua ;

:
2 1 over + 
tt
cua 
"%d" .println
128 129 130
;

