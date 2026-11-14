| RIMM file dialog: port of imfiledlg.r3 (unfinished there) over RIMM
|
|   uiFileName | 'buf max --   field with the file name; a click (or Enter) opens the dialog
|                              centered over the rest; OK writes "folder/name" in the buffer
|                              (max = size of the buffer, it is not written if it does not fit)
|   uiFileFull | -- "folder/name"   the choice of the dialog now
|
| The dialog is a pop-up of uiEnd (as the combo): path bar with a button per folder,
| name line, list of folders (end with /) and files, OK and CANCEL.
| A click on an item selects it; a second click or Enter enters the folder or accepts the file.
|
^r3/lib/str.r3
^r3/rimm/rimmwid.r3

#fvar 0		| buffer of the widget that opened the dialog
#fmax 0
#dname * 1024	| name typed or chosen
#fpath * 1024	| folder (without the last /)
#fseg * 256	| segment of the path bar
#fcutp 0
#fbuf * 32768	| strings of the list: folders (name/) first, then files
#fidx * 8192	| address of each entry (1024)
#flp 0
#nfl 0
#fwant 0
#fent 0
#flsel 0 0	| list variable: chosen, first line shown
#fprev -1
#pw 0 #ph 0

:]fl | n -- adr
	3 << 'fidx + @ ;

:isdir | adr -- flag ; the entry ends with /
	count + 1- c@ $2f xor 0? ( drop 1 ; ) drop 0 ;

|--- scan of the folder
:fadd | entry --
	'fent !
	fent FNAME "." cmpstr 0? ( drop ; ) drop
	fent FDIR fwant <>? ( drop ; ) drop
	nfl 1000 >=? ( drop ; ) drop
	flp 'fbuf 32000 + >=? ( drop ; ) drop
	flp nfl 3 << 'fidx + !
	1 'nfl +!
	fent FNAME flp strcpyl 'flp !
	fwant 1? ( drop $2f flp 1- c! 0 flp c! 1 'flp +! ; ) drop ;

:scan | want --
	'fwant !
	'fpath
|WIN|	"%s/*" sprint
	ffirst ( 1? fadd fnext ) drop ;

:cmpe | a b -- n ; strings, "../" always first
	over "../" cmpstr 0? ( 3drop -1 ; ) drop
	dup "../" cmpstr 0? ( 3drop 1 ; ) drop
	cmpstr ;

#sst #si #skey
:shift? | j -- j flag ; the entry j goes after the key
	dup sst <? ( drop 0 ; ) drop
	dup ]fl skey cmpe 0 >? ( drop 1 ; ) drop 0 ;

:fsort | start -- ; insertion sort of the entries from start to the end
	'sst ! sst 1+
	( nfl <? dup 'si !
		si ]fl 'skey !
		si 1-
		( shift? 1? drop
			dup ]fl over 1+ 3 << 'fidx + !
			1- )
		drop 1+ 3 << 'fidx + skey swap !
		drop si 1+ ) drop ;

#fbuf2 * 32768	| the list in order (what the list widget shows)
#nd 0

:frebuild | --
	'fbuf2 'flp !
	0 ( nfl <?
		dup ]fl flp strcpyl
		flp pick2 3 << 'fidx + !
		'flp ! 1+ ) drop
	0 flp c! ;

:reload | --
	'fbuf 'flp ! 0 'nfl !
	1 scan nfl 'nd ! 0 fsort
	0 scan nd fsort
	frebuild
	0 'flsel ! 0 'flsel 8 + !
	-1 'fprev ! ;

:backfolder | --
	'fpath count +
	( 'fpath >?
		dup c@ $2f =? ( drop 0 swap c! reload ; )
		drop 1- ) drop
	'fpath c@ $2e =? ( drop ".." 'fpath strcpy reload ; ) drop
	"." 'fpath strcpy reload ;

:enterdir | "name/" --
	dup "../" cmpstr 0? ( 2drop backfolder ; ) drop
	"/" 'fpath strcat
	'fpath strcat
	'fpath count + 1- 0 swap c!
	reload ;

:splitname | "folder/file" -- ; folder and name of a path
	dup 'fpath strpath
	'fpath count nip +
	dup c@ $2f =? ( swap 1+ swap ) drop
	'dname strcpy
	'fpath c@ 1? ( drop ; ) drop
	"." 'fpath strcpy ;

|--- selection and acceptance
:select | n -- ; chosen in the list
	]fl dup isdir 1? ( 2drop ; ) drop
	'dname strcpy ;

:cpymax | src dst max --
	pick2 count nip >? ( drop strcpy ; ) 3drop ;

::uiFileFull | -- "folder/name"
	'dname 'fpath "%s/%s" sprint ;

:accept | --
	uiFileFull fvar fmax cpymax
	uiExitWidget ;

:activate | n -- ; second click or Enter on the item
	]fl dup isdir 1? ( drop enterdir ; ) drop
	'dname strcpy accept ;

:flist | --
	fh flpady 2 * - rh / 1 max
	'flsel swap 'fbuf2 uiList
	uiEx? 0? ( drop ; ) drop
	flsel fprev <>? ( dup 'fprev ! select ; ) drop
	flsel nfl >=? ( drop ; ) drop
	flsel activate ;

|--- path bar: a button per folder
:segend | adr -- adr' ; next / or the final 0
	( dup c@ 1? $2f <>? drop 1+ ) drop ;

:segcopy | start end --
	'fseg >a
	swap ( over <? dup c@ ca!+ 1+ ) 2drop
	0 ca!+ ;

:segclick | --
	0 fcutp c! reload ;

:pathbar | --
	'fpath
	( dup c@ 1? drop
		dup segend
		2dup segcopy
		dup 'fcutp !
		nip
		'segclick 'fseg uiNBtn
		dup c@ $2f =? ( "/" uiTlabel swap 1+ swap ) drop
		) 2drop
	uiLn ;

#fbw 1.0 -90 -90

:filedlg | --
	uiPush
	cx cy cw ch uiBox
	uiZoneW
	skinField sk
	rh flpady + 2 * flpady + uiN
	pathbar
	'dname 1023 uiInputLine
	rh flpady 2 * + uiS
	'fbw 3 uiColsW
	nfl "%d items" sprint uiLabel
	'accept "OK" uiBtn
	'uiExitWidget "CANCEL" uiBtn
	1 uiCols
	uiRest
	flist
	uiPop ;

|--- the widget
:fopen | 'buf max -- 'buf max
	2dup 'fmax ! 'fvar !
	fvar splitname reload
	sw 40 - 520 min 'pw !
	sh 40 - rh 18 * min 'ph !
	sw pw - 2/ sh ph - 2/ pw ph 'filedlg uiSaveLast ;

:kbfile
	skFocus
	sdlkey
	<tab> =? ( tabfocus )
	<ret> =? ( drop fopen 0 )
	drop ;

::uiFileName | 'buf max -- ; field with the name of a file: it opens the dialog
	uiZone
	skinField sk
	'kbfile uiFocus
	'fopen uiClk
	over ttinl
	colTxt $ffffff and color
	ICRIGHT cx cw + rh - 2 + cy 2 + rh 4 - uiIcon
	2drop ui.. ;
