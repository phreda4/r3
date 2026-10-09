^r3/lib/console.r3
^r3/lib/rand.r3
^./gamesfx.r3

:screen
	0 0 .at
	"Music" .print
	.flush
	;
	
#i1 #i2
:mkins | --
	0.005 0.12 0.55 0.06 packADSR 'oscSaw iosc 'i1 !
	0.002 0.40 0.0 0.20 packADSR 'oscSin iosc 'i2 ! ;

:music
	"a bb c d e ~ a" 180 i1 0 sfxtune 0.22 0 sfxtunemix drop
	"bb cd " 180 i2 1 sfxtune 0.30 2 sfxtunemix drop
	;

:handle
	[f1] =? ( music ) 
	;
	
:main
	sfxinit mkins
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