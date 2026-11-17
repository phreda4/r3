| RIMM file dialog: port of imfiledlg.r3 (unfinished there) over RIMM
|
|   uiFileName | 'buf max --   field with the file name; a click (or Enter) opens the dialog
|                              centered over the rest; OK writes "folder/name" in the buffer
|                              (max = size of the buffer, it is not written if it does not fit)
|   uiFileFull | -- "folder/name"   the choice of the dialog now
|   uiFileOpen | 'buf max --   like uiFileName, but the file must exist
|   uiFileSave | 'buf max --   like uiFileName, an existing file needs OK twice (overwrite)
|   uiFileFilter | "png bmp" --   only the files with these extensions (case ignored), "" = all
|
| ESC closes the dialog, the Hidden check shows the files that start with a dot, the sizes
| of the selected file are in the bottom line (with the messages of the checks).
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
#fhid 0 #fhidp 0	| bit 0: show the hidden files (start with a dot)
#fhidl "Hidden" 0
#ffilt * 256		| filter: extensions without dot separated by spaces ("png bmp"), empty = all
#fmodew 0 #fmode 0	| 0 any name, 1 the file must exist, 2 overwrite needs a confirmation
#fmsg 0		| address of the message of the bottom line, 0 = none
#fcname * 1024	| name already confirmed to be overwritten
#fszs * 8192	| size of each entry (in the order of the list)
#fe 0 #fe2 0
#fdebug 0		| 1: the bottom line shows the scanned path and the entries found
#fraw 0		| entries returned by the system in the last reload
#pw 0 #ph 0

:]fl | n -- adr
	3 << 'fidx + @ ;

:isdir | adr -- flag ; the entry ends with /
	count + 1- c@ $2f xor 0? ( drop 1 ; ) drop 0 ;

|--- filters
:fshow? | name -- flag ; hidden files only when asked ("../" always)
	dup c@ $2e <>? ( 2drop 1 ; ) drop
	fhid 1 and 1? ( 2drop 1 ; ) drop
	".." cmpstr 0? ( drop 1 ; ) drop 0 ;

:fext | name -- ext ; after the last dot, 0 if there is none
	0 'fe !
	( dup c@ 1? $2e =? ( over 1+ 'fe ! ) drop 1+ ) 2drop fe ;

:fmatch | name -- flag ; the extension is in the filter
	'ffilt c@ 0? ( 2drop 1 ; ) drop
	fext 0? ( ; ) 'fe2 !
	'ffilt
	( dup c@ 1? drop
		dup fe2 =w 1? ( 2drop 1 ; ) drop
		( dup c@ 32 >? drop 1+ ) drop
		( dup c@ 32 =? drop 1+ ) drop
	) 2drop 0 ;

|--- scan of the folder
:fadd | entry --
	'fent ! 1 'fraw +!
	fent FNAME "." cmpstr 0? ( drop ; ) drop
	fent FNAME fshow? 0? ( drop ; ) drop
	fent FDIR fwant <>? ( drop ; ) drop
	fwant 0? ( drop fent FNAME fmatch 0? ( drop ; ) ) drop
	nfl 1000 >=? ( drop ; ) drop
	flp 'fbuf 31900 + >=? ( drop ; ) drop
	flp nfl 3 << 'fidx + !
	1 'nfl +!
	fent FNAME flp strcpyl 'flp !
	fwant 1? ( $2f flp 1- c! 0 flp c! 1 'flp +! ) drop
	flp 7 + -8 and 'flp !
	fent FSIZEF flp ! 8 'flp +! ;

:scanpath | -- "path" ; an empty path is the root
|WIN|	'fpath "%s/*" sprint ;
	'fpath c@ 0? ( drop "/" ; ) drop 'fpath ;

:scan | want --
	'fwant !
	scanpath ffirst ( 1? fadd fnext ) drop ;

:lc | c -- c ; lower case letter
	65 <? ( ; ) 90 >? ( ; ) $20 or ;

:cmpi | a b -- n ; strings ignoring case
	over c@ lc over c@ lc -
	1? ( nip nip ; ) drop
	over c@ 0? ( 3drop 0 ; ) drop
	swap 1+ swap 1+ cmpi ;

:cmpe | a b -- n ; strings, "../" always first
	over "../" cmpstr 0? ( 3drop -1 ; ) drop
	dup "../" cmpstr 0? ( 3drop 1 ; ) drop
	cmpi ;

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
		dup ]fl count + 1+ 7 + -8 and @ over 3 << 'fszs + !
		dup ]fl flp strcpyl
		flp pick2 3 << 'fidx + !
		'flp ! 1+ ) drop
	0 flp c! ;

:reload | --
	'fbuf 'flp ! 0 'nfl ! 0 'fraw !
	1 scan nfl 'nd ! 0 fsort
	0 scan nd fsort
	frebuild
	0 'flsel ! 0 'flsel 8 + !
	0 'fmsg !
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

:lastslash | "str" -- adr/0 ; the last / or \ (0 if there is none)
	0 'fe !
	( dup c@ 1?
		$2f =? ( over 'fe ! )
		$5c =? ( over 'fe ! )
		drop 1+ ) 2drop fe ;

:splitname | "folder/file" -- ; folder and name of a path (without folder: "." and the whole name)
	dup lastslash 0? ( drop 'dname strcpy "." 'fpath strcpy ; )
	dup 1+ 'dname strcpy
	over - 'fe2 !
	'fpath swap fe2 cmove
	0 'fpath fe2 + c! ;

|--- selection and acceptance
:select | n -- ; chosen in the list
	]fl dup isdir 1? ( 2drop ; ) drop
	0 'fmsg !
	'dname strcpy ;

:cpymax | src dst max --
	pick2 count nip >? ( drop strcpy ; ) 3drop ;

::uiFileFull | -- "folder/name"
	'dname 'fpath "%s/%s" sprint ;

|--- checks of the name before accepting
:fexists? | -- flag ; the name is a file of the list
	0 ( nfl <?
		dup ]fl isdir 0? ( drop dup ]fl 'dname cmpstr 0? ( 2drop 1 ; ) ) drop
		1+ ) drop 0 ;

:fok0 | -- flag
	1 ;

:fok1 | -- flag ; open: the file must exist
	fexists? 0? ( drop "File not found" 'fmsg ! 0 ; ) ;

:fok2 | -- flag ; save: an existing file needs a second OK with the same name
	fexists? 0? ( drop 1 ; ) drop
	'dname 'fcname cmpstr 0? ( drop 1 ; ) drop
	'dname 'fcname strcpy
	"Overwrite? press OK again" 'fmsg ! 0 ;

#foktab 'fok0 'fok1 'fok2

:fok? | -- flag
	'dname c@ 0? ( drop "Type a file name" 'fmsg ! 0 ; ) drop
	fmode 3 << 'foktab + @ ex ;

:accept | --
	fok? 0? ( drop ; ) drop
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

|--- bottom line: message, or the size of the selected file
:fsizes | bytes -- "text"
	1024 <? ( "%d B" sprint ; )
	1048576 <? ( 10 >> "%d KB" sprint ; )
	20 >> "%d MB" sprint ;

:finfo | -- "text"
	fmsg 1? ( drop fmsg ; ) drop
	fdebug 1? ( drop nfl fraw scanpath "%s raw=%d n=%d" sprint ; ) drop
	flsel nfl >=? ( drop nfl "%d items" sprint ; ) drop
	flsel ]fl isdir 1? ( drop nfl "%d items" sprint ; ) drop
	flsel 3 << 'fszs + @ fsizes ;

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
	'fpath c@ 0? ( 0 'fseg c! 'fpath 'fcutp ! 'segclick 'fseg uiNBtn "/" uiTlabel ) drop
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

