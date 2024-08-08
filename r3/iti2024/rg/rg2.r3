| Rythm game
| PHREDA 2024
|------------------
^r3/win/sdl2gfx.r3
^r3/win/sdl2mixer.r3
^r3/util/pcfont.r3
^r3/util/arr16.r3

|------ sound
#sndfiles 
"909CX BD1.mp3"
"909CX BD2.mp3"
"909CX BD3.mp3"
"909CX CHH.mp3"
"909CX CP1.mp3"
"909CX CS1.mp3"
"909CX CS2.mp3"
"909CX FTH.mp3"
"909CX FTL.mp3"
"909CX HTH.mp3"
"909CX HTL.mp3"
"909CX MTH.mp3"
"909CX MTL.mp3"
"909CX OHH.mp3"
"909CX PHH.mp3"
"909CX RD2.mp3"
"909CX RM1.mp3"
"909CX SN1.mp3"
"909CX SN2.mp3"
"909CX SN3.mp3"
0
#sndlist * 160

:loadsnd
	'sndlist >a
	'sndfiles
	( dup c@ 1? drop
		dup "media/snd/909/%s" sprint mix_loadWAV a!+
		>>0 ) drop ;

:playsnd | n --
	3 << 'sndlist + @ SNDplay ;

|------- graficos

#imgfondo

| 1 2  3   4   5   6   7 8  9  10 11    
| x y 

:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.s 4 ncell+ ;

#sprgame
#sprplayer

#cucas 0 0 
#fx 0 0

#jugador 0 0 0 0 0 0 0 0


:cuca
	dup 8 + >a 
	a@+ int. a@+ int.  | x y
	a@ timer+ dup a!+ 
	anim>N sprgame ssprite | x y ang zoom img --
	
	5.0 over .x +!
	dup .x @ 1024.0 >? ( 2drop 0 ; ) drop
	|dup .x @ 1000.0 >? ( drop .s @ playsnd 0 ; ) drop
	drop	
	;
	
:+cuca | x y --
	'cuca 'cucas p!+ >a
	swap a!+ a!+
	0 3 $7f ICS>anim a!+ 
	;
	
|------- game
#pulso 1.0 
#largo 500 | miliseconds

#thit
#dif

#tiempo

#estado
#ritmo

|------- timeline

#time1 $1 $2 $4 $5 $1 $8 $1 $7 $3 $2 $1 $4 $5 $f -1
|#time1 1 2 1 2 1 2 1 2 1 2 -1

#ltime
#ntime

:trestart
	-1 'ltime ! 
	0 'ntime !
	;
	
:showtime
	ntime ltime =? ( drop ; ) 
	dup 'ltime !
	3 << 'time1 + @
	-? ( drop 0 'ntime ! ; )
	1 and? ( 0.0 120.0 +cuca )
	2 and? ( 0.0 270.0 +cuca )
	4 and? ( 0.0 420.0 +cuca )
	8 and? ( 0.0 570.0 +cuca )
	drop
	;

	
:tclock
	tiempo timer+ 
	largo <? ( 'tiempo ! ; )
	largo - 'tiempo ! 
	tiempo 'thit ! 
	1 'ntime +! 
	;

:bt
	estado 0? ( drop ; ) drop
	$ff0000 
	tiempo 100 >? ( swap $ff or swap ) drop
	sdlcolor
	400 40 48 40 SDLFrect
	;
	
:rt
	tiempo 100 >? ( drop ; ) drop
	$ff sdlcolor
	0 0 20 20 SDLFrect
	;

:paso
	$ff00 sdlcolor
	tiempo 2 >> 50 + 40 20 20 SDLFrect
	;
	
|------------- jugadores
	
:golpe | time player --
	3 << 'jugador +
	dup @ 1? ( 3drop ; ) drop
	! ;
	
:player	| player --
	500 80 pick2 150 * + 
	pick2 3 << 'jugador + @ 
	1? ( drop 1 )
	sprplayer ssprite
	
	3 << 'jugador +
	dup @ 0? ( 2drop ; ) 
	timer- -? ( 0 nip ) swap !
	;
	
:game
	timer.
	$999999 SDLcls
	0 0 1024 600 imgfondo SDLImages
	|immgui 	
	$0 pccolor
	0 0 pcat
	ntime "ntime:%d" pcprint pccr
	ntime 3 << 'time1 + @ "actual:%h" pcprint

	tclock
	paso rt bt

	'cucas p.draw
	'fx p.draw
	
	0 player
	1 player
	2 player
	3 player
	
	showtime
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<a> =? ( 200 0 golpe )
	<s> =? ( 200 1 golpe )
	<d> =? ( 200 2 golpe )
	<f> =? ( 200 3 golpe )
	<a> =? ( 0 playsnd )
	<s> =? ( 7 playsnd )
	<d> =? ( 8 playsnd ) 
	<f> =? ( 10 playsnd ) 
	
	drop ;

:a	
	<a> =? ( 0 playsnd )
	<s> =? ( 7 playsnd )
	<d> =? ( 8 playsnd ) 
	<f> =? ( 10 playsnd ) 
	<g> =? ( 6 playsnd ) 
	<h> =? ( 1 playsnd ) 
	<j> =? ( 2 playsnd ) 
	<k> =? ( 3 playsnd ) 
	<l> =? ( 4 playsnd ) 
	<l> =? ( 5 playsnd ) 
	;
	
:main
	"Ritmo!!" 1024 600 SDLinit
	|sdlfull
	pcfont
	
	32 32 "r3/iti2024/rg/cuca1.png" ssload 'sprgame !
	128 142 "r3/iti2024/rg/chancla.png" ssload 'sprplayer !
	"r3/iti2024/rg/cocina.png" loadimg 'imgfondo !
	100 'cucas p.ini
	100 'fx p.ini
	
|	0.0 300.0 +cuca
|	0.0 400.0 +cuca
|	0.0 500.0 +cuca
	
	44100 $8010 1 1024 Mix_OpenAudio
	loadsnd
	
	timer<
	'game SDLshow
	SDLquit 
	;


: main ;