| edit-code in sdl
| PHREDA 2007,2023
|---------------------------------------
^r3/lib/sdl2gfx.r3
^r3/lib/gui.r3
^r3/lib/parse.r3
^r3/lib/color.r3

|^r3/util/bfont.r3
^r3/util/ttext.r3

| size win
#xcode 1 #ycode 3 #wcode 40 #hcode 20

| color 
|#colb0 $1f1f1f |sdlcolor | backcode
|#colb1 $000000 |sdlcolor | backnowline
#colb2 $585858 |SDLColor | backselect

#colf0 $EF7D57 |:col_inc $EF7D57 trgb ;
#colf1 $667C96 |:col_com $667C96 trgb ;
#colf2 $ff0000 |:col_cod $ff0000 trgb ;
#colf3 $ff00ff |:col_dat $ff00ff trgb ;
#colf4 $ffffff |:col_str $ffffff trgb ;
#colf5 $73EFF7 |:col_adr $73EFF7 trgb ;
#colf6 $A7F070 |:col_nor $A7F070 trgb ;
#colf7 $ffff00 |:col_nro $ffff00 trgb ;

#xlinea 0 #ylinea 0	| primera linea visible
##ycursor ##xcursor

##edfilename * 1024

#pantaini>	| comienzo de pantalla
#pantafin>	| fin de pantalla

##inisel		| inicio seleccion
##finsel		| fin seleccion

##fuente  	| fuente editable
##fuente> 	| cursor
#$fuente	| fin de texto

#clipboard	|'clipboard
#clipboard>

#undobuffer |'undobuffer
#undobuffer>

#findpad * 64 |----- find text

#mshift

|----- edicion
:lins  | c --
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
		dup c@
		13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@
		13 =? ( drop 1- ; ) | quitar el 1 -
		drop 1+ )
	2 - ;

#1sel #2sel

