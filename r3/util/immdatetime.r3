| UI dstetime
| PHREDA 2025

^r3/lib/jul.r3
^r3/util/immi.r3
^r3/util/datetime.r3

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
	anio 10/ 10* 50 - 'anio1 !
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
	7 7 uiGrid
	|0 1 uiat
	stDark
	'nadia 0 ( 7 <? swap
		dup uiLabelC uiNext
		4 + swap 1+ ) 2drop
	datejuli ( datejul <?
		'clickd over jul2date 2drop .d uiCbtn uiNext
		1+ )
	stInfo
	( datejulm <?
		datejuln =? ( stLink )
		'clickdn over jul2date 2drop .d uiCbtn uiNext
		datejuln =? ( stInfo )
		1+ ) 
	stDark
	( datejule <?
		'clickd over jul2date 2drop .d uiCbtn uiNext
		1+ ) drop ;

:clickm
	anio over 1+ dia hoja! 
	0 'modocal ! ;

:panelmes
	3 4 uiGrid
	stDark
	0 ( 12 <?
		mes 1- =? ( stInfo )
		'clickm over >mesname uiRBtn uiNext
		mes 1- =? ( stDark )
		1+ ) drop ;
	
:clickan
	dup mes dia hoja! 1 'modocal ! ;

:clicka
	dup mes dia hoja! ;
	
:panelanio
	5 5 uiGrid
	stDark
	0 ( 5 <?
		dup 10 * anio1 + 'clicka over .d uiRBtn drop
		uiNext
		1+ ) drop
	stInfo	
	0 ( 15 <?
		dup anio2 + 
		anio =? ( stLink )
		'clickan over .d uiRBtn 
		uiNext
		anio =? ( stInfo )
		drop
		1+ ) drop 
	stDark		
	0 ( 5 <?
		dup 10 * anio1 60 + + 'clicka over .d uiRBtn drop 
		uiNext
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
	uiPush
	cx cy cw ch uiBox
	uiZone $222222 sdlcolor uiFill
	4 4 uiPading
	
	txh 16 + uiN

	" " uiTLabel
	datejuln 1+ 7 mod >dianame uiTLabel ", " uiTLabel
	[ 0 'modocal ! ; ] dia .d uiNBtn " " uiTLabel
	[ 1 'modocal ! ; ] mes 1- >mesname uiNBtn " " uiTLabel
	[ 2 'modocal ! ; ] anio .d uiNBtn
	
	txh 16 + uiS
	8 8 uiPading
	3 1 uiGrid
	0 0 uiat
	StInfo 'setnowdmy "Hoy" uiRBtn
	2 0 uiAt
	StSucc 'exitdlg "Aceptar" uiRBtn
	
	uiRest
	modocal 3 << 'mcall + @ ex
	
	uiPop
	;

|-----------------------------
:uiHMS
	uiZone $222222 sdlcolor uiFill
	4 4 uiPading

	1 11 UIGrid |$444444 sdlcolor uiRFill
	0 0 uiAt 
	'uiExitWidget
	mark datevar @ ,64>dtt 0 ,c empty here uiRBtn

	3 11 UIGrid 
	0 1 uiAt 1 10 uiTo
|	0 24 datevar 3 + uiVSlideri8
|	0 59 datevar 2 + uiVSlideri8
|	0 59 datevar 1 + uiVSlideri8	
	;
		
|----
:datetimefoco
	cx |0.125 %w - 
	cy |0.25 %h -
	0.25 %w txh 20 * |0.5 %h 
	'uiDMY uisaveLast
	|cifoc sdlColor uiRRect
	sdlkey
	<tab> =? ( tabfocus )
	drop ;	
	
:datetimefocoini
	dup 'datevar !
	dup @ 0? ( drop setnowdmy ; ) set64dmy ;
	
::uiDateTime | 'var --
	uiZone $222222 sdlcolor uilFill |overfil uiRFill
	'datetimefoco uiFocus |'datetimefocoini w/foco
	mark @ ,64>dtf 0 ,c empty here 
	ttwritec ui.. ;

|----
:datefocoini
	cx |0.125 %w - 
	cy |0.25 %h -
	0.25 %w |0.5 %h 
	txh 12 *
	'uiDMY uisaveLast
	dup 'datevar !
	dup @ 0? ( drop setnowdmy ; ) set64dmy ;

:datefoco
	$ffffff sdlcolor
	4 cx 1- cy 1- cw 2 + txh 2 + SDLRound
|	cifoc sdlColor uiRRect
	'datefocoini uiClk 
	sdlkey
	<tab> =? ( tabfocus )
	drop ;
	
	
::uiDate | 'var --
	uiZone $222222 sdlcolor uilFill |overfil uiRFill
	'datefoco uiFocus |'datefocoini w/foco
	mark @ ,64>dtd 0 ,c	empty here 
	ttwritec ui.. ;

|----
:timefoco
	cx cy 0.2 %h - 0.1 %w 0.4 %h 
	'uiHMS uisaveLast
|	cifoc sdlColor uiRRect
	sdlkey
	<tab> =? ( tabfocus )
	drop ;
	
:timefocoini
	dup 'datevar !
	dup @ 1? ( drop ; ) drop 
	time 8 << over ! ;

::uiTime | 'var --
	uiZone uilFill |overfil uiRFill
	'timefoco uiFocus |'timefocoini w/foco
	mark @ ,64>dtt 0 ,c empty here 
	ttwritec ui.. ;	
	