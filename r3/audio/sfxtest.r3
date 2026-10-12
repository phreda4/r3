^r3/lib/console.r3
^r3/lib/rand.r3
^./gamesfx.r3

:screen
	0 0 .at
	"Music" .println .cr
	
	"f1 - music1" .println
	"f2 - music2" .println
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
  45 i1 1 sfxtune
0.22 0 sfxtunemix drop
"c#2 a1 e2 b1" 90 i2 1 sfxtune 
0.30 2 sfxtunemix drop
	;

:music2
"<[f#2 c#2 e2 f#2 e2 c#2 b1 c#2]!6 [d2 d2 c#2 c#2 b1 b1 c#2 c#2]!2 [f#2 c#2 b1 c#2 d2 c#2 b1 c#2]!2>"

	117 i2 1 sfxtune
	0.3 0 sfxtunemix drop
	
"<~
 [[f#3,a3,c#4,e4] ~ ~ [g#3,b3,d#4,f#4] ~ ~  ]!5
 [[d3,f3,a3,c4] [c#3,e3,g#3,b3]]!2
 [[f#3,a3,c#4] [b3,d4,f#4]]!2
>"
|	117 i1 1 sfxtune 
|	0.2 0 sfxtunemix drop
	
	;
	
:handle
	[f1] =? ( music ) 
	[f2] =? ( music2 ) 
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