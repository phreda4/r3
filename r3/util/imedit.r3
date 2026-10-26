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

:sele | vacia la seleccion
	0 dup 'inisel ! 'finsel ! ;

:clearundo
	undobuffer dup 'undobuffer> ! 'undobuffer< ! ;

:undoroom | n -- flag ; lugar para n registros (si no hay, vacia el historial)
	3 <<
	dup undobuffer> + undobuffer $8000 + <=? ( 2drop 1 ; ) drop
	clearundo
	$8000 <=? ( drop 1 ; ) drop 0 ;

|---- undo/redo: registros de 8 bytes [pos:32][char:8][tipo:8]
|  tipo bit7 = unido al registro anterior (se deshace junto)
|  0 INS  char insertado en pos     undo: borra          redo: inserta
|  1 DEL  char borrado de pos       undo: inserta        redo: borra
|  2 BACK char borrado de pos       undo: inserta        redo: borra
|         (cursor queda tras el char al deshacer)
|  3 OVR  char reemplazado en pos   undo/redo: intercambian el char
#unj			| 1 = no unir con el registro anterior (tras undo/redo)

:cpos | -- pos ; offset del cursor
	fuente> fuente - ;

:rec | char type pos -- r ; empaqueta un registro (sin el bit de union)
	16 << swap or swap $ff and 8 << or ;

:unrec | r -- type char pos ; desempaqueta (sin el bit de union)
	dup $7f and swap dup 8 >> $ff and swap 16 >> $ffffffff and ;

:lastrec | -- type pos ; ultimo registro (type=-1 si no hay)
	undobuffer> undobuffer =? ( drop -1 -1 ; ) drop
	undobuffer> 8 - @ unrec nip ;

:jstep | type -- d ; pos del registro que se une, relativa al anterior (OVR: nunca)
	0? ( drop 1 ; ) 1 =? ( drop 0 ; ) 2 =? ( drop -1 ; ) drop $1ffffffff ;

:joinable? | r -- flag ; se une al ultimo registro (racha de palabra)
	unj 1? ( 2drop 0 ; ) drop
	unrec lastrec pick4 jstep +			| t c p lt pe
	pick2 <>? ( 2drop 3drop 0 ; )			| pos no contigua
	drop pick3 <>? ( 4drop 0 ; )			| otro tipo de registro
	2drop swap 0? ( drop 32 >? ( drop 1 ; ) drop 0 ; )	| INS: el espacio abre paso nuevo
	2drop 1 ;

:joinbit | force r -- 0/$80 ; force: 0 auto, 1 unir, -1 paso nuevo
	swap -? ( 2drop 0 ; )
	1? ( 2drop $80 ; ) drop
	joinable? 1? ( drop $80 ; ) ;

:urec | force char type pos -- ; graba un registro e invalida redo
	1 undoroom 0? ( drop 4drop ; ) drop
	rec dup >r joinbit r> or
	undobuffer> !+ 'undobuffer> !
	0 'unj !
	undobuffer> 'undobuffer< ! ;

:recsel | -- ; graba el borrado de la seleccion como un solo paso
	finsel inisel - undoroom 0? ( drop ; ) drop
	-1 inisel
	( finsel <?
		dup c@ rot swap 1 inisel fuente - urec
		1+ 1 swap )
	2drop ;


:recins | pos n -- ; graba n bytes insertados desde pos como un solo paso
	dup undoroom 0? ( 3drop ; ) drop
	over + swap -1 swap				| end force pos
	( pick2 <?
		dup fuente + c@ rot swap 0 pick3 urec
		1+ 1 swap )
	3drop ;

:delraw | adr -- ; borra el char bajo adr, no mueve cursor
	dup 1+ $fuente over - 1+ cmove
	-1 '$fuente +! ;

:redoback	| repite un back
	fuente> fuente <=? ( drop ; )
	drop -1 'fuente> +!
	fuente> delraw ;

:back1 | force -- ; borra el byte anterior al cursor
	fuente> fuente <=? ( 2drop ; )
	1- dup c@ swap fuente - 2 swap urec
	redoback ;

:del1 | force -- ; borra el byte bajo el cursor
	fuente> $fuente >=? ( 2drop ; )
	dup c@ swap fuente - 1 swap urec
	fuente> delraw ;

