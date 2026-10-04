| noise
| PHREDA 2025

^r3/lib/math.r3
^r3/lib/rand.r3

|---- white noise
::wnoise
	-1.0 1.0 randminmax ;
	
|---- pink noise
#pinkc
#pink * 16

::pnoise
	$ffff randmax
	pinkc not clz $7 and 2 << 'pink + w+!
	'pink 
	@+ dup 32 >> + dup 16 >> + swap
	@ dup 32 >> + dup 16 >> + +
	3 >> $1fff and $fff - 2* ;
	
::pnoise1			| Voss-McCartney
	pinkc ctz $7 and 1 << 'pink + rand swap w!
	1 'pinkc +!
	0 8 ( 1? 1- dup 1 << 'pink + w@ $ffff and rot + swap ) drop
	3 >> $8000 - 2* ;

|----- brown noise	
#browna
	
::bnoise
	browna 0.99 * 16 >>
	-0.02 0.02 randminmax +
	|1.0 >? ( 1.0 nip ) -1.0 <? ( -1.0 nip )
	clamps16
	dup 'browna !
	;
	
