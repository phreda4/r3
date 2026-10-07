^r3/lib/console.r3
^r3/lib/rand.r3
^./gamesfx.r3

:screen
	0 0 .at
	"Music" .print
	.flush
	;
	
#p1 [ $110 0.0 0.0 0.0 0.22 0.0 0.005 0.12 0.55 0.06 ]
#p2 [ $122 0.0 0.0 0.0 0.30 0.0 0.002 0.40 0.0 0.20 ]
#p3 [ $130 0.0 0.0 0.0 0.32 0.0 0.01 0.10 0.65 0.08 ]
#p4 [ $100 0.0 0.0 0.0 0.20 0.0 0.005 0.10 0.60 0.05 ]

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