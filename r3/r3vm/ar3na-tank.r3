| ar3na tank
| PHREDA 2025
|
| tres pantallas:
|  1) configuracion: cantidad de tanques y script de cada uno
|  2) editor de scripts con la ayuda de las palabras del tanque
|  3) juego: solo se ve la arena
|
| gui y editor: RIMM (rimmsdl, rimmwid, rimmedit)
| ttext queda solo para el titulo, la ayuda y la arena
|-------------------------
^r3/lib/str.r3
^r3/lib/mem.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^r3/rimm/rimmsdl.r3
^r3/rimm/rimmwid.r3
^r3/rimm/rimmedit.r3

^./arena-tank.r3
^./rcodevm.r3

|------------------- datos
#scripts * 1024		| nombres de scripts (32 de 32 bytes)
#scount
#stmp * 32
#keepn * 256		| nombres guardados de cada tanque
#nname * 32

#ntanks 2
#tcode * 64		| script (indice) de cada tanque
#cur			| tanque / fila actual
#etank #eoff		| tanque y posicion del error
#wantedit #again #paused
#okt			| momento del ultimo "compile OK"
#nn
#act #acti		| accion pedida por un boton (se hace al terminar el cuadro)
#fmono #fmain	| fuentes: monoespaciada (editor) y normal

| posiciones iniciales (x y)
#spawns
-170.0 -60.0  150.0 80.0  -60.0 170.0  70.0 -170.0
-170.0 140.0  170.0 -120.0  170.0 150.0  -150.0 -150.0

#order 0 1 2 3 4 5 6 7	| punto de salida de cada tanque (se mezcla en cada partida)

#template "| nuevo script de tanque
| ver la ayuda en la pantalla de edicion

#radar 0.0	| direccion del radar
#blanco 0.0	| distancia al enemigo

