| noise
| PHREDA 2025

^r3/lib/math.r3
^r3/lib/rand.r3

|---- white noise
::wnoise
	-1.0 1.0 randminmax ;
	
|---- pink noise
#pinkc
#pink 0 0 

::pnoise
	$ffff randmax
	pinkc not clz $7 and 2 << 'pink + w+!
	'pink 
	@+ dup 32 >> + dup 16 >> + swap
	@ dup 32 >> + dup 16 >> + +
	3 >> $1fff and $fff - 2*
	1 'pinkc +!
	;

|----- brown noise	
#browna
	
::bnoise
	browna 0.99 * 16 >>
	-0.02 0.02 randminmax +
	|1.0 >? ( 1.0 nip ) -1.0 <? ( -1.0 nip )
	clamps16
	dup 'browna !
	;
	
