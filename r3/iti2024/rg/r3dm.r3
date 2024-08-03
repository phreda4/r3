| Rythm machine
| PHREDA 2024
|------------------
^r3/win/sdl2gfx.r3
^r3/win/sdl2mixer.r3
^r3/util/sdlgui.r3
^r3/util/arr16.r3

|------ sound
#sndfiles 
"909CX BD1"
"909CX BD2"
"909CX BD3"
"909CX CHH"
"909CX CP1"
"909CX CS1"
"909CX CS2"
"909CX FTH"
"909CX FTL"
"909CX HTH"
"909CX HTL"
"909CX MTH"
"909CX MTL"
"909CX OHH"
"909CX PHH"
"909CX RD2"
"909CX RM1"
"909CX SN1"
"909CX SN2"
"909CX SN3"
0
#sndlist * 160
#cntlist

:loadsnd
	'sndlist >a
	'sndfiles
	( dup c@ 1? drop
		dup "media/snd/909/%s.mp3" sprint mix_loadWAV a!+
		>>0 ) 2drop 
	a> 'sndlist - 3 >> 'cntlist !
	;

:playsnd | n --
	3 << 'sndlist + @ SNDplay ;

#largo 250 | milliseconds

#tiempo
#ltime
#ntime

#tgrid * 1024
#lgrid 16

|---- clock
:trestart
	-1 'ltime ! 0 'ntime ! ;
	
:playgrid
	ntime ltime =? ( drop ; ) 
	lgrid >=? ( 0 dup 'ntime ! nip )
	dup cntlist * 'tgrid + >a
	0 ( cntlist <? 
		ca@+ 1? ( over playsnd )
		drop 1 + ) drop
	'ltime !
	;
	
:tclock
	tiempo timer+ 
	largo <? ( 'tiempo ! ; )
	largo - 'tiempo ! 
	1 'ntime +! 
	;
	
:paso
	$ff00 sdlcolor
	tiempo 2 >> 200 + 20 20 20 SDLFrect
	tiempo 100 >? ( drop ; ) drop
	$ff sdlcolor
	200 0 20 20 SDLFrect	
	;

|------- timeline
:channel
	120 14 immbox 16 64 immat
	'sndfiles
	0 ( cntlist <? 
		[ dup playsnd ; ] pick2 immbtn immdn
		swap >>0 swap 1 + ) 2drop ;

:colorcell | cell -- 
	0? ( drop sdlrect ; ) drop
	sdlfrect ;
	
:drawgrid
	$666666 sdlcolor
	'tgrid >a
	0 ( lgrid <?
		0 ( cntlist <? 
			over 4 << 140 + over 4 << 64 + 15 15 
			ca@+ colorcell
			1 + ) drop 
		1 + ) drop ;
	
:mapxy
	SDLy 64 - 4 >>
	SDLx 140 - 4 >>	
	cntlist * + 'tgrid + ;
	
:clickcell
	mapxy dup c@ 1 xor swap c! ;
	
:game
	timer.
	immgui 	
	$0 SDLcls
	
	180 20 immbox
	0 0 immat
	"Rythm Machine" immlabelc immdn
	740 64 immat
	largo " speed %d (ms)" sprint immLabel immdn	
	10 1000 'largo  immSlideri immdn
	
	channel
	drawgrid
	140 64 lgrid 4 << cntlist 4 << guiBox
	'clickcell onClick

	$ff00 sdlcolor
	140 ntime 4 << + 64 cntlist 4 << + 15 15 sdlfrect
	
	tclock
	|paso 
	playgrid
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:main
	"Rythm Machine" 1024 600 SDLinit
	44100 $8010 1 1024 Mix_OpenAudio | minimal buffer for low latency
	loadsnd
	"media/ttf/Roboto-Medium.ttf" 16 TTF_OpenFont immSDL
	1 1 immpad!
	timer<
	'game SDLshow
	SDLquit 
	;


: main ;