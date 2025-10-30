| test gui3
| PHREDA 2025
|
^r3/util/immi.r3
^r3/util/imedit.r3
^r3/util/imcolor.r3
^r3/util/immdatetime.r3

#font1
#font2

#ali

#pad * 1024
#pad2 * 1024
		
#tablist "A" "B" "C" "D" 0

#listex "uno" "dos" "tres" "cuatro" "cinco" "seis" "siete" "Ocho" 0

#treeex
"@uno" "Aaaa" "Abbb" "Blksdhfl" "Blksdhfl" "Axnb"
"@dos" 
"@tres"
"@listado" "Auno" "Ados"
0

#listch "Opcion 1" "Opcion 2" "Opcion 3" 0

#vsl
#vsl2
#vlist 0 0
#vtree 0 0
#vchk
#vrad
#vcolor $ff00
#vdate
#vtime

|-----------------------------
:test
	font1 txfont
	uiStart
	4 4 uiPading
	$ffffff sdlcolor
	
	0.1 %h uiN
	"Widget Test " ali uiText
	
	0.1 %h uiS
	"[esc]-Exit [f1/f2]-align" $11 uiText
	
	0.5 %w uiO
	$111111 sdlcolor uiFill
	
	uiPush
	0.05 %h uiN
	"wid" $11 uiText
	
	uiRest
	0.11 %w uiO
stLink 	
	'vlist 6 'listex uiList | 8
	ui--
	'vchk 'listch uiCheck
	'vdate uiDate
|	'vtime1 uiTime
	'vcolor uiColor | H
|	'vfilen uiFileName	
	
	0.11 %w uiO
	uiPush
	
	0.5 %h uiN
	stDang 'exit "Boton" uiBtn 
	stWarn 'exit "Boton" uiRBtn 
	stSucc 'exit "Boton" uiCBtn 
	stInfo 'exit "Boton" uiBtn 
	stLink 'exit "Boton" uiRBtn 
	stDark 'exit "Boton" uiCBtn 
	stLink 
	ui--
	-1.0 1.0 'vsl uiSliderf 
	0 500 'vsl2 uiSlideri 
	-1.0 1.0 'vsl uiProgressf 
	0 500 'vsl2 uiProgressi 

	ui--
	uiPop
	
	0.12 %w uiO
	'vtree 6 'treeex uiTree
	ui--	
	'vrad 'listch uiRadio | 'var 'list --	
	
	uiRest
	'vlist 'listex uiCombo
	ui--
	'pad 64 uiInputLine
	ui--
	'pad2 64 uiInputLine
	ui--
	
	uiPop

	uiRest
	font2 txfont
	edfocus
	edcodedraw
|	"Hola" $11 uiText
	
	uiEnd
	;
	
	
|-----------------------------
:main
	0 SDLcls
	test
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( ali $1 + $33 and 'ali ! )
	<f2> =? ( ali $10 + $33 and 'ali ! )
	|<tab> =? ( keymd 1 and? ( uiFocus<< ) 1 nand? ( uiFocus>> ) drop )	
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinitR
	
	"media/ttf/Roboto-bold.ttf" 20 txloadwicon 'font1 !
	"media/ttf/RobotoMono-Bold.ttf" 16 txload 'font2 !
 	
	edram 
	0.5 %w 32 550 550 edwin | <<<****
	
	"r3/opengl/voxels/3-vox.r3" edload	
	
	'main SDLshow
	SDLquit 
	;
