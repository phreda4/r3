| edit-code
| PHREDA 2007
|---------------------------------------
^r3/win/console.r3
^r3/lib/math.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

#rows
#cols

| ventana de texto
#xcode 5
#ycode 2
#wcode 40
#hcode 20
#xseli	| x ini win
#xsele	| x end win

#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor

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
		 dup c@
		13 =? ( drop ; )
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
	over -
	rot min +
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

:loadtxt | -- cargar texto
	fuente 'name getpath
	load 0 swap c!

	fuente only13 	|-- queda solo cr al fin de linea
	fuente dup 'pantaini> !
	count + '$fuente !
	;

:savetxt
	mark	| guarda texto
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
	'name savemem
	empty ;

|----------------------------------
:calcselect
|	xcode wcode + gotox ccx 'xsele !
|	xcode gotox ccx 'xseli !
	;

:mode!edit
	0 'emode !
	rows 2 - 'hcode !
	cols 7 - 'wcode !
	calcselect ;
:mode!find
	2 'emode !
	rows 3 - 'hcode !
	cols 7 - 'wcode !
	calcselect ;
:mode!error
	3 'emode !
	rows 4 - 'hcode !
	cols 7 - 'wcode !
	calcselect ;


|----------------------------------
:runfile
	savetxt
	mark
|WIN|	"r3 "
|LIN|	"./r3lin "
|RPI|	"./r3rpi "
	,s 'name ,s ,eol
	empty here sys
	;

:linetocursor | -- ines
	0 fuente ( fuente> <? c@+
		13 =? ( rot 1 + rot rot ) drop ) drop ;

:debugfile
	savetxt
|WIN|	"r3 r3/sys/r3debug.r3"
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
	savetxt
|WIN| "r3 r3/sys/r3plain.r3"
|LIN| "./r3lin r3/sys/r3plain.r3"
|RPI| "./r3rpi r3/sys/r3plain.r3"
	sys
	;

:compile
	savetxt
|WIN| "r3 r3/sys/r3compiler.r3"
|LIN| "./r3lin r3/sys/r3compiler.r3"
|RPI| "./r3rpi r3/sys/r3compiler.r3"
	sys
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
:col_inc .yellow ;
:col_com .blackl ;
:col_cod .green ;
:col_dat .Magenta ;
:col_str .white ;
:col_adr .cyan ;
:col_nor .green ;
:col_nro .yellow ;
:col_select .whitel ;

#mcolor

