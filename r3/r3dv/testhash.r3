^r3/lib/console.r3
^./hash3d.r3


:.v3 dup getz over gety rot getx "%d %d %d" .println ;
	

:main
	.cls
	"test 3dhash" .println
	
	$3 H3d.ini	
	H3d.clear
	
	1 1 1 pack3 dup .v3 .cr
	
	ldebug
	0 16 10 10 10 h3d+! | id rad x y z 
	ldebug
	1 16 12 12 12 h3d+! | id rad x y z 
	ldebug
	2 16 30 30 30 h3d+! | id rad x y z 
	ldebug
	waitesc ;

: main ;
