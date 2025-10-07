^./console.r3
^./utfg.r3


:main
	.cls .blue
	1 1 xat
	"Key Codes" xwrite .cr
	
	"" .eprint
	.white .flush
	testkey ;

: .console 
|.enable-mouse 
main 
|.disable-mouse 
.free ;
