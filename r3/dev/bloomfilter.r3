^r3/lib/console.r3

:hash1 | "" -- 64hash
	0 swap ( c@+ 1? rot 
		31 * + 
		swap ) 2drop ;

:hash2 | "" -- 64hash
	5381 swap ( c@+ 1? rot 
		dup 5 << + + 
		swap ) 2drop ;

:hash3 | "" -- 64hash
	1315423911 swap ( c@+ 1? rot 
		dup 5 << over 2 >> + 
		rot + xor 
		swap ) 2drop ;

#bitset8 0 0 0 0 0 0 0 0 | 512 bits

:bitdres | 'bitset8 64hash -- mask 'bitset[]
	1 over $3f and << 
	-rot 6 >> $7 and + ;
	
:setbit | 'bitset8 64hash --
	bitdres 
	dup @ rot or swap ! ; | or!	
	
:clrbit | 64hash --
	bitdres 
	dup @ rot not and swap ! ; | nand!

:getbit | 64hash -- 0/1
	bitdres @ and 0? ( ; ) -1 nip ;
	
::boomInit | bf --
	0 8 fill ;
	
::boom+! | bf "str" --
	|DUP "ADD:%S" .PRINTLN
	2dup hash1 setbit
	2dup hash2 setbit
	hash3 setbit ;
	
::boom? | bf "" --
|	DUP "check:%S" .PRINTLN
	2dup hash1 getbit -rot
	2dup hash2 getbit -rot
	hash3 getbit and and ;
	
	
#bloomf 0 0 0 0 0 0 0 0 | 512 bits	

#teststr
"apple"
"banana"
"grape" | Not added
"orange"
"kiwi"  | Not added
"apricot" | Not added (might cause a false positive)
0

|// --- Main Example ---
:main
	'bloomf 
	dup boomInit
	dup "apple" boom+!
	dup "banana" boom+!
	dup "orange" boom+!
	drop
	'teststr ( dup c@ 1? drop
		'bloomf over boom? "%d " .PRINT
		dup .println
		>>0 ) 2drop
		
	waitesc
	;

: main ;
	