|---- pink noise
#pinkc
#pink * 32 | 16 words

:npink
	pinkc not clz
	16 <? ( $ffff randmax over 2 << 'pink +! ) 
	drop
	'pink 
	@+ dup 32 >> + dup 16 >> + swap
	@ dup 32 >> + dup 16 >> + +
	4 >> $ffff and
	1 'pinkc +!
	;

:fpink
	pinkc not clz
	16 <? ( $ffff randmax over 2 << 'pink +! ) 
	drop
	'pink 
	@+ dup 32 >> + dup 16 >> + swap
	@ dup 32 >> + dup 16 >> + +
	4 >> $ffff and $7fff - 2* 
	1 'pinkc +!
	;

|---- white noise
:nwhite
	$ffff randmax ;
	
:fwhite
	-1.0 1.0 randminmax ;
	
|----- brown noise	
#browna
	
:nbrown
	$ff randmax
	browna +
	32767 * 15 >> | dc drift
	clamps16
	dup 'browna !	
	;
	
:fbrown
	browna 0.99 * 16 >>
	-0.02 0.02 randminmax * 16 >>
	1.0 >? ( 1.0 nip )
	-1.0 <? ( -1.0 nip )
	dup 'browna !
	;
	
:u16>fp
	$7fff - 2* ;