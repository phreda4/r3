| PHREDA - 2019
| Memory words

^r3/lib/str.r3
^r3/win/core.r3

|---- free memory

##here 0

#memmap * 512
#memmap> 'memmap

::mark | --
	here memmap> !+ 'memmap> ! ;

::empty | --
	memmap> 'memmap =? ( drop mem 'here ! ; )
	8 - dup 'memmap> ! @ 'here ! ;

::savemem | "" --
	memmap> 8 - @ here over - rot save ;

::sizemem | -- size
	here memmap> 8 - @ - ;
	
::memsize | -- mem size
	memmap> 8 - @ here over - ;

#inc 0
::savememinc | "" --
	inc 0? ( memmap> 8 - @ nip )
	here over - rot append
	here 'inc !
	;

::cpymem | 'destino --
	memmap> 8 - @ here over -
	cmove ; | de sr cnt --

::appendmem | "" --
	memmap> 8 - @ here over - rot append ;

|---- conv to mem
::, here d!+ 'here ! ;
::,c here c!+ 'here ! ;
::,q here !+ 'here ! ;
::,w here w!+ 'here ! ;
::,s here swap
	( c@+ 1? rot c!+ swap ) 2drop 'here ! ;
::,word here swap
	( c@+ $ff and 32 >? rot c!+ swap ) 2drop 'here ! ;
::,line here swap
	( c@+ 1?
		10 =? ( 3 + ) 13 =? ( 2drop 'here ! ; )
		rot c!+ swap ) 2drop 'here ! ;
::,d .d ,s ;
::,h .h ,s ;
::,b .b ,s ;
::,f .f ,s ;
::,ifp i2fp , ;
::,ffp f2fp , ;

::,cr 13 ,c ;
::,eol 0 ,c ;
::,sp 32 ,c ;
::,nl 13 ,c 10 ,c ;

|---- print to mem
:c0	| 'p
	;
:c1	| a,q
	;
:c2	| b,r		(%b) binario
	swap .b ,s ;
:c3	| c,s		(%s) string
	swap 0? ( drop ; ) ,s ;
:c4	| d,t		(%d) decimal
	swap .d ,s ;
:c5	| e,u,%		(%%) caracter %
	$25 ,c ;
:c6	| f,v		(%f) punto fijo
	swap .f ,s ;
:c7	| ..w		(%w) palabra
	swap 0? ( drop ; ) ,word ;
:c8	| h..		(%h) hexa
	swap .h ,s ;
:c9	| i,y		(%i) parte entera fixed
	swap 16 >> .d ,s ;
:ca	| j,z		(%j) parte decimal fixel
	swap $ffff and .d ,s  ; | <--- NO ES
:cb	| k,		(%k) caracter
	swap ,c ;
:cc	| l,		(%l) linea
	swap 0? ( drop ; ) ,line ;
:cd	| m,}
	;
:ce	| .	| cr	(%.) finlinea
	13 ,c ;
:cf	| o,		(%o) octal
	swap .o ,s ;

#control c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf

:,emit | c --
	$25 <>? ( ,c ; ) drop
	c@+ $f and 3 << 'control + @ ex ;

::,print | p p .. "" --
	( c@+ 1? ,emit ) 2drop ;

|---- print to buff
#buff * 4096 | 4k limit

::sprint | p p .. "" -- adr
	mark 'buff 'here ! ,print ,eol empty 'buff ;
	
::sprintln | p p .. "" -- adr
	mark 'buff 'here ! ,print 10 ,c 13 ,c ,eol empty 'buff ;

::sprintc | p p .. "" -- adr c
	mark 'buff 'here ! ,print ,eol here empty 'buff swap over - ;
	
::sprintlnc | p p .. "" -- adr c
	mark 'buff 'here ! ,print 10 ,c 13 ,c ,eol here empty 'buff swap over - ;
	
|---- init here with free mem	
: mem 'here ! ;
