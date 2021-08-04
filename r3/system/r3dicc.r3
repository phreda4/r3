| memoria + diccionario r3
| PHREDA 2018
|----------------------------------
^./r3parse.r3


| >>>info
| bit  significado
| $1	0 accion 1 dato
| $2	0 local 1 exportado
| $4	1 es usado con direccion
| $8	1 r esta desbalanceada
| $10	0 un ; 1 varios ;
| $20	1 si es recursiva
| $40	1 si tiene anonimas
| $80	1 termina sin ;
| $100	1 inline
| $200	1 modifica memoria (no pila)
| $400	1 modifica A
| $800	1 modifica B
| $40000000	1 set A
| $80000000	1 set B

| 12-24		llamadas (12 bits)   $00fff000
| 25-32		nivel	(8 bits)     $3f000000
|
| >>>>mov
| byte	significado
| 1		dD (-128..127)
| 2     dU (-128..127)
| 3/    dR ( -8..7 )
| /4	largo en tokens (12 bits)

|-----------------
|--- info de variables
| valor               0
| direccion           1
| direccion codigo    2
| string              3
| lista valores       4
| lista direcciones   5
| lista dir codigos   6
| lista strings       7
| estructura multiple 8
|--------------------



::word+! | tipo --
	dicc> >a
|	data>
	over a!+	| str del nombre
	code> a!+	| token de comienzo
	a!+				| info de palabra
	0 a!+			| mem?
	0 a! a> 'dicc> ! ;

|---- Compila programa
::,, | n --
	code> !+ 'code> ! ;

::,cte | n -- d
	data> swap over !+ 'data> ! data - ;

:rstr | c --
	data> c!+ 'data> ! ;

:realstr | cad -- cad'
	( 1+ dup c@ 1?
		34 =? ( drop 1 + dup c@ 34 <>? ( drop 0 rstr ; ) )
		rstr ) rstr ;

::,str | a -- a' d
	data> swap realstr swap data - ;

::,word | a -- a' nro
	pasapal
	dicc> 'dicc - 4 >> 1-
	;

|--- dibuja movimiento pilas
:ncar | n car -- car
	( swap 1? 1 - swap dup emit 1+ ) drop ;

::printmovword | mov --
	97 >r
	dup 16 << 24 >> | usedD
	neg dup r> ncar >r
	"--" emits
	over 24 << 24 >> + | deltaD
	r> ncar >r
	12 << 28 >>
	0 >? ( dup " R:--" emits r> ncar >r )
	0 <? ( dup " R:" emits neg r> ncar >r "--" emits )
	drop r> drop ;

::printinfword | inf --
	dup 12 >> $fff and
	0? ( "X" emits 2drop ; )	| no usada
	"%d " print
	1 and? (
		$4 nand? ( "C" emits )	| dato constante
	)(
		$10 and? ( ";" emits )	| varios ;
		$20 and? ( "R" emits )	| recursivo
		$80 and? ( "." emits )	| continuo (sin ;)
		$200 nand? ( "L" emits )
	)
	drop ;

:,ncar | n car -- car
	( swap 1? 1 - swap dup ,c 1 + ) drop ;

::,printmovword | mov --
	97 >r
	dup 16 << 24 >> | usedD
	neg dup r> ,ncar >r
	"--" ,s
	over 24 << 24 >> + | deltaD
	r> ,ncar >r
	12 << 28 >>
	0 >? ( dup " R:--" ,s r> ,ncar >r )
	0 <? ( dup " R:" ,s neg r> ,ncar >r "--" ,s )
	drop r> drop
	;

|--- info de variables
#vtipos
"v"	| value  #x 20
"d"	| dir data #y 'x
"c" | dir code #v 'acc
"s" | string #s "string"
".v" | list
".d" | list
".c" | list
".s" | list
":m" | multiple #m 23 "jol" 'ac

::vtype | nro -- str
    $f and
	'vtipos swap ( 1? swap >>0 swap 1 - ) drop ;

::printinfovar | inf --
	dup 12 >> $fff and
	0? ( "X" emits 2drop ; )		| no usada
	drop
	$4 nand? ( "C " emits )	| dato constante
	6 >> vtype emits ;

::,printinfovar | inf --
	dup 12 >> $fff and
	0? ( "X" ,s 2drop ; )		| no usada
	drop
	$4 nand? ( "C" ,s )	| dato constante
	6 >> vtype ,s ;

::,printinfowor | inf --
	dup 12 >> $fff and
	0? ( "X" ,s 2drop ; )		| no usada
	drop
	$8 and? ( "r" ,s )	| r debalanceada
	$10 and? ( ";" ,s )	| varios ;
	$20 and? ( "R" ,s )	| recursivo
	$80 and? ( "." ,s )	| continuo (sin ;)
	$100 and? ( "i" ,s )	| inline
	$200 nand? ( "m" ,s )
	$40000000 and? ( "a" ,s )
	$400 and? ( "A" ,s )
	$80000000 and? ( "b" ,s )
	$800 and? ( "B" ,s )
	drop ;

::,printinfoword | adr --
	8 + @+
	dup 12 >> $fff and
	0? ( "X" ,s 3drop ; )		| no usada
	drop
	1 and? (
		$4 nand? ( "cte " ,s )	| dato constante
		6 >> vtype ,s
		drop
		; )
	$8 and? ( "r" ,s )	| r debalanceada
	$10 and? ( ";" ,s )	| varios ;
	$20 and? ( "R" ,s )	| recursivo
	$80 and? ( "." ,s )	| continuo (sin ;)
	$100 and? ( "i" ,s )	| inline
	$200 nand? ( "m" ,s )
	$40000000 and? ( "a" ,s )
	$400 and? ( "A" ,s )
	$80000000 and? ( "b" ,s )
	$800 and? ( "B" ,s )
	drop " | " ,s
	@ ,printmovword ;

|----------- DEBUG ---------------

::dumpdic
	'dicc ( dicc>  <?
		@+ "%w " print
		@+ "%h " print
		@+ "%h " print
		@+ "%h " print
		cr allowchome ) drop ;

::dumpdicu
	'dicc ( dicc>  <?
	    dup 8 + @ 12 >> $fff and 1? ( drop
		@+ "%w " print
		@+ "%h " print
		@+ "%h " print
		@+ "%h " print
		cr allowchome
		)( drop 16 + )
		 ) drop ;


::infodic
	code> code - "$%h code " print cr
	data> data - "$%h data " print cr
	;
	
#errormsgl
"No existe palabra"					| 1
"No existe libreria"
"Bloque mal formado "
"Definicion anonima mal cerrada"
"Las base no tienen direccion"
"base en Dato"
"# solo"
"falta ; en anonima"
0
