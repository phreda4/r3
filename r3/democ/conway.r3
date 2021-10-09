| Conway Game of Life
| PHREDA 2021
^r3/win/console.r3
^r3/lib/rand.r3

#arena 
#arenan

:check | adr -- adr 
	dup cols - 1 - >a	ca@+ ca@+ + ca@ + 
	over 1 - >a			ca@+ + 1 a+ ca@ +
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
			check 1 + rot rot 
			1 + ) drop
		1 + ) 2drop 
	arena arenan cols rows * move ;
	
:drawscreen
	.home
	arena >a
	0 ( rows <? 
		0 ( cols <? 
			.Reset ca@+ 1? ( .Rever ) drop 
			" " 1 type
			1 + ) drop
			cr
		1 + ) drop ;
	
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
	( getch 27 <>? drop
		drawscreen
		evolve
		) drop ;

: 
	.getconsoleinfo
	here cols + 			| one more line for calc
	dup 'arena !			| start of arena
	rows cols * + 'arenan !	| copy of arena
	.alsb .hidec		
	main
	.masb .showc
	;