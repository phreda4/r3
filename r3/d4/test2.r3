^r3/lib/console.r3
^r3/lib/parse.r3

#v1 #v2 #v3 #v4 #v5 #v6 #v7

:main
	
	"0.2 0.25 0.7 0.9999 0.0001 1.2 -2.399" 
	dup .write .cr
	str>fnro 'v1 !
	str>fnro 'v2 !
	str>fnro 'v3 !
	str>fnro 'v4 !
	str>fnro 'v5 !
	str>fnro 'v6 !
	str>fnro 'v7 !
	
	drop
	
	
	v1 dup dup "%f %m %a" .println
	v2 dup dup "%f %m %a" .println
	v3 dup dup "%f %m %a" .println
	v4 dup dup "%f %m %a" .println
	v5 dup dup "%f %m %a" .println
	v6 dup dup "%f %m %a" .println
	v7 dup dup "%f %m %a" .println
	
	waitkey
	;
	
: main ;