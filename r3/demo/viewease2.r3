^r3/lib/sdl2gfx.r3
^r3/util/varanim.r3
^r3/util/sdlgui.r3
^r3/util/textb.r3

#font

#nameease  "Lineal" "Quad_In" "Quad_Out" "Quad_InOut" "Cub_In" "Cub_Out" "Cub_InOut" "Quar_In" "Quar_Out" "Quar_InOut" "Quin_In" "Quin_Out" "Quin_InOut" "Sin_In" "Sin_Out" "Sin_InOut" "Exp_In" "Exp_Out" "Exp_InOut" "Cir_In" "Cir_Out" "Cir_InOut" "Ela_In" "Ela_Out" "Ela_InOut" "Bac_In" "Bac_Out" "Bac_InOut" "Bou_Out" "Bou_In" "Bou_InOut"
		
#vary * 300 
#texture * 300 

| colb(4) colo(4) pad(2) flag(2) colf(4)	
:inipanel
	'texture >b
	0 ( 31 <?
		dup "%d" sprint $f00fffff0025f000 32 24 font textbox b!+ 
		1+ ) drop ;

:panel
	'vary >a
	'texture >b
	0 ( 31 <?  
		dup 33 * 17 + a@+ 
		b@+ sprite
		1+ ) drop ;	
		
#titulo

:demo
	vupdate
	$0 SDLcls
	512 50 titulo sprite
	panel
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	drop ;	

:anima
	'vary >a
	0 ( 31 <?  
		a> 500 100 pick3 2.0 0.0 +vanim
		a> 100 500 pick3 2.0 2.0 +vanim
		8 a+
		1+ ) drop
	'anima 5.0 +vexe
		;
	
#tex #tex2 #tex3	
|--------------- INICIO ------------	
: 
	"View ease" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 20 TTF_OpenFont 'font ! 
	$ff vaini

	
	inipanel
	"View EASE number" $ffff0025f000 200 80 font textbox 'titulo !
	anima
			
	'demo SDLshow
	SDLquit
	;
