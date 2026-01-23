^r3/lib/console.r3
^r3/lib/rand.r3
^r3/lib/clipboard.r3

#var1 3

:cua dup * ;

:tt
	var1 + cua ;
	
:
2 1 over + 
tt
cua 
"hola" .println
mark here pasteclipboard empty
here .println

"esto es" 4 copyclipboard
( getch [esc] <>? drop
	-1 2 randminmax "%d" .println
	) drop
;

