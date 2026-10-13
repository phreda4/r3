| edit-code in sdl,immi
| PHREDA 2007,2025
|---------------------------------------
^r3/lib/parse.r3
^r3/lib/color.r3
^r3/util/immi.r3

| size win
#xcode #ycode #wcode #hcode 
#xcodel
#xpad		| columnas de tab cortado a la izquierda
#xvis #xrem	| columnas visibles / restantes en la linea

| color 
|#colb0 $1f1f1f |color | backcode
|#colb1 $000000 |color | backnowline
#colb2 $444444 |color | backselect

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

#undobuffer |'undobuffer
#undobuffer>
#undobuffer<	| tope valido de redo

#findpad * 64 |----- find text

#mshift

:xoffs | -- px ; scroll horizontal en pixels
	xlinea 32 txcw * ;

:xclip | x -- x' ; x sin scroll -> pantalla, recortado a la ventana
	xoffs - xcodel max xcode wcode + min ;

:skipcr | adr -- adr' ; hasta el CR (incluido) o fin de texto
	( c@+ 1? 13 =? ( drop ; ) drop ) drop 1- ;

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

:clearundo
	undobuffer 'undobuffer> !
	undobuffer 'undobuffer< ! ;

:undofull | -- ; vacia el buffer si no entra otro registro
	undobuffer $1ffe + undobuffer> <=? ( drop clearundo ; )
	drop ;

:pushu | data marca -- ; graba [marca][data] e invalida redo
	undofull
	undobuffer> c!+ c!+ 'undobuffer> !
	undobuffer> 'undobuffer< ! ;

:delraw | adr -- ; borra el char bajo adr, no mueve cursor
	dup 1+ $fuente over - 1+ cmove
	-1 '$fuente +! ;

:redoback | repite un back
	fuente> fuente <=? ( drop ; )
	drop -1 'fuente> +!
	fuente> delraw ;

:back
	fuente> fuente <=? ( drop ; )
	1- c@ 0 pushu redoback ;

:del | graba [9][char] y borra el char bajo el cursor
	fuente> $fuente >=? ( drop ; )
	dup c@ 9 pushu
	delraw ;

:<<13 | a -- a
	( fuente >=?
		dup c@ 13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@ 13 =? ( drop ; ) | quitar el 1 -
		drop 1+ ) 1- ;

#1sel

