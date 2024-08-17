| edit-code
| PHREDA 2007
|---------------------------------------
^r3/lib/math.r3
^r3/lib/mem.r3
^r3/lib/gui.r3
^r3/lib/input.r3
^r3/lib/parse.r3
^r3/lib/trace.r3

| ventana de texto
#xcode 1
#ycode 1
#wcode 40
#hcode 20
#xseli	| x ini win
#xsele	| x end win

#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor
#mshift

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


|----------------------------------
:calcselect
	xcode wcode + gotox ccx 'xsele !
	xcode gotox ccx 'xseli !
	;

:mode!edit
	0 'emode ! ;
:mode!find
	2 'emode ! ;
:mode!error
	3 'emode ! ;


|----------------------------------
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
	fuente> -rot | f clip cnt
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
:col_inc $ff7f00 'ink ! ;
:col_com $666666 'ink ! ;
:col_cod $ff0000 'ink ! ;
:col_dat $ff00ff 'ink ! ;
:col_str $ffffff 'ink ! ;
:col_adr $ffff 'ink ! ;
:col_nor $ff00 'ink ! ;
:col_nro $ffff00 'ink ! ;
:col_select $444444 'ink ! ;

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
	9 =? ( drop gtab ; )
	emit ccx xsele <? ( drop ; ) drop
	( c@+ 1? 13 <>? drop ) drop 1 -		| eat line to cr or 0
	wcode xcode + gotox
	$ffffff 'ink ! "." print
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
	$aaaaaa 'ink !
	dup ylinea + 1 + .d 3 .r. emits ;

|..............................
:emitsel
	13 =? ( drop cr xcode xlinea - gotox ; )
	9 =? ( drop gtab ; )
	noemit ;

:drawselect
	inisel 0? ( drop ; )
	pantafin> >? ( drop ; )
	xcode xlinea - ycode gotoxy
	pantaini> ( over <? c@+ emitsel ) nip
	xseli ccy cch + dup >r op
	ccx ccy cch + pline
	ccx ccy pline xsele ccy pline
	( pantafin> <? finsel <? c@+ emitsel ) drop
	xsele ccy pline ccx ccy pline
	ccx ccy cch + pline
	xseli ccy cch + pline
	xseli r> pline
	col_select poli
	;

|..............................
:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 4 'xcursor +! ; )
	1 'xcursor +!
	noemit ;

:drawcursor
	ylinea 'ycursor ! 0 'xcursor !
	pantaini> ( fuente> <? c@+ emitcur ) drop

	| hscroll
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea wcode + 4 - >=? ( dup wcode - 5 + 'xlinea ! ) | 4 linenumber
	drop

	blink 1? ( drop ; ) drop

	xcode 4 + xlinea - xcursor +
	ycode ylinea - ycursor + gotoxy
	ccx ccy xy>v >a
	cch ( 1? 1 -
		ccw ( 1? 1 -
			a@ not a!+
			) drop
		sw ccw - 2 << a+
		) drop ;


:drawcode
	drawselect
	pantaini>
	0 ( hcode <?
		xcode ycode pick2 + gotoxy
		linenro
		xcode 4 + gotox
		swap drawline
		swap 1 + ) drop
	drawcursor
	$fuente <? ( 1 - ) 'pantafin> !
	fuente>
	( pantafin> >? scrolldw )
	( pantaini> <? scrollup )
	drop ;

|-------------- panel control
#panelcontrol

:controlon	1 'panelcontrol ! ;
:controloff 0 'panelcontrol ! ;

|--- sobre pantalla
:mmemit | adr x xa -- adr x xa
	rot c@+
	13 =? ( 0 nip )
	0? ( drop 1 - -rot sw + ; )
	9 =? ( drop swap ccw 2 << + rot swap ; ) | 4*ccw is tab
	drop swap ccw + rot swap ;

:cursormouse
	xypen
	pantaini>
	swap cch 1 <<			| x adr y ya
	( over <?
		cch + rot >>13 2 + -rot ) 2drop
	swap ccw 1 << dup 1 << + | adr x xa
	( over <? mmemit ) 2drop
	'fuente> ! ;

:dns
	cursormouse
	fuente> '1sel ! ;

:mos
	cursormouse
	fuente> 1sel over <? ( swap )
	'finsel ! 'inisel ! ;

:ups
	cursormouse
	fuente> 1sel over <? ( swap )
	'finsel ! 'inisel ! ;

|---------- manejo de teclado
:buscapad
	fuente 'findpad findstri
	0? ( drop ; ) 'fuente> ! ;

:findmodekey
	0 hcode 1 + gotoxy
	$0000AE 'ink !
	rows hcode - 1 - backlines

	$ffffff 'ink !
	" > " emits
	'buscapad 'findpad 31 inputex

	key
    <ret> =? ( mode!edit )
	>esc< =? ( mode!edit )
	>ctrl< =? ( controloff )
    drop
	;

:controlkey
	key
	>ctrl< =? ( controloff )
	<f> =? ( mode!find )
	<x> =? ( controlx )
	<c> =? ( controlc )
	<v> =? ( controlv )

	<up> =? ( controla )
	<dn> =? ( controls )

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
	'dns 'mos 'ups guiMap |------ mouse
	char
	1? ( modo ex ; )
	drop

	key
	<back> =? ( kback )
	<del> =? ( kdel )
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	<ins> =? (  modo
				'lins =? ( drop 'lover 'modo ! ; )
				drop 'lins 'modo ! )
	<ret> =? (  13 modo ex )
	<tab> =? (  9 modo ex )
	>esc< =? ( exit )

	<ctrl> =? ( controlon ) >ctrl< =? ( controloff )
	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )

	drop
	;

