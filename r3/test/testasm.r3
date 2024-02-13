| test for vm

#cte 4
#var 

:loop 10 ( 1? 1 - ) drop ;

:conditional 
	3 'var ! 16 <? ( 2 + ) 16 <? ( var * ) ;

:add + ;

|----Boot
: 
	1 5 +
	2 3 add 
	cte * 
	loop 
	conditional ;
