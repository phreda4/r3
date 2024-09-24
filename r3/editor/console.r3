| console r3
| PHREDA 2021

^r3/lib/console.r3

#.bye 0

|-----------------
:ibye 1 '.bye ! "bye!" .write .cr ;

|-----------------
:ihelp
	"r3 console help." .write .cr
	"help - Show available commands" .write .cr
	"ram - Show RAM layout" .write .cr
	"new - Create new cartridge" .write .cr
	"load <file> - Load file.r3 from the local filesystem" .write .cr
	"save <file> - Save file.r3 to the local filesystem" .write .cr
	"run - Run current project" .write .cr
	"cat <file> - show file" .write .cr
	"cls - clear screen" .write .cr	
	"dir - list archives in folder" .write .cr
	"bye - exit console" .write .cr
	;

|-----------------
:icls
	.cls ;

|-----------------	
:linedir | adr --
	44 + .write .cr ;
	
:idir
	"r3//*" ffirst 
	( 1? linedir 
		fnext ) drop
	.cr
	;

|-----------------
:icat
	'pad trim >>sp trim
	here swap "r3/%s" sprint load 
	here =? ( drop "File not found." .write .cr ; )
	0 swap c!
	here .write .cr ;
	
|-----------------	
:ikey
	( getch 27 <>? 
		codekey "$%h $%h " .println ) drop ;
	
:iram 
:inew 
:iload 
:isave 
:irun	
	;
|-----------------	

#inst "ram" "new" "load" "save" "run" "key" "cat" "dir" "cls" "help" "bye" 0
#insc 'iram 'inew 'iload 'isave 'irun 'ikey 'icat 'idir 'icls 'ihelp 'ibye 0

:interp | adr -- ex/0
	'insc >a
	'inst ( dup c@ 1? drop
		2dup =w 1? ( 3drop a> ; ) drop
		>>0 8 a+ ) nip nip ;
	
:interprete
	'pad trim
	dup c@ 0? ( drop ; ) drop
	interp 0? ( " ???" .write .cr drop ; )
	@ ex ;
	
:main
	"r3 console - PHREDA 2021" .write .cr
	"help for help" .write .cr .cr
	|'itest ex
	( .bye 0? drop
		"> " .write .input .cr
		interprete
		) drop ;

	
: main ;