:errmodekey
	xcode hcode 1 + gotoxy
	$AE0000 'ink !
	rows hcode - 1 - backlines

	$ffffff 'ink !
	'outpad text
	editmodekey
	;

:btnf | "" "fx" --
	.sp
	$ff0000 'ink ! backprint
	$ffffff 'ink ! emits
	$ff00 'ink ! emits
	;

:barrac | control+
	"Cut" "X" btnf
	"opy" "C" btnf
	"Paste" "V" btnf
	"ind" "F" btnf
	'findpad
	dup c@ 0? ( 2drop ; ) drop
	$ffffff 'ink !
	" [%s]" print ;


:barra
	xcode ycode 1 - gotoxy
	$ff00 'ink !
	":r3 editor" emits
	xcode wcode + 8 - gotox
	$ffff 'ink ! .sp
	xcursor 1 + .d emits .sp
	ycursor 1 + .d emits .sp
	xcode ycode hcode + gotoxy
	panelcontrol 1? ( drop barrac ; ) drop
    $ff00 'ink !
	'name emits
	;

|------------------------------------------------
::edload | "" --
	'name strcpy
	fuente 'name load 0 swap c!
	fuente only13 1 - '$fuente !	|-- queda solo cr al fin de linea
	fuente 'pantaini> !
	;

::edsave | --
	mark	| guarda texto
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
	'name savemem
	empty ;


|-------------------------------------
:editando
	cls gui

	$101010 'ink !
	xcode ycode over wcode + over hcode + backfill
	barra

	drawcode
	emode
	0? ( editmodekey )
	2 =? ( findmodekey )
	3 =? ( errmodekey )
	drop
	acursor
	;

|----------- principal
::edrun
	0 'xlinea !
	mode!edit
	'editando onshow
	;

::edram
	here	| --- RAM
	dup 'fuente !
	dup 'fuente> !
	dup '$fuente !
	dup 'pantaini> !
	$ffff +			| 64kb texto
	dup 'clipboard !
	dup 'clipboard> !
	$3fff +				| 16KB
	dup 'undobuffer !
	dup 'undobuffer> !
	$1fff +         	| 16kb
	'here  ! | -- FREE
	0 here !
	mark
	;

::edwin | x y w h --
	'hcode ! 'wcode !
	'ycode ! 'xcode !
	calcselect
	;

|----------------- TEST
: mark
	fontj2
	1 2 40 25 edwin
	edram
	"r3/r3arena/test1.r3i" edload

	edrun ;
