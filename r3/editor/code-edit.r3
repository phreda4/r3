||||| edit-code
| PHREDA 2007
|---------------------------------------
^r3/win/console.r3
^r3/lib/math.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

^r3/lib/trace.r3

| ventana de texto
#xcode 6
#ycode 2
#wcode 40
#hcode 20

#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor

#hashfile 
#name * 1024

#pantaini>	| comienzo de pantalla
#pantafin>	| fin de pantalla

#inisel		| inicio seleccion
#finsel		| fin seleccion

#fuente  	| fuente editable
#fuente> 	| cursor
#$fuente	| fin de texto

#clipboard	|'clipboard
#clipboard>

#undobuffer |'undobuffer
#undobuffer>

#linecomm 	| comentarios de linea
#linecomm>

|----- find text
#findpad * 64

|----- scratchpad
#outpad * 2048

#mshift

#lerror 0
#cerror 0
#emode 0

|----- edicion
:lins  | c --
	fuente> dup 1 - $fuente over - 1 + cmove>
	1 '$fuente +!
:lover | c --
	fuente> c!+ dup 'fuente> !
	$fuente >? ( dup '$fuente ! ) drop
:0lin | --
	0 $fuente c! ;

#modo 'lins

:back
	fuente> fuente <=? ( drop ; )
	dup 1 - c@ undobuffer> c!+ 'undobuffer> !
	dup 1 - swap $fuente over - 1 + cmove
	-1 '$fuente +!
	-1 'fuente> +! ;

:del
	fuente>	$fuente >=? ( drop ; )
    1 + fuente <=? ( drop ; )
	9 over 1 - c@ undobuffer> c!+ c!+ 'undobuffer> !
	dup 1 - swap $fuente over - 1 + cmove
	-1 '$fuente +! ;

:<<13 | a -- a
	( fuente >=?
		dup c@ 13 =? ( drop ; )
		drop 1 - ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@
		13 =? ( drop 1 - ; ) | quitar el 1 -
		drop 1 + )
	drop $fuente 2 - ;

#1sel #2sel

:selecc	| agrega a la seleccion
	mshift 0? ( dup 'inisel ! 'finsel ! ; ) drop
	inisel 0? ( fuente> '1sel ! ) drop
	fuente> dup '2sel !
	1sel over <? ( swap )
	'finsel ! 'inisel !
	;

:khome
	selecc
	fuente> 1 - <<13 1 + 'fuente> !
	selecc ;

:kend
	selecc
	fuente> >>13  1 + 'fuente> !
	selecc ;

:scrollup | 'fuente -- 'fuente
	pantaini> 1 - <<13 1 - <<13  1 + 'pantaini> !
	ylinea 1? ( 1 - ) 'ylinea !
	selecc ;

:scrolldw
	pantaini> >>13 2 + 'pantaini> !
	pantafin> >>13 2 + 'pantafin> !
	1 'ylinea +!
	selecc ;

:colcur
	fuente> 1 - <<13 swap - ;

:karriba
	fuente> fuente =? ( drop ; )
	selecc
	dup 1 - <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1 - <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> !
	selecc ;

:kabajo
	fuente> $fuente >=? ( drop ; )
	selecc
	dup 1 - <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1 +    | cnt cura
	dup 1 + >>13 1 + 	| cnt cura curb
	over - rot min +
	'fuente> !
	selecc ;

:kder
	selecc
	fuente> $fuente <?
	( 1 + 'fuente> ! selecc ; ) drop
	;

:kizq
	selecc
	fuente> fuente >?
	( 1 - 'fuente> ! selecc ; ) drop
	;

:kpgup
	selecc
	20 ( 1?
		1 - karriba ) drop
	selecc ;

:kpgdn
	selecc
	20 ( 1?
		1 - kabajo ) drop
	selecc ;

|------------------------------------------------
##path * 1024

| extrat path from string, keep in path var
::getpath | str -- str
	'path over
	( c@+ $ff and 32 >=?
		rot c!+ swap ) 2drop
	1 -
	( dup c@ $2f <>? drop
		1 - 'path <=? ( 0 'path ! drop ; )
		) drop
	0 swap 1 + c! ;

:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
:loadtxt | -- ; cargar texto
	fuente 'name getpath
	load 0 swap c!

	fuente only13 	|-- queda solo cr al fin de linea
	fuente dup 'pantaini> !
	count + '$fuente !
	
	fuente simplehash 'hashfile !
	;

:savetxt | -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
	'name savemem
	empty ;

|----------------------------------

:mode!edit
	0 'emode !
	rows 2 - 'hcode !
	cols 7 - 'wcode !
	;
:mode!find
	2 'emode !
	rows 3 - 'hcode !
	cols 7 - 'wcode !
	;
:mode!error
	3 'emode !
	rows 4 - 'hcode !
	cols 7 - 'wcode !
	;

|----------------------------------
:runfile
	savetxt
	.masb .reset .cls
	mark
|WIN|	"r3 "
|LIN|	"./r3lin "
|RPI|	"./r3rpi "
	,s 'name ,s ,eol
	empty here sys
	cr .reset
	"press <enter> to continue" .write .input
	.alsb
	;

:linetocursor | -- ines
	0 fuente ( fuente> <? c@+
		13 =? ( rot 1 + rot rot ) drop ) drop ;

:debugfile
	savetxt
|WIN|	"r3 r3/system/r3debug.r3"
|LIN|	"./r3lin r3/sys/r3debug.r3"
|RPI|	"./r3rpi r3/sys/r3debug.r3"
	sys
	mark
|... load file info.
	here "mem/debuginfo.db" load 0 swap c!
	here >>cr trim str>nro 'cerror ! drop
	empty

	cerror 0? ( drop ; ) drop
|... enter error mode
	fuente cerror + 'fuente> !
	linetocursor 'lerror !
	here >>cr 0 swap c!
	fuente> lerror 1 + here
	" %s in line %d%. %w " sprint 'outpad strcpy
	mode!error
	;

:mkplain
	.masb .reset .cls
	savetxt
|WIN| "r3 r3/system/r3plain.r3"
|LIN| "./r3lin r3/sys/r3plain.r3"
|RPI| "./r3rpi r3/sys/r3plain.r3"
	sys
	.alsb
	;

:compile
	.masb .reset .cls
	savetxt
|WIN| "r3 r3/system/r3compiler.r3"
|LIN| "./r3lin r3/sys/r3compiler.r3"
|RPI| "./r3rpi r3/sys/r3compiler.r3"
	sys
	.alsb
	;

|-------------------------------------------
:copysel
	inisel 0? ( drop ; )
	clipboard swap
	finsel over - pick2 over + 'clipboard> !
	cmove
	;

:realdel
	fuente>
	inisel <? ( drop ; )
	finsel <=? ( drop inisel 'fuente> ! ; )
	finsel inisel - over swap - 'fuente> !
	drop ;

:borrasel
	inisel finsel $fuente finsel - 4 + cmove
	finsel inisel - neg '$fuente +!
	realdel
	0 dup 'inisel ! 'finsel ! ;

:kdel
	inisel 0? ( drop del ; )
	drop borrasel ;

:kback
	inisel 0? ( drop back ; )
	drop borrasel ;

|-------------
| Edit CtrE
|-------------
:posfijo? | adr -- desde/0
	( c@+ 1?
		46 =? ( drop ; )
		drop )
	nip ;

:editvalid | adr -- adr 1/0
    "ico" =pre 1? ( ; ) drop
    "bmr" =pre 1? ( ; ) drop
    "vsp" =pre 1? ( ; ) drop
    "spr" =pre
	;

#ncar
:controle
	savetxt
	fuente> ( dup 1 - c@ $ff and 32 >? drop 1 - ) drop | busca comienzo
	dup c@
	$5E <>? ( 2drop ; ) | no es ^
	drop
	dup fuente - 'ncar !
	dup 2 + posfijo? 0? ( 2drop ; )
	editvalid 0? ( 3drop ; ) drop
	swap 1 + | ext name
	mark
	dup c@ 46 =? ( swap 2 + 'path ,s ) drop
	,w
|	dup "mem/inc-%w.mem" sprint savemem
	empty
|	"r4/system/inc-%w.txt" sprint run
	drop
	;

|-------------
:controlc | copy
	copysel ;

|-------------
:controlx | move
	controlc
	borrasel ;

|-------------
:controlv | paste
	clipboard clipboard> over - 0? ( 3drop ; ) | clip cnt
	fuente> dup pick2  + swap | clip cnt 'f+ 'f
	$fuente over - 1 + cmove>	| clip cnt
	fuente> rot rot | f clip cnt
	dup '$fuente +!
	cmove
	clipboard> clipboard - 'fuente> +!
	;

|-------------
:controlz | undo
	undobuffer>
	undobuffer =? ( drop ; )
	1 - dup c@
	9 =? ( drop 1 - dup c@ [ -1 'fuente> +! ; ] >r )
	lins 'undobuffer> ! ;

|-------------
:=w | w1 w2 -- 1/0
	( c@+ 32 >?
		toupp rot c@+ toupp rot - 1? ( 3drop 0 ; ) drop swap ) 3drop 1 ;

:exactw | adr 1c act cc -- adr 1c act 1/0
	drop dup pick3 =w ;

:setcur | adr 1c act 1
	drop nip nip 'fuente> ! ;

:controla | -- ;find prev
	'findpad
	dup c@ $ff and
	0? ( 2drop ; )
	toupp
	fuente> 1 - | adr 1c act
	( fuente >?
		dup c@ toupp pick2 =? ( exactw 1? ( setcur ; ) )
		drop 1 - ) 3drop ;

:controls | -- ;find next
	'findpad
	dup c@ $ff and
	0? ( drop ; )
	toupp
	fuente> 1 + | adr 1c act
	( $fuente <?
		dup c@ toupp pick2 =? ( exactw 1? ( setcur ; ) )
		drop 1 + ) 3drop ;

|-------------
:controld | buscar definicion
	;

:controln  | new
	| si no existe esta definicion
	| ir justo antes de la definicion
	| agregar palabra :new  ;
	;

|------ Color line
#colornow 0

:wcolor
	over c@
	$22 =? ( drop 15 'colornow ! ; )	| $22 " string
	$5e =? ( drop 3 'colornow ! ; )	| $5e ^  Include
	$7c =? ( drop 8 'colornow ! ; )	| $7c |	 Comentario
	$3A =? ( drop 9 'colornow ! ; )	| $3a :  Definicion
	$23 =? ( drop 13 'colornow ! ; )	| $23 #  Variable
	$27 =? ( drop 14 'colornow ! ; )	| $27 ' Direccion
    drop
	over isNro 1? ( drop 11 'colornow ! ; ) 
	drop 10 'colornow ! ;

:,esc $1b ,c $5b ,c	;
:,fcolor ,esc "38;5;%dm" ,print ;
:,bcolor ,esc "48;5;%dm" ,print ;
:,eline  ,esc "K" ,s ; | erase line from cursor

:,tcolor colornow ,fcolor ;

:inselect
	inisel finsel bt? ( 4 ,bcolor ; )
	0 ,bcolor ;
	
:atselect
	inisel =? ( 4 ,bcolor ; )
	finsel =? ( 0 ,bcolor ; )
	;

:iniline
	xlinea wcolor
	( 1? 1 - swap
		c@+ 0? ( drop nip 1 - ; )
		13 =? ( drop nip 1 - ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		drop swap ) drop ;
	
:strword
	,c
	( atselect c@+ 1?
		$22 =? (
			over c@  $22 <>? ( drop ; )
			,c swap 1 + swap )
		,c	) drop 1 - ;
	
:endline
	,c ( atselect c@+ 1? 
			13 <>? ,c )	1? ( drop ; ) drop 1 - ;
	
:parseline 
	,tcolor
	( atselect c@+ 1? 13 <>?  | 0 o 13 sale
		9 =? ( wcolor ,tcolor )
		32 =? ( wcolor ,tcolor )
		$22 =? ( strword ) 		| $22 " string
		$5e =? ( endline ; )	| $5e ^  Include
		$7c =? ( endline ; )	| $7c |	 Comentario
		,c
		) 
	1? ( drop ; ) drop
	1 - ;

|..............................
:linenow
	ycursor =? ( ">" ,s ; ) 32 ,c ;
	
:linenro | lin -- lin
	dup ylinea + linenow 1 + .d 3 .r. ,s 32 ,c ; 

:drawline | adr line -- line adr'
	mark 
	,esc "0m" ,s ,esc "37m" ,s ,eline | reset,white,clear
	linenro	swap 
	iniline
	inselect	
	parseline 
	here
	empty
	here dup rot rot - type ;


|..............................
:drawcode
	.reset
	pantaini>
	0 ( hcode <?
		0 ycode pick2 + .at
		drawline
		swap 1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> !
	fuente>
	( pantafin> >? scrolldw )
	( pantaini> <? scrollup )
	drop ;

:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 3 'xcursor +! ; )
	drop 1 'xcursor +! ;

:cursorpos
	ylinea 'ycursor ! 0 'xcursor !
	pantaini> ( fuente> <? c@+ emitcur ) drop
	| hscroll
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea wcode + >=? ( dup wcode - 1 + 'xlinea ! )
	drop 
	xcode xlinea - xcursor +
	ycode ylinea - ycursor + .at 
	;
	
|-------------- panel control
#panelcontrol

:controlon	1 'panelcontrol ! ;
:controloff 0 'panelcontrol ! ;

|---------- manejo de teclado
#ckey

:buscapad
	fuente 'findpad findstri
	0? ( drop ; ) 'fuente> ! ;

:findmodekey
	0 hcode 1 + .at 
|	rows hcode - 1 - backlines

	" > " .write
	|'buscapad 'findpad .print
	.input

	ckey
    $d001c =? ( mode!edit )
	|>esc< =? ( mode!edit )
	|>ctrl< =? ( controloff )
    drop
	;

:controlkey
	ckey
	|>ctrl< =? ( controloff )
	|<f> =? ( mode!find )
	|<x> =? ( controlx )
	|<c> =? ( controlc )
	|<v> =? ( controlv )

|	<up> =? ( controla )
|	<dn> =? ( controls )

|	'controle 18 ?key " E-Edit" emits | ctrl-E dit
||	'controlh 35 ?key " H-Help" emits  | ctrl-H elp
|	'controlz 44 ?key " Z-Undo" emits
||	'controld 32 ?key " D-Def" emits
||	'controln 49 ?key " N-New" emits
||	'controlm 50 ?key " M-Mode" emits

	drop
	;


:editmodekey
	panelcontrol 1? ( drop controlkey ; ) drop

	ckey 
	$1000 nand? (
		16 >> $ff and 
		27 <>? (
			8 >? ( modo ex ; )
			)
		) 
	drop

	ckey
	$8000e =? ( kback )
	$53 =? ( kdel )
	$48 =? ( karriba ) 
	$50 =? ( kabajo )
	$4d =? ( kder ) 
	$4b =? ( kizq )
	$47 =? ( khome ) 
	$4f =? ( kend )
	$49 =? ( kpgup ) 
	$51 =? ( kpgdn )
	$52 =? (  modo | ins
			'lins =? ( drop 'lover 'modo ! .ovec ; )
			drop 'lins 'modo ! .insc )

	|<ctrl> =? ( controlon ) >ctrl< =? ( controloff )
	
	$2a =? ( 1 'mshift ! ) $36 =? ( 1 'mshift ! ) | shift der ize.. falta soltar
	$102a =? ( 0 'mshift ! ) $1036 =? ( 0 'mshift ! ) | shift der ize.. falta soltar	

	$3b =? ( runfile )
	$3c =? ( debugfile )
|	$3d =? ( profiler )
	$3e =? ( mkplain )
	$3f =? ( compile )
	drop
	;

:errmodekey
	0 hcode 1 + .at
|	rows hcode - 1 - backlines
	'outpad .write
	editmodekey
	;

:barraf | F+
	" ^[7mF1^[27m Run ^[7mF2^[27m Debug ^[7mF3^[27m Profile ^[7mF4^[27m Plain ^[7mF5^[27m Compile" .printe ;

:barrac | control+
	" ^[7mX^[27m Cut ^[7mC^[27mopy ^[7mV^[27m Paste ^[7mF^[27mind " .printe
	'findpad
	dup c@ 0? ( 2drop ; ) drop
	" [%s]" .print ;

:printpanel
	panelcontrol
	0? ( drop barraf ; ) drop
	barrac ;

:top
	0 0 .at 
	.bblue .white .eline
	printpanel sp ;

:bottom
	0 hcode 2 + .at 
	.bblue .white .eline
	sp 'name .write sp ycursor xcursor " %d:%d " .print 

	fuente count  " %d chars" .print
	;
	
|-------------------------------------
:pantalla	
	.reset
	.hidec
	top
	drawcode
	bottom
	cursorpos
	.showc
	;

:editor
	.reset .cls
	0 'xlinea !
	mode!edit
	pantalla .insc
	( getch $1B1001 <>? 'ckey !
		emode
		0? ( editmodekey )
|	1 =? ( immmodekey )
		2 =? ( findmodekey )
		3 =? ( errmodekey )
		drop
		pantalla
 		) drop
	;

	
|---- Mantiene estado del editor
:ram
	here	| --- RAM
	dup 'fuente !
	dup 'fuente> !
	dup '$fuente !
	$3ffff +			| 256kb texto
	dup 'clipboard !
	dup 'clipboard> !
	$3fff +				| 16KB
	dup 'undobuffer !
	dup 'undobuffer> !
	$ffff +         	| 64kb
	dup 'linecomm !
	dup	'linecomm> !
	$3fff +				| 4096 linecomm
	'here  ! | -- FREE
	0 here !
	mark 
	;

|----------- principal
:main
	'name "mem/main.mem" load drop
	ram
	loadtxt
	.getconsoleinfo
	.alsb editor .masb
	savetxt
	;

: 4 main ;
