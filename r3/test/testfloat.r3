^r3/win/console.r3

 |int s = ((bits >> 31) == 0) ? 1 : -1;
 |int e = ((bits >> 23) & 0xff);
 |int m = (e == 0) ?
  |               (bits & 0x7fffff) << 1 :
                 |(bits & 0x7fffff) | 0x800000;
				 
|float uint_to_float(unsigned int significand)
|{
|    int shifts = 0;
|    //  Align the leading 1 of the significand to the hidden-1 
|    //  position.  Count the number of shifts required.
|    while ((significand & (1 << 23)) == 0)
|    {
|        significand <<= 1;
|        shifts++;
|    }

|    //  The number 1.0 has an exponent of 0, and would need to be
|    //  shifted left 23 times.  The number 2.0, however, has an
|    //  exponent of 1 and needs to be shifted left only 22 times.
|    //  Therefore, the exponent should be (23 - shifts).  IEEE-754
|    //  format requires a bias of 127, though, so the exponent field
|    //  is given by the following expression:
|    unsigned int exponent = 127 + 23 - shifts;

|    //  Now merge significand and exponent.  Be sure to strip away
|    //  the hidden 1 in the significand.
|    unsigned int merged = (exponent << 23) | (significand & 0x7FFFFF);

#vert [
$43c80000 $43160000 $ff0000ff 0 0 | 400 150
$43480000 $43e10000 $0000ffff 0 0 | 200 450
$44160000 $43e10000 $00ff00ff 0 0 | 600 450
]

| v1
:i2f | i -- fp
	dup	31 >> $80000000 and | signo
	1? ( swap neg swap )
	swap |$ffffff and
	dup clz 8 - | nif shift
	swap over << | shift nif
	150 rot - 23 << 
	swap $7fffff and or 
	or 
	;

:shift
	-? ( neg >> ; ) << ;	
	
| v2 - abs bit trick	
:i2f | i -- fp
	dup 63 >> swap	| sign i
	over + over xor | sign abs(i) 
	dup clz 8 - 	| s i shift
	swap over shift 	| s shift i
	150 rot - 23 << | s i m
	swap $7fffff and or 
	swap $80000000 and or 
	;

	
:x2f | f.p -- fp
	dup 63 >> swap	| sign i
	over + over xor | sign abs(i) 
	dup clz 8 - 	| s i shift
	swap over shift
	134 rot - 23 << | s i m | 16 - (fractional part)
	swap $7fffff and or 
	swap $80000000 and or 
	;
	

	
:fp2f | fp -- fixed point
	dup $7fffff and $800000 or
	over 23 >> $ff and 134 - 
	shift swap -? ( drop neg ; ) drop
	;

:parsefloat
	-2.4 dup "%f %h" .println "-2.4" getfenro dup "%f %h" .println
	-2.8 dup "%f %h" .println "-2.8" getfenro dup "%f %h" .println
	.cr

	-2.75 0.1 + dup "-2.65 %f %h" .print "-2.65" getfenro dup " %f %h" .println
	0 2.75 - dup "-2.75 %f %h" .print "-2.75" getfenro dup " %f %h" .println
	2.75 dup "2.75 %f %h" .print "2.75" getfenro dup " %f %h" .println
	;
	
:incparse
	0.2 dup dup "%f %h" .println
	0.2 - dup dup "%f %h" .println
	0.2 - dup dup "%f %h" .println
	0.2 - dup dup "%f %h" .println
	0.2 - dup dup "%f %h" .println
	0.2 - dup dup "%f %h" .println
	0.2 - dup dup "%f %h" .println
	0.2 - dup dup "%f %h" .println
	drop ;
	
:
.cls
"test to float" .println
400 dup i2f "%h %d" .println
600 dup i2f "%h %d" .println
-10 dup i2f "%h %d" .println
38452 dup i2f "%h %d" .println
.cr
1.0 dup dup x2f "3f800000 %h %f %h " .println
1.0 x2f fp2f "%f" .println

12.0 dup dup x2f "41400000 %h %f %h " .println
12.0 x2f fp2f "%f" .println

-2.5 dup dup x2f "40200000 %h %f %h " .println
-2.5 x2f 32 << 32 >> fp2f "%f" .println

-0.25 dup dup x2f "3e800000 %h %f %h " .println
-0.25 x2f 32 << 32 >> fp2f "%f" .println

0.6554 dup dup x2f "3f27c84b %h %f %h " .println
0.6554 x2f fp2f "%f" .println

100.0 dup dup x2f dup fp2f "%f 43960000 %h %f %h " .println 

300.0 dup dup x2f dup fp2f "%f 43960000 %h %f %h " .println 

1532.625 dup dup x2f dup fp2f "%f 44bf9400 %h %f %h " .println 
|parsefloat
|incparse

128.0 255 2dup / "%f %d %f" .println
255.0 255 2dup / "%f %d %f" .println
0.0 255 2dup / "%f %d %f" .println
1.0 255 / "%h" .println

128.0 16 >> $101 2dup * "%f %h %f" .println
$ff $101 2dup * "%h %h %d" .println
$0 $101 2dup * "%h %h %d" .println


waitesc
;