| edit-code in sdl
| PHREDA 2007,2023
|---------------------------------------
^r3/win/sdl2gfx.r3
^r3/util/bfont.r3
^r3/lib/gui.r3
^r3/lib/parse.r3

| ventana de texto
#xcode 1 #ycode 3
#wcode 40 #hcode 20

#xlinea 0 #ylinea 0	| primera linea visible
##ycursor ##xcursor

##edfilename * 1024

#pantaini>	| comienzo de pantalla
#pantaini>	| comienzo de pantalla
#pantafin>	| fin de pantalla

#inisel		| inicio seleccion
#finsel		| fin seleccion

##fuente  	| fuente editable
##fuente> 	| cursor
#$fuente	| fin de texto

#clipboard	|'clipboard
#clipboard>

#undobuffer |'undobuffer
#undobuffer>

#findpad * 64 |----- find text

#mshift
##edmode 0

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
	fuente> >>13 1 + 'fuente> !
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
:mode!edit
	0 'edmode ! ;
:mode!find
	2 'edmode ! ;
:mode!error
	3 'edmode ! ;


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
:col_inc $EF7D57 bcolor ;
:col_com $667C96 bcolor ;
:col_cod $ff0000 bcolor ;
:col_dat $ff00ff bcolor ;
:col_str $ffffff bcolor ;
:col_adr $73EFF7 bcolor ;
:col_nor $A7F070 bcolor ;
:col_nro $ffff00 bcolor ;

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

:showcursor
	inisel >=? ( finsel <=? ( $566C86 SDLColor bfbox ) )
	fuente> <>? ( ; )
	msec $100 and? ( drop ; ) drop
	$ffffff SDLColor 
	'lover modo	=? ( bbox drop ; ) drop
	bfbox ;
	
:drawline
	iniline
	( showcursor
		c@+ 1?
		13 =? ( drop ; )
		9 =? ( wcolor drop 3 bnsp 32 )
		32 =? ( wcolor )
		$22 =? ( strcol )
		bemit
		) drop 1 - ;

|..............................
:linenro | lin -- lin
	$afafaf bcolor
	dup ylinea + 1 + .d 4 .r. bemits ;

::edcodedraw
	$333C57 sdlcolor 
	xcode 5 + ycode 
	wcode 5 - hcode 1 + bfillline
	$566C86 sdlcolor 
	xcode ycode 
	5 hcode 1 + bfillline	
	pantaini>
	0 ( hcode <?
		xcode ycode pick2 + 1 + gotoxy
		linenro
		xcode 5 + gotox
		swap drawline
		swap 1 + ) drop
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
	9 =? ( drop swap wp 3 * + rot swap ; ) | 4*ccw is tab
	drop swap wp + rot swap ;

:cursormouse
	SDLx xcode wp * - 
	SDLy ycode 1 - hp * - | upper info bar
	pantaini>
	swap hp 1 <<			| x adr y ya
	( over <?
		hp + rot >>13 2 + -rot ) 2drop
	swap wp 1 << dup 1 << + | adr x xa
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
	$0000AE SDLColor
	rows hcode - 1 - bfillline

	$ffffff bcolor
	" > " bemits
|	'buscapad 'findpad 31 inputex

	SDLkey
    <ret> =? ( mode!edit )
|	>esc< =? ( mode!edit )
	>ctrl< =? ( controloff )
    drop
	;

:controlkey
	SDLkey
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


:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 4 'xcursor +! ; )
	drop 1 'xcursor +! ;

:cursorpos
	ylinea 'ycursor ! 0 'xcursor !
	pantaini> ( fuente> <? c@+ emitcur ) drop ;
	
:editmodekey
	panelcontrol 1? ( drop controlkey ; ) drop
	
	SDLchar 1? ( modo ex ; ) drop

	SDLkey 0? ( drop ; )
|	>esc< =? ( exit )
	<ctrl> =? ( controlon ) >ctrl< =? ( controloff )
	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )

	<back> =? ( kback )
	<del> =? ( kdel )
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	<ins> =? (  modo
				'lins =? ( 2drop 'lover 'modo ! ; )
				drop 'lins 'modo ! )
	<ret> =? (  13 modo ex )
	<tab> =? (  9 modo ex )
	drop
	cursorpos
	;
	
:viewmodekey
	SDLkey 0? ( drop ; )
|	>esc< =? ( exit )
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	drop
	;

:errmodekey |*******
	$AE0000 SDLColor
	xcode ycode hcode + 1 + wcode 1 bfillline
	xcode ycode hcode + 1 + gotoxy
	|$ffffff bcolor ederror "%w" sprint bemits
	editmodekey
	;

:btnf | "" "fx" --
	bsp
	$ff0000 bcolor bfillemit
	$ffffff bcolor bemits
	$ff00 bcolor bemits
	;

:barrac | control+
	$747474 SDLColor
	xcode ycode hcode + wcode 1 bfillline
	xcode ycode hcode + gotoxy
	" Ctrl-" bemits
	"Cut" "X" btnf
	"opy" "C" btnf
	"Paste" "V" btnf
	"ind" "F" btnf
	'findpad
	dup c@ 0? ( 2drop ; ) drop
	$ffffff bcolor
	" [%s]" bprint ;


:printmode
	edmode
	0? ( $ffffff bcolor " EDIT " bemits )
	2 =? ( $7f7f00 bcolor " FIND " bemits )
	3 =? ( $7f0000 bcolor " ERROR " bemits )
	4 =? ( $00ff00 bcolor " DEBUG " bemits )
	drop ;
	
::edtoolbar
	$747474 SDLColor
	xcode ycode wcode 1 bfillline
	xcode ycode gotoxy |printmode
	$0 bcolor 'edfilename " %s" bprint
	xcode wcode + 8 - gotox
	$ffff bcolor bsp
	xcursor 1 + .d bemits bsp
	ycursor 1 + .d bemits bsp
	
|	xcode ycode 1 - wcode 1 bfillline
|	xcode ycode hcode + gotoxy
	panelcontrol 1? ( drop barrac ; ) drop
	;

|------------------------------------------------
#hashfile
:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
::edload | "" --
	'edfilename strcpy
	fuente 'edfilename |getpath
	load 0 swap c!
	fuente only13 1 - '$fuente ! |-- queda solo cr al fin de linea
	fuente dup 'pantaini> ! simplehash 'hashfile !
	;

::edsave | --
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	| guarda texto
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
	'edfilename savemem
	empty ;

|-------------------------------------
::edshow
	xcode ycode wcode hcode bsrcsize guiBox
	'dns 'mos 'ups guiMap |------ mouse
	edcodedraw
	edtoolbar

	edmode
	0? ( editmodekey )
	2 =? ( findmodekey )
	3 =? ( errmodekey )
	4 =? ( viewmodekey )
	drop ;
	
:editando
	0 SDLcls edshow SDLredraw ;

|----------- principal
::edreset
	0 'xlinea !
	0 'ylinea !
	mode!edit
	;
	
::edrun
	edreset
	'editando SDLshow
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
	$1fff +         	| 8kb
	'here  ! | -- FREE
	0 here !
	mark
	;

::edwin | x y w h --
	'hcode ! 'wcode !
	'ycode ! 'xcode !
	;

