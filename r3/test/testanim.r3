^r3/win/console.r3
^r3/lib/3dgl.r3
^r3/lib/vec3.r3

#prevt
#dtime

:timeI msec 'prevt ! 0 'dtime ! ;
:time. msec dup prevt - 'dtime ! 'prevt ! ;
:time+ dtime + $ffffff7fffffffff and  ;

:nanim | nanim -- n
	dup |$ffffffffff and 
	over 40 >> $f and 48 + << 1 >>>
	over 44 >> $ff and 63 *>>
	swap 52 >>> + | ini
	;
	
:vni>anim | vel cnt ini -- nanim 
	$fff and 52 << swap
	$ff and 44 << or swap
	$f and 40 << or 
	;
	
#vanim

:dump 
|	dup 40 >> $f and "%d " .print 
|	dup 44 >> $ff and "%d " .print 
|	dup 52 >>> "%d : " .print
	dup "%h" .print
	nanim " : %d" .println
	;
	
:
timeI
.cls
"ani test" .println
7 8 4 vni>anim | vel cnt ini 
'vanim !
25 ( 1? 1 -
	20 'vanim +!
	vanim dump
	) drop
.input
;