| test for vm

#cte 4
#var 

:loop 10 ( 1? 1 - ) ;

:conditional 
	3 'var ! 16 <? ( 2 + ) 16 <? ( var * ) ;

:test*
	var
	dup 3 * drop
	dup 4 * drop
	dup 5 * drop
	dup 6 * drop
	;
	
:add + ;

|----Boot
: 
	1 5 +
	2 3 add 
	cte * 
	loop 
	conditional 
	test*
	;
