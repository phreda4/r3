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
"<[c#4 e4 g#4 b4  a3 c#4 e4 g#4  e3 g#3 b3 e4  b3 d#4 f#4 b4]
[a3 c#4 e4 e4  f#4 e4 d#4 c#4  b3 d#4 f#4 f#4  g#4 f#4 e4 d#4]
[[c#4 e4 g#4 e4] [f#4 e4 c#4 e4]  [a3 c#4 e4 c#4] [f#4 e4 d#4 c#4]  [e3 g#3 b3 g#3] [e4 d#4 c#4 b3]  [b3 d#4 f#4 d#4] [g#4 f#4 e4 d#4]]
[c#5 b4 g#4 f#4  e4 f#4 g#4 e4  a4 g#4 f#4 e4  d#4 e4 f#4 b4]>"
  90 i1 1 sfxtune
0.22 0 sfxtunemix drop
"c#2 a1 e2 b1" 90 i2 1 sfxtune 
0.30 2 sfxtunemix drop
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