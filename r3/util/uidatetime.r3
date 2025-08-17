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
	|refreshfoco
	uiExitWidget
	;
	
:clickd | 'jday -- 'jday
	dup jul2date 'anio ! 'mes ! 'dia !
	jhoja! ;

:clickdn | 'jday -- 'jday
	dup jul2date 'anio ! 'mes ! 'dia !
	jhoja! ; 
	
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
	0.25 %w 0.5 %h uiWinFit! $222222 sdlcolor uiRFill10 $ffffff sdlcolor uiRRect10	
	1 9 UIGridA |$444444 sdlcolor uiRFill	
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
:uiHMS
	4 4 uiPad
	uiZone@ 2drop 0.2 %h - |swap 0.07 %w - swap
	0.1 %w 0.4 %h uiWinFit! 
	$222222 sdlcolor uiRFill10 $ffffff sdlcolor uiRRect10
	1 11 UIGridA $444444 sdlcolor uiRFill
	0 0 uigAt 
	'uiExitWidget
	mark datevar @ ,64>dtt 0 ,c empty here uiRBtn

	3 11 UIGridA uiH
	0 1 uiGAt 1 10 uiGTo
	0 24 datevar 3 + uiVSlideri8
	0 59 datevar 2 + uiVSlideri8
	0 59 datevar 1 + uiVSlideri8	
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
	dup @ 0? ( drop setnowdmy ; ) set64dmy ;
	
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
	dup @ 1? ( drop ; ) drop 
	time 8 << over ! ;

::uiTime | 'var --
	uiZone overfil uiRFill
	'timefoco 'timefocoini w/foco
	'clickfoco onClick		
	mark @ ,64>dtt 0 ,c empty here ttemitc ui.. ;	