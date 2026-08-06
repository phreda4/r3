^r3/lib/console.r3

#cave * 960 | 40x24

#cave1 (
$01 $14 $0A $0F $0A $0B $0C $0D $0E $0C $0C $0C $0C $0C $96 $6E 
$46 $28 $1E $08 $0B $09 $D4 $20 $00 $10 $14 $00 $3C $32 $09 $00 
$42 $01 $09 $1E $02 $42 $09 $10 $1E $02 $25 $03 $04 $04 $26 $12 
$FF )

#randseed1
#randseed2

:rotr8 | v -- v
	dup 2/ $7f and swap $1 and 7 << or ;
	
:nextRandom 
	randseed2 rotr8 $13 +
	dup 8 >> swap $ff and 
	dup 'randseed2 !
	2/ + randseed1 rotr8 + $ff and 
	'randseed1 !
	;

|------------ DECODE
:cave! | t x y --
	40 * + 'cave + c! ;

#ldx (  0   1  1  1  0  -1  -1  -1 )
#ldy ( -1  -1  0  1  1   1   0  -1 )
#dx #dy

:line! | t x y l d --
	dup 'ldx + c@ 'dx ! 'ldy + c@ 'dy !
	( 1? 1- >r
		pick2 pick2 pick2 cave!
		dy + swap dx + swap
		r> ) 4drop	;

:fillrect! | t x y W H O --
	4drop 2drop
	"bb" .println
	;
	
:rect! | t x y w h --
	1- 'dy ! 1- 'dx !
	0 ( dx <=? | t x y cnt
		2over pick2 + pick3 cave!
		2over pick2 + pick3 dy + cave!
		1+ ) drop
	0 ( dy <=?
		2over 2over + cave!
		2over dx + 2over + cave!
		1+ ) drop
	3drop ;
	
:]acave | a -- n
	a> + c@ ;

:t0
	$3f and ca@+ ca@+ cave! ;
:t1
	$3f and ca@+ ca@+ ca@+ ca@+ line! ;
:t2
	$3f and ca@+ ca@+ ca@+ ca@+ c@+ fillrect! ;
:t3
	$3f and ca@+ ca@+ ca@+ ca@+ rect! ;
	
#tlist t0 t1 t2 t3
	
:decodecave | cave --
	>a
	'cave 7 40 22 * cfill
	3 ( 23 <=? 
		0 ( 39 <=?
			nextRandom
			1								| obj
			0 ( 3 <=?						| obj cnt
				randseed1 					| obj cnt rnd
				over $1c + ]acave <? ( 		| obj cnt rnd
					rot drop 				| cnt rnd
					over $18 + ]acave -rot	| obj cnt rnd
					) drop
				1+ ) drop	| y x obj
			over pick3 cave!
			1+ ) drop
		1+ ) drop
	$20 a+
	( ca@+ -1 <>?
		dup 6 >> 3 and 3 <<	'tlist + @ ex
		) drop 
	$7 0 2 40 22 rect!
	;
		
|------------ SHOW
#tchars " .wmof*W<<<<>>>>OOoo^^vv                                                "
:.ec
	$3f and 'tchars + c@ .emit
	;

:showsb
	'cave 80 + >a
	1 ( 23 <? 1+
		dup "%d " .print
		.sp
		40 ( 1? 1-
			ca@+ .ec
			) drop
		.cr
		) drop ;
		
|------------ MAIN	
:main
	"decode bdash" .println
	'cave1 decodecave

	showsb
	
	;
	
: main waitesc ;