#fbw 1.0 -80 -90 -90

:filedlg | --
	flpadx flpady
	uiPush
	cx cy cw ch uiBox
	0 0 uiPad
	uiZoneW
	skinField sk
	12 8 uiPad
	sdlkey >esc< =? ( uiExitWidget ) drop
	rh flpady + 2 * flpady + uiN
	pathbar
	'dname 1023 uiInputLine
	rh flpady 2 * + uiS
	'fbw 4 uiColsW
	finfo uiLabel
	'fhid 'fhidl uiCheck
	'accept "OK" uiBtn
	'uiExitWidget "CANCEL" uiBtn
	1 uiCols
	fhid fhidp <>? ( dup 'fhidp ! reload ) drop
	uiRest
	flist
	uiPop uiPad ;

|--- the widget
:fopen | 'buf max -- 'buf max
	2dup 'fmax ! 'fvar !
	fmodew 'fmode ! 0 'fcname c!
	fvar splitname reload
	sw 40 - 680 min 'pw !
	sh 40 - rh 18 * min 'ph !
	sw pw - 2/ sh ph - 2/ pw ph 'filedlg uiSaveLast ;

:kbfile
	skFocus
	sdlkey
	<tab> =? ( tabfocus )
	<ret> =? ( drop fopen 0 )
	drop ;

:filefield | 'buf max --
	uiZone
	skinField sk
	'kbfile uiFocus
	'fopen uiClk
	over ttinl
	colTxt $ffffff and color
	ICRIGHT cx cw + rh - 2 + cy 2 + rh 4 - uiIcon
	2drop ui.. ;

::uiFileName | 'buf max -- ; field with the name of a file: it opens the dialog
	0 'fmodew ! filefield ;

::uiFileOpen | 'buf max -- ; like uiFileName, the file must exist
	1 'fmodew ! filefield ;

::uiFileSave | 'buf max -- ; like uiFileName, overwriting a file needs a second OK
	2 'fmodew ! filefield ;

::uiFileFilter | "png bmp" -- ; extensions of the files shown (case ignored), "" = all
	'ffilt strcpy ;
