| RIMM date: port of immdatetime.r3 (PHREDA 2025) over RIMM -- first part: the date
|
|   uiDate | 'var --   date field: a click (or Enter) opens a calendar with days, months and years
|
| The variable is a dt64 (as util/datetime.r3):
|   year<<48 | month<<44 | weekday<<40 | day<<32 | hour<<24 | minute<<16 | second<<8
| 0 = no value: the calendar starts today. Accept keeps the time bits of the value.
| The grids of days, months and years are the columns of RIMM (uiCols): each button
| takes its cell. (uiTime and uiDateTime of immdatetime come next.)
|
^r3/lib/jul.r3
^r3/util/datetime.r3
^r3/rimm/rimmwid.r3

#cddia 10 #cdmes 6 #cdanio 2025
#cdmode 0	| panel: 0 days, 1 months, 2 years
#cdjn		| selected day (julian)
#cdj		| first of the month
#cdji		| first cell of the grid (a sunday)
#cdjm		| first of next month
#cdje		| end of the grid
#cda1 #cda2	| years of the panel of years
#cdvar 0	| variable being edited

:hoja! | anio mes dia --
	'cddia ! 'cdmes ! 'cdanio !
	cddia cdmes cdanio date2jul 'cdjn !
	1 cdmes cdanio date2jul
	dup 'cdj !
	dup jul2day
	1+ 7 mod
	- dup 'cdji !
	42 + dup 'cdje !
	( dup jul2date drop nip cdmes <>? drop 1- ) drop
	1+ 'cdjm !
	cdanio 7 - 'cda2 !
	cdanio 10/ 10* 50 - 'cda1 ! ;

|--- the value
:setnow | -- ; today
	date dup 16 >> swap dup 8 >> $ff and swap $ff and hoja! ;

:loadvar | dt64 --
	dup 48 >> $ffff and 0? ( 2drop setnow ; ) drop
	dup 48 >> $ffff and
	over 44 >> $f and
	rot 32 >> $ff and
	hoja! ;

:dt64 | -- v ; the chosen date in dt64 (no time)
	cdanio $ffff and 48 <<
	cdmes $f and 44 << or
	cdjn 1+ 7 mod $f and 40 << or
	cddia $ff and 32 << or ;

:accept | --
	cdvar @ $ffffffff and dt64 or cdvar !
	uiExitWidget ;

|--- panels of the calendar
:clickd | 'jday -- 'jday
	dup jul2date 'cdanio ! 'cdmes ! 'cddia !
	cdanio cdmes cddia hoja! ;

#nadia "Dom" "Lun" "Mar" "Mie" "Jue" "Vie" "Sab"

:paneldia | --
	7 uiCols
	stDark
	'nadia 0 ( 7 <? swap
		dup uiLabelC
		4 + swap 1+ ) 2drop
	cdji ( cdj <?
		'clickd over jul2date 2drop .d uiCBtn
		1+ )
	stInfo
	( cdjm <?
		cdjn =? ( stLink )
		'clickd over jul2date 2drop .d uiCBtn
		cdjn =? ( stInfo )
		1+ )
	stDark
	( cdje <?
		'clickd over jul2date 2drop .d uiCBtn
		1+ ) drop
	stTheme 1 uiCols ;

:clickm | n -- n
	cdanio over 1+ cddia hoja!
	0 'cdmode ! ;

:panelmes | --
	3 uiCols
	stDark
	0 ( 12 <?
		cdmes 1- =? ( stInfo )
		'clickm over >mesname uiRBtn
		cdmes 1- =? ( stDark )
		1+ ) drop
	stTheme 1 uiCols ;

:clicka | y -- y
	dup cdmes cddia hoja! ;

:clickan | y -- y
	dup cdmes cddia hoja! 1 'cdmode ! ;

:panelanio | --
	5 uiCols
	stDark
	0 ( 5 <?
		dup 10 * cda1 + 'clicka over .d uiRBtn drop
		1+ ) drop
	stInfo
	0 ( 15 <?
		dup cda2 +
		cdanio =? ( stLink )
		'clickan over .d uiRBtn
		cdanio =? ( stInfo )
		drop
		1+ ) drop
	stDark
	0 ( 5 <?
		dup 10 * cda1 60 + + 'clicka over .d uiRBtn drop
		1+ ) drop
	stTheme 1 uiCols ;

#mcall 'paneldia 'panelmes 'panelanio

|--- the pop-up
#cdw3 1.0 -90 -90

:header | --
	" " uiTLabel
	cdjn 1+ 7 mod >dianame uiTLabel ", " uiTLabel
	[ 0 'cdmode ! ; ] cddia .d uiNBtn " " uiTLabel
	[ 1 'cdmode ! ; ] cdmes 1- >mesname uiNBtn " " uiTLabel
	[ 2 'cdmode ! ; ] cdanio .d uiNBtn
	uiLn ;

:footer | --
	'cdw3 3 uiColsW
	"" uiLabel
	stInfo 'setnow "Hoy" uiRBtn
	stSucc 'accept "Aceptar" uiRBtn
	stTheme 1 uiCols ;

:popup | --
	uiPush
	cx cy cw ch uiBox
	uiZoneW
	skinField sk
	rh flpady + uiN
	header
	rh flpady + uiS
	footer
	uiRest
	cdmode 3 << 'mcall + @ ex
	uiPop ;

:popw | -- w
	340 sw 16 - min ;
:poph | -- h ; header, names of the days, 6 weeks and footer
	rh flpady + 9 * flpady 4 * + ;
:popx | -- x ; inside the screen
	cx popw + sw >? ( drop sw popw - 8 - ; ) drop cx ;
:popy | -- y ; below the field if it fits, else above
	cy rh + poph + sh >? ( drop cy poph - ; ) drop cy rh + ;

:dopen | 'var -- 'var
	dup 'cdvar !
	dup @ loadvar
	0 'cdmode !
	popx popy popw poph 'popup uiSaveLast ;

|--- the field
:txtdate | 'var -- str
	@ 0? ( drop "---" ; )
	mark ,64>dtd 0 ,c empty here ;

:kbdate
	skFocus
	sdlkey
	<tab> =? ( tabfocus )
	<ret> =? ( drop dopen 0 )
	drop ;

::uiDate | 'var -- ; date field: a click opens the calendar; the variable is a dt64 (0 = none)
	uiZone
	skinField sk
	'kbdate uiFocus
	'dopen uiClk
	dup txtdate colText ttwritec
	drop ui.. ;
