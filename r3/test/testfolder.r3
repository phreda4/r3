^r3/win/console.r3

:FNAME | adr -- adrname
|WIN| 44 +
|LIN| 19 +
|RPI| 11 +
|MAC| 21 +               | when _DARWIN_FEATURE_64_BIT_INODE is set !
	;

:FDIR? | adr -- 1/0
|WIN| d@ 4 >>
|LIN| 18 + c@ 2 >>
|RPI| 10 + c@ 2 >>
|MAC| 20 + c@ 2 >>       | when _DARWIN_FEATURE_64_BIT_INODE is set !
	1 and ;
	
:.file
	":" .print
	dup FDIR? 1? ( "<DIR> " .print ) drop
	FNAME
	dup ".." = 1? ( 2drop ".." .println ; ) drop
	dup "." = 1? ( 2drop ".." .println ; ) drop
	"%s" .println
	;
	
:dir | path --
	ffirst ( .file fnext 1? ) drop ;

	
:nextfile | ff -- ff'
	( dup FDIR? 1? drop fnext ) drop ;
	
:dir | nro path -- file
	ffirst nextfile 
	( swap 1? 1 - swap fnext ) drop ;
	
	
:main
	.cls
	"folder" .println
	"autotv/videos/*" dir
	;
	
: main ;