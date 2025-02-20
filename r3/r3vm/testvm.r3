| testvm
| PHREDA 2025
|-------------------------
^./rcodevm.r3

|------------	
#testcode "
| follow maze

#dir 0

:rdir	
	dir 2 - $7 and ; 
	
:adv 	
	dir step ;
	
:checkr 
	rdir check 
	1 =? ( drop 
		rdir 'dir ! adv ; )
	drop
	dir check 
	1 =? ( drop
		adv ; )
	drop
	2 'dir +! 
	checkr ;
	
:run
	100 ( 1? 1 -
		checkr ) drop ;
	
: run ;
"
|------------	
|------------ STACK
:drawstack
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1- 1? swap
		@+ vmcell .write
		) 2drop 
	TOS vmcell .write ;
	
#code1 #code2
#cpu1 #cpu2 #cpu3 
	
#serror
#terror

:infocode
	code1
	@+ 
	dup 32 >> "data: %d" .println
	dup 16 >> $ffff and "code: %d" .println
	$ffff and "boot: %d" .println
	drop
	;

	
|-------------------
: |<<< BOOT <<<
	
	'testcode 
	vmcompile 
	'serror ! 
	'terror !
	'code1 !
	.cr
	vmdicc

	code1 vmcpu 'cpu1 !
|	code1 vmcpu 'cpu2 !
	|vmreset vmdicc
	vmdicc
	
	( getch $1B1001 <>?
		$1000 nand? (
			vmstepip vmdicc
			) 
		drop
		) drop 
	
|	cpu1 vm@
|	vmreset vmstep
|	cpu1 vm!
	
|	cpu2 vm@
|	vmreset vmstep vmstep
|	cpu2 vm!
		
	;
