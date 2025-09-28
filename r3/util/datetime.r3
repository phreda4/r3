|
| datetime
| PHREDA 2024
|
^r3/lib/mem.r3

|---- datetime
:,time
	time
	dup 16 >> $ff and ,d ":" ,s
	dup 8 >> $ff and ,2d ":" ,s
	$ff and ,2d ;

:,ti:me 
	time 
	dup 16 >> $ff and ,d 
	dup 1 and " :" + c@ ,c 
	8 >> $ff and ,2d ;

:,date
	date
	dup $ff and ,d "/" ,s
	dup 8 >> $ff and ,d "/" ,s
	16 >> $ffff and ,d ;

::str_DMA
	mark ,sp ,date ,sp ,eol empty here ;
	
::str_HMS
	mark ,sp ,time ,sp ,eol empty here ;

::str_HM
	mark ,sp ,ti:me ,sp ,eol empty here ;
	
#t0 "domingo"
#t1 "lunes"
#t2 "martes"
#t3 "miércoles"
#t4 "jueves"
#t5 "viernes"
#t6 "sábado"
#dianame t0 t1 t2 t3 t4 t5 t6

::>dianame 3 << 'dianame + @ ;

#t0 "enero"
#t1 "febrero"
#t2 "marzo"
#t3 "abril"
#t4 "mayo"
#t5 "junio"
#t6 "julio"
#t7 "agosto"
#t8 "septiembre"
#t9 "octubre"
#ta "noviembre"
#tb "diciembre"
#mesname t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 ta tb

::>mesname 3 << 'mesname + @ ;

::str_fullday | -- 'fullday
	mark
	sysdate 
|WIN|	@
	dup date.dw >dianame ,s ", " ,s
	dup date.d ,d " " ,s
	dup date.m >mesname ,s " " ,s
	dup date.y ,d " " ,s
	0 ,c
	empty here ;

::str_hhmmss | -- 'hhmms
	mark
	sysdate 
|WIN|	8 + @
	dup time.h ,2d ":" ,s
	dup time.m ,2d ":" ,s
	time.s ,2d 0 ,c
	empty here ;
	
::dt2timesql | 'sysdate --
|WIN|	@+ 
	dup date.y ,d "-" ,s 
	dup date.m ,2d "-" ,s 
|LIN| dup	
	date.d ,2d " " ,s
|WIN|	@ 
	dup time.h ,2d ":" ,s 
	dup time.m ,2d ":" ,s 
	time.s ,2d ;
	
|------------------------	
| type name size datetime
|satetime 
| YYYY MwDD HHMM SSmm (mm>>2)
::dt>64 | datetime -- dt64
|WIN|	@+
	dup date.y 48 << 
	over date.m 44 << or
	over date.dw 40 << or
|WIN|	swap 
|LIN|	over
	date.d 32 << or
	swap
|WIN|	@
	dup time.h 24 << 
	over time.m 16 << or
	over time.s 8 << or
	swap time.ms 2 >> $ff and or
	or ;

::,64>dtf | dt64 -- "d/m/y h:m"
	dup 32 >> $ff and ,2d "/" ,s
	dup 44 >> $f and ,2d "/" ,s
	dup 48 >> $ffff and ,d " " ,s
	dup 24 >> $ff and ,2d ":" ,s
	16 >> $ff and ,2d ;
	
::,64>dtd | dt64 -- "d/m/y"
	dup 32 >> $ff and ,d "/" ,s
	dup 44 >> $f and ,d "/" ,s
	48 >> $ffff and ,d " " ,s ;

::,64>dtt | dt64 -- "h:m:s"
	dup 24 >> $ff and ,2d ":" ,s
	dup 16 >> $ff and ,2d ":" ,s
	8 >> $ff and ,2d ;

::64>dtc | dt64 -- "y-m-d h:m:s"
	dup 48 >> $ffff and ,d " " ,s
	dup 44 >> $f and ,2d "-" ,s	
	dup 32 >> $ff and ,2d "-" ,s
	dup 24 >> $ff and ,2d ":" ,s
	dup 16 >> $ff and ,2d ":" ,s
	8 >> $ff and ,2d ;