:wcolor
	mcolor 1? ( drop ; ) drop
	over c@
	$5e =? ( drop col_inc ; )				| $5e ^  Include
	$7c =? ( drop col_com 1 'mcolor ! ; )	| $7c |	 Comentario
	$3A =? ( drop col_cod ; )				| $3a :  Definicion
	$23 =? ( drop col_dat ; )				| $23 #  Variable
	$27 =? ( drop col_adr ; )				| $27 ' Direccion
    drop
	over isNro 1? ( drop col_nro ; ) drop
	col_nor
	;

| "" logic
:strcol
	mcolor
	0? ( drop col_str 2 'mcolor ! ; )
	1 =? ( drop ; )
	drop
	over c@ $22 <>? ( drop
		mcolor 3 =? ( drop 2 'mcolor ! ; )
		drop 0 'mcolor ! ; ) drop
	mcolor 2 =? ( drop 3 'mcolor ! ; ) drop
	2 'mcolor !
	;

:iniline
	0 'mcolor !
	xlinea wcolor
	( 1? 1 - swap
		c@+ 0? ( drop nip 1 - ; )
		13 =? ( drop nip 1 - ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		$22 =? ( strcol )
		drop swap ) drop ;

:emitl
|	9 =? ( drop gtab ; )
	emit ;
:a	
	|ccx xsele <? ( drop ; ) drop
	( c@+ 1? 13 <>? drop ) drop 1 -		| eat line to cr or 0
|	wcode xcode + gotox
	"." .
	;

:drawline
	iniline
	( c@+ 1?
		13 =? ( drop ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		$22 =? ( strcol )
		emitl
		) drop 1 - ;

|..............................
:linenro | lin -- lin
	.white
	dup ylinea + 1 + .d 4 .r. . "  " . ;

|..............................
:drawcode
	pantaini>
	0 ( hcode <?
		0 ycode pick2 + .at
		linenro
|		xcode gotox
		swap drawline
		swap 1 + ) drop
	$fuente <? ( 1 - ) 'pantafin> !
|	fuente>
|	( pantafin> >? scrolldw )
|	( pantaini> <? scrollup )
|	drop 
	;

|-------------- panel control
#panelcontrol

:controlon	1 'panelcontrol ! ;
:controloff 0 'panelcontrol ! ;

|---------- manejo de teclado
:buscapad
	fuente 'findpad findstri
	0? ( drop ; ) 'fuente> ! ;

:findmodekey
	0 hcode 1 + .at 

|	rows hcode - 1 - backlines


	" > " .
	|'buscapad 'findpad .
	.input

	codekey 32 >>
    $d001c =? ( mode!edit )
	|>esc< =? ( mode!edit )
	|>ctrl< =? ( controloff )
    drop
	;

:controlkey
	codekey 32 >>
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

	codekey 48 >>
	1? ( modo ex ; )
	drop

	codekey 32 >>
|	<back> =? ( kback )
	|<del> =? ( kdel )
	$48 =? ( karriba ) 
	$50 =? ( kabajo )
	|<ri> =? ( kder ) <le> =? ( kizq )
	$47 =? ( khome ) 
	$4f =? ( kend )
	|<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	|<ins> =? (  modo
				|'lins =? ( drop 'lover 'modo ! ; )
				|drop 'lins 'modo ! )
	$d001c =? (  13 modo ex )
	|<tab> =? (  9 modo ex )
	|>esc< =? ( exit )

	|<ctrl> =? ( controlon ) >ctrl< =? ( controloff )
	|<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )

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
	'outpad .
	editmodekey
	;

:btnf | "" "fx" --
	sp .bred .white . .bwhitel .black . ;

:barraf | F+
	"Run" "F1" btnf
	"Debug" "F2" btnf
|	"Profile" "F3" btnf
	"Plain" "F4" btnf
	"Compile" "F5" btnf ;

:barrac | control+
	"Cut" "X" btnf
	"opy" "C" btnf
	"Paste" "V" btnf
	"ind" "F" btnf
	'findpad
	dup c@ 0? ( 2drop ; ) drop

	" [%s]" .print ;

:printpanel
	panelcontrol
	0? ( drop barraf ; ) drop
	barrac ;

:barratop
	.bwhitel .black
	sp 'name . sp
	printpanel
	sp
	.cyan
	xcursor 1 + .d . sp
	ycursor 1 + .d . sp
	.reset
	;

|-------------------------------------
:pantalla	
	.reset
	.reset .home .cls 
	0 0 .at barratop
	drawcode
	.bwhitel .black
	0 rows .at xcode ycode " %d:%d " .print
	
	xcode xlinea - xcursor +
	ycode ylinea - ycursor + .at 
	
	;

:editor
	0 'xlinea !
	mode!edit
	pantalla
	( getch 27 <>? drop
		emode
		0? ( editmodekey )
|	1 =? ( immmodekey )
		2 =? ( findmodekey )
		3 =? ( errmodekey )
		drop
 		) drop
	;

:redim
	.getconsoleinfo
	consoleinfo $ffff and 'cols ! 
	'consoleinfo 16 + w@ 'rows ! 
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
	redim
	;

|----------- principal
:main
	'name "mem/main.mem" load drop
	ram
	loadtxt
	editor
|	savetxt
	;

: windows mark 4 main ;
