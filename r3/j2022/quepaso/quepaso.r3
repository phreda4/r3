| Juego de preguntas
| Itinerario de informatica
| PHREDA 2022
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/win/sdl2mixer.r3

^r3/util/boxtext.r3
^r3/util/tilesheet.r3
^r3/lib/rand.r3
^r3/lib/gui.r3

#simagenes
#stablero
#scursor
#sfin
#spodio
#sinicio

#sf1 #sf2 #sf3
#tu1 #tu2 #tu3

#sbtn1 #sbtn2
#sbtnj1 #sbtnj2
#sbtns1 #sbtns2

#musicini
#musicrun

|----------------------------------------	
#sndfile "correcta.mp3" "incorrecta.mp3" "boton.mp3" 0

#sndlist * 1024

:loadsndfile
	"r3/j2022/quepaso/audio/musinicio.mp3" Mix_LoadMUS 'musicini !
	"r3/j2022/quepaso/audio/musjuego.mp3" Mix_LoadMUS 'musicrun !

	'sndlist >a
	'sndfile ( dup c@ 1? drop
		dup "r3/j2022/quepaso/audio/%s" sprint
		Mix_LoadWAV a!+
		>>0 ) 2drop ;

:playsnd | n --
	3 << 'sndlist + @ SNDplay ;
	
|----------------------------------------	
	
#fontt
#font
#preguntas

#tiempo
#nropreg 0
#cntpreg
#pregunta * 1024

#res1 * 1024
#res2 * 1024
#res3 * 1024
#res4 * 1024

#r1 #r2 #r3 #r4

#cntjug 3
#njug 0 0 0 0
#pjug 0 0 0 0

#jnow
#resusr
#maxjug
#nrojug

#posiciones [ 
610 850
570 650
620 500
640 350
600 200
470 200
300 350
300 550
430 700
490 890 ]

#xresm 800 #yresm 1047

:nposjug | n -- x y
	10 mod 
	3 << 'posiciones +
	d@+ 400 xresm */ 500 + 40 -
	swap 
	d@ 523 yresm */ 180 + 120 - ;
	
:mapascreen
	'pjug >a
	'sf1 >b
	0 ( cntjug <? 
		da@+ da@+ 
		pick2 3 << 'sf1 + @ sdlimage
		1 + ) drop ;
	
:resetjug | n --
	dup 'cntjug !
	'pjug >b
	( 1? 1 - 
		0 nposjug
		swap 32 randmax 16 - +
		swap 32 randmax 16 - +
		swap db!+ db!+
		) drop ;

:avjug | n --
	3 <<
	1 over 'njug + +!
	dup 'pjug + >a
	'njug + @
	dup maxjug max 'maxjug !
	nposjug		
	swap 32 randmax 16 - +
	swap 32 randmax 16 - +
	swap da!+ da!+
	;
	

|-------------------------------------------
#mseca

:inireloj
	0 'tiempo ! msec 'mseca ! ;
	
:reloj
	msec dup mseca - 'tiempo +! 'mseca ! ;
	
:showreloj
	$11
	tiempo 1000 / "%d" sprint
	36 36 66 60 xywh64 $ffffff fontt textbox 	
	;

:btni | 'vecor 'i x y -- 
	pick2 @ SDLimagewh guibox
	SDLb SDLx SDLy guiIn	
	[ 8 + ; ] guiI 
	@ xr1 yr1 rot SDLImage
	onCLick ;

|-------------------------------------------
:rswap |
	3 randmax 3 << 'r1 +
	3 randmax 3 << 'r1 +
	dup @ pick2 @ rot ! swap ! ;
	
:mixres
	'res1 'r1 ! 'res2 'r2 ! 'res3 'r3 ! 'res4 'r4 !
	21 ( 1? rswap 1 - ) drop ;
	
:cpypreg |
	preguntas
	|nropreg 
	cntpreg randmax
	dup 2 << + | * 5
	( 1? 1 - swap >>cr trim swap ) drop
	dup 'pregunta strcpyln
	>>cr trim dup 'res1 strcpyln
	>>cr trim dup 'res2 strcpyln
	>>cr trim dup 'res3 strcpyln
	>>cr trim dup 'res4 strcpyln
	drop 
	mixres 
	3 playsnd
	;

#col0 "VERDE" #col1 "NARANJA" #col2 "CELESTE"
#lcol col0 col1 col2
#ccol $42A30A $F68E1F $13BFC1
#t0 "TURNO VERDE" #t1 "TURNO NARANJA" #t2 "TURNO CELESTE"
#lturno t0 t1 t2

