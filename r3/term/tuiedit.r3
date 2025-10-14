^./tui.r3
^r3/lib/trace.r3

#hashfile 
##filename * 1024

#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor

#scrini>	| comienzo de pantalla
#scrend>	| fin de pantalla

#fuente		| fuente editable
#fuente> 	| cursor
#$fuente	| fin de texto

#clipboard	|'clipboard
#clipboard>

#undobuffer |'undobuffer
#undobuffer>

#linecomm 	| comentarios de linea
#linecomm>

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

:kback
	fuente> fuente <=? ( drop ; )
	dup 1- c@ undobuffer> c!+ 'undobuffer> !
	dup 1- swap $fuente over - 1+ cmove
	-1 '$fuente +!
	-1 'fuente> +! ;

:kdel
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
		dup c@ 13 =? ( drop 1- ; ) | quitar el 1 -
		drop 1+ ) 2 - ;

:khome	fuente> 1- <<13 1+ 'fuente> ! ;
:kend	fuente> >>13 1+ 'fuente> ! ;

:setpantafin
	scrini>
	fh ( 1? swap >>13 1+ swap 1- ) drop
	$fuente <? ( 1- ) 'scrend> ! ;
	
:setpantaini
	scrend>
	fh ( 1? swap 2 - <<13 1+ swap 1- ) drop
	fuente <? ( fuente nip ) 'scrini> !	;
	
:fixcur
	fuente>
	scrini> <? ( <<13 1+ 'scrini> ! -1 'ylinea +! setpantafin ; )
	scrend> >? ( >>13 2 + 'scrend> ! 1 'ylinea +! setpantaini ; )
	drop ;

:karriba
	fuente> fuente =? ( drop ; )
	dup 1- <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1- <<13			| cnt cur cura
	swap over - 		| cnt cura cur-cura
	rot min + fuente max
	'fuente> ! fixcur ;

:kabajo
	fuente> $fuente >=? ( drop ; )
	dup 1- <<13 | cur inilinea
	over swap - swap | cnt cursor
	>>13 1+		| cnt cura
	dup 1+ >>13 1+ 	| cnt cura curb
	over - rot min +
	'fuente> ! fixcur ;

:kder	fuente> $fuente <? ( 1+ 'fuente> ! ; ) drop ;
:kizq	fuente> fuente >? ( 1- 'fuente> ! ; ) drop ;
:kpgup	fh ( 1? 1- karriba ) drop ;
:kpgdn	fh ( 1? 1- kabajo ) drop ;

|------------------------------------------------
:simplehash | adr -- hash
	0 swap ( c@+ 1? rot dup 5 << + + swap ) 2drop ;
	
:loadtxt | -- ; cargar texto
	fuente 'filename 
	load 0 swap c!
	fuente only13 1- '$fuente !	|-- queda solo cr al fin de linea
	fuente dup 'scrini> ! simplehash 'hashfile !
	;

|-----------------
::TuLoadCode | "" --
	'filename strcpy
	loadtxt
	;

:savetxt | -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
	'filename savemem
	empty 
	;
	
|-----------------
#focoe	
#modoline
	
:codecolor | adr -- adr
	dup c@ 
	33 <? ( drop ; )
	$22 =? ( drop 7 .fc 3 'modoline ! ; )		| $22 " string
	$5e =? ( drop 3 .fc 2 'modoline ! ; )		| $5e ^  Include
	$7c =? ( drop 8 .fc 2 'modoline ! ; )		| $7c |	 Comentario
	$3A =? ( drop 9 .fc ; )		| $3a :  Definicion
	$23 =? ( drop 13 .fc ; )	| $23 #  Variable
	$27 =? ( drop 6 .fc ; )	| $27 ' Direccion
	drop
	dup isNro 1? ( drop 11 .fc ; ) drop
|	dup isBase 
|	1? ( 18 <? ( drop 12 .fc ; ) drop 10 .fc ; ) 
|	drop
	10 .fc ;
	
:setcursor | y c adr
	focoe 1? ( .savec ) drop
	pick2 ylinea + 1+ 'ycursor ! ;
	
:fillend | nlin cnt adr -- nlin adr 	
	swap 1+ .nsp ;

:tabchar | adr 9 -- adr 32
	drop swap 1- swap .sp 32 ;
	
:cemit | adr char -- adr 
	modoline 0? ( drop
		9 =? ( tabchar )
		32 =? ( .emit codecolor ; ) 
		.emit ; ) 
	3 =? ( drop .emit 1 'modoline ! ; ) | prev is "
	2 =? ( drop 9 =? ( tabchar ) .emit ; ) drop
	$22 =? ( .emit 0 'modoline ! codecolor ; ) | ""
	9 =? ( tabchar ) .emit ;
	
:drawline | nlin adr -- nlin adr
	0 'modoline ! | string multilinea****
	codecolor
	fw 5 - 
	( 1? 1- swap 
		fuente> =? ( setcursor )
		c@+ 0? ( drop fillend 1- ; ) | end of text
		13 =? ( drop fillend ; )
		cemit
		swap ) drop
	( c@+ 13 <>? 
		0? ( drop 1- ; ) | end of text
		drop ) drop ;

|-----------------
:cr.. | adr -- adr'
	( c@+ 1? 13 =? ( drop ; ) drop ) drop 1- ;
	
:clickMouse
	evtmxy fy -
	scrini> | x y c
	( swap 1? 1- swap cr.. ) drop | x c
	swap fx - 5 - clamp0 swap | 5- line numbers
	( swap 1? 1- swap 
		c@+ 
		9 =? ( rot 2 - clamp0 -rot )
		13 =? ( 0 nip )
		0? ( drop nip 1- ; ) 
		drop ) drop ;

| 0 = normal
| 1 = over (not all sytems)
| 2 = in
| 3 = active
| 4 = active(outside)
| 5 = out
| 6 = click
:EditMouse
	tuiw 
	6 =? ( clickMouse 'fuente> ! )
	drop ;
	
|-----------------
:chmode
	modo 'lins =? ( drop 'lover 'modo ! .ovec ; )
	drop 'lins 'modo ! .insc ;

:EditFoco
	tuif 0? ( 'focoe ! ; )
	|1 =? ( startfocus ) 
	'focoe !
	tuC!	| activate cursor
	uikey 0? ( drop ; )	
	32 126 in? ( modo ex fixcur ; ) 
	[tab] =? ( modo ex fixcur ; ) 
	[enter] =? ( modo ex fixcur ; ) 
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
	[INS] =? ( chmode )	
	drop 
	fixcur ;
	
|---------------	
:iniline
	.reset |.rever
	dup ylinea + 1+ 
	ycursor =? ( 0 .bc .d 4 .r. .write .sp ; ) |">" .write ; )
	234 .bc	.d 4 .r. .write .sp ;

::tuEditCode 
	EditMouse
	EditFoco
	fw 8 <? ( drop ; ) drop
	scrini>
	0 ( fh <?
		fx over fy + .at
		iniline swap 
		drawline swap 
		1+ ) drop 
	$fuente <? ( 1- ) 
	'scrend> ! ;

|---------------	
:
	here
	dup 'fuente !
	dup 'fuente> !
	dup '$fuente !
	$ffff +			| 64kb texto
	dup 'clipboard !
	dup 'clipboard> !
	$fff +				| 4KB
	dup 'undobuffer !
	dup 'undobuffer> !
	$fff +				| 4kb
	dup 'linecomm !
	dup	'linecomm> !
	$3fff +				| 4096 linecomm
	'here ! | -- FREE
	mark 
;