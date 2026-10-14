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

::pnoise			| rosa: Voss-McCartney
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

::bnoise3 | -- v		| marron normalizado (bnoise sale en +-0.27)
	bnoise 3 * ;