:selecc	| agrega a la seleccion
	mshift 0? ( 'inisel ! ; ) drop
	inisel 0? ( fuente> '1sel ! ) drop
	fuente> 1sel over <? ( swap )
	'finsel ! 'inisel ! ;

:khome
	fuente> 1- <<13 1+ 'fuente> ! ;

:last?
	dup 1+ c@ 0? ( drop 1+ ; ) drop ;
	
:kend
	fuente> >>13 last? 'fuente> ! ;

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
	here swap finsel over - | here ini cnt
	0 pick3 pick2 + ! cmove | dsc
	here SDL_SetClipboardText drop ;	

:cursordel
	fuente>
	inisel <? ( drop ; )
	finsel <=? ( drop inisel 'fuente> ! ; ) drop
	finsel inisel - neg 'fuente> +! ;

:remsel
	inisel 0? ( drop ; )
	finsel $fuente over - 1+ cmove
	finsel inisel - neg '$fuente +!
	cursordel 0 dup 'inisel ! 'finsel !
	clearundo ;

:kdel
	inisel 0? ( drop del ; )
	drop remsel ;

:kback
	inisel 0? ( drop back ; )
	drop remsel ;

|----- insertar / sobreescribir con undo
:ovwchar | c -- ; graba [2][charviejo] y sobreescribe
	fuente> c@
	2 pushu
	lover ;

:canover | c -- c f ; sobreescribir solo ascii sobre ascii
	$80 >=? ( 0 ; )
	13 =? ( 0 ; )
	fuente> $fuente >=? ( drop 0 ; )
	c@ $ff and $80 >=? ( drop 0 ; )
	13 =? ( drop 0 ; ) drop -1 ;

:insins | c -- ; inserta siempre, graba [1][c]
	dup 1 pushu lins ;

:insertchar | c -- ; reemplaza la seleccion, inserta o sobreescribe
	remsel
	modo 'lover =? (
		drop canover 1? ( drop ovwchar ; )
		drop insins ; )
	drop insins ;

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

:controlx | cut
	controlc remsel ;

:controlv | paste
	SDL_HasClipboardText 0? ( drop ; ) drop
	SDL_GetClipboardText
	count 2dup
	fuente> dup pick2 + swap | clip cnt 'f+ 'f
	$fuente over - 1+ cmove>	| clip cnt
	fuente> -rot | f clip cnt
	dup '$fuente +! 
	cmove 'fuente> +!
	clearundo
	SDL_free ;

|-------------
:redodel | repite un del
	fuente> $fuente >=? ( drop ; )
	delraw ;

:swapchar | charnuevo adr -- charviejo
	dup c@ -rot c! ;

| registros [marca][char]: 0 BACK, 1 INS, 9 DEL, 2 OVR
:controlz | undo
	undobuffer>
	undobuffer =? ( drop ; )
	2 - dup c@
	9 =? ( drop dup 1+ c@ lins -1 'fuente> +! 'undobuffer> ! ; )
	1 =? ( drop redoback 'undobuffer> ! ; )
	2 =? ( drop -1 'fuente> +! dup 1+ c@ fuente> swapchar over 1+ c! 'undobuffer> ! ; )
	drop dup 1+ c@ lins 'undobuffer> ! ;

:controly | redo
	undobuffer> undobuffer< =? ( drop ; )
	dup c@
	9 =? ( redodel )
	0 =? ( redoback )
	1 =? ( over 1+ c@ lins )
	2 =? ( over 1+ dup c@ fuente> swapchar swap c! 1 'fuente> +! )
	drop 2 + 'undobuffer> ! ;

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
	0 'mcolor ! 0 'xpad !
	xlinea wcolor
	( 0 >? 1- swap
		c@+ 0? ( drop nip 1- ; )
		13 =? ( drop nip 1- ; )
		9 =? ( wcolor rot 3 - -rot )
		32 =? ( wcolor )
		$22 =? ( strcol )
		drop swap ) neg 'xpad ! ;

:txsp 32 txemit ;
:txtab "   " txwrite ;

:drawline | src nline ylin -- src nline ylin
	pick2 c@ 0? ( drop ; ) drop | linea vacia
	$afafaf txrgb
	swap 1+ dup .d 4 .r. txwrite	| src ylin nline 
	xcodel ycode pick3 + txat
	rot iniline						| ylin nline src 
	xpad 32 txcw * 0 tx+at
	xvis xpad - 'xrem !
	( c@+ 1?
		13 =? ( drop swap rot ; )
		xrem 1 <? ( 2drop skipcr swap rot ; ) drop
		9 =? ( drop txtab 32 wcolor -3 'xrem +! )
		32 =? ( wcolor )
		$22 =? ( strcol )
		txemit -1 'xrem +!
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
	xcode ycode wcode hcode frect ;
	
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

:skipcols | adr -- adr' ; salta xlinea columnas (tab=4)
	0 'xpad !
	xlinea swap			| n adr
	( over 0 >? drop
		dup c@
		13 =? ( drop nip ; )
		0? ( drop nip ; )
		9 =? ( rot 3 - -rot )
		drop swap 1- swap 1+ )
	drop swap neg 'xpad ! ;

:cursormouse
	SDLx xcode - | xmouse
	scrini>
	SDLy
	ycode txh +
	( over <? txh + rot >>13 1+ -rot ) 2drop
	skipcols
	swap 0 txcw 2* dup 2* + xpad 32 txcw * + | adr x xa
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
	<c> =? ( controlc ) | copy
	<v> =? ( controlv ) | paste
	<z> =? ( controlz ) | undo
	<y> =? ( controly ) | redo

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
	( fuente> <? c@+ emitcur ) drop
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea xvis + >=? ( dup xvis - 1+ 'xlinea ! )
	drop ;
	
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
	SDLchar 1? ( insertchar ; ) drop
	SDLkey 0? ( drop ; )
	<ctrl> =? ( controlon drop ; ) >ctrl< =? ( controloff drop ; )
	<shift> =? ( 1 'mshift ! drop ; ) >shift< =? ( 0 'mshift ! drop ; )
	<back> =? ( kback )
	<del> =? ( kdel )
	<ret> =? ( 13 insertchar )
	<tab> =? ( 9 insertchar )
	selecc
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	<ins> =? ( kins )
	drop
	selecc ;

::edtoolbar
	$555555 color
	xcode ycode txh - wcode txh frect 
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
	
:selcar
	13 =? ( drop txh 'sy1 +! xcodel 'sx1 ! ; )
	txcw 'sx1 +! ;
		
:startsel
	xcodel 'sx1 ! ycode 'sy1 ! 
	scrini> inisel >=? ( ; )
	( inisel <? c@+ selcar ) ;
	
:edselshow
	inisel 0? ( drop ; )
	scrend> >? ( drop ; ) drop
	startsel
	sx1 'selxi ! sy1 'selyi !
	0 'sw1 !
	( scrend> <? finsel <? c@+
		13 =? ( txh 'sy1 +! xcodel 'sx1 !
				32 txcw neg 'sw1 ! )
		txcw 'sw1 +! ) 
	finsel <? ( xcode wcode + xoffs + sx1 - 'sw1 ! )
	drop
	sw1 'sx1 +! 
	selxi xclip 'selxi !
	sx1 xclip 'sx1 !
	
	|....draw select
	colb2 color
	selxi selyi sy1 =? ( sx1 pick2 - txh frect ; ) 
	xcode wcode + pick2 - txh frect
	xcodel selyi txh + wcode xcodel xcode - - sy1 pick2 - frect
	xcodel sy1 sx1 pick2 - txh frect
	;

:edlinecursor
	fixcur 
	fuente> scrini> <? ( drop ; ) scrend> >? ( drop ; ) drop
	cursorpos
	msec $100 and? ( drop ; ) drop
	xcodel xoffs -
	ycode ycursor ylinea - txh * + 
	txat
	$ffffff color 
	'lover modo	=? ( drop cursorlin fuente> txcur ; ) drop
	cursorlin fuente> txcuri ;	
	
:inedit | write editor
	|$7f color 
	|xcode ycode wcode hcode rect 
	'dns uiDwn 'mos uiSel 'ups uiUp
	evwmouse
	editmodekey
	edselshow
	edlinecursor ;

::edfocus
	uiZoneW
	'inedit uiFocus
	;

|---- Read only
:romodekey
	panelcontrol 1? ( drop controlkey ; ) drop

	SDLkey 0? ( drop ; )
	<ctrl> =? ( controlon drop ; ) >ctrl< =? ( controloff drop ; )
	<shift> =? ( 1 'mshift ! drop ; ) >shift< =? ( 0 'mshift ! drop ; )

	selecc
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	drop
	selecc ;
	
:inro | readonly editor
	'dns uiDwn 'mos uiSel 'ups uiUp
	evwmouse
	romodekey
	edselshow 
	edlinecursor ;
	
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

#mx #my #mw #mh

:linemark | mark --
	dup $ff and ylinea -
	-? ( 2drop ; ) hcode >=? ( 2drop ; )	| fuera de pantalla
	txh * ycode + 'my !
	dup >a
	dup 8 >> $ff and xlinea - 'mx !
	dup 24 >> $ff and 'mw !
	16 >> $ff and txh * 'mh !
	mx -? ( dup mw + 'mw ! 0 'mx ! ) drop	| recorte izquierdo
	mx mw + xvis -
	0 >? ( dup neg 'mw +! ) drop			| recorte derecho
	mw 1 <? ( drop ; ) drop
	mx 32 txcw * xcode + 5 32 txcw * +	| x real
	my mw 32 txcw * mh
	pick3 1- pick3 1- pick3 2 + pick3 2 +
	a> 32 >> 4bcol color rect
	a> 48 >> 4bcol color frect
	;
	
::showmark
	ab[ 'marcas ( marcas> <? @+ linemark ) drop ]ba ;

	
|----------- principal
::edram
	here	| --- RAM
	dup 'fuente ! dup 'fuente> ! dup '$fuente ! dup 'scrini> !
	$ffff +			| 64kb texto
	dup 'undobuffer ! dup 'undobuffer> ! dup 'undobuffer< !
	$1fff +			| 8kb
	'here !			| -- FREE
	0 here !
	mark ;

::edwin | x y w h --
	'hcode ! 'wcode ! 'ycode ! 'xcode ! 
	"00000" txw nip xcode + 'xcodel !
	wcode xcodel xcode - - 32 txcw / 'xvis ! ;

|------------------------------------------------
#hashfile
:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
:rewind | -- ; vista, cursor, seleccion y undo al inicio
	0 'xlinea !
	fuente dup 'scrini> ! 'fuente> !
	0 dup 'inisel ! 'finsel !
	clearundo ;

::edloadmem | "" --
	fuente strcpy
	fuente only13 1- '$fuente ! |-- queda solo cr al fin de linea
	rewind
	fuente simplehash 'hashfile !
	;
	
::edload | "" --
	'edfilename strcpy
	fuente 'edfilename |getpath
	load 0 swap c!
	fuente only13 1- '$fuente ! |-- queda solo cr al fin de linea
	rewind
	fuente simplehash 'hashfile !
	;

::edsave | --
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	| guarda texto
	fuente ( c@+ 1? 13 =? ( ,c 10 ) ,c ) 2drop
	'edfilename savemem
	empty ;