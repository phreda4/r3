| Conway Game of Life
| PHREDA 2021
^r3/lib/console.r3
^r3/lib/mconsole.r3
^r3/lib/rand.r3

#arena 
#arenan

:check | adr -- adr 
	dup cols - 1 - >a	
	ca@+ ca@+ + ca@ + 
	over 1 - >a	
	ca@+ + 1 a+ ca@ +
	over cols + 1 - >a	ca@+ + ca@+ + ca@ + 	| calc 
	3 =? ( drop 1 cb!+ ; )
	2 <>? ( drop 0 cb!+ ; ) 
	drop
	dup c@ cb!+ ;
	
:evolve
	arenan >b
	arena
	0 ( rows <? 
		0 ( cols <? 
			rot 
			check 1 + -rot 
			1 + ) drop
		1 + ) 2drop 
	arena arenan cols rows * cmove 
	;
	
:cbox
	1? ( ,rever ; ) ,reset ;

:drawscreen
	mark
	,cls
	arena >a
	0 ( rows <? 
		0 ( cols <? 
			ca@+ cbox drop ,sp
			1 + ) drop
		,nl
		1 + ) drop 
	memsize type 
	empty ;
	
:arenarand
	arena >a
	0 ( rows <? 
		0 ( cols <? 
			rand 9 >> 1 and ca!+
			1 + ) drop
		1 + ) drop ;

:main
	.cls
	arenarand
	( inkey $1B1001 <>? drop
		drawscreen
		evolve
		) drop ;

: 
	.getconsoleinfo
	here 1 + cols + 			| one more line for calc
	dup 'arena !			| start of arena
	rows cols * + dup 'arenan !	| copy of arena
	rows cols * + 'here !
	.alsb .hidec		
	main
	.masb .showc
	;