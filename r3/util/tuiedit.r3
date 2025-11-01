| Text Editor
| PHREDA 2025

^r3/util/tui.r3
|^r3/lib/trace.r3

#hashfile 
##filename * 1024

#xlinea 0
#ylinea 0	| primera linea visible
#ycursor
#xcursor

#inisel		| inicio seleccion
#finsel		| fin seleccion

#scrini>	| comienzo de pantalla
#scrend>	| fin de pantalla

##fuente		| fuente editable
##fuente> 	| cursor
##$fuente	| fin de texto

#clipboard	|'clipboard
#clipboard>

#undobuffer |'undobuffer
#undobuffer>

:inselect | adr -- adr
	inisel finsel in? ( 18 .bc ) ;
	
:atselect | adr -- addr
	inisel =? ( 18 .bc ; ) 
	finsel =? ( fuente> =? ( 233 .bc ; ) 235 .bc ) ;

#1sel #2sel

:sela	| add to select 
	inisel 0? ( fuente> '1sel ! ) drop
	fuente> dup '2sel !
	1sel over <? ( swap ) 'finsel ! 'inisel ! ;

:sele | empty select
	0 dup 'inisel ! 'finsel ! ; 
	
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
	( $fuente <=?
		dup c@ 13 =? ( drop ; )
		drop 1+ ) 1- ;

:khome	fuente> 1- <<13 1+ 'fuente> ! ;
:kend	fuente> >>13 'fuente> ! ;

|------- calc xy cursor
:emitcur
	13 =? ( drop 1 'ycursor +! 0 'xcursor ! ; )
	9 =? ( drop 2 'xcursor +! ; )
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
	( fuente> <? c@+ emitcur ) drop 
	xcursor
	xlinea <? ( dup 'xlinea ! )
	xlinea fw + >=? ( dup fw - 1+ 'xlinea ! )
	drop ;
	
|-----------
:setpantafin | cursor --
	1- <<13 1+ dup 'scrini> !
	fh ( 1? swap >>13 swap 1- ) drop
	|$fuente <? ( 1- ) 
	'scrend> ! ;
	
:setpantaini | cursor --
	>>13 1+ dup 'scrend> ! 
	fh ( 1? swap 2 - <<13 1+ swap 1- ) drop
	fuente <? ( fuente nip ) 'scrini> !	;
	
:fixcur
	fuente>
	scrini> <? ( setpantafin ; )
	scrend> >=? ( setpantaini ; )
	drop ;
	
|-----------
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
	>>13		| cnt cura
	dup 1+ >>13 	| cnt cura curb
	over - rot min +
	'fuente> ! ;

:kder	fuente> $fuente <? ( 1+ 'fuente> ! ; ) drop ;
:kizq	fuente> fuente >? ( 1- 'fuente> ! ; ) drop ;
:kpgup	fh ( 1? 1- karriba fixcur ) drop ;
:kpgdn	fh ( 1? 1- kabajo fixcur ) drop ;

:scrollup | 'fuente -- 'fuente
	scrini> 2 - <<13 1+ 
	fuente <=? ( drop ; )
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
	
:loadtxt | -- ; cargar texto
	fuente 'filename 
	load 0 swap c!
	fuente only13 1- '$fuente !	|-- queda solo cr al fin de linea
	fuente dup 'scrini> ! dup 'fuente> !
	simplehash 'hashfile !
	;

:savetxt | -- ; guarda texto
	fuente simplehash hashfile =? ( drop ; ) drop | no cambio
	mark	
	fuente ( c@+ 1?
		13 =? ( ,c 10 ) ,c ) 2drop
	'filename savemem
	empty 
	;
	
|---- draw text with colors
#focoe	
#modoline
	
:codecolor | adr -- adr
	dup c@ 
	33 <? ( drop ; )
	$22 =? ( drop 15 .fc 3 'modoline ! ; )		| $22 " string
	$5e =? ( drop 11 .fc 2 'modoline ! ; )		| $5e ^  Include
	$7c =? ( drop 8 .fc 2 'modoline ! ; )		| $7c |	 Comentario
	$3A =? ( drop 196 .fc ; )		| $3a :  Definicion
	$23 =? ( drop 201 .fc ; )	| $23 #  Variable
	$27 =? ( drop 50 .fc ; )	| $27 ' Direccion
	drop
	dup isNro 1? ( drop 226 .fc ; ) drop
|	dup isBase 
|	1? ( 18 <? ( drop 20 .fc ; ) drop 214 .fc ; ) 
|	drop
	46 .fc ;
	
:setcursor | y c adr
	focoe 1? ( .savec ) drop ;
	
:fillend | nlin cnt adr -- nlin adr 	
	|nip .eline ;
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

:iniline | adr lin -- adr lin 
	.reset |.rever
	fx over fy + .at
	dup ylinea +  
	ycursor =? ( 233 .bc 7 .fc 1+ .d 4 .r. .write .sp ; ) |">" .write ; )
	235 .bc 240 .fc 1+ .d 4 .r. .write .sp ;
	
:drawline | nlin adr -- nlin adr
	inselect
	0 'modoline ! | string multilinea****
	codecolor
	fw 5 - 
	( 1? 1- swap 
		fuente> =? ( setcursor )
		atselect
		c@+ 0? ( drop fuente> =? ( setcursor ) nip 1- ; ) 
		13 =? ( drop fillend ; )
		cemit
		swap ) drop
	( atselect c@+ 13 <>? 
		0? ( drop 1- ; ) | end of text
		drop ) drop ;

:lastline
	dup 1- c@ 13 =? ( drop swap 1+ iniline setcursor drop ; ) drop
	setcursor nip ;
	
:drawlines | ini -- end
	0 ( fh <?
		iniline swap 
		drawline
		$fuente =? ( | line adr
			fuente> =? ( lastline ; ) | cursor in last position
			nip ; ) | not draw more
		swap 1+ ) drop ;
		
|---- mouse & keys
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

#tclick

:dclick |"double click" .println
	fuente>
	( dup c@ $ff and 32 >? drop 1- ) drop
	1+ dup 'inisel ! 
	( c@+ $ff and 32 >? drop ) drop
	1- 'finsel !
	;
	
:dns
	clickMouse '1sel ! ;

:mos
	clickMouse
	1sel over <? ( swap )
	'finsel ! 'inisel ! ;

:ups
	msec dup tclick - 400 <? ( 2drop dclick ; ) drop 'tclick !
	clickMouse
	1sel 
	over =?  ( 2drop 0 'inisel ! ; )
	over <? ( swap )
	'finsel ! 'inisel ! ;

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
	6 =? ( ups clickMouse 'fuente> ! )
	drop ;
	
:chmode
	modo 'lins =? ( drop 'lover 'modo ! .ovec ; )
	drop 'lins 'modo ! .insc ;

:EditFoco
	tuif 0? ( 'focoe ! ; )
	|1 =? ( startfocus ) 
	'focoe !
	tuC!	| activate cursor
	evtmw 1? ( evwmouse cursorpos ) drop
	uikey 0? ( drop ; )	
	32 126 in? ( modo ex fixcur cursorpos ; ) 
	[tab] =? ( modo ex fixcur cursorpos ; ) 
	[enter] =? ( 
|LIN| $d nip | in linux [enter] is $a
		modo ex fixcur cursorpos ; ) 
	[BACK] =? ( kback )
	[DEL] =? ( kdel )
	[UP] =? ( karriba sele ) 
	[DN] =? ( kabajo sele )
	[RI] =? ( kder sele ) 
	[LE] =? ( kizq sele )
	[HOME] =? ( khome sele ) 
	[END] =? ( kend sele )
	[PGUP] =? ( kpgup sele ) 
	[PGDN] =? ( kpgdn sele )
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
	drop 
	fixcur 
	cursorpos ;
	
|---- MAIN words
::tuEditCode 
	EditMouse
	EditFoco
	fw 8 <? ( drop ; ) drop
	scrini> drawlines 'scrend> ! ;

::tuReadCode
	fw 8 <? ( drop ; ) drop
	scrini> drawlines 'scrend> ! ;
	
::tudebug
	ycursor 1+ xcursor 1+ " %d:%d " sprint ;
	
::TuLoadCode | "" --
	'filename strcpy
	loadtxt ;

::TuNewCode
	"r3/new.r3" 'filename strcpy
	fuente dup '$fuente ! dup 'scrini> ! 'fuente> !
	0 fuente !
	0 'hashfile !
	;

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
	'here ! | -- FREE
	mark 
;