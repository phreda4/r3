| test for vm

#cte 4
#var 

:nouse dup * ;

:loop 10 ( 1? 1 - ) drop ;

:conditional 
	3 'var ! 16 <? ( 2 + ) 16 <? ( var * ) ;

:ncell+ 3 << + ;
:.x		1 ncell+ ;
:.vx	4 ncell+ ;

:test
	dup .vx @ over .x +!	| vx
	;
	
:add + ;

#buff * 100

|----Boot
: 
	1 5 + 2 3 add cte * 
	loop 
	conditional 
	'buff test drop
	;
