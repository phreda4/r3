|MEM 64
| vox2z.r3 
|
| "salida"  voxcompress    genera salida.ssv y salida.txt (usa lo juntado por voxdir)
|

^r3/lib/console.r3
^r3/lib/mem.r3
^r3/lib/str.r3
^r3/lib/math.r3

#ssvend
#n3dsprites
#ncols 
#ncolors 
#defspr 
#colbase 
#palbase 

#ccols	
#ctiras

:chxyz | v --
|	dup 32 >> $ff and "x:%d " .print
|	dup 40 >> $ff and "y:%d " .print
|	dup 48 >> $ff and "z:%d " .print 
	dup 32 >> $ff and 
	over 48 >> $ff and * 
	dup 'ccols +!
|	"%d" .print
|	drop
	over 40 >> $ff and * 'ctiras +!
	;


:tsprites
	0 'ccols !
	0 'ctiras !
	defspr >a
	0 ( n3dsprites <?
		a@+
		chxyz 
		|dup "%h " .print .cr
		drop
		1+ ) drop ;
		
:voxcompress	
	here swap "%s.ssv" sprint load 'ssvend !
	here d@ "SSV2" d@ <>? ( drop "not ssv file" .println ; ) drop
	here 4 + d@ 'n3dsprites !
	here 8 + d@ 'ncols !
	here 12 + d@ 'ncolors !
	here 16 + 'defspr !
	defspr n3dsprites 3 << + 'colbase !
	colbase ncols 3 << + 'palbase !	
	
ssvend "%h" .println
n3dsprites "sprites %d" .println
ncols  "columnas %d" .println
ncolors  "tiras %d" .println
|defspr  "%h" .println
|colbase  "%h" .println
|palbase  "%h" .println
	
	tsprites
	
	ccols ncols  "columas %d %d" .println
	ctiras "tiras %d" .println
	;

: 
	"media/ssv/mexcla" voxcompress
	
	waitkey ;
