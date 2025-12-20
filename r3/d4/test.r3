^r3/lib/console.r3
^r3/lib/rand.r3

#var1 3

:cua dup * ;

:tt
	var1 + cua ;
	
:
2 1 over + 
tt
cua 
getch drop
"hola" .print
getch drop
( getch [esc] <>? drop
	-1 2 randminmax "%d" .println
	) drop
;
