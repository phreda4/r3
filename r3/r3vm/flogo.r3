| FLOGO
| forth logo interpreter
| PHREDA 2021-2024(r3)
|-------------------------

^r3/win/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/sdlgui.r3
^r3/win/sdledit.r3

^./r3ivm.r3
^./r3itok.r3
^./r3iprint.r3

#codepath "r3/r3vm/flogo/"

#filenow * 256

:filename
	'codepath "%s%w.r3i" sprint ;

#spad * 256
#vm

|---- LOGO
#tpen 1			| 0-up n-grosor
#tcolor $ffffff
#pcolor 0
#tx #ty #tz
#tax #tay #taz 0.5
#xte #yte

#xcam 0 #ycam 0 #zcam 50.0

|----------------------------------
:error!
	'error ! ;

:drawturtle
	;

:turtle
|	tx ty tz mtransi
|	tax mrotxi tay mrotyi taz mrotzi
|	tcolor 'ink !
	drawturtle ;

:needstack | cnt -- 0/error
	vmdeep >? ( "empty stack!" error! )
	0 nip ;

|-------- WORDS
:xfoward
	1 needstack 1? ( drop ; ) drop
|	tcolor 'ink !
|	camscreen
|	tx ty tz 3dop
	taz vmpop polar 'ty +! 'tx +!
	tpen 0? ( drop ; ) drop
|	tx ty tz 3dline
	;

:xback
	1 needstack 1? ( drop ; ) drop
|	tcolor 'ink !
|	camscreen
|	tx ty tz 3dop
	taz vmpop neg polar 'ty +! 'tx +!
	tpen 0? ( drop ; ) drop
|	tx ty tz 3dline
|	>xfb 
	;


:xleft  1 needstack 1? ( drop ; ) drop vmpop 'taz +! ;
:xright	1 needstack 1? ( drop ; ) drop vmpop neg 'taz +! ;
:xpu	0 'tpen ! ;
:xpd	1 'tpen ! ;
:xps	1 needstack 1? ( drop ; ) drop vmpop 'tpen ! ;
:xink	1 needstack 1? ( drop ; ) drop vmpop 'tcolor ! ;
:xpaper	1 needstack 1? ( drop ; ) drop vmpop 'pcolor ! ;
:xhome	0 'tx ! 0 'ty ! 0 'tz ! 0.5 'taz ! ;
:xcls	xhome ; | cls
:xbye	exit ;

:xrand	rand vmpush ;


:xprint
	1 needstack 1? ( drop ; ) drop
|	camscreen
|	robotoregular 1.0 fontr!
|	4.0 dup rsize
|	tcolor 'ink !
	xte 'ccx ! yte 'ccy !
	vmpop code +
	( c@+ 1?
|		dup fontradr remit3d
|		fontrw 'ccx +!
		) 2drop
	ccx 'xte ! ccy 'yte !
	;

:xsetxy
	2 needstack 1? ( drop ; ) drop
	vmpop 'yte !
	vmpop 'xte !
	;

#wsys "WORDS" "BYE" "HOME" "CLS" "INK" "PAPER"
"FD" "BK" "LT" "RT" "PU" "PD" "PS"
"RAND" "PRINT" "SETXY"

:printname
	.print
	;

:xwords
|	xfb>
|	home
	'wbasdic ( @+ 1?		| core
		code2name printname
		) 2drop
    'wsys ( dup c@ 1? drop	| sys
		dup printname >>0
		) 2drop
	code 256 + | skip stack
	( code> <?				| user
		@+ code2name printname
		@+ $ffff and + ) drop
	;


#xsysexe 'xwords 'xbye 'xhome 'xcls 'xink 'xpaper
'xfoward 'xback 'xleft 'xright 'xpu 'xpd 'xps
'xrand 'xprint 'xsetxy

#wsysdic * 1024 | 256 words

|-------------------
:parse&run
	'spad r3i2token
	1? ( error! drop ; ) 2drop
	'msgok error!

	9 ,i
	vmresetr
	code> vmrun drop
	code> 'icode> !

	0 'spad !
	refreshfoco
	;

:printstack
	"["  bprint
	CODE 4 + ( NOS <=? @+ " %d" bprint ) drop
	CODE NOS <=? ( TOS " %d " bprint ) drop
	"]" bprint
	;

:printinfo | --
	0 rows 10 - gotoxy
	$ffff bcolor	"FLogo " bprint
	$ff00 bcolor printstack
	bcr
	$ffffff bcolor  "> " bprint 
	|'spad 64 binput cr
	$ff00 bcolor    
	error 1? ( dup bprint bcr ) drop

	0 rows 1 - gotoxy
	"F2-Edit" bprint
	sdlkey
	<ret> =? ( parse&run )
	drop
	;

|-------------------
:modedit
	"scratch" filename
	edload
	edrun
	edsave

	vm
	"scratch" filename
	vmload | load and compile CODE
	;

:savecode
|	dlgFileSave 0? ( drop ; )
|	home dup dumpc
	;

:loadcode
|	dlgFileLoad 0? ( drop ; )
|	cls home dup dumpc
|	'filenow strcpy
|	vm 'filenow vmload
	;

:newcode
	;

|-------------------
:runscr
	gui
	printinfo
|	camscreen
	turtle

	sdlkey
	<f2> =? ( modedit )
	<f5> =? ( savecode )
	<f6> =? ( loadcode )
	<f7> =? ( newcode )
	>esc< =? ( exit )
	drop
	;

:modrun
	mark
	vm
	"scratch" filename
	vmload | load CODE
	'runscr sdlshow
	empty
	;

|------------
|<<< BOOT <<<
|------------
:
	mark
|	fontj2
|	'codepath dlgSetPath

|	iniXFB cls >xfb
	$fff vmcpu 'vm !	| create CPU

	'wsysdic 'wsys makedicc
	'wsysdic syswor!
	'xsysexe vecsys!

	0 1 cols 1 - rows 2 - edwin edram

	modrun
	;
