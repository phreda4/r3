| rcode
| PHREDA 2024
|-------------------------

^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/sdledit.r3


| scratchjr
| eventos/movimiento/apariencia/sonido/control/fin
|
| scratch
| movimiento/apariencia/sonido/eventos/control/sensor/operadores/variables/bloques


#instruction "+" "-" "*" "/" 

:minst
	$7f7f 'immcolorbtn !
	60 24 immbox		
	$7f0000 'immcolorbtn !
	'exit ":" immbtn imm>>
	$7f007f 'immcolorbtn !
	'exit "#" immbtn imm>>
	$7f00 'immcolorbtn !
	'exit "ABC" immbtn imm>> | adr+
	$7f7f00 'immcolorbtn !
	'exit "123" immbtn imm>>
	$7f7f7f 'immcolorbtn !
	'exit """s""" immbtn imm>>
	$b5593f 'immcolorbtn !
	'exit "oper" immbtn imm>> | MATH/LOG
	'exit "mem" immbtn imm>> | MEM
	'exit "stack" immbtn imm>> | STACK
	'exit "contr" immbtn imm>> | CONTROL
	$3f3f3f 'immcolorbtn !
	'exit "comm" immbtn imm>> | 
	;
	
	
#cdx 20 #cdy 100
#cdcnt 5
#cdtok * 1024
#
	
:mcode
	'cdtok >a
	0 ( cdcnt <?
		cdx over 24 * cdy + ttat
		$ffffff ttcolor
		dup 1+ "%d" ttprint
		cdx 30 + over 24 * cdy + ttat
		$ff00 ttcolor
		"0" ttprint " " ttprint "MOVE" ttprint
		1+ ) drop
	;
	
#skx 200 #sky 100
#skview 4
#skcnt 6
#sktok * 128	

:dcell
	;
	
:mstack
	skview ( 1? 
		1- ) drop ;
	
#cox 20 #coy 300
#copad "> " * 512
#copad> 'copad

:mconsole
|	$ffffff ttcolor
|	cox coy ttat
|	'copad tt.
	cox coy immat
	'copad 64 input
	;
	
:menu
	0 sdlcls 
	immgui
	
	$ff 'immcolorbtn !
	60 24 immbox
	4 4 immat
	"r3Code" immlabelc immdn
|	$ff0000 'immcolorbtn ! 'exit "Exit" immbtn 
	
	minst
	mcode
	mconsole
	
	SDLredraw 
	sdlkey
	>esc< =? ( exit )
	drop
	;

:modmenu
	'menu sdlShow ;

: |<<< BOOT <<<
	"r3code" 1024 600 SDLinit
	"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	
	modmenu
	SDLquit 
	;