: 1 ( 1?
	radar scan 'blanco !
	blanco 1? ( radar turn blanco fire ) 0? ( 0.03 radar + $ffff and 'radar ! ) drop
	) drop ;
"

|------------------- lista de scripts
:tc@ | i -- idx
	3 << 'tcode + @ ;
:tc! | idx i --
	3 << 'tcode + ! ;
:sname | n -- adr
	5 << 'scripts + ;
:spath | n -- "path"
	sname "r3/r3vm/codetank/%s" sprint ;

:addscript | entry --
	dup FDIR 1? ( 2drop ; ) drop
	FNAME ".r3" =pos 0? ( 2drop ; ) drop
	dup count nip 30 >? ( 2drop ; ) drop
	scount 32 >=? ( 2drop ; ) drop
	scount sname strcpy 1 'scount +! ;

:sswap | i j --
	over sname 'stmp strcpy
	dup sname pick2 sname strcpy
	'stmp over sname strcpy 2drop ;

:ssort
	0 ( scount 1- <?
		dup 1+ ( scount <?
			over sname over sname cmpstr 0 >? ( drop 2dup sswap 0 ) drop
			1+ ) drop
		1+ ) drop ;

:scanscripts
	0 'scount !
|WIN|	"r3/r3vm/codetank//*" ffirst
|LIN|	"r3/r3vm/codetank" ffirst
|MAC|	"r3/r3vm/codetank" ffirst
	( 1? addscript fnext ) drop
	ssort ;

:sfind | "name" -- idx
	0 ( scount <?
		dup sname pick2 = 1? ( drop nip ; ) drop
		1+ ) drop drop 0 ;

:keepnames
	0 ( 8 <? dup tc@ sname over 5 << 'keepn + strcpy 1+ ) drop ;
:restore
	0 ( 8 <? dup 5 << 'keepn + sfind over tc! 1+ ) drop ;
:rescan
	keepnames scanscripts restore ;

:initcfg
	scanscripts
	2 'ntanks !
	"tank1.r3" sfind 0 tc!
	"tank1.r3" sfind 1 tc!
	"tank2.r3" sfind 2 tc!
	"tank3.r3" sfind 3 tc!
	4 ( 8 <? "tank1.r3" sfind over tc! 1+ ) drop ;

|------------------- editor
:chkcode | --
	mark
	fuente vmcompile
	1 >? ( 'terror ! 'fuente> ! clearmark
		fuente> $700ffff addsrcmark empty ; ) 2drop
	empty
	clearmark msec 'okt ! ;

:editscr
	vupdate $101010 cls
	2.0 tsize 0 0 tat $5 tcol "Ar3na" temits $3 tcol "Tank" temits
	1.0 tsize 6 tcol 150 4 tat "Editor: " temits 'edfilename temits
	msec okt - 2000 <? ( 3 tcol 520 4 tat "compile OK" temits ) drop
	632 20 tk.help
	1.0 tsize 6 tcol 8 590 tat "F1: comprobar   F2: guardar   ESC: volver (guarda)" temits
	uiStart
	0 32 624 550 uiBox
	fmono txfont uiEdit showmark fmain txfont
	uiEnd
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<F1> =? ( chkcode )
	<F2> =? ( edsave )
	drop ;

:runedit
	uiRefocus
	'editscr SDLshow
	edsave ;

:editscript | idx --
	spath edload
	0 'okt ! clearmark
	runedit ;

:fixerror | --		; abre el script con error y marca la palabra
	etank tc@ spath edload
	fuente eoff + 'fuente> !
	0 'okt ! clearmark
	fuente> $700ffff addsrcmark
	runedit ;

|------------------- juego
:loadscript | "path" -- str
	here dup rot load 0 swap c!
	dup only13 'here ! ;

:ord@ | i -- v
	3 << 'order + @ ;

:ord! | v i --
	3 << 'order + ! ;

:swapo | i j --
	over ord@ over ord@						| i j vi vj
	pick3 ord!								| order[i] = vj
	swap ord! drop ;						| order[j] = vi

:shuffle | --		; orden al azar de los puntos de salida
	7 ( 1? dup dup 1+ randmax swapo 1- ) drop ;

:spawn | n -- hdg x y		; punto de salida mezclado, rumbo al centro +-0.03 vueltas
	ord@ 4 << 'spawns + @+ swap @
	over neg over neg tk.bear 3932 randmax + 1966 - -rot ;

:startone | -- err		; compila el script del tanque cur y lo crea
	cur tc@ spath loadscript
	dup vmcompile
	1 >? ( 'terror ! over - 'eoff ! drop cur 'etank ! 1 ; ) 2drop drop
	0 'terror !
	cur spawn tk.+tank
	0 ;

:compileall | -- err
	tk.reset
	msec 31 rerand shuffle				| cada partida sale distinta
	0 'cur !
	( cur ntanks <? drop
		startone 1? ( ; ) drop
		1 'cur +! ) drop
	0 ;

:endmsg
	4.0 tsize 7 tcol
	tkwin -? ( drop 448 270 tat "DRAW" temits ; )
	1+ 336 270 tat "TANK %d WINS" tprint ;

:errmsg
	tkerrcode 'terror !
	2.0 tsize 5 tcol 340 250 tat tkerrtank 1+ "Tank %d: " tprint vmerror temits
	1.0 tsize 6 tcol 300 290 tat "E: editar el script    R: reintentar    ESC: volver" temits ;

:playhud
	tkrun 2 =? ( drop endmsg
		1.0 tsize 6 tcol 360 560 tat "R: otra partida    ESC: volver" temits ; )
	3 =? ( drop errmsg ; )
	drop ;

:playedit | --
	tkrun 3 <>? ( drop ; ) drop
	tkerr tkerrbase - 'eoff !
	tkerrcode 'terror !
	tkerrtank 'etank !
	1 'wantedit ! exit ;

:playscr
	vupdate 0 cls
	paused 0? ( tk.update ) drop
	tk.draw
	playhud
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<R> =? ( 1 'again ! exit )
	<spc> =? ( paused 1 xor 'paused ! )
	<E> =? ( playedit )
	drop ;

:game1 | --
	mark
	compileall
	1? ( drop empty fixerror ; ) drop
	0 'paused !
	'playscr SDLshow
	empty
	wantedit 1? ( drop 0 'wantedit ! fixerror ; ) drop ;

:playgame
	scount 0? ( drop ; ) drop
	1 ( 1? drop 0 'again ! game1 again ) drop ;

|------------------- configuracion
:prevcode
	scount 0? ( drop ; ) drop
	cur tc@ 1- -? ( drop scount 1- ) cur tc! ;

:nextcode
	scount 0? ( drop ; ) drop
	cur tc@ 1+ scount >=? ( drop 0 ) cur tc! ;

:goplay 1 'act ! ;
:editcode
	scount 0? ( drop ; ) drop
	2 'act ! cur 'acti ! ;
:newcode 3 'act ! cur 'acti ! ;

:freename | -- n
	1 ( dup "r3/r3vm/codetank/mytank%d.r3" sprint filexist 1? drop 1+ ) drop ;

:donew
	freename 'nn !
	'template count nn "r3/r3vm/codetank/mytank%d.r3" sprint save
	nn "mytank%d.r3" sprint 'nname strcpy
	rescan
	'nname sfind cur tc!
	cur tc@ editscript ;

:doact | -- ; acciones de los botones, fuera del cuadro de la gui
	act 0? ( drop ; )
	0 'act !
	1 =? ( drop playgame ; )
	2 =? ( drop acti tc@ editscript ; )
	3 =? ( drop acti 'cur ! donew ; )
	drop ;

:sname@ | -- str
	scount 0? ( drop "(sin scripts)" ; ) drop
	cur tc@ sname ;

#rw -30 -90 -40 1.0 -40 -90 -90
#bw -200 -160 1.0

:rowtank | i --
	'cur !
	'rw 7 uiColsW
	cur tk.rgb color uiFill ui..
	cur 1+ "Tank %d" sprint uiLabel
	'prevcode "<" uiBtn
	sname@ uiLabelC
	'nextcode ">" uiBtn
	stSucc 'editcode "Edit" uiBtn
	stWarn 'newcode "New" uiBtn
	stTheme ;

:cfgscr
	vupdate $101010 cls
	6.0 tsize 24 4 tat $5 tcol "Ar3na" temits $3 tcol "Tank" temits
	uiStart
	40 96 sw 80 - sh 106 - uiBox
	8 6 uiPad
	44 uiS
		'bw 3 uiColsW
		stSucc 'goplay "PLAY" uiBtn
		stDang 'exit "EXIT" uiBtn
		stTheme "F1: jugar   ESC: salir" uiLabelR
		1 uiCols
	uiRest
	"Tanques" 1 8 'ntanks uiSlideriL
	ui--
	0 ( ntanks <? dup rowtank 1+ ) drop
	1 uiCols ui--
	"< > elige el script   Edit lo edita   New crea uno" uiLabel
	uiEnd
	sdlredraw
	doact
	sdlkey
	>esc< =? ( exit )
	<F1> =? ( playgame )
	drop ;

|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	2.0 8 8 "media/img/atascii.png" tfnt
	"media/ttf/VictorMono-Bold.ttf" 16 txload 'fmono !
	"media/ttf/Roboto-Medium.ttf" 18 txload dup 'fmain ! txfont
	64 vaini
	edram	| editor
	tk.ini
	512 'tkpx ! 300 'tkpy !
	initcfg
	'cfgscr SDLshow
	SDLquit
	;
