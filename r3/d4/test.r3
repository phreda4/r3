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
2 1 over + 
tt
cua 

128 129 130
;