:<<13 | a -- a
	( fuente >=?
		dup c@ 13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( $fuente <?
		dup c@ 13 =? ( drop ; ) | quitar el 1 -
		drop 1+ ) 1- ;

#1sel


:rsel | p -- ; seleccion entre 1sel y p
	1sel over <? ( swap ) 'finsel ! 'inisel ! ;

:selecc	| agrega a la seleccion
	mshift 0? ( 'inisel ! ; ) drop
	inisel 0? ( fuente> '1sel ! ) drop
	fuente> rsel ;


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
:cr>lf | adr cnt -- ; CR -> LF (portapapeles)
	( 1? 1- swap
		dup c@ 13 =? ( 10 pick2 c! ) drop
		1+ swap ) 2drop ;

:copysel
	inisel 0? ( drop ; )
	here swap finsel over - | here ini cnt
	0 pick3 pick2 + ! cmove | dsc
|LIN|	here count cr>lf
	here SDL_SetClipboardText drop ;

:cursordel
	fuente>
	inisel <? ( drop ; )
	finsel <=? ( drop inisel 'fuente> ! ; ) drop
	finsel inisel - neg 'fuente> +! ;

:remsel
	inisel 0? ( drop ; )
	recsel
	finsel $fuente over - 1+ cmove
	finsel inisel - neg '$fuente +!
	cursordel sele ;

:kdel
	inisel 0? ( drop 0 del1 ; )
	drop remsel ;

:kback
	inisel 0? ( drop 0 back1 ; )
	drop remsel ;

|----- insertar / sobreescribir con undo
:ovwchar | c -- ; graba el char viejo (OVERWRITE) y sobreescribe
	0 fuente> c@ 3 cpos urec
	lover ;

:canover | c -- c f ; sobreescribir solo ascii sobre ascii
	$80 >=? ( 0 ; )
	13 =? ( 0 ; )
	fuente> $fuente >=? ( drop 0 ; )
	c@ $ff and $80 >=? ( drop 0 ; )
	13 =? ( drop 0 ; ) drop -1 ;


:insins | c -- ; inserta SIEMPRE y graba INS
	dup 0 swap 0 cpos urec
	lins ;

:insertchar | c -- ; reemplaza la seleccion, inserta o sobreescribe
	remsel
	modo 'lover =? (
		drop canover 1? ( drop ovwchar ; )
		drop insins ; )
	drop insins ;

|-------------
| Edit CtrE
|-------------
|-------------
:controlc | copy
	copysel ;

:controlx | cut
	controlc remsel ;

:pastefix | adr -- ; caracteres de control (menos tab y CR) -> espacio
	( dup c@ $ff and 1?
		32 <? ( 9 <>? ( 13 <>? ( 32 pick2 c! ) ) )
		drop 1+ ) 2drop ;

:insblock | adr cnt -- ; inserta cnt bytes en el cursor como un solo paso de undo
	0? ( 2drop ; )
	fuente> over + fuente>			| adr cnt dst src
	$fuente over - 1+ cmove>			| hace lugar
	dup '$fuente +!
	fuente> pick2 pick2 cmove			| copia el bloque
	fuente> fuente - over recins
	'fuente> +! drop ;

:controlv | paste
	SDL_HasClipboardText 0? ( drop ; ) drop
	remsel
	SDL_GetClipboardText
	dup only13 drop dup pastefix
	dup count insblock
	SDL_free ;

|-------------
:swapchar | charnuevo adr -- charviejo ; escribe charnuevo en adr, devuelve lo que habia
	dup c@ -rot c! ;


:undo1 | adr -- ; deshace un registro
	dup @ unrec fuente + rot					| adr c ud t
	0? ( drop nip dup delraw 'fuente> ! drop ; )			| INS: borra
	1 =? ( drop dup 'fuente> ! swap lins 'fuente> ! drop ; )	| DEL: reinserta, cursor en pos
	2 =? ( drop 'fuente> ! lins drop ; )				| BACK: reinserta, cursor tras el char
	drop dup 'fuente> ! swapchar over 1+ c! drop ;			| OVR: restaura, guarda el otro

:redo1 | adr -- ; rehace un registro
	dup @ unrec fuente + rot					| adr c ud t
	0? ( drop 'fuente> ! lins drop ; )				| INS: inserta
	3 <? ( drop nip dup delraw 'fuente> ! drop ; )			| DEL/BACK: borra
	drop dup 1+ 'fuente> ! swapchar over 1+ c! drop ;		| OVR: reescribe, avanza

:undostep | -- flag ; deshace un registro; flag<>0 si seguia unido al anterior
	undobuffer> undobuffer =? ( drop 0 ; ) drop
	undobuffer> 8 - dup 'undobuffer> !
	dup undo1
	@ $80 and ;

:redostep | -- flag ; rehace un registro; flag<>0 si el siguiente esta unido
	undobuffer> undobuffer< =? ( drop 0 ; ) drop
	undobuffer> dup redo1
	8 + dup 'undobuffer> !
	undobuffer< =? ( drop 0 ; )
	@ $80 and ;

:controlz | undo (un paso = registros unidos)
	sele 1 'unj !
	( undostep 1? drop ) drop ;

:controly | redo
	sele 1 'unj !
	( redostep 1? drop ) drop ;


|----- busqueda (sin distinguir mayusculas)
:findnext | -- ; siguiente coincidencia de findpad
	'findpad c@ 0? ( drop ; ) drop
	fuente> $fuente >=? ( drop ; ) 1+ 'findpad findstri 0? ( drop ; )
	'fuente> ! ;

:findprev | -- ; coincidencia anterior de findpad (ultima que empieza antes del cursor)
	'findpad c@ 0? ( drop ; ) drop
	0 fuente						| ultima p
	( 'findpad findstri 1? fuente> <?		| ultima m
		nip dup 1+ )				| m m+1
	drop 0? ( drop ; )
	'fuente> ! ;

|----- definiciones
#wpad * 64		| palabra bajo el cursor
#newdef * 96		| texto de la definicion nueva

:cprev | a -- a c ; char anterior (0 al inicio del texto)
	fuente <=? ( 0 ; ) dup 1- c@ $ff and ;

:wordpad | -- ini fin ; palabra bajo el cursor (sin la comilla inicial)
	fuente> ( cprev 32 >? drop 1- ) drop
	dup c@ $27 =? ( swap 1+ swap ) drop
	dup ( c@+ $ff and 32 >? drop ) drop 1- ;

:wordcopy | ini fin -- len ; copia la palabra a wpad
	over - 63 min
	'wpad pick2 pick2 cmove
	nip dup 'wpad + 0 swap c! ;

:defname | adr -- name/0 ; salta el prefijo de definicion (: :: # ##) o da 0
	c@+ $ff and
	$3a <>? ( $23 <>? ( 2drop 0 ; ) )
	over c@ =? ( swap 1+ swap ) drop ;

:isword? | name -- flag ; name coincide con wpad y termina ahi
	'wpad
	( c@+ 1? $ff and toupp
		rot c@+ $ff and toupp rot - 1? ( 3drop 0 ; ) drop
		swap )
	2drop c@ $ff and 33 <? ( drop 1 ; ) drop 0 ;

:finddef | -- adr/0 ; linea que define la palabra de wpad
	fuente
	( $fuente <?
		dup defname 1? ( isword? 1? ( drop ; ) ) drop
		>>13 1+ )
	drop 0 ;

:defstart | -- adr ; inicio de la definicion ':' que contiene al cursor
	fuente> 1- <<13 1+
	( fuente >?
		dup c@ $3a =? ( drop ; ) drop
		1- <<13 1+ ) ;

:controld | ir a la definicion de la palabra bajo el cursor
	wordpad wordcopy 0? ( drop ; ) drop
	finddef 0? ( drop ; )
	'fuente> ! ;

:controln | palabra nueva: ir a su definicion, o crear ":palabra ;" antes de la actual
	wordpad wordcopy 0? ( drop ; )			| len
	finddef 1? ( nip 'fuente> ! ; ) drop
	sele defstart 'fuente> !
	$3a 'newdef c!
	'newdef 1+ 'wpad pick2 cmove
	'newdef 1+ over +
	13 swap c!+ 9 swap c!+ $3b swap c!+ 13 swap c!+ 13 swap c!+ drop
	6 + 'newdef swap insblock
	-3 'fuente> +! ;

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

|----- numero de linea
#shownum 1		| 1 = muestra el numero de linea

:gutter | -- w ; ancho del margen con los numeros
	shownum 0? ( ; ) drop "00000" txw nip ;

:edlayout | -- ; posicion del codigo y columnas visibles
	xcode gutter + 'xcodel !
	wcode xcodel xcode - - 32 txcw / 'xvis ! ;

::edlinenum! | 0/1 -- ; muestra u oculta el numero de linea
	1? ( drop 1 ) 'shownum !
	edlayout ;

::edlinenum | -- 0/1
	shownum ;

:drawnum | n -- ; numero de linea en el margen (si esta visible)
	shownum 0? ( 2drop ; ) drop
	$afafaf txrgb .d 4 .r. txwrite ;

:txsp 32 txemit ;
:txtab "   " txwrite ;

:drawline | src nline ylin -- src nline ylin
	pick2 c@ 0? ( drop ; ) drop | linea vacia
	swap 1+ dup drawnum			| src ylin nline
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
	swap 0 txcw 6 * shownum * xpad 32 txcw * + | adr x xa
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
	cursormouse fuente> rsel ;

:ups
	msec dup tclick - 400 <? ( 2drop dclick ; ) drop 'tclick !
	cursormouse
	fuente> 1sel =? ( drop 0 'inisel ! ; )
	rsel ;


:evwmouse 
	SDLw 0? ( drop ; )
	-? ( ( 1? 1+ scrolldw scrolldw ) drop ; )
	( 1? 1- scrollup scrollup ) drop ;	

|---------- busqueda: entrada del texto
#modefind		| 1 = escribiendo el texto a buscar
#rdonly			| 1 = editor de solo lectura

:findoff 0 'modefind ! ;
:findmode 1 'modefind ! 0 'findpad c! ;
:findgo findoff findnext ;

:findchar | c -- ; agrega un caracter al texto de busqueda
	$ff and 32 <? ( drop ; )
	'findpad count 62 >=? ( 3drop ; )
	+ c!+ 0 swap c! ;

:findback | -- ; borra el ultimo caracter
	'findpad count 0? ( 2drop ; ) 1- + 0 swap c! ;

:findkey | key -- ; teclas durante la entrada de la busqueda
	<back> =? ( findback )
	<ret> =? ( findgo )
	<esc> =? ( findoff )
	drop ;

|---------- manejo de teclado
:controledit | key -- key ; atajos que modifican el texto (no en solo lectura)
	rdonly 1? ( drop ; ) drop
	<x> =? ( controlx )
	<v> =? ( controlv )
	<z> =? ( controlz )
	<y> =? ( controly )
	<n> =? ( controln ) ;

:controlkey
	SDLkey
	>ctrl< =? ( controloff )
	controledit
	<c> =? ( controlc ) | copy
	<f> =? ( findmode ) | find
	<d> =? ( controld ) | definition
	<l> =? ( shownum 1 xor edlinenum! ) | line number

	<up> =? ( findprev )
	<dn> =? ( findnext )

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
	SDLchar 1? ( modefind 1? ( drop findchar ; ) drop insertchar ; ) drop
	SDLkey 0? ( drop ; )
	<ctrl> =? ( controlon drop ; ) >ctrl< =? ( controloff drop ; )
	<shift> =? ( 1 'mshift ! drop ; ) >shift< =? ( 0 'mshift ! drop ; )
	modefind 1? ( drop findkey ; ) drop
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
	modefind 1? ( drop " find: " txwrite 'findpad txwrite "_" txwrite ; ) drop
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
	0 'rdonly !
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
	SDLchar 1? ( modefind 1? ( drop findchar ; ) 2drop ; ) drop
	SDLkey 0? ( drop ; )
	<ctrl> =? ( controlon drop ; ) >ctrl< =? ( controloff drop ; )
	<shift> =? ( 1 'mshift ! drop ; ) >shift< =? ( 0 'mshift ! drop ; )
	modefind 1? ( drop findkey ; ) drop

	selecc
	<up> =? ( karriba ) <dn> =? ( kabajo )
	<ri> =? ( kder ) <le> =? ( kizq )
	<home> =? ( khome ) <end> =? ( kend )
	<pgup> =? ( kpgup ) <pgdn> =? ( kpgdn )
	drop
	selecc ;
	
:inro | readonly editor
	1 'rdonly !
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
	$8000 +			| 32kb
	'here !			| -- FREE
	0 here !
	mark ;

::edwin | x y w h --
	'hcode ! 'wcode ! 'ycode ! 'xcode ! 
	edlayout ;

|------------------------------------------------
#hashfile
:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
:rewind | -- ; vista, cursor, seleccion y undo al inicio
	0 'xlinea !
	fuente dup 'scrini> ! 'fuente> !
	0 dup 'inisel ! 'finsel !
	clearundo ;


:txtready | -- ; texto en fuente: solo CR, vista al inicio, hash para detectar cambios
	fuente only13 1- '$fuente ! |-- queda solo cr al fin de linea
	rewind
	fuente simplehash 'hashfile ! ;

::edloadmem | "" --
	fuente strcpy txtready ;

::edload | "" --
	'edfilename strcpy
	fuente 'edfilename |getpath
	load 0 swap c!
	txtready ;


::edsave | --
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	| guarda texto
	fuente ( c@+ 1? 13 =? ( ,c 10 ) ,c ) 2drop
	'edfilename savemem
	empty ;