| print palindrome numbers
^r3/win/console.r3

|         0  4  8   12
#sdlbox [ 10 10 630 470 ]

:.printbox
	'sdlbox
	d@+ "x:%d " .print
	d@+ "y:%d " .print	
	d@+ "w:%d " .print
	d@+ "h:%d " .println drop ;
	
|--- ratio adjust
:setbox | hn wn --
	a> 8 + d@ over - 1 >> a> d+! | padx
	a> 12 + d@ pick2 - 1 >> a> 4 + d+! | pady
	8 a+
	da!+ da!+ ;
	
:ratio2 | w h hx --
	drop
	a> 12 + d@ swap rot */ 	| WN
	a> 12 + d@ swap
	setbox 
	"r2" .println ;
	
::64boxratio | 64wh 'box -- ; adjust box by ratio and pad!
	>a
	dup 32 >> swap 32 << 32 >>	| h w | texture
	a> 8 + d@ pick2 pick2 */	| h w HN
	a> 12 + d@ 
	>? ( ratio2 ; ) 
	nip nip a> 8 + d@ 	| HN WN
	setbox	
	"r1" .println ;
	
	
:
	.cls
	.printbox
	|640 410 32 << or 
	410 640 32 << or 
	'sdlbox 64boxratio
	cr
	.printbox	
	;