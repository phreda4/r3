| Bloom Filter
| PHREDA 2025
|
^r3/lib/console.r3

|---- hash
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

| total: $7 + $3f == $1fff (512 bits)
:bitdres | 'bitset8 64hash -- mask 'bitset[]
	1 over $3f and << 
	-rot $1fc0 and + ;

:setbit | 'bitset8 64hash --
	bitdres 
	dup @ rot or swap ! ; | or!	
	
:clrbit | 64hash --
	bitdres 
	dup @ rot not and swap ! ; | nand!

:getbit | 64hash -- 0/1
	bitdres @ and ;

|--- 8bit
:bitdres8 | 'bitset8 64hash -- mask 'bitset[]
	1 over $7 and << 
	-rot $1ff8 and + ;

:setbit8 | 'bitset8 64hash --
	bitdres8 dup c@ rot or swap c! ; | orc!	
	
:getbit8 | 64hash -- 0/1
	bitdres8 c@ and ;

|--- API	
::boomInit | bf --
	0 8 fill ;
	
::boom+! | bf "str" --
	DUP "ADD:%S" .PRINTLN
	2dup hash1 setbit
	2dup hash2 setbit
	hash3 setbit ;
	
::boom? | bf "" --
|	DUP "check:%S" .PRINTLN
	2dup hash1 getbit 0? ( nip nip ; ) drop
	2dup hash2 getbit 0? ( nip nip ; ) drop
	hash3 getbit 0? ( ; ) -1 nip ;
	
|--- TEST
#bloomf 0 0 0 0 0 0 0 0 | 512 bits	* 64

#teststr
"apple"
"banana"
"grape" | Not added
"orange"
"kiwi"  | Not added
"apricot" | Not added (might cause a false positive)
0

:main
	"Bloom Filter test case" .println
	.cr
	'bloomf 
	dup boomInit
	dup "apple" boom+!
	dup "banana" boom+!
	dup "orange" boom+!
	|dup "kiwi" boom+!
	drop
	.cr
	
	'teststr ( dup c@ 1? drop
		'bloomf over boom? "%d " .PRINT
		dup .println
		>>0 ) 2drop
		
	waitesc
	;

: main ;
	