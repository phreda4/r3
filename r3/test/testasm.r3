| test for vm

:loop 10 ( 1? 1 - ) drop ;

:conditional 16 <? ( 2 + ) 16 <? ( 5 * ) ;

:add + ;

|----Boot
: 
	2 3 add 
	3 * 
	loop 
	conditional ;
