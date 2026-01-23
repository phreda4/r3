^r3/lib/console.r3
^r3/lib/dmath.r3

:test | nro --
	dup .print "=" .print
	dup str>fnro nip log2. "%f " .print
	str>f.d nip log2.d .fd .print
	.cr
	;

:aux
$200000000 sqrt.d .fd "sqrt(2)=%s" .println
$200000000 ln.d .fd "ln(2)=%s" .println
"0.0000001" str>f.d nip 
"0.0000001" str>f.d nip +
.fd "%s" .println
2.0 ln. "%f" .println

0 ( 2.0 <?
	dup "ln2(%f)=" .print
	dup log2. "%f " .print
	dup f>.d log2.d .fd .print
	0.2 + .cr ) drop
	;
:
.cls

"0.2" test
"0.4" test
"0.6" test
"0.8" test
"1.0" test
"1.2" test
"1.4" test
"1.6" test
"1.8" test
"2.0" test


waitkey
;

