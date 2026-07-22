^r3/lib/console.r3
^r3/lib/parse.r3

#v1 #v2 330 #v3 #v4 #v5 #v6 #v7

:main
	|2 2 + 5 * 2 / 89 * 3 +
	|v1 0 <<
	v2 16 2 *>>
	"%d" .println 
	"0.254 0.255 0.256 0.99 0.001 1.2 -2.399" 
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