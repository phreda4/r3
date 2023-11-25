^r3/lib/rand.r3
^r3/lib/color.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2mixer.r3
^r3/util/bfont.r3
^r3/util/arr16.r3
^r3/util/varanim.r3
^r3/util/boxtext.r3
^r3/util/sdlgui.r3

#font
#sprmesa
#sprmafalda
#sprpatoru
#sprmatias
#sprhijitus
#sprfx

#listfx 0 0 | fx

|-------- sprite list
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.r 3 ncell+ ; 
:.a 4 ncell+ ; 
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;

:objsprite | adr -- adr
	dup 8 + >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and | rota zoom				
	a@ timer+ dup a!+ 	| anima
	nanim a@+ sspriter
	dup .vx @ over .x +!	| vx
	dup .vy @ over .y +!	| vy
	;

|--------------- fx	
:ofx
	objsprite
	dup .x @ -400.0 <? ( 1400.0 pick2 .x ! ) drop
	dup .y @ 350.0 - abs 150.0 >? ( over .vy dup @ neg swap ! ) drop | 200..500
	drop
	;

:+fx	| vx vy n x y --
	'ofx 'listfx p!+ >a 
	swap a!+ a!+	| x y 
	1.0 a!+ 		| rota|zoom
	52 << a!+ sprfx a!+ | n spritesheet
	swap a!+ a!+ ;  | vx vy

:fillscr
	40 ( 1? 1 -
		0.5 randmax 0.7 -
		0.1 randmax 0.05 -
		25 randmax 
		1800.0 randmax 400.0 -
		300.0 randmax 200.0 + | 200..500
		+fx
		) drop ;
	
		
|-------------- Juego
#colores $ff $ff00 $ff0000 $ff00ff
#tiempoclick
#colorclick
#puntos 
	
:newcolor
	4 randmax 'colorclick !
	3000 'tiempoclick !
	;

:clickc | color
	colorclick <>? ( drop ; ) drop
	newcolor
	1 'puntos +!
	;
	
:jueces	
	200 230
	msec 9 >> $3 and
	sprmafalda ssprite
	
	400 200
	msec 9 >> 3 mod
	sprpatoru ssprite
	
	570 230
	msec 9 >> $3 and
	sprmatias ssprite
	
	740 230
	msec 9 >> 3 mod
	sprhijitus ssprite
	;
	
:juego
	vupdate timer.
	deltatime neg 'tiempoclick +!
	$78ADE8 SDLcls
	
	jueces
	0 180 sprmesa SDLImage
	
	immgui	

	100 90 immbox
	150 300 immat [ 0 clickc ; ] immzone 
	$ff SDLColor plxywh SDLFRect 
	330 300 immat [ 1 clickc ; ] immzone 
	$ff00 SDLColor plxywh SDLFRect 
	510 300 immat [ 2 clickc ; ] immzone 
	$ff0000 SDLColor plxywh SDLFRect 
	690 300 immat [ 3 clickc ; ] immzone 
	$ff00ff SDLColor plxywh SDLFRect 
	
	'colores colorclick ncell+ @ SDLColor
	412 20 200 100 SDLFRect
	
	200 50 immbox
	412 120 immat
	puntos "%d" sprint immlabelC
	412 160 immat
	tiempoclick "%d" sprint immlabelC
	
	'listfx p.draw
	SDLredraw
	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( newcolor )
	drop ;

:reset
	'listfx p.clear
	0 'puntos !
	newcolor
	;

:jugar 
	reset
	'juego SDLShow ;

|-------------------------------------
|-------------------------------------
:main
	"velocicracia" 1024 600 SDLinit

	"r3/gamejamd/velocicracia/mesa.png" loadimg 'sprmesa !
	196 170 "r3/gamejamd/velocicracia/mafalda.png" ssload 'sprmafalda !
	179 375 "r3/gamejamd/velocicracia/Patoruzito.png" ssload 'sprpatoru !
	163 199 "r3/gamejamd/velocicracia/matias.png" ssload 'sprmatias !
	150 249 "r3/gamejamd/velocicracia/Hijitus.png" ssload 'sprhijitus !

	"media/ttf/roboto-medium.ttf" 48 TTF_OpenFont 'font ! 
	font immSDL 
	timer<
	$7f vaini
	100 'listfx p.ini

	jugar
	SDLquit ;	
	
: main ;
