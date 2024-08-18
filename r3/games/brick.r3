| Brick Game
| PHREDA
^r3/win/sdl2gfx.r3
^r3/util/arr16.r3

#px	350.0 #py 560.0
#pvx 0.0

:paddle
	$ffffff SDLColor
	px int. py int. 100 20 SDLFRect 
	px pvx +
	0 <? ( 0 nip ) 600.0 >? ( 600.0 nip )
	'px !
	;

#bx 390.0 #by 400.0
#bxv 0.0 #byv 2.0

:hitx bxv neg 'bxv ! ;
:hity byv neg 'byv ! ;

:ball
	$ffffff SDLColor
	bx int. by int. 10 10 SDLFRect 

	bx bxv +
	5.0 <? ( hitx ) 785.0 >? ( hitx )
	'bx !
	by byv +
	5.0 <? ( hity ) 585.0 >? ( hity )
	'by !
	
	by py 10.0 - <? ( drop ; ) drop
	bx 
	px 10.0 - <? ( drop ; )
	px 100.0 + >? ( drop ; )
	px 40.0 + <? ( drop -1.6 'bxv ! -1.6 'byv ! ; )
	px 60.0 + >? ( drop 1.6 'bxv ! -1.6 'byv ! ; )
	0.0 'bxv ! -2.0 'byv !
	drop ;

#bricks 0 0

:tbricks | adr --
	8 + >a a@+ SDLColor 
	a@+ a@+	| x y 
	2dup 60 20 SDLFRect
	bx int. rot 10 - dup 60 + in? ( -1 nip )
	by int. rot 10 - dup 20 + in? ( -1 nip ) 
	and -? ( drop 0 hity ; ) drop
	;
	
:+brick | x y color --
	'tbricks 'bricks p!+ >a a!+ swap a!+ a!+ ;
	
:brick_row | y color --
    20 
	11 ( 1? 1 - swap
		dup pick4 pick4 +brick
		70 + swap ) 4drop ;
		
:game
	$0 SDLcls
	ball
	'bricks p.draw
	paddle
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -2.0 'pvx ! )
	<ri> =? ( 2.0 'pvx ! )
	>le< =? ( 0.0 'pvx ! )
	>ri< =? ( 0.0 'pvx ! )
	drop ;
	
:main
	100 'bricks p.ini
	"brick game" 800 600 SDLinit
	
    50 $ff0000 brick_row
    80 $ff0000 brick_row
    110 $ffa500 brick_row
    140 $ffa500 brick_row
    170 $00ff00 brick_row
    200 $00ff00 brick_row

	'game SDLshow

	SDLquit ;	
	
: main ;