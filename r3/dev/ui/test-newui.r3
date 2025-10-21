| test gui3
| PHREDA 2025
|
^r3/util/immi.r3

#font1

#ali

#pad * 1024
#pad2 * 1024
		
#tablist "A" "B" "C" "D" 0

#listex "uno" "dos" "tres" "cuatro" "cinco" 0

#treeex
"@uno" "Aaaa" "Abbb" "Blksdhfl" "Blksdhfl" "Axnb"
"@dos" 
"@tres"
"@listado" "Auno" "Ados"
0

#vsl
#vsl2
#vlist 0 0
#vtree 0 0

|-----------------------------
:test
	uiStart
	4 4 uiPading
	$ffffff sdlcolor
	0.1 %h uiN
	"Widget Test " ali uiText
	0.1 %h uiS
	"[esc]-Exit [f1/f2]-align" $11 uiText
	
	0.6 %w uiO
	$111111 sdlcolor uiFill
	uiPush
	0.05 %h uiN
	"wid" $11 uiText
	uiRest
	0.15 %w uiO
	'vlist 'listex uiList | 8
	0.15 %w uiO
	uiPush
	0.5 %h uiN
	2 2 uiPading
	1 12 uiGrid
	'exit "Boton" uiBtn uiNext
	'exit "Boton" uiRBtn uiNext
	'exit "Boton" uiCBtn uiNext
	'exit "Boton" uiBtn uiNext
	'exit "Boton" uiRBtn uiNext
	'exit "Boton" uiCBtn uiNext
	"----" uiLabelc uiNext
	-1.0 1.0 'vsl uiSliderf uiNext
	0 500 'vsl2 uiSlideri uiNext
	"----" uiLabelc uiNext
	uiPop
	0.15 %w uiO
	'vtree 'treeex uiTree
	
	uiRest
	
	uiPop
	uiRest
	0.1 %h uiN $444444 sdlcolor uiFill
	1 2 uiGrid
	'pad 64 uiInputLine
	'pad2 64 uiInputLine
	uiRest
	"Hola" $11 uiText
	
	uiEnd
	;
	
	
|-----------------------------
:main
	0 SDLcls
	font1 txfont
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
	
	'main SDLshow
	SDLquit 
	;
