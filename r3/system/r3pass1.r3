| r3 compiler
| pass 1 
| load all includes and define order of compiler
| count the tokens, definitions and blocks 
| PHREDA 2018
|----------------
^r3/lib/str.r3
^r3/lib/parse.r3

^r3/system/r3base.r3

##cntinc

|----------- comments / configuration
:escom
|WIN|	"WIN|" =pre 1? ( drop 4 + ; ) drop | Compila para WINDOWS
|LIN|	"LIN|" =pre 1? ( drop 4 + ; ) drop | Compila para LINUX
|MAC|	"MAC|" =pre 1? ( drop 4 + ; ) drop | Compila para MAC
|RPI|	"RPI|" =pre 1? ( drop 4 + ; ) drop | Compila para RPI
	"MEM" =pre 1? ( drop				| MEM 640
		4 +
		trim str>nro 'switchmem !
		>>cr ; ) drop
    >>cr ;

:includepal | str car -- str'
	$7c =? ( drop escom ; )		| $7c |	 Comentario
	1 'cnttokens +!
	$3A =? ( 1 'cntdef +! )		| $3a :  Definicion
	$23 =? ( 1 'cntdef +! )		| $23 #  Variable
	$28 =? ( over c@ 33 <? ( 1 'cntblk +! ) drop )		| $28 (_
	$5b =? ( over c@ 33 <? ( 1 'cntblk +! ) drop )		| $5b [_
	$22 =? ( drop >>str ; )		| $22 "	 Cadena
	drop >>sp ;

|----------- includes
:ininc? | str -- str adr/0
	'inc ( inc> <?
		@+ pick2 =s 1? ( drop ; ) drop
		8 + ) drop 0 ;

:realfilename | str -- str
	"." =pre 0? ( drop "%l" sprint ; ) drop
	2 + 'r3path "%s/%l" sprint ;

:rtrim | str -- str
	dup ( c@+ 1? drop ) drop 2 -
	( dup c@ $ff and 33 <? drop 1 - ) drop
	0 swap 1 + c! ;
	
:load.inc | str -- str new ; incluye codigo
	here over realfilename rtrim
	dup filexist 0? ( nip
			pick2 'lerror ! 
			"Include not found" 'error !
			; ) drop
	load 0 swap c!
	here dup only13 'here ! 			| for see in debug
	;

:add.inc | src here -- src
	over inc> !+ !+ 'inc> ! ;

|*** need recursion detection!!
:includes | src --
	dup ( trimcar 1?
|		over "%l%." filelog
			( $5e =? drop | $5e ^  Include
			ininc? 0? ( drop
|				.cr dup 20 type .cr
				load.inc 0? ( drop ; ) |no existe
				includes
				error 1? ( drop ; ) drop
				dup ) drop
			>>cr trimcar )
		includepal ) 2drop
	add.inc 
|	.cr debuginc trace	
	;

::r3-stage-1 | src -- err/0
|clearlog
	10 'switchmem !
|debuginc trace
	includes
|debuginc
	inc> 'inc - 4 >> 'cntinc !
	;
