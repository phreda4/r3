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
	
#x
::/.g  16 >> 16 <</ ; 

:
2 tt 1 cua over 3 + 
"hola" over tt 
cua 
"%d" .println
128 129 130

.cr
  1234567890.123456789 16 <<
  dup .fd .write .cr  | 1234567890.12344360
  3.0 16 << /.d
  .fd .write .cr      | 0.04114786
  .cr

  "1234567890.123456789" 'x f32!
  x
  dup .fd .write .cr  | 1234567890.12345678
  3.0 16 << /.d
  .fd .write .cr      | 0.04115226
  .cr
  
  "1234567890.123456789" 'x f32!
  x
  dup .fd .write .cr  | 1234567890.12345678
  3.0 16 << /.g
  .fd .write .cr      | 0.04115226
  .cr


waitkey
;

