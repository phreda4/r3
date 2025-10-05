^./console.r3
^./utfg.r3
^./tui.r3

|--------------------------------	
#filename "matrix.r3"
#path "r3/console"

:run
	'filename
	'path
|WIN| 	"cmd /c r3 ""%s/%s"" " |2>mem/error.mem"
|LIN| 	"./r3lin ""%s/%s"" 2>mem/error.mem"
	sprint 
	sysnew |sys
	;
	
|--------------------------------	
#.exit 0 :exit 1 '.exit ! ;

#vfolder 0 0
#vfile 0 0

:dirpanel
	.reset
	1 5 30 rows 11 - .win .wborde
	$1 " Dir " .wtitle
	1 .wmargin
	.wstart
	'vfolder wh 2 - uiDirs tuiTree
	;
:dirfile
	31 5 cols 30 - rows 11 - .win .wborde
	$1 " Files " .wtitle
	1 .wmargin
	.wstart
	'vfile wh 2 - uiFiles tuiList
	;
:dirpad
	1 rows 6 - cols 6 .win .wborde
	$1 " Command " .wtitle
	;
	
:scrmain
	.reset .cls .green
	2 1 xat
	"R3" xwrite .red "Forth" xwrite .cr
	.reset 
	dirpanel
	dirfile
	dirpad
	.rever
	1 rows .at 
	.eline " |ESC| ✕Exit |F1| ⏵Run |F2| ✍Edit |F3| 🔍Search |F4| ❔Help" .write .cr 
	.eline
	.flush
	;

:help
	23 5 40 20 .win
	32 32 32 .bgrgb
	.wfill 
	.greenl
	.wborded 4 .wmargin
	.white
	$00 "0" .wtitle $01 "1" .wtitle $02 "2" .wtitle $03 "3" .wtitle 
	$04 "| coso |" .wtitle 
	$05 "5" .wtitle $06 "6" .wtitle 

	$04 "a" .wtitle $14 "b" .wtitle 
	$24 "| 123 |" .wtitle 
	$34 "d" .wtitle 
	$44 "centro" .wtitle 
	$54 "f" .wtitle $64 "g" .wtitle 
	;
	
	
:hkey
	evtkey 
	[esc] =? ( exit ) 
	[f1] =? ( run ) 
	
	drop ;
	
:hmouse
	evtmb 
	1? ( evtmxy .at "." .fwrite ) 
	drop
	;
	
:testkey
	( .exit 0? drop
		inevt	
		1 =? ( hkey )
		2 =? ( hmouse )
		drop 
		20 ms
		) drop ;


|-----------------------------------
:main
	"r3" scandir
	|0 uiTreePath
	|'basepath 'fullpath strcpyl 1- strcpy
	"r3/audio" scanfiles

	
	'scrmain .onresize
	scrmain
	testkey ;

: .console 
main 
.free ;
