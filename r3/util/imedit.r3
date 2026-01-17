| edit-code in sdl,immi
| PHREDA 2007,2025
|---------------------------------------
^r3/lib/parse.r3
^r3/lib/color.r3
^r3/util/immi.r3

| size win
#xcode #ycode #wcode #hcode 
#xcodel

| color 
|#colb0 $1f1f1f |sdlcolor | backcode
|#colb1 $000000 |sdlcolor | backnowline
#colb2 $333333 |SDLColor | backselect

#xlinea 0 #ylinea 0	| primera linea visible
##ycursor ##xcursor

##edfilename * 1024

#scrini>	| comienzo de pantalla
#scrend>	| fin de pantalla

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
		dup c@ 13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@ 13 =? ( drop ; ) | quitar el 1 -
		drop 1+ ) 1- ;

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
	fuente> >>13 'fuente> ! ;

:scrollup 
	scrini> 2 - <<13 1+ 
	fuente <? ( drop ; ) 'scrini> ! ;

:scrolldw
	scrend> >>13 1+ 
	$fuente >=? ( drop ; ) 'scrend> !
	scrini> >>13 1+ 'scrini> ! 	;
	
|-----------	
:setpantafin
	1- <<13 1+ dup 'scrini> ! 
	hcode ( +? swap >>13 swap txh - ) drop
	|$fuente <? ( 1- ) 
	'scrend> ! ;
	
:setpantaini
	>>13 1+ dup 'scrend> ! 
	hcode ( +? swap 2 - <<13 1+ swap txh - ) drop
	fuente <? ( fuente nip )
	'scrini> ! ;

:fixcur
	fuente>
	scrini> <? ( setpantafin ; )
	scrend> >=? ( setpantaini ; )
	drop ;
	
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
	>>13     | cnt cura
	dup 1+ >>13 	| cnt cura curb
	over - rot min +
	'fuente> ! ;

