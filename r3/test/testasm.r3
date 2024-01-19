
#v1
#v2 3 1 v1
#as 1


:w0 11 + [ 1 ; ] ;
:w1 v2 dup + ( 1? 1 - ) drop ;
:re 0? ( ; ) 1 - re ;
:w2 dup ;
:w3 drop ;
:w4 2 ;

: w1 w2 ;
