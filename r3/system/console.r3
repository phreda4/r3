| console r3
| PHREDA 2021

^r3/win/console.r3

#.bye 0

|-----------------
:ibye 1 '.bye ! "bye!" . cr ;

|-----------------
:ihelp
	"r3 console help." . cr
	"help - Show available commands" . cr
	"ram - Show RAM layout" . cr
	"new - Create new cartridge" . cr
	"load <file> - Load file.r3 from the local filesystem" . cr
	"save <file> - Save file.r3 to the local filesystem" . cr
	"run - Run current project" . cr
	"cat <file> - show file" . cr
	"cls - clear screen" . cr	
	"dir - list archives in folder" . cr
	"bye - exit console" . cr
	;

|-----------------
:icls
	.cls .home ;

|-----------------	
:linedir | adr --
	44 + . cr ;
	
:idir
	"r3//*" ffirst 
	( 1? linedir 
		fnext ) drop
	cr
	;

|-----------------
:icat
	'pad trim >>sp trim
	here swap "r3/%s" sprint load 
	here =? ( drop "File not found." . cr ; )
	0 swap c!
	here . cr ;
	
|-----------------	
:ikey
	( getch 27 <>? 
		codekey "$%h $%h " .print cr ) drop ;
	
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
	interp 0? ( " ???" . cr drop ; )
	@ ex ;
	
:main
	"r3 console - PHREDA 2021" . cr
	"help for help" . cr cr
	|'itest ex
	( .bye 0? drop
		"> " . .input cr
		interprete
		) drop ;

	
: 
windows
mark
main ;

