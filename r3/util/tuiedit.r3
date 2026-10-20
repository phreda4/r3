| Text Editor
| PHREDA 2025

^r3/util/tui.r3
^r3/lib/clipboard.r3
|^r3/lib/trace.r3

#hashfile 
##filename * 1024

#nlw		| ancho linea 0=hidden
#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor

#inisel		| inicio seleccion
#finsel		| fin seleccion

#scrini>	| comienzo de pantalla
#scrend>	| fin de pantalla

##fuente	| fuente editable
##fuente>	| cursor
##$fuente	| fin de texto

#undobuffer |'undobuffer
#undobuffer>
#undobuffer<	| tope valido de redo

#findpad * 64	|----- find text

:ubackc | adr -- adr' ; primer byte del caracter utf8, sin pasar de fuente
	utf8lead fuente max ;

|----- themes

##themeold ( 255 226 244 196 201 50 226 46 18 235 233 239 250 46 )
##themenew ( 255 228 241 204 135 44 220 114 17 232 235 239 216 208 )

#th 'themenew

::tuTheme! | 'theme -- ; 'themeold / 'themenew
	'th ! ;

:tcol | n -- col256
	th + c@ $ff and ;

|----- select
:inselect | adr -- adr
	inisel finsel in? ( 8 tcol .bc ) ;
	
:atselect | adr -- addr
	inisel =? ( 8 tcol .bc ; ) 
	finsel =? ( fuente> =? ( 10 tcol .bc ; ) 9 tcol .bc ) ;

#1sel 

:rsel | p -- ; seleccion entre 1sel y p
	1sel over <? ( swap ) 'finsel ! 'inisel ! ;