:selecc	| agrega a la seleccion
	mshift 0? ( dup 'inisel ! 'finsel ! ; ) drop
	inisel 0? ( fuente> '1sel ! ) drop
	fuente> dup '2sel !
	1sel over <? ( swap )
	'finsel ! 'inisel !
	;

:khome
	fuente> 1- <<13 1+ 'fuente> ! ;

:kend
	fuente> >>13 1+ 'fuente> ! ;

:scrollup | 'fuente -- 'fuente
	pantaini> 1- <<13 1- <<13 1+ 
	fuente <=? ( drop ; )
	'pantaini> ! ;

:scrolldw
	pantafin> >>13 2 + 
	$fuente >=? ( drop ; ) 
	'pantafin> !
	pantaini> >>13 2 + 'pantaini> !
	;
	
:setpantafin
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
	dup 1- <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1- <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> ! ;

:kabajo
	fuente> $fuente >=? ( drop ; )
	dup 1- <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1+    | cnt cura
	dup 1+ >>13 1+ 	| cnt cura curb
	over -
	rot min +
	'fuente> ! ;

:kder	fuente> $fuente <? ( 1+ 'fuente> ! ; ) drop ;
:kizq	fuente> fuente >? ( 1- 'fuente> ! ; ) drop ;
:kpgup	hcode 1- ( 1? 1- karriba ) drop ;
:kpgdn	hcode 1- ( 1? 1- kabajo ) drop ;

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
	'findpad
	dup c@ $ff and
	0? ( 2drop ; )
	toupp
	fuente> 1- | adr 1c act
	( fuente >?
		dup c@ toupp pick2 =? ( exactw 1? ( setcur ; ) )
		drop 1- ) 3drop ;

:controls | -- ;find next
	'findpad
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

:controln  | new
	| si no existe esta definicion
	| ir justo antes de la definicion
	| agregar palabra :new  ;
	;

|------ Color line
:col_inc $EF7D57 trgb ;
:col_com $667C96 trgb ;
:col_cod $ff0000 trgb ;
:col_dat $ff00ff trgb ;
:col_str $ffffff trgb ;
:col_adr $73EFF7 trgb ;
:col_nor $A7F070 trgb ;
:col_nro $ffff00 trgb ;

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
	( 1? 1- swap
		c@+ 0? ( drop nip 1- ; )
		13 =? ( drop nip 1- ; )
		9 =? ( wcolor )
		32 =? ( wcolor )
		$22 =? ( strcol )
		drop swap ) drop ;

:drawline
	dup c@ 0? ( drop ; ) drop
	$afafaf trgb
	
	over ylinea + 1+ .d 4 .r. temits tsp 

	iniline
	( c@+ 1?
		13 =? ( drop ; )
		9 =? ( drop 3 tnsp 32 wcolor )
		32 =? ( wcolor )
		$22 =? ( strcol )
		temit
		) drop 1- ;

|..............................
::edcodedraw
	pantaini>
	0 ( hcode <?
		xcode ycode pick2 + txy
		swap drawline swap 1+ ) drop
	$fuente <? ( 1- ) 'pantafin> !
	;
	
::edfill
	xcode advx * ycode advy *
	wcode advx * hcode advy *
	sdlFrect ;
	
|-------------- panel control
#panelcontrol

:controlon	1 'panelcontrol ! ;
:controloff 0 'panelcontrol ! ;

|--------------- MOUSE
:mmemit | adr x xa -- adr x xa
	rot c@+
	13 =? ( 0 nip )
	0? ( drop 1- -rot sw + ; )
	9 =? ( drop swap advx 3 * + rot swap ; ) | 4*ccw is tab
	drop swap advx + rot swap ;

:cursormouse
	SDLx xcode advx * - | xmouse
	pantaini>
	SDLy
	ycode 1+ advy * 
	( over <? advy + rot >>13 2 + -rot ) 2drop
	swap advx 2* dup 2* + | adr x xa
	( over <? mmemit ) 2drop
	'fuente> ! 
	fixcur ;
	
#tclick

:dclick 
	fuente>
	( dup c@ $ff and 32 >? drop 1- ) drop
	1+ dup 'inisel ! 
	( c@+ $ff and 32 >? drop ) drop
	2 - 'finsel !
	|"double click" .println
	;
	
:dns
	cursormouse
	fuente> '1sel ! ;

:mos
	cursormouse
	fuente> 1sel over <? ( swap )
	'finsel ! 'inisel ! ;

:ups
	msec dup tclick - 400 <? ( 2drop dclick ; ) drop 'tclick !
	cursormouse
	fuente> 1sel 
	over =?  ( 2drop 0 'inisel ! ; )
	over <? ( swap )
	'finsel ! 'inisel ! ;
	
:evwmouse 
	SDLw 0? ( drop ; )
	-? ( ( 1? 1+ scrolldw scrolldw ) drop ; )
	( 1? 1- scrollup scrollup ) drop ;	

|---------- manejo de teclado
:controlkey
	SDLkey
	>ctrl< =? ( controloff )
|	<f> =? ( mode!find )
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

|--------------------------
:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 4 'xcursor +! ; )
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
	( fuente> <? c@+ emitcur ) drop ;
	
:src2pos | src -- 
	0 'xcursor ! 0 'ycursor !
	fuente ( over <? c@+ emitcur ) 2drop ;
	
|--------------------------	
:kins
	modo
	'lins =? ( 2drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;
	
:editmodekey
	panelcontrol 1? ( drop controlkey ; ) drop
	SDLchar 1? ( modo ex fixcur ; ) drop

	SDLkey 0? ( drop ; )
|	>esc< =? ( exit )
	<ctrl> =? ( controlon ) >ctrl< =? ( controloff )
	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )

	selecc
	<back> =? ( kback )
	<del> =? ( kdel )
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	<ins> =? ( kins )
	<ret> =? (  13 modo ex )
	<tab> =? (  9 modo ex )
	fixcur selecc
	drop
	cursorpos
	;
	
	
::edtoolbar
	$747474 SDLColor
	xcode advx * ycode advy *
	wcode advx * advy 
	sdlFrect 
	
	xcode ycode txy |printmode
	$0 trgb 'edfilename " %s" tprint
	xcode wcode + 8 - tx
	$ffff trgb tsp
	xcursor 1+ .d temits tsp
	ycursor 1+ .d temits tsp
	
|	xcode ycode 1- wcode 1 bfillline
|	xcode ycode hcode + gotoxy
|	panelcontrol 1? ( drop barrac ; ) drop
	;

|-------------------------------------
#sx1 #sy1 #sw1 
	
:selectfill
	sx1 xcode + 5 + advx * 
	sy1 advy *
	sw1 xcode - 1+ advx * 
	advy 
	sdlFrect ;
	
:startsel
	0 'sx1 ! ycode 'sy1 ! 
	pantaini> 
	inisel >=? ( ; )
	( inisel <? c@+ 
		13 =? ( 1 'sy1 +! 0 'sx1 ! )
		9 =? ( 3 'sx1 +! )
		drop 
		1 'sx1 +!
		) 
	-1 'sx1 +! 
	;
	
	
:edselshow
	inisel 0? ( drop ; )
	pantafin> >? ( drop ; ) drop
	colb2 SDLColor
	startsel
	0 'sw1 !
	( pantafin> <? finsel <? c@+
		13 =? ( wcode sx1 - 6 - 'sw1 ! selectfill 1 'sy1 +! 0 'sx1 ! -1 'sw1 ! )
		9 =? ( 3 'sw1 +! )
		drop
		1 'sw1 +!
		) 
	finsel <? ( wcode sx1 - 6 - 'sw1 ! )
	drop
	selectfill
	;

:edlinecursor
	fuente> pantaini> <? ( drop ; ) pantafin> >? ( drop ; ) drop
	cursorpos
|	colb1 sdlcolor
|	xcode 1 + ycursor ylinea - ycode + wcode 2 - 1 bfillline
	msec $100 and? ( drop ; ) drop
	xcode 5 + ycursor ylinea - ycode + txy
	$ffffff SDLColor 
	'lover modo	=? ( xcursor tcursor drop ; ) drop
	xcursor tcursori
	;
	
::edfocus
	xcode ycode wcode hcode tsrcsize guiBox
	guin? 0? ( drop ; ) drop
	$ffffff sdlcolor 
	xcode ycode wcode hcode tsrcsize sdlRect 
	'dns 'mos 'ups guiMap |------ mouse
	evwmouse 
	editmodekey
	edlinecursor
	edselshow
	;

|----------- marcas
| y|x|ini|cnt|colorf|colorb
| ttco1co2wwhhxxyy
| 8(t)12(col1)12(col2)8(w)8(h)8(x)8(y)
#marcas * $ff | 32 marcadores
#marcas> 'marcas

::clearmark	'marcas 'marcas> ! ;
::addmark	marcas> !+ 'marcas> ! ;

::addsrcmark | src color --
	32 << swap
	dup >>sp over - 24 << 
	swap src2pos
	ycursor or 
	xcursor 8 << or 
	$010000 or	| h
	or addmark ;

:linemark | mark --
	dup $ff and ylinea -
	-? ( 2drop ; ) hcode >=? ( 2drop ; ) | fuera de pantalla
	over >a
	ycode + advy *  | y real
	over 8 >> $ff and 
	xcode + 5 + advx * | x real
	swap rot | x y vv
	dup 24 >> $ff and advx * | w
	swap 16 >> $ff and advy * | h
	pick3 1- pick3 1- pick3 2 + pick3 2 +
	a> 32 >> 4bcol sdlcolor sdlRect
	a> 48 >> 4bcol sdlcolor sdlFRect
	;
	
::showmark
	ab[ 'marcas ( marcas> <? @+ linemark ) drop ]ba ;

	
|----------- principal
::edram
	here	| --- RAM
	dup 'fuente !
	dup 'fuente> !
	dup '$fuente !
	dup 'pantaini> !
	$ffff +			| 64kb texto
	dup 'clipboard !
	dup 'clipboard> !
	$1fff +			| 8KB
	dup 'undobuffer !
	dup 'undobuffer> !
	$1fff +			| 8kb
	'here !			| -- FREE
	0 here !
	mark
	;

::edwin | x y w h --
	'hcode ! 'wcode !
	'ycode ! 'xcode !
	;

|------------------------------------------------
#hashfile
:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
::edload | "" --
	'edfilename strcpy
	fuente 'edfilename |getpath
	load 0 swap c!
	fuente only13 1- '$fuente ! |-- queda solo cr al fin de linea
	fuente dup 'pantaini> ! simplehash 'hashfile !
	;

::edsave | --
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	| guarda texto
	fuente ( c@+ 1? 13 =? ( ,c 10 ) ,c ) 2drop
	'edfilename savemem
	empty ;