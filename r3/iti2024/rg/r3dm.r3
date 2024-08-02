| Rythm machine
| PHREDA 2024
|------------------
^r3/win/sdl2gfx.r3
^r3/win/sdl2mixer.r3
^r3/lib/gui.r3
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
		>>0 ) 2drop ;

:playsnd | n --
	3 << 'sndlist + @ SNDplay ;

|------- game
#pulso 1.0 
#largo 250 | miliseconds

#thit
#dif

#tiempo

#estado
#ritmo

|------- timeline

#time1 $1 $2 $4 $5 $1 $8 $1 $7 $3 $2 $1 $4 $5 $f -1

#ltime
#ntime

:trestart
	-1 'ltime ! 0 'ntime ! ;
	
:showtime
	ntime ltime =? ( drop ; ) 
	dup 'ltime !
	3 << 'time1 + @
	-? ( drop 0 'ntime ! ; )
|	1 and? ( 0.0 120.0 +cuca )
|	2 and? ( 0.0 270.0 +cuca )
|	4 and? ( 0.0 420.0 +cuca )
|	8 and? ( 0.0 570.0 +cuca )
	drop ;

	
:tclock
	tiempo timer+ 
	largo <? ( 'tiempo ! ; )
	largo - 'tiempo ! 
	tiempo 'thit ! 
	1 'ntime +! 
	;

	
:rt
	tiempo 100 >? ( drop ; ) drop
	$ff sdlcolor
	200 0 20 20 SDLFrect
	;

:paso
	$ff00 sdlcolor
	tiempo 2 >> 200 + 20 20 20 SDLFrect
	;
	
:channel
	pccr pccr
	'sndfiles
	( dup c@ 1? drop
		dup pcprint pccr
		>>0 ) 2drop ;
	
:game
	gui
	$0 SDLcls
	
	$ffffff pccolor
	0 0 pcat
	ntime " ntime:%d" pcprint 
	ntime 3 << 'time1 + @ " actual:%h" pcprint

	channel
	
	pccr pccr
	"[play]" pcprint
	
	timer.
	tclock
	paso rt 
	showtime
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:main
	"Rythm Machine" 1024 600 SDLinit
	44100 $8010 1 1024 Mix_OpenAudio | minimal buffer for low latency
	loadsnd
	pcfont
	
	timer<
	'game SDLshow
	SDLquit 
	;


: main ;