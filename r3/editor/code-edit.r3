| edit-code
| PHREDA 2007
|---------------------------------------
^r3/lib/console.r3
^r3/lib/math.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

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

#fuente		| fuente editable
#fuente> 	| cursor
#$fuente	| fin de texto

#clipboard	|'clipboard
#clipboard>

#undobuffer |'undobuffer
#undobuffer>

#linecomm 	| comentarios de linea
#linecomm>

|----- scratchpad
#outpad * 2048

#mshift

#lerror 0
#cerror 0

|----- edicion
:lins | c --
	fuente> dup 1- $fuente over - 1+ cmove>
	1 '$fuente +!
:lover | c --
	fuente> c!+ dup 'fuente> !
	$fuente >? ( dup '$fuente ! ) drop
:0lin | --
	0 $fuente c! ;

#modo 'lins

:back
	fuente> fuente <=? ( drop ; )
	dup 1- c@ undobuffer> c!+ 'undobuffer> !
	dup 1- swap $fuente over - 1+ cmove
	-1 '$fuente +!
	-1 'fuente> +! ;

:del
	fuente>	$fuente >=? ( drop ; )
	1+ fuente <=? ( drop ; )
	9 over 1- c@ undobuffer> c!+ c!+ 'undobuffer> !
	dup 1- swap $fuente over - 1+ cmove
	-1 '$fuente +! ;

:<<13 | a -- a
	( fuente >=?
		dup c@ 13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@
		13 =? ( drop 1- ; ) | quitar el 1 -
		drop 1+ ) 2 - ;

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
	fuente> 1- <<13 1+ 'fuente> !
	selecc ;

:kend
	selecc
	fuente> >>13 1+ 'fuente> !
	selecc ;

:scrollup
	pantaini> 2 - <<13 1+
	fuente <? ( drop ; )
	'pantaini> !
	selecc ;

:scrolldw
	pantafin> >>13 2 + 
	$fuente >=? ( drop ; ) 
	'pantafin> !
	pantaini> >>13 2 + 'pantaini> !
	selecc ;

::setpantafin
	pantaini>
	hcode ( 1? swap >>13 1+ swap 1- ) drop
	$fuente <? ( 1- ) 'pantafin> ! ;
	
:setpantaini
	pantafin>
	hcode ( 1? swap 2 - <<13 1+ swap 1- ) drop
	fuente <? ( fuente nip )
	'pantaini> !
	;
	


:fixcur
	fuente>
	pantaini> <? ( <<13 1+ 'pantaini> ! setpantafin ; )
	pantafin> >? ( >>13 2 + 'pantafin> ! setpantaini ; )
	drop
	;

:karriba
	fuente> fuente =? ( drop ; )
	selecc
	dup 1- <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1- <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> !
	selecc ;

:kabajo
	fuente> $fuente >=? ( drop ; )
	selecc
	dup 1- <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1+		| cnt cura
	dup 1+ >>13 1+ 	| cnt cura curb
	over - rot min +
	'fuente> !
	selecc ;

:kder
	selecc
	fuente> $fuente <? ( 1+ 'fuente> ! selecc ; ) drop
	;

:kizq
	selecc
	fuente> fuente >? ( 1- 'fuente> ! selecc ; ) drop
	;

:kpgup
	selecc
	hcode ( 1? 1- karriba ) drop
	selecc ;

:kpgdn
	selecc
	hcode ( 1? 1- kabajo ) drop
	selecc ;

|------------------------------------------------
##path * 1024

:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
:loadtxt | -- ; cargar texto
	fuente 'name 
	load 0 swap c!
	fuente only13 1- '$fuente !	|-- queda solo cr al fin de linea
	fuente dup 'pantaini> ! simplehash 'hashfile !
	;

:savetxt | -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	
	mark	
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
		
	'name savemem
	empty 
	;

|---------- compati
#pad * 64
	
:.char
	0? ( drop ; )
	8 =? ( swap 
		1 - 'pad <? ( 2drop 'pad ; )
		swap .emit "1P" .[w ; )
	dup .emit
	swap c!+ ;
	
::.input | --
	'pad 
	( getch [esc] <>? .char ) drop
	0 swap c! ;
	
:emite | char --
	$5e =? ( drop 27 .emit ; ) | ^=escape
	.emit ;
	
::.printe | "" --
	sprint
	( c@+ 1? emite ) 2drop ;


|----------------------------------
:loadinfo
	linecomm "mem/infomap.db" load 
	0 $fff rot !+ !+ 'linecomm> ! ;
	
:clearinfo
	linecomm 8 +
	0 $fff rot !+ !+ 'linecomm> ! ;

:linetocursor | -- ines
	0 fuente ( fuente> <? c@+
		13 =? ( rot 1+ -rot ) drop ) drop ;
		
:r3info
|WIN|	"r3 r3/editor/r3info.r3"
|LIN|	"./r3lin r3/editor/r3info.r3"
|RPI|	"./r3rpi r3/editor/r3info.r3"
	sys

	rows 1- 'hcode !
	0 'outpad !
	0 'cerror !
	
	mark
|... load file info.
	here "mem/debuginfo.db" load 0 swap c!
	here >>cr trim str>nro 'cerror ! drop
	empty

	loadinfo
	cerror 0? ( drop ; ) drop
|... enter error mode
	fuente cerror + 'fuente> !
	linetocursor 'lerror !
	here >>cr 0 swap c!
	fuente> lerror 1+ here
	" %s in line %d (%w)" sprint 'outpad strcpy
	
	rows 2 - 'hcode !
	;
	

:runfile
	savetxt
	r3info	
	cerror 1? ( drop ; ) drop
	.masb .reset .cls
	mark
|WIN|	"r3 "
|LIN|	"./r3lin "
|RPI|	"./r3rpi "
	,s 'name ,s ,eol
	empty here sys
	.reset
	|"press <ESC> to continue" .write waitesc
	.alsb
	;


:debugfile
	savetxt
|WIN|	"r3 r3/editor/r3debug.r3"
|LIN|	"./r3lin r3/editor/r3debug.r3"
|RPI|	"./r3rpi r3/editor/r3debug.r3"
	sys
	"press <ESC> to continue" .write waitesc
	;

:mkplain
	.masb .reset .cls
	savetxt
|WIN| "r3 r3/editor/r3plain.r3"
|LIN| "./r3lin r3/editor/r3plain.r3"
|RPI| "./r3rpi r3/editor/r3plain.r3"
	sys
	.alsb
	;

:compile
	.masb .reset .cls
	savetxt
|WIN| "r3 r3/system/r3compiler.r3"
|LIN| "./r3lin r3/system/r3compiler.r3"
|RPI| "./r3rpi r3/system/r3compiler.r3"
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
	fuente> ( dup 1- c@ $ff and 32 >? drop 1- ) drop | busca comienzo
	dup c@
	$5E <>? ( 2drop ; ) | no es ^
	drop
	dup fuente - 'ncar !
	dup 2 + posfijo? 0? ( 2drop ; )
	editvalid 0? ( 3drop ; ) drop
	swap 1+ | ext name
	mark
	dup c@ 46 =? ( swap 2 + 'path ,s ) drop
	,word
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
	fuente> dup pick2 + swap | clip cnt 'f+ 'f
	$fuente over - 1+ cmove>	| clip cnt
	fuente> -rot | f clip cnt
	dup '$fuente +!
	cmove
	clipboard> clipboard - 'fuente> +!
	;

|-------------
:controlz | undo
	undobuffer>
	undobuffer =? ( drop ; )
	1- dup c@
	9 =? ( drop 1- dup c@ [ -1 'fuente> +! ; ] >r )
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
	'pad
	dup c@ $ff and
	0? ( 2drop ; )
	toupp
	fuente> 1- | adr 1c act
	( fuente >?
		dup c@ toupp pick2 =? ( exactw 1? ( setcur ; ) )
		drop 1- ) 3drop ;

:controls | -- ;find next
	'pad
	dup c@ $ff and
	0? ( drop ; )
	toupp
	fuente> 1+ | adr 1c act
	( $fuente <?
		dup c@ toupp pick2 =? ( exactw 1? ( setcur ; ) )
		drop 1+ ) 3drop ;

|-------------
:controld | buscar definicion
	;

:controln | new
	| si no existe esta definicion
	| ir justo antes de la definicion
	| agregar palabra :new ;
	;

|---------- TAGS in code	
:,ncar | n -- 
	97 ( swap 1? 1- swap dup ,c 1+ ) 2drop ;

:buildinfo | infmov --
	.bcyan 
	dup $f and .sp
	dup ,ncar " -- " .write
	over 55 << 59 >> + | deltaD
	,ncar .sp 
	.reset .sp .bcyan .black
	$1000000000 and? ( ";" .write )	| multiple
	$2000000000 and? ( "R" .write )		| recurse
	$8000000000 nand? ( "." .write )	| no ;
	drop
	;

#linecommnow 

:prnerr	
	drop
	.sp .bred .white " << Error " .write
	;

:inicomm
	linecomm 8 + | head 
	( @+ $fff and ylinea <=? drop 8 + ) drop
	8 - 'linecommnow !
	;
	
:prntcom | line adr' -- line adr'
	linecommnow @ $fff and 
	pick2 ylinea + 
	>? ( drop ; ) drop
	linecommnow @+
	$100000000 and? ( 
		drop @+ swap 'linecommnow ! 
		prnerr prntcom ; ) drop
	@+ swap 'linecommnow !
	.sp
	dup 12 32 + >> $ff and 
	0? ( .bred .white " X " .write ) drop
	.black
	buildinfo
	prntcom
	;

|------ Color line
#colornow 0

:wcolor
	over c@ 
	32 =? ( drop ; ) 9 =? ( drop ; )
	$22 =? ( drop 15 'colornow ! ; )	| $22 " string
	$5e =? ( drop 3 'colornow ! ; )	| $5e ^  Include
	$7c =? ( drop 8 'colornow ! ; )	| $7c |	 Comentario
	$3A =? ( drop 9 'colornow ! ; )	| $3a :  Definicion
	$23 =? ( drop 13 'colornow ! ; )	| $23 #  Variable
	$27 =? ( drop 14 'colornow ! ; )	| $27 ' Direccion
	drop
	over isNro 1? ( drop 11 'colornow ! ; ) 
	drop 10 'colornow ! ;

:,tcolor colornow .fc ;

| 18 = blue dark for select
:inselect
	inisel finsel in? ( 18 .bc ; )
	0 .bc ;
	
:atselect
	inisel =? ( 18 .bc ; )
	finsel =? ( 0 .bc ; )
	;

:iniline
	xlinea wcolor
	( 1? 1- swap
		c@+ 0? ( drop nip 1- ; )
		13 =? ( drop nip 1- ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		drop swap ) drop ;
	
:,ct
	9 =? ( .sp .sp 32 nip ) .emit ;
	
:strword
	.emit
	( atselect c@+ 1?
		$22 =? (
			over c@ $22 <>? ( drop ; )
			.emit swap 1+ swap )
		13 <>?
		,ct ) drop 1- 0 ;
	
:endline
	.emit ( atselect c@+ 1? 13 <>? ,ct )	
	1? ( drop ; ) drop 1- ;
	
:parseline 
	,tcolor
	( atselect c@+ 1? 13 <>? | 0 o 13 sale
		9 =? ( wcolor ,tcolor .sp .sp drop 32 )
		32 =? ( wcolor ,tcolor )
		$22 =? ( strword ) 		| $22 " string
		$5e =? ( endline ; )	| $5e ^  Include
		$7c =? ( endline ; )	| $7c |	 Comentario
		.emit
		) 
	1? ( drop ; ) drop
	1- ;

|... no color line	
:parselinenc
	( atselect c@+ 1? 13 <>? .emit ) 
	1? ( drop ; ) drop
	1- ;

|..............................
:linenow
	ycursor =? ( $3e .emit ; ) 32 .emit ;
	
:linenro | lin -- lin
	over ylinea + linenow 1+ .d 3 .r. .write 32 .emit ; 

:drawline | adr line -- line adr'
	"^[0m^[37m" .printe			| ,esc "0m" ,s ,esc "37m" ,s  | reset,white,clear
	swap
	linenro	
	iniline
	inselect	
	parseline 
	prntcom
	;

:setpantafin
	pantaini>
	0 ( hcode <?
		swap >>cr 1+ swap
		1+ ) drop
	$fuente <? ( 1- ) 'pantafin> ! ;
	
|..............................
:drawcode
	.reset
	inicomm
	pantaini>
	0 ( hcode <?
		1 ycode pick2 + .at
		drawline
		swap 1+ ) drop
	$fuente <? ( 1- ) 'pantafin> ! 
	;

:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 3 'xcursor +! ; )
	drop 1 'xcursor +! ;

#cacheyl
#cachepi

:getcacheini |  -- pantanini>
	pantaini> cachepi =? ( cacheyl 'ylinea ! ; ) drop
	0 'ylinea !
	fuente 
	( pantaini> <? c@+ 13 =? ( 1 'ylinea +! ) drop ) 
	dup 'cachepi !
	ylinea 'cacheyl !
	;	
	
:cursorpos
	0 'xcursor !
	getcacheini
	ylinea 'ycursor !
	( fuente> <? c@+ emitcur ) drop 
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea wcode + >=? ( dup wcode - 1+ 'xlinea ! )
	drop 
	;
	
|-------------- panel control
#panelcontrol

:controlon	1 'panelcontrol ! ;
:controloff 0 'panelcontrol ! ;

|---------- manejo de teclado
:buscapad
	fuente 'pad findstri
	0? ( drop ; ) 'fuente> ! ;

:findmodekey
	1 hcode 1+ .at .eline
	" > " .write .input 
	controls
	;

:controlkey
|	$101d =? ( controloff ) |>ctrl<
|	$1000 and? ( drop ; )	| upkey
	$ff and
	
	$2d =? ( controlx )		| x-cut
	$2e =? ( controlc )		| c-copy
	$2f =? ( controlv )		| v-paste
	$12 =? ( controle ) | E-Edit
|	$23 =? ( controlh ) | H-Help
	$2c =? ( controlz ) | Z-Undo
	$20 =? ( controld ) | D-Def
	$31 =? ( controln ) | N-New
|	$32 =? ( controlm ) | M-Mode

	$48 =? ( controla )		| up
	$50 =? ( controls )		| dn
	
	$21 =? ( findmodekey )	| f-find
	drop
	;

:teclado
|WIN|	panelcontrol 1? ( drop controlkey ; ) drop
	32 126 in? ( modo ex fixcur ; )
	[enter] =? ( 
|LIN| $d nip | in linux [enter] is $a
		clearinfo modo ex ; ) 
	[BACK] =? ( kback )	
	[DEL] =? ( kdel )
	[UP] =? ( karriba ) 
	[DN] =? ( kabajo )
	[RI] =? ( kder ) 
	[LE] =? ( kizq )
	[HOME] =? ( khome ) 
	[END] =? ( kend )
	[PGUP] =? ( kpgup ) 
	[PGDN] =? ( kpgdn )
	
	[INS] =? ( modo | ins
			'lins =? ( drop 'lover 'modo ! .ovec ; )
			drop 'lins 'modo ! .insc )
||WIN|	[CTRL] =? ( controlon ) 
	
||WIN|	[SHIFTR] =? ( 1 'mshift ! ) ]SHIFTR[ =? ( 0 'mshift ! ) | shift der
||WIN|	[SHIFTL] =? ( 1 'mshift ! ) ]SHIFTR[ =? ( 0 'mshift ! ) | shift izq 

	[F1] =? ( runfile )
	[F2] =? ( debugfile )
|	[F3] =? ( profiler )
	[F4] =? ( mkplain )
	[F5] =? ( compile )
	
	drop
	fixcur
	;


|------------------------
:barraf | F+
	" ^[7mF1^[27m Run ^[7mF2^[27m Debug ^[7mF3^[27m Profile ^[7mF4^[27m Plain ^[7mF5^[27m Compile" .printe ;

:barrac | control+
	" ^[7mX^[27m Cut ^[7mC^[27mopy ^[7mV^[27m Paste ^[7mF^[27mind " .printe
	'pad
	dup c@ 0? ( 2drop ; ) drop
	" [%s]" .print ;

:topbar
	1 hcode 2 + .at .bblue .white .eline
	panelcontrol
	0? ( drop barraf ; ) drop
	barrac ;

:fotbar
	1 1 .at 
	.bblue .white .eline
	.sp 'name .write ycursor xcursor "  %d:%d " .print 
	$fuente fuente - " %d chars" .print 
	clipboard> clipboard - " %d " .print
	mshift " %d " .print
	| error-
	cerror 0? ( drop ; ) drop
	1 hcode 3 + .at .bred .white .eline 'outpad .write
	;

:pantalla	
	.hidec .reset .cls
	cursorpos
	
	topbar
	drawcode
	fotbar
	
	xcode xlinea - xcursor +
	ycode ylinea - ycursor + .at 
	.showc
	.flush
	;

#exit 0

:evkey	
	getch [ESC]	=? ( 1 'exit ! )
	teclado ;
	
::>>cr | adr -- adr'
	( c@+ 1? 13 =? ( drop ; ) drop ) drop 1- ;
	
:xycursor | x y -- cursor
	pantaini> | x y c
	( swap 1? 1- swap >>cr ) drop | x c
	swap 5 - clamp0 swap
	( swap 1? 1- swap 
		c@+ 
		9 =? ( rot 2 - clamp0 -rot )
		13 =? ( 0 nip )
		0? ( drop nip 1- ; ) 
		drop ) drop ;

			
:evwmouse 
	evtmw 
	-? ( drop scrolldw scrolldw ; ) drop
	scrollup scrollup ;

:evmouse
	inevt
	1 =? ( drop ; ) | move 
	4 =? ( drop evwmouse ; )
	drop
	evtmb $0 =? ( drop ; ) drop 
	evtmxy
	1 <? ( 2drop ; )
	1- xycursor
	'fuente> ! 
	;

:evsize	
	rows 1- 'hcode !
	cols 7 - 'wcode !
	;
	
:editor
	setpantafin
	rows 1- 'hcode !
	cols 7 - 'wcode !
	0 'xlinea !
	.showc .insc
	( exit 0? drop 
		pantalla
		inevt
		$1 =? ( evkey )
		$2 =? ( evmouse )
		$4 =? ( evsize )
		drop 
		) drop ;

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
	$ffff +				| 64kb
	dup 'linecomm !
	dup	'linecomm> !
	$3fff +				| 4096 linecomm
	'here ! | -- FREE
	mark 

	loadtxt
	loadinfo
	;

|----------- principal
:main
	'name "mem/main.mem" load drop
	
|WIN|	"r3 r3/editor/r3info.r3"
|LIN|	"./r3lin r3/editor/r3info.r3"
|RPI|	"./r3rpi r3/editor/r3info.r3"
	sys
	
	ram
	.alsb 
	editor 
	.masb
	savetxt
	;

: 4 main ;
