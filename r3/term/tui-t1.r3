| TUI demo con tui.r3 - cambiar el tamanio de la terminal reacomoda todo
| PHREDA 2026
^r3/util/tui.r3

|--- datos 
#light 0
#pal.alt [
	$fbfbf8 $eeeee8 $e0e0d8 $cfcfc6
	$1c1c20 $5c5c68 $9a9aa4 $c2571a
	$1f5fbf $6f42c1 $1a7f37 $cf222e $9a6700 ]

#cvec 'fTx 'fMu 'fDi 'fPr 'fBl 'fPu 'fGr 'fRd 'fYe
#cnam "fTx" "fMu" "fDi" "fPr" "fBl" "fPu" "fGr" "fRd" "fYe"

#tdb ( 0 0 0 2 0 1 0 0 )	| tabla: 3 columnas (w just), w se calcula con fw
#tdg ( 0 0 0 2 0 1 0 0 )	| tabla con recuadro, igual formato
#ndat 9
#dtable
	"uno|alfa|ok"
	"dos|señor español|ok"
	"tres|beta|no"
	"cuatro|gamma|ok"
	"cinco||no"
	"seis|delta|ok"
	"siete|epsilon|ok"
	"ocho|zeta|no"
	"nueve|eta|ok"
	0

#txt "El texto se reacomoda solo cuando cambia el tamanio de la terminal. Cada panel usa el layout de tui.r3 (flxN flxS flxO) y las palabras de tui.r3 para pintar: paleta, texto y tablas. Probá agrandar y achicar la ventana, o apretar t para cambiar el tema."

|--- barras 
:head
	fhome bg3 fPr .Bold " tui " .write .NBold fTx
	rows cols "demo  %dx%d" .print .eline ;

:foot
	fhome bg3 fTx " ESC " .write fMu "salir   " .write
	fTx "t " .write fMu "tema" .write .eline ;

|--- panel paleta 
:swatch
	bg0 fTx 6 "bg0" cwrite bg2 6 "bg2" cwrite bg3 6 "bg3" cwrite bg1 ;

:leftv | i --
	9 <? ( dup 3 << 'cvec + @ ex 'cnam swap n>>0 .write "  Aa" .write ; )
	9 =? ( drop swatch ; )
	10 =? ( drop fTx fw "izquierda" lwrite ; )
	11 =? ( drop fw "centro" cwrite ; )
	12 =? ( drop fw "derecha" rwrite ; )
	drop
	fMu "d" .write fTx 6 1234 .nd fMu " h" .write fTx 5 1234 .nh ;

:leftp
	"Paleta" pan
	'leftv fh 1- clamp0 14 min .lines ;

|--- panel tabla 
:tdefs | -- ; anchos de columna segun fw (50% 30% resto)
	fw 3 - clamp0
	dup 1 >> 255 min 'tdb c!
	dup 3 * 10 / 255 min 'tdb 2 + c!
	dup 1 >> over 3 * 10 / + - 255 min 'tdb 4 + c! ;

:zebra | i -- i
	dup 1 and 0? ( drop bg1 ; ) drop bg2 ;

:tabla
	"Tabla" pan
	tdefs 'tdb tcols
	"nombre|valor|ok" hdr
	fh 2 - clamp0 ndat min
	0 ( over <? zebra 'dtable over n>>0 row 1+ ) 2drop ;

|--- panel tabla con recuadro
:tdefg | -- ; anchos segun fw (bordes y espacios = 10)
	fw 10 - clamp0
	dup 1 >> 1 max 255 min 'tdg c!
	dup 3 * 10 / 1 max 255 min 'tdg 2 + c!
	dup 1 >> over 3 * 10 / + - 1 max 255 min 'tdg 4 + c! ;

:tablab
	"Recuadro" pan
	fw 14 <? ( drop "(angosto)" .lw ; ) drop
	tdefg 'tdg tcols
	tbtop
	"nombre|valor|ok" tbhdr
	tbsep
	fh 5 - clamp0 ndat min
	0 ( over <? zebra 'dtable over n>>0 tbrow 1+ ) 2drop
	bg1 tbbot ;


|--- panel texto 
:texto
	"Texto" pan
	0 1 flpad
	fMu 'txt $00 tuText ; 

|--- pantalla 
:theme
	light 1 xor 'light !
	light 1? ( drop 'pal.alt pal! ; ) drop
	'pal.dark pal! ;

:chico
	1 1 .at "terminal chica (min 40x12)" .write ;

#salio 

:exitdlg
	"Salir" 46 9 tuDlg
	fcr
	"Seguro que queres salir?" .cw
	fcr
	1 flxS fhome
	fMu "[ENTER] ok   [ESC] cancelar" .cw
	flxRest
	tuDlgEnd	
	uikey 
	[esc] =? ( exit ) 
	$d =? ( 1 'salio ! exit ) 
	drop
	;
	
:dialogexit
	0 'salio !
	'exitdlg onTui
	salio 1? ( exit ) drop
	;
	
:demo
	.reset bg0 fTx .cls
	cols 40 <? ( drop chico ; ) drop
	rows 12 <? ( drop chico ; ) drop
	1 flxN head
	1 flxS foot
	fw 3 / 22 max 30 min flxO
	leftp
	flxRest
	fh 2/ flxN
	flxpush
	fw 2/ flxO tabla
	flxRest tablab
	flxpop
	flxRest
	texto 
	uikey 
	$74 =? ( theme ) 
	[esc] =? ( dialogexit )
	drop
	;

|-----------------------------------
:
	.alsb
|	onTuiNoExit
|	'changeres onTuiResize
	'demo onTui
	.masb .free ;
