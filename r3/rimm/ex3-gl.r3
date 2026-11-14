| RIMM example 3: the same panel over OpenGL (glgfx + rimmfall)
| run:  ./r3lin r3/rimm/ex3-gl.r3      F1 theme, ESC exits
| The gui code is the same as ex1: only the include and the frame change
| (fini/fend around the gui; the bitmap font of glgfx instead of a ttf).
^r3/rimm/glrimm.r3
^r3/rimm/rimmcolor.r3

#vtab 0
#vtabs "Layout" "Widgets" "Listas" 0
#vname * 64
#vesc 1.0
#vcnt 40
#vmodo 0 0
#vmodos "Normal" "Suave" "Duro" "Extra" 0
#vbits 5
#vbitsl "Sombras" "Bordes" "Luces" 0
#vrad 1
#vradl "Bajo" "Medio" "Alto" 0
#tg1 1 #tg2 0 #tg3 1
#sec1 1
#vcol $FF8800
#vthemes "Dark" "Light" "Blender" "Godot" "Magica" 0
#vthsel 0
#vtree 0 0
#treeex "@Proyecto" "ASrc" "Bmain.r3" "Brimm.r3" "AMedia" "BVoxels" "BSonidos" "@Docs" "AREADME" "@Notas" 0
#lsel 0 0
#listex "uno" "dos" "tres" "cuatro" "cinco" "seis" "siete" "ocho" "nueve" 0

:tablayout
	0.4 uiProps
	"Nombre" uiLabel 'vname 32 uiInputLine
	"Escala" uiLabel 0.0 2.0 'vesc uiSliderf
	"Cantidad" uiLabel 0 100 'vcnt uiSlideri
	"Modo" uiLabel 'vmodo 'vmodos uiCombo
	"Color" uiLabel 'vcol uiColorH
	1 uiCols
	ui--
	3 uiCols
	'tg1 "A" uiToggle 'tg2 "B" uiToggle 'tg3 "C" uiToggle
	1 uiCols ;

:tabwidgets
	'sec1 "Opciones" uiSection 1? ( 'vbits 'vbitsl uiCheck ) drop
	'vrad 'vradl uiRadio
	ui--
	2 uiCols
	[ stDang ; ] "Rojo" uiBtn
	[ stInfo ; ] "Info" uiBtn
	'sec1 ICPLUS uiIBtn
	'sec1 ICX uiIBtn
	1 uiCols ;

:tablistas
	2 uiCols
	'lsel 6 'listex uiList
	'vtree 6 'treeex uiTree
	1 uiCols ;

:main
	GLcls
	vthsel thNow <>? ( dup uiTheme ) drop
	fini
	uiStart
	10 10 420 sh 20 - uiBox
	uiPanelBg
	"RIMM sobre OpenGL" uiLabelC
	'vthsel 'vthemes uiTabs
	'vtab 'vtabs uiTabs
	ui--
	vtab
	0? ( tablayout )
	1 =? ( tabwidgets )
	2 =? ( tablistas )
	drop
	uiEnd
	fend
	GLUpdate
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( thNext thNow 'vthsel ! )
	drop ;

:
	"RIMM ex3 GL" 960 640 rimmGLini
	$101010 GLpaper
	'main SDLshow
	GLend ;
