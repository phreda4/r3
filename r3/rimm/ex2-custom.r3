| RIMM example 2: the layers
|  - a button with your own content (progress ring) using uiBtnX
|  - a custom skin for the buttons, replacing the theme one (skin!)
|  - a custom widget in 6 lines: sense (uiZone) + skin + content + action
|  - the color picker (rimmcolor)
| run:  ./r3lin r3/rimm/ex2-custom.r3     F1 theme, F2 custom skin, ESC exit
^r3/rimm/rimm.r3
^r3/rimm/rimmcolor.r3

#font1
#cola $3A86FF
#colb $FF006E
#ticks 0
#myskin 0

|--- content: what the button shows (it gets the data on the stack)
:ctNum | n -- ; text made from a number
	"%d clicks" sprint ttwritec ;

|--- skin of the buttons: stripes (replaces the one of the theme)
:skstripes
	colFill bx by bw bh frect
	colLight
	0 ( bw <? dup bx + by by bh + 1- lineV 6 + ) drop ;

:toggleskin
	myskin 1 xor dup 'myskin !
	1? ( 'skstripes skinBtn skin! ) 
	0? ( thNow uiTheme ) drop ;

|--- a widget with 6 lines: a "led" toggle
:uiLed | 'var "text" --
	uiZone
	[ over dup @ 1 xor swap ! uiEx! ; ] uiClk
	over @ skinRadio sk
	colText cx rh + 2 + cy rh txh - 2/ + txat txwrite
	drop ui.. ;

#led1 1 #led2 0
#vtree 0 0
#treeex "@Proyecto" "ASrc" "Bmain.r3" "Brimm.r3" "AMedia" "BVoxels" "BSonidos" "@Docs" "AREADME" "@Notas" 0

:click1 1 'ticks +! ;

:main
	$151515 cls
	uiStart
	10 10 340 sh 20 - uiBox
	uiPanelBg
	"Capas: sensado - skin - contenido - accion" uiLabelC
	ui--
	2 uiCols
	'click1 "Texto" uiBtn
	'click1 ICPLUS uiIBtn
	'click1 ticks 'ctNum uiBtnX
	'click1 "Otro" uiBtn
	1 uiCols
	ui--
	'led1 "Led uno" uiLed
	'led2 "Led dos" uiLed
	ui--
	0.4 uiProps
	"Color A" uiLabel 'cola uiColorH
	"Color B" uiLabel 'colb uiColor
	1 uiCols
	ui--
	'vtree 7 'treeex uiTree
	uiEnd
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( thNext )
	<f2> =? ( toggleskin )
	drop ;

:
	"RIMM ex2" 800 600 SDLinitR
	"media/ttf/Roboto-Medium.ttf" 18 txload 'font1 !
	font1 txfont
	'main SDLshow
	SDLquit ;
