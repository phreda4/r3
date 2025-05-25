| appdemo
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/util/textb.r3

#tfont
#tcartel
#swsh

::%w SW 16 *>> ; 
::%h SH 16 *>> ; 

:gencar
	tfont 0.05 %h TTF_SetFontSize
|	tfont 1 TTF_SetFontStyle
	
	"Boton de prueba" 
	$4666f0000025ffff 
	0.3 %w 0.2 %h
	tfont textbox 
	'tcartel !
	;
	
:changesize?
	sh 32 << sw or 
	swsh =? ( drop ; ) 'swsh !
	gencar
	;
	
:demo
	changesize?
	0 SDLcls
	0.3 %w 0.3 %h tcartel sprite
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	drop ;

	
:main
	"r3app" 1024 600 SDLinitR
	"media/ttf/Roboto-Medium.ttf" 28 TTF_OpenFont 'tfont !
	'demo SDLshow
	SDLquit ;	
	
: main ;
