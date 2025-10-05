| MATH extended precision
| PHREDA 2025
^r3/lib/console.r3
^r3/lib/math.r3

|---- fixed point 32.32
::x*	| a b -- c
	24 *>> dup 63 >> - ;

::x/	| a b -- c
	24 <</ ;

::xint 24 >> ;
::xfix 24 << ;
	
::xceil	| a -- a
	$ffffff + xint ;


:str>xp | "" -- xp
	;
:xp>str | xp -- ""
	;
	

:main
	.cls
	0 ( 1.0 <?
		dup "%f " .print
		dup exp. "%f  " .print
		dup exp. "%f " .print
		.cr
		0.25 + ) drop
	;
		
: main waitesc ;
