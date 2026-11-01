| r3build - codigo seleccionado en main.r3 (mem/menu.mem)
| PHREDA 2026

^r3/util/tui.r3
^r3/d4/r3token.r3

#filename * 1024
#msg * 1024

|---- CHECKCODE
		
:coderror | error --
	.cl bg1 fPr lerror " %w | " .print
	.write " in line" .print 
	.eline
	'msg strcpybuf ;
	
:codeok
	.cl
	cnttok cntdef cntinc " OK | inc:%d words:%d tokens:%d" .print 
	.eline
	'msg strcpybuf ;

:checkcode
	0 'msg !
	'filename r3load
	error 1? ( coderror ; ) drop 
	codeok 
	;

|------- old
|:fileplaino "r3/editor/r3plain.r3" r3run tuR! ;

:filecompileo
	"r3/system/r3compiler.r3" r3run
	|.reterm .alsb .flush 
	tuR! ;

|------- new
:filecompile
	"r3/d4/r3plain.r3" r3run
	"r3/d4/r3wincomp.r3" r3run
	|.reterm .alsb .flush 
	tuR! ;

:fileplain
	"r3/d4/r3plain.r3" r3run
|	.reterm .alsb .flush 
	"r3/d4/gen/plain.r3" r3run | exec
	tuR! ;


:main
	"Building" .println
	"Code: " .write 'filename .write .cr .cr
	cntinc " includes:%d |" .print
	cntdef " words:%d |" .print
	cnttok " tokens:%d" .println
	.cr .cr
	cols .hline
	"[f2] Win64exe" .write .cr 
	"[f3] Plain " .write .cr
	"[f4] Win64exeOLD" .write .cr 
|	"[f5] PlainOld " .write .cr
	cols .hline
	.reset .cr
	getch 
	[f2] =? ( filecompile )
	[f3] =? ( fileplain ) 
	
	[f4] =? ( filecompileo )
|	[f5] =? ( fileplaino )
	
	drop
	
	;	


:
	'filename "mem/menu.mem" load drop
	checkcode error 1? ( drop coderror ; ) drop
	.masb .reset .cls
	main
	.alsb
	;
