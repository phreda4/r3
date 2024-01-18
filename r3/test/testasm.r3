
#v1
#v2 3 1 v1
#as 1

:w0 11 + [ 1 ; ] ;

:lista 'w0 ex 'v1 v2 ;

:w1
	v2 dup + 
	( 1? 1 - ) drop ;
:re
	0? ( ; ) 1 - re ;

:w2 0? ( ; ) 2 ;

: v1 'w2 ex w1 lista ;