:kder	fuente> $fuente <? ( 1+ 'fuente> ! ; ) drop ;
:kizq	fuente> fuente >? ( 1- 'fuente> ! ; ) drop ;
:kpgup	hcode ( +? txh - karriba ) drop ;
:kpgdn	hcode ( +? txh - kabajo ) drop ;

|----------------------------------
:copysel
	inisel 0? ( drop ; )
	clipboard swap
	finsel over - pick2 over + 'clipboard> !
	cmove ;

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
| $332A3F txrgb ; | back
:col_cod $C65B79 txrgb ; | rojo
:col_dat $BC4FC6 txrgb ; | violeta
:col_str $D2D7E1 txrgb ; | blanco
:col_nor $5EB489 txrgb ; |verde
:col_adr $0FA0CF txrgb ; | celeste
:col_inc $BBB470 txrgb ; |amarillo
:col_nro $C3B96E txrgb ; | amarillo
:col_com $667C96 txrgb ;

:col_inc $EF7D57 txrgb ;
:col_com $667C96 txrgb ;
:col_cod $ff0000 txrgb ;
:col_dat $ff00ff txrgb ;
:col_str $ffffff txrgb ;
:col_adr $73EFF7 txrgb ;
:col_nor $A7F070 txrgb ;
:col_nro $ffff00 txrgb ;

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

:txsp 32 txemit ;
:txtab "   " txwrite ;

:drawline | src nline ylin -- src nline ylin
	pick2 c@ 0? ( drop ; ) drop | linea vacia
	$afafaf txrgb
	swap 1+ dup .d 4 .r. txwrite	| src ylin nline 
	xcodel ycode pick3 + txat
	rot iniline						| ylin nline src 
	( c@+ 1?
		13 =? ( drop swap rot ; )
		9 =? ( drop txtab 32 wcolor )
		32 =? ( wcolor )
		$22 =? ( strcol )
		txemit
		) drop 1-  
	swap rot ; | src nline ylin

|..............................
::edcodedraw
	scrini>
	ylinea
	0 ( hcode <=? | src nline ylin
		xcode ycode pick2 + txat
		drawline
		txh + ) 2drop
	$fuente <? ( 1- ) 'scrend> !
	;
	
::edfill
	xcode ycode wcode hcode sdlFrect ;
	
|-------------- panel control
#panelcontrol

:controlon	1 'panelcontrol ! ;
:controloff 0 'panelcontrol ! ;

|--------------- MOUSE
:mmemit | adr x xa -- adr x xa
	rot c@+				| x xa adr' c
	13 =? ( 0 nip )
	0? ( drop 1- -rot sw + ; )
	txcw rot +			| x adr' xa'
	rot swap ;

:cursormouse
	SDLx xcode - | xmouse
	scrini>
	SDLy
	ycode txh +
	( over <? txh + rot >>13 1+ -rot ) 2drop
	swap 0 txcw 2* dup 2* + | adr x xa
	( over <? mmemit ) 2drop
	'fuente> ! 
	fixcur ;
	
#tclick

:dclick |"double click" .println
	fuente>
	( dup c@ $ff and 32 >? drop 1- ) drop
	1+ dup 'inisel ! 
	( c@+ $ff and 32 >? drop ) drop
	1- 'finsel !
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
#cursorlin

:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! dup 'cursorlin ! ; )
	9 =? ( drop 4 'xcursor +! ; )
	drop 1 'xcursor +! ;

#cacheyl
#cachepi

:getcacheini |  -- pantanini>
	scrini> cachepi =? ( cacheyl 'ylinea ! ; ) drop
	0 'ylinea !
	fuente 
	( scrini> <? c@+ 13 =? ( 1 'ylinea +! ) drop ) 
	dup 'cachepi !
	ylinea 'cacheyl !
	;
	
:cursorpos
	0 'xcursor !
	getcacheini
	ylinea 'ycursor !
	dup 'cursorlin !
	( fuente> <? c@+ emitcur ) drop ;
	
:src2pos | src -- 
	0 'xcursor ! 0 'ycursor !
	fuente ( over <? c@+ emitcur ) 2drop ;
	
|--------------------------	
:kins
	modo
	'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;
	
:editmodekey
	panelcontrol 1? ( drop controlkey ; ) drop
	SDLchar 1? ( modo ex fixcur ; ) drop

	SDLkey 0? ( drop ; )
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
	<ret> =? ( 13 modo ex )
	<tab> =? ( 9 modo ex )
	fixcur selecc
	drop
	cursorpos
	;

::edtoolbar
	$555555 SDLColor
	xcode ycode txh - wcode txh sdlFrect 
	$ffffff txrgb 
	xcode ycode txh - txat |printmode
	'edfilename " %s" txprint
	": " txwrite
	xcursor 1+ .d txwrite txsp
	ycursor 1+ .d txwrite txsp
|	inisel 0? ( drop ; ) ( finsel <? c@+ "%k" txprint ) drop
|	panelcontrol 1? ( drop barrac ; ) drop
	;

|-------------------------------------
#sx1 #sy1 
#selxi #selyi
#sw1 
	
:startsel
	xcodel 'sx1 !
	ycode 'sy1 ! 
	scrini> 
	inisel >=? ( ; )
	( inisel <? c@+ 
		13 =? ( txh 'sy1 +! xcodel 'sx1 ! )
		txcw 'sx1 +! ) 
	32 txcw neg 'sx1 +! ;
		
:edselshow
	inisel 0? ( drop ; )
	scrend> >? ( drop ; ) drop
	startsel
	sx1 'selxi ! sy1 'selyi !
	0 'sw1 !
	( scrend> <? finsel <? c@+
		13 =? ( wcode sx1 - xcode + 'sw1 ! 
				txh 'sy1 +! xcodel 'sx1 !
				32 txcw neg 'sw1 ! )
		txcw 'sw1 +!
		) 
	finsel <? ( wcode sx1 - 'sw1 ! )
	drop
	sw1 'sx1 +! 
	
	|....draw select
	colb2 SDLColor
	selxi selyi sy1 =? ( sx1 pick2 - txh sdlfrect ; ) 
	xcode wcode + pick2 - txh sdlfrect
	xcodel selyi txh + wcode xcodel xcode - - sy1 pick2 - sdlfrect
	xcodel sy1 sx1 pick2 - txh sdlfrect
	;

:edlinecursor
	fuente> scrini> <? ( drop ; ) scrend> >? ( drop ; ) drop
	cursorpos
	msec $100 and? ( drop ; ) drop
	xcodel
	ycode ycursor ylinea - txh * + 
	txat
	$ffffff SDLColor 
	'lover modo	=? ( drop cursorlin fuente> txcur ; ) drop
	cursorlin fuente> txcuri ;	
	
:inedit | write editor
	$7f sdlcolor 
	|xcode ycode wcode hcode sdlRect 
	|'dns 'mos 'ups onMap
	'dns uiDwn
	'mos uiSel
	'ups uiUp	
	evwmouse
	editmodekey
	edlinecursor
	edselshow ;

::edfocus
	uiZoneW
	'inedit uiFocus
	;

|---- Read only
:romodekey
	panelcontrol 1? ( drop controlkey ; ) drop

	SDLkey 0? ( drop ; )
	<ctrl> =? ( controlon ) >ctrl< =? ( controloff )
	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )

	selecc
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	fixcur selecc
	drop
	cursorpos ;
	
:inro | readonly editor
|	'dns 'mos 'ups onMap
	'dns uiDwn
	'mos uiSel
	'ups uiUp
	evwmouse
	romodekey
	edlinecursor
	edselshow ;
	
::edfocusro
	|xcode ycode wcode hcode guiBox
	uiZoneW
	'inro uiFocus
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
	txh * ycode +  | y real
	over 8 >> $ff and 
	xcode + 5 32 txcw * + | x real
	swap rot | x y vv
	dup 24 >> $ff and 32 txcw * | w
	swap 16 >> $ff and txh * | h
	pick3 1- pick3 1- pick3 2 + pick3 2 +
	a> 32 >> 4bcol sdlcolor sdlRect
	a> 48 >> 4bcol sdlcolor sdlFRect
	;
	
::showmark
	ab[ 'marcas ( marcas> <? @+ linemark ) drop ]ba ;

	
|----------- principal
::edram
	here	| --- RAM
	dup 'fuente ! dup 'fuente> ! dup '$fuente ! dup 'scrini> !
	$ffff +			| 64kb texto
	dup 'clipboard ! dup 'clipboard> !
	$fff +			| 4KB
	dup 'undobuffer ! dup 'undobuffer> !
	$1fff +			| 8kb
	'here !			| -- FREE
	0 here !
	mark ;

::edwin | x y w h --
	'hcode ! 'wcode ! 'ycode ! 'xcode ! 
	"00000" txw nip xcode + 'xcodel ! ;

|------------------------------------------------
#hashfile
:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
::edloadmem | "" --
	fuente strcpy
	fuente only13 1- '$fuente ! |-- queda solo cr al fin de linea
	fuente dup 'scrini> ! simplehash 'hashfile !
	;
	
::edload | "" --
	'edfilename strcpy
	fuente 'edfilename |getpath
	load 0 swap c!
	fuente only13 1- '$fuente ! |-- queda solo cr al fin de linea
	fuente dup 'scrini> ! simplehash 'hashfile !
	;

::edsave | --
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	| guarda texto
	fuente ( c@+ 1? 13 =? ( ,c 10 ) ,c ) 2drop
	'edfilename savemem
	empty ;