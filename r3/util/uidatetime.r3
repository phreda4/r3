| UI dstetime
| PHREDA 2025

^r3/lib/jul.r3

^r3/util/ui.r3
^r3/util/datetime.r3
^r3/util/txfont.r3

#mes	6
#dia	10
#anio	2025

#modocal 0
#datejuln	| now
#datejul	
#datejuli
#datejulm
#datejule

#anio1
#anio2

#datevar

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
	anio 7 - 'anio2 !
	anio 10 / 10 * 50 - 'anio1 !
	;

:exitdlg
	anio $ffff and 48 <<
	mes $f and 44 << or
	dia $ff and 32 << or
	|datevar @ $ffffffff nand or 
	datevar !
	refreshfoco
	;
	
:clickd | 'jday -- 'jday
	dup jul2date 'anio ! 'mes ! 'dia !
	jhoja! ;

:clickdn | 'jday -- 'jday
	dup jul2date 'anio ! 'mes ! 'dia !
	jhoja! exitdlg ;
	
#nadia "Dom" "Lun" "Mar" "Mie" "Jue" "Vie" "Sab" 

:paneldia
	7 9 uiGridA 
	0 1 uiGat
	stDark
	'nadia 0 ( 7 <? swap
		dup uiLabelC
		4 + swap 1+ ) 2drop
	datejuli ( datejul <?
		'clickd over jul2date 2drop .d uiCbtn
		1+ )
	stInfo
	( datejulm <?
		datejuln =? ( stLink )
		'clickdn over jul2date 2drop .d uiCbtn
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
	
:clickan
	dup mes dia hoja! 1 'modocal ! ;

:clicka
	dup mes dia hoja! ;
	
:panelanio
	5 9 uiGridA 
	0 2 uiGat
	stDark
	0 ( 5 <?
		dup 10 * anio1 + 'clicka over .d uiRBtn drop
		1+ ) drop
	stInfo	
	0 ( 15 <?
		dup anio2 + 
		anio =? ( stLink )
		'clickan over .d uiRBtn
		anio =? ( stInfo )
		drop
		1+ ) drop 
	stDark		
	0 ( 5 <?
		dup 10 * anio1 60 + + 'clicka over .d uiRBtn drop
		1+ ) drop ;

|----
:setnowdmy
	date dup 16 >> swap dup 8 >> $ff and swap $ff and
	hoja! ;
	
:set64dmy | dtvar --
	dup 48 >> $ffff and
	over 44 >> $f and
	rot 32 >> $ff and 
	hoja! ;
	
#mcall 'paneldia 'panelmes 'panelanio

:uiDMY	
	4 4 uiPad
	|0.1 %w 0.1 %h 
	uiZone@ 2drop 0.25 %h - swap 0.125 %w - swap
	0.25 %w 0.5 %h uiWin! $222222 sdlcolor uiRFill10	
	1 9 UIGridA $444444 sdlcolor uiRFill	
	0 0 uigAt uiH stDark
	" " uiTLabel
	datejuln 1+ 7 mod >dianame uiTLabel ", " uiTLabel
	[ 0 'modocal ! ; ] dia .d uiTBtn " " uiTLabel
	[ 1 'modocal ! ; ] mes 1- >mesname uiTBtn " " uiTLabel
	[ 2 'modocal ! ; ] anio .d uiTBtn
	modocal 3 << 'mcall + @ ex
	3 9 uiGridA 
	0 8 uiGat
	StInfo
	'setnowdmy "Hoy" uiRBtn
	ui>>
	StSucc
	'exitdlg "Aceptar" uiRBtn
	;

|-----------------------------
#lhora "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" 0
#lms "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "43" "44" "45" "46" "47" "48" "49" "50" "51" "52" "52" "53" "54" "55" "56" "57" "58" "59" 0

#vhora 0 0
#vmin 0 0
#vseg 0 0

:sethms | H m s --
	dup 5 - 0 max 'vseg 8 + ! 'vseg !
	dup 5 - 0 max 'vmin 8 + ! 'vmin !
	dup 5 - 0 max 'vhora 8 + ! 'vhora !	;
	
:setnowhms
	time dup 16 >> $ff and over 8 >> $ff and rot $ff and 
	sethms ;
	
:set64hms | dtvar --
	dup 24 >> $ff and over 16 >> $ff and rot 8 >> $ff and
	sethms ;

:uiHMS
	4 4 uiPad
|	0.4 %w 0.1 %h 
	uiZone@ 2drop 0.2 %h - swap 0.07 %w - swap
	0.14 %w 0.4 %h uiWin! $222222 sdlcolor uiRFill10
	1 11 UIGridA $444444 sdlcolor uiRFill
	0 0 uigAt 
	mark
	vhora ,2d " : " ,s vmin ,2d " : " ,s vseg ,2d 0 ,c 
	empty here uiLabelc
	2 2 uiPad
	3 11 UIGridA uiV 
	vhora
	0 1 uigAt 'vhora 11 'lhora uiList
	vhora swap <>? ( dup 5 - 0 max 'vhora 8 + ! ) drop
	vmin
	1 1 uigAt 'vmin 11 'lms uiList
	vmin swap <>? ( dup 5 - 0 max 'vmin 8 + ! ) drop
	vseg
	2 1 uigAt 'vseg 11 'lms uiList	
	vseg swap <>? ( dup 5 - 0 max 'vseg 8 + ! ) drop
	;
		
|----
:datetimefoco
	'uiDMY uisaveLast
	cifoc sdlColor uiRRect
	sdlkey
	<tab> =? ( nextfoco )
	drop ;	
	
:datetimefocoini
	dup 'datevar !
	dup @ 0? ( drop setnowhms ; ) set64hms ;
	
::uiDateTime | 'var --
	uiZone overfil uiRFill
	'datetimefoco 'datetimefocoini w/foco
	'clickfoco onClick	
	mark @ ,64>dtf 0 ,c empty here ttemitc ui.. ;

|----
:datefoco
	'uiDMY uisaveLast
	cifoc sdlColor uiRRect
	sdlkey
	<tab> =? ( nextfoco )
	drop ;
	
:datefocoini
	dup 'datevar !
	dup @ 0? ( drop setnowdmy ; ) set64dmy ;
	
::uiDate | 'var --
	uiZone overfil uiRFill
	'datefoco 'datefocoini w/foco
	'clickfoco onClick		
	mark @ ,64>dtd 0 ,c	empty here ttemitc ui.. ;

|----
:timefoco
	'uiHMS uisaveLast
	cifoc sdlColor uiRRect
	sdlkey
	<tab> =? ( nextfoco )
	drop ;
	
:timefocoini
	dup 'datevar !
	dup @ 0? ( drop setnowhms ; ) set64hms ;

::uiTime | 'var --
	uiZone overfil uiRFill
	'timefoco 'timefocoini w/foco
	'clickfoco onClick		
	mark @ ,64>dtt 0 ,c empty here ttemitc ui.. ;	