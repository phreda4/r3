| osc.r3 - osciladores: fase 0..1.0 (16 bits) -> valor -1.0..1.0
| PHREDA 2025

^r3/lib/math.r3

|---- OSC
| time -- val
::oscSaw	2* 1.0 - ;
::oscSqr	0.5 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscPul1	0.1 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscPul2	0.25 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscTri	$8000 and? ( $ffff xor ) 2 << 1.0 - ; 
::oscSin	sin ;
::oscHSin	sin abs ;
::oscSin2	sin dup *. ;
::oscSin3	sin dup dup *. *. ;
::oscSinF	2* 1.0 - dup *. 2* 1.0 - ;
::oscSawRev	1.0 swap - 2* 1.0 - ;
::oscTrap	0.25 <? ( 2 << ) 0.75 >? ( 2 << 4.0 - ) 2* 1.0 - ;
::oscParab	dup *. 2* 1.0 - ;

::oscFakeSuperSaw | phase -- v
	dup 2* 1.0 - swap dup *. 2* 1.0 - + 2/ ;
	
::oscSuperSaw2P | phase -- v
	2* 1.0 - dup 1.01 *. 2* 1.0 - + 2/ ;

::oscSuperSaw3P | phase -- v
	dup 2* 1.0 -
	swap dup 0.99 *. 2* 1.0 - +
	swap 1.01 *. 2* 1.0 - +
	0.333 *. ;
