| test for vm

#str "uno" "dos" "tres" 0

:tes 
	'str + ;

:shift
	-? ( neg >> ; ) << ;
	
|--- fixed point to floating point	
::f2fp | f.p -- fp
	0? ( ; )
	dup 63 >> swap	| sign i
	over + over xor | sign abs(i) 
	dup clz 8 - 	| s i shift
	swap over shift 	| v s shift i
	134 rot - 23 << | s i m | 16 - (fractional part)
	swap $7fffff and or 
	swap $80000000 and or 
	;

::count | s1 -- s1 cnt 
	0 over ( c@+ 1?
		drop swap 1 + swap ) 2drop ;
	
:2sort | x x -- min max
	over <? ( swap ) ;
	
:box2rec | x y x y -- x y w h
	rot 2sort 2swap 2sort | ym M xm M
	over - 2swap over - | xm W ym H
	rot swap ;


:rec2box | x y w h - x y x y
	swap pick3 + swap pick2 + ;	

::xywh64 | x y w h -- 64b
	$ffff and swap
	$ffff and 16 << or swap
	$ffff and 32 << or swap
	$ffff and 48 << or ;	
	
:coso
	rot rot 10 * + swap 100 * + ;
	
#EX_IQM_MAGIC "A" 0
	
|----Boot
: 
|	400 400 100 50 box2rec rec2box xywh64
|	1 2 3 coso
|	1.0 f2fp 
	mem 
	1 over !
	@
	'EX_IQM_MAGIC @
	"hola" count
	tes count 2drop
	;
