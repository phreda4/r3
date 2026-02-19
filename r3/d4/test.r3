|main
^r3/lib/console.r3

#var1 33
#var2 0

:meminv	
	23 var1 ! ;
	
:stakover
	10 ( 1? dup ) ;
	
:stackunder
	10 ( 1? nip ) ;

:div0
	1200 var2 / 'var1 ! ;

:rstack
	var2 * ;
	
:tcall
	3 rstack 'var1 + ;
	
: 
.cls 
tcall
"test runtime error" .println
.cr
( 
	"f keys.." .print
	getch [esc] <>? 
	[F2] =? ( meminv ) 
	[F3] =? ( stakover )
	[F4] =? ( stackunder )
	[F5] =? ( div0 )	
	" %h" .println
	) drop
"finish" .println

;

