|main
^r3/lib/console.r3
^r3/lib/dmath.r3

#var1 33

:cua 
	dup * ;
	
:tt 
	var1 + cua 
	10 <? ( 1 + ) 
	over
	;

#v

::/.g   16 >> swap 16 << swap / ;
:
2 tt 1 cua over 3 + 
"hola" over tt 
cua 
"%d" .println
128 129 130

.cr
1234567890.123456789 16 <<
dup
.fd .write .cr
3.0 16 << /.d
.fd .write .cr
.cr

"1234567890.123456789" 'v f32!
v
dup
.fd .write .cr
3.0 16 << /.d
.fd .write .cr
.cr

"1234567890.123456789" 'v f32!
v
dup
.fd .write .cr
3.0 16 << /.g
.fd .write .cr
.cr

waitkey
;

