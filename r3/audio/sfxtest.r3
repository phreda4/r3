^r3/lib/console.r3
^r3/lib/rand.r3
^./gamesfx.r3

:screen
	0 0 .at
	"Music" .print
	.flush
	;
	
#p1 1 0.0 0.0 0.0 10 0.22 0.0  0.005 0.12 0.55 0.06 0
#p2 1 0.0 0.0 0.0 2 0.30 1.0  0.002 0.40 0.0 0.20 2	

:music
	"a bb c d e ~ a" 180 'p1 0 sfxtune drop
	"bb cd " 180 'p2 1 sfxtune drop
	;

:handle
	[f1] =? ( music ) 
	;
	
:main
	sfxinit
	.alsb .hidec .cls
	( inkey [ESC] <>?
		handle drop
		sfxupdate
		screen
		16 ms
		) drop
	.Reset .cls .masb .showc .flush
	.flush .free ;

: main ;