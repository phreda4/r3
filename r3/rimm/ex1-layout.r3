| RIMM example 1: layout by columns, vtabs, sections, vthemes
| run:  ./r3lin r3/rimm/ex1-layout.r3
| F1 changes the theme, ESC exits
^r3/rimm/rimm.r3

#font1

#vtab 0
#vtabs "Layout" "Widgets" "Listas" 0

#vname * 64
#vesc 1.0
#vcnt 40
#vmodo 0 0 | combo and list variables have two cells: chosen, first line shown
#vmodos "Normal" "Suave" "Duro" "Extra" 0
#vbits 5
#vbitsl "Sombras" "Bordes" "Luces" 0
#vrad 1
#vradl "Bajo" "Medio" "Alto" 0
#tg1 1 #tg2 0 #tg3 1 #tg4 0 #tg5 0
#sec1 1
#sec2 1
#vclicks 0

#vthemes "Dark" "Light" "Blender" "Godot" "Magica" 0
#vthsel 0

:cuenta 1 'vclicks +! ;

#vcw4 0.4 0.2 0.2 0.2

:tablayout
	| property rows: vname 40% | value 60%
	0.4 uiProps
	"Nombre" uiLabel 'vname 32 uiInputLine
	"Escala" uiLabel 0.0 2.0 'vesc uiSliderf
	"Cantidad" uiLabel 0 100 'vcnt uiSlideri
	"Modo" uiLabel 'vmodo 'vmodos uiCombo
	1 uiCols
	ui--
	| five equal columns
	5 uiCols
	'tg1 "A" uiToggle 'tg2 "B" uiToggle 'tg3 "C" uiToggle
	'tg4 "D" uiToggle 'tg5 "E" uiToggle
	1 uiCols
	ui--
	| a long vname and three short boxes: weights (0 = the rest, negative = pixels)
	'vcw4 4 uiColsW
	"Nombre largo" uiLabel
	'tg1 "1" uiToggle 'tg2 "2" uiToggle 'tg3 "3" uiToggle
	1 uiCols
	;

:tabwidgets
	'sec1 "Opciones" uiSection 1? ( 'vbits 'vbitsl uiCheck ) drop
	'sec2 "Calidad" uiSection 1? ( 'vrad 'vradl uiRadio ) drop
	ui--
	3 uiCols
	'cuenta "Uno" uiBtn
	'cuenta "Dos" uiBtn
	'cuenta "Tres" uiBtn
	'cuenta ICPLUS uiIBtn
	'cuenta ICX uiIBtn
	[ stDang ; ] "Rojo" uiBtn
	1 uiCols
	vclicks "Clicks: %d" sprint uiLabel ;

#vtree 0 0
#treeex "@Proyecto" "ASrc" "Bmain.r3" "Brimm.r3" "AMedia" "BVoxels" "BSonidos" "@Docs" "AREADME" "@Notas" 0
#lsel 0 0
#listex "uno" "dos" "tres" "cuatro" "cinco" "seis" "siete" "ocho" "nueve" 0

:tablistas
	| a list and a tree, one per column: each takes its cell
	2 uiCols
	'lsel 6 'listex uiList
	'vtree 6 'treeex uiTree
	1 uiCols ;

:main
	$101010 cls
	vthsel thNow <>? ( dup uiTheme ) drop
	uiStart
	10 10 420 sh 20 - uiBox
	uiPanelBg
	"RIMM  -  layout por columnas" uiLabelC
	'vthsel 'vthemes uiTabs
	'vtab 'vtabs uiTabs
	ui--
	vtab
	0? ( tablayout )
	1 =? ( tabwidgets )
	2 =? ( tablistas )
	drop
	uiEnd
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( thNext thNow 'vthsel ! )
	drop ;

:
	"RIMM ex1" 960 640 SDLinitR
	"media/ttf/Roboto-Medium.ttf" 18 txload 'font1 !
	font1 txfont
	'main SDLshow
	SDLquit ;
