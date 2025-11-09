| common socket library
| PHREDA 2025
^r3/lib/term.r3
^r3/lib/netsock.r3

:BUFF_SIZE 4096 ;
#LOCALHOST "127.0.0.1"


:main
	"hola" .println
	.flush
	waitkey
	;
	
: main ;
