| Riv Ide Editor
| PHREDA 2026

^r3/lib/console.r3
^r3/lib/clipboard.r3
^r3/util/utfg.r3
|^r3/lib/trace.r3

#hashfile 
#filename * 1024

#src
#src>
#src$

#view>
#viewx 0
#viewy 0
#vieww 40
#viewh 20

#mode 0
#ncount	

#line * 2048

#pad * 512
#msg * 512

#curx
#cury
#padp

#yank * 4096
#yanklen 0
#remend
#pending 0
#cmdtype 0
#searchpat * 512
#vstart

#undopos
#undoold * 4096
#undooldlen 0
#undonewlen 0
#undovalid 0

:cursorintext
	curx viewx - 1+ cury viewy - 1+ .at	 ;
	
:stm0
	cursorintext
	;
:stm1
	.yellow "-- INSERT --" .write
	cursorintext
	;
:stm2
	.yellow "-- REPLACE --" .write
	cursorintext
	;
:stm3
	.green "-- VISUAL --" .write
	cursorintext
	;
:stm4
	.green "-- VISUAL LINE--" .write
	cursorintext
	;
:stm5
	cmdtype 0? ( drop ":" .write 'pad .write ; )
	drop "/" .write 'pad .write
	;
	
#stmodes stm0 stm1 stm2 stm3 stm4 stm5
|---------------------------
:drawline
	vieww ( 1? 1- 
		ca@+ 0? ( drop 1+ .nsp -1 a+ ; ) 
		13 =? ( drop 1+ .nsp ; )
		9 =? ( drop .sp 32  ) 
		.emit ) drop ;

:drawscreen
	.reset .cls
	view> >a
	viewh 2 -
	0 ( over <?
		drawline .cr
		1+ ) drop 
		
	.rever
	vieww .nsp
	"[" .write 'filename .write "]" .write
	cury 1+ curx 1+ " %d:%d " .print 
	ncount " %d " .print
	src> c@ ">%h<" .print
	src> "%w" .print
	.cr
	.reset	
	mode 3 << 'stmodes + @ ex
	.flush
	;


|------- calc xy cursor

|----- edicion
:lins | c --
	src> dup 1- src$ over - 1+ cmove>
	1 'src$ +!
	src> c!+ 'src> ! ;
:lover | c --
	src> c!+ dup 'src> !
	src$ >? ( dup 'src$ ! ) drop ;
:0lin | --
	0 src$ c! ;

#modo 'lins

#ilinea

:<<13 | a -- a
	( src >=?
		dup c@ 13 =? ( drop ; )
		drop 1- ) ;

:>>13 | a -- a
	( src$ <=?
		dup c@ 13 =? ( drop ; )
		drop 1+ ) 1- ;

:back
	src> src <=? ( drop ; )
	src> 1- c@ 13 =? (
		drop
		-1 'cury +!
		src> 2 - <<13 1+ 'ilinea !
		src> 1- ilinea - 'curx !
		dup 1- swap src$ over - 1+ cmove
		-1 'src$ +!
		-1 'src> +!
		;
	)
	drop
	-1 'curx +!
	dup 1- swap src$ over - 1+ cmove
	-1 'src$ +!
	-1 'src> +! ;

:del
	src> src$ >=? ( drop ; )
	1+ src <=? ( drop ; )
	dup 1- swap src$ over - 1+ cmove
	-1 'src$ +! ;

|--- undo (un nivel)
:recdel | pos len --
	dup 'undooldlen !
	0 'undonewlen !
	over 'undopos !
	'undoold -rot cmove
	1 'undovalid ! ;

:recins | pos len --
	'undonewlen !
	'undopos !
	0 'undooldlen !
	1 'undovalid ! ;

|--- dd / yy / p / P (línea completa)
:dd
	src> 1- <<13 1+ 'ilinea !
	ilinea >>13 src$ <? ( 1+ ) 'remend !
	ilinea remend ilinea - recdel
	remend ilinea - 'yanklen !
	'yank ilinea yanklen cmove
	'yank yanklen copyclipboard
	ilinea remend src$ remend - 1+ cmove
	ilinea src$ remend - + 'src$ !
	ilinea 'src> !
	0 'curx !
	src> src <=? ( drop ; )
	src> src$ <? ( drop ; )
	src> 1- <<13 1+ 'src> !
	-1 'cury +! ;

:yy
	src> 1- <<13 1+ 'ilinea !
	ilinea >>13 src$ <? ( 1+ ) 'remend !
	remend ilinea - 'yanklen !
	'yank ilinea yanklen cmove
	'yank yanklen copyclipboard ;

:pasteat | at --
	yanklen 0? ( 2drop ; ) drop
	dup 'ilinea !
	dup yanklen recins
	dup yanklen + swap src$ over - 1+ cmove>
	yanklen 'src$ +!
	ilinea 'yank yanklen cmove ;

:kp | pegar debajo
	src> >>13 src$ <? ( 1+ ) pasteat
	yanklen 0? ( drop ; ) drop
	ilinea 'src> ! 0 'curx ! 1 'cury +! ;

:kP | pegar encima
	src> 1- <<13 1+ pasteat
	yanklen 0? ( drop ; ) drop
	ilinea 'src> ! 0 'curx ! ;

|--- portapapeles del sistema (xclip)
:cbfix | adr len -- ; normaliza \n a \r (nuestro separador de linea)
	over + swap ( over <?
		dup c@ 10 =? ( over 13 swap c! ) drop
		1+
		) drop ;

#cbbuf * 65536

:pasteclip
	'cbbuf pasteclipboard
	'cbbuf count 4096 min 'yanklen !
	'cbbuf yanklen cbfix
	'yank 'cbbuf yanklen cmove
	kp ;

:khome
	src> 1- <<13 1+ 'src> ! 0 'curx ! ;
:kend
	src> dup >>13 dup rot - 'curx ! 'src> ! ;
:kfspace
	src> 1- <<13 1+ 'src> ! 0 'curx ! 
	src> ( c@+ 0? ( 2drop -1 'curx +! ; ) 
		$ff and 32 <=? drop 1 'curx +! ) 2drop ;

:kup
	cury 0? ( drop ; ) drop | in start
	src> c@ 0? ( drop src> <<13 1+ 'src> ! -1 'cury +! ; ) drop | in end
	src> src <=? ( drop ; )
	dup 1- <<13		| cur inili
	swap over - swap	| cnt cur
	dup 1- <<13			| cnt cur cura
	dup 'ilinea !
	swap over - 		| cnt cura cur-cura
	rot min + src max 
	dup 'src> ! 
	ilinea 1+ - 'curx !
	-1 'cury +! ;

:kdn
	src> src$ >=? ( drop ; )
	dup 1- <<13 | cur inilinea	
	over swap - swap | cnt cursor
	>>13		| cnt cura
	dup 'ilinea !
	dup 1+ >>13 	| cnt cura curb
	over - rot min +
	dup 'src> ! 
	ilinea 1+ - 'curx !
	1 'cury +! ;

:kri
	src> src$ >=? ( drop ; ) 
	dup c@ 13 =? ( 2drop ; ) drop
	1+ 'src> !
	1 'curx +! ;

:kle	
	src> 1- src <=? ( drop ; ) 
	dup c@ 13 =? ( 2drop ; ) drop 
	'src> !
	-1 'curx +! ;
	
|------------------------------
	
:kcount
	$30 $39 in? ( dup $30 - ncount 10* + 'ncount ! ) ;
	
:vcount | vector --
	ncount 0? ( 1+ ) ( 1? 1- over ex ) 2drop
	0 'ncount ! ;

:kmovecursor
	[le] =? ( kle ) 
	[up] =? ( kup )	
	[dn] =? ( kdn ) 
	[ri] =? ( kri ) 
	[home] =? ( khome )
	[end] =? ( kend )
	;
	
:chmode
	modo 'lins =? ( drop 'lover 'modo ! .blockc ; )
	drop 'lins 'modo ! .insc ;

:kinstext
	32 126 in? ( dup modo ex 1 'curx +! )
	[tab] =? ( dup modo ex 2 'curx +! )
	[enter] =? ( dup modo ex 0 'curx ! 1 'cury +! )
	;

|--- D (borrar hasta fin de linea)
:kD
	src> >>13 'ilinea !
	src> ilinea src> - recdel
	src> ilinea src$ ilinea - 1+ cmove
	src$ ilinea src> - - 'src$ ! ;

|--- ~ (toggle mayus/minus y avanza)
:ktilde
	src> 1 recdel
	1 'undonewlen !
	src> c@ 'ilinea !
	ilinea 97 122 in? ( drop ilinea 32 - src> c! kri ; ) drop
	ilinea 65 90 in? ( ilinea 32 + src> c! ) drop
	kri ;

|--- G (ir al final) / gg (ir al inicio)
:kG
	( src> >>13 src$ <? drop kdn ) drop ;

:kgg
	src 'src> ! 0 'curx ! 0 'cury ! ;

|--- o / O (abrir linea debajo/encima)
:kopenb
	kend
	13 modo ex
	0 'curx ! 1 'cury +! ;

:kopena
	khome
	src> 'ilinea !
	13 modo ex
	ilinea 'src> !
	0 'curx ! ;

|--- recalcula curx/cury a partir de src> (para saltos como búsqueda/G)
:synccursor
	0 'cury !
	src 'ilinea !
	src ( src> <?
		dup c@ 13 =? ( 1 'cury +! over 1+ 'ilinea ! )
		drop
		1+ ) drop
	src> ilinea - 'curx ! ;

:undo
	undovalid 0? ( drop ; ) drop
	0 'undovalid !
	undopos undonewlen + 'ilinea !
	undopos ilinea src$ ilinea - 1+ cmove
	src$ undonewlen - 'src$ !
	undopos undooldlen + 'ilinea !
	ilinea undopos src$ undopos - 1+ cmove>
	src$ undooldlen + 'src$ !
	undopos 'undoold undooldlen cmove
	undopos 'src> !
	synccursor ;

|--- movimiento por palabras (w / b)
:skipword | avanza mientras haya texto no-espacio
	src> ( src$ <?
		dup c@ $ff and 32 <=? ( drop 'src> ! ; ) drop
		1+
		) 'src> ! ;

:skipspace | avanza mientras haya espacio/control
	src> ( src$ <?
		dup c@ $ff and 32 >? ( drop 'src> ! ; ) drop
		1+
		) 'src> ! ;

:skipwordback | retrocede mientras haya texto no-espacio
	src> ( src >?
		1- dup c@ $ff and 32 <=? ( drop 1+ 'src> ! ; ) drop
		) 'src> ! ;

:skipspaceback | retrocede mientras haya espacio/control
	src> ( src >?
		1- dup c@ $ff and 32 >? ( drop 1+ 'src> ! ; ) drop
		) 'src> ! ;

:kw
	skipword
	skipspace
	synccursor ;

:kb
	skipspaceback
	skipwordback
	synccursor ;

|--- rango de selección visual (char-wise o linea segun 'mode')
:vrange | -- ; deja lo en 'ilinea, hi+1 en 'remend
	vstart src> min 'ilinea !
	vstart src> max 'remend !
	mode 4 =? ( drop
		ilinea 1- <<13 1+ 'ilinea !
		remend >>13 src$ <? ( 1+ ) 'remend !
		; )
	drop
	remend 1+ 'remend ! ;

:visdel
	vrange
	ilinea remend ilinea - recdel
	remend ilinea - 'yanklen !
	'yank ilinea yanklen cmove
	'yank yanklen copyclipboard
	ilinea remend src$ remend - 1+ cmove
	ilinea src$ remend - + 'src$ !
	ilinea 'src> !
	0 'mode !
	synccursor ;

:visyank
	vrange
	remend ilinea - 'yanklen !
	'yank ilinea yanklen cmove
	'yank yanklen copyclipboard
	ilinea 'src> !
	0 'mode !
	synccursor ;

|--- búsqueda de texto (/pattern, n repite)
:kn | repite la ultima busqueda hacia adelante
	'searchpat c@ 0? ( drop ; ) drop
	src> 1+ 'searchpat findstr
	0? ( drop src 'searchpat findstr )
	0? ( drop ; )
	'src> !
	synccursor ;

:dosearch
	'pad c@ 0? ( drop kn ; )
	drop 'pad 'searchpat strcpy
	kn ;

|---NORMAL
:knor
	evtkey
	pending 0? (
		drop
		$64 =? ( drop $64 'pending ! ; )		| d (dd)
		$79 =? ( drop $79 'pending ! ; )		| y (yy)
		$67 =? ( drop $67 'pending ! ; )		| g (gg)
		kcount
		kmovecursor
		$3A =? ( 'pad 'padp ! 0 'pad c! 0 'cmdtype ! 5 'mode ! ) | :
		$2F =? ( 'pad 'padp ! 0 'pad c! 1 'cmdtype ! 5 'mode ! ) | /
		$6E =? ( kn ) | n (repite busqueda)
		$4E =? ( kn ) | N (repite busqueda, misma direccion por ahora)
		$30 =? ( khome ) | 0
		$24 =? ( kend ) | $
		$5e =? ( kfspace ) | ^
		
		$68 =? ( 'kle vcount ) |h
		$6A =? ( 'kdn vcount ) |j
		$6B =? ( 'kup vcount ) |k
		$6C =? ( 'kri vcount ) |l	
		
		$78 =? ( src> 1 recdel del ) | x
		$44 =? ( kD ) | D
		$70 =? ( kp ) | p
		$50 =? ( kP ) | P
		$7E =? ( ktilde ) | ~
		$47 =? ( kG ) | G
		
		$69 =? ( src> 'undopos ! 1 'mode ! ) | i
		$41 =? ( kend src> 'undopos ! 1 'mode ! ) | A
		$49 =? ( khome src> 'undopos ! 1 'mode ! ) | I
		$6F =? ( kopenb src> 'undopos ! 1 'mode ! ) | o
		$4F =? ( kopena src> 'undopos ! 1 'mode ! ) | O
		$72 =? ( chmode src> 'undopos ! 2 'mode ! ) | r
		$75 =? ( undo ) | u
		$16 =? ( pasteclip ) | ctrl-v (pegar del portapapeles del sistema)
		$76 =? ( src> 'vstart ! 3 'mode ! ) | v
		$56 =? ( src> 'vstart ! 4 'mode ! ) | V
		$77 =? ( kw ) | w
		$62 =? ( kb ) | b
		drop ;
	)
	=? (
		0 'pending !
		dup $64 =? ( drop dd ; )
		dup $79 =? ( drop yy ; )
		$67 =? ( drop kgg ; )
		drop ;
	)
	0 'pending !
	kcount
	kmovecursor
	drop ;
	
|---INSERT
:kins
	evtkey
	[esc] =? ( undopos src> undopos - recins 0 'mode ! ) 
	[back] =? ( back )
	kmovecursor
	kinstext
	drop ;
	
|---REPLACE
:krep
	evtkey
	[esc] =? ( chmode undopos src> undopos - recins 0 'mode ! ) 
	[back] =? ( back )
	kmovecursor	
	kinstext	
	drop ;
|---VISUAL
:kvis
	evtkey
	[esc] =? ( drop 0 'mode ! ; )
	$64 =? ( drop visdel ; )		| d
	$78 =? ( drop visdel ; )		| x
	$79 =? ( drop visyank ; )		| y
	kcount
	kmovecursor
	$68 =? ( 'kle vcount ) |h
	$6A =? ( 'kdn vcount ) |j
	$6B =? ( 'kup vcount ) |k
	$6C =? ( 'kri vcount ) |l
	$30 =? ( khome ) | 0
	$24 =? ( kend ) | $
	$77 =? ( kw ) | w
	$62 =? ( kb ) | b
	drop ;
|---CMD
:excmd | -- ejecuta comando del pad (:w :q :wq)
	'pad c@ $71 =? ( drop -1 'mode ! ; )		| q
	'pad c@ $77 =? ( drop
		src src$ src - 'filename save
		'pad 1+ c@ $71 =? ( drop -1 'mode ! ; )	| wq
		drop 0 'mode ! ; )				| w
	drop
	0 'mode ! ;

:kcmd
	evtkey
	[esc] =? ( drop 0 'mode ! 'pad 'padp ! 0 'pad c! ; )
	[enter] =? ( drop 0 padp c!
		cmdtype 0? ( drop excmd 'pad 'padp ! 0 'pad c! ; )
		drop dosearch 0 'mode !
		'pad 'padp ! 0 'pad c! ; )
	[back] =? ( padp 'pad >? ( -1 'padp +! 0 padp c! ) drop )
	32 126 in? ( dup padp c!+ 'padp ! 0 padp c! )
	drop ;

#kmode 'knor 'kins 'krep 'kvis 'kvis 'kcmd

:getevent
	inevt
	1 =? ( drop 'kmode mode 3 << + @ ex ; )
	| 2 =? ( hmou )
	drop
	50 ms getevent ;
	
:editor
	( mode -1 <>? drop
		drawscreen
		getevent
		) drop ;

::rivMem | "" --
	src strcpy
	src only13 1- 'src$ ! |-- queda solo cr al fin de linea
	src dup 'view> ! 'src> ! 
	0 'curx ! 0 'cury !
	0 'mode !
	;
	
#test
"esto es un texto de prueba
de varias lineas
para probar el editor"
	
|---------------	
:
	mark 
	here
	dup 'src ! $ffff +
	dup 'src$ ! $fff +
	'here
	src 'src> !
	0 'curx ! 0 'cury !
	0 'mode !
	.alsb
	0 'viewx ! 0 'viewy !
	cols 'vieww ! rows 'viewh !
	.ovec
	"riv.txt" 'filename strcpy
	'pad 'padp ! 0 'pad c!
	'test rivMem
	editor
	.masb 
	.free
	;