:sela	| add to select 
	inisel 0? ( fuente> '1sel ! ) drop
	fuente> rsel ;

:sele | empty select
	0 dup 'inisel ! 'finsel ! ; 
	
|----- edit
:lins | c -- ; inserta c en cursor y avanza
	fuente> dup 1+ swap $fuente over - 1+ cmove>
	fuente> c!
	1 '$fuente +!
	1 'fuente> +! ;

:lover | c --
	fuente> c!+ 'fuente> ! ;

#modo 'lins

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
#ut #uc #up #uf		| registro en preparacion
#lt #lp			| ultimo registro: tipo y pos
#ua #ud #uend		| direccion del registro / del texto / limite
#unj			| 1 = no unir con el registro anterior (tras undo/redo)

:cpos | -- pos ; offset del cursor
	fuente> fuente - ;

:lastrec | -- ; lt lp del ultimo registro (lt=-1 si no hay)
	-1 'lt !
	undobuffer> undobuffer =? ( drop ; )
	8 - @ dup $7f and 'lt ! 16 >> $ffffffff and 'lp ! ;

:joinable? | -- flag ; se une al registro anterior (racha de palabra)
	unj 1? ( drop 0 ; ) drop
	lt ut <>? ( drop 0 ; ) drop
	ut 1 =? ( drop lp up =? ( drop 1 ; ) drop 0 ; )		| DEL: misma pos
	2 =? ( drop lp 1- up =? ( drop 1 ; ) drop 0 ; )		| BACK: pos anterior
	0? ( drop lp 1+ up =? ( drop uc 32 >? ( drop 1 ; ) ) drop 0 ; )	| INS: contigua, sin espacio
	drop 0 ;

:joinflag | -- 0/$80 ; uf: 0 auto, 1 unir, -1 paso nuevo
	uf -? ( drop 0 ; ) 0? ( drop joinable? ) 1? ( drop $80 ; ) drop 0 ;

:urec | force char type pos -- ; graba un registro e invalida redo
	'up ! 'ut ! $ff and 'uc ! 'uf !
	1 undoroom 0? ( drop ; ) drop
	lastrec
	joinflag ut or uc 8 << or up 16 << or
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
	over + 'uend !
	-1 swap
	( uend <?
		dup fuente + c@ rot swap 0 pick3 urec
		1+ 1 swap )
	2drop ;

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
	( $fuente <=?
		dup c@ 13 =? ( drop ; )
		drop 1+ ) 1- ;

:khome	fuente> 1- <<13 1+ 'fuente> ! ;
:kend	fuente> >>13 'fuente> ! ;

|------- calc xy cursor
:cwidth | c -- w ; ancho visual: tab 2, continuacion utf8 0, resto 1
	9 =? ( drop 2 ; ) utf8c? 1? ( 1 nip ) ;

:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	cwidth 'xcursor +! ;

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
	( fuente> <? c@+ emitcur ) drop 
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea fw + nlw - >=? ( dup fw - nlw + 1+ 'xlinea ! )
	drop ;
	
|-----------
:lineasup | adr n -- adr' ; sube n lineas (inicio de linea, >= fuente)
	( 1? swap 2 - <<13 1+ swap 1- ) drop
	fuente <? ( fuente nip ) ;

:setpantafin | cursor --
	1- <<13 1+ dup 'scrini> !
	fh ( 1? swap >>13 1+ swap 1- ) drop
	|$fuente <? ( 1- ) 
	'scrend> ! ;
	
:setpantaini | cursor --
	>>13 1+ dup 'scrend> ! 
	fh lineasup 'scrini> ! ;
	
:fixcur
	fuente>
	scrini> <? ( setpantafin ; )
	scrend> >=? ( setpantaini ; )
	drop ;

:fixpos fixcur cursorpos ;

::tuiecursor! | cursor --
	'fuente> ! fixpos ;
	
::tuipos! | pos --
	dup 'fuente> !
	fh 2/ lineasup 'scrini> !
	cursorpos
	;

::tuiposq! | pos --
	scrini> scrend> in? ( 'fuente> ! cursorpos ; ) tuipos! ;
		
|-----------
:linecol | adr -- col 
	dup 1- <<13 1+		| adr ini
	0 swap			| adr col p
	( pick2 <? c@+ $ff and cwidth rot + swap )
	drop nip ;

:coladv | ini col -- adr 
	swap				| col p
	( swap 1? swap			| col p
		dup c@ $ff and
		0? ( drop nip ; )
		13 =? ( drop nip ; )
		cwidth pick2 >? ( drop nip ; )	| no entra (tab) -> antes del char
		rot swap - swap		| col-w p
		utf8next ) drop ;

 :karriba
 	fuente> fuente =? ( drop ; )
	dup linecol swap		| col cur
	1- <<13			| col cr
	fuente <? ( 2drop fuente 'fuente> ! ; )
	1- <<13 1+			| col inilinea
	swap coladv 'fuente> ! ;
 
 :kabajo
 	fuente> $fuente >=? ( drop ; )
	dup linecol swap		| col cur
	>>13				| col cr
	$fuente >=? ( 2drop $fuente 'fuente> ! ; )
	1+ swap coladv 'fuente> ! ;

:kder	fuente> $fuente <? ( utf8next 'fuente> ! ; ) drop ;
:kizq	fuente> fuente >? ( 1- ubackc 'fuente> ! ; ) drop ;
:kpgup	fh ( 1? 1- karriba fixcur ) drop ;
:kpgdn	fh ( 1? 1- kabajo fixcur ) drop ;

:scrollup | 'fuente -- 'fuente
	scrini> 2 - <<13 1+ 
	fuente <? ( drop ; )
	'scrini> ! ;

:scrolldw
	scrend> >>13 1+ 
	$fuente >=? ( drop ; ) 'scrend> !
	scrini> >>13 1+ 'scrini> ! ;
	
:evwmouse
	-? ( ( 1? 1+ scrolldw scrolldw ) ; )
	( 1? 1- scrollup scrollup ) ;	
	
|------------------------------------------------
:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
				
:fin13 | -- ; queda solo cr al fin de linea
	fuente only13 1- '$fuente ! ;

:rewind | -- ; vista y cursor al inicio
	0 'xlinea !
	fuente dup 'scrini> ! 'fuente> !
	clearundo ;

:loadtxt | -- ; cargar texto
	fuente 'filename 
	load 0 swap c!
	fin13 rewind
	fuente simplehash 'hashfile !
	;

:savetxt | -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
	'filename savemem
	empty 
	fuente simplehash 'hashfile !
	;
	
|---- draw text with colors
#focoe	
#modoline

#fc.
:.fcc | color -- ; .fc w/cache
	fc. =? ( drop ; )
	dup .fc 'fc. ! ;
	
:codecolor | adr -- adr
	dup c@ 
	33 <? ( drop ; )
	$22 =? ( drop 0 tcol .fcc 3 'modoline ! ; )		| $22 " string
	$5e =? ( drop 1 tcol .fcc 2 'modoline ! ; )		| $5e ^  Include
	$7c =? ( drop 2 tcol .fcc 2 'modoline ! ; )		| $7c |	 Comentario
	$3A =? ( drop 3 tcol .fcc ; )		| $3a :  Definicion
	$23 =? ( drop 4 tcol .fcc ; )	| $23 #  Variable
	$27 =? ( drop 5 tcol .fcc ; )	| $27 ' Direccion
	drop
	dup isNro 1? ( drop 6 tcol .fcc ; ) drop
|	dup isBase 
|	1? ( 18 <? ( drop 20 .fc ; ) drop 214 .fc ; ) 
|	drop
	7 tcol .fcc ;
	
:ctlfix | c -- c' 
	dup $ff and
	32 <? ( drop 9 =? ( ; ) drop 46 ; )
	$7f =? ( 2drop 46 ; )
	drop ;

:utfrest | adr -- adr' 
	( dup c@ utf8c? 0? drop c@+ .emit ) drop ;
	
:fillend | nlin cnt adr -- nlin adr 	
	|nip .eline ;
	swap 1+ .nsp ;

:tabchar | adr 9 -- adr 32
	drop swap 0? ( swap 32 ; ) 1- swap .sp 32 ;
	
:cskip | adr c -- adr ; avanza estado de color (sin emitir)
	modoline 0? ( drop 32 =? ( drop codecolor ; ) drop ; )
	3 =? ( 2drop 1 'modoline ! ; )
	2 =? ( 2drop ; ) drop
	$22 =? ( drop 0 'modoline ! codecolor ; ) drop ;

:cskipm drop ;	| mono: sin color
:nocolor ;

#skipw 'cskip	| cskip / cskipm
#colw 'codecolor	| codecolor / nocolor

:modocolor 'codecolor 'colw ! 'cskip 'skipw ! ;
:modomono 'nocolor 'colw ! 'cskipm 'skipw ! ;

:cemit | adr char -- adr 
	9 =? ( tabchar )
	dup .emit skipw ex ;
		
	
:linenormal | n --
	9 tcol .bc 11 tcol .fcc
	nlw 0? ( 2drop ; ) drop
	1+ .d 4 .r. .write .sp ;

:linecur | n --
	nlw 0? ( 2drop 9 tcol .bc 11 tcol .fcc ; ) drop
	10 tcol .bc 12 tcol .fcc 1+ .d 4 .r. .write .sp ;	
	
:iniline | adr lin -- adr lin 
	fx over fy + .at
	dup ylinea + 
	|focoe 0? ( drop linenormal ; ) drop | sin foco?
	ycursor =? ( linecur ; ) |">" .write ; )
	linenormal ;
	
:skipx | adr -- adr' ; saltea xlinea columnas sin emitir, se detiene en CR/0
	xlinea swap			| n adr
	( swap 1? 1- swap
		atselect c@+ $ff and
		0? ( drop 1- nip ; )
		13 =? ( drop 1- nip ; )
		9 =? ( rot 1- clamp0 -rot drop 32 )	| tab = 2 columnas
		skipw ex utf8skip )
	drop ;

:cr.. | adr -- adr'
	( c@+ 1? 13 =? ( drop ; ) drop ) drop 1- ;
	
:drawline | nlin adr -- nlin adr
	inselect
	0 'modoline ! | string multilinea****
	colw ex
	skipx
	fw nlw - 
	( 0 >? 1- swap 
		atselect
		c@+ 0? ( drop fillend 1- ; ) 
		13 =? ( drop fillend ; )
		ctlfix cemit utfrest
		swap ) drop
|	( atselect c@+ 13 <>? 
|		0? ( drop 1- ; ) | end of text
|		drop ) drop ;
	cr.. ;

|----------------------
:emline | adr lin -- adr lin 
	fx over fy + .at
	"~" .write fw 1- .nsp ;
	
:emptylines
	9 tcol .bc 11 tcol .fcc
	swap ( 1+ fh <? emline ) drop ;
	
:drawlines | ini -- end
	-1 'fc. !
	0 ( fh <?
		iniline swap 
		drawline
		$fuente =? ( emptylines ; )
		swap 1+ ) drop ;

|---- mouse & keys
:clickMouse0
	evtmxy fy -
	scrini> | x y c
	( swap 1? 1- swap cr.. ) drop | x c
	swap fx - nlw - clamp0 xlinea + swap | nlw<- line numbers
	( swap 1? 1- swap 
		c@+ 
		9 =? ( rot 1- clamp0 -rot )
		13 =? ( 0 nip )
		0? ( drop nip 1- ; ) 
		drop utf8skip ) drop ;

:clickMouse clickMouse0 ubackc ;

#tclick

:dclick |"double click" .println
	fuente>
	( dup c@ $ff and 32 >? drop 1- ) drop
	1+ dup 'inisel ! 
	( c@+ $ff and 32 >? drop ) drop
	1- 'finsel !
	;
	
:dns
	clickMouse 
	'1sel ! ;

:mos
	clickMouse rsel ;

:ups
	msec dup tclick - 400 <? ( 2drop dclick ; ) drop 'tclick !
	clickMouse
	dup 1sel =? ( 2drop sele ; ) drop
	rsel ;

| 0 = normal
| 1 = over (not all sytems)
| 2 = in
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click
:EditMouse
	tuiw 
	2 =? ( dns )
	3 =? ( mos )
	6 =? ( ups clickMouse 'fuente> ! cursorpos )
	drop ;

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
	cursordel sele
	0 'cachepi ! ;

:cr>lf | adr cnt --
	( 1? 1- swap
		dup c@ 13 =? ( 10 pick2 c! ) drop
		1+ swap ) 2drop ;
		
:txtcopy
	inisel 0? ( drop ; )
	finsel over -				| ini cnt (fin exclusivo)
	here pick2 pick2 cmove	| copia a here
	nip 0 over here + c!		| cnt ; terminador
|LIN|	here over cr>lf
	here swap copyclipboard ;

:txtcut
	txtcopy remsel ;

:pastefix | adr -- 
	( dup c@ $ff and 1?
		32 <? ( 9 <>? ( 13 <>? ( 32 pick2 c! ) ) )
		drop 1+ ) 2drop ;

:txtpaste
	remsel
	here pasteclipboard
	here only13 drop here pastefix
	here count 0? ( 2drop ; ) 
	fuente> dup pick2 + swap | from count to+ 
	$fuente over - 1+ cmove>	| clip cnt
	fuente> -rot | f clip cnt
	dup '$fuente +!
	cmove
	fuente> fuente - here count nip recins
	here count nip 'fuente> +!
	;
		
|-------------
:swapchar | charnuevo adr -- charviejo ; escribe charnuevo en adr, devuelve lo que habia
	dup c@ -rot c! ;

:uget | adr -- ; decodifica el registro en ut uc up
	dup 'ua ! @
	dup $7f and 'ut !
	dup 8 >> $ff and 'uc !
	16 >> $ffffffff and 'up ! ;

:undo1 | adr -- ; deshace un registro
	uget up fuente + 'ud !
	ut
	0? ( drop ud delraw ud 'fuente> ! ; )				| INS: borra
	1 =? ( drop ud 'fuente> ! uc lins ud 'fuente> ! ; )		| DEL: reinserta, cursor en pos
	2 =? ( drop ud 'fuente> ! uc lins ; )				| BACK: reinserta, cursor tras el char
	drop uc ud swapchar ua 1+ c! ud 'fuente> ! ;			| OVR: restaura, guarda el otro

:redo1 | adr -- ; rehace un registro
	uget up fuente + 'ud !
	ut
	0? ( drop ud 'fuente> ! uc lins ; )				| INS: inserta
	1 =? ( drop ud delraw ud 'fuente> ! ; )			| DEL: borra
	2 =? ( drop ud delraw ud 'fuente> ! ; )			| BACK: borra
	drop uc ud swapchar ua 1+ c! ud 1+ 'fuente> ! ;		| OVR: reescribe, avanza

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

:backu | borra el caracter utf8 anterior
	fuente> fuente <=? ( drop ; )
	dup 1- ubackc -
	( 1? 1- 0 back1 ) drop ;

:delu | borra el caracter utf8 bajo el cursor
	fuente> $fuente >=? ( drop ; )
	utf8next fuente> -
	( 1? 1- 0 del1 ) drop ;

:kdel
	inisel 0? ( drop delu ; )
	drop remsel ;

:kback
	inisel 0? ( drop backu ; )
	drop remsel ;
	
:chmode
	modo 'lins =? ( drop 'lover 'modo ! .ovec ; )
	drop 'lins 'modo ! .insc ;

|-------------
:findnext
	'findpad c@ 0? ( drop ; ) drop
	fuente> $fuente >=? ( drop ; ) 1+ 'findpad findstri 0? ( drop ; )
	'fuente> ! ;

:findprev
	'findpad c@ 0? ( drop ; ) drop
	fuente 'findpad fuente> fuente <=? ( 3drop ; ) 1- rfindstri 0? ( drop ; )
	'fuente> ! ;	

:enterfind | -- ; pide texto a buscar (como filesearch en main.r3) y busca
	fhome 7 .fc 4 .bc .eline 
	" find: " .write
	.input
	'pad c@ 0? ( drop ; ) drop
	'pad 'findpad strcpy
	findnext ;	

::tueKeyMove
	[UP] =? ( karriba sele ) 
	[DN] =? ( kabajo sele )
	[RI] =? ( kder sele ) 
	[LE] =? ( kizq sele )
	[HOME] =? ( khome sele ) 
	[END] =? ( kend sele )
	[PGUP] =? ( kpgup sele ) 
	[PGDN] =? ( kpgdn sele )
	;
	
:ovwchar | c -- ; graba el char viejo (OVERWRITE) y sobreescribe
	0 fuente> c@ 3 cpos urec
	lover ;

:canover | c -- c f ; sobreescribir solo ascii sobre ascii
	$80 >=? ( 0 ; )
	13 =? ( 0 ; )
	fuente> $fuente >=? ( drop 0 ; )
	c@ $ff and $80 >=? ( drop 0 ; )
	13 =? ( drop 0 ; ) drop -1 ;

:insins | c -- ; inserta SIEMPRE (modo lins) y graba INS
	0 swap 0 cpos urec
	uc lins ;

:insertchar | c -- ; inserta o sobreescribe c, grabando undo/redo
	remsel
	modo 'lover =? (
		drop				| c
		canover 1? ( drop ovwchar ; )	| ascii sobre ascii -> overwrite
		drop insins ; )			| resto -> insert real
	drop insins ;

:typeutf | key n -- ; inserta un caracter utf8 completo
	( 1? 1- swap dup $ff and insertchar 8 >> swap ) 2drop fixpos ;
	
:EditFoco
	tuif 0? ( 'focoe ! ; )
	|1 =? ( startfocus ) 
	'focoe !
	tuC!	| activate cursor
	evtmw 1? ( evwmouse cursorpos ) drop
	uikey 0? ( drop ; )	
	32 126 in? ( insertchar fixpos ; ) 
	.ukey 1? ( typeutf ; ) drop
	[tab] =? ( insertchar fixpos ; ) 
	[enter] =? ( insertchar fixpos ; ) 
	
	[BACK] =? ( kback )
	[DEL] =? ( kdel )
	
	tueKeyMove
	[INS] =? ( chmode )	
|[SHIFT+DEL] =? ( delword )
|[SHIFT+INS] =? ( dupword )
	[SHIFT+UP] =? ( sela karriba sela )
	[SHIFT+DN] =? ( sela kabajo sela )
	[SHIFT+RI] =? ( sela kder sela )
	[SHIFT+LE] =? ( sela kizq sela )
	[SHIFT+PGUP] =? ( sela kpgup sela )
	[SHIFT+PGDN] =? ( sela kpgdn sela )
	[SHIFT+HOME] =? ( sela khome sela )
	[SHIFT+END] =? ( sela kend sela )
	$18 =? ( txtcut ) | ctrl-x
	$3 =? ( txtcopy ) | ctrl-c
	$16 =? ( txtpaste ) | ctrl-v
	$1a =? ( controlz ) | ctrl-z undo
	$19 =? ( controly ) | ctrl-y redo
	$6 =? ( enterfind )	| ctrl-f find
	$e =? ( findnext )	| ctrl-n find next
	$10 =? ( findprev )	| ctrl-p find prev

	drop fixpos ;


|---- MAIN words
::tuEditLN! | n -- ; line number place
	'nlw ! ;

::tuEditShowCursor
	fx xcursor + xlinea - nlw +
	fy ycursor ylinea - clamp0 fh 1- min +	| fila dentro del widget
	.at .savec
	modo 'lins =? ( drop .insc ; ) drop .ovec 
	;
	
::tuEditCode 
	modocolor
:editw	
	EditMouse
	EditFoco
|	fw 8 <? ( drop ; ) drop
	scrini> drawlines 'scrend> ! 
	focoe 0? ( drop ; ) drop
	tuEditShowCursor
	;

:tuEditCodeMono 
	modomono editw ;

::tuReadCode
	modocolor
	fixpos
	scrini> drawlines 'scrend> !
	tuEditShowCursor ;

::tuReadCodeMono
	modomono
	scrini> drawlines 'scrend> ! ;
	
::tuecursor.
	ycursor 1+ xcursor 1+ "%d:%d" sprint ;
	
::TuLoadMem | "" --
	fuente strcpy
	fin13 rewind ;

::TuLoadMemC | "" -- | already sane
	fuente strcpyl 1- '$fuente !
	rewind ;

::TuLoadCode | "" --
	'filename strcpy
	loadtxt ;

::TuNewCode
	"r3/new.r3" 'filename strcpy
	fuente '$fuente !
	0 fuente !
	0 'hashfile !
	rewind ;

::TuSaveCode 
	savetxt ;

|----
::tokenCursor | 'mark --
	dup $fff and 
	ylinea <? ( 2drop ; ) 
	ylinea -
	fh >? ( 2drop ; ) 
	over 12 >> $fff and xlinea - -? ( 3drop ; ) fw nlw - >=? ( 3drop ; ) fx + nlw + 
	swap fy + .at
	dup 24 >> $ffff and fuente + 
	swap 40 >> $ff and .type
	;

|---------------	
:
	here 8 +
	dup 'fuente !
	dup 'fuente> !
	dup '$fuente !
	$3ffff +			| 256kb texto
	dup 'undobuffer !
	clearundo
	$8000 +				| 32kb undo/redo (4096 registros)
	'here ! | -- FREE
	mark 
;