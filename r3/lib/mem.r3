| PHREDA - 2019
| Memory words

^r3/lib/str.r3
^r3/lib/core.r3

|---- free memory
##here 0 | address of the next free byte of memory; the , words write here and advance it

|---- conv to mem
::, | d -- ; write a 32-bit value at here, advance here by 4
	here d!+ 'here ! ;
::,c | c -- ; write a byte at here, advance here by 1
	here c!+ 'here ! ;
::,q | q -- ; write a 64-bit value at here, advance here by 8
	here !+ 'here ! ;
::,w | w -- ; write a 16-bit value at here, advance here by 2
	here w!+ 'here ! ;
::,s | str -- ; write the string str at here, without its final 0
	here swap
	( c@+ 1? rot c!+ swap ) 2drop 'here ! ;
::,word | str -- ; write the first word of str (up to a char <= 32) at here, no 0
	here swap
	( c@+ $ff and 32 >? rot c!+ swap ) 2drop 'here ! ;
::,line | str -- ; write the first line of str (up to CR or LF, not included) at here, no 0
	here swap
	( c@+ 1?
		10 =? ( 3 + ) 13 =? ( 2drop 'here ! ; )
		rot c!+ swap ) 2drop 'here ! ;		
::,2d | n -- ; write n as decimal text; if n < 10 a 0 is written first (use for 2-digit fields)
	10 <? ( "0" ,s )
::,d | n -- ; write n as decimal text (see .d)
	.d ,s ;
::,h | n -- ; write n as hexadecimal text, uppercase (see .h)
	.h ,s ;
::,b | n -- ; write n as binary text (see .b)
	.b ,s ;
::,f | fix -- ; write the 48.16 fixed point as decimal text with 4 decimals (see .f)
	.f ,s ;
::,ifp | i -- ; write the integer i as a float32 (4 bytes)
	i2fp , ;
::,ffp | fix -- ; write the 48.16 fixed point as a float32 (4 bytes)
	f2fp , ;

::,cr | -- ; write a CR (13)
	13 ,c ; | 10 ,c ?
::,eol | -- ; write a 0 byte (end of string)
	0 ,c ;
::,sp | -- ; write a space
	32 ,c ;
::,nl | -- ; write CR LF
	$0a0d ,w ;
::,nsp | n -- ; write n spaces
	here 32 pick2 cfill 'here +! ;


::align32 | mem -- mem' ; round mem up to a multiple of 32
	$1f + $1f nand ;

::align16 | mem -- mem' ; round mem up to a multiple of 16
	$f + $f nand ;	

::align8 | mem -- mem' ; round mem up to a multiple of 8
	$7 + $7 nand ;	
	
#memmap * 512
#memmap> 'memmap

::mark | -- ; save here on the memory stack (64 levels at most); undo it with empty
	here memmap> !+ 'memmap> ! ;

::empty | -- ; restore here to the last mark and drop it (to the start of free memory if none)
	memmap> 'memmap =? ( drop mem 'here ! ; )
	8 - dup 'memmap> ! @ 'here ! ;

::savemem | "file" -- ; save to file the memory written since the last mark
	memmap> 8 - @ here over - rot save ;

::sizemem | -- size ; bytes written since the last mark
	here memmap> 8 - @ - ;
	
::memsize | -- mem size ; address of the last mark and bytes written since it
	memmap> 8 - @ here over - ;

#inc 0
::savememinc | "file" -- ; append to file what was written since the previous call (the first time, since the last mark)
	inc 0? ( memmap> 8 - @ nip )
	here over - rot append
	here 'inc !
	;

::cpymem | 'dst -- ; copy to 'dst the memory written since the last mark
	memmap> 8 - @ here over -
	cmove ; | de sr cnt --

::appendmem | "file" -- ; append to file the memory written since the last mark
	memmap> 8 - @ here over - rot append ;

|---- print to mem
:c0	| 'p
	swap .fd ,s ;
:c1	| a,q		(%a/q) fixed point 1 decimal
	swap .f1 ,s ;
:c2	| b,r		(%b) binario
	swap .b ,s ;
:c3	| c,s		(%s) string
	swap 0? ( drop ; ) ,s ;
:c4	| d,t		(%d) decimal
	swap .d ,s ;
:c5	| e,u,%		(%%) caracter %
	$25 ,c ;
:c6	| f,v		(%f) fixed point 4 decima;
	swap .f ,s ;
:c7	| ..w		(%w) palabra
	swap 0? ( drop ; ) ,word ;
:c8	| h..		(%h) hexa
	swap .h ,s ;
:c9	| i,y		(%i) parte entera fixed
	swap 16 >> .d ,s ;
:ca	| j,z		(%j) parte decimal fixed
	swap $ffff and .d ,s  ; | <--- NO ES
:cb	| k,		(%k) caracter
	swap ,c ;
:cc	| l,		(%l) linea
	swap 0? ( drop ; ) ,line ;
:cd	| m,}		(%m) fixed point 2 decimal
	swap .f2 ,s ;
:ce	| .	| cr	(%.) finlinea
	13 ,c ;
:cf	| o,		(%o) octal
	swap .o ,s ;

#control c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf

:,emit | c --
	$25 <>? ( ,c ; ) drop
	c@+ $f and 3 << 'control + @ ex ;

::,print | p p .. "" -- ; write formatted text at here (no 0); the first % takes the last value pushed. %d %h %b %o number, %s str, %w word, %l line, %k char, %f %m %a fixed point 4/2/1 decimals, %p 32.32 8 decimals, %i %j fixed int/frac part, %% percent, %. CR
	( c@+ 1? ,emit ) 2drop ;

|---- print to buff
#buff * 4096 | 4k limit

::sprint | p p .. "" -- adr ; like ,print into a shared 4 KB buffer, with a final 0; valid until the next sprint/sprintln
	mark 'buff 'here ! ,print ,eol empty 'buff ;
	
::sprintln | p p .. "" -- adr ; like sprint, ending with CR LF
	mark 'buff 'here ! ,print 13 ,c 10 ,c ,eol empty 'buff ;

|::sprintc | p p .. "" -- adr c
|	mark 'buff 'here ! ,print ,eol here empty 'buff swap over - ;
	
|::sprintlnc | p p .. "" -- adr c
|	mark 'buff 'here ! ,print 13 ,c 10 ,c ,eol here empty 'buff swap over - ;
	
|---- init here with free mem	
: mem 'here ! ;
