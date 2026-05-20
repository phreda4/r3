^r3/lib/console.r3
^./hash3d.r3

:.v3 dup getz over gety rot getx "%d %d %d" .println ;
	
:main
	.cls
	"test 3dhash" .println
	
	$fff H3d.ini	
	H3d.clear
	
	1 1 1 pack3  .v3 .cr
|	recorre
	100 16 10 10 10 h3d+! | id rad x y z 
	101 16 12 12 12 h3d+! | id rad x y z 
	102 16 30 30 30 h3d+! | id rad x y z 
	waitesc ;

: main ;
