| triangulso
| PHREDA 2021

^r3/win/sdl2.r3	
^r3/lib/gr.r3

#dx1 1.23
#dx2 -0.1

:tri | xf x1. x2. xi --
	( pick3 <? 
		pick2 16 >> over pick3 16 >> over SDLLine
		rot dx1 + rot dx2 + rot
		1 + ) 4drop ;

:1linea | xy1 xy2 xy3 y --
	swap 32 >> 2swap	| y x3 xy1 xy2
	32 >> swap 32 >> 
	2dup min 
	rot rot max 		| y x3 min max
	pick2 max 
	rot rot min 		| y max min
	rot rot over 
	SDLline ;
	
:y2=y3 | xy1 xy2 xy3 ymin --
	pick3 32 << 32 >>
	=? ( 1linea ; ) | V
	dup >r 
	pick3 32 << 32 >> | ymin ymax 
	dup >a swap - >b | xy1 xy2 xy3 -- ; a:ymax r:ymin b:dy
	rot 32 >> 16 <<
	rot 32 >> 16 <<
	rot 32 >> 16 <<
	pick2 - b> /
	swap rot - b> / | 
	
	
	
	32 >> 16 << >a /
	;
	
	
:sort2 | xy2 xy3 -- xym xyM
	over 32 << 32 >> | y2
	over 32 << 32 >> | y2 y3
	<? ( drop swap ; ) drop ;
		
:triangle | xy1 xy2 xy3 --
	sort2 rot sort2 | mayor-->menor
	over 32 << 32 >>
	over 32 << 32 >> 
	=? ( y2=y3 ; )
	
	;
	
:drawl
	0 SDLclear
	
	$ff00 SDLcolor
	
	200 5.0 200.0 10 tri
	
	SDLRedraw

	
	SDLkey
	>esc< =? ( exit )
	drop ;
		
:main
	"r3sdl" 640 480 SDLinit

	'drawl SDLshow 

	SDLquit
	;

: main ;