:cambioturno
	gui
	$0 SDLcls
	0 0 stablero sdlimage
	
	mapascreen

	$11 
	jnow 3 << 'lturno + @
	370 22 870 136 xywh64 
	jnow 3 << 'ccol + @ 8 <<
	fontt textbox | $vh str box color font	

	970 550 jnow 3 << 'tu1 + @ sdlimage

	[ exit 100 'maxjug ! ; ] 'sbtns1 230 15 btni
	
	sdlx sdly scursor SDLimage
	
	reloj
	tiempo 3000 >? ( exit ) drop
	SDLredraw
	
	|exit |*********

	SDLkey 
	>esc< =? ( 4 'resusr ! exit ) | terminar siempre
	drop 
	;
	
|-------------------------------------------


| 483,143
:btnn | 'vec "text" x y -- 
	2dup 280 65 guibox 
	sdlb sdlx sdly guiIn
	'sbtn1 [ 8 + rot 4 + rot 4 + rot ; ] guiI
	@ pick2 pick2 rot SDLimage
	swap 5 + swap 280 74 xywh64
	$11 rot rot $0 font textbox 
	onCLick ;
	
:jugando
	gui
	$0 SDLcls
	0 0 stablero sdlimage
	
	mapascreen
	'pjug jnow 3 << + >a
	da@+ da@+ jnow 3 << 'sf1 + @ sdlimage

	$11 'pregunta 370 22 870 136 xywh64 $00 fontt textbox | $vh str box color font	
	
	970 550 jnow 3 << 'tu1 + @ sdlimage

	[ 0 'resusr ! exit ; ] r1 25 305 btnn
	[ 1 'resusr ! exit ; ] r2 25 400 btnn
	[ 2 'resusr ! exit ; ] r3 25 495 btnn
	[ 3 'resusr ! exit ; ] r4 25 590 btnn

	[ exit 100 'maxjug ! ; ] 'sbtns1 230 15 btni
	
	reloj
	showreloj
	tiempo 10000 >=? ( 4 'resusr ! exit ) drop | 10 seg para responder
	
	sdlx sdly scursor SDLimage
	SDLredraw

	SDLkey 
	>esc< =? ( 4 'resusr ! exit ) | terminar siempre
	drop 
	;

|---------------------------------

| 109X139
:ganador
	gui
	$0 SDLcls
	0 0 spodio sdlimage
	
	170 300 
	msec 4 >> $3f and +
	218 288 nrojug 3 << 'sf1 + @ sdlimages

	$11
	nrojug 3 << 'lcol + @
	400 490 500 140 xywh64
	nrojug 3 << 'ccol + @ 8 <<
	fontt textbox 

	900 300 
	msec 4 >> $3f and +
	218 288 nrojug 3 << 'sf1 + @ sdlimages

	[ 2 playsnd exit ; ] 'sbtns1 1024 78 btni
	
	sdlx sdly scursor SDLimage

	SDLredraw

	SDLkey 
	>esc< =? ( exit ) | terminar siempre
	drop 
	;
	
|----------------------------------
:respuestaOK
	jnow avjug
	0 playsnd 
	;

:respuestaNO
	1 playsnd
	;
	
:respuesta	
	maxjug 99 >? ( drop ; ) drop | salio
	resusr 3 << 'r1 + @ 'res1 =? ( drop respuestaOK ; ) drop
	respuestaNO
	;
	
:jugar
	cntjug resetjug
	0 'jnow !
	0 'maxjug !
	musicrun -1 Mix_PlayMusic
	( maxjug 10 <? drop
		1 'nropreg +! 

		inireloj
		'cambioturno SDLshow
	
		cpypreg
		inireloj
		'jugando SDLshow

		respuesta	
		jnow 'nrojug !
		jnow 1 + cntjug mod 'jnow ! 
		) drop 
		
	maxjug 100 <? ( 'ganador SDLshow ) drop
	musicini -1 Mix_PlayMusic
	;

|------------------------------------
:menuprincipal
	gui
	0 0 sinicio sdlimage
	
	[ 2 playsnd exit ; ] 'sbtns1 1024 78 btni
	[ 2 playsnd jugar ; ] 'sbtnj1 490 530 btni
	
	sdlx sdly scursor SDLimage
	
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:inicio
	ttf_init
	"r3/j2022/quepaso/font/RobotoCondensed-Bold.ttf" 40 TTF_OpenFont 'fontt !	
	"r3/j2022/quepaso/font/RobotoCondensed-Regular.ttf" 24 TTF_OpenFont 'font !	
	
	"r3/j2022/quepaso/img/cursor.png" loadimg 'scursor !	
	"r3/j2022/quepaso/img/tablero.png" loadimg 'stablero !
	"r3/j2022/quepaso/img/fin.png" loadimg 'sfin !
	"r3/j2022/quepaso/img/podio.png" loadimg 'spodio !
	"r3/j2022/quepaso/img/inicio.png" loadimg 'sinicio !
	
	"r3/j2022/quepaso/img/ficha1.png" loadimg 'sf1 !
	"r3/j2022/quepaso/img/ficha2.png" loadimg 'sf2 !
	"r3/j2022/quepaso/img/ficha3.png" loadimg 'sf3 !
	
	"r3/j2022/quepaso/img/turno1.png" loadimg 'tu1 !
	"r3/j2022/quepaso/img/turno2.png" loadimg 'tu2 !
	"r3/j2022/quepaso/img/turno3.png" loadimg 'tu3 !

	"r3/j2022/quepaso/img/btn1.png" loadimg 'sbtn1 !
	"r3/j2022/quepaso/img/btn2.png" loadimg 'sbtn2 !

	"r3/j2022/quepaso/img/btnj1.png" loadimg 'sbtnj1 !
	"r3/j2022/quepaso/img/btnj2.png" loadimg 'sbtnj2 !

	"r3/j2022/quepaso/img/btns1.png" loadimg 'sbtns1 !
	"r3/j2022/quepaso/img/btns2.png" loadimg 'sbtns2 !
	
	SNDInit
	loadsndfile
	
	here dup 'preguntas !
	"r3/j2022/quepaso/preguntas.txt" load 
	0 swap !+ 'here !

	0 'cntpreg +!
	preguntas
	( dup c@ 1? drop
		>>cr trim >>cr trim >>cr trim >>cr trim >>cr trim
		1 'cntpreg +!
		) 2drop

	0 'nropreg !
	;
	
:main
	"r3sdl" 1280 720 SDLinit
	|SDLfull
	inicio
	0 SDL_ShowCursor

	musicini -1 Mix_PlayMusic
	'menuprincipal SDLshow 

	SDLquit ;	
	
: main ;


