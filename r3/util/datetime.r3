|
| datetime
| PHREDA 2024
|
^r3/lib/mem.r3

|---- datetime
::,time | -- ; write the current time as h:mm:ss (hour without leading zero)
	time
	dup 16 >> $ff and ,d ":" ,s
	dup 8 >> $ff and ,2d ":" ,s
	$ff and ,2d ;

::,ti:me | -- ; write the current time as h:mm with a blinking colon (a space on odd seconds)
	time 
	dup 16 >> $ff and ,d 
	dup 1 and " :" + c@ ,c 
	8 >> $ff and ,2d ;

::,date | -- ; write the current date as d/m/yyyy
	date
	dup $ff and ,d "/" ,s
	dup 8 >> $ff and ,d "/" ,s
	16 >> $ffff and ,d ;

::,date- | -- ; write the current date as yyyy-mm-dd
	date
	dup 16 >> $ffff and ,d "-" ,s
	dup 8 >> $ff and ,2d "-" ,s
	$ff and ,2d ;

::str_DMA | -- str ; the current date as " d/m/yyyy " in a temporary string (at here, valid until the next write to memory)
	mark ,sp ,date ,sp ,eol empty here ;
	
::str_HMS | -- str ; the current time as " h:mm:ss " in a temporary string (at here)
	mark ,sp ,time ,sp ,eol empty here ;

::str_HM | -- str ; the current time as " h:mm " (blinking colon) in a temporary string (at here)
	mark ,sp ,ti:me ,sp ,eol empty here ;
	
#t0 "domingo"
#t1 "lunes"
#t2 "martes"
#t3 "miércoles"
#t4 "jueves"
#t5 "viernes"
#t6 "sábado"
#dianame t0 t1 t2 t3 t4 t5 t6

::>dianame | n -- str ; Spanish name of the weekday n (0 = domingo .. 6 = sabado), no range check
	3 << 'dianame + @ ;

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

::>mesname | n -- str ; Spanish name of the month n (0 = enero .. 11 = diciembre), no range check
	3 << 'mesname + @ ;

::str_fullday | -- str ; current date as "weekday, d month yyyy " in Spanish, zero-terminated, in a temporary string
	mark
	sysdate 
|WIN|	@
	dup date.dw >dianame ,s ", " ,s
	dup date.d ,d " " ,s
	dup date.m 1- >mesname ,s " " ,s
	dup date.y ,d " " ,s
	0 ,c
	empty here ;

::str_hhmmss | -- str ; current time as hh:mm:ss (2 digits each), zero-terminated, in a temporary string (at here)
	mark
	sysdate 
|WIN|	8 + @
	dup time.h ,2d ":" ,s
	dup time.m ,2d ":" ,s
	time.s ,2d 0 ,c
	empty here ;
	
::dt2timesql | 'timedate -- ; write a timedate (address from sysdate or filetimeD) as yyyy-mm-dd hh:mm:ss at here (no final 0)
|WIN|	@+ 
	dup date.y ,d "-" ,s 
	dup date.m ,2d "-" ,s 
|LIN| dup	
|MAC| dup
	date.d ,2d " " ,s
|WIN|	@ 
	dup time.h ,2d ":" ,s 
	dup time.m ,2d ":" ,s 
	time.s ,2d ;
	
|------------------------	
| type name size datetime
|satetime 
| YYYY MwDD HHMM SSmm (mm>>2)
::dt>64 | 'timedate -- dt64 ; pack a timedate in 64 bits: year<<48 | month<<44 | weekday<<40 | day<<32 | hour<<24 | minute<<16 | second<<8 | ms>>2
|WIN|	@+
	dup date.y 48 << 
	over date.m 44 << or
	over date.dw 40 << or
|WIN|	swap 
|LIN|	over
|MAC|	over
	date.d 32 << or
	swap
|WIN|	@
	dup time.h 24 << 
	over time.m 16 << or
	over time.s 8 << or
	swap time.ms 2 >> $ff and or
	or ;

::,64>dtf | dt64 -- ; write a dt64 as dd/mm/yyyy hh:mm
	dup 32 >> $ff and ,2d "/" ,s
	dup 44 >> $f and ,2d "/" ,s
	dup 48 >> $ffff and ,d " " ,s
	dup 24 >> $ff and ,2d ":" ,s
	16 >> $ff and ,2d ;
	
::,64>dtd | dt64 -- ; write the date of a dt64 as d/m/yyyy followed by a space
	dup 32 >> $ff and ,d "/" ,s
	dup 44 >> $f and ,d "/" ,s
	48 >> $ffff and ,d " " ,s ;

::,64>dtt | dt64 -- ; write the time of a dt64 as hh:mm:ss
	dup 24 >> $ff and ,2d ":" ,s
	dup 16 >> $ff and ,2d ":" ,s
	8 >> $ff and ,2d ;

::64>dtc | dt64 -- ; write a dt64 as date and time
	dup 48 >> $ffff and ,d " " ,s
	dup 44 >> $f and ,2d "-" ,s	
	dup 32 >> $ff and ,2d ,sp
	dup 24 >> $ff and ,2d ":" ,s
	dup 16 >> $ff and ,2d ":" ,s
	8 >> $ff and ,2d ;
