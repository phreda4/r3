|main
^r3/lib/console.r3

#var1 33
#var2 0
#var3 

::ctz | x -- n
	0? ( 64 + ; ) 
	dup neg and 
	dup "%h" .println
	0 swap
    $00000000FFFFFFFF nand? ( swap 32 + swap ) 
    $0000FFFF0000FFFF nand? ( swap 16 + swap )
    $00FF00FF00FF00FF nand? ( swap 8 + swap )
    $0F0F0F0F0F0F0F0F nand? ( swap 4 + swap )
    $3333333333333333 nand? ( swap 2 + swap )
    $5555555555555555 nand? ( swap 1 + swap )
	drop 
	.cr ;
	
: 
1 dup ctz "%d %d " .println
2 dup ctz "%d %d " .println
8 dup ctz "%d %d " .println
1.0 dup ctz "%d %d " .println
2.0 dup ctz "%d %d " .println
128.0 dup ctz "%d %d " .println

"finish" .println
waitesc
;

