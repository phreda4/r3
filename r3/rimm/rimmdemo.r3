| RIMM demo: every widget and every possibility, without a backend
| It does not include any backend: the launcher includes one first.
|   demo-sdl.r3   SDL2 render          ./r3lin r3/rimm/demo-sdl.r3
|   demo-gl.r3    OpenGL (glgfx)       ./r3lin r3/rimm/demo-gl.r3
| The same code, the same widgets, the same themes in both. F1 theme, F2 skin.
|
|   demoBack! "name"   name of the backend shown in the title
|   demoFrame          draws the gui of a frame (between the clear and the swap)
|   demoKey key        keys of the demo (F1, F2); consumes the key
|
^r3/rimm/rimmwid.r3
^r3/rimm/rimmcolor.r3
^r3/rimm/rimmfile.r3

#dbackn 0
::demoBack! | "name" -- ;
	'dbackn ! ;

|--- data of the widgets
#dpage 0
#dpages "Layout" "Botones" "Valores" "Listas" "Selectores" "Estilo" 0
#dthsel 0
#dthemes "Dark" "Light" "Blender" "Godot" "Magica" 0

#dsec1 1 #dsec2 1 #dsec3 1
#dname * 64
#desc 1.0
#dmodo 0 0
#dmodos "Normal" "Suave" "Duro" "Extra" 0
#dtab 0
#dtabs "Uno" "Dos" "Tres" 0
#dt1 1 #dt2 0 #dt3 1 #dt4 0 #dt5 0
#dw4 0.4 0.2 0.2 0.2
#dw3 1.0 -80 -80
#dtxt * 64

#dclicks 0
#dsf 0.5 #dsi 120 #dpf 0.3
#dv1 0.2 #dv2 0.5 #dv3 0.8 #dv4 0.4
#dvi 50

#dlist 0 0
#dlistex "uno" "dos" "tres" "cuatro" "cinco" "seis" "siete" "ocho" "nueve" "diez" 0
#dtree 0 0
#dtreeex "@Proyecto" "ASrc" "Bmain.r3" "Brimm.r3" "AMedia" "BVoxels" "BSonidos" "@Docs" "AREADME" "@Notas" 0
#dchk 5
#dchkl "Sombras" "Bordes" "Luces" 0
#drad 1
#dradl "Bajo" "Medio" "Alto" 0

#dcol $3A86FF
#dcol2 $FF006E
#dfile * 1024
#dstripes 0

|--- custom content and skin
:ctNum | n --
	"%d clicks" sprint ttwritec ;

:skstripes
	colFill bx by bw bh frect
	colLight
	0 ( bw <? dup bx + by by bh + 1- lineV 6 + ) drop ;

:toggleskin
	dstripes 1 xor dup 'dstripes !
	1? ( 'skstripes skinBtn skin! )
	0? ( thNow uiTheme ) drop ;

:click 1 'dclicks +! ;

|--- pages
:pgLayout
	'dsec1 "uiProps: nombre | valor" uiSection 1? (
		0.4 uiProps
		"Nombre" uiLabel 'dname 32 uiInputLine
		"Escala" uiLabel 0.0 2.0 'desc uiSliderf
		"Modo" uiLabel 'dmodo 'dmodos uiCombo
		1 uiCols ) drop
	'dsec2 "Columnas iguales y tabs" uiSection 1? (
		5 uiCols
		'dt1 "A" uiToggle 'dt2 "B" uiToggle 'dt3 "C" uiToggle
		'dt4 "D" uiToggle 'dt5 "E" uiToggle
		1 uiCols
		'dtab 'dtabs uiTabs ) drop
	'dsec3 "Pesos, pixeles y uiSpan" uiSection 1? (
		'dw4 4 uiColsW
		"Nombre largo" uiLabel
		'dt1 "1" uiToggle 'dt2 "2" uiToggle 'dt3 "3" uiToggle
		'dw3 3 uiColsW
		"span 1" uiLabel 'dtxt 32 uiInputLine 'click "-80px" uiBtn
		3 uiCols
		2 uiSpan 'dtxt 32 uiInputLine 'click "uiSpan 2" uiBtn
		1 uiCols ) drop ;

