| qoi encoder/decoder
| PHREDA 2021
^r3/lib/math.r3

| QOI_INDEX   0x00 // 00xxxxxx
| QOI_RUN_8   0x40 // 010xxxxx
| QOI_RUN_16  0x60 // 011xxxxx
| QOI_DIFF_8  0x80 // 10xxxxxx
| QOI_DIFF_16 0xc0 // 110xxxxx
| QOI_DIFF_24 0xe0 // 1110xxxx
| QOI_COLOR   0xf0 // 1111xxxx

#px
#qmagic $716f6966 | fioq
#qw #qh
#qsize
#run 

#index * 256 | 64 rgba values

:hash	
	dup 16 >> xor dup 8 >> xor $3f and 2 << 'index + ;
	
:hashclear
	'index 0 32 fill ;

:runlen | cnt -- 
	( 1? 1 - px db!+ ) drop ;

:img!+ | px --
	dup hash d! db!+ ;

:diff8 | val --
	dup 4 >> $3 and 1 - 'px c+!
	dup 2 >> $3 and 1 - 'px 1 + c+!
	$3 and 1 - 			'px 2 + c+! 
	px img!+ ;
	
:diff16 | val --
	$1f and 15 - 		'px c+! 
	ca@+ dup 4 >> 7 - 	'px 1 + c+!
	$f and 7 - 			'px 2 + c+! 
	px img!+ ;

:diff24 | val --
	$f and 1 << ca@+ dup 7 >> $1 and rot or 15 - 	'px c+! |red
	dup $7c and 2 >> 15 - 							'px 1 + c+! | green
	$3 and 3 << ca@+ dup $e0 and 5 >> rot or 15 - 	'px 2 + c+! | blue
	$1f and 15 - 									'px 3 + c+! | alpha
	px img!+ ;
	
:decode | token -- px
	ca@+
	$c0 nand? ( 					| 00.. index
		2 << 'index + d@ $ffffffff and dup 'px ! img!+ ; 
		) 
	$80 nand? (						| 01..
		$20 nand? ( $1f and runlen ; ) 				| 010. run 8
		$1f and 8 << ca@+ $ff and or 32 + runlen ;	| 011. run 16
		)
	$40 nand? ( diff8 ; )			| 10.. diff 8
	$20 nand? ( diff16 ; )			| 110. diff 16
	$10 nand? ( diff24 ; )			| 1110 diff 24
	$8 and? ( ca@+ $ff and 'px c! ) 
	$4 and? ( ca@+ $ff and 'px 1 + c! )
	$2 and? ( ca@+ $ff and 'px 2 + c! )
	$1 and? ( ca@+ $ff and 'px 3 + c! )
	drop
	px img!+ ;


::qoi_decode | bitmap data -- 1/0
	d@+ qmagic <>? ( drop 0 ; )
	w@+ 'qw !
	w@+ 'qh !
	d@+ 'qsize !
	>a >b
	hashclear
	$ff000000 'px !
	qsize a> + 8 -
	( a> <? decode ) ;
	
|------ encode
:encoderun | run --
	33 <? ( 1 - $40 or ca!+ 0 'run ! ; )
	33 - dup 8 >> $60 or ca!+ ca!+ 
	0 'run !
	;

:runencode | px -- px
	run
	$2020 =? ( encoderun ; )
	pick2 0? ( drop encoderun ; ) 
	2drop
	;

#vr #vg #vb #va

:getdiff
	dup dup hash d! px	
	over $ff and over $ff and - 'vr !
	over 8 >> $ff and over 8 >> $ff and - 'vg !
	over 16 >> $ff and over 16 >> $ff and - 'vb !
	over 24 >> $ff and swap 24 >> $ff and - 'va !

	vr -16 17 between -? ( ; ) drop
	vg -16 17 between -? ( ; ) drop
	vb -16 17 between -? ( ; ) drop
	va -16 17 between -? ( ; ) drop
	
	va 6 <<
	vr 1 + 4 << or
	vg 1 + 2 << or
	vb 1 + or
	$c0 nand? ( $80 or ca!+ 0 ; ) drop
	
	va 11 << 
	vr 15 + 8 << or
	vg 7 + 4 << or
	vb 7 + or
	$e000 nand? ( dup 8 >> $c0 or ca!+ ca!+ 0 ; ) drop

	vr 15 + dup 
	1 >> $e0 or ca!+
	1 and 7 << 
	vg 15 + 2 << or
	vb 15 + 3 >> or ca!+
	vb 15 + $7 and 5 <<
	va 15 + or ca!+
	0 ;
	
:encode | 
	px =? ( 1 'run +! runencode ; )
	run 1? ( dup encoderun ) drop
	dup hash d@ $ffffffff and 
	over =? ( ca!+ ; ) drop 		| INDEX=0
	getdiff 0? ( drop ; ) drop
	$f0 
	vr 1? ( swap 8 or swap ) drop
	vg 1? ( swap 4 or swap ) drop
	vb 1? ( swap 2 or swap ) drop
	va 1? ( swap 1 or swap ) drop
	ca!+
	vr 1? ( over ca!+ ) drop
	vg 1? ( over 8 >> ca!+ ) drop
	vb 1? ( over 16 >> ca!+ ) drop
	va 1? ( over 24 >> ca!+ ) drop
	;
	
::qoi_ecode | bitmap w h data -- size
	>a 'qh ! 'qw !
	qmagic da!+
	qw qh 16 << or da!+ 
	a> 'qsize ! | where size
	$deadbeef da!+
	hashclear
	0 'run !
	$ff000000 'px !
	qh qw * ( 1? 1 - swap
		d@+ $ffffffff and
		encode
		'px ! 
		swap ) 2drop  
	a> qsize - 8 + dup 'qsize d!
	;

	
|---------------------------------------
|---------------------------------------
^r3/lib/mem.r3
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/util/bfont.r3

#textbitmap

#imagens
#ibox [ 100 100 40 40 ]

#pixels
#wi #hi #pi

#code
#csize

:encodeimg
	imagens SDL_LockSurface
	imagens
	16 + 
	d@+ 'wi !
	d@+ 'hi !
	d@+ 'pi !
	4 +
	@ 'pixels !
	mark
	hi wi "%d %d" .println
	
	here 'code !
	pixels wi hi here qoi_ecode 
	dup 'csize ! 
	'here +!
	
	imagens SDL_UnlockSurface
	
	cr cr
	csize "%d" .println
	code csize ( 1? 1 - swap 
		c@+ $ff and "%h " .print 
		swap ) 2drop
	
	;
		
:draw
|	SDLrenderer textbitmap 0 0 SDL_RenderCopy		
	
	0 0 bmat
	$ff00 bcolor
	'ibox 8 + >a
	da@+ da@ "%d %d" sprint bmprint
	

	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:cargar
	"media/img/lolomario.png" IMG_Load 'imagens !
	encodeimg
	;
	
|---------------------------------------
:

	.cls
	
	$1 
	$3 and? ( "1 3 and?" .println )
	$3 nand? ( "1 3 nand?" .println )
	6 nand? (  "1 6 nand?" .println )
	6 and? ( "1 3 and?" .println )
	drop
	
	"r3sdl" 800 600 SDLinit
	bfont1
	cargar
	
|	800 600 SDLframebuffer 'textbitmap !
	
	'draw SDLshow 
	
	SDLquit	;
	;