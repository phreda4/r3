^./console.r3
^./utfg.r3

|--------------------------------	
#filename "asciicam.r3"
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

:scrmain
	.cls .green
	2 1 xat
	"R3" xwrite .red "Forth" xwrite .cr

	.reset 
	23 5 40 20 .win
	32 32 32 .bgrgb
	.wfill 
	.greenl
	.wborded 4 .wmargin
	.white
	$00 "0" .wtitle 
	$01 "1" .wtitle 
	$02 "2" .wtitle 
	$03 "3" .wtitle 
	$04 "| coso |" .wtitle 
	$05 "5" .wtitle 
	$06 "6" .wtitle 

	$04 "a" .wtitle 
	$14 "b" .wtitle 
	$24 "| 123 |" .wtitle 
	$34 "d" .wtitle 
	$44 "centro" .wtitle 
	$54 "f" .wtitle 
	$64 "g" .wtitle 

4 40 .at 
"A" .write 1 .nsp "B" .write 2 .nsp "C" .write 3 .nsp "D" .write 33 4 .nch
	.reset .flush
	;
	


	
:hkey
	evtkey 
	[esc] =? ( exit ) 
	|1? ( dup "%h" .fprint .cr ) 
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

|--------------------------------	
:main
	'scrmain .onresize
	scrmain
	testkey ;

: .console 
main 
.free ;
