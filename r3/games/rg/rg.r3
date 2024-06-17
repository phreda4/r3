^r3/win/sdl2gfx.r3
^r3/win/sdl2mixer.r3
^r3/util/sdlgui.r3

|------ sound
#sndfiles 
"909CXBD2.mp3" "909CXBD3.mp3" "909CXCHH.mp3" "909CXCP1.mp3" "909CXCS1.mp3" "909CXCS2.mp3" 
"909CXFTH.mp3" "909CXFTL.mp3" "909CXHTH.mp3" "909CXHTL.mp3" "909CXMTH.mp3" "909CXMTL.mp3" 
"909CXOHH.mp3" "909CXPHH.mp3" "909CXRD2.mp3" "909CXRM1.mp3" "909CXSN1.mp3" "909CXSN2.mp3" 
"909CXSN3.mp3" 0

#sndlist * 128

:loadsnd
	'sndlist >a
	'sndfiles
	( dup c@ 1? drop
		dup "r3/games/rg/samples/%s" sprint mix_loadWAV a!+
		>>0 ) drop ;

:playsnd | n --
	3 << 'sndlist + @ SNDplay ;

|------- game
#pulso 1.0 
#largo 1000 | miliseconds

#thit
#dif

#tiempo

#estado
#ritmo

:bt
	estado 0? ( drop ; ) drop
	$ff0000 
	tiempo 100 >? ( swap $ff or swap ) drop
	sdlcolor
	400 280 48 40 SDLFrect
	;
	
:rt
	tiempo 100 >? ( drop ; ) drop
	$ff sdlcolor
	600 280 48 40 SDLFrect
	;
	
	

:paso
	timer.
	tiempo timer+ 
	largo >? ( largo - 
		15 playsnd 
		tiempo 'thit ! )
	'tiempo !

	$ff00 sdlcolor
	50 tiempo 1 >> 50 + 20 20 SDLFrect

	;
	
:game
	0 SDLcls
	immgui 	
	
	200 28 immbox
	500 16 immat
	dif "d:%d" immlabelc immdn
	
	paso
	rt
	bt
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<a> =? ( 0 playsnd tiempo thit - 'dif ! 1 'estado ! ) >a< =? ( 0 'estado ! )
	<s> =? ( 7 playsnd )
	<d> =? ( 8 playsnd ) 
	<f> =? ( 10 playsnd ) 
	<g> =? ( 6 playsnd ) 
	<h> =? ( 1 playsnd ) 
	<j> =? ( 2 playsnd ) 
	<k> =? ( 3 playsnd ) 
	<l> =? ( 4 playsnd ) 
	<l> =? ( 5 playsnd ) 
	
	
	drop ;
	
	
:main
	"Ritmo!!" 1024 600 SDLinit
	"media/ttf/ProggyClean.TTF" 24 TTF_OpenFont immSDL
	44100 $8010 1 1024 Mix_OpenAudio
	loadsnd
	timer<
	'game SDLshow
	SDLquit 
	;


: main ;