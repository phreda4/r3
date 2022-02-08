^r3/win/console.r3

:pext | x mask -- res
	0 >a 
	1 swap | x b mask
	( 1? 
		pick2 over dup neg and and
		1? ( pick2 a+ ) drop
		dup 1 - and
		swap dup + swap
		) 3drop
	a> ;

	
:pdep | x mask -- res
	0 >a
	( dup dup neg and | x mask lsb
		1? 
		pick2 63 << 63 >>
		over and a+
		not and
		swap 1 >> swap ) 3drop
	a> ;
	
:
 .cls
 $12345678 $ff00fff0 pext
 "$12345678 $ff00fff0 pext -- %h" .println
 
 $12567 $ff00fff0 pdep
 "$12567 $ff00fff0 pdep -- %h" .println 
	;