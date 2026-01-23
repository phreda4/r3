^r3/lib/console.r3
^r3/lib/rand.r3
^r3/lib/clipboard.r3
^r3/lib/dmath.r3

#var1 3

:cua dup * ;

:tt
	var1 + cua ;
	
:
.cls
2 1 over + 
tt
cua 
"hola" .println
mark here pasteclipboard empty
here .println

$200000000 sqrt.d .fd "sqrt(2)=%s" .println
$200000000 ln.d .fd "ln(2)=%s" .println
"0.0000001" str>f.d nip 
"0.0000001" str>f.d nip +
.fd "%s" .println
2.0 ln. "%f" .println

"esto es" 4 copyclipboard
( getch [esc] <>? drop
	-1 2 randminmax "%d" .println
	) drop
;

