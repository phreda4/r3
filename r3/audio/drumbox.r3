| Rythm machine
| PHREDA 2024
|------------------
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^r3/util/varanim.r3
^r3/util/immi.r3
^r3/util/arr16.r3

#font1

|------ sound
#sndfiles 
"BD1"
"BD2"
"BD3"
"CHH"
"CP1"
"CS1"
"CS2"
"FTH"
"FTL"
"HTH"
"HTL"
"MTH"
"MTL"
"OHH"
"PHH"
"RD2"
"RM1"
"SN1"
"SN2"
"SN3"
0
#sndlist * 160
#cntlist

:loadsnd
	'sndlist >a
	'sndfiles
	( dup c@ 1? drop
		dup "media/snd/909/909CX %s.mp3" sprint mix_loadWAV a!+
		>>0 ) 2drop 
	a> 'sndlist - 3 >> 'cntlist !
	;

:playsnd | n --
	-1 swap 3 << 'sndlist + @ 0 -1 Mix_PlayChannelTimed drop ;

#largo 250 | milliseconds

#tiempo
#ltime
#ntime

#tgrid * 1024
#lgrid 16
#boxsize 23

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
	$ff00 color
	tiempo 2 >> 240 + 20 20 20 frect
	tiempo 100 >? ( drop ; ) drop
	$ff color
	200 0 20 20 frect	
	;

|------- timeline
:channel
	'sndfiles
	0 ( cntlist <? 
		[ dup playsnd ; ] pick2 uiBtn
		swap >>0 swap 1 + ) 2drop ;

:colorcell | cell -- 
	0? ( drop rect ; ) drop
	frect ;
	
:drawgrid
	$666666 color
	'tgrid >a
	0 ( lgrid <?
		0 ( cntlist <? 
			over boxsize * cx + over boxsize * cy + boxsize dup
			ca@+ colorcell
			1 + ) drop 
		1 + ) drop ;
	
:mapxy
	SDLy cy - boxsize /
	SDLx cx - boxsize /
	cntlist * + 'tgrid + ;
	
:clickcell
	mapxy dup c@ 1 xor swap c! ;
	
:game
	timer.
	$0 cls
	
	uiStart 
	2 1 uiPading
	
	font1 txfont
	0.05 %h uiN
	"Drum Box" uiLabelC
	
	0.2 %w uiO | ------------
	largo " speed %d (ms)" sprint uiLabelC
	10 1000 'largo uiSlideri
	60000 largo / " %d BPM" sprint uiLabelC
	
	0.1 %w uiO | ------------
	channel
	
	uiRest	| ------------
	drawgrid
	cx cy lgrid boxsize * cntlist boxsize * uiZoneBox
	'clickcell uiClk
	uiBackBox

	$ff00 color
	cx ntime boxsize * + cy cntlist boxsize * + boxsize dup frect
	
	tclock
	
	playgrid

	uiEnd
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
	

:	
	"Drum Box" 1024 600 SDLinitR
	"media/ttf/RobotoMono-Bold.ttf" 16 txload 'font1 !
	
	loadsnd
	timer<
	'game SDLshow
	SDLquit 
	;