:pgBotones
	3 uiCols
	stDang 'click "Peligro" uiBtn
	stWarn 'click "Aviso" uiBtn
	stSucc 'click "Exito" uiBtn
	stLink 'click "uiRBtn" uiRBtn
	stDark 'click "uiCBtn" uiCBtn
	stTheme 'click "Tema" uiBtn
	1 uiCols ui--
	4 uiCols
	'click ICPLUS uiIBtn 'click ICMINUS uiIBtn 'click ICX uiIBtn 'click ICCHK uiIBtn
	1 uiCols
	'click dclicks 'ctNum uiBtnX
	ui--
	'click "uiNBtn" uiNBtn 'click "ancho = texto" uiNBtn 'click "3" uiNBtn uiLn
	ui--
	2 uiCols
	'click "uiTBtnH: texto largo que se envuelve en el boton" $11 rh 3 * uiTBtnH
	'click "alto de 3 filas, en una celda" $11 rh 3 * uiTBtnH
	1 uiCols ;

:pgValores
	0.4 uiProps
	"Slider f" uiLabel -1.0 1.0 'dsf uiSliderf
	"Slider i" uiLabel 0 500 'dsi uiSlideri
	"Progreso" uiLabel 0.0 1.0 'dpf uiProgressf
	1 uiCols
	"Con nombre" 0.0 1.0 'dpf uiSliderfL
	"Entero" 0 500 'dsi uiSlideriL
	ui--
	4 uiCols
	110 'ch ! 0.0 1.0 'dv1 uiVSliderf
	110 'ch ! 0.0 1.0 'dv2 uiVSliderf
	110 'ch ! 0.0 1.0 'dv3 uiVSliderf
	110 'ch ! 0 100 'dvi uiVSlideri
	1 uiCols ;

:pgListas
	2 uiCols
	'dlist 6 'dlistex uiList
	'dtree 6 'dtreeex uiTree
	1 uiCols ui--
	'dchk 'dchkl uiCheck
	3 uiCols 'drad 'dradl uiRadio 1 uiCols
	'drad 'dradl uiRadio
	ui--
	0.4 uiProps
	"Combo" uiLabel 'dlist 'dlistex uiCombo
	1 uiCols ;

:pgSelectores
	0.3 uiProps
	"Color" uiLabel 'dcol uiColorH
	"Color 2" uiLabel 'dcol2 uiColor
	"Archivo" uiLabel 'dfile 1024 uiFileName
	"Texto" uiLabel 'dtxt 32 uiInputLine
	1 uiCols ;

:pgEstilo
	"Tema (F1)" uiLabel
	'dthsel 'dthemes uiTabs
	ui--
	"Forma de los botones (rrad)" uiLabel
	3 uiCols
	[ 0 stRad ; ] "Cuadrado" uiBtn
	[ 6 stRad ; ] "Redondo" uiBtn
	[ -1 stRad ; ] "Capsula" uiBtn
	1 uiCols
	ui--
	'toggleskin "Skin de rayas (skin!, F2)" uiBtn
	'dstripes "Skin de rayas" uiToggle
	ui--
	"Alto de fila (uiRowH)" uiLabel
	4 uiCols
	[ 18 uiRowH ; ] "18" uiBtn [ 22 uiRowH ; ] "22" uiBtn
	[ 26 uiRowH ; ] "26" uiBtn [ 32 uiRowH ; ] "32" uiBtn
	1 uiCols ;

::demoFrame | -- ; one frame of the gui
	dthsel thNow <>? ( dup uiTheme ) drop
	uiStart
	10 10 sw 20 - 560 min sh 20 - uiBox
	uiPanelBg
	dbackn "RIMM demo  -  backend: %s" sprint uiLabelC
	'dpage 'dpages uiTabs
	ui--
	dpage
	0? ( pgLayout )
	1 =? ( pgBotones )
	2 =? ( pgValores )
	3 =? ( pgListas )
	4 =? ( pgSelectores )
	5 =? ( pgEstilo )
	drop
	uiEnd ;

::demoKey | key -- ; F1 changes the theme, F2 the skin of the buttons
	<f1> =? ( thNext thNow 'dthsel ! )
	<f2> =? ( toggleskin )
	drop ;
