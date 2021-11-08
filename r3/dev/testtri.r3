| programa de triangulo
| PHREDA 2021

^r3/win/sdl2.r3	
^r3/lib/gr.r3

|-------------------
#dx1 0
#dx2 0

:tri | yf x1. x2. yi -- x1. x2.
	( pick3 <? 
		pick2 16 >> over pick3 16 >> over SDLLine
		rot dx1 + rot dx2 + rot
		1 + ) 
	drop rot drop ;
	
:triL | yx1 yx2 yx3 --  ; L
	dup 32 >> >r
	32 << 32 >> rot
	32 << 32 >> rot
	32 << 32 >> 
	pick2 pick2 pick2 min min
	>r max max
	>r >r | max min y
	rot over SDLLine ;

:triV | yx1 yx2 yx3 --  ; V
	pick2 32 >> over 32 >> -
	0? ( drop triL ; ) 
	pick3 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	32 << 32 >> 16 <<
	pick2 32 >> swap	| yx1 yx2 yf x3. 
	2swap 				| yf x3. yx1 yx2 
	over 32 << 32 >> over 32 << 32 >> - 16 << | x1 - x2 (fp)
	rot 32 >> pick2 32 >> - 
	/  'dx2 !
	dup	32 << 32 >> 16 <<	|  yf x3. yx2 x2. 
	swap 32 >>
	tri 2drop ;
		
:triangle | yx1 yx2 yx3 --
	over >? ( swap ) 
	pick2 >? ( rot ) >r 
	over >? ( swap ) r> | yxmax yxmed yxmin
	over 32 >> over 32 >> -
	0? ( drop triV ; )
	pick2 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	pick2 32 << 32 >> over 32 << 32 >> - 16 <<
	pick3 32 >> pick2 32 >> - /  'dx2 ! 
	over 32 >> 	over 32 << 32 >> 16 << dup  | yf x1 x1 
	pick3 32 >> | yf x1 x1 yi
	tri
	>r >r drop
	over 32 >> over 32 >> -
	0? ( 3drop r> r> 2drop ; )
	pick2 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	swap 32 >> swap
	r> r> rot 32 >>
	tri 2drop ;
	
:xy | x y -- xy ; mix 2 values in 1 64bit number
	32 << swap $ffffffff and or ;
	
:drawl
	0 SDLclear
	
	$ff00 SDLcolor
	
	100 40 xy 
	140 300 xy
	SDLx SDLy xy
	triangle

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
