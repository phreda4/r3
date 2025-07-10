| calendar
| PHREDA 2025
|
^r3/lib/gui.r3
^r3/lib/jul.r3
^r3/lib/sdl2gfx.r3
^r3/util/ui.r3
^r3/util/datetime.r3
	
#font1

#mes	6
#dia	10
#anio	2025
#hora	8
#min	0
#sec	0

#modocal 0
#datejuln	| now
#datejul	
#datejuli
#datejulm
#datejule

:hoja! | anio mes dia ---
	'dia ! 'mes ! 'anio !
:jhoja!
	dia mes anio date2jul 'datejuln !
	1 mes anio date2jul 
	dup 'datejul !
	dup jul2day | lu-do
	1+ 7 mod | >> do-sa
	- dup 'datejuli !
	42 + dup 'datejule !
	( dup jul2date drop nip mes <>? drop 1- ) drop
	1+ 'datejulm !
	;
	

:clickd | 'jday -- 'jday
	dup jul2date 'anio ! 'mes ! 'dia !
	jhoja! ;
	
#nadia "Dom" "Lun" "Mar" "Mie" "Jue" "Vie" "Sab" 

:paneldia
	7 9 uiGridA 
	0 1 uiGat
	stDark
	'nadia 0 ( 7 <? swap
		dup uiLabelC
		>>0	swap 1+ ) 2drop
	datejuli ( datejul <?
		'clickd over jul2date 2drop .d uiCbtn
		1+ )
	stInfo
	( datejulm <?
		datejuln =? ( stLink )
		'clickd over jul2date 2drop .d uiCbtn
		datejuln =? ( stInfo )
		1+ ) 
	stDark
	( datejule <?
		'clickd over jul2date 2drop .d uiCbtn
		1+ ) drop ;

:clickm
	anio over 1+ dia hoja! 
	0 'modocal ! ;

:panelmes
	3 8 uiGridA 
	0 2 uiGat
	stDark
	0 ( 12 <?
		mes 1- =? ( stInfo )
		'clickm over >mesname uiRBtn
		mes 1- =? ( stDark )
		1+ ) drop ;
	
:clicka
	dup anio + mes dia hoja! 
	1 'modocal ! ;
	
:panelanio
	5 9 uiGridA 
	0 2 uiGat
	stDark
	0 ( 25 <?
		'clicka over anio + 
		anio =? ( stInfo )
		.d uiRBtn
		anio =? ( stDark )
		1+ ) drop ;

:sethoy
	date dup 16 >> swap dup 8 >> $ff and swap $ff and
	hoja! ;
	
#mcall 'paneldia 'panelmes 'panelanio

:uiDMY	
	4 4 uiPad
	0.1 %w 0.1 %h 0.25 %w 0.5 %h uiWin $222222 sdlcolor uiRFill10		
	1 9 UIGridA $444444 sdlcolor uiRFill	
	0 0 uigAt stDark
	" " uiTLabel
	datejuln 1+ 7 mod >dianame uiTLabel ", " uiTLabel
	[ 0 'modocal ! ; ] dia .d uiTBtn " " uiTLabel
	[ 1 'modocal ! ; ] mes 1- >mesname uiTBtn " " uiTLabel
	[ 2 'modocal ! ; ] anio .d uiTBtn
	modocal 3 << 'mcall + @ ex
	3 9 uiGridA uiH
	0 8 uiGat
	StInfo
	'sethoy "Hoy" uiRBtn
	ui>>
	StSucc
	'exit "Aceptar" uiRBtn
	;
	
|-----------------------------
:uiHMS
	4 4 uiPad
	0.4 %w 0.1 %h 0.1 %w 0.5 %h uiWin $222222 sdlcolor uiRFill10
	1 11 UIGridA $444444 sdlcolor uiRFill
	0 0 uigAt 
	mark
	hora ,2d ":" ,s
	min ,2d ":" ,s
	sec ,2d empty here uiLabelc

	3 11 UIGridA uiH
|	0 0 uigAt
|	"Hora" uiLabelc
|	"Min" uiLabelc
|	"Sec" uiLabelc
	0 1 uigAt uiV
	"0" uiLabelC
	0 ( 7 <? 
		dup .d uiLabelC
		1+ ) drop
	"23" uiLabelC
	
	1 1 uigAt uiV
	0 ( 7 <? 
		dup 10 + .d uiLabelC
		1+ ) drop
	2 1 uigAt uiV
	0 ( 7 <? 
		dup 10 + .d uiLabelC
		1+ ) drop ;
		
|-----------------------------
|-----------------------------
:main
	0 SDLcls
	font1 txfont
	uiStart
	
	uiDMY
	uiHMS
		
	uiEnd
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinit
	24 21 "media/img/icong16.png" ssload 'uicons !
	"media/ttf/Roboto-bold.ttf" 18 txload 'font1 !
	
	sethoy
	
	'main SDLshow
	SDLquit 
	;
