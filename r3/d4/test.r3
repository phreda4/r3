^r3/lib/console.r3

#var1 3

:cua dup * ;

:tt
	var1 + cua ;
	
:
2 1 over + 
tt
cua 

"hola" .print
waitesc
;
